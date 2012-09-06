/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <objc/objc-auto.h>
#import <Foundation/NSObject.h>
#import <ORUtilities/ORUtilities.h>

typedef enum { LPinfeasible, LPoptimal, LPsuboptimal, LPunbounded, LPerror} LPOutcome;
typedef enum { LPgeq, LPleq, LPeq } LPConstraintType;
typedef enum { LPminimize, LPmaximize } LPObjectiveType;

@protocol LPConstraint;
@protocol LPVariable;

typedef double (^LPInt2Double)(ORInt);
typedef id<LPVariable> (^LPInt2Var)(ORInt);

typedef struct IRange {
    int low;
    int up;
} IRange;

@protocol LPVariable <NSObject>
-(ORInt)    idx;
-(double) low;
-(double) up;
-(bool) hasBounds;
-(double) value;
-(double) reducedCost;
@end

@protocol LPConstraint <NSObject>
-(LPConstraintType)    type;
-(ORInt)                 size;
-(id<LPVariable>*)     var;
-(ORInt*)                col;
-(double*)             coef;
-(double)              rhs;
-(ORInt)                 idx;
-(double)              dual;
@end

@protocol LPObjective  <NSObject>
-(LPObjectiveType)     type;
-(ORInt)                 size;
-(ORInt*)                col;
-(double*)             coef;
-(double)              value;
@end


@protocol LPColumn <NSObject>
-(ORInt)    idx;
-(double) low;
-(double) up;
-(double) objCoef;
-(ORInt) size;
-(ORInt*) cstrIdx;
-(double*) coef;
@end

@protocol LPLinearTerm <NSObject>
-(ORInt) size;
-(double) cst;
-(void) add: (double) cst;
-(void) add: (double) coef times: (id<LPVariable>) var;
@end

@protocol LPSolver <NSObject> 
-(id<LPVariable>)   createVariable;
-(id<LPVariable>)   createVariable: (double) low up: (double) up;
-(id<LPColumn>)     createColumn: (double) low up: (double) up size: (ORInt) size obj: (double) obj cstr: (id<LPConstraint>*) idx coef: (double*) coef;
-(id<LPColumn>)     createColumn: (double) low up: (double) up;

-(id<LPLinearTerm>) createLinearTerm;
-(id<LPLinearTerm>) createLinearTerm:(IRange) R coef: (LPInt2Double) c var: (LPInt2Var) v;

-(id<LPConstraint>) createLEQ: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPConstraint>) createGEQ: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPConstraint>) createEQ: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef rhs: (double) rhs;
-(id<LPObjective>)  createMinimize: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef;
-(id<LPObjective>)  createMaximize: (ORInt) size var: (id<LPVariable>*) var coef: (double*) coef;

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

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (double) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

@end

