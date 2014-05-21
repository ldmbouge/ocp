/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPIntVarI.h>
#import "CPConstraint.h"


    // Single precedence propagator
    //
@implementation CPPrecedence

-(id) initCPPrecedence:(id<CPActivity>)before after:(id<CPActivity>)after {

    self = [super initCPCoreConstraint:before.startLB.engine];
    
    _before = before;
    _after  = after;
    
    NSLog(@"Create precedence constraint\n");
    
    return self;
}
-(void) dealloc {
    [super dealloc];
}
-(ORStatus) post {
    [self propagate];
    
    if (!_before.startLB.bound)
        [_before.startLB whenChangeMinPropagate:self];
    if (!_before.duration.bound)
        [_before.duration whenChangeMinPropagate:self];
    if (_before.isOptional) {
        if (!_before.top.bound)
            [_before.top whenBindPropagate:self];
    }
    if (!_after.startUB.bound)
        [_after.startUB whenChangeMinPropagate:self];
    if (_after.isOptional) {
        if (!_after.top.bound)
            [_after.top whenBindPropagate:self];
    }
    
    return ORSuspend;
}
-(void) propagate {
    if (_before.isAbsent || _after.isAbsent || _before.startUB.max + _before.duration.max <= _after.startLB.min) {
        assignTRInt(&_active, NO, _trail);
    }
    else if (_before.isPresent && _after.isPresent) {
        [_after updateStartMin:_before.startLB.min + _before.duration.min];
        [_before updateStartMax:_after.startUB.max - _before.duration.min];
        updateMaxDom((CPIntVar *)_before.duration, _after.startUB.max - _before.startLB.min);
    }
    else {
        if ([_before implyPresent:_after]) {
            [_before updateStartMax:_after.startUB.max - _before.duration.min];
            updateMaxDom((CPIntVar *)_before.duration, _after.startUB.max - _before.startLB.min);
        }
        if ([_after implyPresent:_before]) {
            [_after updateStartMin:_before.startLB.min + _before.duration.min];
        }
    }
}
-(NSSet*) allVars
{
    ORInt size = 0;
    size += (_before.isOptional ? 4 : 2);
    size += (_after .isOptional ? 3 : 1);
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_before.startLB ];
    [rv addObject:_after .startLB ];
    [rv addObject:_before.duration];
    if (_before.isOptional) {
        [rv addObject:_before.startUB];
        [rv addObject:_before.top    ];
    }
    if (_after.isOptional) {
        [rv addObject:_after.startUB];
        [rv addObject:_after.top    ];
    }
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    ORUInt nb = 0;
    if (!_before.startLB .bound) nb++;
    if (!_after .startLB .bound) nb++;
    if (!_before.duration.bound) nb++;
    if (!_after .duration.bound) nb++;
    if (_before.isOptional) {
        if (!_before.startUB.bound) nb++;
        if (!_before.top    .bound) nb++;
    }
    if (_after.isOptional) {
        if (!_after.startUB.bound) nb++;
        if (!_after.top    .bound) nb++;
    }
    return nb;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    assert(false);
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    assert(false);
}
@end

    // TODO Alternative propagator
    //
@implementation CPAlternative {
    ORInt * _idx;
    TRInt   _size;
}

