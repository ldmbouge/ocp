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

@protocol ORSearchEngine;
@protocol ORSearchController;
@protocol ORSelect;
@protocol ORTrail;
@protocol ORTRIntArray;
@protocol ORTRIntMatrix;

@interface ORFactory : NSObject
+(void) shutdown;
+(id<ORTrail>) trail;
+(id<ORRandomStream>) randomStream: (id<ORTracker>) tracker;
+(id<ORZeroOneStream>) zeroOneStream: (id<ORTracker>) tracker;
+(id<ORUniformDistribution>) uniformDistribution: (id<ORTracker>) tracker range: (id<ORIntRange>) r;
+(id<ORGroup>)group:(id<ORTracker>)model type:(enum ORGroupType)gt;
+(id<ORGroup>)group:(id<ORTracker>)model;
+(id<ORGroup>)bergeGroup:(id<ORTracker>)model;
+(id<ORInteger>) integer: (id<ORTracker>) tracker value: (ORInt) value;
+(id<ORFloatNumber>) float: (id<ORTracker>) tracker value: (ORFloat) value;
+(id<ORIntSet>)  intSet: (id<ORTracker>) tracker;
+(id<ORIntRange>)  intRange: (id<ORTracker>) tracker low: (ORInt) low up: (ORInt) up;

+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORInt) value;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range values: (ORInt[]) values;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo;

+(id<ORFloatArray>) floatArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORFloat) value;
+(id<ORFloatArray>) floatArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range values: (ORFloat[]) values;
+(id<ORFloatArray>) floatArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORFloat(^)(ORInt)) clo;
+(id<ORFloatArray>) floatArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORFloat(^)(ORInt,ORInt)) clo;
+(id<ORFloatArray>) floatArray:(id<ORTracker>)tracker intVarArray: (id<ORIntVarArray>)arr;

+(id<ORIdArray>)   idArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;

+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker withDereferenced: (id<ORIdMatrix>) m;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker arity:(ORInt)arity ranges:(id<ORIntRange>*)ranges;
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 using: (ORIntxInt2Int)block;
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker with: (id<ORIntMatrix>) m;

+(id<ORIntSetArray>) intSetArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;

+(id<ORIntSet>) collect: (id<ORTracker>) cp range: (id<ORIntRange>) r suchThat: (ORInt2Bool) f of: (ORInt2Int) e;

+(ORInt) minOver: (id<ORIntRange>) r suchThat: (ORInt2Bool) filter of: (ORInt2Int)e;
+(ORInt) maxOver: (id<ORIntRange>) r suchThat: (ORInt2Bool) filter of: (ORInt2Int)e;

+(id<IntEnumerator>) intEnumerator: (id<ORTracker>) cp over: (id<ORIntIterable>) r;
+(id<ORSelect>) select: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order;
+(id<ORSelect>) selectRandom: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Float) order;

+(id<ORIntVar>) reifyView:(id<ORTracker>) tracker var:(id<ORIntVar>) x eqi:(ORInt)c;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker domain: (id<ORIntRange>) r;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x shift: (ORInt) b annotation:(ORAnnotation)c;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a annotation:(ORAnnotation)c;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a shift:(ORInt) b annotation:(ORAnnotation)c;
+(id<ORIntVar>) boolVar: (id<ORTracker>) solver;
+(id<ORBitVar>) bitVar:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORUInt)bLen;
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up;
+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker;

+(id<ORVarArray>) varArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (id<ORVar>(^)(ORInt)) clo;


+(id<ORBindingArray>) bindingArray: (id<ORTracker>) tracker nb: (ORInt) nb;
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
+(id<ORIntVarArray>) flattenMatrix:(id<ORIntVarMatrix>)m;

+(id<ORFloatVarArray>) floatVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range low:(ORFloat)low up:(ORFloat)up;
+(id<ORFloatVarArray>) floatVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;

+(id<ORTrailableIntArray>) trailableIntArray: (id<ORSearchEngine>) tracker range: (id<ORIntRange>) range value: (ORInt) value;
+(id<ORTrailableInt>) trailableInt: (id<ORSearchEngine>) solver value: (ORInt) value;
+(id<ORTRIntArray>)  TRIntArray: (id<ORTracker>) cp range: (id<ORIntRange>) R;
+(id<ORTRIntMatrix>) TRIntMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2;
+(id<ORTable>) table: (id<ORTracker>) cp arity: (int) arity;
+(id<ORTable>) table: (id<ORTracker>) cp with: (id<ORTable>) table;
@end

