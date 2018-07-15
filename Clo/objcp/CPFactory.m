/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <objcp/CPFactory.h>
#import <objcp/CPData.h>

#import <objcp/CPBitVarI.h>
#import <objcp/CPRealVarI.h>

#import "CPTableI.h"
#import "CPBitVarI.h"
#import "CPRealVarI.h"
#import "CPFloatVarI.h"
#import "CPRationalVarI.h"
#import "CPDoubleVarI.h"
#import "CPLDoubleVarI.h"

@implementation CPFactory (DataStructure)
+(void) print:(id)x 
{
    printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);
}
+(id<CPIntVar>) intVar: (id<CPEngine>) cp value: (ORInt) value
{
   return [[CPIntVarCst alloc] initCPIntVarCst: cp value: value];
}
+(id<CPIntVar>) intVar: (id<CPEngine>) cp bounds: (id<ORIntRange>) range
{
   if ([range low] == [range up])
      return [CPFactory intVar: cp value: [range low]];
   return [CPIntVarI initCPIntVar: cp bounds: range];
}
+(id<CPIntVar>) intVar: (id<CPEngine>) cp domain: (id<ORIntRange>) range
{
   ORInt low = [range low],up = [range up];
   if (low == up)
      return [CPFactory intVar: cp value: low];
   else if (low == 0 && up==1)
      return [CPIntVarI initCPBoolVar:cp];
   else
      return [CPIntVarI initCPIntVar: cp low: low up: up];
}
+(id<CPIntVar>) intVar: (CPIntVar*) x shift: (ORInt) b
{
   if (b!=0)
      return [CPIntVarI initCPIntView: x withShift: b];
   else
      return x;
}
+(id<CPIntVar>) intVar: (CPIntVar*) x scale: (ORInt) a
{
   if (a!=1)
    return [CPIntVarI initCPIntView: x withScale: a];
   else return x;
}
+(id<CPIntVar>) intVar: (CPIntVarI *) x scale: (ORInt) a shift:(ORInt) b
{
   if (a==1 && b==0)
      return x;
   else if (a==1)
      return [CPIntVarI initCPIntView:x withShift:b];
   else if (a==-1 && b==0)
      return [CPIntVarI initCPFlipView: x];
   else
      return [CPIntVarI initCPIntView: x withScale: a andShift: b];
}
+(id<CPIntVar>) boolVar: (id<CPEngine>)cp
{
   return [CPIntVarI initCPBoolVar: cp];
}

+(id<CPIntVar>) negate:(id<CPIntVar>)x
{
   return [CPIntVarI initCPNegateBoolView:(CPIntVar*)x];
}
+(id<CPRealVar>) realVar:(id<CPEngine>)cp bounds:(id<ORRealRange>) range
{
   return [[CPRealVarI alloc] init:cp low:range.low up:range.up];
}
+(id<CPRealVar>) realVar:(id<CPEngine>)cp castFrom:(CPIntVar*)x
{
   return [[CPRealViewOnIntVarI alloc] init:cp intVar:x];
}
+(id<CPRealParam>) realParam:(id<CPEngine>)cp initialValue:(ORDouble)v
{
    return [[CPRealParamI alloc] initCPRealParam: cp initialValue: v];
}
//--------------
+(id<CPFloatVar>) floatVar:(id<CPEngine>)cp bounds:(id<ORFloatRange>) range boundsError:(id<ORRationalRange>) rangeError
{
   return [[CPFloatVarI alloc] init:cp low:range.low up:range.up errLow:rangeError.low errUp:rangeError.up];
}
+(id<CPFloatVar>) floatVar:(id<CPEngine>)cp value:(ORFloat) v
{
    return [[CPFloatVarI alloc] init:cp low:v up:v];
}
+(id<CPFloatVar>) floatVar:(id<CPEngine>)cp
{
    return [[CPFloatVarI alloc] init:cp low:-INFINITY up:INFINITY];
}
+(id<CPFloatVar>) floatVar:(id<CPEngine>)cp castFrom:(CPIntVar*)x
{
   // return [[CPFloatViewOnIntVarI alloc] init:cp intVar:x];
    assert(NO);return nil;
}
+(id<CPFloatVarArray>) floatVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range
{
    id<ORIdArray> o = [ORFactory idArray:cp range:range];
    return (id<CPFloatVarArray>) o;
}
+(id<CPFloatVarArray>) floatVarArray: (id<ORTracker>)cp range: (id<ORIntRange>) range with: (id<CPFloatVar>(^)(ORInt)) clo
{
    id<ORIdArray> o = [ORFactory idArray:cp range:range];
    for(ORInt k=range.low;k <= range.up;k++) {
        [o  set:clo(k) at:k];
    }
    return (id<CPFloatVarArray>)o;
}
//----------------------------------------

