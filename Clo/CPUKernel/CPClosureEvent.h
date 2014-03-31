/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>

@interface CPClosureList : NSObject<CPClosureList> {
@public
   TRId                  _node;
   ORClosure             _trigger;
   CPCoreConstraint*     _cstr;
   ORInt                 _priority;
}
-(id) initCPEventNode: (ORClosure) t
                 cstr: (id<CPConstraint>) c
                   at: (ORInt) prio
                trail: (id<ORTrail>)trail;
-(void)dealloc;
@end
