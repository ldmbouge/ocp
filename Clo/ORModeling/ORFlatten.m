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
#import "ORVarI.h"
#import "ORSetI.h"
#import <ORFoundation/ORArrayI.h>

@implementation ORNOopVisit
-(void) visitRandomStream:(id) v {}
-(void) visitZeroOneStream:(id) v {}
-(void) visitUniformDistribution:(id) v{}
-(void) visitIntSet:(id<ORIntSet>)v{}
-(void) visitIntRange:(id<ORIntRange>)v{}
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
-(void) visitExprModI:(id<ORExpr>)e   {}
-(void) visitExprNegateI:(id<ORExpr>) e  {}
-(void) visitExprCstSubI: (id<ORExpr>) e  {}
-(void) visitExprDisjunctI:(id<ORExpr>) e  {}
-(void) visitExprConjunctI: (id<ORExpr>) e  {}
-(void) visitExprImplyI: (id<ORExpr>) e  {}
-(void) visitExprAggOrI: (id<ORExpr>) e  {}
-(void) visitExprVarSubI: (id<ORExpr>) e  {}
@end

@implementation ORFlatten {
   id<ORAddToModel>   _into;
   id               _result;
   NSMapTable*         _map;
}
-(id)initORFlatten:(id<ORAddToModel>) into
{
   self = [super init];
   _into = into;
   _map  = [[NSMapTable alloc] initWithKeyOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                     valueOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                         capacity:32];
   return self;
}
-(void)dealloc
{
   [_map release];
   [super dealloc];
}
-(id)copyOnce:(id)obj
{
   id copy = [_map objectForKey:obj];
   if (copy) {
      return copy;
   } else {
      _result = NULL;
      [obj visit:self];
      [_map setObject:_result forKey:obj];
      return _result;
   }
}
-(void) visitIntVar: (ORIntVarI*) v
{
   id<ORIntRange> cd = [self copyOnce:[v domain]];
   _result = [[ORIntVarI alloc] initORIntVarI:_into domain:cd];
   [v setImpl:_result];
}
-(void) visitBitVar: (ORBitVarI*) v
{
   _result = [[ORBitVarI alloc] initORBitVarI:_into low:[v low] up:[v up] bitLength:[v bitLength]];
   [v setImpl:_result];
}
-(void) visitFloatVar: (ORFloatVarI*) v
{
   _result = [[ORFloatVarI alloc] initORFloatVarI:_into low:[v min] up:[v max]];
   [v setImpl:_result];
}
-(void) visitIntVarLitEQView:(ORIntVarLitEQView*)v
{
   id<ORIntVar> bc = [self copyOnce:[v base]];
   _result = [[ORIntVarLitEQView alloc] initORIntVarLitEQView:_into var:bc eqi:[v literal]];
   [v setImpl:_result];
}
-(void) visitAffineVar:(ORIntVarAffineI*) v
{
   id<ORIntVar> vc = [self copyOnce:[v base]];
   _result = [[ORIntVarAffineI alloc] initORIntVarAffineI:_into var:vc scale:[v scale] shift:[v shift]];
   [v setImpl:_result];
}

// ======================================================================================================

-(void) visitIntArray:(id<ORIntArray>)v
{
   id<ORIntRange> cr = [self copyOnce:[v range]];
   _result = [ORFactory intArray:_into range:cr with:^ORInt(ORInt i) {
      return [v at:i];
   }];
}
-(void) visitFloatArray:(id<ORFloatArray>)v
{
   id<ORIntRange> cr = [self copyOnce:[v range]];
   _result = [ORFactory floatArray:_into range:cr with:^ORFloat(ORInt i) {
      return [v at:i];
   }];
}
-(void) visitIntMatrix:(id<ORIntMatrix>)v
{
   _result = [ORFactory intMatrix:_into with:v];
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
   _result = v;
}
-(void) visitIntSet:(id<ORIntSet>)v
{
   id<ORIntSet> o = [ORFactory intSet:_into];
   [v enumerateWithBlock:^(ORInt i) {
      [o insert: i];
   }];
   _result = o;
}
-(void) visitIntRange:(id<ORIntRange>)v
{
   _result = [[ORIntRangeI alloc] initORIntRangeI: [v low] up: [v up]];
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   id<ORIntRange> cr = [self copyOnce:[v range]];
   id<ORIdArray> ca = [ORFactory idArray:_into range:cr];
   [v enumerateWith:^(id obj, int idx) {
      ca[idx] = [self copyOnce:obj];
   }];
   _result = ca;
}

