/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPFactory.h"
#import "ORFoundation/ORFactory.h"
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

+(id<CPIntArray>) intArray: (id<CP>) cp range: (ORRange) range value: (ORInt) value
{
   return (id<CPIntArray>)[ORFactory intArray:cp range:range value:value];
}
+(id<CPIntArray>) intArray: (id<CP>) cp range: (ORRange) range with:(ORInt(^)(ORInt)) clo
{
   return (id<CPIntArray>)[ORFactory intArray:cp range:range with:clo];
}
+(id<CPIntArray>) intArray: (id<CP>) cp range: (ORRange) r1 range: (ORRange) r2 with: (ORInt(^)(ORInt,ORInt)) clo;
{
   return (id<CPIntArray>)[ORFactory intArray:cp range:r1 range:r2 with:clo];
}

+(CPIntVarI*) intVar: (id<CP>) cp domain: (CPRange) range
{
    return [CPIntVarI initCPIntVar: cp low: range.low up: range.up];
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

+(id<CPIntVar>) negate:(id<CPIntVar>)x
{
   return [CPIntVarI initCPNegateBoolView:(CPIntVarI*)x];
}

+(id<CPIntMatrix>) intMatrix: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2
{
    CPIntMatrixI* o = [[CPIntMatrixI alloc] initCPIntMatrix: cp range: r1 : r2];    
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;   
}

+(id<CPVarArray>) varArray: (id<CP>) cp range: (CPRange) range
{
   CPVarArrayI* o = [[CPVarArrayI alloc] initCPVarArray:cp range:range];
   [[((CoreCPI*)cp) solver] trackObject:o];
   return o;
}
+(CPIntVarArrayI*) intVarArray: (id<CP>) cp range: (CPRange) range domain: (CPRange) domain
{
    CPIntVarArrayI* o = [[CPIntVarArrayI alloc] initCPIntVarArray: cp range:range domain:domain];
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntVarArrayI*) intVarArray: (id<CP>) cp range: (CPRange) range 
{
    CPIntVarArrayI* o = [[CPIntVarArrayI alloc] initCPIntVarArray: cp range:range];
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntVarArrayI*) intVarArray: (id<CP>) cp range: (CPRange) range with:(id<CPIntVar>(^)(CPInt)) clo
{
    CPIntVarArrayI* o = [[CPIntVarArrayI alloc] initCPIntVarArray: cp range:range with:clo];
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntVarArrayI*) intVarArray: (id<CP>) cp range: (CPRange) r1  : (CPRange) r2 with: (id<CPIntVar>(^)(CPInt,CPInt)) clo
{
    CPIntVarArrayI* o = [[CPIntVarArrayI alloc] initCPIntVarArray: cp range: r1 : r2 with:clo];    
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntVarArrayI*) intVarArray: (id<CP>) cp range: (CPRange) r1  : (CPRange) r2 : (CPRange) r3 with: (id<CPIntVar>(^)(CPInt,CPInt,CPInt)) clo
{
    CPIntVarArrayI* o = [[CPIntVarArrayI alloc] initCPIntVarArray: cp range: r1 : r2 : r3 with:clo];    
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntVarMatrixI*) intVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 domain: (CPRange) domain
{
    CPIntVarMatrixI* o = [[CPIntVarMatrixI alloc] initCPIntVarMatrix: cp range: r0 : r1 domain:domain]; 
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntVarMatrixI*) intVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2 domain: (CPRange) domain
{
    CPIntVarMatrixI* o = [[CPIntVarMatrixI alloc] initCPIntVarMatrix: cp range: r0 : r1 : r2 domain:domain]; 
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntVarArrayI*) pointwiseProduct:(id<CPIntVarArray>)x by:(int*)c
{
   CPIntVarArrayI* rv = (CPIntVarArrayI*)[self intVarArray:[x cp] range:(CPRange){[x low],[x up]} with:^id<CPIntVar>(CPInt i) {
      return [self intVar:[x at:i]  scale:c[i]];
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

+(CPTRIntArrayI*) TRIntArray: (id<CP>) cp range: (CPRange) R
{
    CPTRIntArrayI* o = [[CPTRIntArrayI alloc] initCPTRIntArray: cp range: R];    
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;    
}

+(id<CPTRIntMatrix>) TRIntMatrix: (id<CP>) cp range: (CPRange) R1 : (CPRange) R2
{
    CPTRIntMatrixI* o = [[CPTRIntMatrixI alloc] initCPTRIntMatrix: cp range: R1 : R2];    
    [[((CoreCPI*) cp) solver] trackObject: o];
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
      rv = rv==nil ? term : [rv add:term];
      ++i;
   }
   return rv;
}
+(id<CPExpr>) sum: (id<CP>) cp range: (ORRange) r filteredBy: (ORInt2Bool) f of: (ORInt2Expr) e
{
   return (id<CPExpr>)[ORFactory sum:cp range:r filteredBy:f of:e];
}
@end

