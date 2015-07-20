/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objmp/MIPType.h>

@class MIPGurobiSolver;

@interface MIPVariableI : NSObject
{
@protected
   MIPSolverI*            _solver;
   int                   _nb;
   int                   _idx;
   ORFloat               _low;
   ORFloat               _up;
   MIPObjectiveI*         _obj;
   ORFloat               _objCoef;
   int                   _size;
   int                   _maxSize;
   MIPConstraintI**       _cstr;
   int*                  _cstrIdx;
   ORFloat*              _coef;
   bool                  _hasBounds;
}
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver;
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver low: (ORFloat) low up: (ORFloat) up;
-(ORBool) hasBounds;
-(ORFloat) low;
-(ORFloat) up;
-(ORInt) idx;
-(void) setIdx: (ORInt) idx;

-(void) addConstraint: (MIPConstraintI*) c coef: (ORFloat) coef;
-(void) delConstraint: (MIPConstraintI*) c;
-(void) addObjective: (MIPObjectiveI*) obj coef: (ORFloat) coef;
-(void) print;
-(void) del;
-(ORFloat) floatValue;
-(void) setNb: (ORInt) nb;
-(ORInt) nb;
-(NSString*)description;
-(ORBool) isInteger;
@end

@interface MIPIntVariableI : MIPVariableI
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver;
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver low: (ORFloat) low up: (ORFloat) up;
-(ORBool) isInteger;
-(ORInt) intValue;
@end


@protocol MIPVariableArray <ORVarArray>
-(MIPVariableI*) at: (ORInt) value;
-(void) set: (MIPVariableI*) x at: (ORInt) value;
-(MIPVariableI*) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (MIPVariableI*) newValue atIndexedSubscript: (NSUInteger) idx;
@end


@interface MIPConstraintI : NSObject
{
@protected
   MIPSolverI*          _solver;
   int                 _nb;
   int                 _idx;
   MIPConstraintType    _type;
   int                 _maxSize;
   int                 _size;
   MIPVariableI**       _var;
   int*                _col;
   ORFloat*            _coef;
   ORFloat             _rhs;
   
   MIPVariableI**       _tmpVar;
   ORFloat*            _tmpCoef;
}

-(MIPConstraintI*)      initMIPConstraintI: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(void)                dealloc;
-(MIPConstraintType)    type;
-(ORInt)               size;
-(MIPVariableI**)       var;
-(MIPVariableI*)        var: (ORInt) i;
-(ORInt*)              col;
-(ORInt)               col: (ORInt) i;
-(ORFloat*)            coef;
-(ORFloat)             coef: (ORInt) i;
-(ORFloat)             rhs;
-(ORInt)               idx;
-(void)                setIdx: (ORInt) idx;
-(void)                del;
-(void)                delVariable: (MIPVariableI*) var;
-(void)                addVariable: (MIPVariableI*) var coef: (ORFloat) coef;
-(void)                setNb: (ORInt) nb;
-(ORInt)               nb;
@end

@interface MIPConstraintLEQ : MIPConstraintI
-(MIPConstraintI*) initMIPConstraintLEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
@end

@interface MIPConstraintGEQ : MIPConstraintI
-(MIPConstraintI*) initMIPConstraintGEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
@end

@interface MIPConstraintEQ : MIPConstraintI
-(MIPConstraintI*) initMIPConstraintEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
@end

@interface MIPObjectiveI : NSObject
{
@protected
   MIPSolverI*          _solver;
   int                 _nb;
   MIPObjectiveType     _type;
   int                 _size;
   int                _maxSize;
   MIPVariableI**        _var;
   int*                _col;
   ORFloat*             _coef;
   ORFloat              _cst;
   bool                _posted;
   MIPVariableI**       _tmpVar;
   ORFloat*             _tmpCoef;
}
-(MIPObjectiveI*) initMIPObjectiveI: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst;
-(void) dealloc;
-(MIPObjectiveType) type;
-(ORInt) size;
-(MIPVariableI**) var;
-(ORInt*) col;
-(ORFloat*) coef;
-(void) print;
-(void) delVariable: (MIPVariableI*) var;
-(void) addVariable: (MIPVariableI*) var coef: (ORFloat) coef;
-(void) addCst: (ORFloat) cst;
-(id<ORObjectiveValue>) value;
-(void) setPosted;
-(void) setNb: (ORInt) nb;
-(ORInt) nb;
@end

@interface MIPMinimize : MIPObjectiveI
-(MIPObjectiveI*) initMIPMinimize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef;
-(MIPObjectiveI*) initMIPMinimize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst;
-(void) print;
@end

@interface MIPMaximize : MIPObjectiveI
-(MIPObjectiveI*) initMIPMaximize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef;
-(MIPObjectiveI*) initMIPMaximize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef cst: (ORFloat) cst;
-(void) print;
@end

