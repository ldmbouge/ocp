/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <objcp/CPEngine.h>
#import <objcp/CP.h>
#import <objcp/CPTable.h>
#import <objcp/CPHeuristic.h>
#import <objcp/CPData.h>

@interface CPFactory : NSObject
+(id<CPSolver>) createSolver;
//+(id<CPSolver>) createSemSolver;
+(id<CPSolver>) createRandomizedSolver;
+(id<CPSolver>) createDeterministicSolver;
//+(id<CPSolver>) createSemSolverFor:(id<CPEngine>)fdm;
+(void) shutdown;
+(id<CPHeuristic>) createDDeg:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createWDeg:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createIBS:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>)createFF:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createDDeg:(id<CPSolver>)cp;
+(id<CPHeuristic>) createWDeg:(id<CPSolver>)cp;
+(id<CPHeuristic>) createIBS:(id<CPSolver>)cp;
+(id<CPHeuristic>)createFF:(id<CPSolver>)cp;
@end;

void failNow();

@interface CPFactory (DataStructure)
+(void) print: (id) x;
+(id<ORInteger>) integer: (id<ORTracker>)tracker value: (ORInt) value;
+(id<ORIntVar>) intVar: (id<ORTracker>) cp bounds: (id<ORIntRange>) range;
+(id<ORIntVar>) intVar: (id<ORTracker>) cp domain: (id<ORIntRange>) range;
+(id<ORIntVar>) intVar: (id<ORIntVar>) x shift: (ORInt) b;
+(id<ORIntVar>) intVar: (id<ORIntVar>) x scale: (ORInt) a;
+(id<ORIntVar>) intVar: (id<ORIntVar>) x scale: (ORInt) a shift:(ORInt) b;
+(id<ORIntVar>)boolVar: (id<CPSolver>)cp;
+(id<ORIntVar>) negate:(id<ORIntVar>)x;

+(id<ORIntArray>) intArray: (id<CPSolver>) cp range: (id<ORIntRange>) range value: (ORInt) value;
+(id<ORIntArray>) intArray: (id<CPSolver>) cp range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo;
+(id<ORIntArray>) intArray: (id<CPSolver>) cp range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo;


+(id<ORVarArray>) varArray: (id<CPSolver>) cp range: (id<ORIntRange>) range;
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain;
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) range;
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) range with:(id<ORIntVar>(^)(ORInt)) clo;
+(id<ORIntVarArray>) arrayORIntVar: (id<CPSolver>) cp range: (id<ORIntRange>) range with:(id<ORIntVar>(^)(ORInt)) clo;
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 with:(id<ORIntVar>(^)(CPInt,CPInt)) clo;
+(id<ORIntVarArray>) intVarArray: (id<CPSolver>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 : (id<ORIntRange>) r3 with:(id<ORIntVar>(^)(CPInt,CPInt,CPInt)) clo;


+(id<ORIntVarMatrix>) intVarMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) intVarMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) boolVarMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<ORIntVarMatrix>) boolVarMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<ORIntVarArray>) flattenMatrix:(id<ORIntVarMatrix>) m;

+(id<ORIntMatrix>) intMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2;

+(id<ORIntSet>) intSet: (id<CPSolver>) cp;
+(id<ORInformer>) informer: (id<CPSolver>) cp;
+(id<ORVoidInformer>) voidInformer: (id<CPSolver>) cp;
+(id<ORIntInformer>) intInformer: (id<CPSolver>) cp;
+(id<ORBarrier>)  barrier: (id<CPSolver>) cp value: (ORInt) nb;

+(id<CPTable>) table: (id<CPSolver>) cp arity: (int) arity;

+(id<CPTRIntArray>)  TRIntArray: (id<CPSolver>) cp range: (id<ORIntRange>) R;
+(id<CPTRIntMatrix>) TRIntMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2;

+(id<ORIntVarArray>) pointwiseProduct:(id<ORIntVarArray>)x by:(int*)c;

+(id<CPRandomStream>) randomStream: (id<CPSolver>) cp ;
+(id<CPZeroOneStream>) zeroOneStream: (id<CPSolver>) cp ;
+(id<CPUniformDistribution>) uniformDistribution: (id<CPSolver>) cp range: (id<ORIntRange>) r;
@end

@interface CPFactory (expression)
+(id<ORExpr>) exprAbs: (id<ORExpr>) op;
+(id<ORExpr>) dotProduct:(id<ORIntVar>[])vars by:(int[])coefs;
+(id<ORExpr>) sum: (id<CPSolver>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
+(id<CPRelation>) or: (id<CPSolver>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;
@end


#define SUM(P,R,E)         [CPFactory sum: cp over:(R) suchThat:nil of:^id<ORExpr>(ORInt P) { return (id<ORExpr>)(E);}]
#define ALL(RT,P,RANGE,E)  [CPFactory array##RT:cp range:(RANGE) with:^id<RT>(ORInt P) { return (E);}]
#define OR(P,R,E)          [CPFactory or: cp over:(R) suchThat:nil of:^id<ORRelation>(ORInt P) { return (id<ORRelation>)(E);}]