void copyRec(ORFlatten* f,ORInt acc,ORInt d,ORInt arity,id<ORIntRange>* ranges,id<ORIdMatrix> src,id<ORIdMatrix> dst)
{
   if (d >= arity) {
      id cv = [f copyOnce:[src flat:acc]];
      [dst setFlat:cv at:acc];
   } else {
      ORInt low = [ranges[d] low];
      ORInt sz  = (d+1 < arity) ? [ranges[d+1] size] : 1;
      [ranges[d] enumerateWithBlock:^(ORInt i) {
         ORInt next = (acc + (i - low)) * sz;
         copyRec(f,next,d+1,arity,ranges,src,dst);
      }];
   }
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   ORInt arity = [v arity];
   id<ORIntRange>* arc = alloca(sizeof(id<ORIntRange>)*arity);
   for(ORInt i=0;i<arity;i++)
      arc[i] = [self copyOnce:[v range:i]];
   id<ORIdMatrix> o = [ORFactory idMatrix:_into arity:arity ranges:arc];
   copyRec(self,0,0,arity,arc,v,o);
   _result = o;
}
-(void) visitTable:(id<ORTable>) v
{
   _result = [ORFactory table:_into with:v];
}

// ======================================================================================================

-(void) visitRestrict:(id<ORRestrict>)cstr
{
   id<ORIntVar> cv = [self copyOnce:[cstr var]];
   id<ORIntSet> cs = [self copyOnce:[cstr restriction]];
   _result = [ORFactory restrict:_into var:cv to:cs];
   [_into addConstraint:_result];
   [cstr setImpl:_result];
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   id<ORIntVarArray> ca = [self copyOnce:[cstr array]];
   _result = [ORFactory alldifferent:ca annotation:[cstr annotation]];
   [_into addConstraint:_result];
   [cstr setImpl:_result];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   id<ORIntVarArray> ca = [self copyOnce:[cstr array]];
   id<ORIntArray> low = [self copyOnce:[cstr low]];
   id<ORIntArray> up  = [self copyOnce:[cstr up]];
   _result = [ORFactory cardinality:ca low:low up:up annotation:[cstr annotation]];
   [_into addConstraint:_result];
   [cstr setImpl:_result];
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   id<ORIntVarArray> item     = [self copyOnce:[cstr item]];
   id<ORIntVarArray> binSize  = [self copyOnce:[cstr binSize]];
   id<ORIntArray>    itemSize = [cstr itemSize];
   id<ORIntRange> BR = [binSize range];
   id<ORIntRange> IR = [item range];
   id<ORTracker> tracker = [item tracker];
   ORInt brlow = [BR low];
   ORInt brup = [BR up];
   for(ORInt b = brlow; b <= brup; b++) /*note:RangeConsistency*/
      [ORFlatten flattenExpression: [Sum(tracker,i,IR,mult(@([itemSize at:i]),[item[i] eq: @(b)])) eq: binSize[b]]
                              into: _into
                        annotation: DomainConsistency];
   ORInt s = 0;
   ORInt irlow = [IR low];
   ORInt irup = [IR up];
   for(ORInt i = irlow; i <= irup; i++)
      s += [itemSize at:i];
   [ORFlatten flattenExpression: [Sum(tracker,b,BR,binSize[b]) eq: @(s)]
                           into: _into
                     annotation: DomainConsistency];
   
   for(ORInt b = brlow; b <= brup; b++)
      [_into addConstraint: [ORFactory packOne: item itemSize: itemSize bin: b binSize: binSize[b]]];
}
-(void) visitGroup:(id<ORGroup>)g
{
   id<ORGroup> ng = [ORFactory group:_into type:[g type]];
   id<ORAddToModel> a2g = [[ORBatchGroup alloc] init:_into group:ng];
   [g enumerateObjectWithBlock:^(id<ORConstraint> ck) {
      [ORFlatten flatten:ck into:a2g];
   }];
   [_into addConstraint:ng];
   [a2g release];
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   id<ORIntVarArray> ci = [self copyOnce:[cstr item]];
   id<ORIntArray>    cw = [self copyOnce:[cstr weight]];
   id<ORIntVar>      cc = [self copyOnce:[cstr capacity]];
   _result = [ORFactory knapsack:ci weight:cw capacity:cc];
   [_into addConstraint:_result];
   [cstr setImpl:_result];
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   id<ORIntVarArray> cx = [self copyOnce:[cstr x]];
   id<ORIntMatrix>   cm = [self copyOnce:[cstr matrix]];
   id<ORIntVar>      cc = [self copyOnce:[cstr cost]];
   _result = [ORFactory assignment:cx matrix:cm cost:cc];
   [_into addConstraint:_result];
   [cstr setImpl:_result];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   [ORFlatten flattenExpression:[cstr expr] into:_into annotation:[cstr annotation]];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   id<ORIntVarArray> ca = [self copyOnce:[cstr array]];
   id<ORTable>       ct = [self copyOnce:[cstr table]];
   _result = [ORFactory tableConstraint:ca table:ct];
   [_into addConstraint:_result];
   [cstr setImpl:_result];
}
-(void) visitEqualc: (id<OREqualc>)c
{
   id<ORIntVar> cl = [self copyOnce:[c left]];
   _result = [ORFactory equalc:_into var:cl to:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   id<ORIntVar> cl = [self copyOnce:[c left]];
   _result = [ORFactory notEqualc:_into var:cl to:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   id<ORIntVar> cl = [self copyOnce:[c left]];
   _result = [ORFactory  lEqualc:_into var:cl to:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   id<ORIntVar> cl = [self copyOnce:[c left]];
   _result = [ORFactory gEqualc:_into var:cl to:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitEqual: (id<OREqual>)c
{
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory equal:_into var:cl to:cr plus:[c cst] annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitAffine: (id<ORAffine>)c
{
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory model:_into var:cl equal:[c coef] times:cr plus:[c cst] annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory notEqual:_into var:cl to:cr plus:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory lEqual:_into var:cl to:cr plus:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitPlus: (id<ORPlus>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory equal3:_into var:co to:cl plus:cr annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitMult: (id<ORMult>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory mult:_into var:cl by:cr equal:co annotation:Default];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitSquare:(id<ORSquare>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> ci = [self copyOnce:[c op]];
   _result = [ORFactory square:_into var:ci equal:co annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitMod: (id<ORMod>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory mod:_into var:cl mod:cr equal:co];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitModc: (id<ORModc>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> cl = [self copyOnce:[c left]];
   _result = [ORFactory mod:_into var:cl modi:[c right] equal:co annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitAbs: (id<ORAbs>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> cl = [self copyOnce:[c left]];
   _result = [ORFactory abs:_into var:cl equal:co annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitOr: (id<OROr>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory model:_into boolean:cl or:cr equal:co];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitAnd:( id<ORAnd>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory model:_into boolean:cl and:cr equal:co];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitImply: (id<ORImply>)c
{
   id<ORIntVar> co = [self copyOnce:[c res]];
   id<ORIntVar> cl = [self copyOnce:[c left]];
   id<ORIntVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory model:_into boolean:cl imply:cr equal:co];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   id<ORIntArray> ca = [self copyOnce:[c array]];
   id<ORIntVar>   ci = [self copyOnce:[c idx]];
   id<ORIntVar>   co = [self copyOnce:[c res]];
   _result = [ORFactory element:_into var:ci idxCstArray:ca equal:co annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   id<ORIntVarArray> ca = [self copyOnce:[c array]];
   id<ORIntVar>      ci = [self copyOnce:[c idx]];
   id<ORIntVar>      co = [self copyOnce:[c res]];
   _result = [ORFactory element:_into var:ci idxVarArray:ca equal:co annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitCircuit:(id<ORCircuit>) c
{
   id<ORIntVarArray> ca = [self copyOnce:[c array]];
   _result = [ORFactory circuit:ca];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitNoCycle:(id<ORNoCycle>) c
{
   id<ORIntVarArray> ca = [self copyOnce:[c array]];
   _result = [ORFactory nocycle:ca];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitLexLeq:(id<ORLexLeq>) c
{
   id<ORIntVarArray> cx = [self copyOnce:[c x]];
   id<ORIntVarArray> cy = [self copyOnce:[c y]];
   _result = [ORFactory lex:cx leq:cy];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>)c
{
   id<ORIntVar> cb = [self copyOnce:[c b]];
   id<ORIntVar> cx = [self copyOnce:[c x]];
   _result = [ORFactory reify:_into boolean:cb with:cx eqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitReifyEqual: (id<ORReifyEqual>)c
{
   id<ORIntVar> cb = [self copyOnce:[c b]];
   id<ORIntVar> cx = [self copyOnce:[c x]];
   id<ORIntVar> cy = [self copyOnce:[c y]];
   _result = [ORFactory reify:_into boolean:cb with:cx eq:cy annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>)c
{
   id<ORIntVar> cb = [self copyOnce:[c b]];
   id<ORIntVar> cx = [self copyOnce:[c x]];
   _result = [ORFactory reify:_into boolean:cb with:cx neqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>)c
{
   id<ORIntVar> cb = [self copyOnce:[c b]];
   id<ORIntVar> cx = [self copyOnce:[c x]];
   id<ORIntVar> cy = [self copyOnce:[c y]];
   _result = [ORFactory reify:_into boolean:cb with:cx neq:cy annotation:[c annotation]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>)c
{
   id<ORIntVar> cb = [self copyOnce:[c b]];
   id<ORIntVar> cx = [self copyOnce:[c x]];
   _result = [ORFactory reify:_into boolean:cb with:cx leqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>)c
{
   id<ORIntVar> cb = [self copyOnce:[c b]];
   id<ORIntVar> cx = [self copyOnce:[c x]];
   id<ORIntVar> cy = [self copyOnce:[c y]];
   _result = [ORFactory reify:_into boolean:cb  with:cx leq:cy];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>)c
{
   id<ORIntVar> cb = [self copyOnce:[c b]];
   id<ORIntVar> cx = [self copyOnce:[c x]];
   _result = [ORFactory reify:_into boolean:cb with:cx geqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>)c
{
   id<ORIntVar> cb = [self copyOnce:[c b]];
   id<ORIntVar> cx = [self copyOnce:[c x]];
   id<ORIntVar> cy = [self copyOnce:[c y]];
   _result = [ORFactory reify:_into boolean:cb with:cy leq:cx];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   id<ORIntVarArray> ca = [self copyOnce:[c vars]];
   _result = [ORFactory sumbool:_into array:ca eqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>)c
{
   id<ORIntVarArray> ca = [self copyOnce:[c vars]];
   _result = [ORFactory sumbool:_into array:ca leqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>)c
{
   id<ORIntVarArray> ca = [self copyOnce:[c vars]];
   _result = [ORFactory sumbool:_into array:ca geqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitSumEqualc:(id<ORSumEqc>)c
{
   id<ORIntVarArray> ca = [self copyOnce:[c vars]];
   _result = [ORFactory sum:_into array:ca eqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitSumLEqualc:(id<ORSumLEqc>)c
{
   id<ORIntVarArray> ca = [self copyOnce:[c vars]];
   _result = [ORFactory sum:_into array:ca leqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitSumGEqualc:(id<ORSumGEqc>)c
{
   id<ORIntVarArray> ca = [self copyOnce:[c vars]];
   _result = [ORFactory sum:_into array:ca geqi:[c cst]];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
// Bit
-(void) visitBitEqual:(id<ORBitEqual>)c
{
   id<ORBitVar> cl = [self copyOnce:[c left]];
   id<ORBitVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory bit:cl eq:cr];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitBitOr:(id<ORBitOr>)c
{
   id<ORBitVar> cl = [self copyOnce:[c left]];
   id<ORBitVar> cr = [self copyOnce:[c right]];
   id<ORBitVar> co = [self copyOnce:[c res]];
   _result = [ORFactory bit:cl or:cr eq:co];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitBitAnd:(id<ORBitAnd>)c
{
   id<ORBitVar> cl = [self copyOnce:[c left]];
   id<ORBitVar> cr = [self copyOnce:[c right]];
   id<ORBitVar> co = [self copyOnce:[c res]];
   _result = [ORFactory bit:cl and:cr eq:co];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitBitNot:(id<ORBitNot>)c
{
   id<ORBitVar> cr = [self copyOnce:[c right]];
   id<ORBitVar> cl = [self copyOnce:[c left]];
   _result = [ORFactory bit:cr not:cl];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitBitXor:(id<ORBitXor>)c
{
   id<ORBitVar> cl = [self copyOnce:[c left]];
   id<ORBitVar> cr = [self copyOnce:[c right]];
   id<ORBitVar> co = [self copyOnce:[c res]];
   _result = [ORFactory bit:cl xor:cr eq:co];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitBitShiftL:(id<ORBitShiftL>)c
{
   id<ORBitVar> cl = [self copyOnce:[c left]];
   id<ORBitVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory bit:cl shiftLBy:[c places] eq:cr];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitBitRotateL:(id<ORBitRotateL>)c
{
   id<ORBitVar> cl = [self copyOnce:[c left]];
   id<ORBitVar> cr = [self copyOnce:[c right]];
   _result = [ORFactory bit:cl rotateLBy:[c places] eq:cr];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitBitSum:(id<ORBitSum>)c
{
   id<ORBitVar> cl = [self copyOnce:[c left]];
   id<ORBitVar> cr = [self copyOnce:[c right]];
   id<ORBitVar> cin  = [self copyOnce:[c in]];
   id<ORBitVar> cout = [self copyOnce:[c out]];
   id<ORBitVar> res  = [self copyOnce:[c res]];
   _result = [ORFactory bit:cl plus:cr withCarryIn:cin eq:res withCarryOut:cout];
   [_into addConstraint:_result];
   [c setImpl:_result];
}
-(void) visitBitIf:(id<ORBitIf>)c
{
   id<ORBitVar> res = [self copyOnce:[c res]];
   id<ORBitVar> tif = [self copyOnce:[c trueIf]];
   id<ORBitVar> eq  = [self copyOnce:[c equals]];
   id<ORBitVar> z   = [self copyOnce:[c zeroIfXEquals]];
   _result = [ORFactory bit:res trueIf:tif equals:eq zeroIfXEquals:z];
   [_into addConstraint:_result];
   [c setImpl:_result];
}

// Flattening of constraints ============================================================================

-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   id<ORIntVar> x = [self copyOnce:[v var]];
   _result = [_into minimizeVar:x];
   [v setImpl:_result];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   id<ORIntVar> x = [self copyOnce:[v var]];
   _result = [_into maximizeVar:x];
   [v setImpl:_result];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   ORLinear* terms = [ORLinearizer linearFrom: [e expr] model: _into annotation: Default];
   id<ORIntVar> alpha = [ORSubst normSide:terms for:_into annotation:Default];
   id<ORObjectiveFunction> objective = [_into minimizeVar: alpha];
   [e setImpl: objective];
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   ORLinear* terms = [ORLinearizer linearFrom: [e expr] model: _into annotation: Default];
   id<ORIntVar> alpha = [ORSubst normSide:terms for:_into annotation:Default];
   id<ORObjectiveFunction> objective = [_into maximizeVar: alpha];
   [e setImpl: objective];
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   id<ORIntVarArray> ca = [self copyOnce:[v array]];
   id<ORFloatArray>  cc = [self copyOnce:[v coef]];
   _result = [_into minimize:ca coef:cc];
   [v setImpl:_result];
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   id<ORIntVarArray> ca = [self copyOnce:[v array]];
   id<ORFloatArray>  cc = [self copyOnce:[v coef]];
   _result = [_into maximize:ca coef:cc];
   [v setImpl:_result];
}

// ====================================================================================================================

-(void)apply:(id<ORModel>)m
{
   [m applyOnVar:^(id<ORVar> x) {
      [self copyOnce:x];
   } onObjects:^(id<ORObject> x) {
      [self copyOnce:x];
   } onConstraints:^(id<ORConstraint> c) {
      [self copyOnce:c];
   } onObjective:^(id<ORObjectiveFunction> o) {
      [self copyOnce:o];
   }];
}

+(void)flatten:(id<ORConstraint>)c into:(id<ORAddToModel>)m
{
   ORFlatten* flattener  = [[ORFlatten alloc] initORFlatten:m];
   [c visit:flattener];
   [flattener release];
}

+(void) flattenExpression:(id<ORExpr>)expr into:(id<ORAddToModel>)model annotation:(ORAnnotation)note
{
   ORLinear* terms = [ORNormalizer normalize:expr into: model annotation:note];
   switch ([expr type]) {
      case ORRBad: assert(NO);
      case ORREq: {
         if ([terms size] != 0) {
            [terms postEQZ:model annotation:note];
         }
      }break;
      case ORRNEq: {
         [terms postNEQZ:model annotation:note];
      }break;
      case ORRLEq: {
         [terms postLEQZ:model annotation:note];
      }break;
      default:
         assert(terms == nil);
         break;
   }
   [terms release];
}
@end

