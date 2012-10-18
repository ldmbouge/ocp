/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORArray.h"
#import "ORSet.h"
#import "ORModel.h"
#import "ORVar.h"
#import "ORExprI.h"
#import "ORVisit.h"

@protocol ORObjective;

@interface ORConstraintI : NSObject<ORConstraint>
-(ORConstraintI*) initORConstraintI;
-(void) setId: (ORUInt) name;
-(id<ORConstraint>) impl;
-(id<ORConstraint>) dereference;
-(void) setImpl: (id<ORConstraint>) _impl;
-(NSString*) description;
@end

@interface ORFail : ORConstraintI<ORFail>
-(ORFail*)init;
@end

@interface OREqualc : ORConstraintI<OREqualc>
-(OREqualc*)initOREqualc:(id<ORIntVar>)x eqi:(ORInt)c;
@end

@interface ORNEqualc : ORConstraintI<ORNEqualc>
-(ORNEqualc*)initORNEqualc:(id<ORIntVar>)x neqi:(ORInt)c;
@end

@interface ORLEqualc : ORConstraintI<ORLEqualc>
-(ORLEqualc*)initORLEqualc:(id<ORIntVar>)x leqi:(ORInt)c;
@end

@interface OREqual : ORConstraintI<OREqual>
-(OREqual*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(ORInt)c;
-(OREqual*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(ORInt)c note:(ORAnnotation)n;
@end

@interface ORNEqual : ORConstraintI<ORNEqual>
-(ORNEqual*)initORNEqual:(id<ORIntVar>)x neq:(id<ORIntVar>)y;
-(ORNEqual*)initORNEqual:(id<ORIntVar>)x neq:(id<ORIntVar>)y plus:(ORInt)c;
@end

@interface ORLEqual : ORConstraintI<ORLEqual>
-(ORLEqual*)initORLEqual:(id<ORIntVar>)x leq:(id<ORIntVar>)y plus:(ORInt)c;
@end

@interface OREqual3 : ORConstraintI<OREqual3>
-(OREqual3*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z;
-(OREqual3*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z note:(ORAnnotation)n;
@end

@interface ORMult : ORConstraintI<ORMult>
-(ORMult*)initORMult:(id<ORIntVar>)x eq:(id<ORIntVar>)y times:(id<ORIntVar>)z;
@end

@interface ORAbs : ORConstraintI<ORAbs>
-(ORAbs*)initORAbs:(id<ORIntVar>)x eqAbs:(id<ORIntVar>)y;
@end

@interface OROr : ORConstraintI<OROr>
-(OROr*)initOROr:(id<ORIntVar>)x eq:(id<ORIntVar>)y or:(id<ORIntVar>)z;
@end

@interface ORAnd : ORConstraintI<ORAnd>
-(ORAnd*)initORAnd:(id<ORIntVar>)x eq:(id<ORIntVar>)y and:(id<ORIntVar>)z;
@end

@interface ORImply : ORConstraintI<ORImply>
-(ORAnd*)initORImply:(id<ORIntVar>)x eq:(id<ORIntVar>)y imply:(id<ORIntVar>)z;
@end

@interface ORElementCst : ORConstraintI<ORElementCst>
-(ORElementCst*)initORElement:(id<ORIntVar>)idx array:(id<ORIntArray>)y equal:(id<ORIntVar>)z; // y[idx] == z
@end

@interface ORElementVar : ORConstraintI<ORElementVar>
-(ORElementVar*)initORElement:(id<ORIntVar>)idx array:(id<ORIntVarArray>)y equal:(id<ORIntVar>)z; // y[idx] == z
@end

@interface ORReifyEqualc : ORConstraintI<ORReifyEqualc>
-(ORReifyEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eqi:(ORInt)c;
@end

@interface ORReifyNEqualc : ORConstraintI<ORReifyNEqualc>
-(ORReifyNEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neqi:(ORInt)c;
@end

@interface ORReifyEqual : ORConstraintI<ORReifyEqual>
-(ORReifyEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eq:(id<ORIntVar>)y note:(ORAnnotation)n;
@end

@interface ORReifyNEqual : ORConstraintI<ORReifyNEqual>
-(ORReifyNEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neq:(id<ORIntVar>)y note:(ORAnnotation)n;
@end

@interface ORReifyLEqualc : ORConstraintI<ORReifyLEqualc>
-(ORReifyLEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leqi:(ORInt)y;
@end

@interface ORReifyLEqual : ORConstraintI<ORReifyLEqual>
-(ORReifyLEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leq:(id<ORIntVar>)y note:(ORAnnotation)n;
@end

@interface ORReifyGEqualc : ORConstraintI<ORReifyGEqualc>
-(ORReifyGEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geqi:(ORInt)y;
@end

@interface ORReifyGEqual : ORConstraintI<ORReifyGEqual>
-(ORReifyGEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geq:(id<ORIntVar>)y note:(ORAnnotation)n;
@end

@interface ORSumBoolEqc : ORConstraintI<ORSumBoolEqc>
-(ORSumBoolEqc*)initSumBool:(id<ORIntVarArray>)ba eqi:(ORInt)c;
@end

@interface ORSumBoolLEqc : ORConstraintI<ORSumBoolLEqc>
-(ORSumBoolLEqc*)initSumBool:(id<ORIntVarArray>)ba leqi:(ORInt)c;
@end

@interface ORSumBoolGEqc : ORConstraintI<ORSumBoolGEqc>
-(ORSumBoolLEqc*)initSumBool:(id<ORIntVarArray>)ba geqi:(ORInt)c;
@end

@interface ORSumEqc : ORConstraintI<ORSumEqc>
-(ORSumEqc*)initSum:(id<ORIntVarArray>)ia eqi:(ORInt)c;
@end

@interface ORSumLEqc : ORConstraintI<ORSumLEqc>
-(ORSumLEqc*)initSum:(id<ORIntVarArray>)ia leqi:(ORInt)c;
@end

@interface ORSumGEqc : ORConstraintI<ORSumGEqc>
-(ORSumGEqc*)initSum:(id<ORIntVarArray>)ia geqi:(ORInt)c;
@end

@interface ORAlldifferentI : ORConstraintI<ORAlldifferent>
-(ORAlldifferentI*) initORAlldifferentI: (id<ORIntVarArray>) x;
-(id<ORIntVarArray>) array;
@end

@interface ORCardinalityI : ORConstraintI<ORCardinality>
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up;
-(id<ORIntVarArray>) array;
-(id<ORIntArray>) low;
-(id<ORIntArray>) up;
@end;

@interface ORAlgebraicConstraintI : ORConstraintI<ORAlgebraicConstraint>
-(ORAlgebraicConstraintI*) initORAlgebraicConstraintI: (id<ORRelation>) expr;
-(id<ORRelation>) expr;
@end

@interface ORTableConstraintI : ORConstraintI<ORTableConstraint>
-(ORTableConstraintI*) initORTableConstraintI: (id<ORIntVarArray>) x table: (ORTableI*) table;
-(id<ORIntVarArray>) array;
-(id<ORTable>) table;
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
@end

@interface ORPackingI : ORConstraintI<ORPacking>
-(ORPackingI*)initORPackingI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(id<ORIntVarArray>) binSize;
@end

@interface ORKnapsackI : ORConstraintI<ORKnapsack>
-(ORKnapsackI*)initORKnapsackI:(id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c;
@end

@interface ORObjectiveFunctionI : NSObject<ORObjectiveFunction> {
   id<ORIntVar>             _var;
   id<ORObjectiveFunction>  _impl;
}
-(ORObjectiveFunctionI*) initORObjectiveFunctionI: (id<ORIntVar>) x;
-(id<ORIntVar>) var;
-(BOOL) concretized;
-(void) setImpl:(id<ORObjectiveFunction>)impl;
-(id<ORObjectiveFunction>)impl;
-(id<ORObjectiveFunction>) dereference;
-(void) visit: (id<ORVisitor>) visitor;
@end

@interface ORMinimizeI : ORObjectiveFunctionI<ORObjectiveFunction>
-(ORMinimizeI*) initORMinimizeI: (id<ORIntVar>) x;
@end

@interface ORMaximizeI : ORObjectiveFunctionI<ORObjectiveFunction>
-(ORMaximizeI*) initORMaximizeI: (id<ORIntVar>) x;
@end


