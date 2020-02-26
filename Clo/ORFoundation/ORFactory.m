/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORFactory.h>
#import <ORFoundation/ORTrailI.h>
#import <ORUtilities/ORUtilities.h>
#import "ORArrayI.h"
#import "ORConstraintI.h"
#import "ORSelectorI.h" 
#import "ORVarI.h"
#import <ORFoundation/fpi.h>

//#import <objcp/CPBitMacros.h>

@interface OROrderedSweep : NSObject<OROrderedSweep> {
   BOOL*    _used;
   ORInt      _low;
   ORInt      _sz;
   ORInt     _nbo;
   ORInt     _mxo;
   ORDouble* _best;
   ORDouble* _curr;
   ORInt2Double* _of;
   ORInt2Bool   _filter;
   id<ORIntIterable> _col;
}
-(id)initWith:(id<ORIntIterable>)col;
-(void)startup;
-(void)addFilter:(ORInt2Bool)f;
-(void)addOrdered:(ORInt2Double)f;
-(BOOL)next:(ORInt*)v;
@end


@implementation ORFactory
+(void) shutdown
{
   [NSCont shutdown];
}
+(id<ORTrail>) trail
{
   return [[ORTrailI alloc] init];
}
+(id<ORMemoryTrail>) memoryTrail
{
   return [[ORMemoryTrailI alloc] init];
}
+(id<ORRandomStream>) randomStream: (id<ORTracker>) cp
{
   id<ORRandomStream> o = [[ORRandomStreamI alloc] init];
   [cp trackMutable: o];
   return o;
}
+(id<ORZeroOneStream>) zeroOneStream: (id<ORTracker>) cp
{
   id<ORZeroOneStream> o = [[ORZeroOneStreamI alloc] init];
   [cp trackMutable: o];
   return o;
}
+(id<ORUniformDistribution>) uniformDistribution: (id<ORTracker>) cp range: (id<ORIntRange>) r
{
   id<ORUniformDistribution> o = [[ORUniformDistributionI alloc] initORUniformDistribution: r];
   [cp trackMutable: o];
   return o;
}
+(id<ORRandomPermutation>) randomPermutation:(id<ORIntIterable>)onSet
{
   id<ORRandomPermutation> o = [[ORRandomPermutationI alloc] initWithSet:onSet];
   return o;
}

+(id<OROSet>) objectSet
{
    return [[[OROSetI alloc] init] autorelease];
}
+(id<OROSet>) objectSet:(id<ORTracker>)tracker
{
    id<OROSet> o = [[OROSetI alloc] init];
    [tracker trackMutable:o];
    return o;
}

+(id<ORGroup>)group:(id<ORTracker>)model type:(enum ORGroupType)gt
{
   id<ORGroup> o = [[ORGroupI alloc] initORGroupI:model type:gt];
   [model trackObject:o];
   return o;
}
+(id<ORGroup>)group:(id<ORTracker>)model type:(enum ORGroupType)gt guard:(id<ORIntVar>)guard
{
   id<ORGroup> o = [[ORGroupI alloc] initORGroupI:model type:gt guard:guard];
   [model trackObject:o];
   return o;
}
+(id<ORGroup>)group:(id<ORTracker>)model
{
   return [self group:model type:DefaultGroup];
}
+(id<ORGroup>)cdisj:(id<ORTracker>)model clauses:(NSArray* PNULLABLE)cl
{
   id<ORGroup> g = [[ORCDisjGroupI alloc] initORCDGroupI:model];
   [model trackObject:g];
   if (cl)
      for(id<ORGroup> c in cl)
         [g add:c];
   return g;
}
+(id<ORGroup>)cdisj:(id<ORTracker>)model vmap:(NSArray*)varMap
{
   id<ORGroup> g = [[ORCDisjGroupI alloc] initORCDGroupI:model witMap:varMap];
   [model trackObject:g];
   return g;
}
+(id<ORGroup>)bergeGroup:(id<ORTracker>)model
{
   return [self group:model type:BergeGroup];
}
+(id<ORGroup>)group:(id<ORTracker>)model guard:(id<ORIntVar>)g
{
   id<ORGroup> o = [[ORGroupI alloc] initORGroupI:model type:GuardedGroup guard:g];
   [model trackObject:o];
   return o;
}
+(id<ORGroup>)group3B:(id<ORTracker>)model
{
   id<ORGroup> o = [[OR3BGroupI alloc] initOR3BGroupI:model];
   [model trackObject:o];
   return o;
}
+(id<ORInteger>) integer: (id<ORTracker>)tracker value: (ORInt) value
{
   ORIntegerI* o = [[ORIntegerI alloc] initORIntegerI: tracker value:value];
   return [tracker trackImmutable: o];
}
+(id<ORMutableInteger>) mutable: (id<ORTracker>)tracker value: (ORInt) value
{
   ORMutableIntegerI* o = [[ORMutableIntegerI alloc] initORMutableIntegerI: tracker value:value];
   return [tracker trackMutable: o];
}
+(id<ORMutableFloat>) mutable: (id<ORTracker>)tracker fvalue: (ORFloat) value
{
   ORMutableFloatI* o = [[ORMutableFloatI alloc] initORMutableFloatI: tracker value:value];
   return [tracker trackMutable: o];
}
+(id<ORMutableRational>) mutable: (id<ORTracker>)tracker qvalue: (id<ORRational>) value
{
   ORMutableRationalI* o = [[ORMutableRationalI alloc] initORMutableRationalI: tracker value:value];
   return [tracker trackMutable: o];
}
+(id<ORDoubleNumber>) double: (id<ORTracker>) tracker value: (ORDouble) value
{
   ORDoubleI* o = [[ORDoubleI alloc] init: tracker value: value];
   return [tracker trackImmutable: o];
}
+(id<ORFloatNumber>) float: (id<ORTracker>) tracker value: (ORFloat) value
{
    ORFloatI* o = [[ORFloatI alloc] init: tracker value: value];
    return [tracker trackImmutable: o];
}
+(id<ORRationalNumber>) rational: (id<ORTracker>) tracker value: (id<ORRational>) value
{
   ORRationalI* o = [[ORRationalI alloc] init: tracker value: value];
   return [tracker trackImmutable: o];
}
+(id<ORFloatNumber>) infinityf: (id<ORTracker>) tracker
{
    ORFloatI* o = [[ORFloatI alloc] init: tracker value: infinityf()];
    return [tracker trackImmutable: o];
}
+(id<ORMutableDouble>) mutableDouble: (id<ORTracker>)tracker value: (ORDouble) value
{
   ORMutableDoubleI* o = [[ORMutableDoubleI alloc] initORMutableRealI: tracker value:value];
   [tracker trackMutable: o];
   return o;
}
+(id<ORMutableId>) mutableId:(id<ORTracker>) tracker value:(id) value
{
   ORMutableId* o = [[ORMutableId alloc] initWith:value];
   return [tracker trackMutable:o];
}
+(id<ORTrailableInt>) trailableInt: (id<ORSearchEngine>) engine value: (ORInt) value
{
   ORTrailableIntI* o = [[ORTrailableIntI alloc] initORTrailableIntI: [engine trail] value:value];
   return [engine trackMutable: o];
}
+(id<ORIntSet>)  intSet: (id<ORTracker>) tracker
{
   ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI];
   return [tracker trackMutable: o];
}
+(id<ORIntSet>) intSet:(id<ORTracker>) tracker set:(NSSet*)theSet
{
   ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI];
   o = [tracker trackMutable:o];
   for (NSNumber* k in theSet)
      [o insert:k.intValue];
   return o;
}
+(id<ORIntRange>)  intRange: (id<ORTracker>) tracker low: (ORInt) low up: (ORInt) up
{
   ORIntRangeI* o = [[ORIntRangeI alloc] initORIntRangeI: low up: up];
   return [tracker trackImmutable: o];
}
+(id<ORRealRange>) realRange: (id<ORTracker>) tracker low:(ORDouble)low up:(ORDouble) up
{
   ORRealRangeI* o = [[ORRealRangeI alloc] init:low up:up];
   return [tracker trackImmutable:o];
}
+(id<ORFloatRange>) floatRange: (id<ORTracker>) tracker
{
    ORFloatRangeI* o = [[ORFloatRangeI alloc] init:-INFINITY up:INFINITY];
    return [tracker trackImmutable:o];
}
+(id<ORFloatRange>) floatRange: (id<ORTracker>) tracker low:(ORFloat)low up:(ORFloat) up
{
    ORFloatRangeI* o = [[ORFloatRangeI alloc] init:low up:up];
    return [tracker trackImmutable:o];
}
+(id<ORRationalRange>) rationalRange: (id<ORTracker>) tracker
{
   id<ORRational> ninf = [[[ORRational alloc] init] setNegInf];
   id<ORRational> pinf = [[[ORRational alloc] init] setPosInf];
   ORRationalRangeI* o = [[ORRationalRangeI alloc] init:ninf up:pinf];
   [ninf release];
   [pinf release];
   //[o autorelease];
   return [tracker trackImmutable:o];
}
+(id<ORRationalRange>) rationalRange: (id<ORTracker>) tracker low:(id<ORRational>)low up:(id<ORRational>) up
{
   ORRationalRangeI* o = [[ORRationalRangeI alloc] init:low up:up];
   //[o autorelease];
   return [tracker trackImmutable:o];
}
+(id<ORDoubleRange>) doubleRange: (id<ORTracker>) tracker
{
    ORDoubleRangeI* o = [[ORDoubleRangeI alloc] init:-INFINITY up:INFINITY];
    return [tracker trackImmutable:o];
}
+(id<ORDoubleRange>) doubleRange: (id<ORTracker>) tracker low:(ORDouble)low up:(ORDouble) up
{
    ORDoubleRangeI* o = [[ORDoubleRangeI alloc] init:low up:up];
    return [tracker trackImmutable:o];
}
+(id<ORLDoubleRange>) ldoubleRange: (id<ORTracker>) tracker
{
    ORLDoubleRangeI* o = [[ORLDoubleRangeI alloc] init:-INFINITY up:INFINITY];
    return [tracker trackImmutable:o];
}
+(id<ORLDoubleRange>) ldoubleRange: (id<ORTracker>) tracker low:(ORLDouble)low up:(ORLDouble) up
{
    ORLDoubleRangeI* o = [[ORLDoubleRangeI alloc] init:low up:up];
    return [tracker trackImmutable:o];
}
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker array: (NSArray*)array
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray:tracker size:(ORInt)[array count] value:0];
   o = [tracker trackMutable:o];
   ORInt i = 0;
   for(NSNumber* k in array)
      [o set:k.intValue at:i++];
   return o;
}
+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORInt) value
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range:range value: (ORInt) value];
   return [tracker trackMutable: o];
}
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range values: (ORInt[]) values {
    ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range:range value: 0];
    for(ORInt i = [o.range low]; i <= [o.range up]; i++)
        [o set: values[i - [o.range low]]  at: i];
    return [tracker trackMutable: o];
}
+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range:range with:clo];
   return [tracker trackMutable: o];
}
+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range: r1 range: r2 with:clo];    
   return [tracker trackMutable: o];
}
+(ORDoubleArrayI*) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORDouble) value
{
    ORDoubleArrayI* o = [[ORDoubleArrayI alloc] init: tracker range:range value: (ORDouble) value];
    return [tracker trackMutable: o];
}
+(id<ORDoubleArray>) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range values: (ORDouble[]) values {
    ORDoubleArrayI* o = [[ORDoubleArrayI alloc] init: tracker range:range value: 0];
    for(ORInt i = [o.range low]; i <= [o.range up]; i++)
        [o set: values[i - [o.range low]]  at: i];
    return [tracker trackMutable: o];
}
+(ORDoubleArrayI*) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORDouble(^)(ORInt)) clo
{
    ORDoubleArrayI* o = [[ORDoubleArrayI alloc] init: tracker range:range with:clo];
    return [tracker trackMutable: o];
}
+(ORDoubleArrayI*) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORDouble(^)(ORInt,ORInt)) clo
{
    ORDoubleArrayI* o = [[ORDoubleArrayI alloc] init: tracker range: r1 range: r2 with:clo];
    return [tracker trackMutable: o];
}
+(id<ORDoubleArray>) doubleArray:(id<ORTracker>)tracker intVarArray: (id<ORIntVarArray>)arr {
    return [ORFactory doubleArray: tracker range: [arr range] with:^ORDouble(ORInt i) {
        return (ORDouble)[[arr at: i] literal];
    }];
}
+(ORDoubleArrayI*) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   ORDoubleArrayI* o = [[ORDoubleArrayI alloc] init: tracker range:range value:0];
   return [tracker trackMutable: o];
}
+(ORFloatArrayI*) floatArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORFloat(^)(ORInt)) clo
{
    ORFloatArrayI* o = [[ORFloatArrayI alloc] init: tracker range:range with:clo];
    return [tracker trackMutable: o];
}
+(ORFloatArrayI*) floatArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
    ORFloatArrayI* o = [[ORFloatArrayI alloc] init: tracker range:range value:0.f];
    return [tracker trackMutable: o];
}
+(id<ORRationalArray>) rationalArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(id<ORRational>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   [o.range enumerateWithBlock:^(ORInt k) {
      [o set:clo(k) at:k];
   }];
   return (id<ORRationalArray>)o;
}
+(id<ORRationalArray>) rationalArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   id<ORRational> zero = [[ORRational alloc] init];
   [zero setZero];
   id<ORRationalArray> o = [[ORRationalArrayI alloc] init: tracker range:range value:zero];
   [zero release];
   return [tracker trackMutable: o];
}
+(ORLDoubleArrayI*) ldoubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORLDouble(^)(ORInt)) clo
{
   ORLDoubleArrayI* o = [[ORLDoubleArrayI alloc] init: tracker range:range with:clo];
   return [tracker trackMutable: o];
}
+(ORLDoubleArrayI*) ldoubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   ORLDoubleArrayI* o = [[ORLDoubleArrayI alloc] init: tracker range:range value:0.0];
   return [tracker trackMutable: o];
}
+(id<ORIdArray>) idArray: (id<ORTracker>) tracker array: (NSArray*)array
{
   ORIdArrayI* o = [[ORIdArrayI alloc] initORIdArray:tracker range:RANGE(tracker,0,(ORInt)[array count] - 1)];
   [o.range enumerateWithBlock:^(ORInt k) {
      [o set:[array objectAtIndex:k] at:k];
   }];
   return [tracker trackMutable:o];
}

