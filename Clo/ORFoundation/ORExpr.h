/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORUtilities/ORTypes.h"
#import "ORFoundation/ORTracker.h"

@protocol ORRelation;
@protocol ORExpr;
@protocol ORSolverConcretizer;
@protocol ORIntArray;
@protocol ORIntVarArray;

id<ORExpr> __attribute__((overloadable)) mult(ORInt l,id<ORExpr> r);
id<ORExpr> __attribute__((overloadable)) mult(id<ORExpr> l,id<ORExpr> r);


@protocol ORConstraint <ORObject>
@end

@protocol ORExpr <ORConstraint,NSObject,NSCoding>
-(id<ORTracker>) tracker;
-(ORInt) min;
-(ORInt) max;
-(BOOL) isConstant;
-(BOOL) isVariable;
-(id<ORExpr>) plus: (id<ORExpr>) e;
-(id<ORExpr>) sub: (id<ORExpr>) e;
-(id<ORExpr>) mul: (id<ORExpr>) e;
-(id<ORExpr>) muli: (ORInt) e;
-(id<ORRelation>) eq: (id<ORExpr>) e;
-(id<ORRelation>) eqi: (ORInt) e;
-(id<ORRelation>) neq: (id<ORExpr>) e;
-(id<ORRelation>) neqi: (ORInt) e;
-(id<ORRelation>) leq: (id<ORExpr>) e;
-(id<ORRelation>) leqi: (ORInt) e;
-(id<ORRelation>) geq: (id<ORExpr>) e;
-(id<ORRelation>) geqi: (ORInt) e;
-(id<ORRelation>) lt: (id<ORExpr>) e;
-(id<ORRelation>) lti: (ORInt) e;
-(id<ORRelation>) gt: (id<ORExpr>) e;
-(id<ORRelation>) gti: (ORInt) e;

-(id<ORRelation>) and: (id<ORExpr>) e;
-(id<ORRelation>) or: (id<ORExpr>) e;
-(id<ORRelation>) imply:(id<ORExpr>)e;
@end

enum ORRelationType {
   ORRBad = 0,
   ORREq  = 1,
   ORRNEq = 2,
   ORRLEq = 3,
   ORRDisj = 4,
   ORRConj = 5,
   ORRImply = 6
};

@protocol ORRelation <ORExpr>
-(enum ORRelationType) type;
-(id<ORRelation>) and: (id<ORRelation>) e;
-(id<ORRelation>) or: (id<ORRelation>) e;
-(id<ORRelation>) imply: (id<ORRelation>) e;
@end

@protocol ORExprVisitor
-(void) visitIntegerI: (id<ORInteger>) e;
-(void) visitExprPlusI: (id<ORExpr>) e;
-(void) visitExprMinusI: (id<ORExpr>) e;
-(void) visitExprMulI: (id<ORExpr>) e;
-(void) visitExprEqualI: (id<ORExpr>) e;
-(void) visitExprNEqualI: (id<ORExpr>) e;
-(void) visitExprLEqualI: (id<ORExpr>) e;
-(void) visitExprSumI: (id<ORExpr>) e;
-(void) visitExprAbsI:(id<ORExpr>) e;
-(void) visitExprCstSubI: (id<ORExpr>) e;
-(void) visitExprDisjunctI:(id<ORExpr>) e;
-(void) visitExprConjunctI: (id<ORExpr>) e;
-(void) visitExprImplyI: (id<ORExpr>) e;
-(void) visitExprAggOrI: (id<ORExpr>) e;
-(void) visitIntVarI: (id<ORExpr>) var;
-(void) visitExprVarSubI: (id<ORExpr>) e;
@end
