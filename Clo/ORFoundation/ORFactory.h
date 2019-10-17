/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORTrail.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORAnnotation.h>
#import <ORFoundation/ORSelector.h>
#import <ORFoundation/ORData.h>

@protocol ORSearchEngine;
@protocol ORSearchController;
@protocol ORSelect;
@protocol ORTrail;
@protocol ORTRIntArray;
@protocol ORTRIntMatrix;
@protocol ORAutomaton;
@protocol ORRealVarArray;
@protocol ORIntVarArray;
@protocol ORBitVarArray;
@protocol ORVarLitterals;

PORTABLE_BEGIN
@protocol OROrderedSweep <NSObject>
-(BOOL) next: (ORInt*) v;
@end

@interface ORFactory : NSObject
+(void) shutdown;
+(id<ORTrail>) trail;
+(id<ORMemoryTrail>) memoryTrail;
+(id<ORRandomStream>) randomStream: (id<ORTracker>) tracker;
+(id<ORZeroOneStream>) zeroOneStream: (id<ORTracker>) tracker;
+(id<ORUniformDistribution>) uniformDistribution: (id<ORTracker>) tracker range: (id<ORIntRange>) r;
+(id<ORRandomPermutation>) randomPermutation:(id<ORIntIterable>)onSet;
+(id<ORGroup>)group:(id<ORTracker>)model type:(enum ORGroupType)gt;
+(id<ORGroup>)group:(id<ORTracker>)model type:(enum ORGroupType)gt guard:(id<ORIntVar>)guard;
+(id<ORGroup>)group:(id<ORTracker>)model;
+(id<ORGroup>)cdisj:(id<ORTracker>)model clauses:(nullable NSArray*)clauses;
+(id<ORGroup>)cdisj:(id<ORTracker>)model vmap:(NSArray*)varMap;
+(id<ORGroup>)group:(id<ORTracker>)model guard:(id<ORIntVar>)g;
+(id<ORGroup>)bergeGroup:(id<ORTracker>)model;
+(id<ORInteger>) integer: (id<ORTracker>)tracker value: (ORInt) value;
+(id<ORMutableInteger>) mutable: (id<ORTracker>)tracker value: (ORInt) value;
+(id<ORDoubleNumber>) double: (id<ORTracker>) tracker value: (ORDouble) value;
+(id<ORMutableDouble>) mutableDouble: (id<ORTracker>) tracker value: (ORDouble) value;
+(id<ORMutableId>) mutableId:(id<ORTracker>) tracker value:(PNULLABLE id) value;
+(id<ORIntSet>)  intSet: (id<ORTracker>) tracker;
+(id<ORIntSet>) intSet:(id<ORTracker>) tracker set:(NSSet*)theSet;
+(id<ORIntRange>)  intRange: (id<ORTracker>) tracker low: (ORInt) low up: (ORInt) up;
+(id<ORRealRange>) realRange: (id<ORTracker>) tracker low:(ORDouble)low up:(ORDouble) up;

+(id<ORIntArray>) intArray: (id<ORTracker>) tracker array: (NSArray*)array;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORInt) value;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range values: (ORInt*) values;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo;

+(id<ORDoubleArray>) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORDouble) value;
+(id<ORDoubleArray>) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range values: (ORDouble*) values;
+(id<ORDoubleArray>) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORDouble(^)(ORInt)) clo;
+(id<ORDoubleArray>) doubleArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORDouble(^)(ORInt,ORInt)) clo;
+(id<ORDoubleArray>) doubleArray:(id<ORTracker>)tracker intVarArray: (id<ORIntVarArray>)arr;

+(id<ORIdArray>) idArray: (id<ORTracker>) tracker array: (NSArray*)array;
+(id<ORIdArray>) idArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(id(^)(ORInt))clo;
+(id<ORIdArray>) idArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;
+(id<ORIdArray>) sort:(id<ORTracker>)tracker idArray:(id<ORIdArray>)array with:(ORDouble(^)(id))f;