+(id<ORIdArray>) idArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(id(^)(ORInt))clo
{
   ORIdArrayI* o = [[ORIdArrayI alloc] initORIdArray:tracker range:range];
   [range enumerateWithBlock:^(ORInt k) {
      [o set:clo(k) at:k];
   }];
   ORIdArrayI* co = [tracker inCache:o];
   if (co == NULL) {
      [tracker trackMutable:o];
      [tracker addToCache:o];
      return o;
   } else {
      [o release];
      return co;
   }
   //return [tracker trackMutable:o];
}
+(id<ORIdArray>) idArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   ORIdArrayI* o = [[ORIdArrayI alloc] initORIdArray:tracker range:range];
   return [tracker trackMutable:o];
}
+(id<ORIdArray>) idArray: (id<ORTracker>)tracker NSArray: (NSArray*)arr {
    id<ORIntRange> range = RANGE(tracker, 0, (ORInt)arr.count-1);
    id<ORIdArray> o = [ORFactory idArray: tracker range: range with: ^id(ORInt i) { return arr[i]; }];
    return o;
}
struct EltValue {
   ORDouble  _val;
   id       _obj;
};
int cmpEltValue(const struct EltValue* v1,const struct EltValue* v2)
{
   ORDouble d = v1->_val - v2->_val;
   if (d == 0.0) return 0;
   else if (d < 0) return -1;
   else return 1;
}
+(id<ORIdArray>) sort:(id<ORTracker>)tracker idArray:(id<ORIdArray>)array with:(ORDouble(^)(id))f
{
   ORInt low = array.range.low;
   ORInt up  = array.range.up;
   ORInt sz = up - low + 1;
   struct EltValue* fv = alloca(sizeof(struct EltValue)*sz);
   for(ORInt i=low;i <= up;i++)
      fv[i - low] = (struct EltValue){f(array[i]),array[i]};
   qsort(fv,sz,sizeof(struct EltValue),(int(*)(const void*,const void*))&cmpEltValue);
   id na = [ORFactory idArray:[tracker tracker] range:array.range with:^id(ORInt k) {
      return fv[k - low]._obj;
   }];
   return na;
}

+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix:tracker range:r0 :r1];
   return [tracker trackMutable:o];
}
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix:tracker range:r0 :r1 :r2];
   return [tracker trackMutable:o];
}
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   ORIntMatrixI* o = [[ORIntMatrixI alloc] initORIntMatrix: tracker range: r1 : r2];
   return [tracker trackMutable: o];
}
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 with: (ORIntxInt2Int)block
{
   ORIntMatrixI* o = [[ORIntMatrixI alloc] initORIntMatrix: tracker range: r1 : r2 with: block];
   return [tracker trackMutable: o];
}
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker with: (ORIntMatrixI*) m
{
   ORIntMatrixI* o = [[ORIntMatrixI alloc] initORIntMatrix: tracker with: m];
   return [tracker trackMutable: o];
}
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker arity:(ORInt)arity ranges:(id<ORIntRange>*)ranges
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix:tracker arity:arity ranges:ranges];
   return [tracker trackMutable:o];
}
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker with: (ORIdMatrixI*) m
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix: tracker with: m];
   return [tracker trackMutable: o];
}
+(id<ORIntSetArray>) intSetArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   return (id<ORIntSetArray>)[ORFactory idArray: tracker range: range];
}
+(id<ORIntSet>) collect: (id<ORTracker>) tracker range: (id<ORIntRange>) r suchThat: (ORInt2Bool) f of: (ORInt2Int) e
{
   ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI];
   for(ORInt i = [r low]; i <= [r up]; i++)
      if (f == NULL || f(i))
         [o insert: e(i)];
   return [tracker trackMutable: o];
}

+(id<ORIntSet>) collect: (id<ORTracker>) tracker range: (id<ORIntRange>)r1 range:(id<ORIntRange>)r2
               suchThat: (ORIntxInt2Bool) f
                     of: (ORIntxInt2Int) e
{
   ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI];
   for(ORInt i = [r1 low]; i <= [r1 up]; i++)
      for(ORInt j = [r2 low]; i <= [r2 up]; j++)
      if (f == NULL || f(i,j))
         [o insert: e(i,j)];
   return [tracker trackMutable: o];
}
+(id) slice:(id<ORTracker>)model range:(id<ORIntRange>)r suchThat:(ORInt2Bool)f of:(ORInt2Id)e
{
   ORInt nbOk = 0;
   for(ORInt k=r.low;k <= r.up;k++)
      nbOk += f(k);
   id<ORIdArray> o = [ORFactory idArray:model range:RANGE(model,0,nbOk-1)];
   ORInt i = 0;
   for(ORInt k=r.low;k <= r.up;k++)
      if (f(k))
         [o set:e(k) at:i++];
   return o;
}


