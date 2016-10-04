/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LPSolverI.h"

#if TARGET_OS_IPHONE==0
#import "LPGurobi.h"
#endif

@interface LPDoubleVarSnapshot : NSObject  {
   ORUInt    _name;
   ORDouble   _value;
   ORDouble   _reducedCost;
   
}
-(LPDoubleVarSnapshot*) initLPFloatVarSnapshot: (LPVariableI*) v name: (ORInt) name;
-(ORDouble) doubleValue;
-(ORDouble) reducedCost;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation LPDoubleVarSnapshot
-(LPDoubleVarSnapshot*) initLPFloatVarSnapshot: (LPVariableI*) v name: (ORInt) name
{
   self = [super init];
   _name = name;
   _value = [v doubleValue];
   _reducedCost = [v reducedCost];
   return self;
}
-(ORUInt) getId
{
   return _name;
}
-(ORDouble) doubleValue
{
   return _value;
}
-(ORDouble) reducedCost
{
   return _reducedCost;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      LPDoubleVarSnapshot* other = object;
      if (_name == other->_name) {
         return (_value == other->_value) && (_reducedCost == other->_reducedCost);
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + (ORInt) _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"float(%d) : (%f,%f)",_name,_value,_reducedCost];
   return buf;
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_reducedCost];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_reducedCost];
   return self;
}
@end

@interface LPConstraintSnapshot : NSObject {
   ORUInt    _name;
   ORDouble   _dual;
}
-(LPConstraintSnapshot*) initLPConstraintSnapshot: (LPConstraintI*) cstr name: (ORInt) name;
-(ORDouble) dual;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation LPConstraintSnapshot
-(LPConstraintSnapshot*) initLPConstraintSnapshot: (LPConstraintI*) cstr name: (ORInt) name
{
   self = [super init];
   _name = name;
   _dual = [cstr dual];
   return self;
}
-(ORUInt) getId
{
   return _name;
}
-(ORDouble) dual
{
   return _dual;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      LPConstraintSnapshot* other = object;
      if (_name == other->_name) {
         return _dual == other->_dual;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + (ORInt) _dual;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"lp(constraint)(%d) : (%f)",_name,_dual];
   return buf;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_dual];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_dual];
   return self;
}
@end


@implementation LPConstraintI;

-(LPConstraintI*) initLPConstraintI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   if (size < 0)
      @throw [[NSException alloc] initWithName:@"LPConstraint Error"
                                        reason:@"Constraint has negative size"
                                      userInfo:nil];
   self = [super init];
   _solver = solver;
   _idx = -1;
   _size = size;
   _maxSize = 2*size;
   if (_maxSize == 0)
      _maxSize = 1;
   _var = (LPVariableI**) malloc(_maxSize * sizeof(LPVariableI*));
   for(ORInt i = 0; i < _size; i++)
      _var[i] = var[i];
   _col = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   for(ORInt i = 0; i < _size; i++)
      _coef[i] = coef[i];
   _rhs = rhs;
   
   _tmpVar = NULL;
   _tmpCoef = NULL;
   return self;
}

-(void) dealloc
{
   free(_var);
   if (_col)
      free(_col);
   free(_coef);
   [super dealloc];
}
-(id) takeSnapshot: (ORInt) id
{
   return [[LPConstraintSnapshot alloc] initLPConstraintSnapshot: self name: id];
}
-(void) resize
{
   if (_size == _maxSize) {
      LPVariableI** nvar = (LPVariableI**) malloc(2 * _maxSize * sizeof(LPVariableI*));
      ORDouble* ncoef = (ORDouble*) malloc(2 * _maxSize * sizeof(ORDouble));
      for(ORInt i = 0; i < _size; i++) {
         nvar[i] = _var[i];
         ncoef[i] = _coef[i];
      }
      free(_var);
      free(_coef);
      _var = nvar;
      _coef = ncoef;
      _maxSize *= 2;
   }
}
-(LPConstraintType) type
{
   return _type;
}
-(ORInt) size
{
   return _size;
}
-(void)projectVariable:(LPVariableI*)var
{
   ORInt k = -1;
   ORDouble coef;
   for(ORInt i=0;i < _size;i++) {
      if (_var[i] == var) {
         k = i;
         coef = _coef[i];
         break;
      }
   }
   if (k >= 0) {
      for(ORInt i=k;i < _size-1;i++) {
         _var[i]  = _var[i + 1];
         _coef[i] = _coef[i + 1];
      }
      --_size;
      assert(var.low == var.up);
      _rhs -= coef * var.low;
   }
}
-(LPVariableI**) var
{
   _tmpVar = (LPVariableI**) malloc(_size * sizeof(LPVariableI*));
   for(ORInt i = 0; i < _size; i++)
      _tmpVar[i] = _var[i];
   return _tmpVar;
}
-(LPVariableI*) var: (ORInt) i
{
   return _var[i];
}
-(ORInt*) col
{
   _col = (ORInt*) malloc(_size * sizeof(ORInt));
   for(ORInt i = 0; i < _size; i++)
      _col[i] = [_var[i] idx];
   return _col;
}
-(ORInt) col: (ORInt) i
{
   return [_var[i] idx];
}
-(ORDouble*) coef
{
   _tmpCoef = (ORDouble*) malloc(_size * sizeof(ORDouble));
   for(ORInt i = 0; i < _size; i++)
      _tmpCoef[i] = _coef[i];
   return _tmpCoef;
}
-(ORDouble) coef: (ORInt) i
{
   return _coef[i];
}

