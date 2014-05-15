/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORConstraintI.h"
#import "ORVisit.h"


// ORPrecedes
//
@implementation ORPrecedes {
   id<ORActivity> _before;
   id<ORActivity> _after;
}
-(id<ORPrecedes>) initORPrecedes:(id<ORActivity>) before precedes:(id<ORActivity>) after
{
   self = [super initORConstraintI];
   _before = before;
   _after   = after;
   return self;
}
-(void)visit:(ORVisitor*) v
{
   [v visitPrecedes: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> precedes(%@,%@)>", [self class], self, _before, _after];
   return buf;
}
-(id<ORActivity>) before
{
   return _before;
}
-(id<ORActivity>) after
{
   return _after;
}
// [pvh] to update when generalizing activities
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity: 2] autorelease];
   [ms addObject: _before.start];
   [ms addObject: _after.start];
   return ms;
}
@end

@implementation OROptionalPrecedes {
    id<OROptionalActivity> _before;
    id<OROptionalActivity> _after;
}
-(id<OROptionalPrecedes>) initOROptionalPrecedes:(id<OROptionalActivity>) before precedes:(id<OROptionalActivity>) after
{
    self = [super initORConstraintI];
    _before = before;
    _after   = after;
    return self;
}
-(void)visit:(ORVisitor*) v
{
    [v visitOptionalPrecedes: self];
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"<%@ : %p> -> optionalPrecedes(%@,%@)>", [self class], self, _before, _after];
    return buf;
}
-(id<OROptionalActivity>) before
{
    return _before;
}
-(id<OROptionalActivity>) after
{
    return _after;
}
// [pvh] to update when generalizing activities
-(NSSet*)allVars
{
    ORInt cap = 0;
    cap += (_before.isOptional ? 4 : 2);
    cap += (_after .isOptional ? 4 : 2);
    
    NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity: cap] autorelease];

    [ms addObject: _before.startLB ];
    [ms addObject: _before.duration];
    [ms addObject: _after .startLB ];
    [ms addObject: _after .duration];
    if (_before.isOptional) {
        [ms addObject: _before.startUB];
        [ms addObject: _before.top    ];
    }
    if (_after.isOptional) {
        [ms addObject: _after.startUB];
        [ms addObject: _after.top    ];
    }
    return ms;
}
@end


// Cumulative (resource) constraint
//
@implementation ORCumulative {
    id<ORIntVarArray> _start;
    id<ORIntVarArray> _dur;
    id<ORIntArray>    _usage;
    id<ORIntVar>      _cap;
}
-(id<ORCumulative>) initORCumulative:(id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d usage:(id<ORIntArray>) ru capacity:(id<ORIntVar>)c
{
    self = [super initORConstraintI];
    _start = s;
    _dur   = d;
    _usage = ru;
    _cap   = c;
    return self;
}
-(void)visit:(ORVisitor*) v
{
    [v visitCumulative: self];
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"<%@ : %p> -> cumulative(%@,%@,%@,%@)>", [self class], self, _start, _dur, _usage, _cap];
    return buf;
}
-(id<ORIntVarArray>) start
{
    return _start;
}
-(id<ORIntVarArray>) duration
{
    return _dur;
}
-(id<ORIntArray>) usage
{
    return _usage;
}
-(id<ORIntVar>) capacity
{
    return _cap;
}
-(NSSet*)allVars
{
    NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_start count]] autorelease];
    [_start enumerateWith:^(id obj, int idx) {
        [ms addObject:obj];
    }];
    return ms;
}
@end

@implementation ORSchedulingCumulative {
   id<ORActivityArray> _activities;
   id<ORIntArray>      _usage;
   id<ORIntVar>        _cap;
}
-(id<ORSchedulingCumulative>) initORSchedulingCumulative:(id<ORActivityArray>) act usage:(id<ORIntArray>) ru capacity:(id<ORIntVar>)c
{
   self = [super initORConstraintI];
   _activities = act;
   _usage = ru;
   _cap   = c;
   return self;
}
-(void)visit:(ORVisitor*) v
{
   [v visitSchedulingCumulative: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> cumulative(%@,%@,%@)>", [self class], self, _activities, _usage, _cap];
   return buf;
}
-(id<ORActivityArray>) activities
{
   return _activities;
}
-(id<ORIntArray>) usage
{
   return _usage;
}
-(id<ORIntVar>) capacity
{
   return _cap;
}
-(NSSet*) allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_activities count]] autorelease];
   id<ORIntRange> R = _activities.range;
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt k = low; k <= up; k++){
      [ms addObject: _activities[k].start];
   }
   return ms;
}
@end

@implementation ORSchedulingDisjunctive {
   id<ORActivityArray> _activities;
}
-(id<ORSchedulingDisjunctive>) initORSchedulingDisjunctive:(id<ORActivityArray>) act
{
   self = [super initORConstraintI];
   _activities = act;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(void)visit:(ORVisitor*) v
{
   [v visitSchedulingDisjunctive: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> disjunctive(%@)>", [self class], self, _activities];
   return buf;
}
-(id<ORActivityArray>) activities
{
   return _activities;
}
-(NSSet*) allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_activities count]] autorelease];
   id<ORIntRange> R = _activities.range;
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt k = low; k <= up; k++){
      [ms addObject: _activities[k].start];
   }
   return ms;
}
@end

