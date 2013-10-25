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


@implementation ORFlatten {
   NSMapTable* _mapping;
}
-(id)initORFlatten:(id<ORAddToModel>) into
{
   self = [super init];
   _into = into;
   _fresh = nil;
   _mapping = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaqueMemory
                                        valueOptions:NSPointerFunctionsOpaqueMemory
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
-(void)apply:(id<ORModel>)m with:(id<ORAnnotation>)notes
{
   _fresh = notes;
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
      [self flattenIt:c];
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
   _result = [_into addConstraint:cstr];
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   _result = [_into addConstraint:cstr];
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
      [_into addConstraint:[ORFactory tableConstraint:_into table:T on:q[k] :x[k] :q[k+1]]];
   [S enumerateWithBlock:^(ORInt s) {
      if (![F member:s])
         [_into addConstraint:[ORFactory notEqualc:_into var:q[R.up+1] to:s]];
   }];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   _result = [_into addConstraint:cstr];
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
   [_into setCurrent:cstr];
   for(ORInt b = brlow; b <= brup; b++) { /*note:RangeConsistency*/
      [ORFlatten flattenExpression: [Sum(t,i,IR,[[item[i] eq: @(b) track:t] mul:@([itemSize at:i]) track:t]) eq: binSize[b]]
                              into: _into];
   }
   ORInt s = 0;
   ORInt irlow = [IR low];
   ORInt irup = [IR up];
   for(ORInt i = irlow; i <= irup; i++)
      s += [itemSize at:i];
   [ORFlatten flattenExpression: [Sum(t,b,BR,binSize[b]) eq: @(s)]
                           into: _into];
   
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
   _result = [_into addConstraint:ng];
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   _result = [_into addConstraint:cstr];
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   _result = [_into addConstraint:cstr];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   [_into setCurrent:cstr];
   [ORFlatten flattenExpression:[cstr expr] into:_into];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   _result = [_into addConstraint:cstr];
}
-(void) visitFloatEqualc: (id<ORFloatEqualc>)cstr
{
   _result = [_into addConstraint:cstr];
}
-(void) visitEqualc: (id<OREqualc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitEqual: (id<OREqual>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitAffine: (id<ORAffine>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitPlus: (id<ORPlus>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitMult: (id<ORMult>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitSquare:(id<ORSquare>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitFloatSquare:(id<ORSquare>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitMod: (id<ORMod>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitModc: (id<ORModc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitMin:(id<ORMin>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitMax:(id<ORMax>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitAbs: (id<ORAbs>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitOr: (id<OROr>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitAnd:( id<ORAnd>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitImply: (id<ORImply>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitFloatElementCst: (id<ORFloatElementCst>) c
{
   _result = [_into addConstraint:c];
}

static void loopOverMatrix(id<ORIntVarMatrix> m,ORInt d,ORInt arity,id<ORTable> t,ORInt* idx)
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
   [ORFactory tableConstraint:t table:table on:idx0 :idx1 :alpha];
   _result = [ORFactory element:t var:alpha idxVarArray:f equal:res];
   [_into addConstraint:_result];
}
-(void) visitCircuit:(id<ORCircuit>) c
{
   _result = [_into addConstraint:c];
}
-(void) visitNoCycle:(id<ORNoCycle>) c
{
   _result = [_into addConstraint:c];
}
-(void) visitLexLeq:(id<ORLexLeq>) c
{
   _result = [_into addConstraint:c];
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   _result = [_into addConstraint:c];
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitSumEqualc:(id<ORSumEqc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c
{
   _result = [_into addConstraint:c];
}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   _result = [_into addConstraint:c];
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   _result = [_into addConstraint:c];
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
   switch ([e expr].vtype) {
      case ORTInt: {
         ORIntLinear* terms = [ORNormalizer intLinearFrom: [e expr] model: _into];
         id<ORIntVar> alpha = [ORNormalizer intVarIn:terms for:_into];
         _result = [_into minimizeVar: alpha];
      }break;
      case ORTFloat: {
         ORFloatLinear* terms = [ORNormalizer floatLinearFrom: [e expr] model: _into];
         id<ORFloatVar> alpha = [ORNormalizer floatVarIn:terms for:_into];
         _result = [_into minimizeVar:alpha];
      }break;
      default:
         break;
   }
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   switch ([e expr].vtype) {
      case ORTInt: {
         ORIntLinear* terms = [ORNormalizer intLinearFrom: [e expr] model: _into];
         id<ORIntVar> alpha = [ORNormalizer intVarIn:terms for:_into];
         _result = [_into maximizeVar: alpha];
      }break;
      case ORTFloat:{
         ORFloatLinear* terms = [ORNormalizer floatLinearFrom: [e expr] model: _into];
         id<ORFloatVar> alpha = [ORNormalizer floatVarIn:terms for:_into];
         _result = [_into maximizeVar:alpha];
      }break;
      default: break;
   }
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   id<ORIntVarArray> ca = [self flattenIt:[v array]];
   id<ORFloatArray>  cc = [self flattenIt:[v coef]];
   _result = [_into minimize:ca coef:cc independent:0.0];
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   id<ORIntVarArray> ca = [self flattenIt:[v array]];
   id<ORFloatArray>  cc = [self flattenIt:[v coef]];
   _result = [_into maximize:ca coef:cc independent:0.0];
}

// ====================================================================================================================


+(void)flatten:(id<ORConstraint>)c into:(id<ORAddToModel>)m
{
   ORFlatten* flattener  = [[ORFlatten alloc] initORFlatten:m];
   [c visit:flattener];
   [flattener release];
}

+(id<ORConstraint>) flattenExpression:(id<ORExpr>)expr into:(id<ORAddToModel>)model
{
   id<ORConstraint> rv = NULL;
   id<ORLinear> terms = [ORNormalizer normalize:expr into: model];
   switch ([expr type]) {
      case ORRBad: assert(NO);
      case ORREq: rv = [terms postEQZ:model affineOk:YES];break;
      case ORRNEq:rv = [terms postNEQZ:model affineOk:YES];break;
      case ORRLEq:rv = [terms postLEQZ:model affineOk:YES];break;
      case ORRGEq:rv = [terms postGEQZ:model affineOk:YES];break;
      case ORRDisj:rv = [terms postDISJ:model affineOk:YES];break;
      default:
         assert(terms == nil);
         break;
   }
   [terms release];
   return rv;
}
@end


