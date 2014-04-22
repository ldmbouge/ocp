/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORScheduler/ORActivity.h>
#import <ORModeling/ORModeling.h>
#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORScheduler/ORVisit.h>
#import <ORScheduler/ORSchedFactory.h>

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
-(id<ORPrecedes>) precedes: (id<ORActivity>) after
{
   return [ORFactory precedence: self precedes: after];
}
@end

@implementation ORDisjunctiveResource {
   BOOL _closed;
   id<ORTracker> _tracker;
   NSMutableArray* _acc;
   id<ORActivityArray> _activities;
}
-(id<ORDisjunctiveResource>) initORDisjunctiveResource: (id<ORTracker>) tracker
{
   self = [super init];
   _closed = false;
   _tracker = tracker;
   _acc = [[NSMutableArray alloc] initWithCapacity: 16];
   return self;
}
-(void) dealloc
{
   if (_closed) {
      [_acc release];
   }
   [super dealloc];
}
-(void) isRequiredBy: (id<ORActivity>) act
{
   if (_closed) {
      @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource is already closed"];
   }
   [_acc addObject: act];
}
-(void)visit:(ORVisitor*) v
{
   [v visitDisjunctiveResource: self];
}

-(id<ORActivityArray>) activities
{
   if (!_closed) {
      _closed = true;
      _activities = [ORFactory activityArray: _tracker range: RANGE(_tracker,0,(ORInt) [_acc count]-1) with: ^id<ORActivity>(ORInt i) {
         return _acc[i];
      }];
   }
   return _activities;
}
@end

