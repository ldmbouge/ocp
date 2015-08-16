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

@interface LPFloatVarSnapshot : NSObject  {
   ORUInt    _name;
   ORFloat   _value;
   ORFloat   _reducedCost;
   
}
-(LPFloatVarSnapshot*) initLPFloatVarSnapshot: (LPVariableI*) v name: (ORInt) name;
-(ORFloat) floatValue;
-(ORFloat) reducedCost;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation LPFloatVarSnapshot
-(LPFloatVarSnapshot*) initLPFloatVarSnapshot: (LPVariableI*) v name: (ORInt) name
{
   self = [super init];
   _name = name;
   _value = [v floatValue];
   _reducedCost = [v reducedCost];
   return self;
}
-(ORUInt) getId
{
   return _name;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORFloat) reducedCost
{
   return _reducedCost;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      LPFloatVarSnapshot* other = object;
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
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_reducedCost];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_reducedCost];
   return self;
}
@end

@interface LPConstraintSnapshot : NSObject {
   ORUInt    _name;
   ORFloat   _dual;
}
-(LPConstraintSnapshot*) initLPConstraintSnapshot: (LPConstraintI*) cstr name: (ORInt) name;
-(ORFloat) dual;
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
-(ORFloat) dual
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
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_dual];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_dual];
   return self;
}
@end


@implementation LPConstraintI;

-(LPConstraintI*) initLPConstraintI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
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
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
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
      ORFloat* ncoef = (ORFloat*) malloc(2 * _maxSize * sizeof(ORFloat));
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
-(ORFloat*) coef
{
   _tmpCoef = (ORFloat*) malloc(_size * sizeof(ORFloat));
   for(ORInt i = 0; i < _size; i++)
      _tmpCoef[i] = _coef[i];
   return _tmpCoef;
}
-(ORFloat) coef: (ORInt) i
{
   return _coef[i];
}

-(ORFloat) rhs
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
-(void) addVariable: (LPVariableI*) var coef: (ORFloat) coef
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
-(ORFloat) dual
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

@end


@implementation LPConstraintLEQ;

-(LPConstraintI*) initLPConstraintLEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
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

-(LPConstraintI*) initLPConstraintGEQ: (LPSolverI*) solver size:  (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
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

-(LPConstraintI*) initLPConstraintEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
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

-(LPObjectiveI*) initLPObjectiveI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
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
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
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
      ORFloat* ncoef = (ORFloat*) malloc(2 * _maxSize * sizeof(ORFloat));
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
-(ORFloat*) coef
{
   _tmpCoef = (ORFloat*) malloc(_size * sizeof(ORFloat));
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
-(void) addVariable: (LPVariableI*) var coef: (ORFloat) coef
{
   [self resize];
   _var[_size] = var;
   _coef[_size] = coef;
   _size++;
}
-(void) addCst: (ORFloat) cst
{
   _cst += cst;
}
-(void) setPosted
{
   _posted = true;
}
-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueFloat: [_solver lpValue] + _cst minimize: true];
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

-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef
{
   self = [super initLPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
   _type = LPminimize;
   return self;
}
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
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
   return [ORFactory objectiveValueFloat: [_solver lpValue] + _cst minimize: true];
}

@end

@implementation LPMaximize;

-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef
{
   self = [super initLPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
   _type = LPmaximize;
   return self;
}
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
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
   return [ORFactory objectiveValueFloat: [_solver lpValue] + _cst minimize: false];
}
@end

@implementation LPVariableI
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver low: (ORFloat) low up: (ORFloat) up
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
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
   
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
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
   
   return self;
}
-(id) takeSnapshot: (ORInt) id
{
   return [[LPFloatVarSnapshot alloc] initLPFloatVarSnapshot: self name: id];
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

-(ORFloat) low
{
   return _low;
}
-(ORFloat) up
{
   return _up;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"LPVariable(%d,%f)",_idx,[_solver floatValue:self]];
   return buf;
}
-(void) resize
{
   if (_size == _maxSize) {
      LPConstraintI** ncstr = (LPConstraintI**) malloc(2 * _maxSize * sizeof(LPConstraintI*));
      ORFloat* ncoef = (ORFloat*) malloc(2 * _maxSize * sizeof(ORFloat));
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
-(void) addConstraint: (LPConstraintI*) c coef: (ORFloat) coef
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
-(void) addObjective: (LPObjectiveI*) obj coef: (ORFloat) coef
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
   return [_solver createColumn:_low up:_up size:_size obj:_objCoef cstr:_cstr coef:_coef];
}
-(ORFloat) floatValue
{
   return [_solver floatValue:self];
}

-(ORFloat) reducedCost
{
   return [_solver reducedCost: self];
}
-(ORBool) isInteger
{
   return false;
}
@end

@implementation LPColumnI

-(LPColumnI*) initLPColumnI: (LPSolverI*) solver
                        low: (ORFloat) low
                         up: (ORFloat) up
                       size: (ORInt) size
                        obj: (ORFloat) obj
                       cstr: (LPConstraintI**) cstr
                       coef: (ORFloat*) coef

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
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
   for(ORInt i = 0; i < _size; i++)
      _coef[i] = coef[i];
   _tmpCstr = NULL;
   _tmpCoef = NULL;
   return self;
}