-(ORDouble) rhs
{
   return _rhs;
}
-(ORInt) idx
{
   return _idx;
}
-(void) setIdx: (ORInt) idx
{
   _idx = idx;
}
-(void) del
{
   for(ORInt i = 0; i < _size; i++)
      [_var[i] delConstraint: self];
   _idx = -1;
}
-(void) delVariable: (LPVariableI*) var
{
   // linear algorithm: could be replaced by log(n)
   int k = -1;
   for(ORInt i = 0; i < _size; i++)
      if (_var[i] == var) {
         k = i;
         break;
      }
   if (k >= 0) {
      _size--;
      for(ORInt i = k; i < _size; i++) {
         _coef[i] = _coef[i+1];
         _var[i] = _var[i+1];
      }
   }
}
-(void) addVariable: (LPVariableI*) var coef: (ORDouble) coef
{
   [self resize];
   _var[_size] = var;
   _coef[_size] = coef;
   _size++;
}
-(void) print: (char*) o
{
   for(ORInt i = 0; i < _size; i++) {
      printf("%f x%d",_coef[i],[_var[i] idx]);
      if (i < _size - 1)
         printf(" + ");
   }
   printf(" ");
   printf("%s",o);
   printf(" ");
   printf("%f\n",_rhs);
}

-(void) print
{
   [self print: "?"];
}
-(ORDouble) dual
{
   return [_solver dual: self];
}
-(ORInt) nb
{
   return _nb;
}
-(void) setNb: (ORInt) nb
{
   _nb = nb;
}
-(NSString*)description {
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(ORInt i =0;i < _size;i++) {
      [buf appendFormat:@"%f x_%d %c ",_coef[i],_var[i].getId, i < _size - 1 ? '+' : ' '];
   }
   switch(_type) {
      case LPleq: [buf appendFormat:@" ≤ %f",_rhs];break;
      case LPgeq: [buf appendFormat:@" ≥ %f",_rhs];break;
      case LPeq:  [buf appendFormat:@" = %f",_rhs];break;
   }
   return buf;
}
-(ORInterval) evaluation
{
   ORIReady();
   ORInterval ttl = createORI1(0.0);
   for(ORInt i = 0;i < _size;i++) {
      ORInterval term = ORIMul(createORI1(_coef[i]),createORI2(_var[i].low,_var[i].up));
      ttl = ORIAdd(ttl,term);
   }
   return ttl;
}
-(ORBool)redundant
{
   ORInterval bnds = [self evaluation];
   ORInterval ev = ORISub(bnds,createORI1(_rhs));
   switch(_type) {
      case LPleq:
         ev = ORISub(ev,createORI1(1e-14));
         return ORISureNegative(ev);
      case LPgeq:
         ev = ORIAdd(ev,createORI1(1e-14));
         return ORISurePositive(ev);
      case LPeq:
         return ORIBound(ev, 1e-12);
   }
}
@end


@implementation LPConstraintLEQ;

-(LPConstraintI*) initLPConstraintLEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   self = [super initLPConstraintI: solver size: size var: var coef: coef rhs: rhs];
   _type = LPleq;
   return self;
}
-(void) print
{
   [super print: "<="];
}
@end

@implementation LPConstraintGEQ;

-(LPConstraintI*) initLPConstraintGEQ: (LPSolverI*) solver size:  (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   self = [super initLPConstraintI: solver size: size var: var coef: coef rhs: rhs];
   _type = LPgeq;
   return self;
}
-(void) print
{
   [super print: ">="];
}

@end

@implementation LPConstraintEQ;

-(LPConstraintI*) initLPConstraintEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   self = [super initLPConstraintI: solver size: size var: var coef: coef rhs: rhs];
   _type = LPeq;
   return self;
}
-(void) print
{
   [super print: "="];
}
@end



@implementation LPObjectiveI;

-(LPObjectiveI*) initLPObjectiveI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst
{
   self = [super init];
   _solver = solver;
   _size = size;
   _maxSize = 2*size;
   _posted = false;
   _cst = 0.0;
   if (_maxSize == 0)
      _maxSize++;
   _var = (LPVariableI**) malloc(_maxSize * sizeof(LPVariableI*));
   for(ORInt i = 0; i < _size; i++)
      _var[i] = var[i];
   _col = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   for(ORInt i = 0; i < _size; i++)
      _coef[i] = coef[i];
   _cst = cst;
   _tmpVar = NULL;
   _tmpCoef = NULL;
   return self;
}
-(void) resize
{
   if (_size == _maxSize) {
      LPVariableI** nvar = (LPVariableI**) malloc(2 * _maxSize * sizeof(LPVariableI*));
      ORDouble* ncoef = (ORDouble*) malloc(2 * _maxSize * sizeof(ORDouble));
      for(ORInt i = 0; i < _size; i++) {
         nvar[i] = _var[i];
         ncoef[i] = _coef[i];
      }
      free(_var);
      free(_coef);
      _var = nvar;
      _coef = ncoef;
      _maxSize *= 2;
   }
}

-(void) dealloc
{
   if (_col)
      free(_col);
   free(_var);
   free(_coef);
   [super dealloc];
}
-(LPObjectiveType) type
{
   return _type;
}
-(ORInt) size
{
   return _size;
}
-(NSString*)description {
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   switch(_type) {
      case LPminimize: [buf appendString:@"min "];break;
      case LPmaximize: [buf appendString:@"max "];break;
   }
   for(ORInt i =0;i < _size;i++) {
      [buf appendFormat:@"%f x_%d %c ",_coef[i],_var[i]->_idx, i < _size - 1 ? '+' : ' '];
   }
   return buf;
}
-(void)projectVariable:(LPVariableI*)var
{
   [self delVariable:var];
   assert(var.low == var.up);
   _cst += var.objCoef * var.low;
}
-(LPVariableI**) var
{
   _tmpVar = (LPVariableI**) malloc(_size * sizeof(LPVariableI*));
   for(ORInt i = 0; i < _size; i++)
      _tmpVar[i] = _var[i];
   return _tmpVar;
}
-(ORInt*) col
{
   _col = (ORInt*) malloc(_size * sizeof(ORInt));
   for(ORInt i = 0; i < _size; i++)
      _col[i] = [_var[i] idx];
   return _col;
}
-(ORDouble*) coef
{
   _tmpCoef = (ORDouble*) malloc(_size * sizeof(ORDouble));
   for(ORInt i = 0; i < _size; i++)
      _tmpCoef[i] = _coef[i];
   return _tmpCoef;
}
-(void) print
{
   for(ORInt i = 0; i < _size; i++) {
      printf("%f x%d",_coef[i],[_var[i] idx]);
      if (i < _size - 1)
         printf(" + ");
   }
   printf("\n");
}
-(void) delVariable: (LPVariableI*) var
{
   // linear algorithm: could be replaced by log(n)
   int k = -1;
   for(ORInt i = 0; i < _size; i++)
      if (_var[i] == var) {
         k = i;
         break;
      }
   if (k >= 0) {
      _size--;
      for(ORInt i = k; i < _size; i++) {
         _coef[i] = _coef[i+1];
         _var[i] = _var[i+1];
      }
   }
}
-(void) addVariable: (LPVariableI*) var coef: (ORDouble) coef
{
   [self resize];
   _var[_size] = var;
   _coef[_size] = coef;
   _size++;
}
-(void) addCst: (ORDouble) cst
{
   _cst += cst;
}
-(void) setPosted
{
   _posted = true;
}
-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueReal: [_solver lpValue] + _cst minimize: true];
}
-(ORInt) nb
{
   return _nb;
}
-(void) setNb: (ORInt) nb
{
   _nb = nb;
}

