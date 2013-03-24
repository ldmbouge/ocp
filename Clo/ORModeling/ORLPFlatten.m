/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORLPFlatten.h"
#import "ORModelI.h"
#import "ORDecompose.h"
#import "ORLPDecompose.h"

@interface ORLPNOopVisit : NSObject<ORVisitor>
@end

@implementation ORLPNOopVisit
-(void) visitRandomStream:(id) v {}
-(void) visitZeroOneStream:(id) v {}
-(void) visitUniformDistribution:(id) v{}
-(void) visitIntSet:(id<ORIntSet>)v{}
-(void) visitIntRange:(id<ORIntRange>)v{}
-(void) visitIntArray:(id<ORIntArray>)v  {}
-(void) visitIntMatrix:(id<ORIntMatrix>)v  {}
-(void) visitTrailableInt:(id<ORTrailableInt>)v  {}
-(void) visitIntVar: (id<ORIntVar>) v  {}
-(void) visitFloatVar: (id<ORFloatVar>) v  {}
-(void) visitBitVar: (id<ORBitVar>) v {}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v  {}
-(void) visitAffineVar:(id<ORIntVar>) v  {}
-(void) visitIdArray: (id<ORIdArray>) v  {}
-(void) visitIdMatrix: (id<ORIdMatrix>) v  {}
-(void) visitTable:(id<ORTable>) v  {}
// micro-Constraints
-(void) visitConstraint:(id<ORConstraint>)c  {}
-(void) visitGroup:(id<ORGroup>)g {}
-(void) visitObjectiveFunctionVar:(id<ORObjectiveFunctionVar>)f  {}
-(void) visitObjectiveFunctionExpr:(id<ORObjectiveFunctionExpr>)f  {}
-(void) visitObjectiveFunctionLinear:(id<ORObjectiveFunctionLinear>)f  {}
-(void) visitFail:(id<ORFail>)cstr  {}
-(void) visitRestrict:(id<ORRestrict>)cstr  {}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr  {}
-(void) visitCardinality: (id<ORCardinality>) cstr  {}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr  {}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr  {}
-(void) visitLexLeq:(id<ORLexLeq>) cstr  {}
-(void) visitCircuit:(id<ORCircuit>) cstr  {}
-(void) visitNoCycle:(id<ORNoCycle>) cstr  {}
-(void) visitPackOne:(id<ORPackOne>) cstr  {}
-(void) visitPacking:(id<ORPacking>) cstr  {}
-(void) visitKnapsack:(id<ORKnapsack>) cstr  {}
-(void) visitAssignment:(id<ORAssignment>)cstr {}

-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v {}
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v {}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e {}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e {}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o {}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o {}

-(void) visitEqualc: (id<OREqualc>)c  {}
-(void) visitNEqualc: (id<ORNEqualc>)c  {}
-(void) visitLEqualc: (id<ORLEqualc>)c  {}
-(void) visitGEqualc: (id<ORGEqualc>)c  {}
-(void) visitEqual: (id<OREqual>)c  {}
-(void) visitAffine: (id<ORAffine>)c  {}
-(void) visitNEqual: (id<ORNEqual>)c  {}
-(void) visitLEqual: (id<ORLEqual>)c  {}
-(void) visitPlus: (id<ORPlus>)c  {}
-(void) visitMult: (id<ORMult>)c  {}
-(void) visitSquare:(id<ORSquare>)c {}
-(void) visitMod: (id<ORMod>)c {}
-(void) visitModc: (id<ORModc>)c {}
-(void) visitAbs: (id<ORAbs>)c  {}
-(void) visitOr: (id<OROr>)c  {}
-(void) visitAnd:( id<ORAnd>)c  {}
-(void) visitImply: (id<ORImply>)c  {}
-(void) visitElementCst: (id<ORElementCst>)c  {}
-(void) visitElementVar: (id<ORElementVar>)c  {}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c  {}
-(void) visitReifyEqual: (id<ORReifyEqual>)c  {}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c  {}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c  {}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c  {}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c  {}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c  {}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c  {}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c  {}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c  {}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c  {}
-(void) visitSumEqualc:(id<ORSumEqc>)c  {}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c  {}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c  {}

