/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objmp/LPType.h>

@class LPGurobiSolver;

@interface LPVariableI : NSObject 
{
@protected
   LPSolverI*            _solver;
   int                   _nb;
   int                   _idx;
   ORFloat               _low;
   ORFloat               _up;
   LPObjectiveI*         _obj;
   ORFloat               _objCoef;
   int                   _size;
   int                   _maxSize;
   LPConstraintI**       _cstr;
   int*                  _cstrIdx;
   ORFloat*              _coef;
   bool                  _hasBounds;
}
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver;
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver low: (ORFloat) low up: (ORFloat) up;
-(bool) hasBounds;
-(ORFloat) low;
-(ORFloat) up;
-(ORInt) idx;
-(void) setIdx: (ORInt) idx;

-(void) addConstraint: (LPConstraintI*) c coef: (ORFloat) coef;
-(void) delConstraint: (LPConstraintI*) c;
-(void) addObjective: (LPObjectiveI*) obj coef: (ORFloat) coef;
-(void) print;
-(void) del;
-(LPColumnI*) column;
-(ORInt) value;
-(ORFloat) floatValue;
-(ORFloat) reducedCost;
-(void) setNb: (ORInt) nb;
-(ORInt) nb;
-(NSString*)description;
-(BOOL) isInteger;
@end

@interface LPIntVariableI : LPVariableI
-(LPIntVariableI*) initLPIntVariableI: (LPSolverI*) solver;
-(LPIntVariableI*) initLPIntVariableI: (LPSolverI*) solver low: (ORFloat) low up: (ORFloat) up;
-(BOOL) isInteger;
@end


@protocol LPVariableArray <ORVarArray>
-(LPVariableI*) at: (ORInt) value;
-(void) set: (LPVariableI*) x at: (ORInt) value;
-(LPVariableI*) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (LPVariableI*) newValue atIndexedSubscript: (NSUInteger) idx;
@end


@interface LPConstraintI : NSObject 
{
@protected
   LPSolverI*          _solver;
   int                 _nb;
   int                 _idx;
   LPConstraintType    _type;
   int                 _maxSize;
   int                 _size;
   LPVariableI**       _var;
   int*                _col;
   ORFloat*            _coef;
   ORFloat             _rhs;
   
   LPVariableI**       _tmpVar;
   ORFloat*            _tmpCoef;
}

-(LPConstraintI*)      initLPConstraintI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(void)                dealloc;
-(LPConstraintType)    type;
-(ORInt)               size;
-(LPVariableI**)       var;
-(LPVariableI*)        var: (ORInt) i;
-(ORInt*)              col;
-(ORInt)               col: (ORInt) i;
-(ORFloat*)            coef;
-(ORFloat)             coef: (ORInt) i;
-(ORFloat)             rhs;
-(ORInt)               idx;
-(void)                setIdx: (ORInt) idx;
-(void)                del;
-(void)                delVariable: (LPVariableI*) var;
-(void)                addVariable: (LPVariableI*) var coef: (ORFloat) coef;
-(ORFloat)             dual;
-(void)                setNb: (ORInt) nb;
-(ORInt)               nb;
@end

@interface LPConstraintLEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintLEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
@end

@interface LPConstraintGEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintGEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
@end

@interface LPConstraintEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
@end

@interface LPObjectiveI : NSObject 
{
@protected
   LPSolverI*          _solver;
   int                 _nb;
   LPObjectiveType     _type;
   int                 _size;
   int                _maxSize;
   LPVariableI**        _var;
   int*                _col;
   ORFloat*             _coef;
   ORFloat              _cst;
   bool                _posted;
   LPVariableI**       _tmpVar;
   ORFloat*             _tmpCoef;
}
-(LPObjectiveI*) initLPObjectiveI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst;
-(void) dealloc;
-(LPObjectiveType) type;
-(ORInt) size;
-(LPVariableI**) var;
-(ORInt*) col;
-(ORFloat*) coef;
-(void) print;
-(void) delVariable: (LPVariableI*) var;
-(void) addVariable: (LPVariableI*) var coef: (ORFloat) coef;
-(void) addCst: (ORFloat) cst;
-(id<ORObjectiveValue>) value;
-(void) setPosted;
-(void) setNb: (ORInt) nb;
-(ORInt) nb;
@end

@interface LPMinimize : LPObjectiveI
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef;
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst;
-(void) print;
@end

@interface LPMaximize : LPObjectiveI
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef;
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst;
-(void) print;
@end

@interface LPColumnI : NSObject 
{
@protected
   LPSolverI*            _solver;
   int                   _nb;
   int                   _maxSize;
   int                   _idx;
   ORFloat               _low;
   ORFloat               _up;
   ORFloat               _objCoef;
   int                   _size;
   LPConstraintI**       _cstr;
   int*                  _cstrIdx;
   ORFloat*              _coef;
   LPConstraintI**       _tmpCstr;
   ORFloat*              _tmpCoef;
   
}
-(LPColumnI*) initLPColumnI: (LPSolverI*) solver low: (ORFloat) low up: (ORFloat) up;
-(LPColumnI*) initLPColumnI: (LPSolverI*) solver low: (ORFloat) low up: (ORFloat) up size: (ORInt) size obj: (ORFloat) obj cstr: (LPConstraintI**) idx coef: (ORFloat*) coef;
-(void)      dealloc;

