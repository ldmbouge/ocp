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
-(void) visitFloatArray:(id<ORIntArray>)v  {}
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
-(void) visitFloatLinearLeq: (id<ORFloatLinearLeq>) c {}
-(void) visitFloatLinearEq: (id<ORFloatLinearEq>) c {}


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
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e  {}
-(void) visitFloatI: (id<ORFloatNumber>) e  {}
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
-(void) visitFloatArray:(id<ORIntArray>)v;
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


@implementation ORLPFlatten {
   id<ORAddToModel> _into;
}
-(id)initORLPFlatten:(id<ORAddToModel>)into
{
   self = [super init];
   _into = into;
   return self;
}
-(void) apply: (id<ORModel>) m
{
   [m applyOnVar:^(id<ORVar> x) {
      [_into addVariable:x];
   } onMutables:^(id<ORObject> x) {
      ORLPFlattenObjects* fo = [[ORLPFlattenObjects alloc] init:_into];
      [x visit:fo];
      [fo release];
   } onImmutables:^(id<ORObject> x) {
      ORLPFlattenObjects* fo = [[ORLPFlattenObjects alloc] init:_into];
      [x visit:fo];
      [fo release];
   } onConstraints:^(id<ORConstraint> c) {
      [ORLPFlatten flatten:c into:_into];
   } onObjective:^(id<ORObjectiveFunction> o) {
      if (o) {
         ORLPFlattenObjective* fo = [[ORLPFlattenObjective alloc] init:_into];
         [o visit:fo];
         [fo release];
      }
   }];
}

+(void) flatten: (id<ORConstraint>) c into: (id<ORAddToModel>)m
{
   ORLPFlattenConstraint* fc = [[ORLPFlattenConstraint alloc] init:m];
   [c visit:fc];
   [fc release];
}
+(id<ORConstraint>) flattenExpression:(id<ORExpr>)expr into:(id<ORAddToModel>)model annotation:(ORAnnotation)note
{
   ORFloatLinear* terms = [ORLPNormalizer normalize: expr into: model annotation:note];
   id<ORConstraint> cstr = NULL;
   switch ([expr type]) {
      case ORRBad:
         assert(NO);
      case ORREq:
         {
            cstr = [terms postLinearEq: model annotation: note];
         }
         break;
      case ORRNEq:
         {
            @throw [[ORExecutionError alloc] initORExecutionError: "No != constraint supported in LP yet"];
         }
         break;
      case ORRLEq:
         {
           cstr = [terms postLinearLeq: model annotation: note];
         }
         break;
      default:
         assert(terms == nil);
         break;
   }
   [terms release];
   return cstr;
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
-(void) visitFloatArray:(id<ORFloatArray>)v
{
   [_theModel addObject:v];
}

-(void) visitIntMatrix:(id<ORIntMatrix>)v
{
   [_theModel addObject:v];
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
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
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];

}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];

}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitGroup:(id<ORGroup>)g
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   id<ORConstraint> impl = [ORLPFlatten flattenExpression:[cstr expr] into:_theModel annotation:[cstr annotation]];
   [cstr setImpl: impl];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitEqualc: (id<OREqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitEqual: (id<OREqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitAffine: (id<ORAffine>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitPlus: (id<ORPlus>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitMult: (id<ORMult>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitSquare:(id<ORSquare>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitMod: (id<ORMod>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitModc: (id<ORModc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitAbs: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitOr: (id<OROr>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitAnd:( id<ORAnd>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitImply: (id<ORImply>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitCircuit:(id<ORCircuit>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitNoCycle:(id<ORNoCycle>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitLexLeq:(id<ORLexLeq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}

-(void) visitReifyEqualc: (id<ORReifyEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitSumEqualc:(id<ORSumEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
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
   ORFloatLinear* terms = [ORLPLinearizer linearFrom: [v expr] model: _theModel annotation: Default];
   id<ORObjectiveFunction> objective = [_theModel minimize: [terms variables: _theModel] coef: [terms coefficients: _theModel]];
   [v setImpl: objective];
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   ORFloatLinear* terms = [ORLPLinearizer linearFrom: [v expr] model: _theModel annotation: Default];
   id<ORObjectiveFunction> objective = [_theModel maximize: [terms variables: _theModel] coef: [terms coefficients: _theModel]];
   [v setImpl: objective];
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in LP"];
}
@end
