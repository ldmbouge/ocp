/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFoundation.h>
#import "ORFactory.h"
#import "ORError.h"
#import "ORExprI.h"
#import "ORData.h"
#import "ORDataI.h"
#import "ORArrayI.h"
#import "ORSetI.h"
#import "ORModel.h"
#import "ORModelI.h"
#import "ORTrailI.h" 
#import "ORSelectorI.h" 
#import "ORVarI.h"

@implementation ORFactory
+(void) shutdown
{
   [NSCont shutdown];
}
+(id<ORTrail>) trail
{
   return [[ORTrailI alloc] init];
}

+(id<ORInteger>) integer: (id<ORTracker>)tracker value: (ORInt) value
{
   ORIntegerI* o = [[ORIntegerI alloc] initORIntegerI: tracker value:value];
   [tracker trackObject: o];
   return o;
}
+(id<ORTrailableInt>) trailableInt: (id<OREngine>) engine value: (ORInt) value
{
   ORTrailableIntI* o = [[ORTrailableIntI alloc] initORTrailableIntI: [engine trail] value:value];
   [engine trackObject: o];
   return o;
}
+(id<ORIntSet>)  intSet: (id<ORTracker>) tracker
{
   ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI];
   [tracker trackObject: o];
   return o;
}
+(id<ORIntRange>)  intRange: (id<ORTracker>) tracker low: (ORInt) low up: (ORInt) up
{
   ORIntRangeI* o = [[ORIntRangeI alloc] initORIntRangeI: low up: up];
   [tracker trackObject: o];
   return o;
}
+(id<ORIntRange>)  undefinedIntRange {
    ORIntRangeI* o = [[ORIntRangeI alloc] initORIntRangeI: MAXINT up: MININT];
    return o;
}
+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORInt) value
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range:range value: (ORInt) value];
   [tracker trackObject: o];
   return o;
}

+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range:range with:clo];
   [tracker trackObject: o];
   return o;
}

+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range: r1 range: r2 with:clo];    
   [tracker trackObject: o];
   return o;
}
+(id<ORIdArray>) idArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   ORIdArrayI* o = [[ORIdArrayI alloc] initORIdArray:tracker range:range];
   [tracker trackObject:o];
   return o;
}
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix:tracker range:r0 :r1];
   [tracker trackObject:o];
   return o;
}
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix:tracker range:r0 :r1 :r2];
   [tracker trackObject:o];
   return o;
}
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   ORIntMatrixI* o = [[ORIntMatrixI alloc] initORIntMatrix: tracker range: r1 : r2];
   [tracker trackObject: o];
   return o;
}
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker with: (ORIntMatrixI*) m
{
   ORIntMatrixI* o = [[ORIntMatrixI alloc] initORIntMatrix: tracker with: m];
   [tracker trackObject: o];
   return o;
}
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker withDereferenced: (id<ORIntMatrix>) m
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix: tracker withDereferenced: m];
   [tracker trackObject: o];
   return o;
}
+(id<ORIntSetArray>) intSetArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   return (id<ORIntSetArray>)[ORFactory idArray: tracker range: range];
}
+(id<ORIntSet>) collect: (id<ORTracker>) tracker range: (id<ORIntRange>) r suchThat: (ORInt2Bool) f of: (ORInt2Int) e
{
   ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI];
   for(ORInt i = [r low]; i <= [r up]; i++)
      if (f == nil || f(i))
         [o insert: e(i)];
   [tracker trackObject: o];
   return o;
}

+(ORInt) minOver: (id<ORIntRange>) r suchThat: (ORInt2Bool) filter of: (ORInt2Int)e
{
    ORInt m = MAXINT;
    for(ORInt i = [r low]; i <= [r up]; i++) {
        if (filter == nil || filter(i)) {
            ORInt x = e(i);
            if(x < m) m = x;
        }
    }
    return m;
}

+(ORInt) maxOver: (id<ORIntRange>) r suchThat: (ORInt2Bool) filter of: (ORInt2Int)e
{
    ORInt m = MININT;
    for(ORInt i = [r low]; i <= [r up]; i++) {
        if (filter == nil || filter(i)) {
            ORInt x = e(i);
            if(x > m) m = x;
        }
    }
    return m;
}