@interface MIPLinearTermI : NSObject
{
@protected
   MIPSolverI*           _solver;
   int                 _size;
   int                 _maxSize;
   MIPVariableI**        _var;
   ORFloat*             _coef;
   ORFloat              _cst;
}
-(MIPLinearTermI*) initMIPLinearTermI: (MIPSolverI*) solver;
-(void) dealloc;
-(ORInt) size;
-(MIPVariableI**) var;
-(ORFloat*) coef;
-(ORFloat) cst;
-(void) add: (ORFloat) cst;
-(void) add: (ORFloat) coef times: (MIPVariableI*) var;
-(void) close;
@end

@interface MIPSolverI : NSObject<OREngine> {
   MIPGurobiSolver*      _MIP;
   int                  _nbVars;
   int                  _maxVars;
   MIPVariableI**        _var;
   
   int                 _nbCstrs;
   int                 _maxCstrs;
   MIPConstraintI**      _cstr;
   
   MIPObjectiveI*        _obj;
   
   int                 _createdVars;
   int                 _createdCstrs;
   int                 _createdObjs;
   int                 _createdCols;
   bool                _isClosed;
   
   NSMutableArray*     _oStore;
   
}

-(MIPSolverI*) initMIPSolverI;
-(void) dealloc;

+(MIPSolverI*)      create;
-(MIPVariableI*)    createVariable;
-(MIPVariableI*)    createVariable: (ORFloat) low up: (ORFloat) up;
-(MIPIntVariableI*) createIntVariable;
-(MIPIntVariableI*) createIntVariable: (ORFloat) low up: (ORFloat) up;
-(MIPLinearTermI*)  createLinearTerm;

-(MIPConstraintI*) createLEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(MIPConstraintI*) createGEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(MIPConstraintI*) createEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef rhs: (ORFloat) rhs;
-(MIPObjectiveI*)  createMinimize: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef;
-(MIPObjectiveI*)  createMaximize: (ORInt) size var: (MIPVariableI**) var coef: (ORFloat*) coef;

-(MIPConstraintI*) createLEQ: (id<MIPVariableArray>) var coef: (id<ORFloatArray>) coef cst: (ORFloat) cst;
-(MIPConstraintI*) createEQ: (id<MIPVariableArray>) var coef: (id<ORFloatArray>) coef cst: (ORFloat) cst;


-(MIPObjectiveI*)  createObjectiveMinimize: (MIPVariableI*) x;
-(MIPObjectiveI*)  createObjectiveMaximize: (MIPVariableI*) x;
-(MIPObjectiveI*)  createObjectiveMinimize: (id<MIPVariableArray>) var coef: (id<ORFloatArray>) coef;
-(MIPObjectiveI*)  createObjectiveMaximize: (id<MIPVariableArray>) var coef: (id<ORFloatArray>) coef;

-(MIPConstraintI*) createLEQ: (MIPLinearTermI*) t rhs: (ORFloat) rhs;
-(MIPConstraintI*) createGEQ: (MIPLinearTermI*) t rhs: (ORFloat) rhs;
-(MIPConstraintI*) createEQ:  (MIPLinearTermI*) t  rhs: (ORFloat) rhs;
-(MIPObjectiveI*)  createMinimize: (MIPLinearTermI*) t;
-(MIPObjectiveI*)  createMaximize: (MIPLinearTermI*) t;


-(MIPConstraintI*) postConstraint: (MIPConstraintI*) cstr;
-(void) removeConstraint: (MIPConstraintI*) cstr;
-(void) removeVariable: (MIPVariableI*) var;
-(MIPObjectiveI*) postObjective: (MIPObjectiveI*) obj;

-(void) close;
-(ORBool) isClosed;
-(MIPOutcome) solve;

-(MIPOutcome) status;
-(ORInt)   intValue: (MIPIntVariableI*) var;
-(ORFloat) floatValue: (MIPVariableI*) var;
-(ORFloat) lowerBound: (MIPVariableI*) var;
-(ORFloat) upperBound: (MIPVariableI*) var;
-(id<ORObjectiveValue>) objectiveValue;
-(ORFloat) mipvalue;

-(void) updateLowerBound: (MIPVariableI*) var lb: (ORFloat) lb;
-(void) updateUpperBound: (MIPVariableI*) var ub: (ORFloat) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (ORFloat) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotMIPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotMIPAbstractBasis* basis) ;

-(id) trackVariable: (id) var;
-(id) trackMutable: (id) obj;
-(id) trackObjective:(id)obj;
-(id) trackConstraintInGroup:(id)obj;
@end

@interface MIPFactory : NSObject
+(MIPSolverI*) solver;
@end;