-(void) visitLinearGeq: (id<ORLinearGeq>) c {}
-(void) visitLinearLeq: (id<ORLinearLeq>) c {}
-(void) visitLinearEq: (id<ORLinearEq>) c {}


// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c {}
-(void) visitBitOr:(id<ORBitOr>)c {}
-(void) visitBitAnd:(id<ORBitAnd>)c {}
-(void) visitBitNot:(id<ORBitNot>)c {}
-(void) visitBitXor:(id<ORBitXor>)c {}
-(void) visitBitShiftL:(id<ORBitShiftL>)c {}
-(void) visitBitRotateL:(id<ORBitRotateL>)c {}
-(void) visitBitSum:(id<ORBitSum>)c {}
-(void) visitBitIf:(id<ORBitIf>)c {}

// Expressions
-(void) visitIntegerI: (id<ORInteger>) e  {}
-(void) visitExprPlusI: (id<ORExpr>) e  {}
-(void) visitExprMinusI: (id<ORExpr>) e  {}
-(void) visitExprMulI: (id<ORExpr>) e  {}
-(void) visitExprDivI: (id<ORExpr>) e  {}
-(void) visitExprEqualI: (id<ORExpr>) e  {}
-(void) visitExprNEqualI: (id<ORExpr>) e  {}
-(void) visitExprLEqualI: (id<ORExpr>) e  {}
-(void) visitExprSumI: (id<ORExpr>) e  {}
-(void) visitExprProdI: (id<ORExpr>) e  {}
-(void) visitExprAbsI:(id<ORExpr>) e  {}
-(void) visitExprNegateI:(id<ORExpr>) e  {}
-(void) visitExprCstSubI: (id<ORExpr>) e  {}
-(void) visitExprDisjunctI:(id<ORExpr>) e  {}
-(void) visitExprConjunctI: (id<ORExpr>) e  {}
-(void) visitExprImplyI: (id<ORExpr>) e  {}
-(void) visitExprAggOrI: (id<ORExpr>) e  {}
-(void) visitExprVarSubI: (id<ORExpr>) e  {}
@end

@interface ORLPFlattenObjects : ORLPNOopVisit<ORVisitor> {
   id<ORAddToModel> _theModel;
}
-(id)init:(id<ORAddToModel>)m;
-(void) visitIntArray:(id<ORIntArray>)v;
-(void) visitIntMatrix:(id<ORIntMatrix>)v;
-(void) visitTrailableInt:(id<ORTrailableInt>)v;
-(void) visitIntSet:(id<ORIntSet>)v;
-(void) visitIntRange:(id<ORIntRange>)v;
-(void) visitIdArray: (id<ORIdArray>) v;
-(void) visitIdMatrix: (id<ORIdMatrix>) v;
-(void) visitTable:(id<ORTable>) v;
@end

@interface ORLPFlattenConstraint : ORLPNOopVisit<ORVisitor> {
   id<ORAddToModel> _theModel;
}
-(id)init:(id<ORAddToModel>)m;
-(void) visitRestrict:(id<ORRestrict>)cstr;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitPacking: (id<ORPacking>) cstr;
-(void) visitKnapsack:(id<ORKnapsack>) cstr;
-(void) visitAssignment:(id<ORAssignment>)cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitEqualc: (id<OREqualc>)c;
-(void) visitNEqualc: (id<ORNEqualc>)c;
-(void) visitLEqualc: (id<ORLEqualc>)c;
-(void) visitGEqualc: (id<ORGEqualc>)c;
-(void) visitEqual: (id<OREqual>)c;
-(void) visitAffine: (id<ORAffine>)c;
-(void) visitNEqual: (id<ORNEqual>)c;
-(void) visitLEqual: (id<ORLEqual>)c;
-(void) visitPlus: (id<ORPlus>)c;
-(void) visitMult: (id<ORMult>)c;
-(void) visitSquare:(id<ORSquare>)c;
-(void) visitMod: (id<ORMod>)c;
-(void) visitModc: (id<ORModc>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
-(void) visitCircuit:(id<ORCircuit>) cstr;
-(void) visitNoCycle:(id<ORNoCycle>) cstr;
-(void) visitLexLeq:(id<ORLexLeq>) cstr;
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
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)cstr;
-(void) visitBitOr:(id<ORBitOr>)cstr;
-(void) visitBitAnd:(id<ORBitAnd>)cstr;
-(void) visitBitNot:(id<ORBitNot>)cstr;
-(void) visitBitXor:(id<ORBitXor>)cstr;
-(void) visitBitShiftL:(id<ORBitNot>)cstr;
-(void) visitBitSum:(id<ORBitSum>)cstr;
-(void) visitBitIf:(id<ORBitIf>)cstr;
@end