+(id<IntEnumerator>) intEnumerator: (id<ORTracker>) tracker over: (id<ORIntIterator>) r
{
   id<IntEnumerator> ite = [r enumerator];
   [tracker trackObject: ite];
   return ite;
}
+(id<ORSelect>) select: (id<ORTracker>) tracker range: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order
{
   ORSelectI* o = [[ORSelectI alloc] initORSelectI: range suchThat: filter orderedBy: order randomized: false];
   [tracker trackObject: o];
   return o;
}
+(id<ORSelect>) selectRandom: (id<ORTracker>) tracker range: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order
{
   ORSelectI* o = [[ORSelectI alloc] initORSelectI: range suchThat: filter orderedBy: order randomized: YES];
   [tracker trackObject: o];
   return o;
}
+(id<ORIntVar>) reifyView:(id<ORTracker>)model var:(id<ORIntVar>) x eqi:(ORInt)c
{
   return [[ORIntVarLitEQView alloc] initORIntVarLitEQView:model var:x eqi:c];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) model domain: (id<ORIntRange>) r
{
   return [[ORIntVarI alloc]  initORIntVarI: model domain: r];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x shift: (ORInt) b
{
   return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:1 shift:b];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a
{
   if (a==1)
      return x;
   else
      return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:a shift:0];

   /*if (a==1)
      return x;
   else if (a==-1) {
      return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:a shift:0];
   }
   else {
      ORInt l = a > 0 ? a * [x min] : a * [x max];
      ORInt u = a > 0 ? a * [x max] : a * [x min];
      id<ORIntVar> nv = [ORFactory intVar:tracker domain:RANGE(tracker,l,u)];
      [tracker addConstraint:[ORFactory model:tracker var:nv equal:a times:x plus:0 annotation:DomainConsistency]];
      return nv;
   }*/
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a shift:(ORInt) b
{
   if (a == 1 && b == 0)
      return x;
   else
      return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:a shift:b];
/*
   ORInt l = (a > 0 ? a * [x min] : a * [x max]) + b;
   ORInt u = (a > 0 ? a * [x max] : a * [x min]) + b;
   id<ORIntVar> nv = [ORFactory intVar:tracker domain:RANGE(tracker,l,u)];
   [tracker addConstraint:[ORFactory model:tracker var:nv equal:a times:x plus:b annotation:DomainConsistency]];
   return nv;
 */
}
+(id<ORIntVar>) boolVar: (id<ORTracker>) model
{
   return [[ORIntVarI alloc] initORIntVarI: model domain: RANGE(model,0,1)];
}
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up
{
   return [[ORFloatVarI alloc]  initORFloatVarI: tracker low: low up: up];
}
+(id<ORBitVar>) bitVar:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORUInt)bLen
{
   return [[ORBitVarI alloc] initORBitVarI:tracker low:low up:up bitLength:bLen];
}
+(id<ORBindingArray>) bindingArray: (id<ORTracker>) tracker nb: (ORInt) nb
{
   return [[ORBindingArrayI alloc] initORBindingArray: nb];
}
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: [ORFactory intVar: tracker domain:domain] at:k];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (id<ORIntVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++) {
      o[k] = clo(k);
   }
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArrayDereference: (id<ORTracker>) tracker array: (id<ORIntVarArray>) x
{
   return [ORFactory intVarArray: tracker range: [x range] with: ^id<ORIntVar>(ORInt i) { return (id<ORIntVar>)([x[i] dereference]); }];
}

+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) r1  : (id<ORIntRange>) r2 with: (id<ORIntVar>(^)(ORInt,ORInt)) clo
{
   ORInt nb = ([r1 up] - [r1 low] + 1) * ([r2 up] - [r2 low] + 1);
   id<ORIntRange> fr = [ORFactory intRange: cp low: 0 up: nb-1];
   id<ORIdArray> o = [ORFactory idArray:cp range:fr];
   ORInt k = 0;
   for(ORInt i=[r1 low];i <= [r1 up];i++)
      for(ORInt j= [r2 low];j <= [r2 up];j++)
         [o set:clo(i,j) at:k++];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) r1  : (id<ORIntRange>) r2 : (id<ORIntRange>) r3 with: (id<ORIntVar>(^)(ORInt,ORInt,ORInt)) clo
{
   ORInt nb = ([r1 up] - [r1 low] + 1) * ([r2 up] - [r2 low] + 1) * ([r3 up] - [r3 low] + 1);
   id<ORIntRange> fr = [ORFactory intRange: cp low: 0 up: nb-1];
   id<ORIdArray> o = [ORFactory idArray:cp range:fr];
   ORInt l = 0;
   for(ORInt i= [r1 low] ;i <= [r1 up]; i++)
      for(ORInt j= [r2 low]; j <= [r2 up]; j++)
         for(ORInt k= [r3 low];k <= [r3 up]; k++)
            [o set:clo(i,j,k) at:l++];
   return (id<ORIntVarArray>)o;
}

