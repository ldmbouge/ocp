/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORTaskI.h"
#import "ORConstraintI.h"
#import <ORScheduler/ORSchedFactory.h>
#import <ORScheduler/ORVisit.h>


@implementation ORTaskVar {
   @protected id<ORModel> _model;
   id<ORIntRange>  _horizon;
   id<ORIntRange>  _duration;
   ORBool _isOptional;
    id<ORIntVar>   _durationVar;
    id<ORIntVar>   _presenceVar;
}
-(id<ORTaskVar>) initORTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _model = model;
   _duration = duration;
   _horizon = horizon;
   _isOptional = FALSE;
    _durationVar = NULL;
    _presenceVar = NULL;
   return self;
}
-(id<ORTaskVar>) initOROptionalTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _model = model;
   _duration = duration;
   _horizon = horizon;
   _isOptional = TRUE;
    _durationVar = NULL;
    _presenceVar = NULL;
   return self;
}
-(id<ORTracker>) tracker
{
   return _model;
}
-(id<ORIntRange>)   horizon
{
   return _horizon;
}
-(id<ORIntRange>)   duration
{
   return _duration;
}
-(ORBool) isOptional
{
   return _isOptional;
}
-(void)visit:(ORVisitor*) v
{
   [v visitTask: self];
}
-(id<ORTaskPrecedes>) precedes: (id<ORTaskVar>) after
{
   return [ORFactory constraint: self precedes: after];
}
-(id<ORTaskIsFinishedBy>) isFinishedBy: (id<ORIntVar>) date
{
   return [ORFactory constraint: self isFinishedBy: date];
}
-(id<ORIntVar>) getDurationVar
{
    if (_durationVar == NULL)
        _durationVar = [ORFactory intVar:_model bounds:_duration];
    return _durationVar;
}
-(id<ORIntVar>) getPresenceVar
{
    if (_presenceVar == NULL) {
        if (_isOptional)
            _presenceVar = [ORFactory boolVar:_model];
        else
            _presenceVar = [ORFactory intVar:_model value:1];
    }
    return _presenceVar;
}
-(id<ORIntVar>) durationVar
{
    return _durationVar;
}
-(id<ORIntVar>) presenceVar
{
    return _presenceVar;
}
@end

@implementation ORAlternativeTask {
    id<ORTaskVarArray> _alt;
}
-(id<ORAlternativeTask>) initORAlternativeTask:(id<ORModel>)model alternatives:(id<ORTaskVarArray>)alt {
    
    ORInt minHor = MAXINT;
    ORInt maxHor = MININT;
    ORInt minDur = MAXINT;
    ORInt maxDur = MININT;
    for (ORInt k = alt.low; k <= alt.up; k++) {
        minHor = min(minHor, alt[k].horizon.low );
        maxHor = max(maxHor, alt[k].horizon.up  );
        minDur = min(minDur, alt[k].duration.low);
        maxDur = max(maxDur, alt[k].duration.up );
    }
    
    self = [super initORTaskVar: model horizon:RANGE(model, minHor, maxHor) duration:RANGE(model, minDur, maxDur)];
    
    _alt = alt;
    
    return self;
}
-(id<ORAlternativeTask>) initOROptionalAlternativeTask:(id<ORModel>)model alternatives:(id<ORTaskVarArray>)alt {
    
    ORInt minHor = MAXINT;
    ORInt maxHor = MININT;
    ORInt minDur = MAXINT;
    ORInt maxDur = MININT;
    for (ORInt k = alt.low; k <= alt.up; k++) {
        minHor = min(minHor, alt[k].horizon.low );
        maxHor = max(maxHor, alt[k].horizon.up  );
        minDur = min(minDur, alt[k].duration.low);
        maxDur = max(maxDur, alt[k].duration.up );
    }
    
    self = [super initOROptionalTaskVar: model horizon:RANGE(model, minHor, maxHor) duration:RANGE(model, minDur, maxDur)];
    
    _alt = alt;
    
    return self;
}
-(id<ORTaskVarArray>) alternatives
{
    return _alt;
}
-(void)visit:(ORVisitor*) v
{
    [v visitAlternativeTask: self];
}
@end

