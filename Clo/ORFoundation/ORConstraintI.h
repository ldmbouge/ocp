/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORTypes.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORConstraint.h>
#import "ORArray.h"
#import "ORSet.h"
#import "ORVar.h"
#import "ORExprI.h"
#import "ORVisit.h"

@interface ORGroupI : ORObject<ORGroup>
-(ORGroupI*)initORGroupI:(id<ORTracker>)model type:(enum ORGroupType)gt;
-(id<ORConstraint>)add:(id<ORConstraint>)c;
-(NSString*) description;
-(void)enumerateObjectWithBlock:(void(^)(id<ORConstraint>))block;
-(ORInt) size;
-(id<ORConstraint>) at: (ORInt) idx;
-(enum ORGroupType)type;
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

@interface ORFloatEqualc : ORConstraintI<ORFloatEqualc>
-(OREqualc*)init:(id<ORFloatVar>)x eqi:(ORFloat)c;
-(id<ORFloatVar>) left;
-(ORFloat) cst;
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
-(id)initOREqual: (id<ORVar>) x eq: (id<ORVar>) y plus: (ORInt) c;
-(id)initOREqual: (id<ORVar>) x eq: (id<ORVar>) y plus: (ORInt) c annotation: (ORAnnotation) n;
-(id<ORVar>) left;
-(id<ORVar>) right;
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
-(ORMult*)initORMult:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z;
-(id<ORVar>) res;
-(id<ORVar>) left;
-(id<ORVar>) right;
@end

@interface ORSquare : ORConstraintI<ORSquare>
-(ORSquare*)init:(id<ORVar>)z square:(id<ORVar>)x annotation:(ORAnnotation)n;
-(id<ORVar>)res;
-(id<ORVar>)op;
-(ORAnnotation) annotation;
@end

@interface ORFloatSquare : ORSquare
@end

@interface ORMod : ORConstraintI<ORMod>
-(ORMod*)initORMod:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORModc : ORConstraintI<ORModc>
-(ORModc*)initORModc:(id<ORIntVar>)x mod:(ORInt)y equal:(id<ORIntVar>)z annotation:(ORAnnotation)n;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(ORInt) right;
-(ORAnnotation) annotation;
@end

@interface ORMin : ORConstraintI<ORMin>
-(ORMod*)init:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

@interface ORMax : ORConstraintI<ORMax>
-(ORMod*)init:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)z;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(id<ORIntVar>) right;
@end

// PVH: should add annotation
@interface ORAbs : ORConstraintI<ORAbs>
-(ORAbs*)initORAbs:(id<ORIntVar>)x eqAbs:(id<ORIntVar>)y;
-(id<ORIntVar>) res;
-(id<ORIntVar>) left;
-(ORAnnotation) annotation;
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
-(ORImply*)initORImply:(id<ORIntVar>)x eq:(id<ORIntVar>)y imply:(id<ORIntVar>)z;
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

@interface ORElementMatrixVar : ORConstraintI<ORElementMatrixVar>
-(id)initORElement:(id<ORIntVarMatrix>)m elt:(id<ORIntVar>)v0 elt:(id<ORIntVar>)v1 equal:(id<ORIntVar>)y annotation:(ORAnnotation)n;
-(id<ORIntVarMatrix>)matrix;
-(id<ORIntVar>)index0;
-(id<ORIntVar>)index1;
-(id<ORIntVar>) res;
-(ORAnnotation)annotation;
@end

@interface ORFloatElementCst : ORConstraintI<ORFloatElementCst>
-(ORElementCst*)initORElement:(id<ORIntVar>)idx array:(id<ORFloatArray>)y equal:(id<ORFloatVar>)z annotation:(ORAnnotation)n; // y[idx] == z
-(id<ORFloatArray>) array;
-(id<ORIntVar>)       idx;
-(id<ORFloatVar>)     res;
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
-(ORSumBoolGEqc*)initSumBool:(id<ORIntVarArray>)ba geqi:(ORInt)c;
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

@interface ORLinearEq : ORConstraintI<ORLinearEq>
-(ORLinearEq*) initLinearEq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) ca cst: (ORInt) c;
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@interface ORLinearLeq : ORConstraintI<ORLinearLeq>
-(id) initLinearLeq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) ca cst: (ORInt)c;
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@interface ORLinearGeq : ORConstraintI<ORLinearGeq>
-(id) initLinearGeq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) ca cst: (ORInt)c;
-(id<ORIntVarArray>) vars;
-(id<ORIntArray>) coefs;
-(ORInt) cst;
@end

@interface ORFloatLinearEq : ORConstraintI<ORFloatLinearEq>
-(ORLinearEq*) initFloatLinearEq: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORFloatLinearLeq : ORConstraintI<ORFloatLinearLeq>
-(ORFloatLinearLeq*) initFloatLinearLeq: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORFloatLinearGeq : ORConstraintI<ORFloatLinearGeq>
-(ORFloatLinearGeq*) initFloatLinearGeq: (id<ORVarArray>) ia coef: (id<ORFloatArray>) ca cst: (ORFloat) c;
-(id<ORVarArray>) vars;
-(id<ORFloatArray>) coefs;
-(ORFloat) cst;
@end