+(id<ORIntVarArray>) arrayORIntVar: (id<ORTracker>) cp range: (id<ORIntRange>) range with:(id<ORIntVar>(^)(ORInt)) clo
{
   return [self intVarArray:cp range:range with:clo];
}

+(id<ORIntVarArray>) arrayORIntVar: (id<ORTracker>) cp range: (id<ORIntRange>) r1 range: (id<ORIntRange>)r2  with:(id<ORIntVar>(^)(ORInt,ORInt)) clo
{
   return [self intVarArray:cp range:r1 :r2 with:clo];
}

+(id<ORTrailableIntArray>) trailableIntArray: (id<OREngine>) engine range: (id<ORIntRange>) range value: (ORInt) value
{
   id<ORIdArray> o = [ORFactory idArray:engine range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: [ORFactory trailableInt: engine value: value] at:k];
   return (id<ORTrailableIntArray>) o;
}
+(id<ORTRIntArray>) TRIntArray: (id<OREngine>) engine range: (id<ORIntRange>) R
{
   ORTRIntArrayI* o = [[ORTRIntArrayI alloc] initORTRIntArray: engine range: R];
   [engine trackObject: o];
   return o;
}

+(id<ORTRIntMatrix>) TRIntMatrix: (id<OREngine>) engine range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
{
   ORTRIntMatrixI* o = [[ORTRIntMatrixI alloc] initORTRIntMatrix: engine range: R1 : R2];
   [engine trackObject: o];
   return o;
}

+(id<ORTable>) table: (id<ORTracker>) tracker arity: (int) arity
{
   ORTableI* o = [[ORTableI alloc] initORTableI: arity];
   [tracker trackObject: o];
   return o;
}

+(id<ORTable>) table: (id<ORTracker>) tracker with: (ORTableI*) table
{
   ORTableI* o = [[ORTableI alloc] initORTableWithTableI: table];
   [tracker trackObject: o];
   return o;
}

+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range: r0 : r1];
   for(ORInt i=[r0 low];i <= [r0 up];i++)
      for(ORInt j= [r1 low];j <= [r1 up];j++)
         [o set:[ORFactory intVar:cp domain:domain] at:i :j];
   return (id<ORIntVarMatrix>)o;
}
+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(ORInt i= [r0 low];i <= [r0 up]; i++)
      for(ORInt j= [r1 low]; j <= [r1 up]; j++)
         for(ORInt k= [r2 low]; k <= [r2 up];k++)
            [o set:[ORFactory intVar:cp domain:domain] at:i :j :k];
   return (id<ORIntVarMatrix>)o;
}
+(id<ORIntVarMatrix>) boolVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1];
   for(ORInt i= [r0 low];i <= [r0 up]; i++)
      for(ORInt j= [r1 low]; j <= [r1 up];j++)
         [o set: [ORFactory boolVar: cp] at:i :j];
   return (id<ORIntVarMatrix>)o;
}
+(id<ORIntVarMatrix>) boolVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(ORInt i= [r0 low]; i <= [r0 up]; i++)
      for(ORInt j= [r1 low]; j <= [r1 up]; j++)
         for(ORInt k= [r2 low]; k <= [r2 up]; k++)
            [o set: [ORFactory boolVar: cp] at:i :j :k];
   return (id<ORIntVarMatrix>) o;
}
+(id<ORIntVarArray>) flattenMatrix:(id<ORIntVarMatrix>)m
{
   id<ORTracker> tracker = [m tracker];
   ORInt sz = (ORInt)[m count];
   id<ORIdArray> flat = [ORFactory idArray: tracker range: RANGE(tracker,0,sz-1)];
   for(ORInt i=0;i<sz;i++)
      flat[i] = [m flat:i];
   return (id<ORIntVarArray>)flat;
}
@end

