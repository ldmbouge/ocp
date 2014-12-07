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
#import "ORTaskI.h"

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

@implementation ORTaskCumulative {
    BOOL _closed;
    
    id<ORTracker>      _tracker;
    NSMutableArray *   _accT;
    NSMutableArray *   _accU;
    NSMutableSet   *   _accIds;
    id<ORTaskVarArray> _tasks;
    id<ORIntVarArray>  _usages;
    id<ORIntVar>       _capacity;
}
-(id<ORTaskCumulative>) initORTaskCumulative: (id<ORTaskVarArray>) tasks with: (id<ORIntVarArray>) usages and: (id<ORIntVar>) capacity
{
    // Checking whether the size and indices of the arrays tasks and usages are consistent
    if (tasks.count != usages.count || tasks.low != usages.low || tasks.up != usages.up) {
        @throw [[ORExecutionError alloc] initORExecutionError: "ORTaskCumulative: the arrays 'tasks' and 'usages' must have the same size and indices!"];
    }
    
    self = [super initORConstraintI];
    
    _tracker  = [tasks tracker];
    _tasks    = tasks;
    _usages   = usages;
    _capacity = capacity;

    _accT   = 0;
    _accU   = 0;
    _closed = TRUE;
    
    // Check for duplicates
    for (ORInt i = _tasks.low; i <= _tasks.up; i++) {
        if ([_accIds containsObject: _tasks[i]])
            @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource is defined with duplicate tasks"];
        [_accIds addObject: _tasks[i]];
    }
    [_accIds dealloc];
    _accIds = 0;

    return self;
}
-(id<ORTaskCumulative>) initORTaskCumulativeEmpty: (id<ORIntVar>) capacity
{
    self = [super initORConstraintI];
    
    _tracker  = [capacity tracker];
    _tasks    = 0;
    _usages   = 0;
    _capacity = capacity;
    _accT     = [[NSMutableArray alloc] initWithCapacity: 16];
    _accU     = [[NSMutableArray alloc] initWithCapacity: 16];
    _closed   = FALSE;
    
    return self;
}
-(void) dealloc
{
    if (_accT  ) [_accT   dealloc];
    if (_accU  ) [_accU   dealloc];
    if (_accIds) [_accIds dealloc];
    
    [super dealloc];
}
-(void) add: (id<ORTaskVar>) task with:(id<ORIntVar>)usage
{
    // Check whether 'task' is already added
    if (![_accIds containsObject:@([task getId])]) {
        if (_closed)
            @throw [[ORExecutionError alloc] initORExecutionError: "The cumulative resource is already closed"];
        // Add task
        [_accT   addObject: task           ];
        [_accU   addObject: usage          ];
        [_accIds addObject: @([task getId])];
    }
}
-(void) add:(id<ORResourceTask>)task duration:(ORInt)duration
{
    [self add:task duration:duration with:_capacity];
}
-(void) add:(id<ORResourceTask>)task durationRange:(id<ORIntRange>)duration
{
    [self add:task durationRange:duration with:_capacity];
}
-(void) add:(id<ORResourceTask>)task duration:(ORInt)duration with:(id<ORIntVar>)usage
{
    [self add:task durationRange:RANGE(_tracker, duration, duration) with:usage];
}
-(void) add:(id<ORResourceTask>)task durationRange:(id<ORIntRange>)durationRange with:(id<ORIntVar>)usage
{
    // Check whether 'task' is already added
    if (![_accIds containsObject:@([task getId])]) {
        if (_closed)
            @throw [[ORExecutionError alloc] initORExecutionError: "The cumulative resource is already closed"];
        // Add task
        [_accT   addObject: task           ];
        [_accU   addObject: usage          ];
        [_accIds addObject: @([task getId])];
        // Add resource to resource task
        [task addResource:self with:durationRange];
    }
}
-(void) visit: (ORVisitor*) v
{
    [v visitTaskCumulative: self];
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"<%@ : %p> -> cumulative(%@, %@, %@)>", [self class], self, _tasks, _usages, _capacity];
    return buf;
}
-(void) close
{
    if (!_closed) {
        _closed = true;
        _tasks = [ORFactory taskVarArray: _tracker range: RANGE(_tracker,1,(ORInt) [_accT count]) with: ^id<ORTaskVar>(ORInt i) {
            return _accT[i-1];
        }];
        _usages = [ORFactory intVarArray: _tracker range: RANGE(_tracker,1,(ORInt) [_accU count]) with: ^id<ORIntVar>(ORInt i) {
            return _accU[i-1];
        }];
    }
}
-(id<ORTaskVarArray>) taskVars
{
    return _tasks;
}
-(id<ORIntVarArray>) usages
{
    return _usages;
}
-(id<ORIntVar>) capacity
{
    return _capacity;
}
-(NSSet*) allVars
{
    NSMutableSet* ms;
    ms = [[[NSMutableSet alloc] initWithCapacity:2*[_tasks count]+1] autorelease];
    const ORInt low  = _tasks.range.low;
    const ORInt up   = _tasks.range.up;
    for(ORInt k = low; k <= up; k++){
        [ms addObject: _tasks [k]];
        [ms addObject: _usages[k]];
    }
    [ms addObject: _capacity];
    return ms;
}
@end