+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker with: (id<ORIdMatrix>) m;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker arity:(ORInt)arity ranges:(PNULLABLE id<ORIntRange>* PNONNULL)ranges;
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 with: (ORIntxInt2Int)block;
+(id<ORIntMatrix>) intMatrix: (id<ORTracker>) tracker with: (id<ORIntMatrix>) m;

+(id<ORIntSetArray>) intSetArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;

+(id<ORIntSet>) collect: (id<ORTracker>) cp range: (id<ORIntRange>) r suchThat: (PNULLABLE ORInt2Bool) f of: (ORInt2Int) e;
+(id<ORIntSet>) collect: (id<ORTracker>) tracker range: (id<ORIntRange>)r1 range:(id<ORIntRange>)r2
               suchThat: (PNULLABLE ORIntxInt2Bool) f
                     of: (ORIntxInt2Int) e;
+(id) slice:(id<ORTracker>)model range:(id<ORIntRange>)r suchThat:(PNULLABLE ORInt2Bool)f of:(ORInt2Id)e;

+(ORInt) minOver: (id<ORIntRange>) r suchThat: (PNULLABLE ORInt2Bool) filter of: (ORInt2Int)e;
+(ORInt) maxOver: (id<ORIntRange>) r suchThat: (PNULLABLE ORInt2Bool) filter of: (ORInt2Int)e;

+(id<IntEnumerator>) intEnumerator: (id<ORTracker>) cp over: (id<ORIntIterable>) r;
+(id<OROrderedSweep>) orderedSweep: (id<ORTracker>) t over: (id<ORIntIterable>) r filter: (ORInt2Bool) filter orderedBy: (ORInt2Double) o;
+(id<ORSelect>) select: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order;
+(id<ORSelect>) selectRandom: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order;
+(id<ORSelect>) selectRandom: (id<ORTracker>) tracker range: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Double) order randomized:(ORBool)rand;
+(id<ORSelector>) selectMin:(id<ORTracker>)tracker;
+(id<ORIntVar>) reifyView:(id<ORTracker>) tracker var:(id<ORIntVar>) x eqi:(ORInt)c;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker value: (ORInt) value;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker domain: (id<ORIntRange>) r;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker bounds: (id<ORIntRange>) r;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x shift: (ORInt) b;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker var:(id<ORIntVar>) x scale: (ORInt) a shift:(ORInt) b;
+(id<ORIntVar>) boolVar: (id<ORTracker>) solver;
+(id<ORBitVar>) bitVar:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORUInt)bLen;
+(id<ORBitVar>) bitVar:(id<ORTracker>)tracker withLength:(ORUInt)bLen;
//+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker low:(ORFloat) low up: (ORFloat) up;
//+(id<ORFloatVar>) floatVar: (id<ORTracker>) tracker;
//=======
+(id<ORRealVar>) realVar: (id<ORTracker>) tracker low:(ORDouble) low up: (ORDouble) up;
+(id<ORRealVar>) realVar: (id<ORTracker>) tracker;

+(id<ORVarArray>) varArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (id<ORVar>(^)(ORInt)) clo;


