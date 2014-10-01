/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORTaskI.h"
#import <ORScheduler/ORSchedFactory.h>
#import <ORScheduler/ORVisit.h>


@implementation ORTaskVar {
   @protected id<ORModel> _model;
   id<ORIntRange>  _horizon;
   id<ORIntRange>  _duration;
   ORBool _isOptional;
}
-(id<ORTaskVar>) initORTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _model = model;
   _duration = duration;
   _horizon = horizon;
   _isOptional = FALSE;
   return self;
}
-(id<ORTaskVar>) initOROptionalTaskVar: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _model = model;
   _duration = duration;
   _horizon = horizon;
   _isOptional = TRUE;
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