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
    id<ORIntVar>   _startLB;
    id<ORIntVar>   _startUB;
    id<ORIntVar>   _duration;
    id<ORIntVar>   _top;
    id<ORIntVar>   _altIdx;
    BOOL           _optional;
    id<ORIntRange> _startRange;
    id<OROptionalActivityArray> _composition;
    ORInt          _type;
}
-(id<OROptionalActivity>) initORActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
    self = [super init];
    
    _startRange  = horizon;
    _startLB     = [ORFactory intVar: model domain: horizon ];
    _startUB     = _startLB;
    _duration    = [ORFactory intVar: model domain: duration];
    _top         = NULL;
    _optional    = FALSE;
    _altIdx      = NULL;
    _composition = NULL;
    _type        = ORACTCOMP;
    
    return self;
}
-(id<OROptionalActivity>) initOROptionalActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
    self = [super init];
    
    // Initialisation of all variables
    _startRange  = horizon;
    _startLB     = [ORFactory intVar : model domain: RANGE(model, horizon.low    , horizon.up + 1) ];
    _startUB     = [ORFactory intVar : model domain: RANGE(model, horizon.low - 1, horizon.up    ) ];
    _duration    = [ORFactory intVar : model domain: duration];
    _top         = [ORFactory boolVar: model                 ];
    _optional    = TRUE;
    _altIdx      = NULL;
    _composition = NULL;
    _type        = ORACTOPT;
    
    // Constraints for the tri-partite optional variable representation
    [model add: [ORFactory reify:model boolean:_top with:_startLB leq :_startUB   ]];
    [model add: [ORFactory reify:model boolean:_top with:_startLB leqi:horizon.up ]];
    [model add: [ORFactory reify:model boolean:_top with:_startUB geqi:horizon.low]];
    
    return self;
}
-(id<OROptionalActivity>) initORAlternativeActivity:(id<ORModel>)model activities:(id<OROptionalActivityArray>)act
{
//    assert(act.range.low <= act.range.up);
    self = [super init];

    // Determine the start and duration ranges
    ORInt start_min = MAXINT;
    ORInt start_max = MININT;
    ORInt dur_min   = MAXINT;
    ORInt dur_max   = MININT;
    for (ORInt i = act.range.low; i <= act.range.up; i++) {
        start_min = min(start_min, [act[i].startRange low]);
        start_max = max(start_max, [act[i].startRange up ]);
        dur_min   = min(dur_min,   [act[i].duration   low]);
        dur_max   = max(dur_max,   [act[i].duration   up ]);
    }
    
    // Setting and creating variables
    _startRange  = RANGE(model, start_min, start_max);
    _startLB     = [ORFactory intVar: model domain: _startRange];
    _startUB     = _startLB;
    _duration    = [ORFactory intVar: model domain: RANGE(model, dur_min, dur_max)];
    _top         = NULL;
    _altIdx      = [ORFactory intVar:model domain:act.range];
    _composition = act;
    _type        = ORALTCOMP;

    // Constraints for representing the alternative
    // XXX Should the constraints be adding here or to the "concrete" model?
    id<ORIntVar> one   = [ORFactory intVar:model domain:RANGE(model, 1, 1)];
    id<ORIntVarArray> tops      = [ORFactory intVarArray:model range:act.range with:^id<ORIntVar>(ORInt k) {return act[k].top;     }];
    id<ORIntVarArray> starts    = [ORFactory intVarArray:model range:act.range with:^id<ORIntVar>(ORInt k) {return act[k].startLB; }];
    id<ORIntVarArray> durations = [ORFactory intVarArray:model range:act.range with:^id<ORIntVar>(ORInt k) {return act[k].duration;}];
    [model add: [ORFactory sumbool:model array:tops eqi:1]];
    [model add: [ORFactory element:model var:_altIdx idxVarArray:tops      equal:one      ]];
    [model add: [ORFactory element:model var:_altIdx idxVarArray:starts    equal:_startLB ]];
    [model add: [ORFactory element:model var:_altIdx idxVarArray:durations equal:_duration]];
    
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
-(id<OROptionalActivityArray>) composition
{
    return _composition;
}
-(ORInt) type
{
    return _type;
}
-(void)visit:(ORVisitor*) v
{
    [v visitOptionalActivity: self];
}
-(id<OROptionalPrecedes>) precedes: (id<OROptionalActivity>) after
{
    return [ORFactory optionalPrecedence: self precedes: after];
}
@end
