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
   ORDouble               _low;
   ORDouble               _up;
   MIPObjectiveI*         _obj;
   ORDouble               _objCoef;
   int                   _size;
   int                   _maxSize;
   MIPConstraintI**       _cstr;
   int*                  _cstrIdx;
   ORDouble*              _coef;
   bool                  _hasBounds;
   NSString*             _name;
}
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver;
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver  name:(NSString*) name;
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver low: (ORDouble) low up: (ORDouble) up;
-(MIPVariableI*) initMIPVariableI: (MIPSolverI*) solver low: (ORDouble) low up: (ORDouble) up name:(NSString*)name;
-(ORBool) hasBounds;
-(ORDouble) low;
-(ORDouble) up;
-(ORInt) idx;
-(void) setIdx: (ORInt) idx;

-(NSString*) getName;
-(void) addConstraint: (MIPConstraintI*) c coef: (ORDouble) coef;
-(void) delConstraint: (MIPConstraintI*) c;
-(void) addObjective: (MIPObjectiveI*) obj coef: (ORDouble) coef;
-(void) print;
-(void) del;
-(ORDouble) doubleValue;
-(void) setNb: (ORInt) nb;
-(ORInt) nb;
-(NSString*)description;
-(ORBool) isInteger;
-(ORBool) isBool;
@end

@interface MIPIntVariableI : MIPVariableI
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver;
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver name:(NSString*) name;
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver low: (ORDouble) low up: (ORDouble) up;
-(MIPIntVariableI*) initMIPIntVariableI: (MIPSolverI*) solver low: (ORDouble) low up: (ORDouble) up name:(NSString*) name;
-(ORBool) isInteger;
-(ORInt) intValue;
-(NSString*) description;
@end


@protocol MIPVariableArray <ORVarArray>
-(MIPVariableI*) at: (ORInt) value;
-(void) set: (MIPVariableI*) x at: (ORInt) value;
-(MIPVariableI*) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (MIPVariableI*) newValue atIndexedSubscript: (NSUInteger) idx;
@end

@interface MIPParameterI : NSObject
{
@protected
    MIPSolverI*           _solver;
    ORInt                 _cstrIdx;
    ORInt                 _coefIdx;
}
-(MIPParameterI*) initMIPParameterI: (MIPSolverI*) solver;
-(ORInt) cstrIdx;
-(void) setCstrIdx: (ORInt) idx;
-(ORInt) coefIdx;
-(void) setCoefIdx: (ORInt) idx;
-(ORDouble) doubleValue;
-(void) setDoubleValue: (ORDouble)val;

-(NSString*)description;
-(ORBool) isInteger;
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
   ORDouble*            _coef;
   ORDouble             _rhs;
   
   bool                 _quad;
   MIPVariableI**       _tmpVar;
   ORDouble*            _tmpCoef;
}

-(MIPConstraintI*)      initMIPConstraintI: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
-(void)                dealloc;
-(MIPConstraintType)    type;
-(ORInt)               size;
-(MIPVariableI**)       var;
-(MIPVariableI*)        var: (ORInt) i;
-(ORInt*)              col;
-(ORInt)               col: (ORInt) i;
-(ORDouble*)            coef;
-(ORDouble)             coef: (ORInt) i;
-(ORDouble)             rhs;
-(ORInt)               idx;
-(ORDouble)            dual;
-(bool)                isQuad;
-(void)                setIdx: (ORInt) idx;
-(void)                del;
-(void)                delVariable: (MIPVariableI*) var;
-(void)                addVariable: (MIPVariableI*) var coef: (ORDouble) coef;
-(void)                setNb: (ORInt) nb;
-(ORInt)               nb;
@end

@interface MIPConstraintLEQ : MIPConstraintI
-(MIPConstraintI*) initMIPConstraintLEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
@end

@interface MIPConstraintGEQ : MIPConstraintI
-(MIPConstraintI*) initMIPConstraintGEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
@end

@interface MIPConstraintEQ : MIPConstraintI
-(MIPConstraintI*) initMIPConstraintEQ: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
@end

@interface MIPConstraintOR : MIPConstraintI
{
   @protected
   MIPVariableI* _res;
}
-(MIPConstraintI*) initMIPConstraintOR: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef:(ORDouble*) coef res: (MIPVariableI*) res ;
-(MIPVariableI*) res;
@end

@interface MIPConstraintMIN : MIPConstraintI
{
@protected
   MIPVariableI* _res;
}
-(MIPConstraintI*) initMIPConstraintMIN: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef:(ORDouble*) coef res: (MIPVariableI*) res ;
-(MIPVariableI*) res;
@end

