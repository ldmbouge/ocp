/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "ORFoundation/ORFoundation.h"
#import "ORUtilities/ORUtilities.h"
#import "CPFactory.h"
#import "CPData.h"
#import "CPSolverI.h"
#import "CPCreateI.h"
#import "cont.h"
#import "CPTableI.h"
#import "CPEngineI.h"
#import "ORFoundation/ORSemDFSController.h"
#import "ORFoundation/ORSemBDSController.h"
#import "CPEngineI.h"
#import "CPBitVarI.h"


@implementation CPFactory (DataStructure)
+(void) print:(id)x 
{
    printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);
}
+(CPIntVarI*) intVar: (id<CPEngine>) cp bounds: (id<ORIntRange>) range
{
   return [CPIntVarI initCPIntVar: cp bounds: range];
}
+(CPIntVarI*) intVar: (id<CPEngine>) cp domain: (id<ORIntRange>) range
{
    return [CPIntVarI initCPIntVar: cp low: [range low] up: [range up]];
}
+(CPIntVarI*) intVar: (CPIntVarI*) x shift: (ORInt) b
{
   if (b!=0)
      return [CPIntVarI initCPIntView: x withShift: b];
   else return x;
}
+(CPIntVarI*) intVar: (CPIntVarI*) x scale: (ORInt) a
{
   if (a!=1)
    return [CPIntVarI initCPIntView: x withScale: a];
   else return x;
}
+(CPIntVarI*) intVar: (CPIntVarI *) x scale: (ORInt) a shift:(ORInt) b
{
   if (a==1 && b==0)
      return x;
   else 
      return [CPIntVarI initCPIntView: x withScale: a andShift: b];
}
+(id<CPIntVar>) boolVar: (id<CPEngine>)cp
{
   return [CPIntVarI initCPBoolVar: cp];
}

+(id<CPIntVar>) negate:(id<CPIntVar>)x
{
   return [CPIntVarI initCPNegateBoolView:(CPIntVarI*)x];
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
      flat[i] = [m flat:i];
   return (id<CPIntVarArray>)flat;
}
+(id<ORIntSet>) intSet: (id<ORTracker>) cp 
{
    ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI]; 
    [cp trackObject: o];
    return o;
}
+(id<ORTable>) table: (id<ORTracker>) cp arity: (int) arity
{
   return [ORFactory table: cp arity: arity];
}
+(id<ORInformer>) informer: (id<ORTracker>) cp
{
    id<ORInformer> o = [ORConcurrency intInformer];
    [cp trackObject: o];
    return o;    
}
+(id<ORVoidInformer>) voidInformer: (id<ORTracker>) cp
{
   id<ORVoidInformer> o = [ORConcurrency voidInformer];
   [cp trackObject: o];
   return o;       
}
+(id<ORIntInformer>) intInformer: (id<ORTracker>) cp
{
   id<ORIntInformer> o = [ORConcurrency intInformer];
   [cp trackObject: o];
   return o;          
}
+(id<ORBarrier>)  barrier: (id<ORTracker>) cp value: (ORInt) nb
{
    id<ORBarrier> o = [ORConcurrency barrier: nb];
    [cp trackObject: o];
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

+(id<ORRandomStream>) randomStream: (id<ORTracker>) cp
{
   id<ORRandomStream> o = [ORCrFactory randomStream];
   [cp trackObject: o];
   return o;
}
+(id<ORZeroOneStream>) zeroOneStream: (id<ORTracker>) cp
{
   id<ORZeroOneStream> o = (id<ORZeroOneStream>) [ORCrFactory zeroOneStream];
   [cp trackObject: o];
   return o;
}
+(id<ORUniformDistribution>) uniformDistribution: (id<ORTracker>) cp range: (id<ORIntRange>) r
{
   id<ORUniformDistribution> o = (id<ORUniformDistribution>) [ORCrFactory uniformDistribution:r];
   [cp trackObject: o];
   return o;
}
@end


// Not sure how an expression can be added to the solver
@implementation CPFactory (expression)

+(id<ORExpr>) exprAbs: (id<ORExpr>) op
{
   return (id<ORExpr>)[ORFactory exprAbs:op];
}

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
+(id<ORExpr>) sum: (id<ORTracker>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   return [ORFactory sum:cp over: S suchThat:f of:e];
}
+(id<ORRelation>) or: (id<ORTracker>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   return [ORFactory or:cp over: S suchThat:f of:e];
}

@end

@implementation CPFactory (BV)
+(id<CPBitVar>) bitVar:(id<CPEngine>)engine withLow: (ORUInt*) low andUp:(ORUInt*) up andLength:(int) len
{
   return [[CPBitVarI alloc] initCPExplicitBitVarPat:engine withLow:low andUp:up andLen:len];
}
@end