@end


@implementation LPMinimize;

-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef
{
   self = [super initLPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
   _type = LPminimize;
   return self;
}
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst
{
   self = [super initLPObjectiveI: solver size: size var: var coef: coef cst: cst];
   _type = LPminimize;
   return self;
}
-(void) print
{
   printf("minimize ");
   [super print];
}
-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueReal: [_solver lpValue] + _cst minimize: true];
}

@end

@implementation LPMaximize;

-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef
{
   self = [super initLPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
   _type = LPmaximize;
   return self;
}
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst
{
   self = [super initLPObjectiveI: solver size: size var: var coef: coef cst: cst];
   _type = LPmaximize;
   return self;
}
-(void) print
{
   printf("maximize ");
   [super print];
}
-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueReal: [_solver lpValue] + _cst minimize: false];
}
@end

@implementation LPVariableI
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver low: (ORDouble) low up: (ORDouble) up
{
   self = [super init];
   _hasBounds = true;
   _solver = solver;
   _idx = -1;
   _low = low;
   _up = up;
   
   // data structure to preserve the constraint information
   _maxSize = 8;
   _size = 0;
   _cstr = (LPConstraintI**) malloc(_maxSize * sizeof(LPConstraintI*));
   _cstrIdx = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   
   return self;
}
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver
{
   self = [super init];
   _hasBounds = false;
   _solver = solver;
   _idx = -1;
   
   // data structure to preserve the constraint information
   _maxSize = 8;
   _size = 0;
   _cstr = (LPConstraintI**) malloc(_maxSize * sizeof(LPConstraintI*));
   _cstrIdx = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   
   return self;
}
-(id) takeSnapshot: (ORInt) id
{
   return [[LPDoubleVarSnapshot alloc] initLPFloatVarSnapshot: self name: id];
}
-(ORBool) hasBounds
{
   return _hasBounds;
}
-(void) dealloc
{
   free(_cstr);
   if (_cstrIdx)
      free(_cstrIdx);
   free(_coef);
   [super dealloc];
}
-(ORInt)downLock
{
   ORInt dl = 0;
   for(ORInt i=0;i<_size;i++) {
      if (_cstr[i] == nil) continue;
      switch(_cstr[i].type) {
         case LPleq: dl += _coef[i] <= 0;break;
         case LPgeq: dl += _coef[i] >= 0;break;
         case LPeq:  dl += _coef[i] == 0;break;
      }
   }
   return dl;
}
-(ORInt)upLock
{
   ORInt ul = 0;
   for(ORInt i=0;i<_size;i++) {
      if (_cstr[i] == nil) continue;
      switch(_cstr[i].type) {
         case LPleq: ul += _coef[i] >= 0;break;
         case LPgeq: ul += _coef[i] <= 0;break;
         case LPeq:  ul += _coef[i] == 0;break;
      }
   }
   return ul;
}
-(ORInt)locks
{
   ORInt dl = [self downLock],ul = [self upLock];
   return min(dl, ul);
}
-(ORDouble)fractionality
{
   ORDouble frv = _idx == -1 ? _low : [_solver doubleValue:self];
   ORDouble rv  = fabs(frv - floor(frv + 0.5));
   return rv;
}
-(ORDouble)nearestInt
{
   ORDouble frv = _idx == -1 ? _low : [_solver doubleValue:self];
   ORDouble ni = floor(frv + 0.5);
   return ni;
}
-(ORBool)trivialDownRoundable
{
   return [self upLock] == _size;
}
-(ORBool)trivialUpRoundable
{
   return [self downLock] == _size;
}
-(ORBool)triviallyRoundable
{
   return [self trivialDownRoundable] || [self trivialUpRoundable];
}
-(ORBool)fixable
{
   return [self canFixDown] || [self canFixUp];
}
-(ORBool) canFixDown
{
   return [self trivialDownRoundable] && (([_obj type] == LPminimize && _objCoef > 0) ||
                                          ([_obj type] == LPmaximize && _objCoef < 0));
}
-(ORBool) canFixUp
{
   return [self trivialUpRoundable] && (([_obj type] == LPminimize && _objCoef < 0) ||
                                        ([_obj type] == LPmaximize && _objCoef > 0));
}
-(ORBool) minLockDown
{
   ORInt dl = [self downLock],ul = [self upLock];
   if (dl > ul)
      return true;
   else return false;
}
-(ORBool) fixMe
{
   ORBool fixed = false;
   if (_low < _up && [self canFixDown]) {
      _up = _low;
      fixed = true;
   }
   if (_low < _up && [self canFixUp]) {
      _low = _up;
      fixed = true;
   }
   return fixed;
}
-(ORInt) idx
{
   return _idx;
}
-(void) setIdx: (ORInt) idx
{
   _idx = idx;
}
-(ORInt) nb
{
   return _nb;
}
-(void) setNb: (ORInt) nb
{
   _nb = nb;
}