@interface MIPQuadConstraint : MIPConstraintI
{
@protected
   MIPVariableI***      _qvar;// array of quadratic term ex: x^2 + 2xy : { [x,x], [x,y] }
   ORDouble*            _qcoef;// array of quadratic coefs ex :         { 1,2}
   ORInt                _qsize;
   ORInt*               _qcol;
   ORInt*               _qrow;
}
-(MIPConstraintI*) initMIPQuadConstraint: (MIPSolverI*) solver sizeLin: (ORInt) size varLin: (MIPVariableI**) var coefLin: (ORDouble*) coef sizeQuad: (ORInt) sizeq varQuad: (MIPVariableI**) varq coefQuad: (id<ORDoubleArray>) coefq rhs: (ORDouble) rhs;
-(ORInt) qSize;
-(MIPVariableI***) qVar;
-(ORDouble*) qCoef;
-(ORInt*) qCol;
-(ORInt*) qRow;
@end

@interface MIPQuadConstraintLEQ : MIPQuadConstraint
-(MIPConstraintI*) initMIPQuadConstraintLEQ: (MIPSolverI*) solver sizeLin: (ORInt) size varLin: (MIPVariableI**) var coefLin: (ORDouble*) coef sizeQuad: (ORInt) sizeq varQuad: (MIPVariableI**) varq coefQuad:(id<ORDoubleArray>) coefq rhs: (ORDouble) rhs;
@end

@interface MIPQuadConstraintGEQ : MIPQuadConstraint
-(MIPConstraintI*) initMIPQuadConstraintGEQ: (MIPSolverI*) solver sizeLin: (ORInt) size varLin: (MIPVariableI**) var coefLin: (ORDouble*) coef sizeQuad: (ORInt) sizeq varQuad: (MIPVariableI**) varq coefQuad: (id<ORDoubleArray>) coefq rhs: (ORDouble) rhs;
@end

@interface MIPQuadConstraintEQ : MIPQuadConstraint
-(MIPConstraintI*) initMIPQuadConstraintEQ: (MIPSolverI*) solver sizeLin: (ORInt) size varLin: (MIPVariableI**) var coefLin: (ORDouble*) coef sizeQuad: (ORInt) sizeq varQuad: (MIPVariableI**) varq coefQuad: (id<ORDoubleArray>) coefq rhs: (ORDouble) rhs;
@end

@interface MIPObjectiveI : NSObject
{
@protected
   MIPSolverI*          _solver;
   int                  _nb;
   MIPObjectiveType     _type;
   int                  _size;
   int                  _maxSize;
   MIPVariableI**       _var;
   int*                 _col;
   ORDouble*            _coef;
   ORDouble             _cst;
   
   bool                 _posted;
   MIPVariableI**       _tmpVar;
   ORDouble*            _tmpCoef;
}
-(MIPObjectiveI*) initMIPObjectiveI: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst;
-(void) dealloc;
-(MIPObjectiveType) type;
-(ORInt) size;
-(MIPVariableI**) var;
-(ORInt*) col;
-(ORDouble*) coef;
-(void) print;
-(void) delVariable: (MIPVariableI*) var;
-(void) addVariable: (MIPVariableI*) var coef: (ORDouble) coef;
-(void) addCst: (ORDouble) cst;
-(id<ORObjectiveValue>) value;
-(void) setPosted;
-(void) setNb: (ORInt) nb;
-(ORInt) nb;
@end

@interface MIPMinimize : MIPObjectiveI
-(MIPObjectiveI*) initMIPMinimize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef;
-(MIPObjectiveI*) initMIPMinimize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst;
-(void) print;
@end

@interface MIPMaximize : MIPObjectiveI
-(MIPObjectiveI*) initMIPMaximize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef;
-(MIPObjectiveI*) initMIPMaximize: (MIPSolverI*) solver size: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef cst: (ORDouble) cst;
-(void) print;
@end

@interface MIPLinearTermI : NSObject
{
@protected
   MIPSolverI*           _solver;
   int                 _size;
   int                 _maxSize;
   MIPVariableI**        _var;
   ORDouble*             _coef;
   ORDouble              _cst;
}
-(MIPLinearTermI*) initMIPLinearTermI: (MIPSolverI*) solver;
-(void) dealloc;
-(ORInt) size;
-(MIPVariableI**) var;
-(ORDouble*) coef;
-(ORDouble) cst;
-(void) add: (ORDouble) cst;
-(void) add: (ORDouble) coef times: (MIPVariableI*) var;
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
-(MIPVariableI*) createVariableWithName :(NSString*) name;
-(MIPVariableI*)    createVariable: (ORDouble) low up: (ORDouble) up;
-(MIPVariableI*)     createVariable: (ORDouble) low up: (ORDouble) up name:(NSString*) name;
-(MIPParameterI*) createParameter;
-(MIPIntVariableI*) createIntVariable;
-(MIPIntVariableI*) createIntVariable: (ORDouble) low up: (ORDouble) up;
-(MIPIntVariableI*) createIntVariable: (ORDouble) low up: (ORDouble) up name:(NSString*) name;
-(MIPLinearTermI*)  createLinearTerm;

