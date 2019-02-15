/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "MIPSolverI.h"

#if TARGET_OS_IPHONE==0
#import "MIPGurobi.h"
#endif

@interface MIPDoubleVarSnapshot : NSObject {
   ORUInt    _name;
   ORDouble   _value;
   ORDouble   _reducedCost;
   
}
-(MIPDoubleVarSnapshot*) initMIPFloatVarSnapshot: (MIPVariableI*) v name: (ORInt) name;
-(ORDouble) doubleValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation MIPDoubleVarSnapshot
-(MIPDoubleVarSnapshot*) initMIPFloatVarSnapshot: (MIPVariableI*) v name: (ORInt) name
{
   self = [super init];
   _name = name;
   _value = [v doubleValue];
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
      MIPDoubleVarSnapshot* other = object;
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

@interface MIPIntVarSnapshot : NSObject  {
   ORUInt    _name;
   ORInt     _value;
   ORDouble   _reducedCost;
   
}
-(MIPIntVarSnapshot*) initMIPIntVarSnapshot: (MIPIntVariableI*) v name: (ORInt) name;
-(ORInt) intValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation MIPIntVarSnapshot
-(MIPIntVarSnapshot*) initMIPIntVarSnapshot: (MIPIntVariableI*) v name: (ORInt) name
{
   self = [super init];
   _name = name;
   _value = [v intValue];
   return self;
}
-(ORUInt) getId
{
   return _name;
}
-(ORInt) intValue
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
      MIPIntVarSnapshot* other = object;
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
   [buf appendFormat:@"float(%d) : (%d,%f)",_name,_value,_reducedCost];
   return buf;
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_reducedCost];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_reducedCost];
   return self;
}
@end

@interface MIPConstraintSnapshot : NSObject  {
   ORUInt    _name;
}
-(MIPConstraintSnapshot*) initMIPConstraintSnapshot: (MIPConstraintI*) cstr name: (ORInt) name;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation MIPConstraintSnapshot
-(MIPConstraintSnapshot*) initMIPConstraintSnapshot: (MIPConstraintI*) cstr name: (ORInt) name
{
   self = [super init];
   _name = name;
   return self;
}
-(ORUInt) getId
{
   return _name;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      MIPConstraintSnapshot* other = object;
      if (_name == other->_name) {
         return YES;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16);
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"mip(constraint)(%d) :",_name];
   return buf;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
@end

@implementation MIPConstraintI;

