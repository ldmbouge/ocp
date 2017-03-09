/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>

// [PVH] To display the closure + the non-created closure to propagate constraints

@protocol CPClosureList <NSObject>
-(ORClosure) trigger;
-(id<CPClosureList>) next;           // fetches the tail of the list
-(void) scanWithBlock:(void(^)(id))block;
-(void) scanCstrWithBlock:(void(^)(id))block;
-(void)retract;
@end
