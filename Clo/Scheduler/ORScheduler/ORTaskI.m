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
    id<ORIntVar>   _presenceVar;
}
-(id<ORTaskVar>) initORTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _model = model;
   _duration = duration;
   _horizon = horizon;
   _isOptional = FALSE;
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

@implementation ORMachineTask {
    id<ORTaskDisjunctiveArray> _disj;
    id<ORIntArray>             _durArray;

    NSMutableDictionary * _dictDisj;
    NSMutableDictionary * _dictDur;
    ORBool _closed;
}
-(id<ORMachineTask>) initORMachineTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntArray>)duration runsOnOneOf:(id<ORTaskDisjunctiveArray>)disjunctives
{
    ORInt minDur = MAXINT;
    ORInt maxDur = MININT;
    for (ORInt k = duration.low; k <= duration.up; k++) {
        minDur = min(minDur, [duration at:k]);
        maxDur = max(maxDur, [duration at:k]);
    }
    
    self = [super initORTaskVar:model horizon:horizon duration:nil];
    
    _disj     = disjunctives;
    _durArray = duration;
    
    _dictDisj  = NULL;
    _dictDur   = NULL;
    _closed    = true;
    
    // Adding the machine task to the disjunctive resource
    for (ORInt k = duration.low; k <= duration.up; k++)
        [disjunctives[k] add:self duration:[duration at:k]];
    
    return self;
}
-(id<ORMachineTask>) initORMachineTaskEmpty:(id<ORModel>)model horizon:(id<ORIntRange>)horizon
{
    self = [super initORTaskVar:model horizon:horizon duration:RANGE(model, 0, 0)];
    
    _dictDisj = [[NSMutableDictionary alloc] initWithCapacity: 16];
    _dictDur  = [[NSMutableDictionary alloc] initWithCapacity: 16];
    _closed  = false;
    
    return self;
}
-(void) dealloc
{
    if (_dictDisj != NULL)
        [_dictDisj dealloc];
    if (_dictDur != NULL)
        [_dictDur dealloc];
    [super dealloc];
}
-(id<ORTaskDisjunctiveArray>) disjunctives
{
    if (!_closed)
        @throw [[ORExecutionError alloc] initORExecutionError: "The machine task is not closed yet"];
    return _disj;
}
-(id<ORIntArray>) durationArray
{
    if (!_closed)
        @throw [[ORExecutionError alloc] initORExecutionError: "The machine task is not closed yet"];
    return _durArray;
}
-(ORInt) getIndex:(id<ORTaskDisjunctive>)disjunctive
{
    if (!_closed)
        @throw [[ORExecutionError alloc] initORExecutionError: "The machine task is not closed yet"];
    ORInt index = _disj.low;
    for (; index <= _disj.up; index++)
        if (_disj[index].getId == disjunctive.getId)
            return index;
    return ++index;
}
-(void) close
{
    if (!_closed) {
        _closed = true;
        id<ORIntRange> range = RANGE(_model, 1, (ORInt)[_dictDisj count]);
        NSArray * keys = [_dictDisj allKeys];
        _disj     = [ORFactory disjunctiveArray:_model range:range with: ^id<ORTaskDisjunctive>(ORInt i) {
            assert([_dictDisj objectForKey:keys[i - 1]] != NULL);
            return (id<ORTaskDisjunctive>)[_dictDisj objectForKey:keys[i - 1]];
        }];
        _durArray = [ORFactory intArray:_model range: range with:^ORInt(ORInt i) {
            assert([_dictDur objectForKey:keys[i - 1]] != NULL);
            return [[_dictDur objectForKey:keys[i - 1]] intValue];
        }];
        
        ORInt minDur = MAXINT;
        ORInt maxDur = MININT;
        for (ORInt k = _durArray.low; k <= _durArray.up; k++) {
            minDur = min(minDur, [_durArray at:k]);
            maxDur = max(maxDur, [_durArray at:k]);
        }
        _duration = RANGE(_model, minDur, maxDur);
    }
}
-(void) addDisjunctive: (id<ORTaskDisjunctive>) disjunctive with: (ORInt) duration
{
    ORInt key = [disjunctive getId];
    // Check whether it is already added
    if ([_dictDisj objectForKey: @(key)] == nil) {
        if (_closed)
            @throw [[ORExecutionError alloc] initORExecutionError: "The machine task is already closed"];
        // Adding the disjunctive and duration
        [_dictDisj setObject:disjunctive forKey:@(key)];
        [_dictDur  setObject:@(duration) forKey:@(key)];
        // Add machine task to disjunctive
        [disjunctive add:self duration:duration];
    }
}
-(void) visit:(ORVisitor*) v
{
    if (!_closed)
        [self close];
    [v visitMachineTask: self];
}
@end