-(ORDouble) low
{
   return _low;
}
-(ORDouble) up
{
   return _up;
}
-(ORDouble) objCoef
{
   return _objCoef;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var<LP>(x_%d[%d],(%f,%f) [%f .. %f | %f])",self.getId,_idx,_low,_up,[_solver lowerBound:self],[_solver upperBound:self],[_solver doubleValue:self]];
   return buf;
}
-(void) resize
{
   if (_size == _maxSize) {
      LPConstraintI** ncstr = (LPConstraintI**) malloc(2 * _maxSize * sizeof(LPConstraintI*));
      ORDouble* ncoef = (ORDouble*) malloc(2 * _maxSize * sizeof(ORDouble));
      for(ORInt i = 0; i < _size; i++) {
         ncstr[i] = _cstr[i];
         ncoef[i] = _coef[i];
      }
      free(_cstr);
      free(_coef);
      _cstr = ncstr;
      _coef = ncoef;
      _maxSize *= 2;
   }
}
-(void) addConstraint: (LPConstraintI*) c coef: (ORDouble) coef
{
   [self resize];
   _cstr[_size] = c;
   _coef[_size] = coef;
   _size++;
}
-(void) delConstraint: (LPConstraintI*) c
{
   int k = 0;
   for(ORInt i = 0; i < _size; i++) {
      if (_cstr[i] == c) {
         k = i;
         break;
      }
   }
   if (k < _size) {
      _size--;
      for(ORInt i = k; i < _size; i++) {
         _cstr[i] = _cstr[i+1];
         _coef[i] = _coef[i+1];
      }
   }
}
-(void) del
{
   [_obj delVariable: self];
   for(ORInt i = 0; i < _size; i++)
      [_cstr[i] delVariable: self];
   _idx = -1;
}
-(void) addObjective: (LPObjectiveI*) obj coef: (ORDouble) coef
{
   _obj = obj;
   _objCoef = coef;
}
-(void) print
{
   printf("variable %d:",_idx);
   printf(" obj: %f",_objCoef);
   printf(" cstrs: ");
   for(ORInt i = 0; i < _size; i++)
      printf("(%d,%f)",[_cstr[i] idx],_coef[i]);
}
-(LPColumnI*) column
{
   return [_solver createColumn: _low up:_up size:_size obj:_objCoef cstr:_cstr coef:_coef];
}
-(ORDouble) doubleValue
{
   return [_solver doubleValue:self];
}

-(ORDouble) reducedCost
{
   return [_solver reducedCost: self];
}
-(ORBool) isInteger
{
   return false;
}
@end

@implementation LPParameterI
-(LPParameterI*) initLPParameterI: (LPSolverI*) solver
{
    self = [super init];
    _solver = solver;
    _cstrIdx = -1;
    _coefIdx = -1;
    return self;
}
-(ORInt) cstrIdx
{
    return _cstrIdx;
}
-(void) setCstrIdx: (ORInt) idx
{
    _cstrIdx = idx;
}
-(ORDouble) doubleValue
{
    return [_solver paramValue: self];
}
-(void) setDoubleValue: (ORDouble)val
{
    [_solver setParam: self value: val];
}
-(ORInt) coefIdx
{
    return _coefIdx;
}
-(void) setCoefIdx: (ORInt) idx
{
    _coefIdx = idx;
}
-(NSString*)description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"%f",[self doubleValue]];
    return buf;
}
-(ORBool) isInteger
{
    return NO;
}
@end

@implementation LPColumnI

-(LPColumnI*) initLPColumnI: (LPSolverI*) solver
                        low: (ORDouble) low
                         up: (ORDouble) up
                       size: (ORInt) size
                        obj: (ORDouble) obj
                       cstr: (LPConstraintI**) cstr
                       coef: (ORDouble*) coef

{
   self = [super init];
   _solver = solver;
   _hasBounds = true;
   _low = low;
   _up = up;
   _size = size;
   _maxSize = size;
   if (_maxSize == 0)
      _maxSize++;
   _objCoef = obj;
   _cstr = (LPConstraintI**) malloc(_maxSize * sizeof(LPConstraintI*));
   for(ORInt i = 0; i < _size; i++)
      _cstr[i] = cstr[i];
   _cstrIdx = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   for(ORInt i = 0; i < _size; i++)
      _coef[i] = coef[i];
   _tmpCstr = NULL;
   _tmpCoef = NULL;
   return self;
}

-(LPColumnI*) initLPColumnI: (LPSolverI*) solver
                        low: (ORDouble) low
                         up: (ORDouble) up
{
   self = [super init];
   _solver = solver;
   _hasBounds = true;
   _low = low;
   _up = up;
   _size = 0;
   _maxSize = 8;
   _cstr = (LPConstraintI**) malloc(_maxSize * sizeof(LPConstraintI*));
   _cstrIdx = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   return self;
}
-(LPColumnI*) initLPColumnI: (LPSolverI*) solver
{
   self = [super init];
   _solver = solver;
   _hasBounds = false;
   _size = 0;
   _maxSize = 8;
   _cstr = (LPConstraintI**) malloc(_maxSize * sizeof(LPConstraintI*));
   _cstrIdx = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   return self;
}
-(LPVariableI*)theVar
{
   return _theVar;
}
-(void) dealloc
{
   if (_cstrIdx)
      free(_cstrIdx);
   free(_cstr);
   free(_coef);
   if (_tmpCstr)
      free(_tmpCstr);
   if (_tmpCoef)
      free(_tmpCoef);
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   [buf appendFormat:@"<%f>[",_objCoef];
   for(ORInt i=0;i<_size;i++)
      [buf appendFormat:@"%f,",_coef[i]];
   [buf appendString:@"]"];
   return buf;
}
-(void) resize
{
   if (_size == _maxSize) {
      LPConstraintI** ncstr = (LPConstraintI**) malloc(2 * _maxSize * sizeof(LPConstraintI*));
      ORDouble* ncoef = (ORDouble*) malloc(2 * _maxSize * sizeof(ORDouble));
      for(ORInt i = 0; i < _size; i++) {
         ncstr[i] = _cstr[i];
         ncoef[i] = _coef[i];
      }
      free(_cstr);
      free(_coef);
      _cstr = ncstr;
      _coef = ncoef;
      _maxSize *= 2;
   }
}