+(id<ORBindingArray>) bindingArray: (id<ORTracker>) tracker nb: (ORInt) nb;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range bounds: (id<ORIntRange>) domain;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with: (id<ORIntVar>(^)(ORInt)) clo;
+(id<ORExpr>) getStateValue:(id<ORTracker>)t lookup:(int)lookup;
+(id<ORExpr>) getStateValue:(id<ORTracker>)t lookupExpr:(id<ORExpr>)lookup;
+(id<ORExpr>) getStateValue:(id<ORTracker>)t lookup:(int)lookup arrayIndex:(id<ORInteger>)arrayIndex;
+(id<ORExpr>) getLeftStateValue:(id<ORTracker>)t lookup:(int)lookup;
+(id<ORExpr>) getLeftStateValue:(id<ORTracker>)t lookupExpr:(id<ORExpr>)lookup;
+(id<ORExpr>) getRightStateValue:(id<ORTracker>)t lookup:(int)lookup;
+(id<ORExpr>) getRightStateValue:(id<ORTracker>)t lookupExpr:(id<ORExpr>)lookup;
+(id<ORExpr>) valueAssignment:(id<ORTracker>)t;
+(id<ORExpr>) layerVariable:(id<ORTracker>)t;
+(id<ORExpr>) sizeOfArray:(id<ORExpr>)array track:(id<ORTracker>)t;
+(id<ORExpr>) parentInformation:(id<ORTracker>)t;
+(id<ORExpr>) minParentInformation:(id<ORTracker>)t;
+(id<ORExpr>) maxParentInformation:(id<ORTracker>)t;
+(id<ORExpr>) childInformation:(id<ORTracker>)t;
+(id<ORExpr>) minChildInformation:(id<ORTracker>)t;
+(id<ORExpr>) maxChildInformation:(id<ORTracker>)t;
+(id<ORExpr>) leftInformation:(id<ORTracker>)t;
+(id<ORExpr>) rightInformation:(id<ORTracker>)t;
+(id<ORExpr>) singletonSet:(id<ORExpr>)value track:(id<ORTracker>)t;
+(id<ORExpr>) generateMinMaxSetFrom:(id<ORExpr>)left and:(id<ORExpr>)right track:(id<ORTracker>)t;
+(id<ORExprArray>) arrayORExpr: (id<ORTracker>) cp range: (id<ORIntRange>) range with:(id<ORExpr>(^)(ORInt)) clo;
// Macros friendly
+(id<ORIntVarArray>) arrayORIntVar: (id<ORTracker>) cp range: (id<ORIntRange>) range with:(id<ORIntVar>(^)(ORInt)) clo;
+(id<ORIntVarArray>) arrayORIntVar: (id<ORTracker>) cp range: (id<ORIntRange>) r1 range: (id<ORIntRange>)r2  with:(id<ORIntVar>(^)(ORInt,ORInt)) clo;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 with:(id<ORIntVar>(^)(ORInt,ORInt)) clo;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) r1 : (id<ORIntRange>) r2 : (id<ORIntRange>) r3 with:(id<ORIntVar>(^)(ORInt,ORInt,ORInt)) clo;

+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 domain: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 bounds: (id<ORIntRange>) domain;

+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 domain: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) intVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2 bounds: (id<ORIntRange>) domain;
+(id<ORIntVarMatrix>) boolVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<ORIntVarMatrix>) boolVarMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
+(id<ORIntVarArray>) flattenMatrix:(id<ORIntVarMatrix>)m;

+(id<ORRealVarArray>) realVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range low:(ORDouble)low up:(ORDouble)up;
+(id<ORRealVarArray>) realVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;

+(id<ORTrailableIntArray>) trailableIntArray: (id<ORSearchEngine>) tracker range: (id<ORIntRange>) range value: (ORInt) value;
+(id<ORTrailableInt>) trailableInt: (id<ORSearchEngine>) solver value: (ORInt) value;
+(id<ORTRIntArray>)  TRIntArray: (id<ORTracker>) cp range: (id<ORIntRange>) R;
+(id<ORTRIntMatrix>) TRIntMatrix: (id<ORTracker>) cp range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2;
+(id<ORTable>) table: (id<ORTracker>) cp arity: (int) arity;
+(id<ORTable>) table: (id<ORTracker>) cp with: (id<ORTable>) table;
+(id<ORAutomaton>)automaton:(id<ORTracker>)tracker alphabet:(id<ORIntRange>)a states:(id<ORIntRange>)s transition:(ORTransition*)tf size:(ORInt)stf
                    initial:(ORInt)is
                      final:(id<ORIntSet>)fs;
+(id<ORVarLitterals>) varLitterals: (id<ORTracker>) tracker var: (id<ORIntVar>) v;
+(id<ORAnnotation>) annotation;

+(id<ORSolutionInformer>) solutionInformer;
@end

#define COLLECT(m,P,R,E) [ORFactory collect: m range:(R) suchThat:nil of:^ORInt(ORInt P) { return (ORInt)(E);}]