-(LPColumnI*) initLPColumnI: (LPSolverI*) solver
                        low: (ORFloat) low
                         up: (ORFloat) up
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
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
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
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
   return self;
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
-(void) resize
{
   if (_size == _maxSize) {
      LPConstraintI** ncstr = (LPConstraintI**) malloc(2 * _maxSize * sizeof(LPConstraintI*));
      ORFloat* ncoef = (ORFloat*) malloc(2 * _maxSize * sizeof(ORFloat));
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
-(ORFloat) low
{
   return _low;
}
-(ORFloat) up
{
   return _up;
}
-(ORFloat) objCoef
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
-(ORFloat*) coef
{
   if (_tmpCoef)
      free(_tmpCoef);
   _tmpCoef = (ORFloat*) malloc(_size * sizeof(ORFloat));
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
-(void) addObjCoef: (ORFloat) coef
{
   _objCoef = coef;
}
-(void) addConstraint: (LPConstraintI*) cstr coef: (ORFloat) coef
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
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
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
      ORFloat* ncoef = (ORFloat*) malloc(2 * _maxSize * sizeof(ORFloat));
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
-(ORFloat*) coef
{
   return _coef;
}
-(ORFloat) cst
{
   return _cst;
}
-(void) add: (ORFloat) cst
{
   _cst = cst;
}
-(void) add: (ORFloat) coef times: (LPVariableI*) var
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
   ORFloat* bucket = (ORFloat*) alloca(sizeIdx * sizeof(ORFloat));
   LPVariableI** bucketVar = (LPVariableI**) alloca(sizeIdx * sizeof(LPVariableI*));
   bucket -= lidx;
   bucketVar -= lidx;
   for(ORInt i = lidx; i <= uidx; i++)
      bucket[i] = 0.0;
   for(ORInt i = 0; i < _size; i++) {
      int idx = [_var[i] idx];
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
   return self;
}
-(void) dealloc
{
   free(_var);
   free(_cstr);
   [_oStore release];
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

-(LPVariableI*) createVariable
{
   LPVariableI* v = [[LPVariableI alloc] initLPVariableI: self];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}
-(LPVariableI*) createVariable: (ORFloat) low up: (ORFloat) up
{
   LPVariableI* v = [[LPVariableI alloc] initLPVariableI: self low: low up: up];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}

-(LPColumnI*) createColumn: (ORFloat) low up: (ORFloat) up size: (ORInt) size obj: (ORFloat) obj cstr: (LPConstraintI**) cstr coef: (ORFloat*) coef
{
   LPColumnI* c = [[LPColumnI alloc] initLPColumnI: self low: low up: up size: size obj: obj cstr: cstr coef: coef];
   [c setNb: _createdCols++];
   [self trackMutable: c];
   return c;
}
-(LPColumnI*) createColumn: (ORFloat) low up: (ORFloat) up
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
   ORFloat* coef = [cstr coef];
   for(ORInt i = 0; i < size; i++)
      [var[i] addConstraint: cstr coef: coef[i]];
   free(coef);
   return cstr;
   
}
-(LPConstraintI*) createLEQ: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createLEQ: t rhs: rhs];
}

-(LPConstraintI*) createLEQ: (id<LPVariableArray>) var coef: (id<ORFloatArray>) coef cst: (ORFloat) cst
{
   LPLinearTermI* t = [self createLinearTerm];
   id<ORIntRange> R = [var range];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++) 
      [t add: [coef at: i] times: var[i]];
   return [self createLEQ: t rhs: -cst];
}
-(LPConstraintI*) createEQ: (id<LPVariableArray>) var coef: (id<ORFloatArray>) coef cst: (ORFloat) cst
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

