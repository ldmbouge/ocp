/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFlatten.h"
#import "ORModelI.h"
#import "ORDecompose.h"
#import "ORSetI.h"
#import "ORVarI.h"
#import <ORFoundation/ORArrayI.h>

@implementation ORNOopVisit
-(void) visitRandomStream:(id) v {}
-(void) visitZeroOneStream:(id) v {}
-(void) visitUniformDistribution:(id) v{}
-(void) visitIntSet:(id<ORIntSet>)v{}
-(void) visitIntRange:(id<ORIntRange>)v     {}
-(void) visitFloatRange:(id<ORFloatRange>)v {}
-(void) visitIntArray:(id<ORIntArray>)v  {}
-(void) visitFloatArray:(id<ORFloatArray>)v  {}
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
-(void) visitRegular:(id<ORRegular>) cstr {}
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
-(void) visitFloatSquare:(id<ORSquare>)c {}
-(void) visitMod: (id<ORMod>)c {}
-(void) visitModc: (id<ORModc>)c {}
-(void) visitMin:(id<ORMin>)c  {}
-(void) visitMax:(id<ORMax>)c  {}
-(void) visitAbs: (id<ORAbs>)c  {}
-(void) visitOr: (id<OROr>)c  {}
-(void) visitAnd:( id<ORAnd>)c  {}
-(void) visitImply: (id<ORImply>)c  {}
-(void) visitElementCst: (id<ORElementCst>)c  {}
-(void) visitElementVar: (id<ORElementVar>)c  {}
-(void) visitFloatElementCst: (id<ORFloatElementCst>) cstr {}
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
-(void) visitMutableFloatI: (id<ORMutableFloat>) e {}
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
-(void) visitExprSquareI:(id<ORExpr>) e  {}
-(void) visitExprModI:(id<ORExpr>)e   {}
-(void) visitExprMinI: (id<ORExpr>) e {}
-(void) visitExprMaxI: (id<ORExpr>) e {}
-(void) visitExprNegateI:(id<ORExpr>) e  {}
-(void) visitExprCstSubI: (id<ORExpr>) e  {}
-(void) visitExprCstFloatSubI:(id<ORExpr>)e {}
-(void) visitExprDisjunctI:(id<ORExpr>) e  {}
-(void) visitExprConjunctI: (id<ORExpr>) e  {}
-(void) visitExprImplyI: (id<ORExpr>) e  {}
-(void) visitExprAggOrI: (id<ORExpr>) e  {}
-(void) visitExprAggAndI: (id<ORExpr>) e  {}
-(void) visitExprAggMinI: (id<ORExpr>) e  {}
-(void) visitExprAggMaxI: (id<ORExpr>) e  {}
-(void) visitExprVarSubI: (id<ORExpr>) e  {}
@end