@interface ORFactory (Expressions)
+(id<ORExpr>) expr: (id<ORExpr>) left plus: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORExpr>) left sub: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORExpr>) left mul: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORExpr>) left div: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORExpr>) left mod: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORExpr>) left min: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORExpr>) left max: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORRelation>) expr: (id<ORExpr>) left equal: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORRelation>) expr: (id<ORExpr>) left neq: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORRelation>) expr: (id<ORExpr>) left leq: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORRelation>) expr: (id<ORExpr>) left geq: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORRelation>) left land: (id<ORRelation>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORRelation>) left lor: (id<ORRelation>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORRelation>) left imply: (id<ORRelation>) right track:(id<ORTracker>)t;
+(id<ORExpr>) exprAbs: (id<ORExpr>) op track:(id<ORTracker>)t;
+(id<ORExpr>) exprSquare: (id<ORExpr>) op track:(id<ORTracker>)t;
+(id<ORExpr>) exprNegate: (id<ORExpr>) op track:(id<ORTracker>)t;
+(id<ORExpr>) sum:  (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (PNULLABLE ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORExpr>) sum:  (id<ORTracker>) tracker over: (id<ORIntIterable>) S1 over: (id<ORIntIterable>) S2 suchThat: (PNULLABLE ORIntxInt2Bool) f of: (ORIntxInt2Expr) e;
+(id<ORExpr>) prod: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (PNULLABLE ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORRelation>) lor:  (id<ORTracker>) tracker over: (id<ORIntIterable>) r suchThat: (PNULLABLE ORInt2Bool) f of: (ORInt2Relation) e;
+(id<ORRelation>) land: (id<ORTracker>) tracker over: (id<ORIntIterable>) r suchThat: (PNULLABLE ORInt2Bool) f of: (ORInt2Relation) e;
+(id<ORExpr>) min: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (PNULLABLE ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORExpr>) max: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (PNULLABLE ORInt2Bool) f of: (ORInt2Expr) e;

+(id<ORExpr>) elt: (id<ORTracker>) tracker intVarArray: (id<ORIntVarArray>) a index: (id<ORExpr>) index;
+(id<ORExpr>) elt: (id<ORTracker>) tracker intArray: (id<ORIntArray>) a index: (id<ORExpr>) index;
+(id<ORExpr>) elt: (id<ORTracker>) tracker intVarMatrix: (id<ORIntVarMatrix>) m elt:(id<ORExpr>) e0 elt:(id<ORExpr>)e1;
+(id<ORExpr>) elt: (id<ORTracker>) tracker doubleArray: (id<ORDoubleArray>) a index: (id<ORExpr>) index;

+(id<ORExpr>) contains:(id<ORExpr>) value inSet:(id<ORIntSet>)set;
+(id<ORExpr>) contains:(id<ORExpr>) value inExpr:(id<ORExpr>)set;
+(id<ORExpr>) setUnion:(id<ORExpr>)left and:(id<ORExpr>)right;
+(id<ORExpr>) expr: (id<ORExpr>) left appendToArray: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) array:(id<ORExpr>)array atIndex:(id<ORExpr>)index track:(id<ORTracker>)t;
+(id<ORExpr>) ifExpr:(id<ORExpr>)i then:(id<ORExpr>)t elseReturn:(id<ORExpr>)e track:(id<ORTracker>)track;
+(id<ORExpr>) expr: (id<ORExpr>) left toEachInSetPlus: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) expr: (id<ORExpr>) left toEachInSetPlusEachInSet: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORRelation>) expr: (id<ORExpr>) left eachInSetLEQ: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORRelation>) expr: (id<ORExpr>) left eachInSetGEQ: (id<ORExpr>) right track:(id<ORTracker>)t;
+(id<ORExpr>) minBetweenArrays:(id<ORExpr>)left and:(id<ORExpr>)right track:(id<ORTracker>)track;
+(id<ORExpr>) maxBetweenArrays:(id<ORExpr>)left and:(id<ORExpr>)right track:(id<ORTracker>)track;
@end