-(MIPConstraintI*) initMIPConstraintI: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   if (size < 0)
      @throw [[NSException alloc] initWithName:@"MIPConstraint Error"
                                        reason:@"Constraint has negative size"
                                      userInfo:nil];
   self = [super init];
   _solver = solver;
   _idx = -1;
   _size = size;
   _maxSize = 2*size;
   if (_maxSize == 0)
      _maxSize = 1;
   _var = (MIPVariableI**) malloc(_maxSize * sizeof(MIPVariableI*));
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
   if (_tmpVar)
      free(_tmpVar);
   if (_tmpCoef)
      free(_tmpCoef);
   [super dealloc];
}
-(id) takeSnapshot: (ORInt) id
{
   return [[MIPConstraintSnapshot alloc] initMIPConstraintSnapshot: self name: id];
}
-(void) resize
{
   if (_size == _maxSize) {
      MIPVariableI** nvar = (MIPVariableI**) malloc(2 * _maxSize * sizeof(MIPVariableI*));
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
-(MIPConstraintType) type
{
   return _type;
}
-(ORInt) size
{
   return _size;
}
-(MIPVariableI**) var
{
   if (_tmpVar)
      return _tmpVar;
   else {
      _tmpVar = (MIPVariableI**) malloc(_size * sizeof(MIPVariableI*));
      for(ORInt i = 0; i < _size; i++)
         _tmpVar[i] = _var[i];
      return _tmpVar;
   }
}
-(MIPVariableI*) var: (ORInt) i
{
   return _var[i];
}
-(ORInt*) col
{
   if (_col)
      return _col;
   else {
      _col = (ORInt*) malloc(_size * sizeof(ORInt));
      for(ORInt i = 0; i < _size; i++)
         _col[i] = [_var[i] idx];
      return _col;
   }
}
-(ORInt) col: (ORInt) i
{
   return [_var[i] idx];
}
-(ORDouble*) coef
{
   if (_tmpCoef)
      return _tmpCoef;
   else {
      _tmpCoef = (ORDouble*) malloc(_size * sizeof(ORDouble));
      for(ORInt i = 0; i < _size; i++)
         _tmpCoef[i] = _coef[i];
      return _tmpCoef;
   }
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
-(bool)  isQuad
{
   return _quad;
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
-(void) delVariable: (MIPVariableI*) var
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
-(void) addVariable: (MIPVariableI*) var coef: (ORDouble) coef
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
-(ORInt) nb
{
   return _nb;
}
-(void) setNb: (ORInt) nb
{
   _nb = nb;
}

@end


@implementation MIPConstraintLEQ;

-(MIPConstraintI*) initMIPConstraintLEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   self = [super initMIPConstraintI: solver size: size var: var coef: coef rhs: rhs];
   _type = MIPleq;
   return self;
}
-(void) print
{
   [super print: "<="];
}
@end

@implementation MIPConstraintGEQ;

-(MIPConstraintI*) initMIPConstraintGEQ: (MIPSolverI*) solver size:  (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   self = [super initMIPConstraintI: solver size: size var: var coef: coef rhs: rhs];
   _type = MIPgeq;
   return self;
}
-(void) print
{
   [super print: ">="];
}

@end

@implementation MIPConstraintEQ;

-(MIPConstraintI*) initMIPConstraintEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   self = [super initMIPConstraintI: solver size: size var: var coef: coef rhs: rhs];
   _type = MIPeq;
   return self;
}
-(void) print
{
   [super print: "="];
}
@end

@implementation MIPQuadConstraint : MIPConstraintI
#warning [hzi] should add resize and dealloc stuff
-(MIPConstraintI*) initMIPQuadConstraint: (MIPSolverI*) solver sizeLin: (ORInt) size varLin: (MIPVariableI**) var coefLin: (ORDouble*) coef sizeQuad: (ORInt) sizeq varQuad: (MIPVariableI**) varq coefQuad: (ORDouble*) coefq rhs: (ORDouble) rhs
{
   self = [super initMIPConstraintI: solver size: size var: var coef: coef rhs: rhs];
   _quad = true;
   _qsize = sizeq;
   _maxSize = max(2*_qsize,_maxSize);
   _qcol = (ORInt*) malloc(_qsize * sizeof(ORInt));
   _qrow = (ORInt*) malloc(_qsize * sizeof(ORInt));
   _qvar = (MIPVariableI***) malloc(_maxSize * sizeof(MIPVariableI**));
   for(ORInt i = 0; i < _qsize; i++){
      _qvar[i] = (MIPVariableI**) malloc(2 * sizeof(MIPVariableI*));
      _qvar[i][0] = varq[i*2+0];
      _qvar[i][1] = varq[i*2+1];
      _qcol[i] = [varq[i*2+0] idx];
      _qrow[i] = [varq[i*2+1] idx];
   }
   _qcoef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   for(ORInt i = 0; i < _qsize; i++)
      _qcoef[i] = coefq[i];
   return self;
}
-(ORInt) qSize
{
   return _qsize;
}
-(ORDouble*) qCoef
{
   return _qcoef;
}
-(ORInt*) qCol
{
   return _qcol;
}
-(ORInt*) qRow
{
   return _qrow;
}
@end


@implementation MIPQuadConstraintLEQ : MIPQuadConstraint
-(MIPConstraintI*) initMIPQuadConstraintLEQ: (MIPSolverI*) solver sizeLin: (ORInt) size varLin: (MIPVariableI**) var coefLin: (ORDouble*) coef sizeQuad: (ORInt) sizeq varQuad: (MIPVariableI**) varq coefQuad: (ORDouble*) coefq rhs: (ORDouble) rhs
{
   self = [super initMIPQuadConstraint:solver sizeLin:size varLin:var coefLin:coef sizeQuad:sizeq varQuad:varq coefQuad:coefq rhs:rhs];
   _type = MIPleq;
   return self;
}
-(void) print
{
   [super print: "<="];
}
@end

@implementation MIPQuadConstraintGEQ : MIPQuadConstraint
-(MIPConstraintI*) initMIPQuadConstraintGEQ: (MIPSolverI*) solver sizeLin: (ORInt) size varLin: (MIPVariableI**) var coefLin: (ORDouble*) coef sizeQuad: (ORInt) sizeq varQuad: (MIPVariableI**) varq coefQuad: (ORDouble*) coefq rhs: (ORDouble) rhs
{
   self = [super initMIPQuadConstraint:solver sizeLin:size varLin:var coefLin:coef sizeQuad:sizeq varQuad:varq coefQuad:coefq rhs:rhs];
   _type = MIPgeq;
   return self;
}
-(void) print
{
   [super print: ">="];
}
@end

@implementation MIPQuadConstraintEQ : MIPQuadConstraint
-(MIPConstraintI*) initMIPQuadConstraintEQ: (MIPSolverI*) solver sizeLin: (ORInt) size varLin: (MIPVariableI**) var coefLin: (ORDouble*) coef sizeQuad: (ORInt) sizeq varQuad: (MIPVariableI**) varq coefQuad: (ORDouble*) coefq rhs: (ORDouble) rhs
{
   self = [super initMIPQuadConstraint:solver sizeLin:size varLin:var coefLin:coef sizeQuad:sizeq varQuad:varq coefQuad:coefq rhs:rhs];
   _type = MIPeq;
   return self;
}
-(void) print
{
   [super print: "="];
}
@end
@implementation MIPObjectiveI;

-(MIPObjectiveI*) initMIPObjectiveI: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst
{
   self = [super init];
   _solver = solver;
   _size = size;
   _maxSize = 2*size;
   _posted = false;
   _cst = 0.0;
   if (_maxSize == 0)
      _maxSize++;
   _var = (MIPVariableI**) malloc(_maxSize * sizeof(MIPVariableI*));
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
      MIPVariableI** nvar = (MIPVariableI**) malloc(2 * _maxSize * sizeof(MIPVariableI*));
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
   if (_tmpVar)
      free(_tmpVar);
   if (_tmpCoef)
      free(_tmpCoef);
   [super dealloc];
}
-(MIPObjectiveType) type
{
   return _type;
}
-(ORInt) size
{
   return _size;
}
-(MIPVariableI**) var
{
   if (_tmpVar)
      return _tmpVar;
   else {
      _tmpVar = (MIPVariableI**) malloc(_size * sizeof(MIPVariableI*));
      for(ORInt i = 0; i < _size; i++)
         _tmpVar[i] = _var[i];
      return _tmpVar;
   }
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
   if (_tmpCoef)
      return _tmpCoef;
   else {
      _tmpCoef = (ORDouble*) malloc(_size * sizeof(ORDouble));
      for(ORInt i = 0; i < _size; i++)
         _tmpCoef[i] = _coef[i];
      return _tmpCoef;
   }
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
-(void) delVariable: (MIPVariableI*) var
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
-(void) addVariable: (MIPVariableI*) var coef: (ORDouble) coef
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
   return [ORFactory objectiveValueReal: [_solver mipvalue] + _cst minimize: true];
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


@implementation MIPMinimize;

-(MIPObjectiveI*) initMIPMinimize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef
{
   self = [super initMIPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
   _type = MIPminimize;
   return self;
}
-(MIPObjectiveI*) initMIPMinimize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst
{
   _type = MIPminimize;
   return [super initMIPObjectiveI: solver size: size var: var coef: coef cst: cst];
}
-(void) print
{
   printf("minimize ");
   [super print];
}
-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueReal: [_solver mipvalue] + _cst minimize: true];
}

@end

@implementation MIPMaximize;

-(MIPObjectiveI*) initMIPMaximize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef
{
   self =  [super initMIPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
   _type = MIPmaximize;
   return self;
}
-(MIPObjectiveI*) initMIPMaximize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst
{
   self = [super initMIPObjectiveI: solver size: size var: var coef: coef cst: cst];
   _type = MIPmaximize;
   return self;
}
-(void) print
{
   printf("maximize ");
   [super print];
}
-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueReal: [_solver mipvalue] + _cst minimize: false];
}
@end

@implementation MIPVariableI
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver low: (ORDouble) low up: (ORDouble) up
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
   _cstr = (MIPConstraintI**) malloc(_maxSize * sizeof(MIPConstraintI*));
   _cstrIdx = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   
   return self;
}
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver
{
   self = [super init];
   _hasBounds = false;
   _solver = solver;
   _idx = -1;
   
   // data structure to preserve the constraint information
   _maxSize = 8;
   _size = 0;
   _cstr = (MIPConstraintI**) malloc(_maxSize * sizeof(MIPConstraintI*));
   _cstrIdx = NULL;
   _coef = (ORDouble*) malloc(_maxSize * sizeof(ORDouble));
   
   return self;
}
-(id) takeSnapshot: (ORInt) id
{
   return [[MIPDoubleVarSnapshot alloc] initMIPFloatVarSnapshot: self name: id];
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

-(ORDouble) low
{
   return _low;
}
-(ORDouble) up
{
   return _up;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"%f",[_solver doubleValue:self]];
   return buf;
}
-(void) resize
{
   if (_size == _maxSize) {
      MIPConstraintI** ncstr = (MIPConstraintI**) malloc(2 * _maxSize * sizeof(MIPConstraintI*));
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
-(void) addConstraint: (MIPConstraintI*) c coef: (ORDouble) coef
{
   [self resize];
   _cstr[_size] = c;
   _coef[_size] = coef;
   _size++;
}
-(void) delConstraint: (MIPConstraintI*) c
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
-(void) addObjective: (MIPObjectiveI*) obj coef: (ORDouble) coef
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
-(ORDouble) doubleValue
{
   return [_solver doubleValue:self];
}
-(ORBool) isInteger
{
   return false;
}
@end


@implementation MIPIntVariableI
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver low: (ORDouble) low up: (ORDouble) up
{
   self = [super initMIPVariableI: solver low: low up: up];
   return self;
}
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver
{
   self = [super initMIPVariableI: solver];
   return self;
}
-(id) takeSnapshot: (ORInt) id
{
   return [[MIPIntVarSnapshot alloc] initMIPIntVarSnapshot: self name: id];
}
-(ORBool) isInteger
{
   return true;
}
-(ORInt) intValue
{
   return [_solver intValue: self];
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"MIPIntVariable[%f,%f]",_low,_up];
}
@end

@implementation MIPParameterI
-(MIPParameterI*) initMIPParameterI: (MIPSolverI*) solver
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
    [buf appendFormat:@"%f",[_solver paramValue:self]];
    return buf;
}
-(ORBool) isInteger
{
    return NO;
}
@end