@interface ORLPFlattenObjective : NSObject<ORVisitor>
-(id)init:(id<ORAddToModel>)m;

-(void) visitMinimizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeVar: (id<ORObjectiveFunction>) v;
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e;
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) o;
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) o;

@end


@implementation ORLPFlatten
-(id)initORLPFlatten
{
   self = [super init];
   return self;
}
-(void) apply: (id<ORModel>) m into: (id<ORAddToModel>) batch
{
   [m applyOnVar:^(id<ORVar> x) {
      [batch addVariable:x];
   } onObjects:^(id<ORObject> x) {
      ORLPFlattenObjects* fo = [[ORLPFlattenObjects alloc] init:batch];
      [x visit:fo];
      [fo release];
   } onConstraints:^(id<ORConstraint> c) {
      [batch compiling:c];
      [ORLPFlatten flatten:c into:batch];
      NSSet* map = [batch compiledMap];
      NSLog(@"Got a Map %@",map);
   } onObjective:^(id<ORObjective> o) {
      NSLog(@"objective %@ ",o);
      if (o) {
         ORLPFlattenObjective* fo = [[ORLPFlattenObjective alloc] init:batch];
         [o visit:fo];
         [fo release];
      }
   }];
}

+(void)flatten:(id<ORConstraint>)c into:(id<ORAddToModel>)m
{
   ORLPFlattenConstraint* fc = [[ORLPFlattenConstraint alloc] init:m];
   [c visit:fc];
   [fc release];
}
+(void) flattenExpression:(id<ORExpr>)expr into:(id<ORAddToModel>)model annotation:(ORAnnotation)note
{
   ORLinear* terms = [ORLPNormalizer normalize: expr into: model annotation:note];
   switch ([expr type]) {
      case ORRBad:
         assert(NO);
      case ORREq:
         {
            [terms postLinearEq: model annotation: note];
         }
         break;
      case ORRNEq:
         {
            @throw [[ORExecutionError alloc] initORExecutionError: "No != constraint supported in LP yet"];
         }
         break;
      case ORRLEq:
         {
           [terms postLinearLeq: model annotation: note];
         }
         break;
      default:
         assert(terms == nil);
         break;
   }
   [terms release];
}
@end

@implementation ORLPFlattenObjects
-(id)init:(id<ORAddToModel>)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitIntArray:(id<ORIntArray>)v
{
   [_theModel addObject:v];
}
-(void) visitIntMatrix:(id<ORIntMatrix>)v
{
   [_theModel addObject:v];
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
   [_theModel addObject:v];
}
-(void) visitIntSet:(id<ORIntSet>)v
{
   [_theModel addObject:v];
}
-(void) visitIntRange:(id<ORIntRange>)v
{
   [_theModel addObject:v];
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   [_theModel addObject:v];
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   [_theModel addObject:v];
}
-(void) visitTable:(id<ORTable>) v
{
   [_theModel addObject:v];
}
@end

