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


@interface ORIntVarI : NSObject<ORIntVar>
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker domain: (id<ORIntRange>) domain;
-(id<ORIntVar>) dereference;
-(id<ORIntVar>) impl;
-(void) setImpl: (id<ORIntVar>) _impl;
@end

@interface ORConstraintI : NSObject<ORConstraint>
-(ORConstraintI*) initORConstraintI;
-(void) setId: (ORUInt) name;
-(id<ORConstraint>) impl;
-(void) setImpl: (id<ORConstraint>) _impl;
@end

@interface ORAlldifferentI : ORConstraintI<ORAlldifferent>
-(ORAlldifferentI*) initORAlldifferentI: (id<ORIntVarArray>) x;
-(id<ORIntVarArray>) array;
@end

@interface ORObjectiveFunctionI : NSObject
-(id<ORIntVar>) var;
@end

@interface ORMinimizeI : ORObjectiveFunctionI
-(ORMinimizeI*) initORMinimizeI: (id<ORModel>) model obj: (id<ORIntVar>) x;
@end

@interface ORMaximizeI : ORObjectiveFunctionI
-(ORMaximizeI*) initORMaximizeI: (id<ORModel>) model obj: (id<ORIntVar>) x;
@end

@interface ORModelI : NSObject<ORModel>

-(ORModelI*)              initORModelI;
-(void)                   dealloc;
-(NSString*)              description;
-(void)                   setId: (ORUInt) name;
@end
