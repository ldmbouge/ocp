/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objmp/LPType.h>

@class LPGurobiSolver;

@interface LPVariableI : ORObject
{
@public
   int                   _idx;
@protected
   LPSolverI*            _solver;
   int                   _nb;
   ORDouble               _low;
   ORDouble               _up;
   LPObjectiveI*         _obj;
   ORDouble               _objCoef;
   int                   _size;
   int                   _maxSize;
   LPConstraintI**       _cstr;
   int*                  _cstrIdx;
   ORDouble*              _coef;
   bool                  _hasBounds;
}
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver;
-(LPVariableI*) initLPVariableI: (LPSolverI*) solver low: (ORDouble) low up: (ORDouble) up;
-(ORBool) hasBounds;
-(ORDouble) low;
-(ORDouble) up;
-(ORDouble) objCoef;
-(ORInt) idx;
-(void) setIdx: (ORInt) idx;

-(void) addConstraint: (LPConstraintI*) c coef: (ORDouble) coef;
-(void) delConstraint: (LPConstraintI*) c;
-(void) addObjective: (LPObjectiveI*) obj coef: (ORDouble) coef;
-(void) print;
-(void) del;
-(LPColumnI*) column;
-(ORDouble) doubleValue;
-(ORDouble) reducedCost;
-(void) setNb: (ORInt) nb;
-(ORInt) nb;
-(NSString*)description;
-(ORBool) isInteger;
-(ORInt)downLock;
-(ORInt)upLock;
-(ORInt)locks;
-(ORBool)trivialDownRoundable;
-(ORBool)trivialUpRoundable;
-(ORBool)triviallyRoundable;
-(ORBool)fixMe;
-(ORDouble)fractionality;
-(ORDouble)nearestInt;
@end

static inline int getLPId(LPVariableI* p)  { return p->_idx;}

@protocol LPVariableArray <ORVarArray>
-(LPVariableI*) at: (ORInt) value;
-(void) set: (LPVariableI*) x at: (ORInt) value;
-(LPVariableI*) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (LPVariableI*) newValue atIndexedSubscript: (NSUInteger) idx;
@end

@interface LPParameterI : NSObject
{
@protected
    LPSolverI*           _solver;
    ORInt                 _cstrIdx;
    ORInt                 _coefIdx;
}
-(LPParameterI*) initLPParameterI: (LPSolverI*) solver;
-(ORInt) cstrIdx;
-(void) setCstrIdx: (ORInt) idx;
-(ORInt) coefIdx;
-(void) setCoefIdx: (ORInt) idx;
-(ORDouble) doubleValue;
-(void) setDoubleValue: (ORDouble)val;

-(NSString*)description;
-(ORBool) isInteger;
@end


@interface LPConstraintI : ORObject
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
   ORDouble*            _coef;
   ORDouble             _rhs;
   
   LPVariableI**       _tmpVar;
   ORDouble*            _tmpCoef;
}

-(LPConstraintI*)      initLPConstraintI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
-(void)                dealloc;
-(LPConstraintType)    type;
-(ORInt)               size;
-(LPVariableI**)       var;
-(LPVariableI*)        var: (ORInt) i;
-(ORInt*)              col;
-(ORInt)               col: (ORInt) i;
-(ORDouble*)            coef;
-(ORDouble)             coef: (ORInt) i;
-(ORDouble)             rhs;
-(ORInt)               idx;
-(void)                setIdx: (ORInt) idx;
-(void)                del;
-(void)                delVariable: (LPVariableI*) var;
-(void)                addVariable: (LPVariableI*) var coef: (ORDouble) coef;
-(ORDouble)             dual;
-(void)                setNb: (ORInt) nb;
-(ORInt)               nb;
-(ORInterval) evaluation;
-(ORBool)redundant;
@end

@interface LPConstraintLEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintLEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
@end

@interface LPConstraintGEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintGEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
@end

@interface LPConstraintEQ : LPConstraintI
-(LPConstraintI*) initLPConstraintEQ: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
@end

