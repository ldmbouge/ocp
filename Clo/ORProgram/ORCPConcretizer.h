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
// PVH: This must go: the interface should be in modeling and/or foundations
#import <objcp/CPSolver.h>


@interface ORCPConcretizer  : NSObject<ORVisitor>
-(ORCPConcretizer*) initORCPConcretizer: (id<CPSolver>) solver;
-(void) dealloc;

-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;

-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
-(void) visitAffineVar:(id<ORIntVar>) v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitPacking: (id<ORPacking>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitMinimize: (id<ORObjectiveFunction>) v;
-(void) visitMaximize: (id<ORObjectiveFunction>) v;
-(void) visitEqualc: (id<OREqualc>)c;
-(void) visitNEqualc: (id<ORNEqualc>)c;
-(void) visitLEqualc: (id<ORLEqualc>)c;
-(void) visitEqual: (id<OREqual>)c;
-(void) visitNEqual: (id<ORNEqual>)c;
-(void) visitLEqual: (id<ORLEqual>)c;
-(void) visitEqual3: (id<OREqual3>)c;
-(void) visitMult: (id<ORMult>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
//
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
-(void) visitExprVarSubI: (id<ORExpr>) e;
@end

//@interface CPConcretizerI : NSObject<ORSolverConcretizer>
//-(CPConcretizerI*) initCPConcretizerI: (id<CPSolver>) solver;
//-(id<ORIntVar>) intVar: (id<ORIntVar>) v;
//-(id<ORIntVar>) affineVar:(id<ORIntVar>) v;
//-(id<ORIdArray>) idArray: (id<ORIdArray>) a;
//-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr;
//-(id<ORConstraint>) cardinality: (id<ORCardinality>) cstr;
//-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
//-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr;
//-(id<ORIntVar>) minimize: (id<ORIntVar>) v;
//@end
//
//@interface CPParConcretizerI : NSObject<ORSolverConcretizer>
//-(CPConcretizerI*) initCPParConcretizerI: (id<CPSolver>) solver;
//-(id<ORIntVar>) intVar: (id<ORIntVar>) v;
//-(id<ORFloatVar>) floatVar: (id<ORFloatVar>) v;
//-(id<ORIntVar>) affineVar:(id<ORIntVar>) v;
//-(id<ORIdArray>) idArray: (id<ORIdArray>) a;
//-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr;
//-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
//-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr;
//@end
//
//
//@interface ORExprConcretizer : NSObject<ORVisitor>
//-(ORExprConcretizer*) initORExprConcretizer: (CPConcretizerI*) concretizer;
//-(id<ORExpr>) result;
//-(void) visitIntegerI: (id<ORInteger>) e;
//-(void) visitExprPlusI: (id<ORExpr>) e;
//-(void) visitExprMinusI: (id<ORExpr>) e;
//-(void) visitExprMulI: (id<ORExpr>) e;
//-(void) visitExprEqualI: (id<ORExpr>) e;
//-(void) visitExprNEqualI: (id<ORExpr>) e;
//-(void) visitExprLEqualI: (id<ORExpr>) e;
//-(void) visitExprSumI: (id<ORExpr>) e;
//-(void) visitExprAbsI:(id<ORExpr>) e;
//-(void) visitExprCstSubI: (id<ORExpr>) e;
//-(void) visitExprDisjunctI:(id<ORExpr>) e;
//-(void) visitExprConjunctI: (id<ORExpr>) e;
//-(void) visitExprImplyI: (id<ORExpr>) e;
//-(void) visitExprAggOrI: (id<ORExpr>) e;
//-(void) visitIntVar: (id<ORIntVar>) var;
//-(void) visitExprVarSubI: (id<ORExpr>) e;
//@end
