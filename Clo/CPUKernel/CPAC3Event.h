/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>

@class CPCoreConstraint;

@interface CPEventNode : NSObject<CPEventNode> {
@public
   TRId                  _node;
   id                 _trigger;  // type is {ConstraintCallback}
   CPCoreConstraint*     _cstr;
   ORInt             _priority;
}
-(id) initCPEventNode: (id) t
                 cstr: (CPCoreConstraint*) c
                   at: (ORInt) prio
                trail: (id<ORTrail>)trail;
-(void)dealloc;
@end
