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
#import "CPSet.h"
#import "CPTable.h"
#import "CPConcurrency.h"
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
+(id<CPHeuristic>) createDDeg:(id<CP>)cp;
+(id<CPHeuristic>) createWDeg:(id<CP>)cp;
+(id<CPHeuristic>) createIBS:(id<CP>)cp;
+(id<CPHeuristic>)createFF:(id<CP>)cp;
@end;

void failNow();

@interface CPFactory (DataStructure)
+(void) print: (id) x;

+(id<CPInteger>) integer: (id<CP>) cp value: (CPInt) value;
+(id<CPIntVar>) intVar: (id<CP>) cp domain: (CPRange) range;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x shift: (CPInt) b;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x scale: (CPInt) a;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x scale: (CPInt) a shift:(CPInt) b;
+(id<CPIntVar>) negate:(id<CPIntVar>)x;

+(id<CPVarArray>) varArray: (id<CP>) cp range: (CPRange) range;

+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) range domain: (CPRange) domain;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) range;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) range with:(id<CPIntVar>(^)(CPInt)) clo;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2 with:(id<CPIntVar>(^)(CPInt,CPInt)) clo;
+(id<CPIntVarArray>) intVarArray: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2 : (CPRange) r3 with:(id<CPIntVar>(^)(CPInt,CPInt,CPInt)) clo;

+(id<CPIntVarMatrix>) intVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 domain: (CPRange) domain;
+(id<CPIntVarMatrix>) intVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2 domain: (CPRange) domain;

+(id<CPIntArray>) intArray: (id<CP>) cp range: (CPRange) range value: (CPInt) value;
+(id<CPIntArray>) intArray: (id<CP>) cp range: (CPRange) range with:(CPInt(^)(CPInt)) clo;
+(id<CPIntArray>) intArray: (id<CP>) cp range: (CPRange) r1 range: (CPRange) r2 with:(CPInt(^)(CPInt,CPInt)) clo;

+(id<CPIntMatrix>) intMatrix: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2;

+(id<CPIntSet>) intSet: (id<CP>) cp;
+(id<CPInformer>) informer: (id<CP>) cp;
+(id<CPVoidInformer>) voidInformer: (id<CP>) cp;
+(id<CPIntInformer>) intInformer: (id<CP>) cp;
+(id<CPBarrier>)  barrier: (id<CP>) cp value: (CPInt) nb;

+(id<CPTable>) table: (id<CP>) cp arity: (int) arity;

+(id<CPTRIntArray>)  TRIntArray: (id<CP>) cp range: (CPRange) R;
+(id<CPTRIntMatrix>) TRIntMatrix: (id<CP>) cp range: (CPRange) R1 : (CPRange) R2;

+(id<CPIntVarArray>) pointwiseProduct:(id<CPIntVarArray>)x by:(int*)c;

@end

@interface CPFactory (expression)

+(id<CPExpr>) expr: (id<CPExpr>) left add: (id<CPExpr>) right;
+(id<CPExpr>) expr: (id<CPExpr>) left sub: (id<CPExpr>) right;
+(id<CPExpr>) expr: (id<CPExpr>) left mul: (id<CPExpr>) right;
+(id<CPRelation>) expr: (id<CPExpr>) left equal: (id<CPExpr>) right;
+(id<CPExpr>) exprAbs: (id<CPExpr>) op;
+(id<CPExpr>) dotProduct:(id<CPIntVar>[])vars by:(int[])coefs;
+(id<CPExpr>) sum: (id<CP>) cp range: (CPRange) r filteredBy: (CPInt2Bool) f of: (CPInt2Expr) e;

@end;