@interface LPObjectiveI : ORObject
{
@protected
   LPSolverI*          _solver;
   int                 _nb;
   LPObjectiveType     _type;
   int                 _size;
   int                _maxSize;
   LPVariableI**        _var;
   int*                _col;
   ORDouble*             _coef;
   ORDouble              _cst;
   bool                _posted;
   LPVariableI**       _tmpVar;
   ORDouble*             _tmpCoef;
}
-(LPObjectiveI*) initLPObjectiveI: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst;
-(void) dealloc;
-(LPObjectiveType) type;
-(ORInt) size;
-(LPVariableI**) var;
-(ORInt*) col;
-(ORDouble*) coef;
-(void) print;
-(void) delVariable: (LPVariableI*) var;
-(void) addVariable: (LPVariableI*) var coef: (ORDouble) coef;
-(void) addCst: (ORDouble) cst;
-(id<ORObjectiveValue>) value;
-(void) setPosted;
-(void) setNb: (ORInt) nb;
-(ORInt) nb;
@end

@interface LPMinimize : LPObjectiveI
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef;
-(LPObjectiveI*) initLPMinimize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst;
-(void) print;
@end

@interface LPMaximize : LPObjectiveI
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef;
-(LPObjectiveI*) initLPMaximize: (LPSolverI*) solver size: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst;
-(void) print;
@end

@interface LPColumnI : NSObject 
{
@protected
   LPSolverI*            _solver;
   LPVariableI*          _theVar;
   int                   _nb;
   int                   _maxSize;
   int                   _idx;
   BOOL                  _hasBounds;
   ORDouble               _low;
   ORDouble               _up;
   ORDouble               _objCoef;
   int                   _size;
   LPConstraintI**       _cstr;
   int*                  _cstrIdx;
   ORDouble*              _coef;
   LPConstraintI**       _tmpCstr;
   ORDouble*              _tmpCoef;
   
}
-(LPColumnI*) initLPColumnI: (LPSolverI*) solver;
-(LPColumnI*) initLPColumnI: (LPSolverI*) solver low: (ORDouble) low up: (ORDouble) up;
-(LPColumnI*) initLPColumnI: (LPSolverI*) solver low: (ORDouble) low up: (ORDouble) up size: (ORInt) size obj: (ORDouble) obj cstr: (LPConstraintI**) idx coef: (ORDouble*) coef;
-(void)      dealloc;
-(ORInt) idx;
-(void) setIdx: (ORInt) idx;
-(LPVariableI*)theVar;
-(ORBool) hasBounds;
-(ORDouble) low;
-(ORDouble) up;
-(ORDouble) objCoef;
-(ORInt) size;
-(ORInt*) cstrIdx;
-(ORDouble*) coef;
-(void) fill: (LPVariableI*) v obj: (LPObjectiveI*) obj;
-(void) addObjCoef: (ORDouble) coef;
-(void) addConstraint: (LPConstraintI*) cstr coef: (ORDouble) coef;
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
   ORDouble*             _coef;
   ORDouble              _cst;
}
-(LPLinearTermI*) initLPLinearTermI: (LPSolverI*) solver;
-(void) dealloc;
-(ORInt) size;
-(LPVariableI**) var;
-(ORDouble*) coef;
-(ORDouble) cst;
-(void) add: (ORDouble) cst;
-(void) add: (ORDouble) coef times: (LPVariableI*) var;
-(void) close;
@end


@interface LPSolverI : NSObject<OREngine> {
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
   NSMutableArray*     _pStore;
   id<LPBasis>         _basis;  // captured after each call to solve/optimize
}

-(LPSolverI*) initLPSolverI;
-(void) dealloc;
-(void)enumerateColumnWith:(void(^)(LPColumnI*))block;
-(void)restoreBasis:(id<LPBasis>)basis;

