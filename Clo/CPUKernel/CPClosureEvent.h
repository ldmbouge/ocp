/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPClosureList.h>
#import <ORFoundation/ORTrail.h>

@class CPCoreConstraint;

@interface CPClosureList : NSObject<CPClosureList> {
@public
   TRId                  _node;
   TRId                  _prev;
   TRId*                 _list;
   id<ORTrail>           _trail;
   ORClosure             _trigger;
   CPCoreConstraint*     _cstr;
   ORInt                 _priority;
}
-(id) initCPEventNode: (ORClosure) t
                 cstr: (id<CPConstraint>) c
                   at: (ORInt) prio
                trail: (id<ORTrail>)trail;
-(void)dealloc;
-(void)retract;
@end