-(ORInt) idx
{
   return _idx;
}
-(void) setIdx: (ORInt) idx
{
   _idx = idx;
}
-(ORBool) hasBounds
{
   return _hasBounds;
}
-(ORDouble) low
{
   return _low;
}
-(ORDouble) up
{
   return _up;
}
-(ORDouble) objCoef
{
   return _objCoef;
}
-(ORInt) size
{
   return _size;
}
-(LPConstraintI**) cstr
{
   if (_tmpCstr)
      free(_tmpCstr);
   _tmpCstr = (LPConstraintI**) malloc(_size * sizeof(LPConstraintI*));
   for(ORInt i = 0; i < _size; i++)
      _tmpCstr[i] = _cstr[i];
   return _tmpCstr;
}
-(ORInt*) cstrIdx
{
   if (_cstrIdx)
      free(_cstrIdx);
   _cstrIdx = (ORInt*) malloc(_size * sizeof(ORInt));
   for(ORInt i = 0; i < _size; i++)
      _cstrIdx[i] = [_cstr[i] idx];
   return _cstrIdx;
}
-(ORDouble*) coef
{
   if (_tmpCoef)
      free(_tmpCoef);
   _tmpCoef = (ORDouble*) malloc(_size * sizeof(ORDouble));
   for(ORInt i = 0; i < _size; i++)
      _tmpCoef[i] = _coef[i];
   return _tmpCoef;
}
-(void) fill: (LPVariableI*) v obj: (LPObjectiveI*) obj
{
   // Fill the variables
   if (obj)
      [v addObjective: obj coef: _objCoef];
   for(ORInt i = 0; i < _size; i++) {
      if ([_cstr[i] idx] < 0)
         @throw [[NSException alloc] initWithName:@"LPSolver Error"
                                           reason:@"Constraint is not present when adding column"
                                         userInfo:nil];
      [v addConstraint: _cstr[i] coef: _coef[i]];
   }
   // fill the objective
   if (obj) {
      [obj addVariable: v coef: _objCoef];
   }
   // fill the constraints
   for(ORInt i = 0; i < _size; i++)
      [_cstr[i] addVariable: v coef: _coef[i]];
}
-(void) addObjCoef: (ORDouble) coef
{
   _objCoef = coef;
}
-(void) addConstraint: (LPConstraintI*) cstr coef: (ORDouble) coef
{
   [self resize];
   _cstr[_size] = cstr;
   _coef[_size] = coef;
   _size++;
}
-(ORInt) nb
{
   return _nb;
}
-(void) setNb: (ORInt) nb
{
   _nb = nb;
}
@end


@implementation LPLinearTermI

-(LPLinearTermI*) initLPLinearTermI: (LPSolverI*) solver
{
   self = [super init];
   _solver = solver;
   _size = 0;
   _maxSize = 8;
   if (_maxSize == 0)
      _maxSize++;
   _var = (LPVariableI**) malloc(_maxSize * sizeof(LPVariableI*));
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   return self;
}
-(void) dealloc
{
   free(_var);
   free(_coef);
   [super dealloc];
}
-(void) resize
{
   if (_size == _maxSize) {
      LPVariableI** nvar = (LPVariableI**) malloc(2 * _maxSize * sizeof(LPVariableI*));
      ORDouble* ncoef = (ORDouble*) malloc(2 * _maxSize * sizeof(ORDouble));
      for(ORInt i = 0; i < _size; i++) {
         nvar[i] = _var[i];
         ncoef[i] = _coef[i];
      }
      free(_var);
      free(_coef);
      _var = nvar;
      _coef = ncoef;
      _maxSize *= 2;
   }
}
-(ORInt) size
{
   return _size;
}
-(LPVariableI**) var
{
   return _var;
}
-(ORDouble*) coef
{
   return _coef;
}
-(ORDouble) cst
{
   return _cst;
}
-(void) add: (ORDouble) cst
{
   _cst = cst;
}
-(void) add: (ORDouble) coef times: (LPVariableI*) var
{
   [self resize];
   _var[_size] = var;
   _coef[_size] = coef;
   _size++;
}
-(void) close
{
   int lidx = MAXINT;
   int uidx = -1;
   for(ORInt i = 0; i < _size; i++) {
      int idx = [_var[i] idx];
      if (idx < lidx)
         lidx = idx;
      if (idx > uidx)
         uidx = idx;
   }
   int sizeIdx = (uidx - lidx + 1);
   ORDouble* bucket = (ORDouble*) alloca(sizeIdx * sizeof(ORDouble));
   bzero(bucket,sizeIdx * sizeof(ORDouble));
   LPVariableI** bucketVar = (LPVariableI**) alloca(sizeIdx * sizeof(LPVariableI*));
   bucket -= lidx;
   bucketVar -= lidx;
   for(ORInt i = 0; i < _size; i++) {
      int idx = getLPId(_var[i]);
      bucket[idx] += _coef[i];
      bucketVar[idx] = _var[i];
   }
   int nb = 0;
   for(ORInt i = lidx; i <= uidx; i++) {
      if (bucket[i] != 0) {
         _var[nb] = bucketVar[i];
         _coef[nb] = bucket[i];
         nb++;
      }
   }
   _size = nb;
}
@end

@implementation LPSolverI