@implementation ORFactory (Expressions)
+(id<ORExpr>) validate:(id<ORExpr>)e onError:(const char*)str
{
   id<ORTracker> cp = [e tracker];
   if (cp == NULL)
      @throw [[ORExecutionError alloc] initORExecutionError: str]; 
   [cp trackObject: e];
   return e;   
}
+(id<ORExpr>) expr: (id<ORExpr>) left plus: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprPlusI alloc] initORExprPlusI: left and: right]; 
   return [self validate:o onError:"No CP tracker in Add Expression"];
}
+(id<ORExpr>) expr: (id<ORExpr>) left sub: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprMinusI alloc] initORExprMinusI: left and: right]; 
   return [self validate:o onError:"No CP tracker in Sub Expression"];
}
+(id<ORExpr>) expr: (id<ORExpr>) left mul: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprMulI alloc] initORExprMulI: left and: right]; 
   return [self validate:o onError:"No CP tracker in Mul Expression"];
}
+(id<ORExpr>) expr: (id<ORExpr>) left mod: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprModI alloc] initORExprModI: left mod: right];
   return [self validate:o onError:"No CP tracker in Mod Expression"];
}
+(id<ORRelation>) expr: (id<ORExpr>) left equal: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprEqualI alloc] initORExprEqualI: left and: right]; 
   [self validate:o onError:"No CP tracker in == Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left neq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprNotEqualI alloc] initORExprNotEqualI: left and: right];
   [self validate:o onError:"No CP tracker in != Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left leq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: left and: right];
   [self validate:o onError:"No CP tracker in <= Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left geq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: right and: left];
   [self validate:o onError:"No CP tracker in >= Expression"];
   return o;
}
+(id<ORExpr>) expr: (id<ORRelation>) left and: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORConjunctI alloc] initORConjunctI:left and:right];
   return [self validate:o onError:"No CP tracker in && Expression"];
}
+(id<ORExpr>) expr: (id<ORRelation>) left or: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORDisjunctI alloc] initORDisjunctI:left or:right];
   return [self validate:o onError:"No CP tracker in || Expression"];
}
+(id<ORExpr>) expr: (id<ORRelation>) left imply: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORImplyI alloc] initORImplyI:left imply:right];
   return [self validate:o onError:"No CP tracker in => Expression"];
}
+(id<ORExpr>) elt: (id<ORTracker>) tracker intVarArray: (id<ORIntVarArray>) a index: (id<ORExpr>) index
{
   id<ORExpr> o = [[ORExprVarSubI alloc] initORExprVarSubI: a elt: index];
   [tracker trackObject: o];
   return o;
}
+(id<ORExpr>) elt: (id<ORTracker>) tracker intArray: (id<ORIntArray>) a index: (id<ORExpr>) index
{
   id<ORExpr> o = [[ORExprCstSubI alloc] initORExprCstSubI: a index: index];
   [tracker trackObject: o];
   return o;
}
+(id<ORExpr>) exprAbs: (id<ORExpr>) op
{
   id<ORExpr> o = [[ORExprAbsI alloc] initORExprAbsI:op];
   return [self validate:o onError:"No CP tracker in Abs Expression"];
}
+(id<ORExpr>) sum: (id<ORTracker>) tracker over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   ORExprSumI* o = [[ORExprSumI alloc] initORExprSumI: tracker over: S suchThat: f of: e];
   [tracker trackObject: o];
   return o;
}
+(id<ORExpr>) prod: (id<ORTracker>) tracker over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   ORExprProdI* o = [[ORExprProdI alloc] initORExprProdI: tracker over: S suchThat: f of: e];
   [tracker trackObject: o];
   return o;
}

+(id<ORRelation>) or: (id<ORTracker>) tracker over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   ORExprAggOrI* o = [[ORExprAggOrI alloc] initORExprAggOrI: tracker over: S suchThat: f of: e];
   [tracker trackObject: o];
   return o;
}
@end

// =====================================================================================================================
// ORFactory (Modeling constraints)
// =====================================================================================================================