#define COLLECT(m,P,R,E) [ORFactory collect: m range:(R) suchThat:nil of:^ORInt(ORInt P) { return (ORInt)(E);}]

@interface ORFactory (Expressions)
+(id<ORExpr>) expr: (id<ORExpr>) left plus: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORExpr>) left sub: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORExpr>) left mul: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORExpr>) left div: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORExpr>) left mod: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left equal: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left neq: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left leq: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left geq: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left and: (id<ORRelation>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left or: (id<ORRelation>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left imply: (id<ORRelation>) right;
+(id<ORExpr>) exprAbs: (id<ORExpr>) op;
+(id<ORExpr>) exprNegate: (id<ORExpr>) op;
+(id<ORExpr>) sum:  (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORExpr>) sum:  (id<ORTracker>) tracker over: (id<ORIntIterable>) S1 over: (id<ORIntIterable>) S2 suchThat: (ORIntxInt2Bool) f of: (ORIntxInt2Expr) e;
+(id<ORExpr>) prod: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORRelation>) or: (id<ORTracker>) tracker over: (id<ORIntIterable>) r suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;

+(id<ORExpr>) elt: (id<ORTracker>) tracker intVarArray: (id<ORIntVarArray>) a index: (id<ORExpr>) index;
+(id<ORExpr>) elt: (id<ORTracker>) tracker intArray: (id<ORIntArray>) a index: (id<ORExpr>) index;
@end

@interface ORFactory (Constraints)
+(id<ORConstraint>) fail:(id<ORTracker>)model;
+(id<ORConstraint>) restrict:(id<ORTracker>)model var:(id<ORIntVar>)x to:(id<ORIntSet>)d;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eq: (id<ORIntVar>) y annotation:(ORAnnotation)c;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x neq: (id<ORIntVar>) y annotation:(ORAnnotation)c;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x neqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x leqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x geqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x leq: (id<ORIntVar>) y;
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x leqi: (ORInt) c;
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x geqi: (ORInt) c;
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x eqi: (ORInt) c;
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x eqi: (ORInt) c;
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x leqi: (ORInt) c;
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x geqi: (ORInt) c;
+(id<ORConstraint>) sum: (id<ORTracker>) model array: (id<ORIntVarArray>) x coef: (id<ORIntArray>) coef  eq: (ORInt) c;
+(id<ORConstraint>) sum: (id<ORTracker>) model array: (id<ORIntVarArray>) x coef: (id<ORIntArray>) coef  leq: (ORInt) c;

+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  eq: (ORFloat) c;
+(id<ORConstraint>) floatSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORFloatArray>) coef  leq: (ORFloat) c;

+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x or:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<ORConstraint>) model:(id<ORTracker>)model var:(id<ORIntVar>)y equal:(ORInt)a times:(id<ORIntVar>)x plus:(ORInt)b annotation:(ORAnnotation)n;
+(id<ORConstraint>) equal3:(id<ORTracker>)model  var:(id<ORIntVar>) x to: (id<ORIntVar>) y plus:(id<ORIntVar>) z annotation: (ORAnnotation)cons;
+(id<ORConstraint>) equal:(id<ORTracker>)model  var: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(ORInt) c annotation: (ORAnnotation)cons;
+(id<ORConstraint>) equal:(id<ORTracker>)model  var: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (ORInt) c;
+(id<ORConstraint>) equalc:(id<ORTracker>)model  var: (id<ORIntVar>) x to:(ORInt) c;
+(id<ORConstraint>) notEqual:(id<ORTracker>)model  var: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (ORInt) c;
+(id<ORConstraint>) notEqual:(id<ORTracker>)model  var: (id<ORIntVar>) x to: (id<ORIntVar>) y;
+(id<ORConstraint>) notEqualc:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(ORInt)c;
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y plus:(ORInt)c;
+(id<ORConstraint>) lEqualc:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (ORInt) c;
+(id<ORConstraint>) gEqualc:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (ORInt) c;
+(id<ORConstraint>) less:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<ORConstraint>) mult:(id<ORTracker>)model  var: (id<ORIntVar>)x by:(id<ORIntVar>)y equal:(id<ORIntVar>)z annotation:(ORAnnotation)c;
+(id<ORConstraint>) square:(id<ORTracker>)model var:(id<ORIntVar>)x equal:(id<ORIntVar>)res annotation:(ORAnnotation)n;
+(id<ORConstraint>) mod:(id<ORTracker>)model var:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
+(id<ORConstraint>) mod:(id<ORTracker>)model var:(id<ORIntVar>)x modi:(ORInt)c equal:(id<ORIntVar>)z annotation:(ORAnnotation)n;
+(id<ORConstraint>) abs:(id<ORTracker>)model  var: (id<ORIntVar>)x equal:(id<ORIntVar>)y annotation:(ORAnnotation)c;
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<ORIntVar>)y
                 annotation:(ORAnnotation)note;
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORIntVar>)x idxVarArray:(id<ORIntVarArray>)c equal:(id<ORIntVar>)y
                 annotation:(ORAnnotation)note;

