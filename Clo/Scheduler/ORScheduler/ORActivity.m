/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORScheduler/ORActivity.h>
#import <ORModeling/ORModeling.h>
#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORScheduler/ORVisit.h>

@implementation ORActivity
{
   id<ORIntVar> _start;
   ORInt _duration;
}
-(id<ORActivity>) initORActivity: (id<ORTracker>) tracker horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   self = [super init];
   _start = [ORFactory intVar: tracker domain: horizon];
   _duration = duration;
   return self;
}
-(id<ORIntVar>) start
{
   return _start;
}
-(ORInt) duration
{
   return _duration;
}
-(void)visit:(ORVisitor*) v
{
   [v visitActivity: self];
}
@end