@implementation MIPLinearTermI

-(MIPLinearTermI*) initMIPLinearTermI: (MIPSolverI*) solver
{
   self = [super init];
   _solver = solver;
   _size = 0;
   _maxSize = 8;
   if (_maxSize == 0)
      _maxSize++;
   _var = (MIPVariableI**) malloc(_maxSize * sizeof(MIPVariableI*));
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
      MIPVariableI** nvar = (MIPVariableI**) malloc(2 * _maxSize * sizeof(MIPVariableI*));
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
-(MIPVariableI**) var
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
-(void) add: (ORDouble) coef times: (MIPVariableI*) var
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
   MIPVariableI** bucketVar = (MIPVariableI**) alloca(sizeIdx * sizeof(MIPVariableI*));
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

@implementation MIPSolverI

+(MIPSolverI*) create
{
   return [[MIPSolverI alloc] initMIPSolverI];
}
-(MIPSolverI*) initMIPSolverI
{
   self = [super init];
#if TARGET_OS_IPHONE==0
   _MIP = [[MIPGurobiSolver alloc] init];
#else
   _MIP = nil; // [ldm] we do not have GUROBI on IOS
#endif
   _nbVars = 0;
   _maxVars = 32;
   _var = (MIPVariableI**) malloc(_maxVars * sizeof(MIPVariableI*));
   _nbCstrs = 0;
   _maxCstrs = 32;
   _cstr = (MIPConstraintI**) malloc(_maxCstrs * sizeof(MIPConstraintI*));
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
-(ORUInt) nbPropagation
{
   return 0;
}
-(void) addVariable: (MIPVariableI*) v
{
   if (_nbVars == _maxVars) {
      MIPVariableI** nvar = (MIPVariableI**) malloc(2 * _maxVars * sizeof(MIPVariableI*));
      for(ORInt i = 0; i < _nbVars; i++)
         nvar[i] = _var[i];
      free(_var);
      _var = nvar;
      _maxVars *= 2;
   }
   [v setIdx: _nbVars];
   _var[_nbVars++] = v;
}

-(MIPVariableI*) createVariable
{
   MIPVariableI* v = [[MIPVariableI alloc] initMIPVariableI: self];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}
-(MIPIntVariableI*) createIntVariable: (ORDouble) low up: (ORDouble) up
{
   MIPIntVariableI* v = [[MIPIntVariableI alloc] initMIPIntVariableI: self low: low up: up];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}
-(MIPIntVariableI*) createIntVariable
{
   MIPIntVariableI* v = [[MIPIntVariableI alloc] initMIPIntVariableI: self];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}
-(MIPVariableI*) createVariable: (ORDouble) low up: (ORDouble) up
{
   MIPVariableI* v = [[MIPVariableI alloc] initMIPVariableI: self low: low up: up];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}
-(MIPParameterI*) createParameter
{
    MIPParameterI* v = [[MIPParameterI alloc] initMIPParameterI: self];
    [self trackMutable: v];
    return v;
}
-(MIPLinearTermI*) createLinearTerm
{
   MIPLinearTermI* o = [[MIPLinearTermI alloc] initMIPLinearTermI: self];
   [self trackMutable: o];
   return o;
}
-(MIPConstraintI*) addConstraint: (MIPConstraintI*) cstr
{
   if (_nbCstrs == _maxCstrs) {
      MIPConstraintI** ncstr = (MIPConstraintI**) malloc(2 * _maxCstrs * sizeof(MIPConstraintI*));
      for(ORInt i = 0; i < _nbCstrs; i++)
         ncstr[i] = _cstr[i];
      free(_cstr);
      _cstr = ncstr;
      _maxCstrs *= 2;
   }
   _cstr[_nbCstrs++] = cstr;
   
   int size = [cstr size];
   MIPVariableI** var = [cstr var];
   ORDouble* coef = [cstr coef];
   for(ORInt i = 0; i < size; i++)
      [var[i] addConstraint: cstr coef: coef[i]];
   return cstr;
}
-(MIPConstraintI*) createLEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createLEQ: t rhs: rhs];
}

