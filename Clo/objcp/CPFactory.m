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
#import "CPI.h"
#import "CPCreateI.h"
#import "cont.h"
#import "CPExprI.h"
#import "CPTableI.h"
#import "CPDDeg.h"
#import "CPWDeg.h"
#import "CPIBS.h"
#import "CPFirstFail.h"
#import "CPSolverI.h"
#import "CPArrayI.h"

void failNow()
{
   static CPFailException* fex = nil;
   if (fex==nil) fex = [CPFailException new];
   @throw  CFRetain(fex);
}


@implementation CPFactory

// [ldm] I removed the autorelease. We cannot do that. The pool is embedded in the solver
// that sits inside the CoreCPI that is created by the calls below. So the pool will
// only disappear when the CPSolver goes away. Which happens when the CoreCPI goes away.
// So the pool can't be released automatically. Worse, the addition  of a release in the
// test program causes a double-deletion since the CPI is in the pool and manually released.
// Bottom line: we still have some issues with memory management. I'm going over them.
+(CPI*) createSolver
{
    return [CPI create];
}
+(SemCP*) createSemSolver
{
   return [SemCP create];
}
+(CPI*) createRandomizedSolver
{
    return [CPI createRandomized];
}
+(CPI*) createDeterministicSolver
{
    return [CPI createDeterministic];
}
+(SemCP*) createSemSolverFor:(id<CPSolver>)fdm
{
   return [[SemCP alloc] initFor:fdm];
}
+(id<CPHeuristic>) createWDeg:(id<CP>)cp restricted:(id<CPVarArray>)rvars;
{
   return [[CPWDeg alloc] initCPWDeg:cp restricted:rvars];
}
+(id<CPHeuristic>) createDDeg:(id<CP>)cp restricted:(id<CPVarArray>)rvars; 
{
   return [[CPDDeg alloc] initCPDDeg:cp restricted:rvars];
}
+(id<CPHeuristic>) createIBS:(id<CP>)cp restricted:(id<CPVarArray>)rvars;
{
   return [[CPIBS alloc] initCPIBS:cp restricted:rvars];
}
+(id<CPHeuristic>)createFF:(id<CP>)cp restricted:(id<CPVarArray>)rvars;
{
   return [[CPFirstFail alloc] initCPFirstFail:cp restricted:rvars];
}
+(id<CPHeuristic>) createWDeg:(id<CP>)cp;
{
   return [[CPWDeg alloc] initCPWDeg:cp restricted:nil];
}
+(id<CPHeuristic>) createDDeg:(id<CP>)cp 
{
   return [[CPDDeg alloc] initCPDDeg:cp restricted:nil];
}
+(id<CPHeuristic>) createIBS:(id<CP>)cp
{
   return [[CPIBS alloc] initCPIBS:cp restricted:nil];
}
+(id<CPHeuristic>)createFF:(id<CP>)cp
{
   return [[CPFirstFail alloc] initCPFirstFail:cp restricted:nil];
}
+(void) shutdown 
{
   [NSCont shutdown];
}
@end;

@implementation CPFactory (DataStructure)
+(void) print:(id)x 
{
    printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);
}
+(id<CPInteger>) integer: (id<ORTracker>)tracker value: (CPInt) value
{
   return (id<CPInteger>)[ORFactory integer:tracker value:value];
}

+(id<CPIntArray>) intArray: (id<CP>) cp range: (id<ORIntRange>) range value: (ORInt) value
{
   return (id<CPIntArray>)[ORFactory intArray:cp range: range value:value];
}
+(id<CPIntArray>) intArray: (id<CP>) cp range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo
{
   return (id<CPIntArray>)[ORFactory intArray:cp range: range with:clo];
}
+(id<CPIntArray>) intArray: (id<CP>) cp range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo;
{
   return (id<CPIntArray>)[ORFactory intArray:cp range:r1 range: r2 with:clo];
}

+(id<CPIntVar>) intVar: (id<CP>) cp bounds: (id<ORIntRange>) range
{
   return [CPIntVarI initCPIntVar:cp bounds: range];
}
+(CPIntVarI*) intVar: (id<CP>) cp domain: (id<ORIntRange>) range
{
    return [CPIntVarI initCPIntVar: cp low: [range low] up: [range up]];
}
+(CPIntVarI*) intVar: (CPIntVarI*) x shift: (CPInt) b
{
   if (b!=0)
      return [CPIntVarI initCPIntView: x withShift: b];
   else return x;
}
+(CPIntVarI*) intVar: (CPIntVarI*) x scale: (CPInt) a
{
   if (a!=1)
    return [CPIntVarI initCPIntView: x withScale: a]; 
   else return x;
}
+(CPIntVarI*) intVar: (CPIntVarI *)x scale: (CPInt) a shift:(CPInt) b
{
   if (a==1 && b==0)
      return x;
   else 
      return [CPIntVarI initCPIntView: x withScale: a andShift: b]; 
}
+(id<CPIntVar>)boolVar: (id<CP>)cp
{
   return [CPIntVarI initCPBoolVar:cp];
}