-(id) iniitCPAlternative: (id<CPActivity>) act alternatives: (id<CPActivityArray>) alter
{
    self = [super initCPCoreConstraint:act.startLB.engine];
    
    _act   = act;
    _alter = alter;
    _idx   = NULL;
    
    NSLog(@"Create alternative constraint\n");
    
    return self;
}
-(void) dealloc
{
    if (_idx != NULL) free(_idx);
    [super dealloc];
}
-(ORStatus) post
{
    // Initialise trailed parameters
    _size = makeTRInt(_trail, (ORInt)_alter.count);
    
    // Allocate memory
    _idx = malloc(_alter.count * sizeof(ORInt));
    
    // Check whether memory allocation was successful
    if (_idx == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPAlternative: Out of memory!"];
    }
    
    // Initialise misc
    for (ORInt i = 0; i < _alter.count; i++) {
        _idx[i] = i + _alter.range.low;
    }
    
    // Initial propagation
    [self propagate];
    
    // Subscription of variables to the constraint
    for (ORInt i = _alter.range.low; i <= _alter.range.up; i++) {
        assert(_alter[i].isOptional);
        if (_alter[i].top.max == 0) continue;
        [_alter[i].top whenBindPropagate:self];
        if (!_alter[i].startLB.bound)
            [_alter[i].startLB whenChangeMinPropagate:self];
        if (!_alter[i].startUB.bound)
            [_alter[i].startUB whenChangeMaxPropagate:self];
        if (!_alter[i].duration.bound)
            [_alter[i].duration whenChangeBoundsPropagate:self];
    }
    if (_act.isOptional && !_act.top.bound)
        [_act.top whenBindPropagate:self];
    if (!_act.startLB.bound)
        [_act.startLB whenChangeMinPropagate:self];
    if (!_act.startUB.bound)
        [_act.startUB whenChangeMinPropagate:self];
    if (!_act.duration.bound)
        [_act.duration whenChangeBoundsPropagate:self];

    return ORSuspend;
}
-(void) propagate
{
    // Checking present
    ORInt size = _size._val;
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = _idx[ii];
        if (_alter[i].top.bound) {
            if (_alter[i].top.value == 1) {
                [_act.top bind:1];
                _idx[ii] = _idx[0];
                _idx[0]  = i;
                for (ORInt kk = 1; kk < size; kk++)
                    [_alter[_idx[kk]].top bind:0];
                size = 1;
                break;
            }
            else {
                _idx[ii]       = _idx[size - 1];
                _idx[size - 1] = i;
                size--;
                ii--;
            }
        }
        else {
            // Check present
            if (_alter[i].startLB.min > _act.startUB.max || _alter[i].startUB.max < _act.startLB.min
                || _alter[i].duration.min > _act.duration.max || _alter[i].duration.max < _act.duration.min) {
                [_alter[i].top bind: 0];
                ii--;
            }
        }
    }
    if (size == 0) {
        if (_act.isOptional)
            [_act.top bind:0];
        else
            failNow();
    }
    assignTRInt(&_size, size, _trail);
    
    // Propagation of start and duration
    ORInt startMin = MAXINT;
    ORInt startMax = MININT;
    ORInt durMin   = MAXINT;
    ORInt durMax   = MININT;
    for (ORInt ii = 0; ii < size; ii++) {
        const ORInt i = _idx[ii];
        if (_alter[i].startLB.min < _act.startLB.min) [_alter[i] updateStartMin:_act.startLB.min];
        if (_alter[i].startUB.max > _act.startUB.max) [_alter[i] updateStartMax:_act.startUB.max];
        if (_alter[i].duration.min < _act.duration.min) [_alter[i].duration updateMin:_act.duration.min];
        if (_alter[i].duration.max > _act.duration.max) [_alter[i].duration updateMax:_act.duration.max];
        startMin = min(startMin, _alter[i].startLB .min);
        startMax = max(startMax, _alter[i].startUB .max);
        durMin   = min(durMin  , _alter[i].duration.min);
        durMax   = max(durMax  , _alter[i].duration.max);
    }
    if (startMin > _act.startLB.min) [_act updateStartMin:startMin];
    if (startMax < _act.startUB.max) [_act updateStartMax:startMax];
    if (durMin > _act.duration.min) [_act.duration updateMin:durMin];
    if (durMax < _act.duration.max) [_act.duration updateMax:durMax];
}
-(void) bindActivity
{
    assert(_act.top.bound);
    if (_act.top.value == 1) {
        if (_size._val == 1) {
            const ORInt startMin = max(_act.startLB.min, _alter[_idx[0]].startLB.min);
            const ORInt startMax = min(_act.startUB.max, _alter[_idx[0]].startUB.max);
            [_alter[_idx[0]].top bind:1];
            [_alter[_idx[0]].startLB updateMin:startMin];
            [_alter[_idx[0]].startUB updateMax:startMax];
            [_act.startLB updateMin:startMin];
            [_act.startUB updateMin:startMax];
        }
    }
    else {
        for (ORInt ii = 0; ii < _size._val; ii++) {
            [_alter[_idx[ii]].top bind:0];
        }
        assignTRInt(&_size, 0, _trail);
    }
}
-(NSSet*) allVars
{
    // TODO
}
-(ORUInt) nbUVars
{
    // TODO
}

@end