-(MIPConstraintI*) createLEQ: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst
{
   MIPLinearTermI* t = [self createLinearTerm];
   id<ORIntRange> R = [var range];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createLEQ: t rhs: -cst];
}
-(MIPConstraintI*) createGEQ: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst
{
   MIPLinearTermI* t = [self createLinearTerm];
   id<ORIntRange> R = [var range];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createGEQ: t rhs: -cst];
}

-(MIPConstraintI*) createEQ: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst
{
   MIPLinearTermI* t = [self createLinearTerm];
   id<ORIntRange> R = [var range];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createEQ: t rhs: -cst];
}
-(MIPObjectiveI*)  createObjectiveMinimize: (MIPVariableI*) x
{
   MIPLinearTermI* t = [self createLinearTerm];
   [t add: 1 times: x];
   return [self createMinimize: t];
}
-(MIPObjectiveI*)  createObjectiveMaximize: (MIPVariableI*) x
{
   MIPLinearTermI* t = [self createLinearTerm];
   [t add: 1 times: x];
   return [self createMaximize: t];
}

-(MIPConstraintI*) createGEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createGEQ: t rhs: rhs];
   
}
-(MIPConstraintI*) createEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createEQ: t rhs: rhs];
}

-(MIPConstraintI*) createQuadEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef sizeQ:(ORInt) sizeq varQ: (MIPVariableI**) varq coefQ: (ORDouble*) coefq rhs: (ORDouble) rhs
{
   return [[MIPQuadConstraintEQ alloc] initMIPQuadConstraintEQ:self sizeLin:size varLin:var coefLin:coef sizeQuad:sizeq varQuad:varq coefQuad:coefq rhs:rhs];
}

