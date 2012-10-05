//
//  CPConcretizer.h
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORSolver.h>
@protocol CPSolver;

@interface CPConcretizerI : NSObject<ORSolverConcretizer>
-(CPConcretizerI*) initCPConcretizerI: (id<CPSolver>) solver;
-(id<ORIntVar>) intVar: (id<ORIntVar>) v;
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v;
-(id<ORIdArray>) idArray: (id<ORIdArray>) a;
-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr;
-(id<ORConstraint>) cardinality: (id<ORCardinality>) cstr;
-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr;
-(id<ORIntVar>) minimize: (id<ORIntVar>) v;
@end

@interface CPParConcretizerI : NSObject<ORSolverConcretizer>
-(CPConcretizerI*) initCPParConcretizerI: (id<CPSolver>) solver;
-(id<ORIntVar>) intVar: (id<ORIntVar>) v;
-(id<ORFloatVar>) floatVar: (id<ORFloatVar>) v;
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v;
-(id<ORIdArray>) idArray: (id<ORIdArray>) a;
-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr;
-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr;
@end


@interface ORExprConcretizer : NSObject<ORExprVisitor>
-(ORExprConcretizer*) initORExprConcretizer: (CPConcretizerI*) concretizer;
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
