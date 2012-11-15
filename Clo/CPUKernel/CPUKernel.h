/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngine.h>

typedef enum {
   CPChecked,
   CPTocheck,
   CPOff
} CPTodo;

@protocol CPConstraint <ORConstraint,ORCommand>
-(ORUInt)getId;
@end

@protocol CPEvent<NSObject>
-(ORInt)execute;
@end

@protocol VarEventNode <NSObject>
@end

@class CPCoreConstraint;

@interface VarEventNode : NSObject<VarEventNode> {
   @public
   VarEventNode*         _node;
   id                 _trigger;  // type is {ConstraintCallback}
   CPCoreConstraint*     _cstr;
   ORInt             _priority;
}
-(VarEventNode*) initVarEventNode: (VarEventNode*) next trigger: (id) t cstr: (CPCoreConstraint*) c at: (ORInt) prio;
-(void)dealloc;
@end

void collectList(VarEventNode* list,NSMutableSet* rv);
void freeList(VarEventNode* list);

@interface CPFactory : NSObject
+(id<CPEngine>) engine: (id<ORTrail>) trail;
@end;