@interface ORAlldifferentI : ORConstraintI<ORAlldifferent>
-(ORAlldifferentI*) initORAlldifferentI: (id<ORIntVarArray>) x annotation:(ORAnnotation)n;
-(id<ORIntVarArray>) array;
-(ORAnnotation) annotation;
@end

@interface ORRegularI : ORConstraintI<ORRegular>
-(id)init:(id<ORIntVarArray>)x  for:(id<ORAutomaton>)a;
-(id<ORIntVarArray>) array;
-(id<ORAutomaton>)automaton;
@end

@interface ORCardinalityI : ORConstraintI<ORCardinality>
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up annotation:(ORAnnotation)c;
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

@interface ORSoftAlgebraicConstraintI : ORAlgebraicConstraintI<ORSoftConstraint>
-(ORSoftAlgebraicConstraintI*) initORSoftAlgebraicConstraintI: (id<ORRelation>) expr slack: (id<ORVar>)slack annotation: (ORAnnotation)ann;
-(id<ORVar>) slack;
@end

@interface ORFloatWeightedVarI : ORConstraintI<ORWeightedVar>
-(ORFloatWeightedVarI*) initFloatWeightedVar: (id<ORVar>)x;
-(id<ORVar>) z;
-(id<ORVar>)x;
-(id<ORParameter>)weight;
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


@interface ORObjectiveValueIntI : ORObject<ORObjectiveValueInt> {
   ORInt _value;
   ORInt _direction;
   ORInt _pBound;
}
-(id) initObjectiveValueIntI: (ORInt) pb minimize: (ORBool) b ;
-(ORInt)value;
-(ORInt)primal;
-(ORFloat)key;
-(NSString*)description;
@end

@interface ORObjectiveValueFloatI : ORObject<ORObjectiveValueFloat> {
   ORFloat _value;
   ORInt _direction;
   ORInt _pBound;
}
-(id) initObjectiveValueFloatI: (ORFloat) pb minimize: (ORBool) b ;
-(ORFloat)value;
-(ORFloat)primal;
-(ORFloat)key;
-(NSString*)description;
@end


@interface ORObjectiveFunctionI : ORObject<ORObjectiveFunction>
-(ORObjectiveFunctionI*) initORObjectiveFunctionI;
-(id<ORObjectiveValue>) value;
@end

@interface ORObjectiveFunctionVarI : ORObjectiveFunctionI<ORObjectiveFunctionVar>
{
   id<ORVar>             _var;
}
-(ORObjectiveFunctionVarI*) initORObjectiveFunctionVarI: (id<ORVar>) x;
-(id<ORVar>) var;
-(id<ORObjectiveValue>) value;
-(void) visit: (ORVisitor*) visitor;
@end

@interface ORObjectiveFunctionLinearI : ORObjectiveFunctionI<ORObjectiveFunctionLinear>
{
   id<ORVarArray>  _array;
   id<ORFloatArray> _coef;
   ORFloat            _ic;
}
-(ORObjectiveFunctionLinearI*) initORObjectiveFunctionLinearI: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef independent:(ORFloat)c;
-(id<ORVarArray>) array;
-(id<ORFloatArray>) coef;
-(ORFloat)independent;
-(void) visit: (ORVisitor*) visitor;
@end

@interface ORObjectiveFunctionExprI : ORObjectiveFunctionI<ORObjectiveFunctionExpr>
{
   id<ORExpr> _expr;
}
-(ORObjectiveFunctionExprI*) initORObjectiveFunctionExprI: (id<ORExpr>) expr;
-(id<ORExpr>) expr;
-(void) visit: (ORVisitor*) visitor;
@end

@interface ORMinimizeVarI : ORObjectiveFunctionVarI<ORObjectiveFunctionVar>
-(ORMinimizeVarI*) initORMinimizeVarI: (id<ORVar>) x;
@end

@interface ORMaximizeVarI : ORObjectiveFunctionVarI<ORObjectiveFunctionVar>
-(ORMaximizeVarI*) initORMaximizeVarI: (id<ORVar>) x;
@end

@interface ORMinimizeExprI : ORObjectiveFunctionExprI<ORObjectiveFunctionExpr>
-(ORMinimizeExprI*) initORMinimizeExprI: (id<ORExpr>) e;
@end

@interface ORMaximizeExprI : ORObjectiveFunctionExprI<ORObjectiveFunctionExpr>
-(ORMaximizeExprI*) initORMaximizeExprI: (id<ORExpr>) e;
@end

@interface ORMinimizeLinearI : ORObjectiveFunctionLinearI<ORObjectiveFunctionLinear>
-(ORMinimizeLinearI*) initORMinimizeLinearI: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef independent:(ORFloat)c;
@end

@interface ORMaximizeLinearI : ORObjectiveFunctionLinearI<ORObjectiveFunctionLinear>
-(ORMaximizeLinearI*) initORMaximizeLinearI: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef independent:(ORFloat)c;
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
