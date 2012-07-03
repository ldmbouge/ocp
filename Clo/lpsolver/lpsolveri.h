/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <objc/objc-auto.h>
#import <Foundation/NSGarbageCollector.h>
#import <Foundation/NSObject.h>
#import <mpwrapper/mpwrapper.h>

@class LPConstraintI;
@class LPObjectiveI;
@class LPColumnI;
@class LPSolverI;
@class LPVariableI;
@class LPLinearTermI;

#define MAXINT ((CPInt)0x7FFFFFFF)
#define MININT ((CPInt)0x80000000)


@interface LPVariableI : NSObject <LPVariable>
{
@protected
    LPSolverI*            _solver;
    int                   _nb;
    int                   _idx;
    double                _low;
    double                _up;
    LPObjectiveI*         _obj;
    double                _objCoef;
    int                   _size;
    int                   _maxSize;
    LPConstraintI**       _cstr;
    int*                  _cstrIdx;
    double*               _coef;
    bool                  _hasBounds;
}
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver;
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver low: (double) low up: (double) up;
-(bool) hasBounds;
-(double) low;
-(double) up;
-(CPInt) idx;
-(void) setIdx: (CPInt) idx;

-(void) addConstraint: (LPConstraintI*) c coef: (double) coef;
-(void) delConstraint: (LPConstraintI*) c;
-(void) addObjective: (LPObjectiveI*) obj coef: (double) coef;
-(void) print;
-(void) del;
-(LPColumnI*) column;
-(double) value;
-(double) reducedCost;
-(void) setNb: (CPInt) nb;
-(CPInt) nb;
@end

@interface LPConstraintI : NSObject <LPConstraint>
{
@protected
    LPSolverI*           _solver;
    int                  _nb;
    int                 _idx;
    LPConstraintType    _type;
    int                 _maxSize;
    int                 _size;
    LPVariableI**       _var;
    int*                _col;
    double*             _coef;
    double              _rhs;
    
    LPVariableI**       _tmpVar;
    double*             _tmpCoef;
}
-(LPConstraintI*)      initLPConstraintI: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef rhs: (double) rhs;
-(void)                dealloc;
-(LPConstraintType)    type;
-(CPInt)                 size;
-(LPVariableI**)       var;
-(id<LPVariable>)      var: (CPInt) i;
-(CPInt*)                col;
-(CPInt)                 col: (CPInt) i;
-(double*)             coef;
-(double)              coef: (CPInt) i;
-(double)              rhs;
-(CPInt)                 idx;
-(void)                setIdx: (CPInt) idx;
-(void)                del;
-(void)                delVariable: (LPVariableI*) var;
-(void)                addVariable: (LPVariableI*) var coef: (double) coef;
-(double)              dual;
-(void) setNb: (CPInt) nb;
-(CPInt) nb;
@end

@interface LPConstraintLEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintLEQ: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef rhs: (double) rhs;
@end

@interface LPConstraintGEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintGEQ: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef rhs: (double) rhs;
@end

@interface LPConstraintEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintEQ: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef rhs: (double) rhs;
@end

@interface LPObjectiveI : NSObject <LPObjective>
{
@protected
    LPSolverI*          _solver;
    int                 _nb;
    LPObjectiveType     _type;
    int                 _size;
    int                _maxSize;
    LPVariableI**        _var;
    int*                _col;
    double*             _coef;
    double              _cst;
    bool                _posted;
    LPVariableI**       _tmpVar;
    double*             _tmpCoef;
}
-(LPObjectiveI*) initLPObjectiveI: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef cst: (double) cst;
-(void) dealloc;
-(LPObjectiveType) type;
-(CPInt) size;
-(LPVariableI**) var;
-(CPInt*) col;
-(double*) coef;
-(void) print;
-(void) delVariable: (LPVariableI*) var;
-(void) addVariable: (LPVariableI*) var coef: (double) coef;
-(void) addCst: (double) cst;
-(double) value;
-(void) setPosted;
-(void) setNb: (CPInt) nb;
-(CPInt) nb;
@end

@interface LPMinimize : LPObjectiveI
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef;
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef cst: (double) cst;
-(void) print;
@end

@interface LPMaximize : LPObjectiveI
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef;
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (CPInt) size var: (LPVariableI**) var coef: (double*) coef cst: (double) cst;
-(void) print;
@end

@interface LPColumnI : NSObject <LPColumn>
{
@protected
    LPSolverI*             _solver;
    int                    _nb;
    int                   _maxSize;
    int                   _idx;
    double                _low;
    double                _up;
    double                _objCoef;
    int                   _size;
    LPConstraintI**       _cstr;
    int*                  _cstrIdx;
    double*               _coef;
    LPConstraintI**       _tmpCstr;
    double*               _tmpCoef;

}
-(LPColumnI*) initLPColumnI: (LPSolverI*) solver low: (double) low up: (double) up;
-(LPColumnI*) initLPColumnI: (LPSolverI*) solver low: (double) low up: (double) up size: (CPInt) size obj: (double) obj cstr: (LPConstraintI**) idx coef: (double*) coef;
-(void)      dealloc;