+(LPSolverI*) create
{
   return [[LPSolverI alloc] initLPSolverI];
}
-(LPSolverI*) initLPSolverI
{
   self = [super init];
#if TARGET_OS_IPHONE==0
   _lp = [[LPGurobiSolver alloc] init];
#else
   _lp = nil; // [ldm] we do not have GUROBI on IOS
#endif
   _nbVars = 0;
   _maxVars = 32;
   _var = (LPVariableI**) malloc(_maxVars * sizeof(LPVariableI*));
   _nbCstrs = 0;
   _maxCstrs = 32;
   _cstr = (LPConstraintI**) malloc(_maxCstrs * sizeof(LPConstraintI*));
   _obj = 0;
   _isClosed = false;
   _createdVars = 0;
   _createdCstrs = 0;
   _createdObjs = 0;
   _createdCols = 0;
   _oStore = [[NSMutableArray alloc] initWithCapacity:32];
   _pStore = [[NSMutableArray alloc] initWithCapacity:32];
   _basis  = nil;
   return self;
}
-(void) dealloc
{
   free(_var);
   free(_cstr);
   [_lp release];
   [_oStore release];
   [_pStore release];
   [_basis release];
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return self;
}
-(void) addVariable: (LPVariableI*) v
{
   if (_nbVars == _maxVars) {
      LPVariableI** nvar = (LPVariableI**) malloc(2 * _maxVars * sizeof(LPVariableI*));
      for(ORInt i = 0; i < _nbVars; i++)
         nvar[i] = _var[i];
      free(_var);
      _var = nvar;
      _maxVars *= 2;
   }
   [v setIdx: _nbVars];
   _var[_nbVars++] = v;
}
-(void)enumerateColumnWith:(void(^)(LPColumnI*))block
{
   @autoreleasepool {
      for(ORInt i=0;i < _nbVars;i++)
         block([_var[i] column]);
   }
}

-(LPVariableI*) createVariable
{
   LPVariableI* v = [[LPVariableI alloc] initLPVariableI: self];
   [v setId: _createdVars];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}
-(LPVariableI*) createVariable: (ORDouble) low up: (ORDouble) up
{
   LPVariableI* v = [[LPVariableI alloc] initLPVariableI: self low: low up: up];
   [v setId: _createdVars];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}

-(LPColumnI*) createColumn: (ORDouble) low up: (ORDouble) up size: (ORInt) size obj: (ORDouble) obj cstr: (LPConstraintI**) cstr coef: (ORDouble*) coef
{
   LPColumnI* c = [[LPColumnI alloc] initLPColumnI: self low: low up: up size: size obj: obj cstr: cstr coef: coef];
   [c setNb: _createdCols++];
   [self trackMutable: c];
   return c;
}
-(LPColumnI*) createColumn: (ORDouble) low up: (ORDouble) up
{
   LPColumnI* c = [[LPColumnI alloc] initLPColumnI: self low: low up: up];
   [c setNb: _createdCols++];
   [self trackMutable: c];
   return c;
}
-(LPColumnI*) createColumn
{
   LPColumnI* c = [[LPColumnI alloc] initLPColumnI: self];
   [c setNb: _createdCols++];
   [self trackMutable: c];
   return c;
}
-(LPLinearTermI*) createLinearTerm
{
   LPLinearTermI* o = [[LPLinearTermI alloc] initLPLinearTermI: self];
   [self trackMutable: o];
   return o;
}
-(LPConstraintI*) addConstraint: (LPConstraintI*) cstr
{
   if (_nbCstrs == _maxCstrs) {
      LPConstraintI** ncstr = (LPConstraintI**) malloc(2 * _maxCstrs * sizeof(LPConstraintI*));
      for(ORInt i = 0; i < _nbCstrs; i++)
         ncstr[i] = _cstr[i];
      free(_cstr);
      _cstr = ncstr;
      _maxCstrs *= 2;
   }
   _cstr[_nbCstrs++] = cstr;
   
   int size = [cstr size];
   LPVariableI** var = [cstr var];
   ORDouble* coef = [cstr coef];
   for(ORInt i = 0; i < size; i++)
      [var[i] addConstraint: cstr coef: coef[i]];
   free(coef);
   return cstr;
   
}
-(LPConstraintI*) createLEQ: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createLEQ: t rhs: rhs];
}

-(LPConstraintI*) createLEQ: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst
{
   LPLinearTermI* t = [self createLinearTerm];
   id<ORIntRange> R = [var range];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++) 
      [t add: [coef at: i] times: var[i]];
   return [self createLEQ: t rhs: -cst];
}
-(LPConstraintI*) createGEQ: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst
{
   LPLinearTermI* t = [self createLinearTerm];
   id<ORIntRange> R = [var range];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createGEQ: t rhs: -cst];
}
-(LPConstraintI*) createEQ: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst
{
   LPLinearTermI* t = [self createLinearTerm];
   id<ORIntRange> R = [var range];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++) 
      [t add: [coef at: i] times: var[i]];
   return [self createEQ: t rhs: -cst];
}
-(LPObjectiveI*)  createObjectiveMinimize: (LPVariableI*) x
{
   LPLinearTermI* t = [self createLinearTerm];
   [t add: 1 times: x];
   return [self createMinimize: t];
}
-(LPObjectiveI*)  createObjectiveMaximize: (LPVariableI*) x
{
   LPLinearTermI* t = [self createLinearTerm];
   [t add: 1 times: x];
   return [self createMaximize: t];
}

-(LPConstraintI*) createGEQ: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createGEQ: t rhs: rhs];
   
}
-(LPConstraintI*) createEQ: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createEQ: t rhs: rhs];
}
-(LPObjectiveI*) createMinimize: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createMinimize: t];
}
-(LPObjectiveI*) createMaximize: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createMaximize: t];
}
-(LPObjectiveI*) createMaximize: (LPLinearTermI*) t
{
   [t close];
   LPObjectiveI* o = [[LPMaximize alloc] initLPMaximize: self size: [t size] var: [t var] coef: [t coef]];
   [o setNb: _createdObjs++];
   [self trackMutable: o];
   return o;
}
-(LPObjectiveI*) createMinimize: (LPLinearTermI*) t
{
   [t close];
   LPObjectiveI* o = [[LPMinimize alloc] initLPMinimize: self size: [t size] var: [t var] coef: [t coef]];
   [o setNb: _createdObjs++];
   [self trackMutable: o];
   return o;
}
-(LPObjectiveI*)  createObjectiveMinimize: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef
{
   LPLinearTermI* t = [self createLinearTerm];
   ORInt low = [var low];
   ORInt up = [var up];
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createMinimize: t];
}
-(LPObjectiveI*)  createObjectiveMaximize: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef
{
   LPLinearTermI* t = [self createLinearTerm];
   ORInt low = [var low];
   ORInt up = [var up];
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createMaximize: t];
}