-(MIPConstraintI*) createQuadGEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef sizeQ:(ORInt) sizeq varQ: (MIPVariableI**) varq coefQ: (ORDouble*) coefq rhs: (ORDouble) rhs
{
   return [[MIPQuadConstraintGEQ alloc] initMIPQuadConstraintGEQ:self sizeLin:size varLin:var coefLin:coef sizeQuad:sizeq varQuad:varq coefQuad:coefq rhs:rhs];
}


-(MIPConstraintI*) createQuadLEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef sizeQ:(ORInt) sizeq varQ: (MIPVariableI**) varq coefQ: (ORDouble*) coefq rhs: (ORDouble) rhs
{
   return [[MIPQuadConstraintLEQ alloc] initMIPQuadConstraintLEQ:self sizeLin:size varLin:var coefLin:coef sizeQuad:sizeq varQuad:varq coefQuad:coefq rhs:rhs];
}


-(MIPObjectiveI*) createMinimize: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createMinimize: t];
}
-(MIPObjectiveI*) createMaximize: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createMaximize: t];
}
-(MIPObjectiveI*) createMaximize: (MIPLinearTermI*) t
{
   [t close];
   MIPObjectiveI* o = [[MIPMaximize alloc] initMIPMaximize: self size: [t size] var: [t var] coef: [t coef] cst:[t cst]];
   [o setNb: _createdObjs++];
   [self trackMutable: o];
   return o;
}
-(MIPObjectiveI*) createMinimize: (MIPLinearTermI*) t
{
   [t close];
   MIPObjectiveI* o = [[MIPMinimize alloc] initMIPMinimize: self size: [t size] var: [t var] coef: [t coef] cst:[t cst]];
   [o setNb: _createdObjs++];
   [self trackMutable: o];
   return o;
}
-(MIPObjectiveI*)  createObjectiveMinimize: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef
{
   MIPLinearTermI* t = [self createLinearTerm];
   ORInt low = [var low];
   ORInt up = [var up];
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createMinimize: t];
}
-(MIPObjectiveI*)  createObjectiveMaximize: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef
{
   MIPLinearTermI* t = [self createLinearTerm];
   ORInt low = [var low];
   ORInt up = [var up];
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createMaximize: t];
}

