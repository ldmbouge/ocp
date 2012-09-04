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
#import "ORExprI.h"

@protocol ORObjective;

@interface ORIntVarI : ORExprI<ORIntVar>
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker domain: (id<ORIntRange>) domain;
// [ldm] All the methods below were missing??????
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds)bounds;
-(BOOL) member: (ORInt) v;
-(BOOL) isBool;
-(id<ORIntVar>) dereference;
-(id<ORIntVar>) impl;
-(void) setImpl: (id<ORIntVar>) _impl;
-(id<ORSolver>) solver;
-(NSSet*)constraints;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(void) visit: (id<ORExprVisitor>)v;
@end


@interface ORIntVarAffineI : ORIntVarI
-(ORIntVarAffineI*)initORIntVarAffineI:(id<ORTracker>)tracker var:(id<ORIntVar>)x scale:(ORInt)a shift:(ORInt)b;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
@end

@interface ORFloatVarI : ORExprI<ORFloatVar>
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) tracker low: (ORFloat) low up: (ORFloat) up;
-(ORFloat) value;
-(ORFloat) min;
-(ORFloat) max;
-(id<ORIntVar>) dereference;
-(id<ORIntVar>) impl;
-(void) setImpl: (id<ORIntVar>) _impl;
-(id<ORSolver>) solver;
-(NSSet*) constraints;
-(void) visit: (id<ORExprVisitor>)v;
@end


@interface ORConstraintI : NSObject<ORConstraint>
-(ORConstraintI*) initORConstraintI;
-(void) setId: (ORUInt) name;
-(id<ORConstraint>) impl;
-(id<ORConstraint>) dereference;
-(void) setImpl: (id<ORConstraint>) _impl;
-(NSString*) description;
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

@interface ORObjectiveFunctionI : NSObject<ORObjectiveFunction>
-(ORObjectiveFunctionI*) initORObjectiveFunctionI: (id<ORModel>) model obj: (id<ORIntVar>) x;
-(id<ORIntVar>) var;
-(BOOL) concretized;
-(BOOL) isMinimize;
-(void) setImpl:(id<ORObjective>)impl;
@end

@interface ORMinimizeI : ORObjectiveFunctionI<ORObjectiveFunction>
-(ORMinimizeI*) initORMinimizeI: (id<ORModel>) model obj: (id<ORIntVar>) x;
-(BOOL) isMinimize;
@end

@interface ORMaximizeI : ORObjectiveFunctionI<ORObjectiveFunction>
-(ORMaximizeI*) initORMaximizeI: (id<ORModel>) model obj: (id<ORIntVar>) x;
-(BOOL) isMinimize;
@end

@interface ORModelI : NSObject<ORModel>
-(ORModelI*)              initORModelI;
-(void)                   dealloc;
-(NSString*)              description;
-(void)                   setId: (ORUInt) name;
-(void)                   applyOnVar:(void(^)(id<ORObject>))doVar onObjects:(void(^)(id<ORObject>))doObjs onConstraints:(void(^)(id<ORObject>))doCons;
-(id<ORObjectiveFunction>)objective;
@end