@implementation ORFactory (Constraints)
+(id<ORConstraint>) fail:(id<ORTracker>)model
{
   id<ORConstraint> o = [[ORFail alloc] init];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) restrict:(id<ORTracker>)model var:(id<ORIntVar>)x to:(id<ORIntSet>)d
{
   id<ORConstraint> o = [[ORRestrict alloc] initRestrict:x to:d];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i
{
   id<ORConstraint> o = [[ORReifyEqualc alloc] initReify: b equiv:x eqi: i];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eq: (id<ORIntVar>) y annotation:(ORAnnotation)c
{
   id<ORConstraint> o = [[ORReifyEqual alloc] initReify: b equiv: x eq: y annotation:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x neqi: (ORInt) i
{
   id<ORConstraint> o = [[ORReifyNEqualc alloc] initReify: b equiv: x neqi: i];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x leqi: (ORInt) i
{
   id<ORConstraint> o = [[ORReifyLEqualc alloc] initReify: b equiv: x leqi: i];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x geqi: (ORInt) i
{
   id<ORConstraint> o = [[ORReifyGEqualc alloc] initReify: b equiv: x geqi: i];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x geqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumBoolGEqc alloc] initSumBool: x geqi: c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x leqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumBoolLEqc alloc] initSumBool: x leqi: c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x eqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumBoolEqc alloc] initSumBool: x eqi: c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x eqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumEqc alloc] initSum:x eqi:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x leqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumLEqc alloc] initSum:x leqi:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x or:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[OROr alloc] initOROr:b eq:x or:y];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[ORAnd alloc] initORAnd:b eq:x and:y];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[ORImply alloc] initORImply:b eq:x imply:y];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) equal:(id<ORTracker>)model  var:(id<ORIntVar>) x to: (id<ORIntVar>) y plus:(int) c
{
   id<ORConstraint> o = [[OREqual alloc] initOREqual:x eq:y plus:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) equal:(id<ORTracker>)model  var:(id<ORIntVar>) x to: (id<ORIntVar>) y plus:(int) c annotation: (ORAnnotation)n
{
   id<ORConstraint> o = [[OREqual alloc] initOREqual:x eq:y plus:c annotation:n];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) model:(id<ORTracker>)model var:(id<ORIntVar>)y equal:(ORInt)a times:(id<ORIntVar>)x plus:(ORInt)b
               annotation:(ORAnnotation)n
{
   id<ORConstraint> o = [[ORAffine alloc] initORAffine:y eq:a times:x plus:b annotation:n];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) equal3:(id<ORTracker>)model  var: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(id<ORIntVar>) z
                annotation: (ORAnnotation)n
{
   id<ORConstraint> o = [[ORPlus alloc] initORPlus:x eq:y plus:z annotation:n];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) equalc:(id<ORTracker>)model  var: (id<ORIntVar>) x to:(int) c
{
   id<ORConstraint> o = [[OREqualc alloc] initOREqualc:x eqi:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) notEqual:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(id<ORIntVar>)y plus:(int)c
{
   id<ORConstraint> o = [[ORNEqual alloc] initORNEqual:x neq:y plus:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) notEqual:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[ORNEqual alloc] initORNEqual:x neq:y];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) notEqualc:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(ORInt)c
{
   id<ORConstraint> o = [[ORNEqualc alloc] initORNEqualc:x neqi:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y
{
   id<ORConstraint> o = [[ORLEqual alloc] initORLEqual:x leq:y plus:0];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y plus:(ORInt)c
{
   id<ORConstraint> o = [[ORLEqual alloc] initORLEqual:x leq:y plus:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) lEqualc:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (ORInt) c
{
   id<ORConstraint> o = [[ORLEqualc alloc] initORLEqualc:x leqi:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) gEqualc:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (ORInt) c
{
   id<ORConstraint> o = [[ORGEqualc alloc] initORGEqualc:x geqi:c];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) less:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y
{
   id<ORIntVar> yp = [self intVar:[x tracker] var:y shift:-1];
   id<ORConstraint> o = [self lEqual:model var:x to:yp plus:0];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) mult:(id<ORTracker>)model  var: (id<ORIntVar>)x by:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   id<ORConstraint> o = [[ORMult alloc] initORMult:z eq:x times:y];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) mod:(id<ORTracker>)model var:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   id<ORConstraint> o = [[ORMod alloc] initORMod:x mod:y equal:z];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) mod:(id<ORTracker>)model var:(id<ORIntVar>)x modi:(ORInt)c equal:(id<ORIntVar>)z
{
   id<ORConstraint> o = [[ORModc alloc] initORModc:x mod:c equal:z];
   [model trackConstraint:o];
   return o;
}

+(id<ORConstraint>) abs:(id<ORTracker>)model  var: (id<ORIntVar>)x equal:(id<ORIntVar>)y annotation:(ORAnnotation)n
{
   id<ORConstraint> o = [[ORAbs alloc] initORAbs:y eqAbs:x];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<ORIntVar>)y
                 annotation:(ORAnnotation)note
{
   id<ORConstraint> o = [[ORElementCst alloc]  initORElement:x array:c equal:y annotation:note];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORIntVar>)x idxVarArray:(id<ORIntVarArray>)c equal:(id<ORIntVar>)y
                 annotation:(ORAnnotation)note
{
   id<ORConstraint> o = [[ORElementVar alloc] initORElement:x array:c equal:y annotation:note];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) lex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y
{
   id<ORConstraint> o = [[ORLexLeq alloc] initORLex:x leq:y];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) circuit: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORCircuitI alloc] initORCircuitI:x];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) nocycle: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORNoCycleI alloc] initORNoCycleI:x];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load
{
   id<ORConstraint> o = [[ORPackingI alloc] initORPackingI:item itemSize:itemSize load:load];
   [[item tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) packOne: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize
{
   id<ORConstraint> o = [[ORPackOneI alloc] initORPackOneI:item itemSize:itemSize bin:b binSize:binSize];
   [[item tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) knapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c
{
   id<ORConstraint> o = [[ORKnapsackI alloc] initORKnapsackI:x weight:w capacity:c];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORAlldifferentI alloc] initORAlldifferentI: x annotation:DomainConsistency];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x annotation:(ORAnnotation)c
{
   id<ORConstraint> o = [[ORAlldifferentI alloc] initORAlldifferentI:x annotation:c];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntArray>) binSize
{
   // Rewritten in terms of the variable-driven load form.
   id<ORIntRange> R = [binSize range];
   id<ORIntVarArray> load = (id<ORIntVarArray>)[ORFactory idArray:[item tracker] range:R];
   [binSize enumerateWith:^(ORInt bk, int k) {
      load[k] = [ORFactory intVar:[item tracker] domain:RANGE([item tracker],0,bk)];
   }];
   id<ORConstraint> o =  [self packing:item itemSize:itemSize load:load];
   [[item tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) algebraicConstraint:(id<ORTracker>) model expr: (id<ORRelation>) exp annotation:(ORAnnotation)n
{
   id<ORConstraint> o = [[ORAlgebraicConstraintI alloc] initORAlgebraicConstraintI: exp annotation:n];
   [model trackConstraint:o];
   return o;
}
+(id<ORConstraint>) tableConstraint: (id<ORIntVarArray>) x table: (ORTableI*) table
{
   id<ORConstraint> o = [[ORTableConstraintI alloc] initORTableConstraintI: x table: table];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
   id<ORConstraint> o = [[ORCardinalityI alloc] initORCardinalityI: x low: low up: up];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) tableConstraint: (id<ORTable>) table on: (id<ORIntVar>) x : (id<ORIntVar>) y : (id<ORIntVar>) z
{
   id<ORTracker> tracker = [x tracker];
   id<ORIntRange> R = RANGE(tracker,0,2);
   id<ORIdArray> a = [ORFactory idArray:tracker range:R];
   a[0] = x;
   a[1] = y;
   a[2] = z;
   id<ORConstraint> o = [self tableConstraint: (id<ORIntVarArray>) a table: table];
   [tracker trackConstraint:o];
   return o;
}

+(id<ORConstraint>) assignment:(id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost
{
   id<ORConstraint> o = [[ORAssignmentI alloc] initORAssignment:x matrix:matrix cost:cost];
   [[x tracker] trackConstraint:o];
   return o;
}
@end

@implementation ORFactory (BV)
+(id<ORConstraint>) bit:(id<ORBitVar>)x eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitEqual alloc] initORBitEqual:x eq:y];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x or:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitOr alloc] initORBitOr:x or:y eq:z];
   [[x tracker]trackConstraint:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x and:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitAnd alloc] initORBitAnd:x and:y eq:z];
   [[x tracker]trackConstraint:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x not:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitNot alloc] initORBitNot:x not:y];
   [[x tracker] trackConstraint:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x xor:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitXor alloc] initORBitXor:x xor:y eq:z];
   [[x tracker]trackConstraint:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftLBy:(ORInt)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitShiftL alloc] initORBitShiftL:x by:p eq:y];
   [[x tracker]trackConstraint:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x rotateLBy:(ORInt)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitRotateL alloc] initORBitRotateL:x by:p eq:y];
   [[x tracker]trackConstraint:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x plus:(id<ORBitVar>)y withCarryIn:(id<ORBitVar>)ci eq:(id<ORBitVar>)z withCarryOut:(id<ORBitVar>)co
{
   id<ORConstraint> o = [[ORBitSum alloc] initORBitSum:x plus:y in:ci eq:z out:co];
   [[x tracker]trackConstraint:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)w trueIf:(id<ORBitVar>)x equals:(id<ORBitVar>)y zeroIfXEquals:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitIf alloc] initORBitIf:w trueIf:x equals:y zeroIfXEquals:z];
   [[x tracker]trackConstraint:o];
   return o;
}
@end