+(id<CPIntVar>) negate:(id<CPIntVar>)x
{
   return [CPIntVarI initCPNegateBoolView:(CPIntVarI*)x];
}

+(id<CPIntMatrix>) intMatrix: (id<CP>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
    CPIntMatrixI* o = [[CPIntMatrixI alloc] initCPIntMatrix: cp range: r1 : r2];    
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;   
}
+(id<CPVarArray>) varArray: (id<CP>) cp range: (id<ORIntRange>) range
{
   return (id<CPVarArray>)[ORFactory idArray:cp range: range];
}
+(id<CPIntVarArray>) arrayCPIntVar: (id<CP>) cp range: (id<ORIntRange>) range with:(id<CPIntVar>(^)(CPInt)) clo
{
   return [self intVarArray:cp range:range with:clo];
}
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   for(CPInt k=range.low;k <= range.up;k++)
      [o set:[CPFactory intVar:cp domain:domain] at:k];
   return (id<CPIntVarArray>)o;
}
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (id<ORIntRange>) range 
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   return (id<CPIntVarArray>)o;
}
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (id<ORIntRange>) range with:(id<CPIntVar>(^)(CPInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   for(CPInt k= [range low];k <= [range up];k++)
      [o set:clo(k) at:k];
   return (id<CPIntVarArray>)o;
}
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (id<ORIntRange>) r1  : (id<ORIntRange>) r2 with: (id<CPIntVar>(^)(CPInt,CPInt)) clo
{
   CPInt nb = ([r1 up] - [r1 low] + 1) * ([r2 up] - [r2 low] + 1);
   id<ORIntRange> fr = [ORFactory intRange: cp low: 0 up: nb-1];
   id<ORIdArray> o = [ORFactory idArray:cp range:fr];
   CPInt k = 0;
   for(CPInt i=[r1 low];i <= [r1 up];i++)
      for(CPInt j= [r2 low];j <= [r2 up];j++)
         [o set:clo(i,j) at:k++];
   return (id<CPIntVarArray>)o;
}
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (id<ORIntRange>) r1  : (id<ORIntRange>) r2 : (id<ORIntRange>) r3 with: (id<CPIntVar>(^)(CPInt,CPInt,CPInt)) clo
{
   CPInt nb = ([r1 up] - [r1 low] + 1) * ([r2 up] - [r2 low] + 1) * ([r3 up] - [r3 low] + 1);
   id<ORIntRange> fr = [ORFactory intRange: cp low: 0 up: nb-1]; 
   id<ORIdArray> o = [ORFactory idArray:cp range:fr];
   CPInt l = 0;
   for(CPInt i= [r1 low] ;i <= [r1 up]; i++)
      for(CPInt j= [r2 low]; j <= [r2 up]; j++)
         for(CPInt k= [r3 low];k <= [r3 up]; k++)
            [o set:clo(i,j,k) at:l++];
   return (id<CPIntVarArray>)o;
}
+(id<CPIntVarMatrix>) intVarMatrix: (id<CP>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range: r0 : r1];
   for(CPInt i=[r0 low];i <= [r0 up];i++)
      for(CPInt j= [r1 low];j <= [r1 up];j++)
         [o set:[CPFactory intVar:cp domain:domain] at:i :j];
    return (id<CPIntVarMatrix>)o;
}
+(id<CPIntVarMatrix>) intVarMatrix: (id<CP>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(CPInt i= [r0 low];i <= [r0 up]; i++)
      for(CPInt j= [r1 low]; j <= [r1 up]; j++)
         for(CPInt k= [r2 low]; k <= [r2 up];k++)
            [o set:[CPFactory intVar:cp domain:domain] at:i :j :k];
   return (id<CPIntVarMatrix>)o;
}
+(id<CPIntVarMatrix>) boolVarMatrix: (id<CP>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1];
   for(CPInt i= [r0 low];i <= [r0 up]; i++)
      for(CPInt j= [r1 low]; j <= [r1 up];j++)
         [o set:[CPFactory boolVar:cp] at:i :j];
   return (id<CPIntVarMatrix>)o;   
}
+(id<CPIntVarMatrix>) boolVarMatrix: (id<CP>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(CPInt i= [r0 low]; i <= [r0 up]; i++)
      for(CPInt j= [r1 low]; j <= [r1 up]; j++)
         for(CPInt k= [r2 low]; k <= [r2 up]; k++)
            [o set:[CPFactory boolVar:cp] at:i :j :k];
   return (id<CPIntVarMatrix>)o;
}

