/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/


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
+(id<CPHeuristic>) createWDeg:(id<CP>)cp
{
   return [[CPWDeg alloc] initCPWDeg:cp];
}
+(id<CPHeuristic>) createDDeg:(id<CP>)cp
{
   return [[CPDDeg alloc] initCPDDeg:cp];
}
+(id<CPHeuristic>) createIBS:(id<CP>)cp
{
   return [[CPIBS alloc] initCPIBS:cp];
}
+(id<CPHeuristic>)createFF:(id<CP>)cp
{
   return [[CPFirstFail alloc] initCPFirstFail:cp];
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
+(id<CPInteger>) integer: (id<CP>) cp value: (CPInt) value
{
    CPIntegerI* o = [[CPIntegerI alloc] initCPIntegerI: value];
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
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

+(CPIntArrayI*) intArray: (id<CP>) cp range: (CPRange) range value: (CPInt) value
{
    CPIntArrayI* o = [[CPIntArrayI alloc] initCPIntArray: cp range:range value: (CPInt) value];
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntArrayI*) intArray: (id<CP>) cp range: (CPRange) range with:(CPInt(^)(CPInt)) clo
{
    CPIntArrayI* o = [[CPIntArrayI alloc] initCPIntArray: cp range:range with:clo];
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o;
}
+(CPIntArrayI*) intArray: (id<CP>) cp range: (CPRange) r1 range: (CPRange) r2 with: (CPInt(^)(CPInt,CPInt)) clo
{
    CPIntArrayI* o = [[CPIntArrayI alloc] initCPIntArray: cp range: r1 range: r2 with:clo];    
    [[((CoreCPI*) cp) solver] trackObject: o];
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
+(CPIntVarArrayI*) intVarArray: (id<CP>) cp range: (CPRange) r1 range: (CPRange) r2 with: (id<CPIntVar>(^)(CPInt,CPInt)) clo
{
    CPIntVarArrayI* o = [[CPIntVarArrayI alloc] initCPIntVarArray: cp range: r1 range: r2 with:clo];    
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
+(id<CPIntSet>) intSet: (id<CP>) cp 
{
    CPIntSetI* o = [[CPIntSetI alloc] initCPIntSetI: cp]; 
    [[cp solver] trackObject: o];
    return o;
}
+(id<CPTable>) table: (id<CP>) cp arity: (int) arity
{
    CPTableI* o = [[CPTableI alloc] initCPTableI: cp arity: arity]; 
    [[cp solver] trackObject: o];
    return o;
}
+(id<CPInformer>) informer: (id<CP>) cp
{
    id<CPInformer> o = [CPConcurrency intInformer];
    [[cp solver] trackObject: o];
    return o;    
}
+(id<CPVoidInformer>) voidInformer: (id<CP>) cp
{
   id<CPVoidInformer> o = [CPConcurrency voidInformer];
   [[cp solver] trackObject: o];
   return o;       
}
+(id<CPIntInformer>) intInformer: (id<CP>) cp
{
   id<CPIntInformer> o = [CPConcurrency intInformer];
   [[cp solver] trackObject: o];
   return o;          
}
+(id<CPBarrier>)  barrier: (id<CP>) cp value: (CPInt) nb
{
    id<CPBarrier> o = [CPConcurrency barrier: nb];
    [[cp solver] trackObject: o];
    return o;    
}
@end


// Not sure how an expression can be added to the solver
@implementation CPFactory (expression)
+(id<CPExpr>) validate:(id<CPExpr>)e onError:(const char*)str
{
   id<CP> cp = [e cp];
   if (cp == NULL)
      @throw [[CPExecutionError alloc] initCPExecutionError: str]; 
   [[((CoreCPI*) cp) solver] trackObject: e];
   return e;   
}
+(id<CPExpr>) expr: (id<CPExpr>) left add: (id<CPExpr>) right
{
   id<CPExpr> o = [[CPExprPlusI alloc] initCPExprPlusI: left and: right]; 
   return [self validate:o onError:"No CP Solver in Add Expression"];
}
+(id<CPExpr>) expr: (id<CPExpr>) left sub: (id<CPExpr>) right
{
   id<CPExpr> o = [[CPExprMinusI alloc] initCPExprMinusI: left and: right]; 
   return [self validate:o onError:"No CP Solver in Sub Expression"];
}
+(id<CPExpr>) expr: (id<CPExpr>) left mul: (id<CPExpr>) right
{
   id<CPExpr> o = [[CPExprMulI alloc] initCPExprMulI: left and: right]; 
   return [self validate:o onError:"No CP Solver in Mul Expression"];
}
+(id<CPExpr>) expr: (id<CPExpr>) left equal: (id<CPExpr>) right
{
   id<CPExpr> o = [[CPExprEqualI alloc] initCPExprEqualI: left and: right]; 
   return [self validate:o onError:"No CP Solver in == Expression"];
}
+(id<CPExpr>) exprAbs: (id<CPExpr>) op
{
   id<CPExpr> o = [[CPExprAbsI alloc] initCPExprAbsI:op];
   return [self validate:o onError:"No CP Solver in Abs Expression"];
}

+(id<CPExpr>) sum: (id<CP>) cp range: (CPRange) r filteredBy: (CPInt2Bool) f of: (CPInt2Expr) e
{
    CPExprSumI* o = [[CPExprSumI alloc] initCPExprSumI: cp range: r filteredBy: f of: e];
    [[((CoreCPI*) cp) solver] trackObject: o];
    return o; 
}

+(id<CPExpr>) dotProduct:(id<CPIntVar>[])vars by:(int[])coefs
{
   id<CP> cp = [vars[0] cp];
   id<CPExpr> rv = nil;
   CPInt i = 0;
   while(vars[i]!=nil) {
      id<CPExpr> term = [self expr:vars[i] mul:[CPFactory integer:cp value:coefs[i]]];
      rv = rv==nil ? term : [CPFactory expr:rv add:term];
      ++i;
   }
   return rv;
}

@end