-(LPConstraintI*) createLEQ: (LPLinearTermI*) t rhs: (ORDouble) rhs;
{
   [t close];
   LPConstraintI* c = [[LPConstraintLEQ alloc] initLPConstraintLEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackMutable: c];
   return c;
}
-(LPConstraintI*) createGEQ: (LPLinearTermI*) t rhs: (ORDouble) rhs;
{
   [t close];
   LPConstraintI* c = [[LPConstraintGEQ alloc] initLPConstraintGEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackMutable: c];
   return c;
}
-(LPConstraintI*) createEQ: (LPLinearTermI*) t rhs: (ORDouble) rhs;
{
   [t close];
   LPConstraintI* c = [[LPConstraintEQ alloc] initLPConstraintEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackMutable: c];
   return c;
}

-(LPConstraintI*) postConstraint: (LPConstraintI*) cstr
{
    if ([cstr idx] < 0) {
      [cstr setIdx: _nbCstrs];
      [self addConstraint: cstr];
      if (_isClosed) {
         [_lp addConstraint: cstr];
         [_lp solve];
      }
   }
   else
      @throw [[NSException alloc] initWithName:@"LPSolver Error"
                                        reason:@"Constraint is already present"
                                      userInfo:nil];
   return cstr;
}
-(void) removeConstraint: (LPConstraintI*) cstr
{
   if ([cstr idx] < 0)
      @throw [[NSException alloc] initWithName:@"LPSolver Error"
                                        reason:@"Constraint is not present"
                                      userInfo:nil];
   int k = -1;
   for(ORInt i = 0; i < _nbCstrs; i++)
      if (_cstr[i] == cstr) {
         k = i;
         break;
      }
   if (k >= 0) {
      [_lp delConstraint: cstr];
      [cstr del];
      for(ORInt i = k; i < _nbCstrs - 1; i++) {
         _cstr[i] = _cstr[i+1];
         [_cstr[i] setIdx: i];
      }
      _nbCstrs--;
   }
   if (_isClosed)
      [_lp solve];
}
-(void) removeVariable: (LPVariableI*) var
{
   if ([var idx] < 0)
      @throw [[NSException alloc] initWithName:@"LPSolver Error"
                                        reason:@"Variable is not present"
                                      userInfo:nil];
   int k = -1;
   for(ORInt i = 0; i < _nbVars; i++)
      if (_var[i] == var) {
         k = i;
         break;
      }
   if (k >= 0) {
      [_lp delVariable: var];
      [var del];
      _nbVars--;
      for(ORInt i = k; i < _nbVars; i++) {
         _var[i] = _var[i+1];
         [_var[i] setIdx: i];
      }
   }
   if (_isClosed)
      [_lp solve];
}
-(void)projectVariable:(LPVariableI*)var
{
   if (var.idx < 0)
      @throw [[NSException alloc] initWithName:@"LPSolver Error"
                                        reason:@"Variable is not present"
                                      userInfo:nil];
   int k = -1;
   for(ORInt i = 0; i < _nbVars; i++)
      if (_var[i] == var) {
         k = i;
         break;
      }
   if (k >= 0) {
      // Variable _var[k] is variable var and should be replaced by its value (projected out) because
      // var was _bound_ (fixed) as a result of cleaning up the model.
      [_lp delVariable:var];
      for(ORInt i=0;i < _nbCstrs;i++)
         [_cstr[i] projectVariable:var];
      [_obj projectVariable:var];
      [_pStore addObject:var];
      [var setIdx:-1]; // projected out.
      _nbVars--;
      for(ORInt i = k; i < _nbVars; i++) {
         _var[i] = _var[i+1];
         [_var[i] setIdx: i];
      }
   }
   if (_isClosed)
      [_lp solve];
}
-(LPObjectiveI*) postObjective: (LPObjectiveI*) obj
{
   if (_obj != NULL) {
      @throw [[NSException alloc] initWithName:@"LP Solver Error"
                                        reason:@"Objective function already posted"
                                      userInfo:nil];
   }
   _obj = obj;
   
   int size = [obj size];
   LPVariableI** var = [obj var];
   ORDouble* coef = [obj coef];
   for(ORInt i = 0; i < size; i++)
      [var[i] addObjective: obj coef: coef[i]];
   free(coef);
   return _obj;
}

-(LPVariableI*) postColumn: (LPColumnI*) col
{
   LPVariableI* v;
   if ([col hasBounds])
      v = [self createVariable: [col low] up: [col up]];
   else
      v = [self createVariable];
   [col setIdx: [v idx]];
   [col fill: v obj: _obj];
   if (_isClosed) {
      [_lp addColumn: col];
      [_lp solve];
   }
   return v;
}

-(void) close
{
   if (!_isClosed) {
      ORBool improving = NO;
      do {
         improving = NO;
         for(ORInt i=0;i < _nbCstrs;i++) {
            ORBool isR = [_cstr[i] redundant];
            improving |= isR;
            if (isR) {
               [self removeConstraint:_cstr[i]];
               i -= 1; // we need to inspect the next constraint, can't skip.
            }
         }
         for(ORInt i=0;i < _nbVars;i++) {
            ORBool fixed = [_var[i] fixMe];
            if (fixed)
               [self projectVariable:_var[i--]]; // decrement i *after* to scan the next var 
            improving |= fixed;
         }
      } while (improving);
      _isClosed = true;
      for(ORInt i = 0; i < _nbVars; i++)
         [_lp addVariable: _var[i]];
      for(ORInt i = 0; i < _nbCstrs; i++)
         [_lp addConstraint: _cstr[i]];
      [_lp addObjective: _obj];
   }
}
-(ORBool) isClosed
{
   return _isClosed;
}
-(id<LPBasis>)basis
{
//   id<LPBasis> rv = _basis;
//   _basis = nil;
//   return rv;
   return [_basis retain];
}