@interface ORFactory (Constraints)
+(id<ORConstraint>) fail:(id<ORTracker>)model;
+(id<ORConstraint>) restrict:(id<ORTracker>)model var:(id<ORIntVar>)x to:(id<ORIntSet>)d;
+(id<ORConstraint>) imply:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eq: (id<ORIntVar>) y;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x neq: (id<ORIntVar>) y;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x neqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x leqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x geqi: (ORInt) i;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b with: (id<ORIntVar>) x leq: (id<ORIntVar>) y;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b sumbool:(id<ORIntVarArray>) x eqi: (ORInt) c;
+(id<ORConstraint>) reify:(id<ORTracker>)model boolean:(id<ORIntVar>) b sumbool:(id<ORIntVarArray>) x geqi: (ORInt) c;
+(id<ORConstraint>) hreify:(id<ORTracker>)model boolean:(id<ORIntVar>) b sumbool:(id<ORIntVarArray>) x eqi: (ORInt) c;
+(id<ORConstraint>) hreify:(id<ORTracker>)model boolean:(id<ORIntVar>) b sumbool:(id<ORIntVarArray>) x geqi: (ORInt) c;
+(id<ORConstraint>) clause:(id<ORTracker>)model over:(id<ORIntVarArray>) x equal:(id<ORIntVar>)tv;
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x leqi: (ORInt) c;
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x geqi: (ORInt) c;
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x eqi: (ORInt) c;
+(id<ORConstraint>) sumbool:(id<ORTracker>)model array:(id<ORIntVarArray>) x neqi: (ORInt) c;
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x eqi: (ORInt) c;
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x leqi: (ORInt) c;
+(id<ORConstraint>) sum:(id<ORTracker>)model array:(id<ORIntVarArray>) x geqi: (ORInt) c;
+(id<ORConstraint>) sum: (id<ORTracker>) model array: (id<ORIntVarArray>) x coef: (id<ORIntArray>) coef  eq: (ORInt) c;
+(id<ORConstraint>) sum: (id<ORTracker>) model array: (id<ORIntVarArray>) x coef: (id<ORIntArray>) coef  leq: (ORInt) c;

+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x lor:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x land:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y equal:(id<ORIntVar>)b;
+(id<ORConstraint>) model:(id<ORTracker>)model boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y;

+(id<ORConstraint>) model:(id<ORTracker>)model var:(id<ORIntVar>)y equal:(ORInt)a times:(id<ORIntVar>)x plus:(ORInt)b;
+(id<ORConstraint>) equal3:(id<ORTracker>)model  var:(id<ORIntVar>) x to: (id<ORIntVar>) y plus:(id<ORIntVar>) z;
+(id<ORConstraint>) equal:(id<ORTracker>)model  var: (id<ORVar>) x to: (id<ORVar>) y plus:(ORInt) c;
+(id<ORConstraint>) equalc:(id<ORTracker>)model  var: (id<ORIntVar>) x to:(ORInt) c;
+(id<ORConstraint>) notEqual:(id<ORTracker>)model  var: (id<ORIntVar>) x to: (id<ORIntVar>) y plus: (ORInt) c;
+(id<ORConstraint>) notEqual:(id<ORTracker>)model  var: (id<ORIntVar>) x to: (id<ORIntVar>) y;
+(id<ORSoftConstraint>) softNotEqual:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(id<ORIntVar>)y plus:(int)c slack: (id<ORVar>)slack;
+(id<ORConstraint>) notEqualc:(id<ORTracker>)model  var:(id<ORIntVar>)x to:(ORInt)c;
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y plus:(ORInt)c;
+(id<ORConstraint>) lEqual:(id<ORTracker>)model  coef:(ORInt)a times: (id<ORIntVar>)x leq:(ORInt)b times:(id<ORIntVar>) y plus:(ORInt)c;
+(id<ORConstraint>) lEqualc:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (ORInt) c;
+(id<ORConstraint>) gEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<ORConstraint>) gEqual:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y plus:(ORInt)c;
+(id<ORConstraint>) gEqualc:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (ORInt) c;
+(id<ORConstraint>) less:(id<ORTracker>)model  var: (id<ORIntVar>)x to: (id<ORIntVar>) y;
+(id<ORConstraint>) mult:(id<ORTracker>)model  var: (id<ORIntVar>)x by:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
+(id<ORConstraint>) square:(id<ORTracker>)model var:(id<ORVar>)x equal:(id<ORVar>)res;
+(id<ORConstraint>) geq:(id<ORTracker>)model  x: (id<ORIntVar>)x y: (id<ORIntVar>) y plus:(ORInt)c;