@implementation ORTaskDisjunctive {
    BOOL _closed;
    
    id<ORTracker>      _tracker;
    NSMutableArray *   _acc;
    NSMutableArray *   _accTypes;
    NSMutableSet   *   _accIds;
    id<ORTaskVarArray> _tasks;
    id<ORIntArray>     _types;
    id<ORIntVarArray>  _successors;
    id<ORIntMatrix>    _transition;
    id<ORIntMatrix>    _typeTransition;
    id<ORTaskVarArray> _transitionTasks;
    
    id<ORIntRange>    _transitionRow;
    id<ORIntRange>    _transitionColumn;
    id<ORIntVarArray> _transitionTimes;
    id<ORIntArray>*   _transitionArray;
}
-(id<ORTaskDisjunctive>) initORTaskDisjunctive: (id<ORTaskVarArray>) tasks
{
    const ORInt low = _tasks.range.low;
    const ORInt up  = _tasks.range.up;

    self = [super initORConstraintI];
    
    _tracker    = [tasks tracker];
    _tasks      = tasks;
    _successors = [ORFactory intVarArray: _tracker range: RANGE(_tracker,low-1,up) domain: RANGE(_tracker,low,up+1)];
    _acc        = 0;
    _accTypes   = 0;
    _accIds     = [[NSMutableSet alloc] initWithCapacity:tasks.count];
    _closed     = TRUE;
    
    // Check for duplicates
    for (ORInt i = low; i <= up; i++) {
        if ([_accIds containsObject: _tasks[i]])
            @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource is defined with duplicate tasks"];
        [_accIds addObject: _tasks[i]];
    }
    [_accIds dealloc];
    _accIds = 0;
    
    // TODO Check whether this resource is added to a machine or resource task
//    for (ORInt i = low; i <= up; i++) {
//        if ([_tasks[i] isMemberOfClass:[ORMachineTask class]])
//            TODO
//        else if ([_tasks[i] isMemberOfClass:[ORResourceTask class]])
//            TODO
//    }
    
    return self;
}
-(id<ORTaskDisjunctive>) initORTaskDisjunctiveEmpty: (id<ORTracker>) tracker;
{
    self = [super initORConstraintI];
    
    _tracker    = tracker;
    _tasks      = 0;
    _acc        = [[NSMutableArray alloc] initWithCapacity: 16];
    _accTypes   = 0;
    _accIds     = [[NSMutableSet   alloc] initWithCapacity: 16];
    _transition = 0;
    _closed     = FALSE;

    return self;
}
-(id<ORTaskDisjunctive>) initORTaskDisjunctiveEmpty: (id<ORTracker>) tracker transition: (id<ORIntMatrix>) transition;
{
    self = [super initORConstraintI];
    
    _tracker    = tracker;
    _tasks      = 0;
    _acc        = [[NSMutableArray alloc] initWithCapacity: 16];
    _accTypes   = [[NSMutableArray alloc] initWithCapacity: 16];
    _accIds     = [[NSMutableSet   alloc] initWithCapacity: 16];
    _transition = transition;
    _closed     = FALSE;
    
    return self;
}