-(MIPConstraintI*) createLEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
-(MIPConstraintI*) createGEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
-(MIPConstraintI*) createEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef rhs: (ORDouble) rhs;
-(MIPObjectiveI*)  createMinimize: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef;
-(MIPObjectiveI*)  createMaximize: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef;

-(MIPConstraintI*) createQuadEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef sizeQ:(ORInt) sizeq varQ: (MIPVariableI**) varq coefQ: (id<ORDoubleArray>) coefq rhs: (ORDouble) rhs;
-(MIPConstraintI*) createQuadGEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef sizeQ:(ORInt) sizeq varQ: (MIPVariableI**) varq coefQ: (id<ORDoubleArray>) coefq rhs: (ORDouble) rhs;
-(MIPConstraintI*) createQuadLEQ: (ORInt) size var: (MIPVariableI**) var coef: (ORDouble*) coef sizeQ:(ORInt) sizeq varQ: (MIPVariableI**) varq coefQ: (id<ORDoubleArray>) coefq rhs: (ORDouble) rhs;


-(MIPConstraintI*) createLEQ: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst;
-(MIPConstraintI*) createGEQ: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst;
-(MIPConstraintI*) createEQ: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef cst: (ORDouble) cst;
-(MIPConstraintI*) createOR:(id<MIPVariableArray>) vars eq:(MIPVariableI*) x;
-(MIPConstraintI*) createMIN:(id<MIPVariableArray>) vars eq:(MIPVariableI*) x;


-(MIPObjectiveI*)  createObjectiveMinimize: (MIPVariableI*) x;
-(MIPObjectiveI*)  createObjectiveMaximize: (MIPVariableI*) x;
-(MIPObjectiveI*)  createObjectiveMinimize: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef;
-(MIPObjectiveI*)  createObjectiveMaximize: (id<MIPVariableArray>) var coef: (id<ORDoubleArray>) coef;

-(MIPConstraintI*) createLEQ: (MIPLinearTermI*) t rhs: (ORDouble) rhs;
-(MIPConstraintI*) createGEQ: (MIPLinearTermI*) t rhs: (ORDouble) rhs;
-(MIPConstraintI*) createEQ:  (MIPLinearTermI*) t  rhs: (ORDouble) rhs;
-(MIPObjectiveI*)  createMinimize: (MIPLinearTermI*) t;
-(MIPObjectiveI*)  createMaximize: (MIPLinearTermI*) t;


-(MIPConstraintI*) postConstraint: (MIPConstraintI*) cstr;
-(void) removeConstraint: (MIPConstraintI*) cstr;
-(void) removeVariable: (MIPVariableI*) var;
-(MIPObjectiveI*) postObjective: (MIPObjectiveI*) obj;

-(void) close;
-(ORBool) isClosed;
-(MIPOutcome) solve;
-(void) setTimeLimit: (double)limit;
-(ORDouble) bestObjectiveBound;
-(ORFloat) dualityGap;
-(ORDouble) dual: (MIPConstraintI*) cstr;

-(MIPOutcome) status;
-(ORInt)   intValue: (MIPIntVariableI*) var;
-(void) setIntVar: (MIPVariableI*)var value:(ORInt)val;
-(ORDouble) doubleValue: (MIPVariableI*) var;
-(ORDouble) lowerBound: (MIPVariableI*) var;
-(ORDouble) upperBound: (MIPVariableI*) var;
-(id<ORObjectiveValue>) objectiveValue;
-(ORDouble) mipvalue;

-(void) updateLowerBound: (MIPVariableI*) var lb: (ORDouble) lb;
-(void) updateUpperBound: (MIPVariableI*) var ub: (ORDouble) ub;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setDoubleParameter: (const char*) name val: (ORDouble) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(ORDouble) paramValue: (MIPParameterI*) param;
-(void) setParam: (MIPParameterI*) param value: (ORDouble)val;

-(void) tightenBound: (ORDouble)bnd;
-(void) injectSolution: (NSArray*)vars values: (NSArray*)vals size: (ORInt)size;
-(id<ORDoubleInformer>) boundInformer;
-(void) print;
-(void) printModelToFile: (char*) fileName;
-(void) cancel;

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
