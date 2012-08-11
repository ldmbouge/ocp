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
#import "CPExprI.h"
#import "CPTableI.h"
#import "CPDDeg.h"
#import "CPWDeg.h"
#import "CPIBS.h"
#import "CPFirstFail.h"
#import "CPEngineI.h"
#import "CPArrayI.h"

void failNow()
{
   static CPFailException* fex = nil;
   if (fex==nil) fex = [CPFailException new];
   @throw  CFRetain(fex);
}


@implementation CPFactory

+(CPSolverI*) createSolver
{
    return [CPSolverI create];
}
//+(SemCP*) createSemSolver
//{
//   return [SemCP create];
//}
+(CPSolverI*) createRandomizedSolver
{
    return [CPSolverI createRandomized];
}
+(CPSolverI*) createDeterministicSolver
{
    return [CPSolverI createDeterministic];
}
//+(SemCP*) createSemSolverFor:(id<CPEngine>)fdm
//{
//   return [[SemCP alloc] initFor:fdm];
//}
+(id<CPHeuristic>) createWDeg:(id<CPSolver>)cp restricted:(id<CPVarArray>)rvars;
{
   return [[CPWDeg alloc] initCPWDeg:cp restricted:rvars];
}
+(id<CPHeuristic>) createDDeg:(id<CPSolver>)cp restricted:(id<CPVarArray>)rvars; 
{
   return [[CPDDeg alloc] initCPDDeg:cp restricted:rvars];
}
+(id<CPHeuristic>) createIBS:(id<CPSolver>)cp restricted:(id<CPVarArray>)rvars;
{
   return [[CPIBS alloc] initCPIBS:cp restricted:rvars];
}
+(id<CPHeuristic>)createFF:(id<CPSolver>)cp restricted:(id<CPVarArray>)rvars;
{
   return [[CPFirstFail alloc] initCPFirstFail:cp restricted:rvars];
}
+(id<CPHeuristic>) createWDeg:(id<CPSolver>)cp;
{
   return [[CPWDeg alloc] initCPWDeg:cp restricted:nil];
}
+(id<CPHeuristic>) createDDeg:(id<CPSolver>)cp 
{
   return [[CPDDeg alloc] initCPDDeg:cp restricted:nil];
}
+(id<CPHeuristic>) createIBS:(id<CPSolver>)cp
{
   return [[CPIBS alloc] initCPIBS:cp restricted:nil];
}
+(id<CPHeuristic>)createFF:(id<CPSolver>)cp
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

+(id<ORIntArray>) intArray: (id<CPSolver>) cp range: (id<ORIntRange>) range value: (ORInt) value
{
   return (id<ORIntArray>)[ORFactory intArray:cp range: range value:value];
}
+(id<ORIntArray>) intArray: (id<CPSolver>) cp range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo
{
   return (id<ORIntArray>)[ORFactory intArray:cp range: range with:clo];
}
+(id<ORIntArray>) intArray: (id<CPSolver>) cp range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo;
{
   return (id<ORIntArray>)[ORFactory intArray:cp range:r1 range: r2 with:clo];
}

+(id<ORIntVar>) intVar: (id<CPSolver>) cp bounds: (id<ORIntRange>) range
{
   return [CPIntVarI initCPIntVar:cp bounds: range];
}
+(CPIntVarI*) intVar: (id<CPSolver>) cp domain: (id<ORIntRange>) range
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
+(CPIntVarI*) intVar: (CPIntVarI *)x scale: (ORInt) a shift:(ORInt) b
{
   if (a==1 && b==0)
      return x;
   else 
      return [CPIntVarI initCPIntView: x withScale: a andShift: b]; 
}
+(id<ORIntVar>)boolVar: (id<CPSolver>)cp
{
   return [CPIntVarI initCPBoolVar:cp];
}

+(id<ORIntVar>) negate:(id<ORIntVar>)x
{
   return [CPIntVarI initCPNegateBoolView:(CPIntVarI*)x];
}