-(void) dealloc
{
    if (_acc     ) [_acc      dealloc];
    if (_accTypes) [_accTypes dealloc];
    if (_accIds  ) [_accIds   dealloc];

    [super dealloc];
}
-(void) add: (id<ORTaskVar>) task
{
    // Check whether 'task' is already added
    if (![_accIds containsObject:@([task getId])]) {
        if (_closed)
            @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource is already closed"];
        // Add task
        [_acc    addObject: task           ];
        [_accIds addObject: @([task getId])];
    }
}
-(void) add: (id<ORTaskVar>) task type: (ORInt) type
{
    if (_transition == NULL)
        @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource was created without transition"];
    // Check whether 'task' is already added
    if (![_accIds containsObject:@([task getId])]) {
        if (_closed)
            @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource is already closed"];
        // Add task
        [_acc      addObject: task           ];
        [_accTypes addObject: @(type)        ];
        [_accIds   addObject: @([task getId])];
    }
}
-(void) add: (id<ORResourceTask>) task duration:(ORInt)duration
{
    [self add:task durationRange:RANGE(_tracker, duration, duration)];
}
-(void) add:(id<ORResourceTask>)task durationRange:(id<ORIntRange>)durationRange
{
    // Check whether 'task' is already added
    if (![_accIds containsObject:@([task getId])]) {
        if (_closed)
            @throw [[ORExecutionError alloc] initORExecutionError: "The disjunctive resource is already closed"];
        // Add task
        [_acc    addObject: task           ];
        [_accIds addObject: @([task getId])];
        // Add resource to resource task
        [task addResource:self with:durationRange];
    }
}
-(void) postTransitionTimes
{
   if (_transition == NULL)
      return;
   id<ORModel> model = (id<ORModel>) _tracker;
   ORInt       nbAct = (ORInt) [_acc count];
    
   _transitionRow    = RANGE(_tracker,0,nbAct);
   _transitionColumn = RANGE(_tracker,1,nbAct+1);
   _typeTransition   = [ORFactory intMatrix: _tracker range: _transitionRow : _transitionColumn];
    
   for(ORInt i = _transitionColumn.low; i <= _transitionColumn.up ; i++) 
      [_typeTransition set: 0 at: 0 : i];
   for(ORInt i = _transitionRow.low; i <= _transitionRow.up ; i++)
      [_typeTransition set: 0 at: i : nbAct + 1];
    
   ORInt maxTransition = -MAXINT;
   for(ORInt i = 1; i <= nbAct ; i++) {
      ORInt typei = [_accTypes[i-1] intValue];
      for(ORInt j = 1; j <= nbAct ; j++) {
         ORInt typej = [_accTypes[j-1] intValue];
         ORInt tt = [_transition at: typei : typej];
         if (tt > maxTransition)
            maxTransition = tt;
         [_typeTransition set: tt at: i : j];
         
      }
   }
   _transitionArray = (id<ORIntArray>*) malloc(sizeof(id<ORIntArray>) * (nbAct + 1));
   for(ORInt i = 0; i <= nbAct ; i++)
      _transitionArray[i] = [ORFactory intArray: _tracker range: _transitionColumn with: ^ORInt(ORInt j) { return [_typeTransition at: i : j];}];
      
//   NSLog(@"transition: %@",_transition);
//   NSLog(@"type transition: %@",_typeTransition);
   _transitionTimes = [ORFactory intVarArray: _tracker range: RANGE(_tracker,0,(ORInt) [_acc count]) bounds: RANGE(_tracker,0,maxTransition)];
   
   for(ORInt i = 0; i <= nbAct ; i++)
      [model add: [ORFactory element: _tracker var: _successors[i] idxCstArray: _transitionArray[i] equal: _transitionTimes[i]]];
   
   ORInt minDuration = MAXINT;
   ORInt maxDuration = -MAXINT;
   ORInt minHorizon = MAXINT;
   ORInt maxHorizon = -MAXINT;
   for(ORInt i = 1; i <= nbAct; i++) {
      ORInt m = _tasks[i].duration.low;
      ORInt M = _tasks[i].duration.up;
      if (m < minDuration)
         minDuration = m;
      if (M > maxDuration)
         maxDuration = M;
      m = _tasks[i].horizon.low;
      M = _tasks[i].horizon.up;
      if (m < minHorizon)
         minHorizon = m;
      if (M > maxHorizon)
         maxHorizon = M;
   }

   // Create the transition tasks
   id<ORIntRange> RT = RANGE(_tracker,minDuration,maxDuration + maxTransition);
   id<ORIntRange> HT = RANGE(_tracker,minHorizon,2*maxHorizon);
   _transitionTasks = [ORFactory taskVarArray:_tracker range:_tasks.range horizon:HT range: RT];
   id<ORIntVarArray> dt = [ORFactory intVarArray:_tracker range:_tasks.range with:^id<ORIntVar>(ORInt k) {
        return [_tasks[k] getDurationVar];
    }];
   id<ORIntVarArray> dtt = [ORFactory intVarArray:_tracker range:_tasks.range with:^id<ORIntVar>(ORInt k) {
        return [_tasks[k] getDurationVar];
    }];
   for(ORInt i = 1; i <= nbAct; i++) {
      [model add: [[dt[i] plus: _transitionTimes[i]] eq: dtt[i]]];
      [model add: [ORFactory constraint: _tasks[i] extended: _transitionTasks[i] time: _transitionTimes[i]]];
   }
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
      [self postTransitionTimes];
   }
}
-(id<ORTaskVarArray>) taskVars
{
    return _tasks;
}
-(id<ORTaskVarArray>) transitionTaskVars
{
   return _transitionTasks;
}
-(ORBool) hasTransition
{
   return _transition != 0;
}
-(id<ORIntVarArray>) successors
{
   return _successors;
}
-(id<ORIntVarArray>) transitionTimes
{
   return _transitionTimes;
}
-(id<ORIntMatrix>) extendedTransitionMatrix
{
   return _typeTransition;
}
-(NSSet*) allVars
{
   NSMutableSet* ms;
   if (_transition) {
      ms = [[[NSMutableSet alloc] initWithCapacity:4*[_tasks count]+1] autorelease];
   }
   else {
      ms = [[[NSMutableSet alloc] initWithCapacity:2*[_tasks count]+1] autorelease];
   }
   id<ORIntRange> R = _tasks.range;
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt k = low; k <= up; k++){
      [ms addObject: _tasks[k]];
   }
   for(ORInt k = low-1; k <= up; k++){
      [ms addObject: _successors[k]];
   }
   if (_transition) {
      for(ORInt k = low; k <= up; k++){
         [ms addObject: _transitionTasks[k]];
      }
      for(ORInt k = low-1; k <= up; k++){
         [ms addObject: _transitionTimes[k]];
      }
   }
   return ms;
}
@end


