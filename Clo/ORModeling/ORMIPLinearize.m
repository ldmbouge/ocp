/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012,2013 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORMIPLinearize.h"
#import <ORFoundation/ORArrayI.h>
#import "ORConstraintI.h"
#import "ORModelI.h"
#import "ORDecompose.h"
#import "ORVarI.h"
#import "ORSetI.h"

@implementation ORMIPLinearize
{
   id<ORAddToModel> _into;
   id               _result;
   id<ORIntRange>   _01;
   ORInt            _M;
}
-(id) initORMIPLinearize: (id<ORAddToModel>) into
{
   self = [super init];
   _into = into;
   _01 = RANGE(_into,0,1);
   _M = 10000;
   return self;
}
+(id<ORModel>) linearize: (id<ORModel>) model
{
   id<ORModel> lin = [ORFactory createModel: [model nbObjects] mappings: model.modelMappings];
   ORBatchModel* lm = [[ORBatchModel alloc] init: lin source:model annotation:nil]; //TOFIX
   id<ORModelTransformation> linearizer = [[ORMIPLinearize alloc] initORMIPLinearize: lm];
   [linearizer apply: model with:nil]; //TOFIX
   return lin;
}
-(void) dealloc
{
   [super dealloc];
}
-(id<ORAddToModel>)target
{
   return _into;
}
-(id) linearizeIt: (id) obj
{
   id pr = _result;  // linearizeIt must work if reentrant.
   _result = NULL;
   [obj visit:self];
   id rv = _result;
   _result = pr;     // restore what used to be result.
   return rv;
}

-(void) apply: (id<ORModel>) m with:(id<ORAnnotation>)notes 
{
   [m applyOnVar: ^(id<ORVar> x) {
      [_into addVariable: x];
   }
   onMutables: ^(id<ORObject> x) {
      if (![x isKindOfClass:[ORNEqual class]])
          [_into addMutable: x];
   }
   onImmutables: ^(id<ORObject> x) {
      [_into addImmutable: x];
   }
   onConstraints: ^(id<ORConstraint> c) {
      [self linearizeIt: c];
   }
   onObjective: ^(id<ORObjectiveFunction> o) {
      [self linearizeIt: o];
   }];
}

-(void) visitIntVar: (ORIntVarI*) v
{
   _result = v;
}
-(void) visitBitVar: (ORBitVarI*) v
{
   _result = v;
}
-(void) visitFloatVar: (ORFloatVarI*) v
{
   _result = v;
}
-(void) visitIntVarLitEQView:(ORIntVarLitEQView*)v
{
   _result = v;
}
-(void) visitAffineVar:(ORIntVarAffineI*) v
{
   _result = v;
}

// ======================================================================================================

-(void) visitIntegerI: (id<ORInteger>) e
{
   _result = e;
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   _result = e;
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   _result = e;
}

-(void) visitIntArray:(id<ORIntArray>)v
{
   _result = v;
}
-(void) visitFloatArray:(id<ORFloatArray>)v
{
   _result = v;
}
-(void) visitIntMatrix:(id<ORIntMatrix>)v
{
   _result = v;
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
   _result = v;
}
-(void) visitIntSet:(id<ORIntSet>)v
{
   _result = v;
}
-(void) visitIntRange:(id<ORIntRange>)v
{
   _result = v;
}
-(void) visitFloatRange:(id<ORFloatRange>)v
{
   _result = v;
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   _result = v;
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   _result = v;
}
-(void) visitTable:(id<ORTable>) v
{
   _result = v;
}

// ======================================================================================================