@implementation ORFlatten {
   NSMapTable* _mapping;
}
-(id)initORFlatten:(id<ORAddToModel>) into
{
   self = [super init];
   _into = into;
   _mapping = [[NSMapTable alloc] initWithKeyOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                        valueOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                            capacity:64];
   return self;
}
-(void)dealloc
{
   [_mapping release];
   [super dealloc];
}
-(id<ORAddToModel>)target
{
   return _into;
}
-(id)flattenIt:(id)obj
{
   if (obj==nil) return obj;
   id fo = [_mapping objectForKey:obj];
   if (fo)
      return fo;
   else {
      id pr = _result;  // flattenIt must work if reentrant.
      _result = NULL;
      [obj visit:self];
      id rv = _result;
      _result = pr;     // restore what used to be result.
      if (rv == NULL)
         [_mapping setObject:[NSNull null] forKey:obj];
      else
         [_mapping setObject:rv forKey:obj];
      return rv;
   }
}
-(void)apply:(id<ORModel>)m
{
   [m applyOnVar: ^(id<ORVar> x) {
      [_into addVariable: [self flattenIt:x]];
   }
   onMutables: ^(id<ORObject> x) {
      [_into addMutable:x];
   }
   onImmutables: ^(id<ORObject> x) {
      [_into addImmutable:x];
   }
   onConstraints: ^(id<ORConstraint> c) {
      [_into addConstraint:[self flattenIt:c]];
   }
   onObjective: ^(id<ORObjectiveFunction> o) {
      [self flattenIt:o];
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
   id<ORIntRange> S = [[cstr automaton] states];
   id<ORIntRange> R = [[cstr array] range];
   id<ORIntRange> E = [ORFactory intRange:_into low:R.low up:R.up+1];
   id<ORTable>    T = [[cstr automaton] transition];
   id<ORIntSet>   F = [[cstr automaton] final];
   id<ORIntVarArray> x = [cstr array];
   id<ORIntVarArray> q = [ORFactory intVarArray:_into range:E domain:S];
   [_into addConstraint:[ORFactory equalc:_into var:q[R.low] to:S.low]];
   for(ORInt k=R.low;k <= R.up;k++)
      [_into addConstraint:[ORFactory tableConstraint:T on:q[k] :x[k] :q[k+1]]];
   [S enumerateWithBlock:^(ORInt s) {
      if (![F member:s])
         [_into addConstraint:[ORFactory notEqualc:_into var:q[R.up+1] to:s]];
   }];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   _result = cstr;
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   id<ORIntVarArray> item     = [self flattenIt:[cstr item]];
   id<ORIntVarArray> binSize  = [self flattenIt:[cstr binSize]];
   id<ORIntArray>    itemSize = [self flattenIt:[cstr itemSize]];
   id<ORIntRange> BR = [binSize range];
   id<ORIntRange> IR = [item range];
   id<ORTracker> t = [_into tracker];
   ORInt brlow = [BR low];
   ORInt brup = [BR up];
   for(ORInt b = brlow; b <= brup; b++) /*note:RangeConsistency*/
      [ORFlatten flattenExpression: [Sum(t,i,IR,[[item[i] eq: @(b) track:t] mul:@([itemSize at:i]) track:t]) eq: binSize[b]]
                              into: _into
                        annotation: DomainConsistency];
   ORInt s = 0;
   ORInt irlow = [IR low];
   ORInt irup = [IR up];
   for(ORInt i = irlow; i <= irup; i++)
      s += [itemSize at:i];
   [ORFlatten flattenExpression: [Sum(t,b,BR,binSize[b]) eq: @(s)]
                           into: _into
                     annotation: DomainConsistency];
   
   for(ORInt b = brlow; b <= brup; b++)
      [_into addConstraint: [ORFactory packOne:t item:item itemSize: itemSize bin: b binSize: binSize[b]]];
}
-(void) visitGroup:(id<ORGroup>)g
{
   id<ORGroup> ng = [ORFactory group:[_into tracker] type:[g type]];
   id<ORAddToModel> a2g = [[ORBatchGroup alloc] init:(id)[_into tracker] group:ng];
   [g enumerateObjectWithBlock:^(id<ORConstraint> ck) {
      [ORFlatten flatten:ck into:a2g];
   }];
   [a2g release];
   _result = ng;
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
   [ORFlatten flattenExpression:[cstr expr] into:_into annotation:[cstr annotation]];
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
-(void) visitNEqual: (id<ORNEqual>)c
{
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

void loopOverMatrix(id<ORIntVarMatrix> m,ORInt d,ORInt arity,id<ORTable> t,ORInt* idx)
{
   if (d == arity) {
      idx[arity]++;
      [t insertTuple:idx];
   } else {
      [[m range:d] enumerateWithBlock:^(ORInt k) {
         idx[d] = k;
         loopOverMatrix(m, d+1, arity, t, idx);
      }];
   }
}
-(void) visitElementMatrixVar:(id<ORElementMatrixVar>)c
{
   id<ORIntVarMatrix> m = [self flattenIt:[c matrix]];
   id<ORIntVar> idx0    = [self flattenIt:[c index0]];
   id<ORIntVar> idx1    = [self flattenIt:[c index1]];
   id<ORIntVar> res     = [self flattenIt:[c res]];
   NSUInteger cnt = [m count];
   id<ORTracker> t = [_into tracker];
   id<ORIntRange> fr = [ORFactory intRange:t low:0 up:(ORInt)cnt-1];
   id<ORIntVarArray> f = (id)[ORFactory idArray:t range:fr with:^id(ORInt i) {
      return [m flat:i];
   }];
   id<ORTable> table = [ORFactory table:t arity:[m arity]+1];
   ORInt k = [m arity]+1;
   ORInt idx[k];
   idx[k-1] = 0;
   loopOverMatrix(m,0,[m arity],table,idx);
   table = [t memoize:table];
   id<ORIntVar> alpha = [ORFactory intVar:t domain:fr];
   [ORFactory tableConstraint:table on:idx0 :idx1 :alpha];
   _result = [ORFactory element:t var:alpha idxVarArray:f equal:res annotation:DomainConsistency];
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
   ORIntLinear* terms = [ORNormalizer intLinearFrom: [e expr] model: _into annotation: Default];
   id<ORIntVar> alpha = [ORNormalizer intVarIn:terms for:_into annotation:Default];
   _result = [_into minimizeVar: alpha];
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   ORIntLinear* terms = [ORNormalizer intLinearFrom: [e expr] model: _into annotation: Default];
   id<ORIntVar> alpha = [ORNormalizer intVarIn:terms for:_into annotation:Default];
   _result = [_into maximizeVar: alpha];
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   id<ORIntVarArray> ca = [self flattenIt:[v array]];
   id<ORFloatArray>  cc = [self flattenIt:[v coef]];
   _result = [_into minimize:ca coef:cc];
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   id<ORIntVarArray> ca = [self flattenIt:[v array]];
   id<ORFloatArray>  cc = [self flattenIt:[v coef]];
   _result = [_into maximize:ca coef:cc];
}

// ====================================================================================================================


+(void)flatten:(id<ORConstraint>)c into:(id<ORAddToModel>)m
{
   ORFlatten* flattener  = [[ORFlatten alloc] initORFlatten:m];
   [c visit:flattener];
   [flattener release];
}

+(id<ORConstraint>) flattenExpression:(id<ORExpr>)expr into:(id<ORAddToModel>)model annotation:(ORAnnotation)note
{
   id<ORConstraint> rv = NULL;
   id<ORLinear> terms = [ORNormalizer normalize:expr into: model annotation:note];
   switch ([expr type]) {
      case ORRBad: assert(NO);
      case ORREq: rv = [terms postEQZ:model annotation:note];break;
      case ORRNEq:rv = [terms postNEQZ:model annotation:note];break;
      case ORRLEq:rv = [terms postLEQZ:model annotation:note];break;
      case ORRDisj:rv = [terms postDISJ:model annotation:note];break;
      default:
         assert(terms == nil);
         break;
   }
   [terms release];
   return rv;
}
@end


