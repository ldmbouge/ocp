/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPScheduler/CPActivity.h>
#import <objcp/CPVar.h>

@implementation CPActivity
{
   id<CPIntVar> _start;
   id<CPIntVar> _duration;
}
-(id<CPActivity>) initCPActivity: (id<CPIntVar>) start duration: (id<CPIntVar>) duration
{
   self = [super init];
   _start = start;
   _duration = duration;
   return self;
}
-(id<CPIntVar>) start
{
   return _start;
}
-(id<CPIntVar>) duration
{
   return _duration;
}
@end

@implementation CPDisjunctiveResource {
   id<ORTracker> _tracker;
   id<CPActivityArray> _activities;
}
-(id<CPDisjunctiveResource>) initCPDisjunctiveResource: (id<ORTracker>) tracker activities: (id<CPActivityArray>) activities
{
   self = [super init];
   _tracker = tracker;
   _activities = activities;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(id<CPActivityArray>) activities
{
   return _activities;
}
@end