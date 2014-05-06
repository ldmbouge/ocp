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
   id<CPIntVar> _end;
}
-(id<CPActivity>) initCPActivity: (id<CPIntVar>) start duration: (id<CPIntVar>) duration end: (id<CPIntVar>) end
{
   self = [super init];
   _start = start;
   _duration = duration;
   _end = end;
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
-(id<CPIntVar>) end
{
   return _end;
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


/*******************************************************************************
 Below is the implementation of an optional activity object using a tripartite
 representation for "optional" variables
 ******************************************************************************/

@implementation CPOptionalActivity
{
    id<CPIntVar> _startLB;
    id<CPIntVar> _startUB;
    id<CPIntVar> _duration;
    id<CPIntVar> _top;
    BOOL         _optional;
    ORInt        _initStartMin;
    ORInt        _initStartMax;
}
-(id<CPOptionalActivity>) initCPActivity:(id<CPIntVar>)start duration:(id<CPIntVar>)duration
{
    self = [super init];
    _startLB  = start;
    _startUB  = start;
    _duration = duration;
    _top      = NULL;
    _optional = FALSE;
    _initStartMin = [start min];
    _initStartMax = [start max];
    
    return self;
}
-(id<CPOptionalActivity>) initCPOptionalActivity: (id<CPIntVar>) top startLB: (id<CPIntVar>) startLB startUB: (id<CPIntVar>) startUB startRange: (id<ORIntRange>) startRange duration: (id<CPIntVar>) duration
{
    self = [super init];
    _startLB  = startLB;
    _startUB  = startUB;
    _duration = duration;
    _top      = top;
    _optional = TRUE;
    _initStartMin = [startRange low];
    _initStartMax = [startRange up ];
    
    return self;
}
-(id<CPIntVar>) startLB
{
    return _startLB;
}
-(id<CPIntVar>) startUB
{
    return _startUB;
}
-(id<CPIntVar>) duration
{
    return _duration;
}
-(id<CPIntVar>) top
{
    return _top;
}
-(BOOL) isOptional
{
    return _optional;
}
-(void) updateStartMin:(ORInt)v
{
    if (!_optional) {
        [_startLB updateMin: v];
    }
    else if (_top.max == 1) {
        [_startLB updateMin: min(v, _initStartMax + 1)];
        if (v > _initStartMax) [_top bind:0];
    }
}
-(void) updateStartMax:(ORInt)v
{
    if (!_optional) {
        [_startUB updateMax:v];
    }
    else if (_top.max == 1) {
        [_startUB updateMax: max(v, _initStartMin - 1)];
        if (v < _initStartMin) [_top bind:0];
    }
}
@end