+(id<ORIntMatrix>) intMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
    CPIntMatrixI* o = [[CPIntMatrixI alloc] initCPIntMatrix: cp range: r1 : r2];    
    [[((CPSolverI*) cp) solver] trackObject: o];
    return o;   
}
+(id<CPVarArray>) varArray: (id<CPSolver>) cp range: (id<ORIntRange>) range
{
   return (id<CPVarArray>)[ORFactory idArray:cp range: range];
}
+(id<ORIntVarArray>) arrayORIntVar: (id<CPSolver>) cp range: (id<ORIntRange>) range with:(id<ORIntVar>(^)(ORInt)) clo
{
   return [self intVarArray:cp range:range with:clo];
}
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   for(CPInt k=range.low;k <= range.up;k++)
      [o set:[CPFactory intVar:cp domain:domain] at:k];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) range with:(id<ORIntVar>(^)(ORInt)) clo
{
   id<ORIdArray> o = [ORFactory idArray:cp range:range];
   for(CPInt k= [range low];k <= [range up];k++)
      [o set:clo(k) at:k];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) r1  : (id<ORIntRange>) r2 with: (id<ORIntVar>(^)(CPInt,CPInt)) clo
{
   CPInt nb = ([r1 up] - [r1 low] + 1) * ([r2 up] - [r2 low] + 1);
   id<ORIntRange> fr = [ORFactory intRange: cp low: 0 up: nb-1];
   id<ORIdArray> o = [ORFactory idArray:cp range:fr];
   CPInt k = 0;
   for(CPInt i=[r1 low];i <= [r1 up];i++)
      for(CPInt j= [r2 low];j <= [r2 up];j++)
         [o set:clo(i,j) at:k++];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) r1  : (id<ORIntRange>) r2 : (id<ORIntRange>) r3 with: (id<ORIntVar>(^)(CPInt,CPInt,CPInt)) clo
{
   CPInt nb = ([r1 up] - [r1 low] + 1) * ([r2 up] - [r2 low] + 1) * ([r3 up] - [r3 low] + 1);
   id<ORIntRange> fr = [ORFactory intRange: cp low: 0 up: nb-1]; 
   id<ORIdArray> o = [ORFactory idArray:cp range:fr];
   CPInt l = 0;
   for(CPInt i= [r1 low] ;i <= [r1 up]; i++)
      for(CPInt j= [r2 low]; j <= [r2 up]; j++)
         for(CPInt k= [r3 low];k <= [r3 up]; k++)
            [o set:clo(i,j,k) at:l++];
   return (id<ORIntVarArray>)o;
}
+(id<ORIntVarMatrix>) intVarMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range: r0 : r1];
   for(CPInt i=[r0 low];i <= [r0 up];i++)
      for(CPInt j= [r1 low];j <= [r1 up];j++)
         [o set:[CPFactory intVar:cp domain:domain] at:i :j];
    return (id<ORIntVarMatrix>)o;
}
+(id<ORIntVarMatrix>) intVarMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(CPInt i= [r0 low];i <= [r0 up]; i++)
      for(CPInt j= [r1 low]; j <= [r1 up]; j++)
         for(CPInt k= [r2 low]; k <= [r2 up];k++)
            [o set:[CPFactory intVar:cp domain:domain] at:i :j :k];
   return (id<ORIntVarMatrix>)o;
}
+(id<ORIntVarMatrix>) boolVarMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1];
   for(CPInt i= [r0 low];i <= [r0 up]; i++)
      for(CPInt j= [r1 low]; j <= [r1 up];j++)
         [o set:[CPFactory boolVar:cp] at:i :j];
   return (id<ORIntVarMatrix>)o;   
}
+(id<ORIntVarMatrix>) boolVarMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2
{
   id<ORIdMatrix> o = [ORFactory idMatrix:cp range:r0 :r1 :r2];
   for(CPInt i= [r0 low]; i <= [r0 up]; i++)
      for(CPInt j= [r1 low]; j <= [r1 up]; j++)
         for(CPInt k= [r2 low]; k <= [r2 up]; k++)
            [o set:[CPFactory boolVar:cp] at:i :j :k];
   return (id<ORIntVarMatrix>)o;
}