-(MIPConstraintI*) createLEQ: (MIPLinearTermI*) t rhs: (ORDouble) rhs;
{
   [t close];
   MIPConstraintI* c = [[MIPConstraintLEQ alloc] initMIPConstraintLEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackMutable: c];
   return c;
}
-(MIPConstraintI*) createGEQ: (MIPLinearTermI*) t rhs: (ORDouble) rhs;
{
   [t close];
   MIPConstraintI* c = [[MIPConstraintGEQ alloc] initMIPConstraintGEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackMutable: c];
   return c;
}
-(MIPConstraintI*) createEQ: (MIPLinearTermI*) t rhs: (ORDouble) rhs;
{
   [t close];
   MIPConstraintI* c = [[MIPConstraintEQ alloc] initMIPConstraintEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackMutable: c];
   return c;
}

-(MIPConstraintI*) postConstraint: (MIPConstraintI*) cstr
{
   if ([cstr idx] < 0) {
      [cstr setIdx: _nbCstrs];
      [self addConstraint: cstr];
      if (_isClosed) {
         [_MIP addConstraint: cstr];
         //[_MIP solve];
      }
   }
   else
      @throw [[NSException alloc] initWithName:@"MIPSolver Error"
                                        reason:@"Constraint is already present"
                                      userInfo:nil];
   return cstr;
}
-(void) removeConstraint: (MIPConstraintI*) cstr
{
   if ([cstr idx] < 0)
      @throw [[NSException alloc] initWithName:@"MIPSolver Error"
                                        reason:@"Constraint is not present"
                                      userInfo:nil];
   int k = -1;
   for(ORInt i = 0; i < _nbCstrs; i++)
      if (_cstr[i] == cstr) {
         k = i;
         break;
      }
   if (k >= 0) {
      [_MIP delConstraint: cstr];
      [cstr del];
      _nbCstrs--;
      for(ORInt i = k; i < _nbCstrs; i++) {
         _cstr[i] = _cstr[i+1];
         [_cstr[i] setIdx: i];
      }
   }
   if (_isClosed)
      [_MIP solve];
}
-(void) removeVariable: (MIPVariableI*) var
{
   if ([var idx] < 0)
      @throw [[NSException alloc] initWithName:@"MIPSolver Error"
                                        reason:@"Variable is not present"
                                      userInfo:nil];
   int k = -1;
   for(ORInt i = 0; i < _nbVars; i++)
      if (_var[i] == var) {
         k = i;
         break;
      }
   if (k >= 0) {
      [_MIP delVariable: var];
      [var del];
      _nbVars--;
      for(ORInt i = k; i < _nbVars; i++) {
         _var[i] = _var[i+1];
         [_var[i] setIdx: i];
      }
   }
   if (_isClosed)
      [_MIP solve];
}
-(MIPObjectiveI*) postObjective: (MIPObjectiveI*) obj
{
   if (_obj != NULL) {
      @throw [[NSException alloc] initWithName:@"MIP Solver Error"
                                        reason:@"Objective function already posted"
                                      userInfo:nil];
   }
   _obj = obj;
   
   int size = [obj size];
   MIPVariableI** var = [obj var];
   ORDouble* coef = [obj coef];
   for(ORInt i = 0; i < size; i++)
      [var[i] addObjective: obj coef: coef[i]];
   return _obj;
}