+(id<CPRationalVar>) rationalVar:(id<CPEngine>)cp bounds:(id<ORRationalRange>) range
{
   return [[CPRationalVarI alloc] init:cp low:range.low up:range.up];
}
+(id<CPRationalVar>) rationalVar:(id<CPEngine>)cp value:(ORRational*) v
{
   return [[CPRationalVarI alloc] init:cp low:v up:v];
}
+(id<CPRationalVar>) rationalVar:(id<CPEngine>)cp
{
   ORRational* low = [[ORRational alloc] init];
   ORRational* up = [[ORRational alloc] init];
   [low setNegInf];
   [up setPosInf];
   return [[CPRationalVarI alloc] init:cp low:low up:up];
}
+(id<CPRationalVar>) rationalVar:(id<CPEngine>)cp castFrom:(CPIntVar*)x
{
   // return [[CPRationalViewOnIntVarI alloc] init:cp intVar:x];
   assert(NO);return nil;
}
+(id<CPRationalVarArray>) rationalVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   return (id<CPRationalVarArray>) o;
}
+(id<CPRationalVarArray>) rationalVarArray: (id<ORTracker>)cp range: (id<ORIntRange>) range with: (id<CPRationalVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   for(ORInt k=range.low;k <= range.up;k++) {
      [o  set:clo(k) at:k];
   }
   return (id<CPRationalVarArray>)o;
}

//----------------------------------------

/*+(id<CPRationalVar>) errorVar:(id<CPEngine>)cp bounds:(id<ORRationalRange>) range
{
   return [[CPRationalVarI alloc] init:cp low:range.low up:range.up];
}*/

//----------------------------------------
+(id<CPDoubleVar>) doubleVar:(id<CPEngine>)cp
{
   return [[CPDoubleVarI alloc] init:cp low:-INFINITY up:INFINITY];
}
+(id<CPDoubleVar>) doubleVar:(id<CPEngine>)cp value:(ORDouble) v
{
    return [[CPDoubleVarI alloc] init:cp low:v up:v];
}
+(id<CPDoubleVar>) doubleVar:(id<CPEngine>)cp bounds:(id<ORDoubleRange>) range
{
    return [[CPDoubleVarI alloc] init:cp low:range.low up:range.up];
}
+(id<CPDoubleVar>) doubleVar:(id<CPEngine>)cp castFrom:(CPIntVar*)x
{
    //return [[CPDoubleViewOnIntVarI alloc] init:cp intVar:x];
    assert(NO);return nil;
}
+(id<CPLDoubleVar>) ldoubleVar:(id<CPEngine>)cp bounds:(id<ORLDoubleRange>) range
{
    return [[CPLDoubleVarI alloc] init:cp low:range.low up:range.up];
}
+(id<CPLDoubleVar>) ldoubleVar:(id<CPEngine>)cp castFrom:(id<ORLDoubleRange>)x
{
    //return [[CPLDoubleViewOnIntVarI alloc] init:cp intVar:x];
    assert(NO);return nil;
}
//--------------
+(id<CPIntSetVar>) intSetVar:(id<CPEngine>)cp withSet:(id<ORIntSet>)theSet
{
   return [[CPIntSetVarI alloc] initWith:cp set:theSet];
}
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   return [ORFactory intMatrix: tracker range: r1 : r2];
}
+(id<CPVarArray>) varArray: (id<ORTracker>) cp range: (id<ORIntRange>) range
{
   return (id<CPVarArray>)[ORFactory idArray:cp range: range];
}
+(id<CPIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   return (id<CPIntVarArray>) o;
}
+(id<CPIntVarArray>) intVarArray: (id<ORTracker>)cp range: (id<ORIntRange>) range with: (id<CPIntVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   for(ORInt k=range.low;k <= range.up;k++) {
      [o  set:clo(k) at:k];
   }
   return (id<CPIntVarArray>)o;
}

