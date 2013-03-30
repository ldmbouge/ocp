/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LPSolverI.h"

#if defined(__x86_64__) || defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import "LPGurobi.h"
#endif

@implementation LPConstraintI;

-(LPConstraintI*) initLPConstraintI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   if (size < 0)
      @throw [[NSException alloc] initWithName:@"LPConstraint Error"
                                        reason:@"Constraint has negative size"
                                      userInfo:nil];
   [super init];
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
   NSLog(@"dealloc LPConstraintI");
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
   if (_tmpVar)
      free(_tmpVar);
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
   if (_col)
      free(_col);
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
   if (_tmpCoef)
      free(_tmpCoef);
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
   _type = LPleq;
   return [super initLPConstraintI: solver size: size var: var coef: coef rhs: rhs];
}
-(void) print
{
   [super print: "<="];
}
@end

@implementation LPConstraintGEQ;

-(LPConstraintI*) initLPConstraintGEQ: (LPSolverI*) solver size:  (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   _type = LPgeq;
   return [super initLPConstraintI: solver size: size var: var coef: coef rhs: rhs];
}
-(void) print
{
   [super print: ">="];
}

@end

@implementation LPConstraintEQ;

-(LPConstraintI*) initLPConstraintEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   _type = LPeq;
   return [super initLPConstraintI: solver size: size var: var coef: coef rhs: rhs];
}
-(void) print
{
   [super print: "="];
}
@end



@implementation LPObjectiveI;

-(LPObjectiveI*) initLPObjectiveI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
{
   [super init];
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
   NSLog(@"dealloc LPObjectiveI");
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
   if (_tmpVar)
      free(_tmpVar);
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
   if (_tmpCoef)
      free(_tmpCoef);
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
   _type = LPminimize;
   return [super initLPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
}
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
{
   _type = LPminimize;
   return [super initLPObjectiveI: solver size: size var: var coef: coef cst: cst];
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
   _type = LPmaximize;
   return [super initLPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
}
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
{
   _type = LPmaximize;
   return [super initLPObjectiveI: solver size: size var: var coef: coef cst: cst];
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
   [super init];
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
   [super init];
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
-(bool) hasBounds
{
   return _hasBounds;
}
-(void) dealloc
{
   NSLog(@"dealloc LPVariableI");
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
   [buf appendFormat:@"%f",[_solver floatValue:self]];
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
-(BOOL) isInteger
{
   return false;
}
@end


@implementation LPIntVariableI
-(LPIntVariableI*) initLPIntVariableI: (LPSolverI*) solver low: (ORFloat) low up: (ORFloat) up
{
   [super initLPVariableI: solver low: low up: up];
   return self;
}
-(LPIntVariableI*) initLPIntVariableI: (LPSolverI*) solver
{
   [super initLPVariableI: solver];
   return self;
}
-(BOOL) isInteger
{
   return true;
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
   [super init];
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
   [super init];
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
   [super init];
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
   NSLog(@"dealloc LPColumnI");
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
-(BOOL) hasBounds
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
   [super init];
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
   NSLog(@"dealloc LPLinearTermI");
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
   [super init];
#if defined(__x86_64__) || defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
   _lp = [[LPGurobiSolver alloc] initLPGurobiSolver];
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
   NSLog(@"dealloc LPSolverI");
   free(_var);
   free(_cstr);
   [_oStore release];
   [super dealloc];
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
-(LPVariableI*) createIntVariable: (ORFloat) low up: (ORFloat) up
{
   LPIntVariableI* v = [[LPIntVariableI alloc] initLPIntVariableI: self low: low up: up];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}
-(LPIntVariableI*) createIntVariable
{
   LPIntVariableI* v = [[LPIntVariableI alloc] initLPIntVariableI: self];
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
   [self trackObject: c];
   return c;
}
-(LPColumnI*) createColumn: (ORFloat) low up: (ORFloat) up
{
   LPColumnI* c = [[LPColumnI alloc] initLPColumnI: self low: low up: up];
   [c setNb: _createdCols++];
   [self trackObject: c];
   return c;
}
-(LPColumnI*) createColumn
{
   LPColumnI* c = [[LPColumnI alloc] initLPColumnI: self];
   [c setNb: _createdCols++];
   [self trackObject: c];
   return c;
}
-(LPLinearTermI*) createLinearTerm
{
   LPLinearTermI* o = [[LPLinearTermI alloc] initLPLinearTermI: self];
   [self trackObject: o];
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
   [self trackObject: o];
   return o;
}
-(LPObjectiveI*) createMinimize: (LPLinearTermI*) t
{
   [t close];
   LPObjectiveI* o = [[LPMinimize alloc] initLPMinimize: self size: [t size] var: [t var] coef: [t coef]];
   [o setNb: _createdObjs++];
   [self trackObject: o];
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
   [self trackObject: c];
   return c;
}
-(LPConstraintI*) createGEQ: (LPLinearTermI*) t rhs: (ORFloat) rhs;
{
   [t close];
   LPConstraintI* c = [[LPConstraintGEQ alloc] initLPConstraintGEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackObject: c];
   return c;
}
-(LPConstraintI*) createEQ: (LPLinearTermI*) t rhs: (ORFloat) rhs;
{
   [t close];
   LPConstraintI* c = [[LPConstraintEQ alloc] initLPConstraintEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackObject: c];
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
-(bool) isClosed
{
   return _isClosed;
}
-(LPOutcome) solve
{
   if (!_isClosed)
      [self close];
   return [_lp solve];
}

-(LPOutcome) status;
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
   return [_lp objectiveValue];
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

-(void) trackVariable: (id) var
{
   NSLog(@"Track Variable");
   [_oStore addObject: var];
   [var release];
}
-(void) trackObject:(id)obj
{
   [_oStore addObject:obj];
   [obj release];
}
-(void) trackConstraint:(id)obj
{
   [_oStore addObject:obj];
   [obj release];

}

@end

@implementation LPFactory

+(LPSolverI*) solver
{
   return [LPSolverI create];
}
@end;




