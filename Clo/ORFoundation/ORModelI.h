/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORObject.h"
#import "ORArray.h"
#import "ORSet.h"
#import "ORModel.h"
#import "ORVar.h"
#import "ORExprI.h"
#import "ORVisit.h"
#import "ORTypes.h"

@protocol ORObjective;

@interface ORConstraintI : ORModelingObjectI<ORConstraint>
-(ORConstraintI*) initORConstraintI;
-(void) setId: (ORUInt) name;
-(NSString*) description;
@end

@interface ORFail : ORConstraintI<ORFail>
-(ORFail*)init;
@end

@interface ORRestrict : ORConstraintI<ORRestrict>
-(ORRestrict*)initRestrict:(id<ORIntVar>)x to:(id<ORIntSet>)d;
-(id<ORIntVar>)var;
-(id<ORIntSet>)restriction;
@end

@interface OREqualc : ORConstraintI<OREqualc>
-(OREqualc*)initOREqualc:(id<ORIntVar>)x eqi:(ORInt)c;
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@interface ORNEqualc : ORConstraintI<ORNEqualc>
-(ORNEqualc*)initORNEqualc:(id<ORIntVar>)x neqi:(ORInt)c;
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@interface ORLEqualc : ORConstraintI<ORLEqualc>
-(ORLEqualc*)initORLEqualc:(id<ORIntVar>)x leqi:(ORInt)c;
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@interface ORGEqualc : ORConstraintI<ORGEqualc>
-(ORGEqualc*)initORGEqualc:(id<ORIntVar>)x geqi:(ORInt)c;
-(id<ORIntVar>) left;
-(ORInt) cst;
@end

@interface OREqual : ORConstraintI<OREqual>
-(OREqual*)initOREqual: (id<ORIntVar>) x eq: (id<ORIntVar>) y plus: (ORInt) c;
-(OREqual*)initOREqual: (id<ORIntVar>) x eq: (id<ORIntVar>) y plus: (ORInt) c annotation: (ORAnnotation) n;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt) cst;
@end

@interface ORAffine :ORConstraintI<ORAffine>
-(ORAffine*)initORAffine: (id<ORIntVar>) y eq:(ORInt)a times:(id<ORIntVar>) x plus: (ORInt) b annotation: (ORAnnotation) n;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt)coef;
-(ORInt)cst;
@end


@interface ORNEqual : ORConstraintI<ORNEqual,NSCoding>
-(ORNEqual*) initORNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y;
-(ORNEqual*) initORNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y plus: (ORInt) c;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt) cst;
@end

@interface ORLEqual : ORConstraintI<ORLEqual>
-(ORLEqual*)initORLEqual: (id<ORIntVar>) x leq: (id<ORIntVar>) y plus: (ORInt) c;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
-(ORInt) cst;
@end

@interface ORPlus : ORConstraintI<ORPlus>
-(ORPlus*)initORPlus:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z;
-(ORPlus*)initORPlus:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z annotation:(ORAnnotation)n;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORMult : ORConstraintI<ORMult>
-(ORMult*)initORMult:(id<ORIntVar>)x eq:(id<ORIntVar>)y times:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORSquare : ORConstraintI<ORSquare>
-(ORSquare*)initORSquare:(id<ORIntVar>)z square:(id<ORIntVar>)x annotation:(ORAnnotation)n;
-(id<ORIntVar>)res;
-(id<ORIntVar>)op;
-(ORAnnotation) annotation;
@end

@interface ORMod : ORConstraintI<ORMod>
-(ORMod*)initORMod:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORModc : ORConstraintI<ORModc>
-(ORModc*)initORModc:(id<ORIntVar>)x mod:(ORInt)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(ORInt) right;
@end

// PVH: should add annotation
@interface ORAbs : ORConstraintI<ORAbs>
-(ORAbs*)initORAbs:(id<ORIntVar>)x eqAbs:(id<ORIntVar>)y;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
@end

@interface OROr : ORConstraintI<OROr>
-(OROr*)initOROr:(id<ORIntVar>)x eq:(id<ORIntVar>)y or:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORAnd : ORConstraintI<ORAnd>
-(ORAnd*)initORAnd:(id<ORIntVar>)x eq:(id<ORIntVar>)y and:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORImply : ORConstraintI<ORImply>
-(ORAnd*)initORImply:(id<ORIntVar>)x eq:(id<ORIntVar>)y imply:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORElementCst : ORConstraintI<ORElementCst>
-(ORElementCst*)initORElement:(id<ORIntVar>)idx array:(id<ORIntArray>)y equal:(id<ORIntVar>)z annotation:(ORAnnotation)n; // y[idx] == z
-(id<ORIntArray>) array;
-(id<ORIntVar>)   idx;
-(id<ORIntVar>)   res;
-(ORAnnotation)annotation;
@end

