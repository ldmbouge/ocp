/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "MIPSolverI.h"

#if defined(__x86_64__) || defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import "MIPGurobi.h"
#endif

@implementation MIPConstraintI;

-(MIPConstraintI*) initMIPConstraintI: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   if (size < 0)
      @throw [[NSException alloc] initWithName:@"MIPConstraint Error"
                                        reason:@"Constraint has negative size"
                                      userInfo:nil];
   [super init];
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
   if (_tmpVar)
      free(_tmpVar);
   if (_tmpCoef)
      free(_tmpCoef);
   [super dealloc];
}
-(void) resize
{
   if (_size == _maxSize) {
      MIPVariableI** nvar = (MIPVariableI**) malloc(2 * _maxSize * sizeof(MIPVariableI*));
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
      free(_tmpVar);
   _tmpVar = (MIPVariableI**) malloc(_size * sizeof(MIPVariableI*));
   for(ORInt i = 0; i < _size; i++)
      _tmpVar[i] = _var[i];
   return _tmpVar;
}
-(MIPVariableI*) var: (ORInt) i
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
-(void) addVariable: (MIPVariableI*) var coef: (ORFloat) coef
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

-(MIPConstraintI*) initMIPConstraintLEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   _type = MIPleq;
   return [super initMIPConstraintI: solver size: size var: var coef: coef rhs: rhs];
}
-(void) print
{
   [super print: "<="];
}
@end

@implementation MIPConstraintGEQ;

-(MIPConstraintI*) initMIPConstraintGEQ: (MIPSolverI*) solver size:  (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   _type = MIPgeq;
   return [super initMIPConstraintI: solver size: size var: var coef: coef rhs: rhs];
}
-(void) print
{
   [super print: ">="];
}

@end

@implementation MIPConstraintEQ;

-(MIPConstraintI*) initMIPConstraintEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   _type = MIPeq;
   return [super initMIPConstraintI: solver size: size var: var coef: coef rhs: rhs];
}
-(void) print
{
   [super print: "="];
}
@end



@implementation MIPObjectiveI;

