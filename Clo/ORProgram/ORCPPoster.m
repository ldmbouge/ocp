/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORProgram.h"
#import "CPConcretizer.h"
#import "ORCPPoster.h"
#import "objcp/CPFactory.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPSolver.h"
#import "objcp/CPSolver.h"

@implementation ORCPPoster
{
   id<CPSolver> _solver;
}
-(ORCPPoster*) initORCPPoster: (id<CPSolver>) solver
{
   self = [super init];
   _solver = [solver retain];
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
-(void) visitIntRange:(id<ORIntRange>)v
{
   
}
-(void) visitIntVar: (id<ORIntVar>) v
{
}
-(void) visitFloatVar: (id<ORFloatVar>) v
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
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   [_solver add: [cstr impl]];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   [_solver add: [cstr impl]];   
}
//-(void) visitBinPacking: (id<ORBinPacking>) cstr
//{
//   [_solver add: [cstr impl]];
//}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   [_solver add: [cstr impl]];   
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   [_solver add: [cstr impl]];   
}
-(void) visitMinimize: (id<ORObjectiveFunction>) v
{
 
}
-(void) visitMaximize: (id<ORObjectiveFunction>) v
{
   
}
-(void) visitEqualc: (id<OREqualc>)c
{
   [_solver add: [c impl]];     
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   [_solver add: [c impl]];     
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   [_solver add: [c impl]];     
}
-(void) visitEqual: (id<OREqual>)c
{
   [_solver add: [c impl]];     
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   [_solver add: [c impl]];     
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   [_solver add: [c impl]];     
}
-(void) visitEqual3: (id<OREqual3>)c
{
   [_solver add: [c impl]];     
}
-(void) visitMult: (id<ORMult>)c
{
   [_solver add: [c impl]];     
}
-(void) visitAbs: (id<ORAbs>)c
{
   [_solver add: [c impl]];     
}
-(void) visitOr: (id<OROr>)c
{
   [_solver add: [c impl]];     
}
-(void) visitAnd:( id<ORAnd>)c
{
   [_solver add: [c impl]];     
}
-(void) visitImply: (id<ORImply>)c
{
   [_solver add: [c impl]];     
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   [_solver add: [c impl]];     
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   [_solver add: [c impl]];     
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