-(OROutcome) solve
{
   if (!_isClosed)
      [self close];
   OROutcome oc = [_lp solve];
   [_basis release];
   _basis = [_lp captureBasis];  // reference count is 1
   return oc;
}

-(OROutcome) solveFrom:(id<LPBasis>)basis
{
   if (!_isClosed)
      [self close];
   OROutcome oc = [_lp solveFrom:basis];
   [_basis release];
   _basis = [_lp captureBasis];  // reference count is 1
   return oc;
}

-(OROutcome) status;
{
   return [_lp status];
}
-(ORDouble) doubleValue: (LPVariableI*) var
{
   return [_lp value: var];
}
-(ORDouble) lowerBound: (LPVariableI*) var
{
   if (var->_idx == -1)
      return var.low;
   else
      return [_lp lowerBound: var];
}
-(ORDouble) upperBound: (LPVariableI*) var
{
   if (var->_idx == -1)
      return var.up;
   else
      return [_lp upperBound: var];
}
-(ORDouble) reducedCost: (LPVariableI*) var
{
   if (var->_idx == -1)
      return 0.0;
   else
      return [_lp reducedCost: var];
}
-(ORBool) inBasis:(LPVariableI*)var
{
   if (var->_idx == -1)
      return NO;
   else
      return [_lp inBasis:var];
}
-(ORDouble)fractionality:(LPVariableI*)var
{
   return [var fractionality];
}
-(ORDouble)nearestInt:(LPVariableI*)var
{
   return [var nearestInt];
}
-(ORBool)triviallyRoundable:(LPVariableI*)var
{
   return [var triviallyRoundable];
}
-(ORBool)trivialDownRoundable:(LPVariableI*)var
{
   return [var trivialDownRoundable];
}
-(ORBool)trivialUpRoundable:(LPVariableI*)var
{
   return [var trivialUpRoundable];
}
-(ORInt)nbLocks:(LPVariableI*)var
{
   return [var locks];
}
-(ORBool)minLockDown:(LPVariableI*)var
{
   return [var minLockDown];
}
-(ORDouble) dual: (LPConstraintI*) cstr;
{
   return [_lp dual: cstr];
}
-(id<ORDoubleArray>) duals
{
    id<ORDoubleArray> arr = [ORFactory doubleArray: self range: RANGE(self, 0, _nbCstrs-1) with: ^ORDouble(ORInt i) {
        return [_cstr[i] dual];
    }];
   return arr;
}
-(id<ORObjectiveValue>) objectiveValue
{
   if (_obj)
      return [_obj value];
   else
      @throw [[NSException alloc] initWithName:@"LPSolver Error"
                                        reason:@"No objective function posted"
                                      userInfo:nil];
   return NULL;
}
-(ORDouble) lpValue
{
#if TARGET_OS_IPHONE==1
   return 0.0;
#else
   return [_lp objectiveValue];
#endif
}

-(void) updateBounds:(LPVariableI*)var lower:(ORDouble)low  upper:(ORDouble)up
{
   if (var->_idx >= 0)
      [_lp setBounds:var low:low up:up];
}
-(void) updateLowerBound: (LPVariableI*) var lb: (ORDouble) lb
{
   if (var->_idx >= 0)
      [_lp updateLowerBound: var lb: lb];
}
-(void) updateUpperBound: (LPVariableI*) var ub: (ORDouble) ub
{
   if (var->_idx >= 0)
      [_lp updateUpperBound: var ub: ub];
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
   [_lp setIntParameter: name val: val];
}
-(void) setDoubleParameter: (const char*) name val: (ORDouble) val;
{
   [_lp setDoubleParameter: name val: val];
}
-(void) setStringParameter: (const char*) name val: (char*) val
{
   [_lp setStringParameter: name val: val];
}
-(ORDouble) paramValue: (LPParameterI*) param
{
   return [_lp paramValue: param];
}
-(void) setParam: (LPParameterI*) param value: (ORDouble)val
{
   [_lp setParam: param value: val];
}
-(void) print;
{
   if (_obj || _nbCstrs > 0) {
      if (_obj)
         [_obj print];
      printf("subject to \n");
      for(ORInt i = 0; i < _nbCstrs; i++) {
         printf("\t");
         [_cstr[i] print];
      }
      printf("\n");
   }
}
-(NSMutableString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   @autoreleasepool {
      if (_obj || _nbCstrs > 0) {
         for(ORInt i=0;i < _nbVars;i++)
            [buf appendFormat:@"\t%@\n",_var[i]];
         if (_obj)
            [buf appendString: [_obj description]];
         [buf appendString:@"\nSubject to:\n"];
         for(ORInt i=0;i < _nbCstrs;i++) {
            [buf appendString:@"\t"];
            [buf appendString:[_cstr[i] description]];
            [buf appendString:@"\n"];
         }
      } else [buf appendString:@"empty model"];
   }
   return buf;
}
-(void) printModelToFile: (char*) fileName
{
   [_lp printModelToFile: fileName];
}

-(void)restoreBasis:(id<LPBasis>)basis
{
   [_lp restoreBasis:basis];
}

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

-(id) trackVariable: (id) var
{
   [_oStore addObject: var];
   [var release];
   return var;
}
-(id) trackObject:(id)obj
{
   [_oStore addObject:obj];
   [obj release];
   return obj;
}
-(id) trackConstraintInGroup:(id)obj
{
   return obj;
}
-(id) trackObjective:(id)obj
{
   [_oStore addObject:obj];
   [obj release];
   return obj;
}
-(id) trackMutable:(id)obj
{
   [_oStore addObject:obj];
   [obj release];
   return obj;
}
-(id) trackImmutable: (id) obj
{
   // temporary
   [_oStore addObject:obj];
   [obj release];
   return obj;
}
@end

@implementation LPFactory

+(LPSolverI*) solver
{
   return [LPSolverI create];
}
@end;