-(MIPObjectiveI*) initMIPObjectiveI: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
{
   [super init];
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
      MIPVariableI** nvar = (MIPVariableI**) malloc(2 * _maxSize * sizeof(MIPVariableI*));
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
      free(_tmpVar);
   _tmpVar = (MIPVariableI**) malloc(_size * sizeof(MIPVariableI*));
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
-(void) addVariable: (MIPVariableI*) var coef: (ORFloat) coef
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
   return [ORFactory objectiveValueFloat: [_solver mipvalue] + _cst minimize: true];
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

-(MIPObjectiveI*) initMIPMinimize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef
{
   _type = MIPminimize;
   return [super initMIPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
}
-(MIPObjectiveI*) initMIPMinimize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
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
   return [ORFactory objectiveValueFloat: [_solver mipvalue] + _cst minimize: true];
}

@end

@implementation MIPMaximize;

-(MIPObjectiveI*) initMIPMaximize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef
{
   _type = MIPmaximize;
   return [super initMIPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
}
-(MIPObjectiveI*) initMIPMaximize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst
{
   _type = MIPmaximize;
   return [super initMIPObjectiveI: solver size: size var: var coef: coef cst: cst];
}
-(void) print
{
   printf("maximize ");
   [super print];
}
-(id<ORObjectiveValue>) value
{
   return [ORFactory objectiveValueFloat: [_solver mipvalue] + _cst minimize: false];
}
@end

@implementation MIPVariableI
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver low: (ORFloat) low up: (ORFloat) up
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
   _cstr = (MIPConstraintI**) malloc(_maxSize * sizeof(MIPConstraintI*));
   _cstrIdx = NULL;
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
   
   return self;
}
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver
{
   [super init];
   _hasBounds = false;
   _solver = solver;
   _idx = -1;
   
   // data structure to preserve the constraint information
   _maxSize = 8;
   _size = 0;
   _cstr = (MIPConstraintI**) malloc(_maxSize * sizeof(MIPConstraintI*));
   _cstrIdx = NULL;
   _coef = (ORFloat*) malloc(_maxSize * sizeof(ORFloat));
   
   return self;
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
   [buf appendFormat:@"%f",[_solver floatValue:self]];
   return buf;
}
-(void) resize
{
   if (_size == _maxSize) {
      MIPConstraintI** ncstr = (MIPConstraintI**) malloc(2 * _maxSize * sizeof(MIPConstraintI*));
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
-(void) addConstraint: (MIPConstraintI*) c coef: (ORFloat) coef
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
-(void) addObjective: (MIPObjectiveI*) obj coef: (ORFloat) coef
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
-(ORFloat) floatValue
{
   return [_solver floatValue:self];
}
-(ORBool) isInteger
{
   return false;
}
@end


@implementation MIPIntVariableI
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver low: (ORFloat) low up: (ORFloat) up
{
   [super initMIPVariableI: solver low: low up: up];
   return self;
}
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver
{
   [super initMIPVariableI: solver];
   return self;
}
-(ORBool) isInteger
{
   return true;
}
-(ORInt) intValue
{
   return [_solver intValue: self];
}
@end



@implementation MIPLinearTermI

-(MIPLinearTermI*) initMIPLinearTermI: (MIPSolverI*) solver
{
   [super init];
   _solver = solver;
   _size = 0;
   _maxSize = 8;
   if (_maxSize == 0)
      _maxSize++;
   _var = (MIPVariableI**) malloc(_maxSize * sizeof(MIPVariableI*));
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
      MIPVariableI** nvar = (MIPVariableI**) malloc(2 * _maxSize * sizeof(MIPVariableI*));
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
-(MIPVariableI**) var
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
-(void) add: (ORFloat) coef times: (MIPVariableI*) var
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
   [super init];
#if defined(__x86_64__) || defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
   _MIP = [[MIPGurobiSolver alloc] initMIPGurobiSolver];
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
-(MIPIntVariableI*) createIntVariable: (ORFloat) low up: (ORFloat) up
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
-(MIPVariableI*) createVariable: (ORFloat) low up: (ORFloat) up
{
   MIPVariableI* v = [[MIPVariableI alloc] initMIPVariableI: self low: low up: up];
   [v setNb: _createdVars++];
   [self addVariable: v];
   [self trackVariable: v];
   return v;
}

-(MIPLinearTermI*) createLinearTerm
{
   MIPLinearTermI* o = [[MIPLinearTermI alloc] initMIPLinearTermI: self];
   [self trackObject: o];
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
   ORFloat* coef = [cstr coef];
   for(ORInt i = 0; i < size; i++)
      [var[i] addConstraint: cstr coef: coef[i]];
   return cstr;
}
-(MIPConstraintI*) createLEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createLEQ: t rhs: rhs];
}

-(MIPConstraintI*) createLEQ: (id<MIPVariableArray>) var coef: (id<ORFloatArray>) coef cst: (ORFloat) cst
{
   MIPLinearTermI* t = [self createLinearTerm];
   id<ORIntRange> R = [var range];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createLEQ: t rhs: -cst];
}
-(MIPConstraintI*) createEQ: (id<MIPVariableArray>) var coef: (id<ORFloatArray>) coef cst: (ORFloat) cst
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

-(MIPConstraintI*) createGEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createGEQ: t rhs: rhs];
   
}
-(MIPConstraintI*) createEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createEQ: t rhs: rhs];
}
-(MIPObjectiveI*) createMinimize: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createMinimize: t];
}
-(MIPObjectiveI*) createMaximize: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef
{
   MIPLinearTermI* t = [self createLinearTerm];
   for(ORInt i = 0; i < size; i++)
      [t add: coef[i] times: var[i]];
   return [self createMaximize: t];
}
-(MIPObjectiveI*) createMaximize: (MIPLinearTermI*) t
{
   [t close];
   MIPObjectiveI* o = [[MIPMaximize alloc] initMIPMaximize: self size: [t size] var: [t var] coef: [t coef]];
   [o setNb: _createdObjs++];
   [self trackObject: o];
   return o;
}
-(MIPObjectiveI*) createMinimize: (MIPLinearTermI*) t
{
   [t close];
   MIPObjectiveI* o = [[MIPMinimize alloc] initMIPMinimize: self size: [t size] var: [t var] coef: [t coef]];
   [o setNb: _createdObjs++];
   [self trackObject: o];
   return o;
}
-(MIPObjectiveI*)  createObjectiveMinimize: (id<MIPVariableArray>) var coef: (id<ORFloatArray>) coef
{
   MIPLinearTermI* t = [self createLinearTerm];
   ORInt low = [var low];
   ORInt up = [var up];
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createMinimize: t];
}
-(MIPObjectiveI*)  createObjectiveMaximize: (id<MIPVariableArray>) var coef: (id<ORFloatArray>) coef
{
   MIPLinearTermI* t = [self createLinearTerm];
   ORInt low = [var low];
   ORInt up = [var up];
   for(ORInt i = low; i <= up; i++)
      [t add: [coef at: i] times: var[i]];
   return [self createMaximize: t];
}