+(id<ORConstraint>) ExactMDDAllDifferent:(id<ORTracker>)model  var: (id<ORIntVarArray>)x reduced:(bool)reduced;
+(id<ORConstraint>) RestrictedMDDAllDifferent:(id<ORTracker>)model  var: (id<ORIntVarArray>)x size:(ORInt)restrictionSize reduced:(bool)reduced;
+(id<ORConstraint>) RelaxedMDDAllDifferent:(id<ORTracker>)model  var: (id<ORIntVarArray>)x size:(ORInt)relaxationSize reduced:(bool)reduced;
+(id<ORConstraint>) ExactMDDMISP:(id<ORTracker>)model  var: (id<ORIntVarArray>)x reduced:(bool)reduced adjacencies:( bool* _Nonnull * _Nonnull)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<ORIntVar>)objectiveValue;
+(id<ORConstraint>) RestrictedMDDMISP:(id<ORTracker>)model  var: (id<ORIntVarArray>)x size:(ORInt)restrictionSize reduced:(bool)reduced adjacencies:( bool* _Nonnull * _Nonnull)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<ORIntVar>)objectiveValue;
+(id<ORConstraint>) RelaxedMDDMISP:(id<ORTracker>)model  var: (id<ORIntVarArray>)x size:(ORInt)relaxationSize reduced:(bool)reduced adjacencies:( bool* _Nonnull * _Nonnull)adjacencyMatrix weights:(id<ORIntArray>)weights objective:(id<ORIntVar>)objectiveValue;
+(id<ORConstraint>) CustomMDD:(id<ORTracker>)model var: (id<ORIntVarArray>)x relaxed:(bool)relaxed size:(ORInt)relaxationSize stateClass:(Class)stateClass topDown:(bool)topDown;
+(id<ORConstraint>) CustomMDDWithObjective:(id<ORTracker>)model var: (id<ORIntVarArray>)x relaxed:(bool)relaxed size:(ORInt)relaxationSize objective:(id<ORIntVar>)objective maximize:(bool)maximize stateClass:(Class)stateClass;

+(id<ORMDDSpecs>) MDDSpecs:(id<ORTracker>)model variables:(id<ORIntVarArray>)x stateSize:(int)stateSize;
+(id<ORAltMDDSpecs>) AltMDDSpecs:(id<ORTracker>)model variables:(id<ORIntVarArray>)x;


+(id<ORConstraint>) mod:(id<ORTracker>)model var:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
+(id<ORConstraint>) mod:(id<ORTracker>)model var:(id<ORIntVar>)x modi:(ORInt)c equal:(id<ORIntVar>)z;
+(id<ORConstraint>) min:(id<ORTracker>)model var:(id<ORIntVar>)x land:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
+(id<ORConstraint>) max:(id<ORTracker>)model var:(id<ORIntVar>)x land:(id<ORIntVar>)y equal:(id<ORIntVar>)z;

