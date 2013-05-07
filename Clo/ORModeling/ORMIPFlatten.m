/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORMIPFlatten.h"
#import "ORModelI.h"
#import "ORDecompose.h"
#import "ORMIPDecompose.h"
#import "ORFloatLinear.h"
#import "ORFlatten.h"

@implementation ORMIPFlatten
-(id)initORMIPFlatten:(id<ORAddToModel>)into
{
   self = [super initORFlatten:into];
   return self;
}
+(void)flatten:(id<ORConstraint>)c into:(id<ORAddToModel>)m
{
   ORMIPFlatten* fc = [[ORMIPFlatten alloc] initORMIPFlatten:m];
   [c visit:fc];
   [fc release];
}
+(id<ORConstraint>) flattenExpression:(id<ORExpr>) expr into:(id<ORAddToModel>)model annotation:(ORAnnotation)note
{
   ORFloatLinear* terms = [ORMIPNormalizer normalize: expr into: model annotation:note];
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
         @throw [[ORExecutionError alloc] initORExecutionError: "No != constraint supported in MIP yet"];
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


-(void) visitRestrict:(id<ORRestrict>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitGroup:(id<ORGroup>)g
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   _result = [ORMIPFlatten flattenExpression:[cstr expr] into:[self target] annotation:[cstr annotation]];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitEqualc: (id<OREqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitEqual: (id<OREqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitAffine: (id<ORAffine>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitPlus: (id<ORPlus>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitMult: (id<ORMult>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitSquare:(id<ORSquare>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitMod: (id<ORMod>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitModc: (id<ORModc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitAbs: (id<ORAbs>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitOr: (id<OROr>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitAnd:( id<ORAnd>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitImply: (id<ORImply>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitCircuit:(id<ORCircuit>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitNoCycle:(id<ORNoCycle>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitLexLeq:(id<ORLexLeq>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitSumEqualc:(id<ORSumEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}

-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   [super visitMinimizeVar:v];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   [super visitMaximizeVar:v];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   ORFloatLinear* terms = [ORMIPLinearizer linearFrom: [v expr] model: _into annotation: Default];
   id<ORObjectiveFunction> objective = [_into minimize: [terms variables: _into] coef: [terms coefficients: _into]];
   [v setImpl: objective];
   [terms release];
   _result =  objective;
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   ORFloatLinear* terms = [ORMIPLinearizer linearFrom: [v expr] model: _into annotation: Default];
   id<ORObjectiveFunction> objective = [_into maximize: [terms variables: _into] coef: [terms coefficients: _into]];
   [v setImpl: objective];
   [terms release];
   _result =  objective;
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Cannot flatten in MIP yet"];
}
@end
