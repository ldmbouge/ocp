/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORUtilities/ORUtilities.h"
#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import "CPFactory.h"
#import "CPSolver.h"
#import "CPTypes.h"
#import "CPConstraintI.h"

@interface CPFactory (Expressions)
+(id<ORExpr>) exprPlus: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right;
+(id<ORExpr>) exprSub: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right;
+(id<ORExpr>) exprMul: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right;
+(id<ORRelation>) exprEq: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right;
+(id<ORRelation>) exprNeq: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right;
+(id<ORRelation>) exprLeq: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right;
+(id<ORRelation>) exprGeq: (id<CPSolver>) cp  left: (id<ORExpr>) left right: (id<ORExpr>) right;
+(id<ORExpr>) exprAnd: (id<CPSolver>) cp  left: (id<ORRelation>) left right: (id<ORRelation>) right;
+(id<ORExpr>) exprOr: (id<CPSolver>) cp  left: (id<ORRelation>) left right: (id<ORRelation>) right;
+(id<ORExpr>) exprImply: (id<CPSolver>) cp  left: (id<ORRelation>) left right: (id<ORRelation>) right;
+(id<ORExpr>) exprAbs: (id<CPSolver>) cp  expr: (id<ORExpr>) op;
+(id<ORExpr>) exprSum: (id<CPSolver>) tracker expr: (id<ORExpr>) op;
+(id<ORRelation>) exprAggOr: (id<CPSolver>) tracker expr: (id<ORExpr>) op;
+(id<ORExpr>) exprElt: (id<CPSolver>) tracker intVarArray: (id<ORIntVarArray>) a index: (id<ORExpr>) index;
+(id<ORExpr>) exprElt: (id<CPSolver>) tracker intArray: (id<ORIntArray>) a index: (id<ORExpr>) index;
@end

@interface CPConcretizerI : NSObject<ORSolverConcretizer>
-(CPConcretizerI*) initCPConcretizerI: (id<CPSolver>) solver;
-(id<ORIntVar>) intVar: (id<ORIntVar>) v;
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v;
-(id<ORIdArray>) idArray: (id<ORIdArray>) a;
-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr;
-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr;
@end

@interface ORExprConcretizer : NSObject<ORExprVisitor>
-(ORExprConcretizer*) initORExprConcretizer: (id<CPSolver>) cp concretizer: (CPConcretizerI*) concretizer;
-(id<ORExpr>) result;
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
