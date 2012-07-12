/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CPSolver.h"
#import "CP.h"
#import "ORFoundation/ORSet.h"
#import "CPTable.h"
#import "ORConcurrency.h"
#import "CPHeuristic.h"
#import "CPSolverI.h"
#import "CPData.h"

@interface CPFactory : NSObject
+(id<CP>) createSolver;
+(id<CP>) createSemSolver;
+(id<CP>) createRandomizedSolver;
+(id<CP>) createDeterministicSolver;
+(id<CP>) createSemSolverFor:(id<CPSolver>)fdm;
+(void) shutdown;
+(id<CPHeuristic>) createDDeg:(id<CP>)cp restricted:(id<CPVarArray>)rvars;
+(id<CPHeuristic>) createWDeg:(id<CP>)cp restricted:(id<CPVarArray>)rvars;
+(id<CPHeuristic>) createIBS:(id<CP>)cp restricted:(id<CPVarArray>)rvars;
+(id<CPHeuristic>)createFF:(id<CP>)cp restricted:(id<CPVarArray>)rvars;
+(id<CPHeuristic>) createDDeg:(id<CP>)cp;
+(id<CPHeuristic>) createWDeg:(id<CP>)cp;
+(id<CPHeuristic>) createIBS:(id<CP>)cp;
+(id<CPHeuristic>)createFF:(id<CP>)cp;
@end;

//void failNow();

@interface CPFactory (DataStructure)
+(void) print: (id) x;
+(id<CPInteger>) integer: (id<ORTracker>)tracker value: (CPInt) value;
+(id<CPIntVar>) intVar: (id<ORTracker>) cp bounds: (CPRange) range;
+(id<CPIntVar>) intVar: (id<ORTracker>) cp domain: (CPRange) range;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x shift: (CPInt) b;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x scale: (CPInt) a;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x scale: (CPInt) a shift:(CPInt) b;
+(id<CPIntVar>)boolVar: (id<CP>)cp;
+(id<CPIntVar>) negate:(id<CPIntVar>)x;

+(id<CPIntArray>) intArray: (id<CP>) cp range: (ORRange) range value: (ORInt) value;
+(id<CPIntArray>) intArray: (id<CP>) cp range: (ORRange) range with:(ORInt(^)(ORInt)) clo;
+(id<CPIntArray>) intArray: (id<CP>) cp range: (ORRange) r1 range: (ORRange) r2 with: (ORInt(^)(ORInt,ORInt)) clo;


+(id<CPVarArray>) varArray: (id<CP>) cp range: (CPRange) range;


+(id<CPIntVarArray>) arrayCPIntVar: (id<CP>) cp range: (CPRange) range with:(id<CPIntVar>(^)(CPInt)) clo;

+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) range domain: (CPRange) domain;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) range;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) range with:(id<CPIntVar>(^)(CPInt)) clo;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2 with:(id<CPIntVar>(^)(CPInt,CPInt)) clo;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2 : (CPRange) r3 with:(id<CPIntVar>(^)(CPInt,CPInt,CPInt)) clo;
+(id<CPIntVarArray>) flattenMatrix:(id<CPIntVarMatrix>)m;

+(id<CPIntVarMatrix>) intVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 domain: (CPRange) domain;
+(id<CPIntVarMatrix>) intVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2 domain: (CPRange) domain;
+(id<CPIntVarMatrix>) boolVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1;
+(id<CPIntVarMatrix>) boolVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2;

+(id<CPIntMatrix>) intMatrix: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2;

+(id<ORIntSet>) intSet: (id<CP>) cp;
+(id<ORInformer>) informer: (id<CP>) cp;
+(id<ORVoidInformer>) voidInformer: (id<CP>) cp;
+(id<ORIntInformer>) intInformer: (id<CP>) cp;
+(id<ORBarrier>)  barrier: (id<CP>) cp value: (CPInt) nb;

+(id<CPTable>) table: (id<CP>) cp arity: (int) arity;

+(id<CPTRIntArray>)  TRIntArray: (id<CP>) cp range: (CPRange) R;
+(id<CPTRIntMatrix>) TRIntMatrix: (id<CP>) cp range: (CPRange) R1 : (CPRange) R2;

+(id<CPIntVarArray>) pointwiseProduct:(id<CPIntVarArray>)x by:(int*)c;

+(id<CPRandomStream>) randomStream: (id<CP>) cp ;
+(id<CPZeroOneStream>) zeroOneStream: (id<CP>) cp ;
+(id<CPUniformDistribution>) uniformDistribution: (id<CP>) cp range: (ORRange) r;
@end

@interface CPFactory (expression)
+(id<CPExpr>) exprAbs: (id<CPExpr>) op;
+(id<CPExpr>) dotProduct:(id<CPIntVar>[])vars by:(int[])coefs;
+(id<CPExpr>) sum: (id<CP>) cp range: (ORRange) r filteredBy: (ORInt2Bool) f of: (ORInt2Expr) e;
@end

#define RANGE(a,b)         ((CPRange){(a),(b)})
#define SUM(P,R,E)         [CPFactory sum: cp range:(R) filteredBy:nil of:^id<CPExpr>(ORInt P) { return (id<CPExpr>)(E);}]
#define ALL(RT,P,RANGE,E)  [CPFactory array##RT:cp range:(RANGE) with:^id<RT>(CPInt P) { return (E);}]

static inline void failNow()
{
   static CPFailException* fex = nil;
   if (fex==nil) fex = [CPFailException new];
   @throw  CFRetain(fex);
}
