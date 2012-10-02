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
#import "ORSolver.h"
#import "ORSelectorI.h" 

@implementation ORFactory
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
+(id<ORTrailableInt>) trailableInt: (id<ORSolver>) solver value: (ORInt) value
{
   ORTrailableIntI* o = [[ORTrailableIntI alloc] initORTrailableIntI: [[solver engine] trail] value:value];
   [solver trackObject: o];
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

+(id<IntEnumerator>) intEnumerator: (id<ORTracker>) tracker over: (id<ORIntIterator>) r
{
   id<IntEnumerator> ite = [r enumerator];
   [tracker trackObject: ite];
   return ite;
}
+(id<ORSelect>) select: (id<ORTracker>) tracker range: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order
{
   ORSelectI* o = [[ORSelectI alloc] initORSelectI: range suchThat: filter orderedBy: order randomized: NO];
   [tracker trackObject: o];
   return o;
}
+(id<ORSelect>) selectRandom: (id<ORTracker>) tracker range: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order
{
   ORSelectI* o = [[ORSelectI alloc] initORSelectI: range suchThat: filter orderedBy: order randomized: YES];
   [tracker trackObject: o];
   return o;
}
+(id<ORModel>) createModel
{
   return [[[ORModelI alloc]  initORModelI] autorelease];
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
   return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:a shift:0];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a shift:(ORInt) b
{
   return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:a shift:b];
}
+(id<ORIntVar>) boolVar: (id<ORTracker>) model
{
   return [[ORIntVarI alloc] initORIntVarI: model domain: RANGE(model,0,1)];
}
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up
{
   return [[ORFloatVarI alloc]  initORFloatVarI: tracker low: low up: up];
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

+(id<ORTrailableIntArray>) trailableIntArray: (id<ORSolver>) tracker range: (id<ORIntRange>) range value: (ORInt) value
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: [ORFactory trailableInt: tracker value: value] at:k];
   return (id<ORTrailableIntArray>) o;
}
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORAlldifferentI alloc] initORAlldifferentI: x];
   [[x tracker] trackObject: o];
   return o;
}
+(id<ORConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntVarArray>) binSize
{
   id<ORConstraint> o = [[ORBinPackingI alloc] initORBinPackingI: item itemSize: itemSize binSize: binSize];
   [[item tracker] trackObject: o];
   return o;
}
+(id<ORConstraint>) algebraicConstraint:(id<ORModel>) model expr: (id<ORRelation>) exp
{
   id<ORConstraint> o = [[ORAlgebraicConstraintI alloc] initORAlgebraicConstraintI: exp];
   [model trackObject: o];
   return o;
}
+(id<ORConstraint>) tableConstraint: (id<ORIntVarArray>) x table: (ORTableI*) table
{
   id<ORConstraint> o = [[ORTableConstraintI alloc] initORTableConstraintI: x table: table];
   [[x tracker] trackObject: o];
   return o;
}
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
   id<ORConstraint> o = [[ORCardinalityI alloc] initORCardinalityI: x low: low up: up];
   [[x tracker] trackObject: o];
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
   return [self tableConstraint: (id<ORIntVarArray>) a table: table];
}
+(id<ORTRIntArray>) TRIntArray: (id<ORTracker>) solver range: (id<ORIntRange>) R
{
   ORTRIntArrayI* o = [[ORTRIntArrayI alloc] initORTRIntArray: (id<ORSolver>) solver range: R];
   [solver trackObject: o];
   return o;
}

+(id<ORTRIntMatrix>) TRIntMatrix: (id<ORTracker>) solver range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
{
   ORTRIntMatrixI* o = [[ORTRIntMatrixI alloc] initORTRIntMatrix: (id<ORSolver>) solver range: R1 : R2];
   [solver trackObject: o];
   return o;
}

+(id<ORTable>) table: (id<ORSolver>) solver arity: (int) arity
{
   ORTableI* o = [[ORTableI alloc] initORTableI: solver arity: arity];
   [solver trackObject: o];
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
   return [self validate:o onError:"No CP Solver in Add Expression"];
}
+(id<ORExpr>) expr: (id<ORExpr>) left sub: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprMinusI alloc] initORExprMinusI: left and: right]; 
   return [self validate:o onError:"No CP Solver in Sub Expression"];
}
+(id<ORExpr>) expr: (id<ORExpr>) left mul: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprMulI alloc] initORExprMulI: left and: right]; 
   return [self validate:o onError:"No CP Solver in Mul Expression"];
}
+(id<ORRelation>) expr: (id<ORExpr>) left equal: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprEqualI alloc] initORExprEqualI: left and: right]; 
   [self validate:o onError:"No CP Solver in == Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left neq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprNotEqualI alloc] initORExprNotEqualI: left and: right];
   [self validate:o onError:"No CP Solver in != Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left leq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: left and: right];
   [self validate:o onError:"No CP Solver in <= Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left geq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: right and: left];
   [self validate:o onError:"No CP Solver in >= Expression"];
   return o;
}
+(id<ORExpr>) expr: (id<ORRelation>) left and: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORConjunctI alloc] initORConjunctI:left and:right];
   return [self validate:o onError:"No CP Solver in && Expression"];
}
+(id<ORExpr>) expr: (id<ORRelation>) left or: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORDisjunctI alloc] initORDisjunctI:left or:right];
   return [self validate:o onError:"No CP Solver in || Expression"];
}
+(id<ORExpr>) expr: (id<ORRelation>) left imply: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORImplyI alloc] initORImplyI:left imply:right];
   return [self validate:o onError:"No CP Solver in => Expression"];
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
   return [self validate:o onError:"No CP Solver in Abs Expression"];
}
+(id<ORExpr>) sum: (id<ORTracker>) tracker over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   ORExprSumI* o = [[ORExprSumI alloc] initORExprSumI: tracker over: S suchThat: f of: e];
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