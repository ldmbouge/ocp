/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORConstraintI.h"
#import "ORVisit.h"
#import "ORSchedFactory.h"

// ORPrecedes
//
@implementation ORTaskPrecedes {
   id<ORTaskVar> _before;
   id<ORTaskVar> _after;
}
-(id<ORTaskPrecedes>) initORTaskPrecedes: (id<ORTaskVar>) before precedes:(id<ORTaskVar>) after
{
   self = [super initORConstraintI];
   _before = before;
   _after   = after;
   return self;
}
-(void)visit: (ORVisitor*) v
{
   [v visitTaskPrecedes: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> TaskPrecedes(%@,%@)>", [self class], self, _before, _after];
   return buf;
}
-(id<ORTaskVar>) before
{
   return _before;
}
-(id<ORTaskVar>) after
{
   return _after;
}
-(NSSet*) allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity: 2] autorelease];
   [ms addObject: _before ];
   [ms addObject: _after ];
   return ms;
}
@end

@implementation ORTaskIsFinishedBy {
   id<ORTaskVar> _task;
   id<ORIntVar>  _date;
}
-(id<ORTaskIsFinishedBy>) initORTaskIsFinishedBy: (id<ORTaskVar>) task isFinishedBy: (id<ORIntVar>)date;
{
   self = [super initORConstraintI];
   _task = task;
   _date   = date;
   return self;
}
-(void)visit: (ORVisitor*) v
{
   [v visitTaskIsFinishedBy: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> TaskIsFinishedBy(%@,%@)>", [self class], self, _task, _date];
   return buf;
}
-(id<ORTaskVar>) task
{
   return _task;
}
-(id<ORIntVar>) date
{
   return _date;
}
-(NSSet*) allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity: 2] autorelease];
   [ms addObject: _task ];
   [ms addObject: _date ];
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


@implementation ORTaskDisjunctive {
   BOOL _closed;
   id<ORTracker> _tracker;
   NSMutableArray* _acc;
   id<ORTaskVarArray> _tasks;
   id<ORIntVarArray> _successors;
}
-(id<ORTaskDisjunctive>) initORTaskDisjunctive: (id<ORTaskVarArray>) tasks
{
   self = [super initORConstraintI];
   _tracker = [tasks tracker];
   _tasks = tasks;
   ORInt low = _tasks.range.low;
   ORInt up = _tasks.range.up;
   _successors = [ORFactory intVarArray: _tracker range: RANGE(_tracker,low-1,up) domain: RANGE(_tracker,low,up+1)];
   _acc = 0;
   _closed = TRUE;
   return self;
}
-(id<ORTaskDisjunctive>) initORTaskDisjunctiveEmpty: (id<ORTracker>) tracker;
{
   self = [super initORConstraintI];
   _tracker = tracker;
   _tasks = 0;
    _acc = [[NSMutableArray alloc] initWithCapacity: 16];
   _closed = FALSE;
   return self;
}
-(void) dealloc
{
   if (_acc)
      [_acc dealloc];
   [super dealloc];
}
-(void) add: (id<ORTaskVar>) task
{
   if (_closed) {
      @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource is already closed"];
   }
   [_acc addObject: task];
}
-(void)visit: (ORVisitor*) v
{
   [v visitTaskDisjunctive: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> disjunctive(%@)>", [self class], self, _tasks];
   return buf;
}
-(void) close
{
   if (!_closed) {
      _closed = true;
      _tasks = [ORFactory taskVarArray: _tracker range: RANGE(_tracker,1,(ORInt) [_acc count]) with: ^id<ORTaskVar>(ORInt i) {
         return _acc[i-1];
      }];
      _successors = [ORFactory intVarArray: _tracker range: RANGE(_tracker,0,(ORInt) [_acc count]) domain: RANGE(_tracker,1,(ORInt) [_acc count]+1)];
   }
}
-(id<ORTaskVarArray>) taskVars
{
    return _tasks;
}
-(id<ORIntVarArray>) successors
{
   return _successors;
}
-(NSSet*) allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:2*[_tasks count]+1] autorelease];
   id<ORIntRange> R = _tasks.range;
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt k = low; k <= up; k++){
      [ms addObject: _tasks[k]];
   }
   for(ORInt k = low-1; k <= up; k++){
      [ms addObject: _successors[k]];
   }
   return ms;
}
@end


@implementation ORTaskSequence {
   BOOL _closed;
   id<ORTracker> _tracker;
   NSMutableArray* _acc;
   id<ORTaskVarArray> _tasks;
   id<ORIntVarArray> _successors;
}
-(id<ORTaskSequence>) initORTaskSequenceEmpty: (id<ORTracker>) tracker;
{
   self = [super initORConstraintI];
   _tracker = tracker;
   _tasks = 0;
   _successors = 0;
   _acc = [[NSMutableArray alloc] initWithCapacity: 16];
   _closed = FALSE;
   return self;
}
-(void) dealloc
{
   if (_acc)
      [_acc dealloc];
   [super dealloc];
}
-(void) add: (id<ORTaskVar>) task
{
   if (_closed) {
      @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource is already closed"];
   }
   [_acc addObject: task];
}
-(void)visit: (ORVisitor*) v
{
   [v visitTaskSequence: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> sequence(%@)>", [self class], self, _tasks];
   return buf;
}
-(void) close
{
   if (!_closed) {
      _closed = true;
      _tasks = [ORFactory taskVarArray: _tracker range: RANGE(_tracker,1,(ORInt) [_acc count]) with: ^id<ORTaskVar>(ORInt i) {
         return _acc[i-1];
      }];
      _successors = [ORFactory intVarArray: _tracker range: RANGE(_tracker,0,(ORInt) [_acc count]) domain: RANGE(_tracker,1,(ORInt) [_acc count]+1)];
   }
}
-(id<ORTaskVarArray>) taskVars
{
   return _tasks;
}
-(id<ORIntVarArray>) successors
{
   return _successors;
}
-(NSSet*) allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:2*[_tasks count]+1] autorelease];
   id<ORIntRange> R = _tasks.range;
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt k = low; k <= up; k++){
      [ms addObject: _tasks[k]];
   }
   low = _successors.low;
   up = _successors.up;
   for(ORInt k = low; k <= up; k++){
      [ms addObject: _successors[k]];
   }
   return ms;
}
@end