+(ORInt) minOver: (id<ORIntRange>) r suchThat: (ORInt2Bool) filter of: (ORInt2Int)e
{
    ORInt m = MAXINT;
    for(ORInt i = [r low]; i <= [r up]; i++) {
        if (filter == NULL || filter(i)) {
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
        if (filter == NULL || filter(i)) {
            ORInt x = e(i);
            if(x > m) m = x;
        }
    }
    return m;
}

+(id<IntEnumerator>) intEnumerator: (id<ORTracker>) tracker over: (id<ORIntIterable>) r
{
   id<IntEnumerator> ite = [r enumerator];
   [tracker trackMutable: ite];
   return ite;
}
+(id<OROrderedSweep>) orderedSweep: (id<ORTracker>) t over: (id<ORIntIterable>) r filter: (ORInt2Bool) filter orderedBy: (ORInt2Double) o;
{
   OROrderedSweep* ite = [[OROrderedSweep alloc] initWith: r];
   [ite addFilter:filter];
   [ite addOrdered:o];
   [t trackObject:ite];
   [ite startup];
   return ite;
}
+(id<ORSelect>) select: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order
{
   ORSelectI* o = [[ORSelectI alloc] initORSelectI: range
                                          suchThat: filter
                                         orderedBy: order
                                        randomized: [ORStreamManager randomized]];
   [tracker trackMutable: o];
   return o;
}
+(id<ORSelect>) selectRandom: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order
{
   ORSelectI* o = [[ORSelectI alloc] initORSelectI: range suchThat: filter orderedBy: order randomized: NO];
   [tracker trackMutable: o];
   return o;
}
+(id<ORSelect>) selectRandom: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order randomized:(ORBool)rand
{
   ORSelectI* o = [[ORSelectI alloc] initORSelectI: range suchThat: filter orderedBy: order randomized: rand];
   [tracker trackMutable: o];
   return o;
}
+(id<ORSelect>) select: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order  tiebreak: (ORInt2Double) tb
{
   ORSelectI* o = [[ORSelectI alloc] initORSelectI: range
                                          suchThat: filter
                                         orderedBy: order
                                        tiebreak: tb];
   [tracker trackMutable: o];
   return o;
}
+(id<ORSelector>) selectMin:(id<ORTracker>)tracker
{
   id<ORSelector> sweeper = [[ORMinSelector alloc] init];
   [tracker trackMutable:sweeper];
   return sweeper;
}

+(id<ORIntVar>) reifyView:(id<ORTracker>)model var:(id<ORIntVar>) x eqi:(ORInt)c
{
#if USEVIEWS==1
   return [[ORIntVarLitEQView alloc] initORIntVarLitEQView:model var:x eqi:c];
#else
   assert(0);
   return nil;
#endif
}
+(id<ORIntVar>) intVar: (id<ORTracker>) model
{
   return [[ORIntVarI alloc]  initORIntVarI: model domain:RANGE(model, 0, MAXINT)];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) model name:(NSString*) name
{
   return [[ORIntVarI alloc]  initORIntVarI: model domain:RANGE(model, 0, MAXINT) name:name];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) model domain: (id<ORIntRange>) r
{
   return [[ORIntVarI alloc]  initORIntVarI: model domain: r];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) model bounds: (id<ORIntRange>) r
{
   return [[ORIntVarI alloc]  initORIntVarI: model bounds: r];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker value: (ORInt) value
{
   return [[ORIntVarI alloc]  initORIntVarI: tracker domain: RANGE(tracker,value,value)];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) model domain: (id<ORIntRange>) r name:(NSString*) name
{
   return [[ORIntVarI alloc]  initORIntVarI: model domain: r name:name];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) model bounds: (id<ORIntRange>) r name:(NSString*) name
{
   return [[ORIntVarI alloc]  initORIntVarI: model bounds: r name:name];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker value: (ORInt) value name:(NSString*) name
{
   return [[ORIntVarI alloc]  initORIntVarI: tracker domain: RANGE(tracker,value,value) name:name];
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x shift: (ORInt) b
{
#if USEVIEWS==1
   return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:1 shift:b];
#else
   if (b==0)
      return x;
   else {
      id<ORIntVar> nv = [ORFactory intVar:tracker domain:RANGE(tracker,[x min] + b,[x max] + b)];
      [tracker addConstraint:[ORFactory equal:tracker var:nv to:x plus:b]];
      return nv;
   }
#endif
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a
{
#if USEVIEWS==1
   if (a==1)
      return x;
   else
      return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:a shift:0];
#else
   if (a==1)
      return x;
   else {
      ORInt l = a > 0 ? a * [x min] : a * [x max];
      ORInt u = a > 0 ? a * [x max] : a * [x min];
      id<ORIntVar> nv = [ORFactory intVar:tracker domain:RANGE(tracker,l,u)];
      [tracker addConstraint:[ORFactory model:tracker var:nv equal:a times:x plus:0]];
      return nv;
   }
#endif
}
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a shift:(ORInt) b
{
#if USEVIEWS==1
   if (a == 1 && b == 0)
      return x;
   else
      return [[ORIntVarAffineI alloc] initORIntVarAffineI:tracker var:x scale:a shift:b];
#else
   if (a== 1 && b == 0)
      return x;
   else {
      ORInt l = (a > 0 ? a * [x min] : a * [x max]) + b;
      ORInt u = (a > 0 ? a * [x max] : a * [x min]) + b;
      id<ORIntVar> nv = [ORFactory intVar:tracker domain:RANGE(tracker,l,u)];
      [tracker addConstraint:[ORFactory model:tracker var:nv equal:a times:x plus:b]];
      return nv;
   }
#endif
}
+(id<ORIntVar>) boolVar: (id<ORTracker>) model
{
   return [[ORIntVarI alloc] initORIntVarI: model domain: RANGE(model,0,1)];
}
+(id<ORRealVar>) realVar: (id<ORTracker>) tracker low:(ORDouble) low up: (ORDouble) up name:(NSString*) name
{
   return [[ORRealVarI alloc]  init: tracker low: low up: up name:name];
}
+(id<ORRealVar>) realVar: (id<ORTracker>) tracker low:(ORDouble) low up: (ORDouble) up
{
    return [[ORRealVarI alloc]  init: tracker low: low up: up];
}
+(id<ORRealVar>) realVar: (id<ORTracker>) tracker
{
    return [[ORRealVarI alloc]  init: tracker];
}
+(id<ORRealVar>) realVar: (id<ORTracker>) tracker name:(NSString*) name
{
   return [[ORRealVarI alloc]  init: tracker name:name];
}
//-------------------------------
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up
{
    return [[ORFloatVarI alloc]  init: tracker low: low up: up];
}
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker domain:(id<ORFloatRange>) dom
{
   return [[ORFloatVarI alloc]  init: tracker domain:dom];
}
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker name:(NSString*) name
{
   return [[ORFloatVarI alloc]  init: tracker name:name];
}
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up name:(NSString*) name
{
   return [[ORFloatVarI alloc]  init: tracker low: low up: up name:name];
}
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up elow:(id<ORRational>) elow eup:(id<ORRational>) eup name:(NSString*) name
{
   return [[ORFloatVarI alloc]  init: tracker low: low up: up elow: elow eup: eup name:name];
}
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker
{
   return [[ORFloatVarI alloc]  init: tracker];
}
+(id<ORRationalVar>) rationalVar: (id<ORTracker>) tracker low:(id<ORRational>) low up: (id<ORRational>) up
{
   return [[ORRationalVarI alloc]  init: tracker low: low up: up];
}
+(id<ORRationalVar>) rationalVar: (id<ORTracker>) tracker domain:(id<ORRationalRange>) dom
{
   return [[ORRationalVarI alloc]  init: tracker domain:dom];
}
+(id<ORRationalVar>) rationalVar: (id<ORTracker>) tracker name:(NSString*) name
{
   return [[ORRationalVarI alloc]  init: tracker name:name];
}
+(id<ORRationalVar>) rationalVar: (id<ORTracker>) tracker from:(id<ORFloatVar>) f
{
   return [[ORRationalVarI alloc]  init: tracker name:[f prettyname]];
}
+(id<ORRationalVar>) rationalVar: (id<ORTracker>) tracker low:(id<ORRational>) low up: (id<ORRational>) up name:(NSString*) name
{
   return [[ORRationalVarI alloc]  init: tracker low: low up: up name:name];
}
+(id<ORRationalVar>) rationalVar: (id<ORTracker>) tracker
{
   return [[ORRationalVarI alloc]  init: tracker];
}
+(id<ORRationalVar>) errorVar: (id<ORTracker>) mdl of:(id<ORVar>)f
{
   id<ORRational> low = [[[ORRational alloc] init] setNegInf];
   id<ORRational> up =  [[[ORRational alloc] init] setPosInf];
   ORRationalVarI* r = [[ORRationalVarI alloc] init: mdl
                                                 low:low
                                                  up:up
                                                name:[NSString stringWithFormat:@"e%@",[f prettyname]]];
   id<ORConstraint> c = [ORFactory errorOf:mdl var:f is:r];
   [mdl add: c];
   [low release];
   [up release];
   return r;
}
+(id<ORDoubleVar>) doubleConstantVar: (id<ORTracker>) tracker value:(ORDouble) v string:(NSString*) vs name:(NSString*) name
{
   id<ORRational> xQ = [[ORRational alloc] init];
   id<ORRational> xF = [[ORRational alloc] init];
   id<ORRational> ex = [[ORRational alloc] init];
   [xQ set_str:(char*)[vs UTF8String]];
   [xF set_d:v];
   [ex set:[xQ sub: xF]];
   
   id<ORDoubleVar> x = [ORFactory doubleVar:tracker low:v up:v elow:ex eup:ex name:name];
   [xQ release];
   [xF release];
   [ex release];
   
   return x;
}
+(id<ORDoubleVar>) doubleInputVar: (id<ORTracker>) tracker low:(ORDouble) low up: (ORDouble) up name:(NSString*) name
{
   id<ORRational> negInf = [[ORRational alloc] init];
   id<ORRational> posInf = [[ORRational alloc] init];
   [negInf setNegInf];
   [posInf setPosInf];
   id<ORDoubleVar> x = [[ORDoubleVarI alloc]  init: tracker low: low up: up elow: negInf eup: posInf name:name inputVar:true];
   id<ORRationalVar> ex = [ORFactory errorVar:tracker of:x];
   id<ORRationalVar> ulp = [ORFactory ulpVar:tracker of:x];
   [tracker add:[ex leq:ulp]];
   [tracker add:[ex geq:ulp]];
   [negInf release];
   [posInf release];
   
   return x;
}
+(id<ORDoubleVar>) doubleInputVar: (id<ORTracker>) tracker low:(ORDouble) low up: (ORDouble) up elow:(id<ORRational>) elow eup:(id<ORRational>) eup name:(NSString*) name
{
   return [[ORDoubleVarI alloc]  init: tracker low: low up: up elow: elow eup: eup name:name inputVar:true];
}
+(id<ORFloatVar>) floatConstantVar: (id<ORTracker>) tracker value:(ORFloat) v string:(NSString*) vs name:(NSString*) name
{
   id<ORRational> xQ = [[ORRational alloc] init];
   id<ORRational> xF = [[ORRational alloc] init];
   id<ORRational> ex = [[ORRational alloc] init];
   [xQ set_str:(char*)[vs UTF8String]];
   [xF set_d:v];
   [ex set:[xQ sub: xF]];
   
   id<ORFloatVar> x = [ORFactory floatVar:tracker low:v up:v elow:ex eup:ex name:name];
   [xQ release];
   [xF release];
   [ex release];
   
   return x;
}
+(id<ORFloatVar>) floatInputVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up name:(NSString*) name
{
   id<ORRational> negInf = [[ORRational alloc] init];
   id<ORRational> posInf = [[ORRational alloc] init];
   [negInf setNegInf];
   [posInf setPosInf];
   id<ORFloatVar> x = [[ORFloatVarI alloc]  init: tracker low: low up: up elow: negInf eup: posInf name:name inputVar:true];
   id<ORRationalVar> ex = [ORFactory errorVar:tracker of:x];
   id<ORRationalVar> ulp = [ORFactory ulpVar:tracker of:x];
   [tracker add:[ex leq:ulp]];
   [tracker add:[ex geq:ulp]];
   [negInf release];
   [posInf release];
   
   return x;
}
+(id<ORFloatVar>) floatInputVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up elow:(id<ORRational>) elow eup:(id<ORRational>) eup name:(NSString*) name
{
   return [[ORFloatVarI alloc]  init: tracker low: low up: up elow: elow eup: eup name:name inputVar:true];
}
+(id<ORRationalVar>) ulpVar: (id<ORTracker>) mdl of:(id<ORVar>)f
{
   id<ORRational> low = [[[ORRational alloc] init] setNegInf];
   id<ORRational> up =  [[[ORRational alloc] init] setPosInf];
   ORRationalVarI* r = [[ORRationalVarI alloc] init: mdl
                                                 low:low
                                                  up:up
                                                name:[NSString stringWithFormat:@"ulp(%@)",[f prettyname]]];
   id<ORConstraint> c = [ORFactory ulpOf:mdl var:f is:r];
   [mdl add: c];
   [low release];
   [up release];
   return r;
}
+(id<ORDoubleVar>) doubleVar: (id<ORTracker>) tracker low:(ORDouble) low up: (ORDouble) up
{
    return [[ORDoubleVarI alloc]  init: tracker low: low up: up];
}
+(id<ORDoubleVar>) doubleVar: (id<ORTracker>) tracker domain:(id<ORDoubleRange>) dom
{
    return [[ORDoubleVarI alloc]  init: tracker domain:dom];
}
+(id<ORDoubleVar>) doubleVar: (id<ORTracker>) tracker
{
    return [[ORDoubleVarI alloc]  init: tracker];
}
+(id<ORDoubleVar>) doubleVar: (id<ORTracker>) tracker low:(ORDouble) low up: (ORDouble) up name:(NSString*) name
{
   return [[ORDoubleVarI alloc]  init: tracker low: low up: up name:name];
}
+(id<ORDoubleVar>) doubleVar: (id<ORTracker>) tracker low:(ORDouble) low up: (ORDouble) up elow:(id<ORRational>) elow eup:(id<ORRational>) eup name:(NSString*) name
{
   return [[ORDoubleVarI alloc]  init: tracker low: low up: up elow: elow eup: eup name:name];
}
+(id<ORDoubleVar>) doubleVar: (id<ORTracker>) tracker domain:(id<ORDoubleRange>) dom name:(NSString*) name
{
   return [[ORDoubleVarI alloc]  init: tracker domain:dom name:name];
}
+(id<ORDoubleVar>) doubleVar: (id<ORTracker>) tracker name:(NSString*) name
{
   return [[ORDoubleVarI alloc]  init: tracker name:name];
}
+(id<ORLDoubleVar>) ldoubleVar: (id<ORTracker>) tracker low:(ORLDouble) low up: (ORLDouble) up
{
    return [[ORLDoubleVarI alloc]  init: tracker low: low up: up];
}
+(id<ORLDoubleVar>) ldoubleVar: (id<ORTracker>) tracker domain:(id<ORLDoubleRange>) dom
{
    return [[ORLDoubleVarI alloc]  init: tracker domain:dom];
}
+(id<ORLDoubleVar>) ldoubleVar: (id<ORTracker>) tracker
{
    return [[ORLDoubleVarI alloc]  init: tracker];
}
//---------------------------------
+(id<ORBitVar>) bitVar:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORUInt)bLen
{
   return [[ORBitVarI alloc] initORBitVarI:tracker low:low up:up bitLength:bLen];
}
+(id<ORBitVar>) bitVar:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORUInt)bLen name:(NSString*) name
{
   return [[ORBitVarI alloc] initORBitVarI:tracker low:low up:up bitLength:bLen name:name];
}
+(id<ORBitVar>) bitVar:(id<ORTracker>)tracker withLength:(ORUInt)bLen
{
   ORUInt wordLength = (bLen / 32) + ((bLen % 32 != 0) ? 1: 0);
   ORUInt* up = alloca(sizeof(ORUInt)*wordLength);
   ORUInt* low = alloca(sizeof(ORUInt)*wordLength);
   
   for (int i = 0; i<wordLength; i++) {
      low[i] = 0x00000000;
      up[i] = 0xFFFFFFFF;
   }
   ORUInt binLW = bLen % 32; // bits in last word
   ORUInt mask = 0xFFFFFFFF >> (32 - binLW);
   up[wordLength-1] = 0xFFFFFFFF & mask;
   return [[ORBitVarI alloc] initORBitVarI:tracker low:low up:up bitLength:bLen];
}
+(id<ORBindingArray>) bindingArray: (id<ORTracker>) tracker nb: (ORInt) nb
{
   return [[ORBindingArrayI alloc] initORBindingArray: nb];
}
+(id<ORFloatVarArray>) floatVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range low:(ORFloat)low up:(ORFloat)up
{
    id<ORIdArray> o = [ORFactory idArray:tracker range:range];
    for(ORInt k=range.low;k <= range.up;k++)
        [o set:[ORFactory floatVar:tracker low:low up:up] at:k];
    return (id<ORFloatVarArray>)o;
}
+(id<ORFloatVarArray>) floatVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
    id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   //[hzi : we should not init var, because it used as storage]
//    for(ORInt k=range.low;k <= range.up;k++)
//        [o set:[ORFactory floatVar:tracker] at:k];
    return (id<ORFloatVarArray>)o;
}
+(id<ORFloatVarArray>) floatVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range names: (NSString*) name
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:[ORFactory floatVar:tracker name:[NSString stringWithFormat:@"%@[%d]",name,k]] at:k];
   return (id<ORFloatVarArray>)o;
}
+(id<ORFloatVarArray>) floatVarArray:(id<ORTracker>) tracker range: (id<ORIntRange>) range clo:(id<ORFloatVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:clo(k) at:k];
   return (id<ORFloatVarArray>)o;
}
+(id<ORDisabledVarArray>) disabledFloatVarArray:(id<ORVarArray>) vars engine:(id<ORSearchEngine>) engine
{
    [[ORDisabledVarArrayI alloc] init:vars engine:engine];
    id<ORDisabledVarArray> r = [[ORDisabledVarArrayI alloc] init:vars engine:engine];
    [engine trackObject: r];
    return r;
}
+(id<ORDisabledVarArray>) disabledFloatVarArray:(id<ORVarArray>) vars engine:(id<ORSearchEngine>) engine initials:(id<ORIntArray>) iarray
{
    id<ORDisabledVarArray> r = [[ORDisabledVarArrayI alloc] init:vars engine:engine initials:iarray];
    [engine trackObject: r];
    return r;
}
+(id<ORDisabledVarArray>) disabledFloatVarArray:(id<ORVarArray>) vars engine:(id<ORSearchEngine>) engine nbFixed:(ORUInt)nb
{
   id<ORDisabledVarArray> r =  [[ORDisabledVarArrayI alloc] init:vars engine:engine nbFixed:nb];
    [engine trackObject: r];
    return r;
}
+(id<ORDisabledVarArray>) disabledFloatVarArray:(id<ORVarArray>) ovars varabs:(NSArray *) absvars solver:(id<ORSearchEngine>)p nbFixed:(ORUInt)nb
{
   ORInt size = (ORInt)([absvars count] + [ovars count]);
   id<ORFloatVarArray> keeped = [ORFactory floatVarArray:p range:RANGE(p, 0, size-1)];
   id<ORIntArray> ia = [ORFactory intArray:p range:keeped.range value:1];
   ORInt i = 0;
   for(id<ORFloatVar> x in ovars){
      keeped[i++] = x;
   }
   for(id<ORFloatVar> x in absvars){
      keeped[i] = x;
      ia[i++] = @(0);
   }
   return [ORFactory disabledFloatVarArray:keeped engine:p initials:ia nbFixed:nb];
}
+(id<ORDisabledVarArray>) disabledFloatVarArray:(id<ORVarArray>) vars engine:(id<ORSearchEngine>) engine initials:(id<ORIntArray>) iarray nbFixed:(ORUInt)nb
{
   id<ORDisabledVarArray> r = [[ORDisabledVarArrayI alloc] init:vars engine:engine initials:iarray nbFixed:nb];
    [engine trackObject: r];
    return r;
}