-(CPInt) idx;
-(void) setIdx: (CPInt) idx;
-(double) low;
-(double) up;
-(double) objCoef;
-(CPInt) size;
-(CPInt*) cstrIdx;
-(double*) coef;
-(void) fill: (LPVariableI*) v obj: (LPObjectiveI*) obj;
-(void) addObjCoef: (double) coef;
-(void) addConstraint: (LPConstraintI*) cstr coef: (double) coef;
-(void) setNb: (CPInt) nb;
-(CPInt)  nb;
@end

@interface LPLinearTermI : NSObject
{
@protected
    LPSolverI*           _solver;
    int                 _size;
    int                 _maxSize;
    LPVariableI**        _var;
    double*             _coef;
    double              _cst;
}
-(LPLinearTermI*) initLPLinearTermI: (LPSolverI*) solver;
-(LPLinearTermI*) initLPLinearTermI: (LPSolverI*) solver range: (IRange) R coef: (LPInt2Double) c var: (LPInt2Var) v;
-(void) dealloc;
-(CPInt) size;
-(LPVariableI**) var;
-(double*) coef;
-(double) cst;
-(void) add: (double) cst;
-(void) add: (double) coef times: (LPVariableI*) var;
-(void) close;
@end

@interface LPSolverI : NSObject<LPSolver> {
    id<LPSolverWrapper> _lp;
    int                 _nbVars;
    int                 _maxVars;
    LPVariableI**        _var;
    
    int                 _nbCstrs;
    int                 _maxCstrs;
    LPConstraintI**      _cstr;
    
    LPObjectiveI*        _obj;

    int                 _createdVars;
    int                 _createdCstrs;  
    int                 _createdObjs;   
    int                 _createdCols; 
    bool                _isClosed;
    
}

-(LPSolverI*) initLPSolverI;
-(void) dealloc;

+(id<LPSolver>)     create;
-(id<LPVariable>)   createVariable;
-(id<LPVariable>)   createVariable: (double) low up: (double) up;
-(id<LPColumn>)     createColumn: (double) low up: (double) up size: (CPInt) size obj: (double) obj cstr: (id<LPConstraint>*) idx coef: (double*) coef;
-(id<LPColumn>)     createColumn: (double) low up: (double) up;

-(id<LPLinearTerm>) createLinearTerm;
-(id<LPLinearTerm>)  createLinearTerm:(IRange) R coef: (LPInt2Double) c var: (LPInt2Var) v;

-(id<LPConstraint>) createLEQ: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPConstraint>) createGEQ: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPConstraint>) createEQ: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPObjective>)  createMinimize: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef;
-(id<LPObjective>)  createMaximize: (CPInt) size var: (id<LPVariable>*) var coef: (double*) coef;

-(id<LPConstraint>) createLEQ: (id<LPLinearTerm>) t rhs: (double) rhs;
-(id<LPConstraint>) createGEQ: (id<LPLinearTerm>) t rhs: (double) rhs;
-(id<LPConstraint>) createEQ:  (id<LPLinearTerm>) t  rhs: (double) rhs;
-(id<LPObjective>)  createMinimize: (id<LPLinearTerm>) t;
-(id<LPObjective>)  createMaximize: (id<LPLinearTerm>) t;



-(id<LPConstraint>) postConstraint: (id<LPConstraint>) cstr;
-(void) removeConstraint: (id<LPConstraint>) cstr;
-(void) removeVariable: (id<LPVariable>) var;
-(id<LPObjective>) postObjective: (id<LPObjective>) obj;
-(id<LPVariable>) postColumn: (id<LPColumn>) col;

-(void) close;
-(bool) isClosed;
-(LPOutcome) solve;

-(LPOutcome) status;
-(double) value: (LPVariableI*) var;
-(double) lowerBound: (LPVariableI*) var;
-(double) upperBound: (LPVariableI*) var;
-(double) reducedCost: (LPVariableI*) var;
-(double) dual: (LPConstraintI*) cstr;
-(double) objectiveValue;
-(double) lpValue;

-(void) updateLowerBound: (LPVariableI*) var lb: (double) lb;
-(void) updateUpperBound: (LPVariableI*) var ub: (double) ub;
-(void) removeLastConstraint;
-(void) removeLastVariable;

-(void) setIntParameter: (const char*) name val: (CPInt) val;
-(void) setFloatParameter: (const char*) name val: (double) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

@end