+(id<ORConstraint>) abs:(id<ORTracker>)model  var: (id<ORIntVar>)x equal:(id<ORIntVar>)y;
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<ORIntVar>)y;
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORIntVar>)x idxVarArray:(id<ORIntVarArray>)c equal:(id<ORIntVar>)y;
+(id<ORConstraint>) element:(id<ORTracker>)model  var:(id<ORBitVar>)x idxBitVarArray:(id<ORIdArray>)c equal:(id<ORBitVar>)y;
+(id<ORConstraint>) element:(id<ORTracker>)model matrix:(id<ORIntVarMatrix>)m elt:(id<ORIntVar>)v0 elt:(id<ORIntVar>)v1 equal:(id<ORIntVar>)y;
+(id<ORConstraint>) lex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y;
+(id<ORConstraint>) circuit: (id<ORIntVarArray>) x;
+(id<ORConstraint>) path: (id<ORIntVarArray>) x;
+(id<ORConstraint>) subCircuit: (id<ORIntVarArray>) x;
+(id<ORConstraint>) nocycle: (id<ORIntVarArray>) x;
+(id<ORConstraint>) packing:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntArray>) binSize;
+(id<ORConstraint>) multiknapsack:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize capacity: (id<ORIntArray>) binSize;
+(id<ORConstraint>) multiknapsackOne:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b capacity: (ORInt) binSize;
+(id<ORConstraint>) meetAtmost:(id<ORTracker>)t x:(id<ORIntVarArray>) x y: (id<ORIntVarArray>) y atmost: (ORInt) atmost;
+(id<ORConstraint>) packing:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load;
+(id<ORConstraint>) packOne:(id<ORTracker>)t item:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize;
+(id<ORConstraint>) knapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c;
+(id<ORSoftConstraint>) softKnapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c slack: (id<ORVar>) slack;
+(id<ORConstraint>) alldifferent: (id<ORExprArray>) x;
+(id<ORConstraint>) among: (id<ORExprArray>) x values: (id<ORIntSet>) values low: (ORInt) low up: (ORInt) up;
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
+(id<ORConstraint>) algebraicConstraint: (id<ORTracker>) model expr: (id<ORRelation>) exp;
+(id<ORConstraint>) tableConstraint: (id<ORIntVarArray>) x table: (id<ORTable>) table;
+(id<ORConstraint>) tableConstraint: (id<ORTracker>)model table:(id<ORTable>) table on: (id<ORIntVar>) x : (id<ORIntVar>) y : (id<ORIntVar>) z;
+(id<ORConstraint>) assignment:(id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost;
+(id<ORConstraint>) regular:(id<ORIntVarArray>) x belongs:(id<ORAutomaton>)a;
@end

@interface ORFactory (ORReal)
+(id<ORConstraint>) realSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  eq: (ORDouble) c;
+(id<ORConstraint>) realSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  leq: (ORDouble) c;
+(id<ORConstraint>) realSum: (id<ORTracker>) model array: (id<ORVarArray>) x coef: (id<ORDoubleArray>) coef  geq: (ORDouble) c;
+(id<ORConstraint>) realSquare:(id<ORTracker>)model var:(id<ORRealVar>)x equal:(id<ORRealVar>)res;
+(id<ORConstraint>) realEqualc:(id<ORTracker>)model  var: (id<ORRealVar>) x to:(ORDouble) c;
+(id<ORConstraint>) realElement:(id<ORTracker>)model  var:(id<ORIntVar>)x idxCstArray:(id<ORDoubleArray>)c equal:(id<ORRealVar>)y;
@end

@interface ORFactory (BV)
+(id<ORBitVarArray>) bitVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;
+(id<ORConstraint>) bvEqualBit:(id<ORTracker>)tracker var:(id<ORBitVar>)x bit:(ORInt)k with:(ORInt)val;
+(id<ORConstraint>) bvEqualc:(id<ORTracker>)tracker var:(id<ORBitVar>)x to:(ORInt) c;

+(id<ORConstraint>) bit:(id<ORBitVar>)x eq:(id<ORBitVar>)y;
+(id<ORConstraint>) bit:(id<ORBitVar>)x bor:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x band:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x bnot:(id<ORBitVar>)y;
+(id<ORConstraint>) bit:(id<ORBitVar>)x bxor:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftLBy:(ORInt)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftLByBV:(id<ORBitVar>)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftRBy:(ORInt)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftRByBV:(id<ORBitVar>)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftRABy:(ORInt)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x shiftRAByBV:(id<ORBitVar>)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x rotateLBy:(ORInt)p eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x negative:(id<ORBitVar>)y;
+(id<ORConstraint>) bit:(id<ORBitVar>)x plus:(id<ORBitVar>)y withCarryIn:(id<ORBitVar>)ci eq:(id<ORBitVar>)z withCarryOut:(id<ORBitVar>)co;
+(id<ORConstraint>) bit:(id<ORBitVar>)x minus:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x times:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x dividedby:(id<ORBitVar>)y eq:(id<ORBitVar>)q rem:(id<ORBitVar>)r;
+(id<ORConstraint>) bit:(id<ORBitVar>)w trueIf:(id<ORBitVar>)x equals:(id<ORBitVar>)y zeroIfXEquals:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x count:(id<ORIntVar>)p;
+(id<ORConstraint>) bit:(id<ORBitVar>)x channel:(id<ORIntVar>)xc;
+(id<ORConstraint>) bit:(id<ORBitVar>)x zeroExtendTo:(id<ORBitVar>)p;
+(id<ORConstraint>) bit:(id<ORBitVar>)x signExtendTo:(id<ORBitVar>)p;
+(id<ORConstraint>) bit:(id<ORBitVar>)x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<ORBitVar>)p;
+(id<ORConstraint>) bit:(id<ORBitVar>)x concat:(id<ORBitVar>)y eq:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x EQ:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x LT:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x LE:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x SLE:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)x SLT:(id<ORBitVar>)y eval:(id<ORBitVar>)z;
+(id<ORConstraint>) bit:(id<ORBitVar>)i then:(id<ORBitVar>)t else:(id<ORBitVar>)e result:(id<ORBitVar>)r;
+(id<ORConstraint>) bit:(id<ORBitVarArray>)x logicalAndEval:(id<ORBitVar>)r;
+(id<ORConstraint>) bit:(id<ORBitVarArray>)x logicalOrEval:(id<ORBitVar>)r;
+(id<ORConstraint>) bit:(id<ORBitVar>)x orb:(id<ORBitVar>)y eval:(id<ORBitVar>)r;
+(id<ORConstraint>) bit:(id<ORBitVar>)x notb:(id<ORBitVar>)r;
+(id<ORConstraint>) bit:(id<ORBitVar>)x equalb:(id<ORBitVar>)y eval:(id<ORBitVar>)r;
@end