+(id<ORIntVarArray>) flattenMatrix:(id<ORIntVarMatrix>)m
{
   id<ORTracker> tracker = [m tracker];
   CPInt sz = (ORInt)[m count];
   id<ORIdArray> flat = [ORFactory idArray: tracker range: RANGE(tracker,0,sz-1)];
   for(CPInt i=0;i<sz;i++)
      flat[i] = [m flat:i];
   return (id<ORIntVarArray>)flat;
}

+(id<ORIntVarArray>) pointwiseProduct:(id<ORIntVarArray>)x by:(int*)c
{
   id<ORIntVarArray> rv = [self intVarArray:[x cp] range: [x range] with:^id<ORIntVar>(CPInt i) {
      id<ORIntVar> theView = [self intVar:[x at:i]  scale:c[i]];
      return theView;
   }];
   return rv;
}
+(id<ORIntSet>) intSet: (id<CPSolver>) cp 
{
    ORIntSetI* o = [[ORIntSetI alloc] initORIntSetI]; 
    [[cp solver] trackObject: o];
    return o;
}
+(id<CPTable>) table: (id<CPSolver>) cp arity: (int) arity
{
    CPTableI* o = [[CPTableI alloc] initCPTableI: cp arity: arity]; 
    [[cp solver] trackObject: o];
    return o;
}
+(id<ORInformer>) informer: (id<CPSolver>) cp
{
    id<ORInformer> o = [ORConcurrency intInformer];
    [[cp solver] trackObject: o];
    return o;    
}
+(id<ORVoidInformer>) voidInformer: (id<CPSolver>) cp
{
   id<ORVoidInformer> o = [ORConcurrency voidInformer];
   [[cp solver] trackObject: o];
   return o;       
}
+(id<ORIntInformer>) intInformer: (id<CPSolver>) cp
{
   id<ORIntInformer> o = [ORConcurrency intInformer];
   [[cp solver] trackObject: o];
   return o;          
}
+(id<ORBarrier>)  barrier: (id<CPSolver>) cp value: (ORInt) nb
{
    id<ORBarrier> o = [ORConcurrency barrier: nb];
    [[cp solver] trackObject: o];
    return o;    
}

+(CPTRIntArrayI*) TRIntArray: (id<CPSolver>) cp range: (id<ORIntRange>) R
{
    CPTRIntArrayI* o = [[CPTRIntArrayI alloc] initCPTRIntArray: cp range: R];    
    [[((CPSolverI*) cp) solver] trackObject: o];
    return o;    
}

+(id<CPTRIntMatrix>) TRIntMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
{
    CPTRIntMatrixI* o = [[CPTRIntMatrixI alloc] initCPTRIntMatrix: cp range: R1 : R2];    
    [[((CPSolverI*) cp) solver] trackObject: o];
    return o;    
}

+(id<CPRandomStream>) randomStream: (id<CPSolver>) cp
{
   id<CPRandomStream> o = (id<CPRandomStream>) [ORCrFactory randomStream];
   [[cp solver] trackObject: o];
   return o;
}
+(id<CPZeroOneStream>) zeroOneStream: (id<CPSolver>) cp
{
   id<CPZeroOneStream> o = (id<CPZeroOneStream>) [ORCrFactory zeroOneStream];
   [[cp solver] trackObject: o];
   return o;
}
+(id<CPUniformDistribution>) uniformDistribution: (id<CPSolver>) cp range: (id<ORIntRange>) r
{
   id<CPUniformDistribution> o = (id<CPUniformDistribution>) [ORCrFactory uniformDistribution:r];
   [[cp solver] trackObject: o];
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
+(id<ORExpr>) sum: (id<CPSolver>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   return [ORFactory sum:cp over: S suchThat:f of:e];
}
+(id<ORRelation>) or: (id<CPSolver>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   return [ORFactory or:cp over: S suchThat:f of:e];
}

@end