@implementation ORLPFlattenConstraint
-(id)init:(id<ORAddToModel>)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitRestrict:(id<ORRestrict>)cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   id<ORIntVarArray> item = [cstr item];
   id<ORIntVarArray> binSize = [cstr binSize];
   id<ORIntArray>    itemSize = [cstr itemSize];
   id<ORIntRange> BR = [binSize range];
   id<ORIntRange> IR = [item range];
   id<ORTracker> tracker = [item tracker];
   ORInt brlow = [BR low];
   ORInt brup = [BR up];
   for(ORInt b = brlow; b <= brup; b++) /*note:RangeConsistency*/
      [ORLPFlatten flattenExpression: [Sum(tracker,i,IR,mult([itemSize at:i],[item[i] eqi: b])) eq: binSize[b]]
                              into: _theModel
                        annotation: DomainConsistency];
   ORInt s = 0;
   ORInt irlow = [IR low];
   ORInt irup = [IR up];
   for(ORInt i = irlow; i <= irup; i++)
      s += [itemSize at:i];
   [ORLPFlatten flattenExpression: [Sum(tracker,b,BR,binSize[b]) eqi: s]
                           into: _theModel
                     annotation: DomainConsistency];
   
   for(ORInt b = brlow; b <= brup; b++)
      [_theModel addConstraint: [ORFactory packOne: item itemSize: itemSize bin: b binSize: binSize[b]]];
}
-(void) visitGroup:(id<ORGroup>)g
{
   id<ORGroup> ng = [ORFactory group:_theModel type:[g type]];
   id<ORAddToModel> a2g = [[ORBatchGroup alloc] init:_theModel group:ng];
   [g enumerateObjectWithBlock:^(id<ORConstraint> ck) {
      [ORLPFlatten flatten:ck into:a2g];
   }];
   [_theModel addConstraint:ng];
   [a2g release];
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   [ORLPFlatten flattenExpression:[cstr expr] into:_theModel annotation:[cstr annotation]];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   [_theModel addConstraint:cstr];
}
-(void) visitEqualc: (id<OREqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitEqual: (id<OREqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitAffine: (id<ORAffine>)c
{
   [_theModel addConstraint:c];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitPlus: (id<ORPlus>)c
{
   [_theModel addConstraint:c];
}
-(void) visitMult: (id<ORMult>)c
{
   [_theModel addConstraint:c];
}
-(void) visitSquare:(id<ORSquare>)c
{
   [_theModel addConstraint:c];
}
-(void) visitMod: (id<ORMod>)c
{
   [_theModel addConstraint:c];
}
-(void) visitModc: (id<ORModc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitAbs: (id<ORAbs>)c
{
   [_theModel addConstraint:c];
}
-(void) visitOr: (id<OROr>)c
{
   [_theModel addConstraint:c];
}
-(void) visitAnd:( id<ORAnd>)c
{
   [_theModel addConstraint:c];
}
-(void) visitImply: (id<ORImply>)c
{
   [_theModel addConstraint:c];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   [_theModel addConstraint:c];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   [_theModel addConstraint:c];
}
-(void) visitCircuit:(id<ORCircuit>) c
{
   [_theModel addConstraint:c];
}
-(void) visitNoCycle:(id<ORNoCycle>) c
{
   [_theModel addConstraint:c];
}
-(void) visitLexLeq:(id<ORLexLeq>) c
{
   [_theModel addConstraint:c];
}

-(void) visitReifyEqualc: (id<ORReifyEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   [_theModel addConstraint:c];
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitSumEqualc:(id<ORSumEqc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c
{
   [_theModel addConstraint:c];
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c
{
   [_theModel addConstraint:c];
}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   [_theModel addConstraint:c];
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   [_theModel addConstraint:c];
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   [_theModel addConstraint:c];
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   [_theModel addConstraint:c];
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   [_theModel addConstraint:c];
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   [_theModel addConstraint:c];
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   [_theModel addConstraint:c];
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   [_theModel addConstraint:c];
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   [_theModel addConstraint:c];
}
@end

@implementation ORLPFlattenObjective {
   id<ORAddToModel> _theModel;
}
-(id)init:(id<ORAddToModel>)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   [_theModel minimize:[v var]];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   [_theModel maximize:[v var]];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   ORLinear* terms = [ORLPLinearizer linearFrom: [v expr] model: _theModel annotation: Default];
   [_theModel minimize: [terms variables: _theModel] coef: [terms coefficients: _theModel]];
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   ORLinear* terms = [ORLPLinearizer linearFrom: [v expr] model: _theModel annotation: Default];
   [_theModel maximize: [terms variables: _theModel] coef: [terms coefficients: _theModel]];
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   assert(FALSE);
   //   [_theModel minimize:[v var]];
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   assert(FALSE);
   //   [_theModel maximize:[v var]];
}
@end