@implementation ORResourceTask {
    id<ORResourceArray> _res;
    id<ORIntArray>      _durArray;
    
    NSMutableDictionary * _dictRes;
    NSMutableDictionary * _dictDur;
    ORBool _closed;
}
-(id<ORResourceTask>) initORResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntArray>)duration runsOnOneOf:(id<ORResourceArray>)resources
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
        minDur = min(minDur, [duration at:k]);
        maxDur = max(maxDur, [duration at:k]);
    }
    
    self = [super initORTaskVar:model horizon:horizon duration:nil];
    
    _res      = resources;
    _durArray = duration;
    
    _dictRes  = NULL;
    _dictDur  = NULL;
    _closed   = true;
    
    // Adding the resource task to the resources
    for (ORInt k = low; k <= up; k++) {
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*) resources[k] addRT:self duration:[duration at:k]];
        else
            [(ORTaskCumulative *) resources[k] addRT:self duration:[duration at:k]];
    }
    
    return self;
}
-(id<ORResourceTask>) initORResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntArray>)duration usageArray:(id<ORIntVarArray>)usage runsOnOneOf:(id<ORResourceArray>)resources
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
        minDur = min(minDur, [duration at:k]);
        maxDur = max(maxDur, [duration at:k]);
    }
    
    self = [super initORTaskVar:model horizon:horizon duration:nil];
    
    _res      = resources;
    _durArray = duration;
    
    _dictRes  = NULL;
    _dictDur  = NULL;
    _closed   = true;
    
    // Adding the resource task to the resources
    for (ORInt k = low; k <= up; k++) {
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*) resources[k] addRT:self duration:[duration at:k]];
        else
            [(ORTaskCumulative *) resources[k] addRT:self duration:[duration at:k] with:[usage at:k]];
    }
    
    return self;
}
-(id<ORResourceTask>) initORResourceTaskEmpty:(id<ORModel>)model horizon:(id<ORIntRange>)horizon
{
    self = [super initORTaskVar:model horizon:horizon duration:RANGE(model, 0, 0)];
    
    _dictRes = [[NSMutableDictionary alloc] initWithCapacity: 16];
    _dictDur = [[NSMutableDictionary alloc] initWithCapacity: 16];
    _closed  = false;
    
    return self;
}
-(id<ORResourceTask>) initOROptionalResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntArray>)duration runsOnOneOf:(id<ORResourceArray>)resources
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
        minDur = min(minDur, [duration at:k]);
        maxDur = max(maxDur, [duration at:k]);
    }
    
    self = [super initOROptionalTaskVar:model horizon:horizon duration:nil];
    
    _res      = resources;
    _durArray = duration;
    
    _dictRes  = NULL;
    _dictDur  = NULL;
    _closed   = true;
    
    // Adding the resource task to the resources
    for (ORInt k = low; k <= up; k++) {
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*) resources[k] addRT:self duration:[duration at:k]];
        else
            [(ORTaskCumulative *) resources[k] addRT:self duration:[duration at:k]];
    }
    
    return self;
}
-(id<ORResourceTask>) initOROptionalResourceTask:(id<ORModel>)model horizon:(id<ORIntRange>)horizon durationArray:(id<ORIntArray>)duration usageArray:(id<ORIntVarArray>)usage runsOnOneOf:(id<ORResourceArray>)resources
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
        minDur = min(minDur, [duration at:k]);
        maxDur = max(maxDur, [duration at:k]);
    }
    
    self = [super initOROptionalTaskVar:model horizon:horizon duration:nil];
    
    _res      = resources;
    _durArray = duration;
    
    _dictRes  = NULL;
    _dictDur  = NULL;
    _closed   = true;
    
    // Adding the resource task to the resources
    for (ORInt k = low; k <= up; k++) {
        if ([resources[k] isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*) resources[k] addRT:self duration:[duration at:k]];
        else
            [(ORTaskCumulative *) resources[k] addRT:self duration:[duration at:k] with:[usage at:k]];
    }
    
    return self;
}
-(id<ORResourceTask>) initOROptionalResourceTaskEmpty:(id<ORModel>)model horizon:(id<ORIntRange>)horizon
{
    self = [super initOROptionalTaskVar:model horizon:horizon duration:RANGE(model, 0, 0)];
    
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
-(id<ORIntArray>) durationArray
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
        _durArray = [ORFactory intArray:_model range: range with:^ORInt(ORInt i) {
            assert([_dictDur objectForKey:keys[i - 1]] != NULL);
            return [[_dictDur objectForKey:keys[i - 1]] intValue];
        }];
        
        ORInt minDur = MAXINT;
        ORInt maxDur = MININT;
        for (ORInt k = _durArray.low; k <= _durArray.up; k++) {
            minDur = min(minDur, [_durArray at:k]);
            maxDur = max(maxDur, [_durArray at:k]);
        }
        _duration = RANGE(_model, minDur, maxDur);
    }
}
-(void) addResource: (id<ORConstraint>) resource with: (ORInt) duration
{
    if (![resource isMemberOfClass: [ORTaskDisjunctive class]] && ![resource isMemberOfClass: [ORTaskDisjunctive class]])
        @throw [[ORExecutionError alloc] initORExecutionError: "Tried to add a non-resource to resource task"];
    ORInt key = [resource getId];
    // Check whether it is already added
    if ([_dictRes objectForKey: @(key)] == nil) {
        if (_closed)
            @throw [[ORExecutionError alloc] initORExecutionError: "The resource task is already closed"];
        // Adding the resource and duration
        [_dictRes setObject:resource    forKey:@(key)];
        [_dictDur setObject:@(duration) forKey:@(key)];
        // Add machine task to disjunctive
        if ([resource isMemberOfClass: [ORTaskDisjunctive class]])
            [(ORTaskDisjunctive*)resource addRT:self duration:duration];
        else
            [(ORTaskCumulative*) resource addRT:self duration:duration];
    }
}
-(void) visit:(ORVisitor*) v
{
    if (!_closed)
        [self close];
    [v visitResourceTask: self];
}
@end