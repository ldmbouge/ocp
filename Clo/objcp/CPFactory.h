/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <objcp/CPEngine.h>
#import <objcp/CPSolver.h>
#import <objcp/CPHeuristic.h>
#import <objcp/CPData.h>

@interface CPFactory : NSObject
+(id<CPSolver>) createSolver;
+(id<CPSemSolver>) createSemSolver:(Class)ctrl;
+(id<CPEngine>) engine: (id<ORTrail>) trail;
//+(id<CPParSolver>) createParSolver:(int)nbt withController:(Class)ctrlClass;
+(id<CPSolver>) createRandomizedSolver;
+(id<CPSolver>) createDeterministicSolver;
//+(id<CPSolver>) createSemSolverFor:(id<CPEngine>)fdm;
+(void) shutdown;
+(id<CPHeuristic>) createDDeg:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createWDeg:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createIBS:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createABS:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createFF:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createDDeg:(id<CPSolver>)cp;
+(id<CPHeuristic>) createWDeg:(id<CPSolver>)cp;
+(id<CPHeuristic>) createIBS:(id<CPSolver>)cp;
+(id<CPHeuristic>) createABS:(id<CPSolver>)cp;
+(id<CPHeuristic>) createFF:(id<CPSolver>)cp;
+(id<ORSearchController>)dfsController:(id<CPSemSolver>)cp;
+(id<ORSearchController>)bdsController:(id<CPSemSolver>)cp;
@end;

void failNow();

@interface CPFactory (DataStructure)
+(void) print: (id) x;
+(id<ORInteger>) integer: (id<ORTracker>) tracker value: (ORInt) value;

+(id<CPIntVar>) intVar: (id<ORTracker>) cp bounds: (id<ORIntRange>) range;
+(id<CPIntVar>) intVar: (id<ORTracker>) cp domain: (id<ORIntRange>) range;
+(id<CPIntVar>) intVar: (id<ORIntVar>) x shift: (ORInt) b;
+(id<CPIntVar>) intVar: (id<ORIntVar>) x scale: (ORInt) a;
+(id<CPIntVar>) intVar: (id<ORIntVar>) x scale: (ORInt) a shift:(ORInt) b;
+(id<CPIntVar>) boolVar: (id<CPSolver>)cp;
+(id<CPIntVar>) negate:(id<ORIntVar>)x;

+(id<ORIntArray>) intArray: (id<ORTracker>) cp range: (id<ORIntRange>) range value: (ORInt) value;
+(id<ORIntArray>) intArray: (id<ORTracker>) cp range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo;
+(id<ORIntArray>) intArray: (id<ORTracker>) cp range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo;


+(id<ORVarArray>) varArray: (id<ORTracker>) cp range: (id<ORIntRange>) range;
+(id<CPIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range;

+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) boolVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<ORIntVarMatrix>) boolVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<ORIntVarArray>) flattenMatrix:(id<ORIntVarMatrix>) m;

+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2;

+(id<ORIntSet>) intSet: (id<ORTracker>) cp;
+(id<ORInformer>) informer: (id<ORTracker>) cp;
+(id<ORVoidInformer>) voidInformer: (id<ORTracker>) cp;
+(id<ORIntInformer>) intInformer: (id<ORTracker>) cp;
+(id<ORBarrier>)  barrier: (id<ORTracker>) cp value: (ORInt) nb;

+(id<ORTable>) table: (id<ORTracker>) cp arity: (int) arity;

+(id<ORRandomStream>) randomStream: (id<ORTracker>) cp ;
+(id<ORZeroOneStream>) zeroOneStream: (id<ORTracker>) cp ;
+(id<ORUniformDistribution>) uniformDistribution: (id<ORTracker>) cp range: (id<ORIntRange>) r;

+(id<ORTRIntArray>)  TRIntArray: (id<ORTracker>) cp range: (id<ORIntRange>) R;
+(id<ORTRIntMatrix>) TRIntMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2;

@end

// pvh: should be merged with below
@interface CPFactory (expression)
+(id<ORExpr>) exprAbs: (id<ORExpr>) op;
+(id<ORExpr>) dotProduct:(id<ORIntVar>[])vars by:(int[])coefs;
+(id<ORExpr>) sum: (id<ORTracker>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORRelation>) or: (id<ORTracker>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;
@end

#define FORALL(p,S,c,b,body) [cp forall:(S) suchThat:^bool(ORInt p) { return (c);} orderedBy:^ORInt(ORInt p) { return (b);} do:(body)];