@implementation ORTaskAddTransitionTime {
   id<ORTaskVar> _normal;
   id<ORTaskVar> _extended;
   id<ORIntVar> _time;
}
-(id<ORTaskAddTransitionTime>) initORTaskAddTransitionTime: (id<ORTaskVar>) normal extended: (id<ORTaskVar>) extended time: (id<ORIntVar>) time
{
   self = [super initORConstraintI];
   _normal = normal;
   _extended = extended;
   _time = time;
   return self;
}
-(void)visit: (ORVisitor*) v
{
   [v visitTaskAddTransitionTime: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> TaskAddTransitionTime(%@,%@,%@)>", [self class], self, _normal,_extended,_time];
   return buf;
}
-(id<ORTaskVar>) normal
{
   return _normal;
}
-(id<ORTaskVar>) extended
{
   return _extended;
}
-(id<ORIntVar>) time
{
   return _time;
}
-(NSSet*) allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity: 2] autorelease];
   [ms addObject: _normal ];
   [ms addObject: _extended ];
   [ms addObject: _time ];
   return ms;
}
@end



@implementation ORSumTransitionTimes {
   id<ORTaskDisjunctive> _disjunctive;
   id<ORIntVar> _ub;
}
-(id<ORSumTransitionTimes>) initORSumTransitionTimes: (id<ORTaskDisjunctive>) disjunctive leq: (id<ORIntVar>) ub
{
   self = [super initORConstraintI];
   _disjunctive = disjunctive;
   _ub = ub;
   return self;
}
-(void)visit: (ORVisitor*) v
{
   [v visitSumTransitionTimes: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> SumransitionTime(%@,%@)>", [self class], self, _disjunctive,_ub];
   return buf;
}
-(id<ORTaskDisjunctive>) disjunctive
{
   return _disjunctive;
}
-(id<ORIntVar>) ub
{
   return _ub;
}
-(NSSet*) allVars
{
   NSMutableSet* ms = (NSMutableSet*)[_disjunctive allVars];
   [ms addObject: _ub];
   return ms;
}
@end