-(ORInt) idx;
-(void) setIdx: (ORInt) idx;
-(ORFloat) low;
-(ORFloat) up;
-(ORFloat) objCoef;
-(ORInt) size;
-(ORInt*) cstrIdx;
-(ORFloat*) coef;
-(void) fill: (LPVariableI*) v obj: (LPObjectiveI*) obj;
-(void) addObjCoef: (ORFloat) coef;
-(void) addConstraint: (LPConstraintI*) cstr coef: (ORFloat) coef;
-(void) setNb: (ORInt) nb;
-(ORInt)  nb;
@end

@interface LPLinearTermI : NSObject
{
@protected
   LPSolverI*           _solver;
   int                 _size;
   int                 _maxSize;
   LPVariableI**        _var;
   ORFloat*             _coef;
   ORFloat              _cst;
}
-(LPLinearTermI*) initLPLinearTermI: (LPSolverI*) solver;
-(void) dealloc;
-(ORInt) size;
-(LPVariableI**) var;
-(ORFloat*) coef;
-(ORFloat) cst;
-(void) add: (ORFloat) cst;
-(void) add: (ORFloat) coef times: (LPVariableI*) var;
-(void) close;
@end

@interface LPSolverI : NSObject<ORTracker> {
   LPGurobiSolver*      _lp;
   int                  _nbVars;
   int                  _maxVars;
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
   
   NSMutableArray*     _oStore;
   
}

-(LPSolverI*) initLPSolverI;
-(void) dealloc;

+(LPSolverI*)      create;
-(LPVariableI*)    createVariable;
-(LPIntVariableI*) createVariable: (ORFloat) low up: (ORFloat) up;
-(LPIntVariableI*) createIntVariable;
-(LPVariableI*)    createIntVariable: (ORFloat) low up: (ORFloat) up;
-(LPColumnI*)      createColumn: (ORFloat) low up: (ORFloat) up size: (ORInt) size obj: (ORFloat) obj cstr: (LPConstraintI**) idx coef: (ORFloat*) coef;
-(LPColumnI*)      createColumn: (ORFloat) low up: (ORFloat) up;

-(LPLinearTermI*)  createLinearTerm;

-(LPConstraintI*) createLEQ: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(LPConstraintI*) createGEQ: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(LPConstraintI*) createEQ: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(LPObjectiveI*)  createMinimize: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef;
-(LPObjectiveI*)  createMaximize: (ORInt) size var: (LPVariableI**) var coef: (ORFloat*) coef;

-(LPConstraintI*) createLEQ: (id<LPVariableArray>) var coef: (id<ORIntArray>) coef cst: (ORInt) cst;
-(LPConstraintI*) createEQ: (id<LPVariableArray>) var coef: (id<ORIntArray>) coef cst: (ORInt) cst;


-(LPObjectiveI*)  createObjectiveMinimize: (LPVariableI*) x;
-(LPObjectiveI*)  createObjectiveMaximize: (LPVariableI*) x;
-(LPObjectiveI*)  createObjectiveMinimize: (id<LPVariableArray>) var coef: (id<ORIntArray>) coef;
-(LPObjectiveI*)  createObjectiveMaximize: (id<LPVariableArray>) var coef: (id<ORIntArray>) coef;

-(LPConstraintI*) createLEQ: (LPLinearTermI*) t rhs: (ORFloat) rhs;
-(LPConstraintI*) createGEQ: (LPLinearTermI*) t rhs: (ORFloat) rhs;
-(LPConstraintI*) createEQ:  (LPLinearTermI*) t  rhs: (ORFloat) rhs;
-(LPObjectiveI*)  createMinimize: (LPLinearTermI*) t;
-(LPObjectiveI*)  createMaximize: (LPLinearTermI*) t;


-(LPConstraintI*) postConstraint: (LPConstraintI*) cstr;
-(void) removeConstraint: (LPConstraintI*) cstr;
-(void) removeVariable: (LPVariableI*) var;
-(LPObjectiveI*) postObjective: (LPObjectiveI*) obj;
-(LPVariableI*) postColumn: (LPColumnI*) col;

-(void) close;
-(bool) isClosed;
-(LPOutcome) solve;

-(LPOutcome) status;
-(ORInt) value: (LPIntVariableI*) var;
-(ORFloat) floatValue: (LPVariableI*) var;
-(ORFloat) lowerBound: (LPVariableI*) var;
-(ORFloat) upperBound: (LPVariableI*) var;
-(ORFloat) reducedCost: (LPVariableI*) var;
-(ORFloat) dual: (LPConstraintI*) cstr;
-(id<ORFloatArray>) duals;
-(id<ORObjectiveValue>) objectiveValue;
-(ORFloat) lpValue;

-(void) updateLowerBound: (LPVariableI*) var lb: (ORFloat) lb;
-(void) updateUpperBound: (LPVariableI*) var ub: (ORFloat) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (ORFloat) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

-(void) trackVariable: (id) var;
-(void) trackObject: (id) obj;
-(void) trackConstraint: (id) obj;

@end

@interface LPFactory : NSObject
+(LPSolverI*) solver;
@end;