+(id<ORConstraint>) lex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y;
+(id<ORConstraint>) circuit: (id<ORIntVarArray>) x;
+(id<ORConstraint>) nocycle: (id<ORIntVarArray>) x;
+(id<ORConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntArray>) binSize;
+(id<ORConstraint>) packing: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load;
+(id<ORConstraint>) packOne: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize;
+(id<ORConstraint>) knapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c;
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x;
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x annotation:(ORAnnotation)c;
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up annotation:(ORAnnotation)c;
+(id<ORConstraint>) algebraicConstraint: (id<ORTracker>) model expr: (id<ORRelation>) exp annotation:(ORAnnotation)note;
+(id<ORConstraint>) tableConstraint: (id<ORIntVarArray>) x table: (id<ORTable>) table;
+(id<ORConstraint>) tableConstraint: (id<ORTable>) table on: (id<ORIntVar>) x : (id<ORIntVar>) y : (id<ORIntVar>) z;
+(id<ORConstraint>) assignment:(id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost;
@end

@interface ORFactory (BV)
+(id<ORConstraint>) bit:(id<ORBitVar>)x eq:(id<ORBitVar>)y;
+(id<ORConstraint>) bit:(id<ORBitVar>)x or:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x and:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x not:(id<ORBitVar>)y;
+(id<ORConstraint>) bit:(id<ORBitVar>)x xor:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftLBy:(ORInt)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x rotateLBy:(ORInt)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x plus:(id<ORBitVar>)y withCarryIn:(id<ORBitVar>)ci eq:(id<ORBitVar>)z withCarryOut:(id<ORBitVar>)co;
+(id<ORConstraint>) bit:(id<ORBitVar>)w trueIf:(id<ORBitVar>)x equals:(id<ORBitVar>)y zeroIfXEquals:(id<ORBitVar>)z;
@end

@interface ORFactory (ObjectiveValue)
+(id<ORObjectiveValue>) objectiveValueFloat: (ORFloat) f minimize: (ORBool) b;
+(id<ORObjectiveValue>) objectiveValueInt: (ORInt) v minimize: (ORBool) b;
@end

#define INTEGER(track,v)      [ORFactory integer:track value:(v)]
#define RANGE(track,a,b)      [ORFactory intRange: track low: a up: b]
#define Sum(track,P,R,E)      [ORFactory sum:  track over:(R) suchThat:nil of:^id<ORExpr>(ORInt P) { return (id<ORExpr>)(E);}]
#define Sum2(track,I,R1,J,R2,E)      [ORFactory sum: track over:(R1) over:(R2) suchThat:nil of:^id<ORExpr>(ORInt I, ORInt J) { return (id<ORExpr>)(E);}]
#define Prod(track,P,R,E)     [ORFactory prod: track over:(R) suchThat:nil of:^id<ORExpr>(ORInt P) { return (id<ORExpr>)(E);}]
#define All(track,RT,P,RANGE,E)               [ORFactory array##RT: track range:(RANGE) with:^id<RT>(ORInt P) { return (E);}]
#define All2(track,RT,P1,RANGE1,P2,RANGE2,E)  [ORFactory array##RT: track range:(RANGE1) range:(RANGE2) with:^id<RT>(ORInt P1,ORInt P2) { return (E);}]
#define Or(track,P,R,E)       [ORFactory or: track over:(R) suchThat:nil of:^id<ORRelation>(ORInt P) { return (id<ORRelation>)(E);}]

