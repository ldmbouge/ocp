/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "lpsolver.h"
#import "lpsolveri.h"
#import <mpwrapperfactory/mpwrapperfactory.h>

@implementation LPConstraintI;

-(LPConstraintI*) initLPConstraintI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (double*) coef rhs: (double) rhs
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
    for(CPInt i = 0; i < _size; i++)
        _var[i] = [var[i] retain];
    _col = NULL;
    _coef = (double*) malloc(_maxSize * sizeof(double));
    for(CPInt i = 0; i < _size; i++)
        _coef[i] = coef[i];
    _rhs = rhs;
    
    _tmpVar = NULL;
    _tmpCoef = NULL;
    return self;
}
-(void) dealloc
{
    for(CPInt i = 0; i < _size; i++)
        [_var[i] release];
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
        double* ncoef = (double*) malloc(2 * _maxSize * sizeof(double));
        for(CPInt i = 0; i < _size; i++) {
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
    for(CPInt i = 0; i < _size; i++)
        _tmpVar[i] = _var[i];
    return _tmpVar;
}
-(id<LPVariable>) var: (ORInt) i
{
    return _var[i];
}
-(CPInt*) col
{
    if (_col)
        free(_col);
    _col = (CPInt*) malloc(_size * sizeof(ORInt));
    for(CPInt i = 0; i < _size; i++)
        _col[i] = [_var[i] idx];
    return _col;
}
-(ORInt) col: (ORInt) i
{
   return [_var[i] idx];
}
-(double*) coef
{
    if (_tmpCoef)
        free(_tmpCoef);
    _tmpCoef = (double*) malloc(_size * sizeof(double));
    for(CPInt i = 0; i < _size; i++)
        _tmpCoef[i] = _coef[i];
    return _tmpCoef;
}
-(double) coef: (ORInt) i
{
    return _coef[i];
}

-(double) rhs
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
    for(CPInt i = 0; i < _size; i++)
        [_var[i] delConstraint: self];
    _idx = -1;
}
-(void) delVariable: (LPVariableI*) var
{
    // linear algorithm: could be replaced by log(n)
    int k = -1;
    for(CPInt i = 0; i < _size; i++)
        if (_var[i] == var) {
            k = i;
            break;
        }
    if (k >= 0) {
        [_var[k] release];
        _size--;
        for(CPInt i = k; i < _size; i++) {
            _coef[i] = _coef[i+1];
            _var[i] = _var[i+1];
        }
    }
}
-(void) addVariable: (LPVariableI*) var coef: (double) coef
{
    [self resize];
    _var[_size] = [var retain];
    _coef[_size] = coef;
    _size++;
}
-(void) print: (char*) o
{
    for(CPInt i = 0; i < _size; i++) {
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
-(double) dual
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

-(LPConstraintI*) initLPConstraintLEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (double*) coef rhs: (double) rhs
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

-(LPConstraintI*) initLPConstraintGEQ: (LPSolverI*) solver size:  (ORInt) size var: (LPVariableI**) var coef: (double*) coef rhs: (double) rhs
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

-(LPConstraintI*) initLPConstraintEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (double*) coef rhs: (double) rhs
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

-(LPObjectiveI*) initLPObjectiveI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (double*) coef cst: (double) cst
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
    for(CPInt i = 0; i < _size; i++)
        _var[i] = [var[i] retain];
    _col = NULL;
    _coef = (double*) malloc(_maxSize * sizeof(double));
    for(CPInt i = 0; i < _size; i++)
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
        double* ncoef = (double*) malloc(2 * _maxSize * sizeof(double));
        for(CPInt i = 0; i < _size; i++) {
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
    for(CPInt i = 0; i < _size; i++)
        [_var[i] release];
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
    for(CPInt i = 0; i < _size; i++)
        _tmpVar[i] = _var[i];
    return _tmpVar;
}
-(CPInt*) col
{
    _col = (CPInt*) malloc(_size * sizeof(ORInt));
    for(CPInt i = 0; i < _size; i++)
        _col[i] = [_var[i] idx];
    return _col;
}
-(double*) coef
{
    if (_tmpCoef)
        free(_tmpCoef);
    _tmpCoef = (double*) malloc(_size * sizeof(double));
    for(CPInt i = 0; i < _size; i++)
        _tmpCoef[i] = _coef[i];
    return _tmpCoef;   
}
-(void) print
{
    for(CPInt i = 0; i < _size; i++) {
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
    for(CPInt i = 0; i < _size; i++)
        if (_var[i] == var) {
            k = i;
            break;
        }
    if (k >= 0) {
        [_var[k] release];
        _size--;
        for(CPInt i = k; i < _size; i++) {
            _coef[i] = _coef[i+1];
            _var[i] = _var[i+1];
        }
    }
}
-(void) addVariable: (LPVariableI*) var coef: (double) coef
{
    [self resize];
    _var[_size] = [var retain];
    _coef[_size] = coef;
    _size++;
}
-(void) addCst: (double) cst
{
    _cst += cst;
}
-(void) setPosted
{
    _posted = true;
}
-(double) value
{
    return [_solver lpValue] + _cst;
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

-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (double*) coef 
{
    _type = LPminimize;
    return [super initLPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
}
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (double*) coef cst: (double) cst
{
    _type = LPminimize;
    return [super initLPObjectiveI: solver size: size var: var coef: coef cst: cst];
}
-(void) print
{
    printf("minimize ");
    [super print];
}
@end

@implementation LPMaximize;

-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (double*) coef 
{
    _type = LPmaximize;
    return [super initLPObjectiveI: solver size: size var: var coef: coef cst: 0.0];
}
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (double*) coef cst: (double) cst
{
    _type = LPmaximize;
    return [super initLPObjectiveI: solver size: size var: var coef: coef cst: cst];
}
-(void) print
{
    printf("maximize ");   
    [super print];
}
@end

@implementation LPVariableI
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver low: (double) low up: (double) up
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
    _coef = (double*) malloc(_maxSize * sizeof(double));
    
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
    _coef = (double*) malloc(_maxSize * sizeof(double));
    
    return self;
}
-(bool) hasBounds
{
    return _hasBounds;
}
-(void) dealloc
{
    for(CPInt i = 0; i < _size; i++)
        [_cstr[i] release];
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

-(double) low
{
    return _low;
}
-(double) up
{
    return _up;
}
-(void) resize
{
    if (_size == _maxSize) {
        LPConstraintI** ncstr = (LPConstraintI**) malloc(2 * _maxSize * sizeof(LPConstraintI*));
        double* ncoef = (double*) malloc(2 * _maxSize * sizeof(double));
        for(CPInt i = 0; i < _size; i++) {
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
-(void) addConstraint: (LPConstraintI*) c coef: (double) coef
{
    [self resize];
    _cstr[_size] = [c retain];
    _coef[_size] = coef;
    _size++;
}
-(void) delConstraint: (LPConstraintI*) c
{
    int k;
    for(CPInt i = 0; i < _size; i++) {
        if (_cstr[i] == c) {
            k = i;
            break;
        }
    }
    if (k < _size) {
        [_cstr[k] release];
        _size--;
        for(CPInt i = k; i < _size; i++) {
            _cstr[i] = _cstr[i+1];
            _coef[i] = _coef[i+1];
        }
    }
}
-(void) del
{
    [_obj delVariable: self];
    for(CPInt i = 0; i < _size; i++)
        [_cstr[i] delVariable: self];
    _idx = -1;
}
-(void) addObjective: (LPObjectiveI*) obj coef: (double) coef
{
    _obj = obj;
    _objCoef = coef;
}
-(void) print
{
    printf("variable %d:",_idx);
    printf(" obj: %f",_objCoef);
    printf(" cstrs: ");
    for(CPInt i = 0; i < _size; i++)
        printf("(%d,%f)",[_cstr[i] idx],_coef[i]);
}
-(LPColumnI*) column
{
    return [_solver createColumn:_low up:_up size:_size obj:_objCoef cstr:_cstr coef:_coef];
}
-(double) value
{
    return [_solver value: self];
}
-(double) reducedCost
{
    return [_solver reducedCost: self];
}
@end


@implementation LPColumnI

-(LPColumnI*) initLPColumnI: (LPSolverI*) solver 
                        low: (double) low 
                         up: (double) up 
                       size: (ORInt) size 
                        obj: (double) obj 
                       cstr: (LPConstraintI**) cstr 
                       coef: (double*) coef
    
{
    [super init];
    _solver = solver;
    _low = low;
    _up = up;
    _size = size;
    _maxSize = size;
    if (_maxSize == 0)
        _maxSize++;
    _objCoef = obj;
    _cstr = (LPConstraintI**) malloc(_maxSize * sizeof(LPConstraintI*));
    for(CPInt i = 0; i < _size; i++)
        _cstr[i] = [cstr[i] retain];
    _cstrIdx = NULL;
    _coef = (double*) malloc(_maxSize * sizeof(double));
    for(CPInt i = 0; i < _size; i++)
        _coef[i] = coef[i];
    _tmpCstr = NULL;
    _tmpCoef = NULL;
    return self;
}

-(LPColumnI*) initLPColumnI: (LPSolverI*) solver 
                        low: (double) low 
                         up: (double) up 
{
    [super init];
    _solver = solver;
    _low = low;
    _up = up;
    _size = 0;
    _maxSize = 8;
    _cstr = (LPConstraintI**) malloc(_maxSize * sizeof(LPConstraintI*));
    _cstrIdx = NULL;
    _coef = (double*) malloc(_maxSize * sizeof(double));
    return self;
}
-(void) dealloc
{
    if (_cstrIdx)
        free(_cstrIdx);
    for(CPInt i = 0; i < _size; i++)
        [_cstr[i] release];
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
        double* ncoef = (double*) malloc(2 * _maxSize * sizeof(double));
        for(CPInt i = 0; i < _size; i++) {
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
-(double) low
{
    return _low;
}
-(double) up
{
    return _up;
}
-(double) objCoef
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
    for(CPInt i = 0; i < _size; i++)
        _tmpCstr[i] = _cstr[i];
    return _tmpCstr;   
}
-(CPInt*) cstrIdx
{
    if (_cstrIdx)
        free(_cstrIdx);
    _cstrIdx = (CPInt*) malloc(_size * sizeof(ORInt));
    for(CPInt i = 0; i < _size; i++) 
        _cstrIdx[i] = [_cstr[i] idx];
    return _cstrIdx;
}
-(double*) coef
{
    if (_tmpCoef)
        free(_tmpCoef);
    _tmpCoef = (double*) malloc(_size * sizeof(double));
    for(CPInt i = 0; i < _size; i++)
        _tmpCoef[i] = _coef[i];
    return _tmpCoef;   
}
-(void) fill: (LPVariableI*) v obj: (LPObjectiveI*) obj
{
    // Fill the variables
    if (obj)
        [v addObjective: obj coef: _objCoef];
    for(CPInt i = 0; i < _size; i++) {
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
    for(CPInt i = 0; i < _size; i++) 
        [_cstr[i] addVariable: v coef: _coef[i]];
}
-(void) addObjCoef: (double) coef
{
    _objCoef = coef;
}
-(void) addConstraint: (LPConstraintI*) cstr coef: (double) coef
{
    [self resize];
    _cstr[_size] = [cstr retain];
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
    _coef = (double*) malloc(_maxSize * sizeof(double));
    return self;
}
-(LPLinearTermI*) initLPLinearTermI: (LPSolverI*) solver range: (IRange) R coef: (LPInt2Double) c var: (LPInt2Var) v
{
    [super init];
    _solver = solver;
    int low = R.low;
    int up = R.up;
    if (up - low + 1 < 0)
        @throw [[NSException alloc] initWithName:@"LPSolver Error" 
                                          reason:@"Linear Term has zero size" 
                                        userInfo:nil];    
    _maxSize = (up -low +1);
    if (_maxSize == 0)
        _maxSize++;
    _var = (LPVariableI**) malloc(_maxSize * sizeof(LPVariableI*));
    _coef = (double*) malloc(_maxSize * sizeof(double));
    for (int i=low ; i <= up; i++) 
        [self add: c(i) times: v(i)];
    return self;    
}
-(void) dealloc
{
    for(CPInt i = 0; i < _size; i++)
        [_var[i] release];
    free(_var);
    free(_coef);
    [super dealloc];   
}
-(void) resize
{
    if (_size == _maxSize) {
        LPVariableI** nvar = (LPVariableI**) malloc(2 * _maxSize * sizeof(LPVariableI*));
        double* ncoef = (double*) malloc(2 * _maxSize * sizeof(double));
        for(CPInt i = 0; i < _size; i++) {
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
-(double*) coef
{
    return _coef; 
}
-(double) cst
{
    return _cst;
}
-(void) add: (double) cst
{
    _cst = cst;
}
-(void) add: (double) coef times: (LPVariableI*) var
{
    [self resize];
    _var[_size] = [var retain];
    _coef[_size] = coef;
    _size++;
}
-(void) close
{
    int lidx = MAXINT;
    int uidx = -1;
    for(CPInt i = 0; i < _size; i++) {
        int idx = [_var[i] idx];
        if (idx < lidx)
            lidx = idx;
        if (idx > uidx)
            uidx = idx;
    }
    int sizeIdx = (uidx - lidx + 1);
    double* bucket = (double*) alloca(sizeIdx * sizeof(double));
    LPVariableI** bucketVar = (LPVariableI**) alloca(sizeIdx * sizeof(LPVariableI*));
    bucket -= lidx;
    for(CPInt i = lidx; i <= uidx; i++) 
        bucket[i] = 0.0;
    for(CPInt i = 0; i < _size; i++) {
        int idx = [_var[i] idx];
        bucket[idx] += _coef[idx];
        bucketVar[idx] = _var[i];
    }
    int nb = 0;
    for(CPInt i = lidx; i <= uidx; i++) {
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

+(id<LPSolver>) create
{
    return [[LPSolverI alloc] initLPSolverI];
}
-(LPSolverI*) initLPSolverI
{
    [super init];
    _lp = [MPWrapperFactory lpwrapper];  
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
    return self;
}
-(void) dealloc
{
    for(CPInt i = 0; i < _nbVars; i++) 
        [_var[i] release];
    for(CPInt i = 0; i < _nbCstrs; i++) 
        [_cstr[i] release];
    free(_var);
    free(_cstr);
    [super dealloc];
}
-(void) addVariable: (LPVariableI*) v
{
    if (_nbVars == _maxVars) {
        LPVariableI** nvar = (LPVariableI**) malloc(2 * _maxVars * sizeof(LPVariableI*));
        for(CPInt i = 0; i < _nbVars; i++) 
            nvar[i] = _var[i];
        free(_var);
        _var = nvar;
        _maxVars *= 2;
    }
    [v setIdx: _nbVars];
    _var[_nbVars++] = [v retain];
}

-(id<LPVariable>) createVariable
{
    LPVariableI* v = [[[LPVariableI alloc] initLPVariableI: self] autorelease];
    [v setNb: _createdVars++];
    [self addVariable: v];   
    return v;
}
-(LPVariableI*) createVariable: (double) low up: (double) up
{
    LPVariableI* v = [[[LPVariableI alloc] initLPVariableI: self low: low up: up] autorelease];
    [v setNb: _createdVars++];
    [self addVariable: v];   
    return v;
}
-(LPColumnI*) createColumn: (double) low up: (double) up size: (ORInt) size obj: (double) obj cstr: (id<LPConstraint>*) cstr coef: (double*) coef
{
    LPColumnI* c = [[[LPColumnI alloc] initLPColumnI: self low: low up: up size: size obj: obj cstr: cstr coef: coef] autorelease];
    [c setNb: _createdCols++];
    return c;
}
-(LPColumnI*) createColumn: (double) low up: (double) up 
{
    LPColumnI* c = [[[LPColumnI alloc] initLPColumnI: self low: low up: up] autorelease];
    [c setNb: _createdCols++];
    return c;
}
-(LPLinearTermI*) createLinearTerm
{
    return [[[LPLinearTermI alloc] initLPLinearTermI: self] autorelease]; 
}
-(LPLinearTermI*) createLinearTerm: (IRange) R coef: (LPInt2Double) c var: (LPInt2Var) v
{
    return [[[LPLinearTermI alloc] initLPLinearTermI: self range: R coef: c var: v] autorelease];    
}
-(void) addConstraint: (LPConstraintI*) cstr
{
    if (_nbCstrs == _maxCstrs) {
        LPConstraintI** ncstr = (LPConstraintI**) malloc(2 * _maxCstrs * sizeof(LPConstraintI*));
        for(CPInt i = 0; i < _nbCstrs; i++) 
            ncstr[i] = _cstr[i];
        free(_cstr);
        _cstr = ncstr;
        _maxCstrs *= 2;
    }
    _cstr[_nbCstrs++] = [cstr retain];
    
    int size = [cstr size];
    LPVariableI** var = [cstr var];
    double* coef = [cstr coef];
    for(CPInt i = 0; i < size; i++)
        [var[i] addConstraint: cstr coef: coef[i]];
    
}
-(id<LPConstraint>) createLEQ: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs
{
    id<LPLinearTerm> t = [self createLinearTerm];
    for(CPInt i = 0; i < size; i++) 
        [t add: coef[i] times: var[i]];
    return [self createLEQ: t rhs: rhs];
}
-(id<LPConstraint>) createGEQ: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs
{
    id<LPLinearTerm> t = [self createLinearTerm];
    for(CPInt i = 0; i < size; i++) 
        [t add: coef[i] times: var[i]];
    return [self createGEQ: t rhs: rhs];
   
 }
-(id<LPConstraint>) createEQ: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs
{
    id<LPLinearTerm> t = [self createLinearTerm];
    for(CPInt i = 0; i < size; i++) 
        [t add: coef[i] times: var[i]];
    return [self createEQ: t rhs: rhs];
}
-(id<LPObjective>) createMinimize: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef 
{
    id<LPLinearTerm> t = [self createLinearTerm];
    for(CPInt i = 0; i < size; i++) 
        [t add: coef[i] times: var[i]];
    return [self createMinimize: t];
}
-(id<LPObjective>) createMaximize: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef 
{
    id<LPLinearTerm> t = [self createLinearTerm];
    for(CPInt i = 0; i < size; i++) 
        [t add: coef[i] times: var[i]];
    return [self createMaximize: t];
}
-(id<LPObjective>) createMaximize: (LPLinearTermI*) t
{
    if (![t isKindOfClass: [LPLinearTermI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The linear term was not constructed by the solver" 
                                        userInfo:nil];  
    }
    [t close];
    LPObjectiveI* o = [[[LPMaximize alloc] initLPMaximize: self size: [t size] var: [t var] coef: [t coef]] autorelease]; 
    [o setNb: _createdObjs++];
    return o;
}
-(id<LPObjective>) createMinimize: (id<LPLinearTerm>) ti
{
    if (![ti isKindOfClass: [LPLinearTermI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The linear term was not constructed by the solver" 
                                        userInfo:nil];  
    }
    LPLinearTermI* t = ti;
    [t close];
    LPObjectiveI* o = [[[LPMinimize alloc] initLPMinimize: self size: [t size] var: [t var] coef: [t coef]] autorelease]; 
    [o setNb: _createdObjs++];
    return o; 
}
-(id<LPConstraint>) createLEQ: (id<LPLinearTerm>) ti rhs: (double) rhs;
{
    if (![ti isKindOfClass: [LPLinearTermI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The linear term was not constructed by the solver" 
                                        userInfo:nil];  
    }
    LPLinearTermI* t = ti;
    [t close];
    LPConstraintI* c = [[[LPConstraintLEQ alloc] initLPConstraintLEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]] autorelease];
    [c setNb: _createdCstrs++];
    return c; 
}
-(id<LPConstraint>) createGEQ: (id<LPLinearTerm>) ti rhs: (double) rhs;
{
    if (![ti isKindOfClass: [LPLinearTermI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The linear term was not constructed by the solver" 
                                        userInfo:nil];  
    }
    LPLinearTermI* t = ti;
    [t close];
    LPConstraintI* c = [[[LPConstraintGEQ alloc] initLPConstraintGEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]] autorelease];
    [c setNb: _createdCstrs++];
    return c;   
 }
-(id<LPConstraint>) createEQ: (id<LPLinearTerm>) ti rhs: (double) rhs;
{
    if (![ti isKindOfClass: [LPLinearTermI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The linear term was not constructed by the solver" 
                                        userInfo:nil];  
    }
    LPLinearTermI* t = ti;
    [t close];
     LPConstraintI* c = [[[LPConstraintEQ alloc] initLPConstraintEQ: self size: [t size] var: [t var] coef: [t coef] rhs: rhs-[t cst]] autorelease];
    [c setNb: _createdCstrs++];
    return c; 
}

-(id<LPConstraint>) postConstraint: (id<LPConstraint>) cstrItf
{
    if (![cstrItf isKindOfClass: [LPConstraintI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The constraint was not constructed by the solver" 
                                        userInfo:nil];  
    }
    LPConstraintI* cstr = cstrItf;
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
-(void) removeConstraint: (id<LPConstraint>) cstrItf
{
    if (![cstrItf isKindOfClass: [LPConstraintI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The constraint was not constructed by the solver" 
                                        userInfo:nil];  
    }

    LPConstraintI* cstr = cstrItf;
    if ([cstr idx] < 0) 
        @throw [[NSException alloc] initWithName:@"LPSolver Error" 
                                          reason:@"Constraint is not present" 
                                        userInfo:nil];     
    int k = -1;
    for(CPInt i = 0; i < _nbCstrs; i++) 
        if (_cstr[i] == cstr) {
            k = i;
            break;
        }
    if (k >= 0) {
        [_lp delConstraint: cstr];
        [cstr del];
        [_cstr[k] release];
        _nbCstrs--;
        for(CPInt i = k; i < _nbCstrs; i++) {
            _cstr[i] = _cstr[i+1];
            [_cstr[i] setIdx: i];
        }
    }
    if (_isClosed)
        [_lp solve];
}
-(void) removeVariable: (id<LPVariable>) vari
{
    if (![vari isKindOfClass: [LPVariableI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The variable was not constructed by the solver" 
                                        userInfo:nil];  
    }

    LPVariableI* var = vari;
    if ([var idx] < 0) 
        @throw [[NSException alloc] initWithName:@"LPSolver Error" 
                                          reason:@"Variable is not present" 
                                        userInfo:nil];     
    int k = -1;
    for(CPInt i = 0; i < _nbVars; i++) 
        if (_var[i] == var) {
            k = i;
            break;
        }
    if (k >= 0) {
        [_lp delVariable: var];
        [var del];
        [_var[k] release];
        _nbVars--;
        for(CPInt i = k; i < _nbVars; i++) {
            _var[i] = _var[i+1];
            [_var[i] setIdx: i];
        }
    }
    if (_isClosed)
        [_lp solve];    
}
-(id<LPObjective>) postObjective: (id<LPObjective>) objItf
{
    if (![objItf isKindOfClass: [LPObjectiveI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The objective was not constructed by the solver" 
                                        userInfo:nil];  
    }
    LPObjectiveI* obj = objItf;
    if (_obj != NULL) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"Objective function already posted" 
                                        userInfo:nil];       
    }
    _obj = obj;
    
    int size = [obj size];
    LPVariableI** var = [obj var];
    double* coef = [obj coef];
    for(CPInt i = 0; i < size; i++)
        [var[i] addObjective: obj coef: coef[i]];
    return _obj;
}

-(id<LPVariable>) postColumn: (id<LPColumn>) coli
{
    if (![coli isKindOfClass: [LPColumnI class]]) {
        @throw [[NSException alloc] initWithName:@"LP Solver Error" 
                                          reason:@"The column was not constructed by the solver" 
                                        userInfo:nil];  
    }
    LPColumnI* col = coli;
    LPVariableI* v = [self createVariable: [col low] up: [col up]];
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
        for(CPInt i = 0; i < _nbVars; i++)
            [_lp addVariable: _var[i]];
        for(CPInt i = 0; i < _nbCstrs; i++)
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
-(double) value: (LPVariableI*) var
{
    return [_lp value: var];
}
-(double) lowerBound: (LPVariableI*) var
{
    return [_lp lowerBound: var];
}
-(double) upperBound: (LPVariableI*) var
{
    return [_lp upperBound: var];
}
-(double) reducedCost: (LPVariableI*) var
{
    return [_lp reducedCost: var];
}
-(double) dual: (LPConstraintI*) cstr;
{
    return [_lp dual: cstr];
}
-(double) objectiveValue
{
    if (_obj)
        return [_obj value];
    else
        @throw [[NSException alloc] initWithName:@"LPSolver Error" 
                                          reason:@"No objective function posted" 
                                        userInfo:nil];  
    return 0.0;
}
-(double) lpValue
{
    return [_lp objectiveValue];
}

-(void) updateLowerBound: (LPVariableI*) var lb: (double) lb
{
    [_lp updateLowerBound: var lb: lb];
}
-(void) updateUpperBound: (LPVariableI*) var ub: (double) ub
{
    [_lp updateUpperBound: var ub: ub];
}
-(void) removeLastConstraint
{
    [_lp removeLastConstraint];
}
-(void) removeLastVariable
{
    [_lp removeLastVariable];
}

-(void) setIntParameter: (const char*) name val: (ORInt) val
{
    [_lp setIntParameter: name val: val];
}
-(void) setFloatParameter: (const char*) name val: (double) val;
{
    [_lp setFloatParameter: name val: val];
}
-(void) setStringParameter: (const char*) name val: (char*) val
{
    [_lp setStringParameter: name val: val];
}

-(void) print;
{
    /*
    for(CPInt i = 0; i < _nbVars; i++) {
        [_var[i] print];
        printf("\n");
    }
    printf("\n");
     */
    if (_obj || _nbCstrs > 0) {
        if (_obj) 
            [_obj print];
        printf("subject to \n");
        for(CPInt i = 0; i < _nbCstrs; i++) {
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

@end

@implementation LPFactory 

+(id<LPSolver>) solver 
{
    return [LPSolverI create];
}
@end;