-(LPConstraintI*) createGEQ: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createGEQ: t rhs: rhs];
   
}
-(LPConstraintI*) createEQ: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createEQ: t rhs: rhs];
}
-(LPObjectiveI*) createMinimize: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef
{
   LPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createMinimize: t];
}
-(LPObjectiveI*) createMaximize: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef
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
-(LPObjectiveI*)  createObjectiveMinimize: (id<LPVariableArray>) var coef: (id<ORFloatArray>) coef
{
   LPLinearTermI* t = [self createLinearTerm];
   ORInt low = [var low];
   ORInt up = [var up];
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createMinimize: t];
}
-(LPObjectiveI*)  createObjectiveMaximize: (id<LPVariableArray>) var coef: (id<ORFloatArray>) coef
{
   LPLinearTermI* t = [self createLinearTerm];
   ORInt low = [var low];
   ORInt up = [var up];
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createMaximize: t];
}

-(LPConstraintI*) createLEQ: (LPLinearTermI*) t rhs: (ORFloat) rhs;
{
   [t close];
   LPConstraintI* c = [[LPConstraintLEQ alloc] initLPConstraintLEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackMutable: c];
   return c;
}
-(LPConstraintI*) createGEQ: (LPLinearTermI*) t rhs: (ORFloat) rhs;
{
   [t close];
   LPConstraintI* c = [[LPConstraintGEQ alloc] initLPConstraintGEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackMutable: c];
   return c;
}
-(LPConstraintI*) createEQ: (LPLinearTermI*) t rhs: (ORFloat) rhs;
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
      _nbCstrs--;
      for(ORInt i = k; i < _nbCstrs; i++) {
         _cstr[i] = _cstr[i+1];
         [_cstr[i] setIdx: i];
      }
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
   ORFloat* coef = [obj coef];
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
-(OROutcome) solve
{
   if (!_isClosed)
      [self close];
 
   return [_lp solve];
}

-(OROutcome) status;
{
   return [_lp status];
}
-(ORFloat) floatValue: (LPVariableI*) var
{
   return [_lp value: var];
}
-(ORFloat) lowerBound: (LPVariableI*) var
{
   return [_lp lowerBound: var];
}
-(ORFloat) upperBound: (LPVariableI*) var
{
   return [_lp upperBound: var];
}
-(ORFloat) reducedCost: (LPVariableI*) var
{
   return [_lp reducedCost: var];
}
-(ORFloat) dual: (LPConstraintI*) cstr;
{
   return [_lp dual: cstr];
}
-(id<ORFloatArray>) duals
{
    id<ORFloatArray> arr = [ORFactory floatArray: self range: RANGE(self, 0, _nbCstrs-1) with: ^ORFloat(ORInt i) {
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
-(ORFloat) lpValue
{
#if TARGET_OS_IPHONE==1
   return 0.0;
#else
   return [_lp objectiveValue];
#endif
}

-(void) updateLowerBound: (LPVariableI*) var lb: (ORFloat) lb
{
   [_lp updateLowerBound: var lb: lb];
}
-(void) updateUpperBound: (LPVariableI*) var ub: (ORFloat) ub
{
   [_lp updateUpperBound: var ub: ub];
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
   [_lp setIntParameter: name val: val];
}
-(void) setFloatParameter: (const char*) name val: (ORFloat) val;
{
   [_lp setFloatParameter: name val: val];
}
-(void) setStringParameter: (const char*) name val: (char*) val
{
   [_lp setStringParameter: name val: val];
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
-(void) printModelToFile: (char*) fileName
{
   [_lp printModelToFile: fileName];
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