-(void) close
{
   if (!_isClosed) {
      _isClosed = true;
      for(ORInt i = 0; i < _nbVars; i++)
         [_MIP addVariable: _var[i]];
      [_MIP updateModel];
      for(ORInt i = 0; i < _nbCstrs; i++)
         [_MIP addConstraint: _cstr[i]];
      [_MIP updateModel];
      [_MIP addObjective: _obj];
   }
}
-(ORBool) isClosed
{
   return _isClosed;
}
-(MIPOutcome) solve
{
   if (!_isClosed)
      [self close];
   return [_MIP solve];
}
-(void) setTimeLimit: (double)limit
{
    [_MIP setTimeLimit: limit];
}
-(ORDouble) bestObjectiveBound
{
    return [_MIP bestObjectiveBound];
}
-(ORFloat) dualityGap
{
    return [_MIP dualityGap];
}
-(id) inCache:(id)obj
{
    return nil;
}
-(id)addToCache:(id)obj
{
    return nil;
}
-(MIPOutcome) status;
{
   return [_MIP status];
}
-(ORInt) intValue: (MIPIntVariableI*) var
{
   return (ORInt) [_MIP intValue: var];
}
-(void) setIntVar: (MIPIntVariableI*)var value:(ORInt)val
{
    [_MIP setIntVar: var value: val];
}
-(ORDouble) doubleValue: (MIPVariableI*) var
{
   return [_MIP doubleValue: var];
}
-(ORDouble) lowerBound: (MIPVariableI*) var
{
   return [_MIP lowerBound: var];
}
-(ORDouble) upperBound: (MIPVariableI*) var
{
   return [_MIP upperBound: var];
}
-(id<ORObjectiveValue>) objectiveValue
{
   if (_obj)
      return [_obj value];
   else
      @throw [[NSException alloc] initWithName:@"MIPSolver Error"
                                        reason:@"No objective function posted"
                                      userInfo:nil];
   return NULL;
}
-(ORDouble) mipvalue
{
#if TARGET_OS_IPHONE==1
   return 0.0;
#else
  return [_MIP objectiveValue];
#endif
}

-(void) updateLowerBound: (MIPVariableI*) var lb: (ORDouble) lb
{
   [_MIP updateLowerBound: var lb: lb];
}
-(void) updateUpperBound: (MIPVariableI*) var ub: (ORDouble) ub
{
   [_MIP updateUpperBound: var ub: ub];
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
   [_MIP setIntParameter: name val: val];
}
-(void) setDoubleParameter: (const char*) name val: (ORDouble) val;
{
   [_MIP setDoubleParameter: name val: val];
}
-(void) setStringParameter: (const char*) name val: (char*) val
{
   [_MIP setStringParameter: name val: val];
}
-(ORDouble) paramValue: (MIPParameterI*) param
{
    return [_MIP paramValue: param];
}
-(void) setParam: (MIPParameterI*) param value: (ORDouble)val
{
    [_MIP setParam: param value: val];
}

-(void) tightenBound: (ORDouble)bnd
{
    [_MIP tightenBound: bnd];
}

-(void) injectSolution: (NSArray*)vars values: (NSArray*)vals size: (ORInt)size;
{
    [_MIP injectSolution: vars values: vals size: size];
}

-(id<ORDoubleInformer>) boundInformer
{
    return [_MIP boundInformer];
}

-(void) print;
{
   //
   //    for(ORInt i = 0; i < _nbVars; i++) {
   //    [_var[i] print];
   //    printf("\n");
   //    }
   //    printf("\n");
   //
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
   [_MIP printModelToFile: fileName];
}

-(void) cancel {
    [_MIP cancel];
}

//-(CotMIPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotMIPAbstractBasis* basis) ;

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
-(id) trackImmutable:(id)obj
{
   [_oStore addObject:obj];
   [obj release];
   return obj;
}
@end

@implementation MIPFactory

+(MIPSolverI*) solver
{
   return [MIPSolverI create];
}
@end;