+(LPSolverI*)      create;
-(LPVariableI*)    createVariable;
-(LPVariableI*)    createVariable: (ORDouble) low up: (ORDouble) up;
-(LPColumnI*)      createColumn: (ORDouble) low up: (ORDouble) up size: (ORInt) size obj: (ORDouble) obj cstr: (LPConstraintI**) idx coef: (ORDouble*) coef;
-(LPColumnI*)      createColumn: (ORDouble) low up: (ORDouble) up;
-(LPColumnI*)      createColumn;

-(LPLinearTermI*)  createLinearTerm;

-(LPConstraintI*) createLEQ: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
-(LPConstraintI*) createGEQ: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
-(LPConstraintI*) createEQ: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
-(LPObjectiveI*)  createMinimize: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef;
-(LPObjectiveI*)  createMaximize: (ORInt) size var: (LPVariableI**) var coef: (ORDouble*) coef;

-(LPConstraintI*) createLEQ: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst;
-(LPConstraintI*) createGEQ: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst;
-(LPConstraintI*) createEQ: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst;


-(LPObjectiveI*)  createObjectiveMinimize: (LPVariableI*) x;
-(LPObjectiveI*)  createObjectiveMaximize: (LPVariableI*) x;
-(LPObjectiveI*)  createObjectiveMinimize: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef;
-(LPObjectiveI*)  createObjectiveMaximize: (id<LPVariableArray>) var coef: (id<ORDoubleArray>) coef;

-(LPConstraintI*) createLEQ: (LPLinearTermI*) t rhs: (ORDouble) rhs;
-(LPConstraintI*) createGEQ: (LPLinearTermI*) t rhs: (ORDouble) rhs;
-(LPConstraintI*) createEQ:  (LPLinearTermI*) t  rhs: (ORDouble) rhs;
-(LPObjectiveI*)  createMinimize: (LPLinearTermI*) t;
-(LPObjectiveI*)  createMaximize: (LPLinearTermI*) t;


-(LPConstraintI*) postConstraint: (LPConstraintI*) cstr;
-(void) removeConstraint: (LPConstraintI*) cstr;
-(void) removeVariable: (LPVariableI*) var;
-(LPObjectiveI*) postObjective: (LPObjectiveI*) obj;
-(LPVariableI*) postColumn: (LPColumnI*) col;
-(id<LPBasis>)basis;
-(void) close;
-(ORBool) isClosed;
-(OROutcome) solve;

-(OROutcome) status;
-(ORDouble) doubleValue: (LPVariableI*) var;
-(ORDouble) lowerBound: (LPVariableI*) var;
-(ORDouble) upperBound: (LPVariableI*) var;
-(ORDouble) reducedCost: (LPVariableI*) var;
-(ORBool) inBasis:(LPVariableI*)var;
-(ORDouble)fractionality:(LPVariableI*)var;
-(ORDouble)nearestInt:(LPVariableI*)var;
-(ORBool)triviallyRoundable:(LPVariableI*)var;
-(ORBool)trivialDownRoundable:(LPVariableI*)var;
-(ORBool)trivialUpRoundable:(LPVariableI*)var;
-(ORInt)nbLocks:(LPVariableI*)var;
-(ORDouble) dual: (LPConstraintI*) cstr;
-(id<ORDoubleArray>) duals;
-(id<ORObjectiveValue>) objectiveValue;
-(ORDouble) lpValue;

-(void) updateBounds:(LPVariableI*)var lower:(ORDouble)low  upper:(ORDouble)up;
-(void) updateLowerBound: (LPVariableI*) var lb: (ORDouble) lb;
-(void) updateUpperBound: (LPVariableI*) var ub: (ORDouble) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setDoubleParameter: (const char*) name val: (ORDouble) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(ORDouble) paramValue: (LPParameterI*) param;
-(void) setParam: (LPParameterI*) param value: (ORDouble)val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

-(id) trackVariable: (id) var;
-(id) trackMutable: (id) obj;
-(id) trackObjective: (id) obj;
-(id) trackConstraintInGroup:(id)obj;
@end

@interface LPFactory : NSObject
+(LPSolverI*) solver;
@end;