@implementation ORSpanTask {
    id<ORTaskVarArray> _compound;
}
-(id<ORSpanTask>) initORSpanTask:(id<ORModel>)model horizon:(id<ORIntRange>) horizon compound:(id<ORTaskVarArray>)compound {
    
    self = [super initORTaskVar: model horizon:horizon duration:horizon];
    
    _compound = compound;
    
    return self;
}
-(id<ORSpanTask>) initOROptionalSpanTask:(id<ORModel>)model horizon:(id<ORIntRange>) horizon compound:(id<ORTaskVarArray>)compound {
    
    self = [super initOROptionalTaskVar: model horizon:horizon duration:horizon];
    
    _compound = compound;
    
    return self;
}
-(id<ORTaskVarArray>) compound
{
    return _compound;
}
-(void)visit:(ORVisitor*) v
{
    [v visitSpanTask: self];
}
@end


@implementation ORResourceTask {
    id<ORResourceArray>   _res;
    id<ORIntRangeArray>   _durArray;
    NSMutableDictionary * _dictRes;
    NSMutableDictionary * _dictDur;
    
    // Variables concerning transition times
    id<ORResourceTask>    _transitionSource;
    id<ORResourceTask>    _transitionTask;
    id<ORIntVarArray>     _transitionTime;
    NSMutableDictionary * _transitionDictTime;
    

    
    ORBool _closed;
}
-(id<ORResourceTask>) initORResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntRangeArray>)duration runsOnOneOf:(id<ORResourceArray>)resources
{
    assert(duration.low == resources.low);
    assert(duration.up  == resources.up );
    const ORInt low = duration.low;
    const ORInt up  = duration.up;
    
    // Checking for the right resources
    for (ORInt k = low; k <= up; k++) {
        if (![resources[k] isMemberOfClass: [ORTaskDisjunctive class]] && ![resources[k] isMemberOfClass: [ORTaskCumulative class]])
            @throw [[ORExecutionError alloc] initORExecutionError: "The resource task contains references to non-resource constraints"];
    }
    
    ORInt minDur = MAXINT;
    ORInt maxDur = MININT;
    for (ORInt k = low; k <= up; k++) {
        minDur = min(minDur, [duration at:k].low);
        maxDur = max(maxDur, [duration at:k].up );
    }
    
    self = [super initORTaskVar:model horizon:horizon duration:RANGE(_model, minDur, maxDur)];
    
    _res      = resources;
    _durArray = duration;
    _transitionSource   = NULL;
    _transitionTask     = NULL;
    _transitionTime     = NULL;
    _transitionDictTime = NULL;
    
    _dictRes  = NULL;
    _dictDur  = NULL;
    _closed   = true;
    
    // Adding the resource task to the resources
    for (ORInt k = low; k <= up; k++) {
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*) resources[k] add:self durationRange:[duration at:k]];
        else
            [(ORTaskCumulative *) resources[k] add:self durationRange:[duration at:k]];
    }
    
    return self;
}
-(id<ORResourceTask>) initORResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntRangeArray>)duration usageArray:(id<ORIntVarArray>)usage runsOnOneOf:(id<ORResourceArray>)resources
{
    assert(duration.low == resources.low);
    assert(duration.up  == resources.up );
    assert(duration.low == usage.low);
    assert(duration.up  == usage.up );
    const ORInt low = duration.low;
    const ORInt up  = duration.up;
    
    // Checking for the right resources
    for (ORInt k = low; k <= up; k++) {
        if (![resources[k] isMemberOfClass: [ORTaskDisjunctive class]] && ![resources[k] isMemberOfClass: [ORTaskCumulative class]])
            @throw [[ORExecutionError alloc] initORExecutionError: "The resource task contains references to non-resource constraints"];
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]] && !([[usage at: k] min] == 1 && [[usage at: k] max] == 1))
            @throw [[ORExecutionError alloc] initORExecutionError: "The resource task contains references to non-resource constraints"];
    }
    
    ORInt minDur = MAXINT;
    ORInt maxDur = MININT;
    for (ORInt k = low; k <= up; k++) {
        minDur = min(minDur, [duration at:k].low);
        maxDur = max(maxDur, [duration at:k].up );
    }
    
    self = [super initORTaskVar:model horizon:horizon duration:RANGE(_model, minDur, maxDur)];
    
    _res      = resources;
    _durArray = duration;
    _transitionSource   = NULL;
    _transitionTask     = NULL;
    _transitionTime     = NULL;
    _transitionDictTime = NULL;
    
    _dictRes  = NULL;
    _dictDur  = NULL;
    _closed   = true;
    
    // Adding the resource task to the resources
    for (ORInt k = low; k <= up; k++) {
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*) resources[k] add:self durationRange:[duration at:k]];
        else
            [(ORTaskCumulative *) resources[k] add:self durationRange:[duration at:k] with:[usage at:k]];
    }
    
    return self;
}
-(id<ORResourceTask>) initORResourceTaskEmpty:(id<ORModel>)model horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration
{
    self = [super initORTaskVar:model horizon:horizon duration:duration];

    _transitionSource   = NULL;
    _transitionTask     = NULL;
    _transitionTime     = NULL;
    _transitionDictTime = NULL;
    
    _dictRes = [[NSMutableDictionary alloc] initWithCapacity: 16];
    _dictDur = [[NSMutableDictionary alloc] initWithCapacity: 16];
    _closed  = false;
    
    return self;
}
-(id<ORResourceTask>) initOROptionalResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntRangeArray>)duration runsOnOneOf:(id<ORResourceArray>)resources
{
    assert(duration.low == resources.low);
    assert(duration.up  == resources.up );
    const ORInt low = duration.low;
    const ORInt up  = duration.up;
    
    // Checking for the right resources
    for (ORInt k = low; k <= up; k++) {
        if (![resources[k] isMemberOfClass: [ORTaskDisjunctive class]] && ![resources[k] isMemberOfClass: [ORTaskCumulative class]])
            @throw [[ORExecutionError alloc] initORExecutionError: "The resource task contains references to non-resource constraints"];
    }
    
    ORInt minDur = MAXINT;
    ORInt maxDur = MININT;
    for (ORInt k = low; k <= up; k++) {
        minDur = min(minDur, [duration at:k].low);
        maxDur = max(maxDur, [duration at:k].up );
    }
    
    self = [super initOROptionalTaskVar:model horizon:horizon duration:RANGE(_model, minDur, maxDur)];
    
    _res      = resources;
    _durArray = duration;
    _transitionSource   = NULL;
    _transitionTask     = NULL;
    _transitionTime     = NULL;
    _transitionDictTime = NULL;
    
    _dictRes  = NULL;
    _dictDur  = NULL;
    _closed   = true;
    
    // Adding the resource task to the resources
    for (ORInt k = low; k <= up; k++) {
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*) resources[k] add:self durationRange:[duration at:k]];
        else
            [(ORTaskCumulative *) resources[k] add:self durationRange:[duration at:k]];
    }
    
    return self;
}
-(id<ORResourceTask>) initOROptionalResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntRangeArray>)duration usageArray:(id<ORIntVarArray>)usage runsOnOneOf:(id<ORResourceArray>)resources
{
    assert(duration.low == resources.low);
    assert(duration.up  == resources.up );
    assert(duration.low == usage.low);
    assert(duration.up  == usage.up );
    const ORInt low = duration.low;
    const ORInt up  = duration.up;
    
    // Checking for the right resources
    for (ORInt k = low; k <= up; k++) {
        if (![resources[k] isMemberOfClass: [ORTaskDisjunctive class]] && ![resources[k] isMemberOfClass: [ORTaskCumulative class]])
            @throw [[ORExecutionError alloc] initORExecutionError: "The resource task contains references to non-resource constraints"];
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]] && !([[usage at: k] min] == 1 && [[usage at: k] max] == 1))
            @throw [[ORExecutionError alloc] initORExecutionError: "The resource task contains references to non-resource constraints"];
    }
    
    ORInt minDur = MAXINT;
    ORInt maxDur = MININT;
    for (ORInt k = low; k <= up; k++) {
        minDur = min(minDur, [duration at:k].low);
        maxDur = max(maxDur, [duration at:k].up );
    }
    
    self = [super initOROptionalTaskVar:model horizon:horizon duration:RANGE(_model, minDur, maxDur)];
    
    _res      = resources;
    _durArray = duration;
    _transitionSource   = NULL;
    _transitionTask     = NULL;
    _transitionTime     = NULL;
    _transitionDictTime = NULL;
    
    _dictRes  = NULL;
    _dictDur  = NULL;
    _closed   = true;
    
    // Adding the resource task to the resources
    for (ORInt k = low; k <= up; k++) {
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*) resources[k] add:self durationRange:[duration at:k]];
        else
            [(ORTaskCumulative *) resources[k] add:self durationRange:[duration at:k] with:[usage at:k]];
    }
    
    return self;
}
-(id<ORResourceTask>) initOROptionalResourceTaskEmpty:(id<ORModel>)model horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration
{
    self = [super initOROptionalTaskVar:model horizon:horizon duration:duration];
    
    _transitionSource   = NULL;
    _transitionTask     = NULL;
    _transitionTime     = NULL;
    _transitionDictTime = NULL;
    
    _dictRes = [[NSMutableDictionary alloc] initWithCapacity: 16];
    _dictDur = [[NSMutableDictionary alloc] initWithCapacity: 16];
    _closed  = false;
    
    return self;
}
-(void) dealloc
{
    if (_dictRes != NULL)
        [_dictRes dealloc];
    if (_dictDur != NULL)
        [_dictDur dealloc];
    [super dealloc];
}
-(id<ORResourceArray>) resources
{
    if (!_closed)
        @throw [[ORExecutionError alloc] initORExecutionError: "The resource task is not closed yet"];
    return _res;
}
-(id<ORIntRangeArray>) durationArray
{
    if (!_closed)
        @throw [[ORExecutionError alloc] initORExecutionError: "The resource task is not closed yet"];
    return _durArray;
}
-(ORInt) getIndex:(id<ORConstraint>)resource
{
    if (!_closed)
        @throw [[ORExecutionError alloc] initORExecutionError: "The resource task is not closed yet"];
    ORInt index = _res.low;
    for (; index <= _res.up; index++)
        if (_res[index].getId == resource.getId)
            return index;
    return ++index;
}
-(id<ORResourceTask>) getTransitionTask
{
    if (_transitionTask == NULL) {
        if (_isOptional)
            _transitionTask = [ORFactory optionalResourceTask:_model horizon:RANGE(_model,_horizon.low,MAXINT) duration:RANGE(_model, MININT, MAXINT)];
        else
            _transitionTask = [ORFactory resourceTask:_model horizon:RANGE(_model,_horizon.low,MAXINT) duration:RANGE(_model, MININT, MAXINT)];
        [(ORResourceTask *)_transitionTask setTransitionSource:self];
        if (_closed)
            _transitionTime = [ORFactory intVarArray:_model range:_res.range with:^id<ORIntVar>(ORInt k) {return NULL;}];
        else {
            _transitionDictTime = [[NSMutableDictionary alloc] initWithCapacity: 16];
        }
    }
    return _transitionTask;
}
-(id<ORResourceTask>) getTransitionSource
{
    return _transitionSource;
}
-(id<ORIntVarArray>) getTransitionTime
{
    return _transitionTime;
}
-(void) setTransitionSource:(id<ORResourceTask>)source
{
    _transitionSource = source;
}
-(void) close
{
    if (!_closed) {
        _closed = true;
        id<ORIntRange> range = RANGE(_model, 1, (ORInt)[_dictRes count]);
        NSArray * keys = [_dictRes allKeys];
        _res      = [ORFactory resourceArray:_model range:range with: ^id<ORConstraint>(ORInt i) {
            assert([_dictRes objectForKey:keys[i - 1]] != NULL);
            return (id<ORConstraint>)[_dictRes objectForKey:keys[i - 1]];
        }];
        _durArray = [ORFactory intRangeArray:_model range: range with:^id<ORIntRange>(ORInt i) {
            assert([_dictDur objectForKey:keys[i - 1]] != NULL);
            return (id<ORIntRange>)[_dictDur objectForKey:keys[i - 1]];
        }];
        if (_transitionTask != NULL) {
            _transitionTime = [ORFactory intVarArray:_model range:range with:^id<ORIntVar>(ORInt i) {
                return (id<ORIntVar>)[_transitionDictTime objectForKey:keys[i - 1]];
            }];
        }
    }
}
-(void) addResource: (id<ORConstraint>) resource with: (id<ORIntRange>) duration
{
    if (![resource isMemberOfClass: [ORTaskDisjunctive class]] && ![resource isMemberOfClass: [ORTaskCumulative class]])
        @throw [[ORExecutionError alloc] initORExecutionError: "Tried to add a non-resource to resource task"];
    ORInt key = [resource getId];
    // Check whether it is already added
    if ([_dictRes objectForKey: @(key)] == nil) {
        if (_closed)
            @throw [[ORExecutionError alloc] initORExecutionError: "The resource task is already closed"];
        // Adding the resource and duration
        [_dictRes setObject:resource forKey:@(key)];
        [_dictDur setObject:duration forKey:@(key)];
        // Add machine task to disjunctive
        if ([resource isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*)resource add:self durationRange:duration];
        else
            [(ORTaskCumulative*) resource add:self durationRange:duration];
    }
}
-(void) addTransition: (id<ORConstraint>) resource with: (id<ORIntVar>) duration
{
    if (![resource isMemberOfClass: [ORTaskDisjunctive class]] && ![resource isMemberOfClass: [ORTaskCumulative class]])
        @throw [[ORExecutionError alloc] initORExecutionError: "Tried to add a non-resource to resource task"];
    const ORInt key = [resource getId];
    if (_closed) {
        ORInt r = _res.range.low;
        for (; r <= _res.range.up; r++) {
            if (_res[r].getId == key)
                break;
        }
        if (r > _res.range.up)
            @throw [[ORExecutionError alloc] initORExecutionError: "Resource is not part of the resource task"];
        [_transitionTime set:duration at:r];
    }
    else {
        assert([_dictRes objectForKey:@(key)] != nil);
        assert([_transitionDictDur objectForKey:@(key)] == nil);
        [_transitionDictTime setObject:duration forKey:@(key)];
    }
}
-(void) finaliseTransitionTask
{
    assert(_transitionTime != NULL);
    assert(_transitionTime.low == _res.low && _transitionTime.up == _res.up);
    ORInt tmin = MAXINT;
    ORInt tmax = MININT;
    // Compute the transition time range
    for (ORInt i = _transitionTime.low; i <= _transitionTime.up; i++) {
        id<ORIntVar> time = [_transitionTime at:i];
        if (time == NULL) {
            time = [ORFactory intVar:_model value:0];
            [_transitionTime set:time at:i];
        }
        tmin = min(tmin, time.min);
        tmax = max(tmax, time.max);
    }
    // Compute all ranges
    id<ORIntRange> horizon  = RANGE(_model, _horizon.low, _horizon.up + tmax);
    id<ORIntRange> duration = RANGE(_model, _duration.low + tmin, _duration.up + tmax);
    // Update the ranges
    [(ORResourceTask *)_transitionTask updateTransitionTask:horizon duration:duration];
}
-(void) updateTransitionTask:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration
{
    assert(_transitionSource != NULL);
    _horizon  = horizon;
    _duration = duration;
}
-(void) visit:(ORVisitor*) v
{
    if (!_closed)
        [self close];
    [v visitResourceTask: self];
}
@end