@interface ORFactory (ObjectiveValue)
+(id<ORObjectiveValue>) objectiveValueReal: (ORDouble) f minimize: (ORBool) b;
+(id<ORObjectiveValue>) objectiveValueInt: (ORInt) v minimize: (ORBool) b;
@end

PORTABLE_END


#define INTEGER(track,v)      [ORFactory mutable:track value:(v)]
#define RANGE(track,a,b)      [ORFactory intRange: track low: a up: b]
#define Sum(track,P,R,E)      [ORFactory sum:  track over:(R) suchThat:nil of:^id<ORExpr>(ORInt P) { return (id<ORExpr>)(E);}]
#define Sum2(track,I,R1,J,R2,E)      [ORFactory sum: track over:(R1) over:(R2) suchThat:nil of:^id<ORExpr>(ORInt I, ORInt J) { return (id<ORExpr>)(E);}]
#define Prod(track,P,R,E)     [ORFactory prod: track over:(R) suchThat:nil of:^id<ORExpr>(ORInt P) { return (id<ORExpr>)(E);}]
#define All(track,RT,P,RANGE,E)               [ORFactory array##RT: track range:(RANGE) with:^id<RT>(ORInt P) { return (E);}]
#define All2(track,RT,P1,RANGE1,P2,RANGE2,E)  [ORFactory array##RT: track range:(RANGE1) range:(RANGE2) with:^id<RT>(ORInt P1,ORInt P2) { return (E);}]
#define Or(track,P,R,E)       [ORFactory lor: track over:(R) suchThat:nil of:^id<ORRelation>(ORInt P) { return (id<ORRelation>)(E);}]
#define And(track,P,R,E)      [ORFactory land:track over:(R) suchThat:nil of:^id<ORRelation>(ORInt P) { return (id<ORRelation>)(E);}]

// [ldm] To check. Not clear why there is such a macro.
#define geq(track,x,y,c)      [ORFactory geq: track x: x y: y plus: c]

