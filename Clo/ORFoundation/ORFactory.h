/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORData.h"
#import "ORFoundation/ORArray.h"
#import "ORFoundation/ORSet.h"
#import "ORModelI.h"
#import "ORTrail.h"

@protocol OREngine;
@protocol ORSearchController;
@protocol ORSelect;

@interface ORFactory : NSObject
+(id<ORTrail>) trail;
+(id<ORInteger>) integer: (id<ORTracker>) tracker value: (ORInt) value;
+(id<ORIntSet>)  intSet: (id<ORTracker>) tracker;
+(id<ORIntRange>)  intRange: (id<ORTracker>) tracker low: (ORInt) low up: (ORInt) up;

+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORInt) value;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo;

+(id<ORIdArray>)   idArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2;

+(id<ORIntSetArray>) intSetArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;
+(id<ORIntSet>) collect: (id<ORTracker>) cp range: (id<ORIntRange>) r suchThat: (ORInt2Bool) f of: (ORInt2Int) e;

+(id<IntEnumerator>) intEnumerator: (id<ORTracker>) cp over: (id<ORIntIterator>) r;
+(id<ORSelect>) select: (id<ORTracker>) tracker range: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order;
+(id<ORSelect>) selectRandom: (id<ORTracker>) tracker range: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order;

+(id<ORIntVar>) intVar: (id<ORTracker>) tracker domain: (id<ORIntRange>) r;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x shift: (ORInt) b;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a shift:(ORInt) b;
+(id<ORIntVar>) boolVar: (id<ORTracker>) solver;

+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up;

+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (id<ORIntVar>(^)(ORInt)) clo;
+(id<ORIntVarArray>) intVarArrayDereference: (id<ORTracker>) tracker array: (id<ORIntVarArray>) a;
+(id<ORIntVarArray>) arrayORIntVar: (id<ORTracker>) cp range: (id<ORIntRange>) range with:(id<ORIntVar>(^)(ORInt)) clo;
+(id<ORIntVarArray>) arrayORIntVar: (id<ORTracker>) cp range: (id<ORIntRange>) r1 range: (id<ORIntRange>)r2  with:(id<ORIntVar>(^)(ORInt,ORInt)) clo;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 with:(id<ORIntVar>(^)(ORInt,ORInt)) clo;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 : (id<ORIntRange>) r3 with:(id<ORIntVar>(^)(ORInt,ORInt,ORInt)) clo;

+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) boolVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<ORIntVarMatrix>) boolVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;

+(id<ORTrailableIntArray>) trailableIntArray: (id<OREngine>) tracker range: (id<ORIntRange>) range value: (ORInt) value;

+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x;
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
+(id<ORConstraint>) algebraicConstraint: (id<ORTracker>) model expr: (id<ORRelation>) exp;
+(id<ORConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntVarArray>) binSize;
+(id<ORConstraint>) tableConstraint: (id<ORIntVarArray>) x table: (id<ORTable>) table;
+(id<ORConstraint>) tableConstraint: (id<ORTable>) table on: (id<ORIntVar>) x : (id<ORIntVar>) y : (id<ORIntVar>) z;
+(id<ORTrailableInt>) trailableInt: (id<OREngine>) solver value: (ORInt) value;
+(id<ORTRIntArray>)  TRIntArray: (id<ORTracker>) cp range: (id<ORIntRange>) R;
+(id<ORTRIntMatrix>) TRIntMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2;

+(id<ORTable>) table: (id<ORTracker>) cp arity: (int) arity;
@end

#define COLLECT(m,P,R,E) [ORFactory collect: m range:(R) suchThat:nil of:^ORInt(ORInt P) { return (ORInt)(E);}]

@interface ORFactory (Expressions)
+(id<ORExpr>) expr: (id<ORExpr>) left plus: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORExpr>) left sub: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORExpr>) left mul: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left equal: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left neq: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left leq: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left geq: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left and: (id<ORRelation>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left or: (id<ORRelation>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left imply: (id<ORRelation>) right;
+(id<ORExpr>) exprAbs: (id<ORExpr>) op;
+(id<ORExpr>) sum: (id<ORTracker>) tracker over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORRelation>) or: (id<ORTracker>) tracker over: (id<ORIntIterator>) r suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;

+(id<ORExpr>) elt: (id<ORTracker>) tracker intVarArray: (id<ORIntVarArray>) a index: (id<ORExpr>) index;
+(id<ORExpr>) elt: (id<ORTracker>) tracker intArray: (id<ORIntArray>) a index: (id<ORExpr>) index;
@end

#define RANGE(track,a,b)      [ORFactory intRange: track low: a up: b]
#define Sum(track,P,R,E) [ORFactory sum: track over:(R) suchThat:nil of:^id<ORExpr>(ORInt P) { return (id<ORExpr>)(E);}]
#define All(track,RT,P,RANGE,E)               [ORFactory array##RT: track range:(RANGE) with:^id<RT>(ORInt P) { return (E);}]
#define All2(track,RT,P1,RANGE1,P2,RANGE2,E)  [ORFactory array##RT: track range:(RANGE1) range:(RANGE2) with:^id<RT>(ORInt P1,ORInt P2) { return (E);}]
#define Or(track,P,R,E)          [ORFactory or: track over:(R) suchThat:nil of:^id<ORRelation>(ORInt P) { return (id<ORRelation>)(E);}]