// Disjunctive (resource) constraint
//
@implementation ORDisjunctive {
    id<OROptionalActivityArray> _act;
    id<ORIntVarArray>           _start;
    id<ORIntVarArray>           _dur;
}
-(id<ORDisjunctive>) initORDisjunctive:(id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d
{
    self = [super initORConstraintI];
    _act   = NULL;
    _start = s;
    _dur   = d;
    return self;
}
-(id<ORDisjunctive>) initORDisjunctive:(id<OROptionalActivityArray>)act
{
    self = [super initORConstraintI];
    _act   = act;
    _start = NULL;
    _dur   = NULL;
    return self;
}
-(void)visit:(ORVisitor*) v
{
    [v visitDisjunctive: self];
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"<%@ : %p> -> disjunctive(%@,%@)>", [self class], self, _start, _dur];
    return buf;
}
-(id<OROptionalActivityArray>) act
{
    return _act;
}
-(id<ORIntVarArray>) start
{
    return _start;
}
-(id<ORIntVarArray>) duration
{
    return _dur;
}
-(NSSet*)allVars
{
    NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:_start.count + _dur.count] autorelease];
    [_start enumerateWith: ^(id obj, int idx) {
        [ms addObject:obj];
    }];
    [_dur enumerateWith: ^(id obj, int idx) {
        [ms addObject:obj];
    }];
    return ms;
}
@end

// Difference logic constraint
//
@implementation ORDifference {
    id<ORTracker>       _tracker;
    ORInt               _cap;
}
-(id<ORDifference>) initORDifference:(id<ORTracker>) model initWithCapacity:(ORInt) numItems
{
    assert(numItems > 0);
    
    self = [super initORConstraintI];
    _tracker = model;
    _cap  = numItems;
    return self;
}
-(void)visit:(ORVisitor*) v
{
//    [v visitDifference: self with: _model];
}
-(id<ORTracker>) tracker
{
    return _tracker;
}
-(ORInt) initCapacity
{
    return _cap;
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"<%@ : %p> -> difference()>", [self class], self];
    return buf;
}
-(NSSet*)allVars
{
    NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity: 1] autorelease];
    return ms;
}
@end

// x <= y + d handled by the difference logic constraint
//
@implementation ORDiffLEqual {
    id<ORIntVar>     _x;
    id<ORIntVar>     _y;
    ORInt            _d;
    id<ORDifference> _diff;
}
-(id<ORDiffLEqual>) initORDiffLEqual:(id<ORDifference>)diff var:(id<ORIntVar>)x to:(id<ORIntVar>)y plus:(ORInt)d;
{
    self = [super initORConstraintI];
    _x    = x;
    _y    = y;
    _d    = d;
    _diff = diff;
    return self;
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"diffLEqual %@ %@",[self class],self];
    return buf;
}
-(void) visit:(ORVisitor*) v
{
    [v visitDiffLEqual: self];
}
-(id<ORIntVar>) x
{
    return _x;
}
-(id<ORIntVar>) y
{
    return _y;
}
-(ORInt) d
{
    return _d;
}
-(id<ORDifference>) diff
{
    return _diff;
}
-(NSSet*) allVars
{
    return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
@end

// b <-> x <= y + d handled by the difference logic constraint
//
@implementation ORDiffReifyLEqual {
    id<ORIntVar>     _b;
    id<ORIntVar>     _x;
    id<ORIntVar>     _y;
    ORInt            _d;
    id<ORDifference> _diff;
}
-(id<ORDiffReifyLEqual>) initORDiffReifyLEqual:(id<ORDifference>)diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus:(ORInt)d;
{
    self = [super initORConstraintI];
    _b    = b;
    _x    = x;
    _y    = y;
    _d    = d;
    _diff = diff;
    return self;
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"diffReifyLEqual %@ %@",[self class],self];
    return buf;
}
-(void) visit:(ORVisitor*) v
{
    [v visitDiffReifyLEqual: self];
}
-(id<ORIntVar>) b
{
    return _b;
}
-(id<ORIntVar>) x
{
    return _x;
}
-(id<ORIntVar>) y
{
    return _y;
}
-(ORInt) d
{
    return _d;
}
-(id<ORDifference>) diff
{
    return _diff;
}
-(NSSet*) allVars
{
    return [[[NSSet alloc] initWithObjects:_b,_x,_y,nil] autorelease];
}
@end

// b -> x <= y + d handled by the difference logic constraint
//
@implementation ORDiffImplyLEqual {
    id<ORIntVar>     _b;
    id<ORIntVar>     _x;
    id<ORIntVar>     _y;
    ORInt            _d;
    id<ORDifference> _diff;
}
-(id<ORDiffImplyLEqual>) initORDiffImplyLEqual:(id<ORDifference>)diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus:(ORInt)d;
{
    self = [super initORConstraintI];
    _b    = b;
    _x    = x;
    _y    = y;
    _d    = d;
    _diff = diff;
    return self;
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"diffImplyLEqual %@ %@",[self class],self];
    return buf;
}
-(void) visit:(ORVisitor*) v
{
    [v visitDiffImplyLEqual: self];
}
-(id<ORIntVar>) b
{
    return _b;
}
-(id<ORIntVar>) x
{
    return _x;
}
-(id<ORIntVar>) y
{
    return _y;
}
-(ORInt) d
{
    return _d;
}
-(id<ORDifference>) diff
{
    return _diff;
}
-(NSSet*) allVars
{
    return [[[NSSet alloc] initWithObjects:_b,_x,_y,nil] autorelease];
}
@end