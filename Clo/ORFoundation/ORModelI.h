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
@end

@interface ORNEqual : ORConstraintI<ORNEqual>
-(ORNEqual*)initORNEqual:(id<ORIntVar>)x neq:(id<ORIntVar>)y;
@end

@interface ORLEqual : ORConstraintI<ORLEqual>
-(ORLEqual*)initORLEqual:(id<ORIntVar>)x leq:(id<ORIntVar>)y plus:(ORInt)c;
@end

@interface OREqual3 : ORConstraintI<OREqual>
-(OREqual3*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z;
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

@interface ORBinPackingI : ORConstraintI<ORBinPacking>
-(ORBinPackingI*) initORBinPackingI: (id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntVarArray>) binSize;
-(id<ORIntVarArray>) item;
-(id<ORIntArray>) itemSize;
-(id<ORIntArray>) binSize;
@end

@interface ORAlgebraicConstraintI : ORConstraintI<ORAlgebraicConstraint>
-(ORAlgebraicConstraintI*) initORAlgebraicConstraintI: (id<ORRelation>) expr;
-(id<ORRelation>) expr;
@end

@interface ORTableConstraintI : ORConstraintI<ORTableConstraint>
-(ORTableConstraintI*) initORTableConstraintI: (id<ORIntVarArray>) x table: (ORTableI*) table;
-(id<ORIntVarArray>) array;
-(id<ORTable>) table;
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
@end

@interface ORMinimizeI : ORObjectiveFunctionI<ORObjectiveFunction>
-(ORMinimizeI*) initORMinimizeI: (id<ORIntVar>) x;
@end

@interface ORMaximizeI : ORObjectiveFunctionI<ORObjectiveFunction>
-(ORMaximizeI*) initORMaximizeI: (id<ORIntVar>) x;
@end