+(id<ORRationalVarArray>) rationalVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range low:(id<ORRational>)low up:(id<ORRational>)up
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:[ORFactory rationalVar:tracker low:low up:up] at:k];
   return (id<ORRationalVarArray>)o;
}
+(id<ORRationalVarArray>) rationalVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:[ORFactory rationalVar:tracker] at:k];
   return (id<ORRationalVarArray>)o;
}
+(id<ORRationalVarArray>) rationalVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range names: (NSString*) name
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:[ORFactory rationalVar:tracker name:[[NSString alloc] initWithFormat:@"%@[%d]",name,k]] at:k];
   return (id<ORRationalVarArray>)o;
}
+(id<ORRationalVarArray>) rationalVarArray:(id<ORTracker>) tracker range: (id<ORIntRange>) range clo:(id<ORRationalVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:clo(k) at:k];
   return (id<ORRationalVarArray>)o;
}
+(id<ORDisabledRationalVarArray>) disabledRationalVarArray:(id<ORVarArray>) vars engine:(id<ORSearchEngine>) engine
{
   return [[ORDisabledRationalVarArrayI alloc] init:vars engine:engine];
}
+(id<ORDoubleVarArray>) doubleVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range low:(ORDouble)low up:(ORDouble)up
{
    id<ORIdArray> o = [ORFactory idArray:tracker range:range];
    for(ORInt k=range.low;k <= range.up;k++)
        [o set:[ORFactory doubleVar:tracker low:low up:up] at:k];
    return (id<ORDoubleVarArray>)o;
}
+(id<ORDoubleVarArray>) doubleVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
    id<ORIdArray> o = [ORFactory idArray:tracker range:range];
    return (id<ORDoubleVarArray>)o;
}
+(id<ORDoubleVarArray>) doubleVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range names: (NSString*) name
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:[ORFactory doubleVar:tracker name:[NSString stringWithFormat:@"%@[%d]",name,k]] at:k];
   return (id<ORDoubleVarArray>)o;
}
+(id<ORLDoubleVarArray>) ldoubleVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range low:(ORLDouble)low up:(ORLDouble)up
{
    id<ORIdArray> o = [ORFactory idArray:tracker range:range];
    for(ORInt k=range.low;k <= range.up;k++)
        [o set:[ORFactory ldoubleVar:tracker low:low up:up] at:k];
    return (id<ORLDoubleVarArray>)o;
}
+(id<ORLDoubleVarArray>) ldoubleVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
    id<ORIdArray> o = [ORFactory idArray:tracker range:range];
    return (id<ORLDoubleVarArray>)o;
}
+(id<ORRealVarArray>) realVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range low:(ORDouble)low up:(ORDouble)up
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:[ORFactory realVar:tracker low:low up:up] at:k];
   return (id<ORRealVarArray>)o;
}
+(id<ORRealVarArray>) realVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range low:(ORDouble)low up:(ORDouble)up names:(NSString*) name
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:[ORFactory realVar:tracker low:low up:up name:[NSString stringWithFormat:@"%@[%d]",name,k]] at:k];
   return (id<ORRealVarArray>)o;
}
+(id<ORRealVarArray>) realVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range names:(NSString*) name
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set:[ORFactory realVar:tracker name:[NSString stringWithFormat:@"%@[%d]",name,k]] at:k];
   return (id<ORRealVarArray>)o;
}
+(id<ORRealVarArray>) realVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range 
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   return (id<ORRealVarArray>)o;
}

+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain names:(NSString*) name
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: [ORFactory intVar: tracker domain:domain name:[NSString stringWithFormat:@"%@[%d]",name,k]] at:k];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range names:(NSString*) name
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: [ORFactory intVar: tracker name:[NSString stringWithFormat:@"%@[%d]",name,k]] at:k];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: [ORFactory intVar: tracker domain:domain] at:k];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range bounds: (id<ORIntRange>) domain
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: [ORFactory intVar: tracker bounds:domain] at:k];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (id<ORIntVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++) {
      [o  set:clo(k) at:k];
   }
   return (id<ORIntVarArray>)o;
}
+(id<ORVarArray>) varArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (id<ORVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   for(ORInt k=range.low;k <= range.up;k++) {
      [o  set:clo(k) at:k];
   }
   return (id<ORVarArray>)o;
}

//+(id<ORIntVarArray>) intVarArrayDereference: (id<ORTracker>) tracker array: (id<ORIntVarArray>) x
//{
//   @throw [[ORExecutionError alloc] initORExecutionError: "intVarArrayDereference is totally obsolete"];
//   return [ORFactory intVarArray: tracker range: [x range] with: ^id<ORIntVar>(ORInt i) { return (id<ORIntVar>)([[x at:i] dereference]); }];
//}

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
+(id<ORExprArray>) arrayORExpr: (id<ORTracker>) cp range: (id<ORIntRange>) range with:(id<ORExpr>(^)(ORInt)) clo
{
   id<ORExprArray> t = (id<ORExprArray>)[ORFactory idArray:cp range:range];
   for(ORInt i=range.low;i <= range.up;i++)
      t[i] = clo(i);
   return t;
}
+(id<ORIntVarArray>) arrayORIntVar: (id<ORTracker>) cp range: (id<ORIntRange>) range with:(id<ORIntVar>(^)(ORInt)) clo
{
   return [self intVarArray:cp range:range with:clo];
}

+(id<ORIntVarArray>) arrayORIntVar: (id<ORTracker>) cp range: (id<ORIntRange>) r1 range: (id<ORIntRange>)r2  with:(id<ORIntVar>(^)(ORInt,ORInt)) clo
{
   return [self intVarArray:cp range:r1 :r2 with:clo];
}
+(id<ORTrailableIntArray>) trailableIntArray: (id<ORSearchEngine>) engine range: (id<ORIntRange>) range value: (ORInt) value
{
   id<ORIdArray> o = [ORFactory idArray:engine range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: [ORFactory trailableInt: engine value: value] at:k];
   return (id<ORTrailableIntArray>) o;
}
+(id<ORTRIntArray>) TRIntArray: (id<ORSearchEngine>) engine range: (id<ORIntRange>) R
{
   ORTRIntArrayI* o = [[ORTRIntArrayI alloc] initORTRIntArray: engine range: R];
   [engine trackMutable: o];
   return o;
}
+(id<ORTRIntMatrix>) TRIntMatrix: (id<ORSearchEngine>) engine range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
{
   ORTRIntMatrixI* o = [[ORTRIntMatrixI alloc] initORTRIntMatrix: engine range: R1 : R2];
   [engine trackMutable: o];
   return o;
}

+(id<ORTable>) table: (id<ORTracker>) tracker arity: (int) arity
{
   ORTableI* o = [[ORTableI alloc] initORTableI: arity];
   [tracker trackMutable: o];
   return o;
}

+(id<ORTable>) table: (id<ORTracker>) tracker with: (ORTableI*) table
{
   ORTableI* o = [[ORTableI alloc] initORTableWithTableI: table];
   [tracker trackMutable: o];
   return o;
}
+(id<ORAutomaton>)automaton:(id<ORTracker>)tracker alphabet:(id<ORIntRange>)a states:(id<ORIntRange>)s transition:(ORTransition*)tf size:(ORInt)stf
                    initial:(ORInt)is
                      final:(id<ORIntSet>)fs
{
   id<ORTable> tt = [self table:tracker arity:3];
   ORAutomatonI* o = [[ORAutomatonI alloc] init:a states:s transition:tf size:stf initial:is final:fs table:tt];
   return [tracker trackImmutable:o];
}
+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range: r0 : r1];
   for(ORInt i=[r0 low];i <= [r0 up];i++)
      for(ORInt j= [r1 low];j <= [r1 up];j++)
         [o set:[ORFactory intVar:cp domain:domain] at:i :j];
   return (id<ORIntVarMatrix>)o;
}
+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 bounds: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range: r0 : r1];
   for(ORInt i=[r0 low];i <= [r0 up];i++)
      for(ORInt j= [r1 low];j <= [r1 up];j++)
         [o set:[ORFactory intVar:cp bounds:domain] at:i :j];
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
+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 bounds: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(ORInt i= [r0 low];i <= [r0 up]; i++)
      for(ORInt j= [r1 low]; j <= [r1 up]; j++)
         for(ORInt k= [r2 low]; k <= [r2 up];k++)
            [o set:[ORFactory intVar:cp bounds:domain] at:i :j :k];
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
      [flat set:[m flat:i] at:i];
   return (id<ORIntVarArray>)flat;
}
+(id<ORVarLitterals>) varLitterals: (id<ORTracker>) tracker var: (id<ORIntVar>) v
{
   id<ORVarLitterals> l = [[ORVarLitterals alloc] initORVarLitterals: tracker var: v];
   return [tracker trackImmutable: l];
}
+(id<ORAnnotation>) annotation
{
   return [[ORAnnotation alloc] init];
}
+(id<ORSolutionInformer>) solutionInformer
{
   return [ORConcurrency solutionInformer];
}
@end