+(id<CPIntVarMatrix>) intVarMatrix: (id<CPEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range: r0 : r1];
   for(ORInt i=[r0 low];i <= [r0 up];i++)
      for(ORInt j= [r1 low];j <= [r1 up];j++)
         [o set:[CPFactory intVar:cp domain:domain] at:i :j];
    return (id<CPIntVarMatrix>)o;
}
+(id<CPIntVarMatrix>) intVarMatrix: (id<CPEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(ORInt i= [r0 low];i <= [r0 up]; i++)
      for(ORInt j= [r1 low]; j <= [r1 up]; j++)
         for(ORInt k= [r2 low]; k <= [r2 up];k++)
            [o set:[CPFactory intVar:cp domain:domain] at:i :j :k];
   return (id<CPIntVarMatrix>)o;
}
+(id<CPIntVarMatrix>) boolVarMatrix: (id<CPEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1];
   for(ORInt i= [r0 low];i <= [r0 up]; i++)
      for(ORInt j= [r1 low]; j <= [r1 up];j++)
         [o set:[CPFactory boolVar: cp] at:i :j];
   return (id<CPIntVarMatrix>)o;
}
+(id<CPIntVarMatrix>) boolVarMatrix: (id<CPEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(ORInt i= [r0 low]; i <= [r0 up]; i++)
      for(ORInt j= [r1 low]; j <= [r1 up]; j++)
         for(ORInt k= [r2 low]; k <= [r2 up]; k++)
            [o set:[CPFactory boolVar: cp] at:i :j :k];
   return (id<CPIntVarMatrix>)o;
}

+(id<CPIntVarArray>) flattenMatrix:(id<CPIntVarMatrix>)m
{
   id<ORTracker> tracker = [m tracker];
   ORInt sz = (ORInt)[m count];
   id<ORIdArray> flat = [ORFactory idArray: tracker range: RANGE(tracker,0,sz-1)];
   for(ORInt i=0;i<sz;i++)
      [flat set:[m flat:i] at:i];
   return (id<CPIntVarArray>)flat;
}
+(id<ORIntSet>) intSet: (id<ORTracker>) cp 
{
    ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI]; 
    [cp trackMutable: o];
    return o;
}
+(id<ORTable>) table: (id<ORTracker>) cp arity: (int) arity
{
   return [ORFactory table: cp arity: arity];
}

+(id<ORInformer>) informer: (id<ORTracker>) cp
{
    id<ORInformer> o = [ORConcurrency intInformer];
    [cp trackMutable: o];
    return o;    
}
+(id<ORVoidInformer>) voidInformer: (id<ORTracker>) cp
{
   id<ORVoidInformer> o = [ORConcurrency voidInformer];
   [cp trackMutable: o];
   return o;       
}
+(id<ORIntInformer>) intInformer: (id<ORTracker>) cp
{
   id<ORIntInformer> o = [ORConcurrency intInformer];
   [cp trackMutable: o];
   return o;          
}
+(id<ORBarrier>)  barrier: (id<ORTracker>) cp value: (ORInt) nb
{
    id<ORBarrier> o = [ORConcurrency barrier: nb];
    [cp trackMutable: o];
    return o;    
}

+(id<ORTRIntArray>) TRIntArray: (id<ORTracker>) cp range: (id<ORIntRange>) R
{
   return [ORFactory TRIntArray: cp range: R];   
}

+(id<ORTRIntMatrix>) TRIntMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
{
   return [ORFactory TRIntMatrix: cp range: R1 : R2];
}

@end


// Not sure how an expression can be added to the solver
@implementation CPFactory (expression)
+(id<ORExpr>) dotProduct:(id<ORIntVar>[])vars by:(int[])coefs
{
   id<ORTracker> cp = [vars[0] tracker];
   id<ORExpr> rv = nil;
   ORInt i = 0;
   while(vars[i]!=nil) {
      id<ORExpr> term = [vars[i] mul:[ORFactory integer:cp value:coefs[i]]];
      rv = rv==nil ? term : [rv plus:term];
      ++i;
   }
   return rv;
}
+(id<ORExpr>) sum: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   return [ORFactory sum:cp over: S suchThat:f of:e];
}
+(id<ORRelation>) lor: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   return [ORFactory lor:cp over: S suchThat:f of:e];
}

@end

@implementation CPFactory (BV)
+(id<CPBitVar>) bitVar:(id<CPEngine>)engine withLow: (ORUInt*) low andUp:(ORUInt*) up andLength:(unsigned int) len
{
   return [[CPBitVarI alloc] initCPExplicitBitVarPat:engine withLow:low andUp:up andLen:len];
}
+(id<CPBitVarArray>) bitVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   return (id<CPBitVarArray>) o;
}
+(id<CPBitVarArray>) bitVarArray: (id<ORTracker>)cp range: (id<ORIntRange>) range with: (id<CPBitVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   for(ORInt k=range.low;k <= range.up;k++) {
      [o  set:clo(k) at:k];
   }
   return (id<CPBitVarArray>)o;
}
@end
