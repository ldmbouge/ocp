/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>
#import <objcp/CPData.h>
#import <objcp/CPVar.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPISVarI.h>


@interface CPFactory (DataStructure)
+(void) print: (id) x;
+(id<CPIntVar>) intVar: (id<CPEngine>) cp value: (ORInt) value;
+(id<CPIntVar>) intVar: (id<CPEngine>) cp bounds: (id<ORIntRange>) range;
+(id<CPIntVar>) intVar: (id<CPEngine>) cp domain: (id<ORIntRange>) range;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x shift: (ORInt) b;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x scale: (ORInt) a;
+(id<CPIntVar>) intVar: (id<CPIntVar>) x scale: (ORInt) a shift:(ORInt) b;
+(id<CPIntVar>) boolVar: (id<CPEngine>)cp;
+(id<CPIntVar>) negate:(id<CPIntVar>)x;

+(id<CPRealVar>) realVar:(id<CPEngine>)cp bounds:(id<ORRealRange>) range;
+(id<CPRealVar>) realVar:(id<CPEngine>)cp castFrom:(id<CPIntVar>)x;
+(id<CPRealParam>) realParam:(id<CPEngine>)cp initialValue:(ORDouble)v;


+(id<CPFloatVar>) floatVar:(id<CPEngine>)cp bounds:(id<ORFloatRange>) range;
+(id<CPDoubleVar>) doubleVar:(id<CPEngine>)cp bounds:(id<ORDoubleRange>) range;
+(id<CPLDoubleVar>) ldoubleVar:(id<CPEngine>)cp bounds:(id<ORLDoubleRange>) range;

+(id<CPIntSetVar>) intSetVar:(id<CPEngine>)cp withSet:(id<ORIntSet>)theSet;

+(id<CPVarArray>) varArray: (id<ORTracker>) cp range: (id<ORIntRange>) range;
+(id<CPIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range;
+(id<CPIntVarArray>) intVarArray: (id<ORTracker>)cp range: (id<ORIntRange>) range with: (id<CPIntVar>(^)(ORInt)) clo;

+(id<CPIntVarMatrix>) intVarMatrix: (id<CPEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain;
+(id<CPIntVarMatrix>) intVarMatrix: (id<CPEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain;
+(id<CPIntVarMatrix>) boolVarMatrix: (id<CPEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<CPIntVarMatrix>) boolVarMatrix: (id<CPEngine>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<CPIntVarArray>) flattenMatrix:(id<CPIntVarMatrix>) m;

+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2;

+(id<ORIntSet>) intSet: (id<ORTracker>) cp;
+(id<ORInformer>) informer: (id<ORTracker>) cp;
+(id<ORVoidInformer>) voidInformer: (id<ORTracker>) cp;
+(id<ORIntInformer>) intInformer: (id<ORTracker>) cp;
+(id<ORBarrier>)  barrier: (id<ORTracker>) cp value: (ORInt) nb;

+(id<ORTable>) table: (id<ORTracker>) cp arity: (int) arity;
+(id<ORTRIntArray>)  TRIntArray: (id<ORTracker>) cp range: (id<ORIntRange>) R;
+(id<ORTRIntMatrix>) TRIntMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2;
@end

@interface CPFactory (expression)
+(id<ORExpr>) dotProduct:(__strong id<ORIntVar>[])vars by:(int[])coefs;
+(id<ORExpr>) sum: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORRelation>) lor: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;
@end

@interface CPFactory (BV)
+(id<CPBitVar>) bitVar:(id<CPEngine>)engine withLow: (ORUInt*) low andUp:(ORUInt*) up andLength:(int) len;
@end



#define FORALL(p,S,c,b,body) [cp forall:(S) suchThat:^bool(ORInt p) { return (c);} orderedBy:^ORInt(ORInt p) { return (b);} do:(body)];