@implementation ORFactory (Expressions)
+(id<ORExpr>) validate:(id<ORExpr>)e onError:(const char*)str track:(id<ORTracker>)cp
{
   if (cp == NULL) 
      @throw [[ORExecutionError alloc] initORExecutionError: str]; 
   [cp trackObject: e];
   return e;   
}
+(id<ORExpr>) exprUnaryMinus: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprUnaryMinusI alloc] initORExprUnaryMinusI:right];
   [self validate:o onError:"No CP tracker in Assign Expression" track:t];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left set: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORRelation> o = [[ORExprAssignI alloc] initORExprAssignI: left and: right];
   [self validate:o onError:"No CP tracker in Assign Expression" track:t];
   return o;
}
+(id<ORExpr>) expr: (id<ORExpr>) left plus: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprPlusI alloc] initORExprPlusI: left and: right];
   return [self validate:o onError:"No CP tracker in Add Expression" track:t];
}
+(id<ORExpr>) expr: (id<ORExpr>) left sub: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprMinusI alloc] initORExprMinusI: left and: right];
   return [self validate:o onError:"No CP tracker in Sub Expression" track:t];
}
+(id<ORExpr>) expr: (id<ORExpr>) left mul: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprMulI alloc] initORExprMulI: left and: right];
   return [self validate:o onError:"No CP tracker in Mul Expression" track:t];
}
+(id<ORExpr>) expr: (id<ORExpr>) left div: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprDivI alloc] initORExprDivI: left and: right];
   return [self validate:o onError:"No CP tracker in Div Expression" track:t];
}
+(id<ORExpr>) expr: (id<ORExpr>) left mod: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprModI alloc] initORExprModI: left mod: right];
   return [self validate:o onError:"No CP tracker in Mod Expression" track:t];
}
+(id<ORExpr>) expr: (id<ORExpr>) left min: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprMinI alloc] initORExprMinI: left min: right];
   return [self validate:o onError:"No CP tracker in min Expression" track:t];
}
+(id<ORExpr>) expr: (id<ORExpr>) left max: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprMaxI alloc] initORExprMaxI: left max: right];
   return [self validate:o onError:"No CP tracker in max Expression" track:t];
}
+(id<ORRelation>) expr: (id<ORExpr>) left equal: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORRelation> o = [[ORExprEqualI alloc] initORExprEqualI: left and: right]; 
   [self validate:o onError:"No CP tracker in == Expression" track:t];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left neq: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORRelation> o = [[ORExprNotEqualI alloc] initORExprNotEqualI: left and: right];
   [self validate:o onError:"No CP tracker in != Expression" track:t];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left leq: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: left and: right];
   [self validate:o onError:"No CP tracker in <= Expression" track:t];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left geq: (id<ORExpr>) right track:(id<ORTracker>)t
{
   id<ORRelation> o = [[ORExprGEqualI alloc] initORExprGEqualI: left and: right];
   [self validate:o onError:"No CP tracker in >= Expression" track:t];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left lt: (id<ORExpr>) right track:(id<ORTracker>)t
{
    id<ORRelation> o = [[ORExprLThenI alloc] initORExprLThenI: left and: right];
    [self validate:o onError:"No CP tracker in < Expression" track:t];
    return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left gt: (id<ORExpr>) right track:(id<ORTracker>)t
{
    id<ORRelation> o = [[ORExprGThenI alloc] initORExprGThenI: left and: right];
    [self validate:o onError:"No CP tracker in > Expression" track:t];
    return o;
}
+(id<ORExpr>) expr: (id<ORRelation>) left land: (id<ORRelation>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORConjunctI alloc] initORConjunctI:left and:right];
   return [self validate:o onError:"No CP tracker in && Expression" track:t];
}
+(id<ORExpr>) expr: (id<ORRelation>) left lor: (id<ORRelation>) right track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORDisjunctI alloc] initORDisjunctI:left or:right];
   return [self validate:o onError:"No CP tracker in || Expression" track:t];
}
+(id<ORExpr>) expr: (id<ORRelation>) left imply: (id<ORRelation>) right  track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORImplyI alloc] initORImplyI:left imply:right];
   return [self validate:o onError:"No CP tracker in => Expression" track:t];
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
+(id<ORExpr>) elt: (id<ORTracker>) tracker intVarMatrix: (id<ORIntVarMatrix>) m elt:(id<ORExpr>) e0 elt:(id<ORExpr>)e1
{
   id<ORExpr> o = [[ORExprMatrixVarSubI alloc] initORExprMatrixVarSubI:m elt:e0 elt:e1];
   [tracker trackObject:o];
   return o;
}
+(id<ORExpr>) elt: (id<ORTracker>) tracker floatArray: (id<ORFloatArray>) a index: (id<ORExpr>) index
{
    id<ORExpr> o = [[ORExprCstFloatSubI alloc] initORExprCstFloatSubI: a index: index];
    [tracker trackObject: o];
    return o;
}
+(id<ORExpr>) elt: (id<ORTracker>) tracker rationalArray: (id<ORRationalArray>) a index: (id<ORExpr>) index
{
   id<ORExpr> o = [[ORExprCstRationalSubI alloc] initORExprCstRationalSubI: a index: index];
   [tracker trackObject: o];
   return o;
}
+(id<ORExpr>) elt: (id<ORTracker>) tracker doubleArray: (id<ORDoubleArray>) a index: (id<ORExpr>) index
{
   id<ORExpr> o = [[ORExprCstDoubleSubI alloc] initORExprCstDoubleSubI: a index: index];
   [tracker trackObject: o];
   return o;
}
+(id<ORExpr>) exprAbs: (id<ORExpr>) op track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprAbsI alloc] initORExprAbsI:op];
   return [self validate:o onError:"No CP tracker in Abs Expression" track:t];
}
+(id<ORExpr>) exprSqrt: (id<ORExpr>) op track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprSqrtI alloc] initORExprSqrtI:op];
   return [self validate:o onError:"No CP tracker in Abs Expression" track:t];
}
+(id<ORExpr>) exprSquare: (id<ORExpr>) op track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprSquareI alloc] initORExprSquareI:op];
   return [self validate:o onError:"No CP tracker in Square Expression" track:t];
}
+(id<ORExpr>) exprNegate: (id<ORExpr>) op track:(id<ORTracker>)t
{
   id<ORExpr> o = [[ORExprNegateI alloc] initORNegateI:op];
   return [self validate:o onError:"No CP tracker in negate Expression" track:t];
}
+(id<ORExpr>) sum: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   ORExprSumI* o = [[ORExprSumI alloc] init: tracker over: S suchThat: f of: e];
   return [tracker trackObject: o];
}
+(id<ORExpr>) sum:  (id<ORTracker>) tracker over: (id<ORIntIterable>) S1 over: (id<ORIntIterable>) S2
         suchThat: (ORIntxInt2Bool) f
               of: (ORIntxInt2Expr) e
{
    ORExprSumI* o = [[ORExprSumI alloc] init: tracker over: S1 over: S2 suchThat: f of: e];
    return [tracker trackObject: o];
}
+(id<ORExpr>) prod: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   ORExprProdI* o = [[ORExprProdI alloc] init: tracker over: S suchThat: f of: e];
   return [tracker trackObject: o];
}
+(id<ORRelation>) lor: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   ORExprAggOrI* o = [[ORExprAggOrI alloc] init: tracker over: S suchThat: f of: e];
   return [tracker trackObject: o];
}
+(id<ORRelation>) land: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   ORExprAggAndI* o = [[ORExprAggAndI alloc] init: tracker over: S suchThat: f of: e];
   return [tracker trackObject: o];
}
+(id<ORExpr>) min: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   ORExprAggMinI* o = [[ORExprAggMinI alloc] init: tracker over: S suchThat: f of: e];
   return [tracker trackObject: o];
}
+(id<ORExpr>) max: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   ORExprAggMaxI* o = [[ORExprAggMaxI alloc] init: tracker over: S suchThat: f of: e];
   return [tracker trackObject: o];
}
@end

// =====================================================================================================================
// ORFactory (Modeling constraints)
// =====================================================================================================================