-(MIPConstraintI*) createLEQ: (MIPLinearTermI*) t rhs: (ORFloat) rhs;
{
   [t close];
   MIPConstraintI* c = [[MIPConstraintLEQ alloc] initMIPConstraintLEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackObject: c];
   return c;
}
-(MIPConstraintI*) createGEQ: (MIPLinearTermI*) t rhs: (ORFloat) rhs;
{
   [t close];
   MIPConstraintI* c = [[MIPConstraintGEQ alloc] initMIPConstraintGEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackObject: c];
   return c;
}
-(MIPConstraintI*) createEQ: (MIPLinearTermI*) t rhs: (ORFloat) rhs;
{
   [t close];
   MIPConstraintI* c = [[MIPConstraintEQ alloc] initMIPConstraintEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]];
   [c setNb: _createdCstrs++];
   [self trackObject: c];
   return c;
}

-(MIPConstraintI*) postConstraint: (MIPConstraintI*) cstr
{
   if ([cstr idx] < 0) {
      [cstr setIdx: _nbCstrs];
      [self addConstraint: cstr];
      if (_isClosed) {
         [_MIP addConstraint: cstr];
         [_MIP solve];
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
   ORFloat* coef = [obj coef];
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
      for(ORInt i = 0; i < _nbCstrs; i++)
         [_MIP addConstraint: _cstr[i]];
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

-(MIPOutcome) status;
{
   return [_MIP status];
}
-(ORInt) intValue: (MIPIntVariableI*) var
{
   return (ORInt) [_MIP intValue: var];
}
-(ORFloat) floatValue: (MIPVariableI*) var
{
   return [_MIP floatValue: var];
}
-(ORFloat) lowerBound: (MIPVariableI*) var
{
   return [_MIP lowerBound: var];
}
-(ORFloat) upperBound: (MIPVariableI*) var
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
-(ORFloat) mipvalue
{
   return [_MIP objectiveValue];
}

-(void) updateLowerBound: (MIPVariableI*) var lb: (ORFloat) lb
{
   [_MIP updateLowerBound: var lb: lb];
}
-(void) updateUpperBound: (MIPVariableI*) var ub: (ORFloat) ub
{
   [_MIP updateUpperBound: var ub: ub];
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
   [_MIP setIntParameter: name val: val];
}
-(void) setFloatParameter: (const char*) name val: (ORFloat) val;
{
   [_MIP setFloatParameter: name val: val];
}
-(void) setStringParameter: (const char*) name val: (char*) val
{
   [_MIP setStringParameter: name val: val];
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

//-(CotMIPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotMIPAbstractBasis* basis) ;

-(void) trackVariable: (id) var
{
   [_oStore addObject: var];
   [var release];
}
-(void) trackObject:(id)obj
{
   [_oStore addObject:obj];
   [obj release];
}
-(void) trackImmutable:(id)obj
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

@implementation MIPFactory

+(MIPSolverI*) solver
{
   return [MIPSolverI create];
}
@end;