+(id<CPIntVarArray>) flattenMatrix:(id<CPIntVarMatrix>)m
{
   id<ORTracker> tracker = [m tracker];
   CPInt sz = (CPInt)[m count];
   id<ORIdArray> flat = [ORFactory idArray: tracker range: RANGE(tracker,0,sz-1)];
   for(CPInt i=0;i<sz;i++)
      flat[i] = [m flat:i];
   return (id<CPIntVarArray>)flat;
}

+(id<CPIntVarArray>) pointwiseProduct:(id<CPIntVarArray>)x by:(int*)c
{
   id<CPIntVarArray> rv = [self intVarArray:[x cp] range: [x range] with:^id<CPIntVar>(CPInt i) {
      id<CPIntVar> theView = [self intVar:[x at:i]  scale:c[i]];
      return theView;
   }];
   return rv;
}
+(id<ORIntSet>) intSet: (id<CP>) cp 
{
    ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI]; 
    [[cp solver] trackObject: o];
    return o;
}
+(id<CPTable>) table: (id<CP>) cp arity: (int) arity
{
    CPTableI* o = [[CPTableI alloc] initCPTableI: cp arity: arity]; 
    [[cp solver] trackObject: o];
    return o;
}
+(id<ORInformer>) informer: (id<CP>) cp
{
    id<ORInformer> o = [ORConcurrency intInformer];
    [[cp solver] trackObject: o];
    return o;    
}
+(id<ORVoidInformer>) voidInformer: (id<CP>) cp
{
   id<ORVoidInformer> o = [ORConcurrency voidInformer];
   [[cp solver] trackObject: o];
   return o;       
}
+(id<ORIntInformer>) intInformer: (id<CP>) cp
{
   id<ORIntInformer> o = [ORConcurrency intInformer];
   [[cp solver] trackObject: o];
   return o;          
}
+(id<ORBarrier>)  barrier: (id<CP>) cp value: (CPInt) nb
{
    id<ORBarrier> o = [ORConcurrency barrier: nb];
    [[cp solver] trackObject: o];
    return o;    
}

+(CPTRIntArrayI*) TRIntArray: (id<CP>) cp range: (id<ORIntRange>) R
{
    CPTRIntArrayI* o = [[CPTRIntArrayI alloc] initCPTRIntArray: cp range: R];    
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;    
}

+(id<CPTRIntMatrix>) TRIntMatrix: (id<CP>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
{
    CPTRIntMatrixI* o = [[CPTRIntMatrixI alloc] initCPTRIntMatrix: cp range: R1 : R2];    
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;    
}

+(id<CPRandomStream>) randomStream: (id<CP>) cp
{
   id<CPRandomStream> o = (id<CPRandomStream>) [ORCrFactory randomStream];
   [[cp solver] trackObject: o];
   return o;
}
+(id<CPZeroOneStream>) zeroOneStream: (id<CP>) cp
{
   id<CPZeroOneStream> o = (id<CPZeroOneStream>) [ORCrFactory zeroOneStream];
   [[cp solver] trackObject: o];
   return o;
}
+(id<CPUniformDistribution>) uniformDistribution: (id<CP>) cp range: (id<ORIntRange>) r
{
   id<CPUniformDistribution> o = (id<CPUniformDistribution>) [ORCrFactory uniformDistribution:r];
   [[cp solver] trackObject: o];
   return o;
}
@end


// Not sure how an expression can be added to the solver
@implementation CPFactory (expression)

+(id<CPExpr>) exprAbs: (id<CPExpr>) op
{
   return (id<CPExpr>)[ORFactory exprAbs:op];
}

+(id<CPExpr>) dotProduct:(id<CPIntVar>[])vars by:(int[])coefs
{
   id<CP> cp = [vars[0] cp];
   id<CPExpr> rv = nil;
   CPInt i = 0;
   while(vars[i]!=nil) {
      id<CPExpr> term = [vars[i] mul:[CPFactory integer:cp value:coefs[i]]];
      rv = rv==nil ? term : [rv plus:term];
      ++i;
   }
   return rv;
}
+(id<CPExpr>) sum: (id<CP>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   return (id<CPExpr>)[ORFactory sum:cp over: S suchThat:f of:e];
}
+(id<CPRelation>) or: (id<CP>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   return (id<CPRelation>)[ORFactory or:cp over: S suchThat:f of:e];
}

@end

