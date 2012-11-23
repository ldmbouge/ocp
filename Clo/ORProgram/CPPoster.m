/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import "CPProgram.h"
#import "CPConcretizer.h"
#import "CPPoster.h"

@implementation ORCPPoster
{
   id<CPCommonProgram> _solver;
   id<CPEngine> _engine;
}
-(ORCPPoster*) initORCPPoster: (id<CPCommonProgram>) solver
{
   self = [super init];
   _solver = [solver retain];
   _engine = [_solver engine];
   return self;
}
-(void) dealloc
{
   [_solver release];
   [super dealloc];
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{   
}
-(void) visitIntSet:(id<ORIntSet>)v
{
}
-(void) visitIntArray:(id<ORIntArray>)v
{
}
-(void) visitIntMatrix: (id<ORIntMatrix>) v
{
}

-(void) visitIntRange:(id<ORIntRange>)v
{
}
-(void) visitIntVar: (id<ORIntVar>) v
{
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
}
-(void) visitBitVar: (id<ORBitVar>) v
{
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
}
-(void) visitIdArray: (id<ORIdArray>) v
{
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
}
-(void) visitTable:(id<ORTable>) v
{
}

-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   [_engine add: [cstr dereference]];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   [_engine add: [cstr dereference]];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   [_engine add: [cstr dereference]];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   [_engine add: [cstr dereference]];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   [_engine add: [cstr dereference]];
}
-(void) visitRestrict:(id<ORRestrict>)cstr
{
   [_engine add:[cstr dereference]];
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
  [_engine add: [cstr dereference]];   
}
-(void) visitNoCycle:(id<ORNoCycle>) cstr
{
  [_engine add: [cstr dereference]];   
}
-(void) visitLexLeq:(id<ORLexLeq>)cstr
{
   [_engine add: [cstr dereference]];
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
  [_engine add: [cstr dereference]];   
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
  [_engine add: [cstr dereference]];   
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   [_engine add:[cstr impl]];
}
-(void) visitMinimize: (id<ORObjectiveFunction>) v
{
   [_engine add: [v dereference]];
   [_engine setObjective: [v dereference]];
}
-(void) visitMaximize: (id<ORObjectiveFunction>) v
{
   [_engine add: [v dereference]];
   [_engine setObjective: [v dereference]];
}
-(void) visitEqualc: (id<OREqualc>)c
{
   [_engine add: [c dereference]];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   [_engine add: [c dereference]];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   [_engine add: [c dereference]];
}
-(void) visitEqual: (id<OREqual>)c
{
   [_engine add: [c dereference]];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   [_engine add: [c dereference]];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   [_engine add: [c dereference]];
}
-(void) visitPlus: (id<ORPlus>)c
{
   [_engine add: [c dereference]];
}
-(void) visitMult: (id<ORMult>)c
{
   [_engine add: [c dereference]];
}
-(void) visitAbs: (id<ORAbs>)c
{
   [_engine add: [c dereference]];
}
-(void) visitOr: (id<OROr>)c
{
   [_engine add: [c dereference]];
}
-(void) visitAnd:( id<ORAnd>)c
{
   [_engine add: [c dereference]];
}
-(void) visitImply: (id<ORImply>)c
{
   [_engine add: [c dereference]];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   [_engine add: [c dereference]];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   [_engine add: [c dereference]];
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>) cstr
{
   [_engine add: [cstr dereference]];
}
-(void) visitReifyEqual: (id<ORReifyEqual>) cstr
{
   [_engine add: [cstr dereference]];
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>) cstr
{
    [_engine add: [cstr dereference]];  
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitSumEqualc:(id<ORSumEqc>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitSumLEqualc:(id<ORSumLEqc>) cstr
{
   [_engine add: [cstr dereference]];   
}
-(void) visitSumGEqualc:(id<ORSumGEqc>) cstr
{
   [_engine add: [cstr dereference]];   
}

//
-(void) visitIntegerI: (id<ORInteger>) e
{

}
-(void) visitExprPlusI: (id<ORExpr>) e
{

}
-(void) visitExprMinusI: (id<ORExpr>) e
{
   
}
-(void) visitExprMulI: (id<ORExpr>) e
{
   
}
-(void) visitExprEqualI: (id<ORExpr>) e
{
   
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
   
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
   
}
-(void) visitExprSumI: (id<ORExpr>) e
{
   
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
   
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
   
}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{
   
}
-(void) visitExprConjunctI: (id<ORExpr>) e
{
   
}
-(void) visitExprImplyI: (id<ORExpr>) e
{
   
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
   
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
   
}
@end
