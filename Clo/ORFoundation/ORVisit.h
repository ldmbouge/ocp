/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORData.h>
#import <ORFoundation/ORVar.h>

@protocol ORTrailableInt;

@protocol ORVisitor <NSObject>
@optional
-(void) visitRandomStream:(id) v;
-(void) visitZeroOneStream:(id) v;
-(void) visitUniformDistribution:(id) v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitIntArray:(id<ORIntArray>)v;
-(void) visitIntMatrix:(id<ORIntMatrix>)v;
-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntVar: (id<ORIntVar>) v;
-(void) visitBitVar: (id<ORBitVar>) v;
-(void) visitFloatVar: (id<ORFloatVar>) v;
-(void) visitIntVarLitEQView:(id<ORIntVar>)v;
-(void) visitAffineVar:(id<ORIntVar>) v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitTable:(id<ORTable>) v;
// micro-Constraints
-(void) visitConstraint:(id<ORConstraint>)c;
-(void) visitObjectiveFunction:(id<ORObjectiveFunction>)f;
-(void) visitFail:(id<ORFail>)cstr;
-(void) visitRestrict:(id<ORRestrict>)cstr;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitLexLeq:(id<ORLexLeq>) cstr;
-(void) visitCircuit:(id<ORCircuit>) cstr;
-(void) visitNoCycle:(id<ORNoCycle>) cstr;
-(void) visitPackOne:(id<ORPackOne>) cstr;
-(void) visitPacking:(id<ORPacking>) cstr;
-(void) visitKnapsack:(id<ORKnapsack>) cstr;
-(void) visitAssignment:(id<ORAssignment>)cstr;
-(void) visitMinimize: (id<ORObjectiveFunction>) v;
-(void) visitMaximize: (id<ORObjectiveFunction>) v;
-(void) visitEqualc: (id<OREqualc>)c;
-(void) visitNEqualc: (id<ORNEqualc>)c;
-(void) visitLEqualc: (id<ORLEqualc>)c;
-(void) visitEqual: (id<OREqual>)c;
-(void) visitNEqual: (id<ORNEqual>)c;
-(void) visitLEqual: (id<ORLEqual>)c;
-(void) visitPlus: (id<ORPlus>)c;
-(void) visitMult: (id<ORMult>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c;
-(void) visitReifyEqual: (id<ORReifyEqual>)c;
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c;
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c;
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c;
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c;
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c;
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c;
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c;
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c;
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c;
-(void) visitSumEqualc:(id<ORSumEqc>)c;
-(void) visitSumLEqualc:(id<ORSumLEqc>)c;
-(void) visitSumGEqualc:(id<ORSumGEqc>)c;
// Expressions
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
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c;
@end