@implementation ORFactory (Constraints)
+(id<ORConstraint>) fail:(id<ORTracker>)model
{
   id<ORConstraint> o = [[ORFail alloc] init];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) restrict:(id<ORTracker>)model var:(id<ORIntVar>)x to:(id<ORIntSet>)d
{
   id<ORConstraint> o = [[ORRestrict alloc] initRestrict:x to:d];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) imply:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i
{
    id<ORConstraint> o = [[ORImplyEqualc alloc] initImply: b equiv:x eqi: i];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i
{
   id<ORConstraint> o = [[ORReifyEqualc alloc] initReify: b equiv:x eqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eq: (id<ORIntVar>) y
{
   id<ORConstraint> o = [[ORReifyEqual alloc] initReify: b equiv: x eq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x neq: (id<ORIntVar>) y
{
   id<ORConstraint> o = [[ORReifyNEqual alloc] initReify: b equiv: x neq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x neqi: (ORInt) i
{
   id<ORConstraint> o = [[ORReifyNEqualc alloc] initReify: b equiv: x neqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x leqi: (ORInt) i
{
   id<ORConstraint> o = [[ORReifyLEqualc alloc] initReify: b equiv: x leqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x geqi: (ORInt) i
{
   id<ORConstraint> o = [[ORReifyGEqualc alloc] initReify: b equiv: x geqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x leq: (id<ORIntVar>) y
{
   id<ORConstraint> o = [[ORReifyLEqual alloc] initReify: b equiv: x leq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x geq: (id<ORIntVar>) y
{
   id<ORConstraint> o = [[ORReifyGEqual alloc] initReify: b equiv: x geq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b sumbool:(id<ORIntVarArray>) x eqi: (ORInt) c
{
   id<ORConstraint> o = [[ORReifySumBoolEqc alloc] init:b array:x eqi: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b sumbool:(id<ORIntVarArray>) x geqi: (ORInt) c
{
   id<ORConstraint> o = [[ORReifySumBoolGEqc alloc] init:b array:x geqi: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) hreify:(id<ORTracker>)model boolean:(id<ORIntVar>) b sumbool:(id<ORIntVarArray>) x eqi: (ORInt) c
{
   id<ORConstraint> o = [[ORHReifySumBoolEqc alloc] init:b array:x eqi: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) hreify:(id<ORTracker>)model boolean:(id<ORIntVar>) b sumbool:(id<ORIntVarArray>) x geqi: (ORInt) c
{
   id<ORConstraint> o = [[ORHReifySumBoolGEqc alloc] init:b array:x geqi: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) clause:(id<ORTracker>)model over:(id<ORIntVarArray>) x equal:(id<ORIntVar>)tv
{
   id<ORConstraint> o = [[ORClause alloc] init: x eq: tv];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x geqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumBoolGEqc alloc] initSumBool: x geqi: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x leqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumBoolLEqc alloc] initSumBool: x leqi: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x eqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumBoolEqc alloc] initSumBool: x eqi: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x neqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumBoolNEqc alloc] initSumBool: x neqi: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x eqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumEqc alloc] initSum:x eqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x leqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumLEqc alloc] initSum:x leqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x geqi: (ORInt) c
{
   id<ORConstraint> o = [[ORSumGEqc alloc] initSum:x geqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sum: (id<ORTracker>) model array: (id<ORIntVarArray>) x coef: (id<ORIntArray>) coef  eq: (ORInt) c
{
   id<ORConstraint> o = [[ORLinearEq alloc] initLinearEq: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sum: (id<ORTracker>) model array: (id<ORIntVarArray>) x coef: (id<ORIntArray>) coef  leq: (ORInt) c
{
   id<ORConstraint> o = [[ORLinearLeq alloc] initLinearLeq: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) sumSquare: (id<ORTracker>) model array: (id<ORVarArray>) x eq: (id<ORVar>) res
{
   id<ORConstraint> o = [[ORSumSquare alloc] init: x eq:res];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x lor:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[OROr alloc] initOROr:b eq:x or:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x land:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[ORAnd alloc] initORAnd:b eq:x and:y];
   [model trackObject:o];
   return o;
}

+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[ORImply alloc] initORImply:b eq:x imply:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[ORBinImply alloc] init:x imply:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) equal:(id<ORTracker>)model  var:(id<ORVar>) x to: (id<ORVar>) y plus:(int) c
{
   id<ORConstraint> o = [[OREqual alloc] initOREqual:x eq:y plus:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) model:(id<ORTracker>)model var:(id<ORIntVar>)y equal:(ORInt)a times:(id<ORIntVar>)x plus:(ORInt)b
{
   id<ORConstraint> o = [[ORAffine alloc] initORAffine:y eq:a times:x plus:b];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) equal3:(id<ORTracker>)model  var: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(id<ORIntVar>) z
{
   id<ORConstraint> o = [[ORPlus alloc] initORPlus:x eq:y plus:z];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) equalc:(id<ORTracker>)model  var: (id<ORIntVar>) x to:(ORInt) c
{
   id<ORConstraint> o = [[OREqualc alloc] initOREqualc:x eqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) notEqual:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(id<ORIntVar>)y plus:(int)c
{
   id<ORConstraint> o = [[ORNEqual alloc] initORNEqual:x neq:y plus:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) notEqual:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[ORNEqual alloc] initORNEqual:x neq:y];
   [model trackObject:o];
   return o;
}
+(id<ORSoftConstraint>) softNotEqual:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(id<ORIntVar>)y plus:(int)c slack: (id<ORVar>)slack
{
    id<ORSoftConstraint> o = [[ORSoftNEqual alloc] initORSoftNEqual:x neq:y plus:c slack: slack];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) notEqualc:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(ORInt)c
{
   id<ORConstraint> o = [[ORNEqualc alloc] initORNEqualc:x neqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y
{
   id<ORConstraint> o = [[ORLEqual alloc] initORLEqual:x leq:y plus:0];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y plus:(ORInt)c
{
   id<ORConstraint> o = [[ORLEqual alloc] initORLEqual:x leq:y plus:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) geq:(id<ORTracker>)model  x: (id<ORIntVar>)x y: (id<ORIntVar>) y plus:(ORInt)c
{
   return [self lEqual: model var: y to: x plus: -c];
}
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  coef:(ORInt)a times: (id<ORIntVar>)x leq:(ORInt)b times:(id<ORIntVar>) y plus:(ORInt)c
{
   id<ORConstraint> o = [[ORLEqual alloc] initORLEqual:a times:x leq:b times:y plus:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) lEqualc:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (ORInt) c
{
   id<ORConstraint> o = [[ORLEqualc alloc] initORLEqualc:x leqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) gEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y // x >= y
{   
   id<ORConstraint> o = [[ORLEqual alloc] initORLEqual:y leq:x plus:0];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) gEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y plus:(ORInt)c // x >= y + c <=> y <= x - c
{
   id<ORConstraint> o = [[ORLEqual alloc] initORLEqual:y leq:x plus:-c];
   [model trackObject:o];
   return o;   
}
+(id<ORConstraint>) gEqualc:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (ORInt) c
{
   id<ORConstraint> o = [[ORGEqualc alloc] initORGEqualc:x geqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) less:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y
{
   id<ORIntVar> yp = [self intVar:[x tracker] var:y shift:-1];
   id<ORConstraint> o = [self lEqual:model var:x to:yp plus:0];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) mult:(id<ORTracker>)model  var: (id<ORIntVar>)x by:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   if ([x getId] == [y getId]) {
      id<ORConstraint> o = [[ORSquare alloc] init:z square:x];
      [model trackObject:o];
      return o;
   } else {
      id<ORConstraint> o = [[ORMult alloc] initORMult:z eq:x times:y];
      [model trackObject:o];
      return o;
   }
}
+(id<ORConstraint>) square:(id<ORTracker>)model var:(id<ORVar>)x equal:(id<ORVar>)res
{
   id<ORConstraint> o = [[ORSquare alloc] init:res square:x];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) mod:(id<ORTracker>)model var:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   id<ORConstraint> o = [[ORMod alloc] initORMod:x mod:y equal:z];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) mod:(id<ORTracker>)model var:(id<ORIntVar>)x modi:(ORInt)c equal:(id<ORIntVar>)z
{
   id<ORConstraint> o = [[ORModc alloc] initORModc:x mod:c equal:z];
   [model trackObject:o];
   return o;
}

+(id<ORConstraint>) min:(id<ORTracker>)model var:(id<ORIntVar>)x land:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   id<ORConstraint> o = [[ORMin alloc] init:x and:y equal:z];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) max:(id<ORTracker>)model var:(id<ORIntVar>)x land:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   id<ORConstraint> o = [[ORMax alloc] init:x and:y equal:z];
   [model trackObject:o];
   return o;   
}
+(id<ORConstraint>) abs:(id<ORTracker>)model  var: (id<ORIntVar>)x equal:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[ORAbs alloc] initORAbs:y eqAbs:x];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[ORElementCst alloc]  initORElement:x array:c equal:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORIntVar>)x idxVarArray:(id<ORIntVarArray>)c equal:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[ORElementVar alloc] initORElement:x array:c equal:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORBitVar>)x idxBitVarArray:(id<ORIdArray>)c equal:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORElementBitVar alloc] initORElement:x array:c equal:y];
   [model trackObject:o];
   return o;
}

+(id<ORConstraint>)element:(id<ORTracker>)model matrix:(id<ORIntVarMatrix>)m elt:(id<ORIntVar>)v0 elt:(id<ORIntVar>)v1
                     equal:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[ORElementMatrixVar alloc] initORElement:m elt:v0 elt:v1 equal:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) lex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y
{
   id<ORConstraint> o = [[ORLexLeq alloc] initORLex:x leq:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) circuit: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORCircuit alloc] initORCircuit:x];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) path: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORPath alloc] initORPath:x];
   [[x tracker] trackObject:o];
   return o;
}

+(id<ORConstraint>) subCircuit: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORSubCircuit alloc] initORSubCircuit:x];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) nocycle: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORNoCycleI alloc] initORNoCycleI:x];
   [[x tracker] trackObject:o];
   return o;
}

+(id<ORConstraint>) packing:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load
{
   id<ORConstraint> o = [[ORPackingI alloc] initORPackingI:item itemSize:itemSize load:load];
   [t trackObject:o];
   return o;
}
+(id<ORConstraint>) multiknapsack:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize capacity: (id<ORIntArray>) capacity
{
   id<ORConstraint> o = [[ORMultiKnapsackI alloc] initORMultiKnapsackI:item itemSize:itemSize capacity:capacity];
   [t trackObject:o];
   return o;
}
+(id<ORConstraint>) multiknapsackOne:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) bin capacity: (ORInt) capacity
{
   id<ORConstraint> o = [[ORMultiKnapsackOneI alloc] initORMultiKnapsackOneI:item itemSize:itemSize bin: bin capacity:capacity];
   [t trackObject:o];
   return o;
}
+(id<ORConstraint>) meetAtmost:(id<ORTracker>)t x:(id<ORIntVarArray>) x y: (id<ORIntVarArray>) y atmost: (ORInt) atmost
{
   id<ORConstraint> o = [[ORMeetAtmostI alloc] initORMeetAtmostI: x and: y atmost: atmost];
   [t trackObject:o];
   return o;

}
+(id<ORConstraint>) packOne:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize
{
   id<ORConstraint> o = [[ORPackOneI alloc] initORPackOneI:item itemSize:itemSize bin:b binSize:binSize];
   [t trackObject:o];
   return o;
}
+(id<ORConstraint>) knapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c
{
   id<ORConstraint> o = [[ORKnapsackI alloc] initORKnapsackI:x weight:w capacity:c];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORSoftConstraint>) softKnapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c slack: (id<ORVar>) slack
{
    id<ORSoftConstraint> o = [[ORSoftKnapsackI alloc] initORSoftKnapsackI: x weight: w capacity: c slack: slack];
    [[x tracker] trackObject:o];
    return o;
}
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[ORAlldifferentI alloc] initORAlldifferentI:x];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) regular:(id<ORIntVarArray>) x belongs:(id<ORAutomaton>)a
{
   id<ORConstraint> o = [[ORRegularI alloc] init:x for:a];
   [[x tracker] trackObject:o];
   return o;
}

+(id<ORConstraint>) packing:(id<ORTracker>)t item: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntArray>) binSize
{
   // Rewritten in terms of the variable-driven load form.
   id<ORIntRange> R = [binSize range];
   id<ORIntVarArray> load = (id<ORIntVarArray>)[ORFactory idArray:[item tracker] range:R];
   [binSize enumerateWith:^(ORInt bk, int k) {
      load[k] = [ORFactory intVar:[item tracker] domain:RANGE([item tracker],0,bk)];
   }];
   id<ORConstraint> o =  [self packing:t item:item itemSize:itemSize load:load];
   return o;
}
+(id<ORConstraint>) algebraicConstraint:(id<ORTracker>) model expr: (id<ORRelation>) exp
{
   id<ORConstraint> o = [[ORAlgebraicConstraintI alloc] initORAlgebraicConstraintI: exp];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) tableConstraint:(id<ORIntVarArray>) x table: (ORTableI*) table
{
   id<ORConstraint> o = [[ORTableConstraintI alloc] initORTableConstraintI:x table: table];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
   id<ORConstraint> o = [[ORCardinalityI alloc] initORCardinalityI: x low: low up: up];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) tableConstraint:(id<ORTracker>)model table:(id<ORTable>) table on: (id<ORIntVar>) x : (id<ORIntVar>) y : (id<ORIntVar>) z
{
   id<ORIntRange> R = RANGE(model,0,2);
   id<ORIdArray> a = [ORFactory idArray:model range:R];
   [a set:x at:0];
   [a set:y at:1];
   [a set:z at:2];
   id<ORConstraint> o = [self tableConstraint:(id<ORIntVarArray>) a table: table];
   return o;
}

+(id<ORConstraint>) assignment:(id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost
{
   id<ORConstraint> o = [[ORAssignmentI alloc] initORAssignment:x matrix:matrix cost:cost];
   [[x tracker] trackObject:o];
   return o;
}
@end

@implementation ORFactory (ObjectiveValue)
+(id<ORObjectiveValue>) objectiveValueReal: (ORDouble) f minimize: (ORBool) b
{
   return [[ORObjectiveValueRealI alloc] initObjectiveValueRealI: f minimize: b];
}
+(id<ORObjectiveValue>) objectiveValueInt: (ORInt) v minimize: (ORBool) b
{
   return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: v minimize: b];
}
+(id<ORObjectiveValue>) objectiveValueFloat: (ORFloat) f minimize: (ORBool) b
{
   return [[ORObjectiveValueFloatI alloc] initObjectiveValueFloatI: f minimize: b];
}
+(id<ORObjectiveValue>) objectiveValueRational: (id<ORRational>) f minimize: (ORBool) b
{
   return [[ORObjectiveValueRationalI alloc] initObjectiveValueRationalI: f minimize: b];
}
@end

@implementation ORFactory (ORReal)
+(id<ORConstraint>) realMin: (id<ORTracker>) model array: (id<ORVarArray>) x eq: (id<ORVar>) res
{
   id<ORConstraint> o = [[ORRealMin alloc] init: x eq:res];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) realSquare:(id<ORTracker>)model var:(id<ORRealVar>)x equal:(id<ORRealVar>)res
{
   id<ORConstraint> o = [[ORRealSquare alloc] init:res square:x];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) realSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  eq: (ORDouble) c
{
   id<ORConstraint> o = [[ORRealLinearEq alloc] initRealLinearEq: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) realSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  leq: (ORDouble) c
{
   id<ORConstraint> o = [[ORRealLinearLeq alloc] initRealLinearLeq: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) realSum: (id<ORTracker>) model array: (id<ORRealVarArray>)x coef:(id<ORDoubleArray>)coef geq:(ORDouble)c
{
    id<ORConstraint> o = [[ORRealLinearGeq alloc] initRealLinearGeq: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) realMult:(id<ORTracker>)model  var: (id<ORVar>)x by:(id<ORVar>)y equal:(id<ORVar>)z
{
   id<ORConstraint> o = [[ORRealMult alloc] initORRealMult:z eq:x times:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) realEqualc:(id<ORTracker>)model  var: (id<ORRealVar>) x to:(ORDouble) c
{
   id<ORConstraint> o = [[ORRealEqualc alloc] init:x eqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) realElement:(id<ORTracker>)model  var:(id<ORIntVar>)x idxCstArray:(id<ORDoubleArray>)c equal:(id<ORRealVar>)y
{
   id<ORConstraint> o = [[ORRealElementCst alloc]  initORElement:x array:c equal:y];
   [model trackObject:o];
   return o;   
}

+(id<ORConstraint>) realReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRealVar>) x eqi: (ORDouble) i{
   id<ORConstraint> o = [[ORRealReifyEqualc alloc] initRealReify: b equiv:x eqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) realReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRealVar>) x geqi: (ORDouble) i{
   id<ORConstraint> o = [[ORRealReifyGEqualc alloc] initRealReify: b equiv:x geqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) realReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRealVar>) x eq: (id<ORRealVar>) y
{
   id<ORConstraint> o = [[ORRealReifyEqual alloc] initRealReify: b equiv: x eq: y];
   [model trackObject:o];
   return o;
}
@end

@implementation ORFactory (ORFloat)
+(id<ORConstraint>) floatAssignC: (id<ORTracker>) model var:(id<ORFloatVar>) x to:(ORFloat)c
{
   id<ORConstraint> o = [[ORFloatAssignC alloc] initORFloatAssignC:x to:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatEqualc: (id<ORTracker>) model var:(id<ORFloatVar>) x eqc:(ORFloat)c
{
    id<ORConstraint> o = [[ORFloatEqualc alloc] initORFloatEqualc:x eqi:c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatLThenc: (id<ORTracker>) model var:(id<ORFloatVar>) x lt:(ORFloat)c
{
   id<ORConstraint> o = [[ORFloatLThenc alloc] initORFloatLThenc:x lt:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatLEqualc: (id<ORTracker>) model var:(id<ORFloatVar>) x leq:(ORFloat)c
{
   id<ORConstraint> o = [[ORFloatLEqualc alloc] initORFloatLEqualc:x leq:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatGThenc: (id<ORTracker>) model var:(id<ORFloatVar>) x gt:(ORFloat)c
{
   id<ORConstraint> o = [[ORFloatGThenc alloc] initORFloatGThenc:x gt:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatGEqualc: (id<ORTracker>) model var:(id<ORFloatVar>) x geq:(ORFloat)c
{
   id<ORConstraint> o = [[ORFloatGEqualc alloc] initORFloatGEqualc:x geq:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatNEqualc: (id<ORTracker>) model var:(id<ORFloatVar>) x neqc:(ORFloat)c
{
    id<ORConstraint> o = [[ORFloatNEqualc alloc]initORFloatNEqualc:x neqi:c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatAssign: (id<ORTracker>) model var:(id<ORFloatVar>) x to:(id<ORFloatVar>) y
{
   id<ORConstraint> o = [[ORFloatAssign alloc] initORFloatAssign:x to:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  eq: (ORFloat) c
{
    id<ORConstraint> o = [[ORFloatLinearEq alloc] initFloatLinearEq: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  neq: (ORFloat) c
{
    id<ORConstraint> o = [[ORFloatLinearNEq alloc] initFloatLinearNEq: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  set: (ORFloat) c
{
   if([x count] <= 1){
      id<ORConstraint> o = [[ORFloatAssignC alloc] initORFloatAssignC:x[0] to:c];
      [model trackObject:o];
      return o;
   }else if([x count] == 2){
      id<ORConstraint> o = [[ORFloatAssign alloc] initORFloatAssign:x[0] to:x[1]];
      [model trackObject:o];
      return o;
   }else
      assert(NO);
}
+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  lt: (ORFloat) c
{
    id<ORConstraint> o = [[ORFloatLinearLT alloc] initFloatLinearLT: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  gt: (ORFloat) c
{
    id<ORConstraint> o = [[ORFloatLinearGT alloc] initFloatLinearGT: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  leq: (ORFloat) c
{
    id<ORConstraint> o = [[ORFloatLinearLEQ alloc] initFloatLinearLEQ: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  geq: (ORFloat) c
{
    id<ORConstraint> o = [[ORFloatLinearGEQ alloc] initFloatLinearGEQ: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatUnaryMinus:(id<ORTracker>)model  var: (id<ORFloatVar>)x eqm:(id<ORFloatVar>)y
{
   id<ORConstraint> o = [[ORFloatUnaryMinus alloc] initORFloatUnaryMinus:x eqm:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatSqrt:(id<ORTracker>)model  var: (id<ORFloatVar>)x eq:(id<ORFloatVar>)y
{
   id<ORConstraint> o = [[ORFloatSqrt alloc] initORSqrt:x eqSqrt:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatAbs:(id<ORTracker>)model  var: (id<ORFloatVar>)x eq:(id<ORFloatVar>)y
{
   id<ORConstraint> o = [[ORFloatAbs alloc] initORAbs:x eqAbs:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatMult:(id<ORTracker>)model  var: (id<ORFloatVar>)x by:(id<ORFloatVar>)y equal:(id<ORFloatVar>)z
{
    id<ORConstraint> o = [[ORFloatMult alloc] initORFloatMult:z eq:x times:y];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatDiv:(id<ORTracker>)model  var: (id<ORFloatVar>)x by:(id<ORFloatVar>)y equal:(id<ORFloatVar>)z
{
    id<ORConstraint> o = [[ORFloatDiv alloc] initORFloatDiv:z eq:x times:y];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) phi:(id<ORTracker>)model on:(id<ORExpr>) c  var: (id<ORFloatVar>)x with:(id<ORFloatVar>)y or:(id<ORFloatVar>)z
{
    //correspond to : 2 hreify one for c and one for not(c)
   id<ORConstraint> o = [[c imply:[x eq:y]] land: [[c neg] imply:[x eq:z]]];
    [model trackObject:o];
//    [model trackObject:o2];
    return o;
}
+(id<ORConstraint>) phi:(id<ORTracker>)model on_boolean:(id<ORIntVar>) b  var: (id<ORFloatVar>)x with:(id<ORFloatVar>)y or:(id<ORFloatVar>)z
{
   //correspond to : 2 hreify one for c and one for not(c)
   id<ORConstraint> o = [[b imply:[x eq:y]] land: [[b neg] imply:[x eq:z]]];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x eq: (id<ORFloatVar>) y
{
    id<ORConstraint> o = [[ORFloatReifyEqual alloc] initFloatReify: b equiv: x eq: y];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x neq: (id<ORFloatVar>) y
{
    id<ORConstraint> o = [[ORFloatReifyNEqual alloc] initFloatReify: b equiv: x neq: y];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x leq: (id<ORFloatVar>) y
{
   id<ORConstraint> o = [[ORFloatReifyLEqual alloc] initFloatReify: b equiv: x leq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x geq: (id<ORFloatVar>) y
{
   id<ORConstraint> o = [[ORFloatReifyGEqual alloc] initFloatReify: b equiv: x geq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x gt: (id<ORFloatVar>) y
{
   id<ORConstraint> o = [[ORFloatReifyGThen alloc] initFloatReify: b equiv: x gt: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x lt: (id<ORFloatVar>) y
{
   id<ORConstraint> o = [[ORFloatReifyLThen alloc] initFloatReify: b equiv: x lt: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x eqi: (ORFloat) i
{
   id<ORConstraint> o = [[ORFloatReifyEqualc alloc] initFloatReify: b equiv:x eqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x neqi: (ORFloat) i
{
    id<ORConstraint> o = [[ORFloatReifyNEqualc alloc] initFloatReify: b equiv: x neqi: i];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x leqi: (ORFloat) i
{
    id<ORConstraint> o = [[ORFloatReifyLEqualc alloc] initFloatReify: b equiv: x leqi: i];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x geqi: (ORFloat) i
{
    id<ORConstraint> o = [[ORFloatReifyGEqualc alloc] initFloatReify: b equiv: x geqi: i];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x gti: (ORFloat)c
{
   id<ORConstraint> o = [[ORFloatReifyGThenc alloc] initFloatReify: b equiv: x gti: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORFloatVar>) x lti: (ORFloat)c
{
   id<ORConstraint> o = [[ORFloatReifyLThenc alloc] initFloatReify: b equiv: x lti:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) floatCast:(id<ORTracker>)model from:(id<ORDoubleVar>) x res:(id<ORFloatVar>)var
{
   id<ORConstraint> o = [[ORFloatCast alloc] init:var eq:x];
   [model trackObject:o];
   return o;
}
+(id<ORExpr>) expr:(id<ORExpr>) e1 mul:(id<ORVar>) var power:(ORInt) i
{
   id<ORExpr> r = e1;
   for (int j = 0; j < i; j++)
      r = [r mul:var];
   return r;
}
@end

@implementation ORFactory (ORRational)
+(id<ORConstraint>) rationalAssignC: (id<ORTracker>) model var:(id<ORRationalVar>) x to:(id<ORRational>)c
{
   id<ORConstraint> o = [[ORRationalAssignC alloc] initORRationalAssignC:x to:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalEqualc: (id<ORTracker>) model var:(id<ORRationalVar>) x eqc:(id<ORRational>)c
{
   id<ORConstraint> o = [[ORRationalEqualc alloc] initORRationalEqualc:x eqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) errorOf:(id<ORTracker>)model  var:(id<ORVar>) x is: (id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalErrorOf alloc] initORRationalErrorOf:x is:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) ulpOf:(id<ORTracker>)model  var:(id<ORVar>) x is: (id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalUlpOf alloc] initORRationalUlpOf:x is:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) channel:(id<ORFloatVar>)x with:(id<ORRationalVar>)y
{
   id<ORConstraint> o = [[ORRationalChannel alloc] initORRationalChannel:x with:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalNEqualc: (id<ORTracker>) model var:(id<ORRationalVar>) x neqc:(id<ORRational>)c
{
   id<ORConstraint> o = [[ORRationalNEqualc alloc] initORRationalNEqualc:x neqi:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalLEqualc: (id<ORTracker>) model var:(id<ORRationalVar>) x leq:(id<ORRational>)c
{
   id<ORConstraint> o = [[ORRationalLEqualc alloc] initORRationalLEqualc:x leq:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalGEqualc: (id<ORTracker>) model var:(id<ORRationalVar>) x geq:(id<ORRational>)c
{
   id<ORConstraint> o = [[ORRationalGEqualc alloc] initORRationalGEqualc:x geq:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalAssign: (id<ORTracker>) model var:(id<ORRationalVar>) x to:(id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalAssign alloc] initORRationalAssign:x to:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORRationalArray>) coef  eq: (id<ORRational>) c
{
   id<ORConstraint> o = [[ORRationalLinearEq alloc] initRationalLinearEq: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORRationalArray>) coef  neq: (id<ORRational>) c
{
   id<ORConstraint> o = [[ORRationalLinearNEq alloc] initRationalLinearNEq: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORRationalArray>) coef  set: (id<ORRational>) c
{
   if([x count] <= 1){
      id<ORConstraint> o = [[ORRationalAssignC alloc] initORRationalAssignC:x[0] to:c];
      [model trackObject:o];
      return o;
   }else if([x count] == 2){
      id<ORConstraint> o = [[ORRationalAssign alloc] initORRationalAssign:x[0] to:x[1]];
      [model trackObject:o];
      return o;
   }else
      assert(NO);
}
+(id<ORConstraint>) rationalSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORRationalArray>) coef  lt: (id<ORRational>) c
{
   id<ORConstraint> o = [[ORRationalLinearLT alloc] initRationalLinearLT: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORRationalArray>) coef  gt: (id<ORRational>) c
{
   id<ORConstraint> o = [[ORRationalLinearGT alloc] initRationalLinearGT: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORRationalArray>) coef  leq: (id<ORRational>) c
{
   id<ORConstraint> o = [[ORRationalLinearLEQ alloc] initRationalLinearLEQ: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORRationalArray>) coef  geq: (id<ORRational>) c
{
   id<ORConstraint> o = [[ORRationalLinearGEQ alloc] initRationalLinearGEQ: x coef: coef cst: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalUnaryMinus:(id<ORTracker>)model  var: (id<ORRationalVar>)x eqm:(id<ORRationalVar>)y
{
   id<ORConstraint> o = [[ORRationalUnaryMinus alloc] initORRationalUnaryMinus:x eqm:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalMult:(id<ORTracker>)model  var: (id<ORRationalVar>)x by:(id<ORRationalVar>)y equal:(id<ORRationalVar>)z
{
   id<ORConstraint> o = [[ORRationalMult alloc] initORRationalMult:z eq:x times:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalDiv:(id<ORTracker>)model  var: (id<ORRationalVar>)x by:(id<ORRationalVar>)y equal:(id<ORRationalVar>)z
{
   id<ORConstraint> o = [[ORRationalDiv alloc] initORRationalDiv:z eq:x times:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalAbs:(id<ORTracker>)model  var: (id<ORRationalVar>)x eq:(id<ORRationalVar>)y
{
   id<ORConstraint> o = [[ORRationalAbs alloc] initORAbs:x eqAbs:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x eq: (id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalReifyEqual alloc] initRationalReify: b equiv: x eq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x neq: (id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalReifyNEqual alloc] initRationalReify: b equiv: x neq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x leq: (id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalReifyLEqual alloc] initRationalReify: b equiv: x leq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x geq: (id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalReifyGEqual alloc] initRationalReify: b equiv: x geq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x gt: (id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalReifyGThen alloc] initRationalReify: b equiv: x gt: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x lt: (id<ORRationalVar>) y
{
   id<ORConstraint> o = [[ORRationalReifyLThen alloc] initRationalReify: b equiv: x lt: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x eqi: (id<ORRational>) i
{
   id<ORConstraint> o = [[ORRationalReifyEqualc alloc] initRationalReify: b equiv:x eqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x neqi: (id<ORRational>) i
{
   id<ORConstraint> o = [[ORRationalReifyNEqualc alloc] initRationalReify: b equiv: x neqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x leqi: (id<ORRational>) i
{
   id<ORConstraint> o = [[ORRationalReifyLEqualc alloc] initRationalReify: b equiv: x leqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x geqi: (id<ORRational>) i
{
   id<ORConstraint> o = [[ORRationalReifyGEqualc alloc] initRationalReify: b equiv: x geqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x gti: (id<ORRational>)c
{
   id<ORConstraint> o = [[ORRationalReifyGThenc alloc] initRationalReify: b equiv: x gti: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) rationalReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORRationalVar>) x lti: (id<ORRational>)c
{
   id<ORConstraint> o = [[ORRationalReifyLThenc alloc] initRationalReify: b equiv: x lti:c];
   [model trackObject:o];
   return o;
}
@end

@implementation ORFactory (ORDouble)
+(id<ORConstraint>) doubleSqrt:(id<ORTracker>)model  var: (id<ORDoubleVar>)x eq:(id<ORDoubleVar>)y
{
   id<ORConstraint> o = [[ORDoubleSqrt alloc] initORSqrt:x eqSqrt:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleAbs:(id<ORTracker>)model  var: (id<ORDoubleVar>)x eq:(id<ORDoubleVar>)y
{
   id<ORConstraint> o = [[ORDoubleAbs alloc] initORAbs:x eqAbs:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleCast:(id<ORTracker>)model from:(id<ORFloatVar>) x res:(id<ORDoubleVar>)var
{
   id<ORConstraint> o = [[ORDoubleCast alloc] init:var eq:x];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleEqualc: (id<ORTracker>) model var:(id<ORDoubleVar>) x eqc:(ORDouble)c
{
    id<ORConstraint> o = [[ORDoubleEqualc alloc] initORDoubleEqualc:x eqi:c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleLThenc: (id<ORTracker>) model var:(id<ORDoubleVar>) x lt:(ORDouble)c
{
   id<ORConstraint> o = [[ORDoubleLThenc alloc] initORDoubleLThenc:x lt:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleLEqualc: (id<ORTracker>) model var:(id<ORDoubleVar>) x leq:(ORDouble)c
{
   id<ORConstraint> o = [[ORDoubleLEqualc alloc] initORDoubleLEqualc:x leq:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleGThenc: (id<ORTracker>) model var:(id<ORDoubleVar>) x gt:(ORDouble)c
{
   id<ORConstraint> o = [[ORDoubleGThenc alloc] initORDoubleGThenc:x gt:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleGEqualc: (id<ORTracker>) model var:(id<ORDoubleVar>) x geq:(ORDouble)c
{
   id<ORConstraint> o = [[ORDoubleGEqualc alloc] initORDoubleGEqualc:x geq:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleAssignC: (id<ORTracker>) model var:(id<ORDoubleVar>) x to:(ORDouble)c
{
   id<ORConstraint> o = [[ORDoubleAssignC alloc] initORDoubleAssignC:x to:c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleAssign: (id<ORTracker>) model var:(id<ORDoubleVar>) x to:(id<ORDoubleVar>) y
{
   id<ORConstraint> o = [[ORDoubleAssign alloc] initORDoubleAssign:x to:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleNEqualc: (id<ORTracker>) model var:(id<ORDoubleVar>) x neqc:(ORDouble)c
{
    id<ORConstraint> o = [[ORDoubleNEqualc alloc]initORDoubleNEqualc:x neqi:c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  eq: (ORDouble) c
{
    id<ORConstraint> o = [[ORDoubleLinearEq alloc] initDoubleLinearEq: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  neq: (ORDouble) c
{
    id<ORConstraint> o = [[ORDoubleLinearNEq alloc] initDoubleLinearNEq: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  set: (ORDouble) c
{
   if([x count] <= 1){
      id<ORConstraint> o = [[ORDoubleAssignC alloc] initORDoubleAssignC:x[0] to:c];
      [model trackObject:o];
      return o;
   }else if([x count] == 2){
      id<ORConstraint> o = [[ORDoubleAssign alloc] initORDoubleAssign:x[0] to:x[1]];
      [model trackObject:o];
      return o;
   }else
      assert(NO);
}
+(id<ORConstraint>) doubleSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  lt: (ORDouble) c
{
    id<ORConstraint> o = [[ORDoubleLinearLT alloc] initDoubleLinearLT: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  gt: (ORDouble) c
{
    id<ORConstraint> o = [[ORDoubleLinearGT alloc] initDoubleLinearGT: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  leq: (ORDouble) c
{
    id<ORConstraint> o = [[ORDoubleLinearLEQ alloc] initDoubleLinearLEQ: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  geq: (ORDouble) c
{
    id<ORConstraint> o = [[ORDoubleLinearGEQ alloc] initDoubleLinearGEQ: x coef: coef cst: c];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleUnaryMinus:(id<ORTracker>)model  var: (id<ORDoubleVar>)x eqm:(id<ORDoubleVar>)y
{
   id<ORConstraint> o = [[ORDoubleUnaryMinus alloc] initORDoubleUnaryMinus:x eqm:y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleMult:(id<ORTracker>)model  var: (id<ORDoubleVar>)x by:(id<ORDoubleVar>)y equal:(id<ORDoubleVar>)z
{
    id<ORConstraint> o = [[ORDoubleMult alloc] initORDoubleMult:z eq:x times:y];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleDiv:(id<ORTracker>)model  var: (id<ORDoubleVar>)x by:(id<ORDoubleVar>)y equal:(id<ORDoubleVar>)z
{
    id<ORConstraint> o = [[ORDoubleDiv alloc] initORDoubleDiv:z eq:x times:y];
    [model trackObject:o];
    return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x eq: (id<ORDoubleVar>) y
{
   id<ORConstraint> o = [[ORDoubleReifyEqual alloc] initDoubleReify: b equiv: x eq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x neq: (id<ORDoubleVar>) y
{
   id<ORConstraint> o = [[ORDoubleReifyNEqual alloc] initDoubleReify: b equiv: x neq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x leq: (id<ORDoubleVar>) y
{
   id<ORConstraint> o = [[ORDoubleReifyLEqual alloc] initDoubleReify: b equiv: x leq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x geq: (id<ORDoubleVar>) y
{
   id<ORConstraint> o = [[ORDoubleReifyGEqual alloc] initDoubleReify: b equiv: x geq: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x gt: (id<ORDoubleVar>) y
{
   id<ORConstraint> o = [[ORDoubleReifyGThen alloc] initDoubleReify: b equiv: x gt: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x lt: (id<ORDoubleVar>) y
{
   id<ORConstraint> o = [[ORDoubleReifyLThen alloc] initDoubleReify: b equiv: x lt: y];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x eqi: (ORDouble) i
{
   id<ORConstraint> o = [[ORDoubleReifyEqualc alloc] initDoubleReify: b equiv:x eqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x neqi: (ORDouble) i
{
   id<ORConstraint> o = [[ORDoubleReifyNEqualc alloc] initDoubleReify: b equiv: x neqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x leqi: (ORDouble) i
{
   id<ORConstraint> o = [[ORDoubleReifyLEqualc alloc] initDoubleReify: b equiv: x leqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x geqi: (ORDouble) i
{
   id<ORConstraint> o = [[ORDoubleReifyGEqualc alloc] initDoubleReify: b equiv: x geqi: i];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x gti: (ORDouble)c
{
   id<ORConstraint> o = [[ORDoubleReifyGThenc alloc] initDoubleReify: b equiv: x gti: c];
   [model trackObject:o];
   return o;
}
+(id<ORConstraint>) doubleReify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORDoubleVar>) x lti: (ORDouble)c
{
   id<ORConstraint> o = [[ORDoubleReifyLThenc alloc] initDoubleReify: b equiv: x lti:c];
   [model trackObject:o];
   return o;
}
@end

@implementation ORFactory (BV)
+(id<ORBitVarArray>) bitVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray:tracker range:range];
   return (id<ORBitVarArray>)o;
}
+(id<ORConstraint>) bvEqualBit:(id<ORTracker>)tracker var:(id<ORBitVar>)x bit:(ORInt)k with:(ORInt)val
{
   id<ORConstraint> o = [[ORBitEqualAt alloc] init:x at:k with:val];
   [tracker trackObject:o];
   return o;
}
+(id<ORConstraint>) bvEqualc:(id<ORTracker>)tracker var:(id<ORBitVar>)x to:(ORInt) c
{
   id<ORConstraint> o = [[ORBitEqualc alloc] init:x eqc:c];
   [tracker trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x booleq:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[ORBitEqBool alloc] init:x eq:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitEqual alloc] initORBitEqual:x eq:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x bor:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitOr alloc] initORBitOr:x bor:y eq:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x band:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitAnd alloc] initORBitAnd:x band:y eq:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x bnot:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitNot alloc] initORBitNot:x bnot:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x bxor:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitXor alloc] initORBitXor:x bxor:y eq:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftLBy:(ORInt)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitShiftL alloc] initORBitShiftL:x by:p eq:y];
   [[x tracker]trackObject:o];
   return o;
}
+ (id<ORConstraint>) bit:(id<ORBitVar>)x shiftLByBV:(id<ORBitVar>)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitShiftL_BV alloc] initORBitShiftL_BV:x by:p eq:y];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftRBy:(ORInt)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitShiftR alloc] initORBitShiftR:x by:p eq:y];
   [[x tracker]trackObject:o];
   return o;
}
+ (id<ORConstraint>) bit:(id<ORBitVar>)x shiftRByBV:(id<ORBitVar>)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitShiftR_BV alloc] initORBitShiftR_BV:x by:p eq:y];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftRABy:(ORInt)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitShiftRA alloc] initORBitShiftRA:x by:p eq:y];
   [[x tracker]trackObject:o];
   return o;
}
+ (id<ORConstraint>) bit:(id<ORBitVar>)x shiftRAByBV:(id<ORBitVar>)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitShiftRA_BV alloc] initORBitShiftRA_BV:x by:p eq:y];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x rotateLBy:(ORInt)p eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitRotateL alloc] initORBitRotateL:x by:p eq:y];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x plus:(id<ORBitVar>)y withCarryIn:(id<ORBitVar>)ci eq:(id<ORBitVar>)z withCarryOut:(id<ORBitVar>)co
{
   id<ORConstraint> o = [[ORBitSum alloc] initORBitSum:x plus:y in:ci eq:z out:co];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x negative:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitNegative alloc] initORBitNegative:x eq:y];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x minus:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitSubtract alloc] initORBitSubtract:x minus:y eq:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x times:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitMultiply alloc] initORBitMultiply:x times:y eq:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x dividedby:(id<ORBitVar>)y eq:(id<ORBitVar>)q rem:(id<ORBitVar>)r
{
   id<ORConstraint> o = [[ORBitDivide alloc] initORBitDivide:x dividedby:y eq:q rem:r];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x dividedbysigned:(id<ORBitVar>)y eq:(id<ORBitVar>)q rem:(id<ORBitVar>)r
{
    id<ORConstraint> o = [[ORBitDivideSigned alloc] initORBitDivideSigned:x dividedby:y eq:q rem:r];
    [[x tracker]trackObject:o];
    return o;
}

+(id<ORConstraint>) bit:(id<ORBitVar>)w trueIf:(id<ORBitVar>)x equals:(id<ORBitVar>)y zeroIfXEquals:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitIf alloc] initORBitIf:w trueIf:x equals:y zeroIfXEquals:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x count:(id<ORIntVar>)p
{
   id<ORConstraint> o = [[ORBitCount alloc] initORBitCount:x count:p];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x channel:(id<ORIntVar>)xc
{
   id<ORConstraint> o = [[ORBitChannel alloc] init:x channel:xc];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x zeroExtendTo:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitZeroExtend alloc] initORBitZeroExtend:x extendTo:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x signExtendTo:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitSignExtend alloc] initORBitSignExtend:x extendTo:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x concat:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitConcat alloc] initORBitConcat:x concat:y eq:z];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<ORBitVar>)y
{
   id<ORConstraint> o = [[ORBitExtract alloc] initORBitExtract:x from:lsb to:msb eq:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x EQ:(id<ORBitVar>)y eval:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitLogicalEqual alloc] initORBitLogicalEqual:x EQ:y eval:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x LT:(id<ORBitVar>)y eval:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitLT alloc] initORBitLT:x LT:y eval:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x LE:(id<ORBitVar>)y eval:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitLE alloc] initORBitLE:x LE:y eval:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x SLE:(id<ORBitVar>)y eval:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitSLE alloc] initORBitSLE:x SLE:y eval:z];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x SLT:(id<ORBitVar>)y eval:(id<ORBitVar>)z
{
   id<ORConstraint> o = [[ORBitSLT alloc] initORBitSLT:x SLT:y eval:z];
   [[x tracker]trackObject:o];
   return o;
}

+(id<ORConstraint>) bit:(id<ORBitVar>)i then:(id<ORBitVar>)t else:(id<ORBitVar>)e result:(id<ORBitVar>)r
{
   id<ORConstraint> o = [[ORBitITE alloc] initORBitITE:i then:t else:e result:r];
   [[i tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVarArray>)x logicalAndEval:(id<ORBitVar>)r
{
   id<ORConstraint> o = [[ORBitLogicalAnd alloc] initORBitLogicalAnd:x eval:r];
   [[r tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVarArray>)x logicalOrEval:(id<ORBitVar>)r
{
   id<ORConstraint> o = [[ORBitLogicalOr alloc] initORBitLogicalOr:x eval:r];
   [[r tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x orb:(id<ORBitVar>)y eval:(id<ORBitVar>)r
{
   id<ORConstraint> o = [[ORBitOrb alloc] initORBitOrb:x bor:y eval:r];
   [[x tracker]trackObject:o];
   return o;
}
+(id<ORConstraint>) bit:(id<ORBitVar>)x notb:(id<ORBitVar>)r
{
   id<ORConstraint> o = [[ORBitNotb alloc] initORBitNotb:x eval:r];
   [[x tracker]trackObject:o];
   return o;
}

+(id<ORConstraint>) bit:(id<ORBitVar>)x equalb:(id<ORBitVar>)y eval:(id<ORBitVar>)r
{
   id<ORConstraint> o = [[ORBitEqualb alloc] initORBitEqualb:x equal:y eval:r];
   [[x tracker]trackObject:o];
   return o;
}

+(id<ORConstraint>) bit:(id<ORBitVar>)x distinctFrom:(id<ORBitVar>)y eval:(id<ORBitVar>)r
{
   id<ORConstraint> o = [[ORBitDistinct alloc] initORBitDistinct:x distinctFrom:y eval:r];
   [[x tracker]trackObject:o];
   return o;
}

@end


@implementation OROrderedSweep

-(id)initWith:(id<ORIntIterable>)col
{
   self = [super init];
   _sz = [col size];
   _low = [col low];
   _used = malloc(sizeof(BOOL)*_sz);
   memset(_used,0,sizeof(BOOL)*_sz);
   _used -= _low;
   _col = col;
   _mxo = 2;
   _nbo = 0;
   _of = malloc(sizeof(ORInt2Double)*_mxo);
   _filter =  NULL;
   return self;
}
-(void)dealloc
{
   //NSLog(@"OROrderedSweep (%p) dealloc'd",self);
   _used += _low;
   free(_used);
   free(_best);
   free(_curr);
   for(ORInt i=0;i<_nbo;i++)
      [_of[i] release];
   free(_of);
   [_filter release];
   [super dealloc];
}
-(void)startup
{
   _best = malloc(sizeof(ORDouble)*_nbo);
   _curr = malloc(sizeof(ORDouble)*_nbo);
}
-(void)addFilter:(ORInt2Bool)f
{
   [_filter release];
   _filter = [f copy];
}

-(void)addOrdered:(ORInt2Double)f
{
   if (_nbo >= _mxo) {
      _of = realloc(_of,sizeof(ORInt2Double)*_mxo*2);
      _mxo = _mxo * 2;
   }
   _of[_nbo++] = [f copy];
}
-(void)updateBest:(ORInt)from
{
   for(ORInt i=from;i<_nbo;i++)
      _best[i] = _curr[i];
}
-(BOOL)next:(ORInt*)v
{
   __block ORInt sel = -1;
   __block BOOL found = NO;
   for(ORInt k=0;k < _nbo;k++)
      _best[k] = FDMAXINT;
   [_col enumerateWithBlock:^(ORInt i) {
      if (!_used[i]) {
         BOOL keep = !_filter || _filter(i);
         if (!keep) {
            _used[i] = YES;
            return;
         }
         for(ORInt k=0;k < _nbo;k++)
            _curr[k] = _of[k](i);
         BOOL tieBreak = YES;
         for(ORInt k=0;k < _nbo;k++) {
            if (_curr[k] < _best[k]) {
               tieBreak = NO;
               [self updateBest:k];
               sel = i;
               found = YES;
               break;
            } else if (_curr[k] > _best[k]) {
               tieBreak = NO;
               break;
            } else {
               assert(_curr[k] == _best[k]);
            }
         }
         if (tieBreak) {
            
         }
      }
   }];
   if (found) {
      _used[sel] = YES;
      *v = sel;
      return YES;
   } else {
      return NO;
   }
}
@end