-(void) visitRestrict:(id<ORRestrict>)cstr
{
   _result = cstr;
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   _result = cstr;
}
-(void) visitRegular:(id<ORRegular>) cstr
{
   _result = cstr;
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   _result = cstr;
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   assert(false);
}
-(void) visitGroup:(id<ORGroup>)g
{
    assert(false);
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   _result = cstr;
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   _result = cstr;
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   assert(false);
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   _result = cstr;
}
-(void) visitFloatEqualc: (id<ORFloatEqualc>)c
{
   _result = c;
}
-(void) visitEqualc: (id<OREqualc>)c
{
   _result = c;
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   NSLog(@"NEQC");
   _result = c;
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   _result = c;
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   _result = c;
}
-(void) visitEqual: (id<OREqual>)c
{
   _result = c;
}
-(void) visitAffine: (id<ORAffine>)c
{
   _result = c;
}
-(void) visitNEqual: (id<ORNEqual>) c
{
   id<ORIntVar> b = [ORFactory intVar: _into domain: _01];
   id<ORIntVar> x = [c left];
   id<ORIntVar> y = [c right];
   ORInt cst = [c cst];
   
   id<ORExpr> c1 = [x gt: [[y plus: @(cst) track:_into] sub: [b mul: @(_M) track:_into] track:_into] track:_into];
   id<ORExpr> c2 = [x lt: [[y plus: @(cst) track:_into] sub: [[b sub: @(1) track:_into] mul: @(_M) track:_into] track:_into] track:_into];
   [_into addConstraint: c1];
   [_into addConstraint: c2];
   _result = c;
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   _result = c;
}
-(void) visitPlus: (id<ORPlus>)c
{
   _result = c;
}
-(void) visitMult: (id<ORMult>)c
{
   _result = c;
}
-(void) visitSquare:(id<ORSquare>)c
{
   _result = c;
}
-(void) visitFloatSquare:(id<ORSquare>)c
{
   _result = c;
}
-(void) visitMod: (id<ORMod>)c
{
   _result = c;
}
-(void) visitModc: (id<ORModc>)c
{
   _result = c;
}
-(void) visitMin:(id<ORMin>)c
{
   _result = c;
}
-(void) visitMax:(id<ORMax>)c
{
   _result = c;
}
-(void) visitAbs: (id<ORAbs>)c
{
   _result = c;
}
-(void) visitOr: (id<OROr>)c
{
   _result = c;
}
-(void) visitAnd:( id<ORAnd>)c
{
   _result = c;
}
-(void) visitImply: (id<ORImply>)c
{
   _result = c;
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   _result = c;
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   _result = c;
}
-(void) visitFloatElementCst: (id<ORFloatElementCst>) c
{
   _result = c;
}
-(void) visitCircuit:(id<ORCircuit>) c
{
   _result = c;
}
-(void) visitNoCycle:(id<ORNoCycle>) c
{
   _result = c;
}
-(void) visitLexLeq:(id<ORLexLeq>) c
{
   _result = c;
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c
{
   _result = c;
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   _result = c;
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
   _result = c;
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c
{
   _result = c;
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c
{
   _result = c;
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c
{
   _result = c;
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
   _result = c;
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c
{
   _result = c;
}
-(void) visitReifySumBoolEqualc:(id<ORReifySumBoolEqc>)c
{
   _result = c;
}
-(void) visitReifySumBoolGEqualc:(id<ORReifySumBoolGEqc>)c
{
   _result = c;
}
-(void) visitHReifySumBoolEqualc:(id<ORReifySumBoolEqc>)c
{
   _result = c;
}
-(void) visitHReifySumBoolGEqualc:(id<ORReifySumBoolGEqc>)c
{
   _result = c;
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   _result = c;
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c
{
   _result = c;
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c
{
   _result = c;
}
-(void) visitSumEqualc:(id<ORSumEqc>)c
{
   _result = c;
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c
{
   _result = c;
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c
{
   _result = c;
}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   _result = c;
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   _result = c;
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   _result = c;
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   _result = c;
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   _result = c;
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   _result = c;
}
-(void) visitBitShiftR:(id<ORBitShiftR>)c
{
   _result = c;
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   _result = c;
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   _result = c;
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   _result = c;
}
-(void) visitBitCount:(id<ORBitCount>)c
{
   _result = c;
}
-(void) visitBitZeroExtend:(id<ORBitZeroExtend>)c
{
   _result = c;
}
-(void) visitBitExtract:(id<ORBitExtract>)c
{
   _result = c;
}
-(void) visitBitConcat:(id<ORBitConcat>)c
{
   _result = c;
}
-(void) visitBitLogicalEqual:(id<ORBitLogicalEqual>)c
{
   _result = c;
}
-(void) visitBitLT:(id<ORBitLT>)c
{
   _result = c;
}
-(void) visitBitLE:(id<ORBitLE>)c
{
   _result = c;
}

-(void) visitBitITE:(id<ORBitITE>)c
{
   _result = c;
}

-(void) visitBitLogicalAnd:(id<ORBitLogicalAnd>)c
{
   _result = c;
}
-(void) visitBitLogicalOr:(id<ORBitLogicalOr>)c
{
   _result = c;
}
// Flattening of constraints ============================================================================

-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   _result = [_into minimizeVar:[v var]];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   _result = [_into maximizeVar:[v var]];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   assert(false);
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   assert(false);
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   _result = [_into minimize: [v array] coef: [v coef]];
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   _result = [_into maximize: [v array] coef: [v coef]];
}

@end


