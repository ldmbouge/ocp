/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

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


@interface ORExprConcretizer : NSObject<ORVisitor>
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
-(void) visitIntVar: (id<ORIntVar>) var;
-(void) visitExprVarSubI: (id<ORExpr>) e;
@end
