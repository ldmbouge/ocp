/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORTaskI.h"
#import <ORScheduler/ORVisit.h>

@implementation ORTask {
   id<ORIntRange>  _horizon;
   id<ORIntRange>  _duration;
}
-(id<ORTask>) initORTask: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _duration = duration;
   _horizon = horizon;
   return self;
}
-(id<ORIntRange>)   horizon
{
   return _horizon;
}
-(id<ORIntRange>)   duration
{
   return _duration;
}
-(void)visit:(ORVisitor*) v
{
   [v visitTask: self];
}
@end
