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
   id<ORIntVar> _duration;
   id<ORIntVar> _end;
}
-(id<ORActivity>) initORActivity: (id<ORTracker>) tracker horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   self = [super init];
   _start = [ORFactory intVar: tracker domain: horizon];
   _duration = [ORFactory intVar: tracker domain: RANGE(tracker,duration,duration)];
   return self;
}
-(id<ORActivity>) initORActivity: (id<ORTracker>) tracker horizon: (id<ORIntRange>) horizon durationVariable: (id<ORIntVar>) duration
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
-(id<ORIntVar>) duration
{
   return _duration;
}
-(id<ORIntVar>) end
{
   return _end;
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


/*******************************************************************************
 Below is the definition of an optional activity object using a tripartite
 representation for "optional" variables
 ******************************************************************************/

@implementation OROptionalActivity
{
    id<ORIntVar> _startLB;
    id<ORIntVar> _startUB;
    id<ORIntVar> _duration;
    id<ORIntVar> _top;
    BOOL         _optional;
    id<ORIntRange> _startRange;
}
-(id<OROptionalActivity>) initORActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
    self      = [super init];
    _startLB  = [ORFactory intVar: model domain: horizon ];
    _startUB  = _startLB;
    _duration = [ORFactory intVar: model domain: duration];
    _top      = [ORFactory intVar: model value : 1       ];
    _optional = FALSE;
    _startRange = horizon;
    return self;
}
-(id<OROptionalActivity>) initOROptionalActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
    self      = [super init];
    // Initialisation of all variables
    _startLB  = [ORFactory intVar : model domain: RANGE(model, horizon.low    , horizon.up + 1) ];
    _startUB  = [ORFactory intVar : model domain: RANGE(model, horizon.low - 1, horizon.up    ) ];
    _duration = [ORFactory intVar : model domain: duration];
    _top      = [ORFactory boolVar: model                 ];
    _optional = TRUE;
    _startRange = horizon;
    // Constraints for the tri-partite optional variable representation
    [model add: [ORFactory reify:model boolean:_top with:_startLB leq :_startUB   ]];
    [model add: [ORFactory reify:model boolean:_top with:_startLB leqi:horizon.up ]];
    [model add: [ORFactory reify:model boolean:_top with:_startUB geqi:horizon.low]];
    return self;
}
-(id<ORIntVar>) startLB
{
    return _startLB;
}
-(id<ORIntVar>) startUB
{
    return _startLB;
}
-(id<ORIntVar>) duration
{
    return _duration;
}
-(id<ORIntVar>) top
{
    return _top;
}
-(BOOL) isOptional
{
    return _optional;
}
-(id<ORIntRange>) startRange
{
    return _startRange;
}
-(void)visit:(ORVisitor*) v
{
    [v visitOptionalActivity: self];
}
//-(id<ORPrecedes>) precedes: (id<OROptionalActivity>) after
//{
//    return [ORFactory precedence: self precedes: after];
//}
@end