@interface ORElementVar : ORConstraintI<ORElementVar>
-(ORElementVar*)initORElement:(id<ORIntVar>)idx array:(id<ORIntVarArray>)y equal:(id<ORIntVar>)z
                   annotation:(ORAnnotation)note; // y[idx] == z
-(id<ORIntVarArray>) array;
-(id<ORIntVar>)   idx;
-(id<ORIntVar>)   res;
-(ORAnnotation)annotation;
@end

@interface ORReifyEqualc : ORConstraintI<ORReifyEqualc>
-(ORReifyEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eqi:(ORInt)c;
@end

@interface ORReifyNEqualc : ORConstraintI<ORReifyNEqualc>
-(ORReifyNEqualc*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neqi:(ORInt)c;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@interface ORReifyEqual : ORConstraintI<ORReifyEqual>
-(ORReifyEqual*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eq:(id<ORIntVar>)y annotation:(ORAnnotation)n;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORAnnotation) annotation;
@end

@interface ORReifyNEqual : ORConstraintI<ORReifyNEqual>
-(ORReifyNEqual*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neq:(id<ORIntVar>)y annotation:(ORAnnotation)n;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORAnnotation) annotation;
@end

@interface ORReifyLEqualc : ORConstraintI<ORReifyLEqualc>
-(ORReifyLEqualc*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leqi:(ORInt)y;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@interface ORReifyLEqual : ORConstraintI<ORReifyLEqual>
-(ORReifyLEqual*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leq:(id<ORIntVar>)y annotation:(ORAnnotation)n;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORAnnotation) annotation;
@end

@interface ORReifyGEqualc : ORConstraintI<ORReifyGEqualc>
-(ORReifyGEqualc*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geqi:(ORInt)y;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(ORInt)        cst;
@end

@interface ORReifyGEqual : ORConstraintI<ORReifyGEqual>
-(ORReifyGEqual*) initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geq:(id<ORIntVar>)y annotation:(ORAnnotation)n;
-(id<ORIntVar>) b;
-(id<ORIntVar>) x;
-(id<ORIntVar>) y;
-(ORAnnotation) annotation;
@end

@interface ORSumBoolEqc : ORConstraintI<ORSumBoolEqc>
-(ORSumBoolEqc*) initSumBool:(id<ORIntVarArray>)ba eqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumBoolLEqc : ORConstraintI<ORSumBoolLEqc>
-(ORSumBoolLEqc*)initSumBool:(id<ORIntVarArray>)ba leqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumBoolGEqc : ORConstraintI<ORSumBoolGEqc>
-(ORSumBoolLEqc*)initSumBool:(id<ORIntVarArray>)ba geqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumEqc : ORConstraintI<ORSumEqc>
-(ORSumEqc*)initSum:(id<ORIntVarArray>)ia eqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumLEqc : ORConstraintI<ORSumLEqc>
-(ORSumLEqc*)initSum:(id<ORIntVarArray>)ia leqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORSumGEqc : ORConstraintI<ORSumGEqc>
-(ORSumGEqc*)initSum:(id<ORIntVarArray>)ia geqi:(ORInt)c;
-(id<ORIntVarArray>)vars;
-(ORInt)cst;
@end

@interface ORAlldifferentI : ORConstraintI<ORAlldifferent>
-(ORAlldifferentI*) initORAlldifferentI: (id<ORIntVarArray>) x annotation:(ORAnnotation)n;
-(id<ORIntVarArray>) array;
-(ORAnnotation) annotation;
@end

@interface ORCardinalityI : ORConstraintI<ORCardinality>
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
-(id<ORIntVarArray>) array;
-(id<ORIntArray>) low;
-(id<ORIntArray>) up;
-(ORAnnotation) annotation;
@end;

@interface ORAlgebraicConstraintI : ORConstraintI<ORAlgebraicConstraint>
-(ORAlgebraicConstraintI*) initORAlgebraicConstraintI: (id<ORRelation>) expr annotation:(ORAnnotation)n;
-(id<ORRelation>) expr;
-(ORAnnotation)annotation;
@end

@interface ORTableConstraintI : ORConstraintI<ORTableConstraint>
-(ORTableConstraintI*) initORTableConstraintI: (id<ORIntVarArray>) x table: (id<ORTable>) table;
-(id<ORIntVarArray>) array;
-(id<ORTable>) table;
@end

@interface ORLexLeq : ORConstraintI<ORLexLeq>
-(ORLexLeq*)initORLex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y;
-(id<ORIntVarArray>)x;
-(id<ORIntVarArray>)y;
@end

@interface ORCircuitI : ORConstraintI<ORCircuit>
-(ORCircuitI*)initORCircuitI:(id<ORIntVarArray>)x;
-(id<ORIntVarArray>) array;
@end

@interface ORNoCycleI : ORConstraintI<ORNoCycle>
-(ORCircuitI*)initORNoCycleI:(id<ORIntVarArray>)x;
-(id<ORIntVarArray>) array;
@end

@interface ORPackOneI : ORConstraintI<ORPackOne>
-(ORPackOneI*)initORPackOneI:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(ORInt) bin;
-(id<ORIntVar>) binSize;
@end

@interface ORPackingI : ORConstraintI<ORPacking>
-(ORPackingI*)initORPackingI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(id<ORIntVarArray>) binSize;
@end

@interface ORKnapsackI : ORConstraintI<ORKnapsack>
-(ORKnapsackI*)initORKnapsackI:(id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) weight;
-(id<ORIntVar>) capacity;
@end


@interface ORAssignmentI: ORConstraintI<ORAssignment>
-(ORAssignmentI*)initORAssignment:(id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost;
-(id<ORIntVarArray>) x;
-(id<ORIntMatrix>) matrix;
-(id<ORIntVar>) cost;
@end

@interface ORObjectiveFunctionI : ORModelingObjectI<ORObjectiveFunction> {
   id<ORIntVar>             _var;
}
-(ORObjectiveFunctionI*) initORObjectiveFunctionI: (id<ORIntVar>) x;
-(id<ORIntVar>) var;
-(BOOL) concretized;
-(void) visit: (id<ORVisitor>) visitor;
@end

@interface ORIntObjectiveValue : NSObject<ORObjectiveValue> {
   ORInt     _value;
   ORInt _direction;
}
-(id)initObjectiveValue:(id<ORIntVar>)var minimize:(BOOL)b;
-(ORInt)value;
-(ORFloat)key;
-(NSString*)description;
@end

@interface ORMinimizeI : ORObjectiveFunctionI<ORObjectiveFunction>
-(ORMinimizeI*) initORMinimizeI: (id<ORIntVar>) x;
-(id<ORObjectiveValue>)value;
@end

@interface ORMaximizeI : ORObjectiveFunctionI<ORObjectiveFunction>
-(ORMaximizeI*) initORMaximizeI: (id<ORIntVar>) x;
-(id<ORObjectiveValue>)value;
@end

@interface ORBitEqual : ORConstraintI<ORBitEqual>
-(ORBitEqual*)initORBitEqual: (id<ORBitVar>) x eq: (id<ORBitVar>) y;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitOr : ORConstraintI<ORBitOr>
-(ORBitOr*)initORBitOr: (id<ORBitVar>) x or: (id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitAnd : ORConstraintI<ORBitAnd>
-(ORBitAnd*)initORBitAnd: (id<ORBitVar>) x and: (id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitNot : ORConstraintI<ORBitNot>
-(ORBitNot*)initORBitNot: (id<ORBitVar>) x not: (id<ORBitVar>) y;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitXor : ORConstraintI<ORBitXor>
-(ORBitXor*)initORBitXor: (id<ORBitVar>) x xor: (id<ORBitVar>) y eq:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitShiftL : ORConstraintI<ORBitShiftL>
-(ORBitShiftL*)initORBitShiftL: (id<ORBitVar>) x by:(ORInt)p eq: (id<ORBitVar>) y;
-(ORInt) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitRotateL : ORConstraintI<ORBitRotateL>
-(ORBitRotateL*)initORBitRotateL: (id<ORBitVar>) x by:(ORInt)p eq: (id<ORBitVar>) y;
-(ORInt) places;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
@end

@interface ORBitSum : ORConstraintI<ORBitSum>
-(ORBitSum*)initORBitSum: (id<ORBitVar>) x plus:(id<ORBitVar>) y in:(id<ORBitVar>)ci eq:(id<ORBitVar>)z out:(id<ORBitVar>)co;
-(id<ORBitVar>) left;
-(id<ORBitVar>) right;
-(id<ORBitVar>) res;
-(id<ORBitVar>) in;
-(id<ORBitVar>) out;
@end

@interface ORBitIf : ORConstraintI<ORBitIf>
-(ORBitIf*)initORBitIf: (id<ORBitVar>) w trueIf:(id<ORBitVar>) x equals:(id<ORBitVar>)y zeroIfXEquals:(id<ORBitVar>)z;
-(id<ORBitVar>) res;
-(id<ORBitVar>) trueIf;
-(id<ORBitVar>) equals;
-(id<ORBitVar>) zeroIfXEquals;
@end
