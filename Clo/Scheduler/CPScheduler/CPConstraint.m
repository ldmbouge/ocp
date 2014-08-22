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
#import "CPTask.h"
#import "CPTaskI.h"


    // Alternative propagator
    //
@implementation CPAlternative {
    ORInt * _idx;   // Array of alternative task's indices
    TRInt   _size;  // Pointer to the first absent alternative task in the array _idx
    
    TRInt   _watchStart;
    TRInt   _watchEnd;
    TRInt   _watchMinDur;
    TRInt   _watchMaxDur;
}
-(id) initCPAlternative: (id<CPTaskVar>) task alternatives: (id<CPTaskVarArray>) alt
{
    self = [super initCPCoreConstraint:task.engine];
    
    _task = task;
    _alt  = alt;
    _idx  = NULL;
    
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
    const ORInt size = [_alt count];
    const ORInt low  = [_alt low  ];
    const ORInt up   = [_alt up   ];
    
    // Initialise trailed parameters
    _size        = makeTRInt(_trail, size);
    _watchStart  = makeTRInt(_trail, size);
    _watchEnd    = makeTRInt(_trail, size);
    _watchMinDur = makeTRInt(_trail, size);
    _watchMaxDur = makeTRInt(_trail, size);
    
    // Allocate memory
    _idx = malloc(size * sizeof(ORInt));
    
    // Check whether memory allocation was successful
    if (_idx == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPAlternative: Out of memory!"];
    }
    
    // Initialise misc
    for (ORInt i = 0; i < size; i++) {
        _idx[i] = i + low;
    }
    
    // Initial propagation
    [self initPropagation];
    
    // Subscription of the alternative tasks
    for (ORInt i = low; i <= up; i++) {
        if (_alt[i].isPresent) {
            // Bound change on start
            [_alt[i] whenChangeStartDo:^{
                [_task updateStart:_alt[i].est];
            } onBehalf: self];
            // Bound change on end
            [_alt[i] whenChangeEndDo:^{
                [_task updateEnd:_alt[i].lct];
            } onBehalf: self];
            // Bound change on duration
            if (_alt[i].minDuration < _alt[i].maxDuration) {
                [_alt[i] whenChangeDurationDo: ^{
                    [_task updateMinDuration: _alt[i].minDuration];
                    [_task updateMaxDuration: _alt[i].maxDuration];
                } onBehalf: self];
            }
        }
        else if (!_alt[i].isAbsent) {
            // Change to present
            [_alt[i] whenPresentDo: ^{
                [self propagateAlternativePresence: i];
            } onBehalf: self];
            // Change to absent
            [_alt[i] whenAbsentDo: ^{
                [self propagateAlternativeAbsence: i];
            } onBehalf: self];
            // Bound change on start
            [_alt[i] whenChangeStartDo: ^{
                if (_size._val == 1) {
                    assert(_idx[0] == i);
                    [_task updateStart: _alt[i].est];
                }
                else if (_watchStart._val == i) {
                    [self propagateAlternativeStart];
                }
            } onBehalf: self];
            // Bound change on end
            [_alt[i] whenChangeEndDo: ^{
                if (_size._val == 1) {
                    assert(_idx[0] == i);
                    [_task updateEnd: _alt[i].lct];
                }
                else if (_watchEnd._val == i) {
                    [self propagateAlternativeEnd];
                }
            } onBehalf: self];
            // Bound change on duration
            [_alt[i] whenChangeDurationDo: ^{
                if (_size._val == 1) {
                    assert(_idx[0] == i);
                    [_task updateMinDuration: _alt[i].minDuration];
                    [_task updateMaxDuration: _alt[i].maxDuration];
                }
                else if (_watchMinDur._val == i || _watchMaxDur._val == i) {
                    [self propagateAlternativeDuration];
                }
            } onBehalf: self];
        }
    }
    
    if (!_task.isAbsent) {
        // Bound change on start
        [_task whenChangeStartDo: ^{
            
        } onBehalf: self];
    }
    
    return ORSuspend;
}
-(void) propagateTaskAbsence
{
    assert(_task.isAbsent);
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_alt[i] labelPresent: false];
    }
    assignTRInt(&(_size), 0, _trail);
}
-(void) propagateAllVariablesOfTask
{
    assert(!_task.isAbsent);
    const ORInt start  = _task.est;
    const ORInt end    = _task.lct;
    const ORInt minDur = _task.minDuration;
    const ORInt maxDur = _task.maxDuration;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        [_alt[i] updateStart      : start ];
        [_alt[i] updateEnd        : end   ];
        [_alt[i] updateMinDuration: minDur];
        [_alt[i] updateMaxDuration: maxDur];
    }
}
-(void) propagateAlternativeStart
{
    ORInt minStart = MAXINT;
    ORInt wStart   = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (minStart > _alt[i].est) {
            minStart = _alt[i].est;
            wStart   = i;
        }
    }
    assert(_alt.low <= wStart  && wStart  <= _alt.up);
    [_task updateStart: minStart];
    if (wStart != _watchStart._val)
        assignTRInt(&(_watchStart), wStart, _trail);
}
-(void) propagateAlternativeEnd
{
    ORInt maxEnd = MININT;
    ORInt wEnd   = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (maxEnd < _alt[i].lct) {
            maxEnd = _alt[i].lct;
            wEnd   = i;
        }
    }
    assert(_alt.low <= wEnd    && wEnd    <= _alt.up);
    [_task updateEnd: maxEnd];
    if (wEnd != _watchEnd._val)
        assignTRInt(&(_watchEnd), wEnd, _trail);
}
-(void) propagateAlternativeDuration
{
    ORInt minDur  = MAXINT;
    ORInt maxDur  = MININT;
    ORInt wMinDur = MAXINT;
    ORInt wMaxDur = MAXINT;
    for (ORInt ii = 0; ii < _size._val; ii++) {
        const ORInt i = _idx[ii];
        if (minDur > _alt[i].minDuration) {
            minDur  = _alt[i].minDuration;
            wMinDur = i;
        }
        if (maxDur < _alt[i].maxDuration) {
            maxDur  = _alt[i].maxDuration;
            wMaxDur = i;
        }
    }
    assert(_alt.low <= wMinDur && wMinDur <= _alt.up);
    assert(_alt.low <= wMaxDur && wMaxDur <= _alt.up);
    [_task updateMinDuration: minDur];
    [_task updateMaxDuration: maxDur];
    if (wMinDur != _watchMinDur._val)
        assignTRInt(&(_watchMinDur), wMinDur, _trail);
    if (wMaxDur != _watchMaxDur._val)
        assignTRInt(&(_watchMaxDur), wMaxDur, _trail);
}
-(void) propagateAlternativePresence: (ORInt) k
{
    if (_size._val > 1) {
        for (ORInt ii = 0; ii < _size._val; ii++) {
            const ORInt i = _idx[ii];
            if (i == k) {
                _idx[ii] = _idx[0];
                _idx[0 ] = i;
            }
            else
                [_alt[i] labelPresent: false];
        }
        assignTRInt(&(_size), 1, _trail);
    }
    assert(_size._val == 1);
    assert(_idx[0] == k);
    assert(_alt[k].isPresent);
    [_task labelPresent: true];
    [self propagateAllEqualities];
}
-(void) propagateAlternativeAbsence: (ORInt) k
{
    if (_size._val == 1) {
        assert(_idx[0] == k);
        [_task labelPresent: false];
    }
    else {
        const ORInt size = _size._val - 1;
        for (ORInt ii = 0; ii <= size; ii++) {
            const ORInt i = _idx[ii];
            if (i == k) {
                _idx[ii]   = _idx[size];
                _idx[size] = i;
                break;
            }
        }
        if (size == 1) {
            if (_task.isPresent)
                [_alt[_idx[0]] labelPresent: true];
            else
                [self propagateAllEqualities];
        }
        else {
            if (_watchStart._val == k)
                [self propagateAlternativeStart];
            if (_watchEnd._val == k)
                [self propagateAlternativeEnd];
            if (_watchMinDur._val == k || _watchMaxDur._val == k)
                [self propagateAlternativeDuration];
        }
        assignTRInt(&(_size), size, _trail);
    }
}
-(void) propagateAllEqualities
{
    const ORInt k = _idx[0];
    ORBool test = false;
    do {
        [_task updateStart      : _alt[k].est        ];
        [_task updateEnd        : _alt[k].lct        ];
        [_task updateMinDuration: _alt[k].minDuration];
        [_task updateMaxDuration: _alt[k].maxDuration];
        test = (_task.est != _alt[k].est || _task.lct != _alt[k].lct ||
             _task.minDuration != _alt[k].minDuration ||
             _task.maxDuration != _alt[k].maxDuration);
    } while (test && !_task.isAbsent && !_alt[k].isAbsent);
}
-(void) initPropagation
{
    ORInt size = _size._val;
    ORInt minStart = MAXINT;
    ORInt maxEnd   = MININT;
    ORInt minDur   = MAXINT;
    ORInt maxDur   = MININT;
    ORInt wStart   = MAXINT;
    ORInt wEnd     = MAXINT;
    ORInt wMinDur  = MAXINT;
    ORInt wMaxDur  = MAXINT;
    ORBool update  = false;
    ORBool noAltPresent = true;
    
    do {
        if (_task.isAbsent)
            [self propagateTaskAbsence];
        else {
            // Retrieving information from the alternative tasks
            for (ORInt ii = 0; ii < size; ii++) {
                const ORInt i = _idx[ii];
                // Check whether alternative task is absent
                if (_alt[i].isAbsent) {
                    // Alternative task is absent, swap it to the end
                    if (ii < size - 1) {
                        size--;
                        _idx[ii  ] = _idx[size];
                        _idx[size] = i;
                        ii--;
                    }
                }
                else if (_alt[i].isPresent) {
                    // Alternative task is present
                    [self propagateAlternativePresence: i];
                    noAltPresent = false;
                    break;
                }
                else {
                    // Presence of alternative task is still unknown
                    if (_alt[i].est < minStart) {
                        minStart = _alt[i].est;
                        wStart   = i;
                    }
                    if (_alt[i].lct > maxEnd) {
                        maxEnd = _alt[i].lct;
                        wEnd   = i;
                    }
                    if (_alt[i].minDuration < minDur) {
                        minDur  = _alt[i].minDuration;
                        wMinDur = i;
                    }
                    if (_alt[i].maxDuration > maxDur) {
                        maxDur  = _alt[i].maxDuration;
                        wMaxDur = i;
                    }
                }
            }
            if (size == 1) {
                if (_task.isPresent) {
                    [_alt[_idx[0]] labelPresent: true];
                    noAltPresent = false;
                }
                [self propagateAllEqualities];
            }
            else {
                // Updating the task bounds
                [_task updateStart      : minStart];
                [_task updateEnd        : maxEnd  ];
                [_task updateMinDuration: minDur  ];
                [_task updateMaxDuration: maxDur  ];
                // Updating the alternative task bounds
                if (_task.isAbsent)
                    update = true;
                else if (_task.est > minStart || _task.lct < maxEnd || _task.minDuration > minDur || _task.maxDuration < maxDur) {
                    [self propagateAllVariablesOfTask];
                    update = true;
                }
            }
        }
    } while (update && noAltPresent);
    
    if (noAltPresent) {
        assert(_alt.low <= wStart  && wStart  <= _alt.up);
        assert(_alt.low <= wEnd    && wEnd    <= _alt.up);
        assert(_alt.low <= wMinDur && wMinDur <= _alt.up);
        assert(_alt.low <= wMaxDur && wMaxDur <= _alt.up);
        assignTRInt(&(_watchStart ), wStart , _trail);
        assignTRInt(&(_watchEnd   ), wEnd   , _trail);
        assignTRInt(&(_watchMinDur), wMinDur, _trail);
        assignTRInt(&(_watchMaxDur), wMaxDur, _trail);
        if (size < _size._val)
            assignTRInt(&(_size), size, _trail);
    }
}
//-(void) propagate
//{
//    ORInt size = _size._val;
//    for (ORInt ii = 0; ii < size; ii++) {
//        const ORInt i = _idx[ii];
//        if (_alter[i].top.bound) {
//            if (_alter[i].top.value == 1) {
//                if (_act.isOptional)
//                    [_act.top bind:1];
//                _idx[ii] = _idx[0];
//                _idx[0]  = i;
//                for (ORInt kk = 1; kk < size; kk++)
//                    [_alter[_idx[kk]].top bind:0];
//                size = 1;
//                break;
//            }
//            else {
//                _idx[ii]       = _idx[size - 1];
//                _idx[size - 1] = i;
//                size--;
//                ii--;
//            }
//        }
//        else {
//            // Check present
//            if (_alter[i].startLB.min > _act.startUB.max || _alter[i].startUB.max < _act.startLB.min
//                || _alter[i].duration.min > _act.duration.max || _alter[i].duration.max < _act.duration.min
//            ) {
//                [_alter[i].top bind: 0];
//                _idx[ii]       = _idx[size - 1];
//                _idx[size - 1] = i;
//                size--;
//                ii--;
//            }
//        }
//    }
//    assignTRInt(&_size, size, _trail);
//    if (size == 1 && _alter[_idx[0]].top.bound) {
//        if (_act.isOptional)
//            [_act.top bind: 1];
//        [self propagateEqual];
//    }
//    if (size == 0) {
//        if (_act.isOptional)
//            [_act.top bind:0];
//        else {
//            failNow();
//        }
//    }
//}
//-(void) dumpState
//{
//    printf("Meta: start [%d,%d]; dur [%d,%d]\n", _act.startLB.min, _act.startUB.max, _act.duration.min, _act.duration.max);
//    for (ORInt i = _alter.range.low; i <= _alter.range.up; i++) {
//        printf("\t%d: top [%d,%d]; start [%d,%d]; dur [%d,%d]\n", i, _alter[i].top.min, _alter[i].top.max, _alter[i].startLB.min, _alter[i].startUB.max, _alter[i].duration.min, _alter[i].duration.max);
//    }
//}
//-(void) bindActivity
//{
//    assert(_act.top.bound);
//    if (_act.top.value == 1) {
//        if (_size._val == 1) {
//            [_alter[_idx[0]].top bind:1];
//            [self propagateEqual];
//        }
//    }
//    else {
//        for (ORInt ii = 0; ii < _size._val; ii++) {
//            [_alter[_idx[ii]].top bind:0];
//        }
//        assignTRInt(&_size, 0, _trail);
//        // Disentail propagator
//        assignTRInt(&_active, NO, _trail);
//    }
//}
//-(void) propActDurMin
//{
//    for (ORInt ii = 0; ii < _size._val; ii++) {
//        const ORInt i = _idx[ii];
//        if (_alter[i].duration.max < _act.duration.min)
//            [_alter[i].top bind:0];
//        else
//            [_alter[i].duration updateMin:_act.duration.min];
//    }
//}
//-(void) propActDurMax
//{
//    for (ORInt ii = 0; ii < _size._val; ii++) {
//        const ORInt i = _idx[ii];
//        if (_alter[i].duration.min > _act.duration.max)
//            [_alter[i].top bind:0];
//        else
//            [_alter[i].duration updateMax:_act.duration.max];
//    }
//}
//-(void) propAlterStartMin
//{
//    ORInt startMin = MAXINT;
//    for (ORInt ii = 0; ii < _size._val; ii++)
//        startMin = min(startMin, _alter[_idx[ii]].startLB.min);
//    [_act updateStartMin:startMin];
//}
//-(void) propAlterStartMax
//{
//    ORInt startMax = MININT;
//    for (ORInt ii = 0; ii < _size._val; ii++)
//        startMax = max(startMax, _alter[_idx[ii]].startUB.max);
//    [_act updateStartMax:startMax];
//}
//-(void) propAlterDurMin
//{
//    ORInt durMin = MAXINT;
//    for (ORInt ii = 0; ii < _size._val; ii++)
//        durMin = min(durMin, _alter[_idx[ii]].duration.min);
//    if (_act.duration.max < durMin)
//        [_act.top bind:0];
//    else
//        [_act.duration updateMin:durMin];
//}
//-(void) propAlterDurMax
//{
//    ORInt durMax = MININT;
//    for (ORInt ii = 0; ii < _size._val; ii++)
//        durMax = max(durMax, _alter[_idx[ii]].duration.max);
//    if (_act.duration.min > durMax)
//        [_act.top bind:0];
//    else
//        [_act.duration updateMax:durMax];
//}
//-(void) propagateEqual
//{
//    assert(_size._val == 1 && _alter[_idx[0]].top.bound && _alter[_idx[0]].top.value == 1);
//    assert((_act.isOptional && _act.top.value == 1) || !_act.isOptional);
//    const ORInt i = _idx[0];
//    id<CPEngine> engine = [_act.startLB engine];
//    [engine addInternal:[CPFactory equal:_act.startLB  to:_alter[i].startLB  plus:0]];
//    [engine addInternal:[CPFactory equal:_act.startUB  to:_alter[i].startUB  plus:0]];
//    [engine addInternal:[CPFactory equal:_act.duration to:_alter[i].duration plus:0]];
//    // Disentail propagator
//    assignTRInt(&_active, NO, _trail);
//}
//-(NSSet*) allVars
//{
//    NSUInteger nb = 4 * [_alter count] + (_act.isOptional ? 4 : 3);
//    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:nb];
//    for (ORInt i = _alter.range.low; i < _alter.range.up; i++) {
//        [rv addObject:_alter[i].top     ];
//        [rv addObject:_alter[i].startLB ];
//        [rv addObject:_alter[i].startUB ];
//        [rv addObject:_alter[i].duration];
//    }
//    if (_act.isOptional)
//        [rv addObject:_act.top];
//    [rv addObject:_act.startLB ];
//    [rv addObject:_act.startUB ];
//    [rv addObject:_act.duration];
//    [rv autorelease];
//    return rv;
//}
//-(ORUInt) nbUVars
//{
//    ORUInt nb = 0;
//    for (ORInt ii = 0; ii < _size._val; ii++) {
//        const ORInt i = _idx[ii];
//        if (!_alter[i].top.bound     ) nb++;
//        if (!_alter[i].startLB.bound ) nb++;
//        if (!_alter[i].duration.bound) nb++;
//    }
//    if (_act.isOptional && !_act.top.bound) nb++;
//    if (!_act.startLB.bound ) nb++;
//    if (!_act.duration.bound) nb++;
//    
//    return nb;
//}
//-(void) encodeWithCoder:(NSCoder *)aCoder
//{
//    assert(false);
//}
//-(id) initWithCoder:(NSCoder *)aDecoder
//{
//    assert(false);
//}
@end



@implementation CPTaskPrecedence

-(id) initCPTaskPrecedence: (id<CPTaskVar>) before after: (id<CPTaskVar>) after
{
   self = [super initCPCoreConstraint: [before engine]];
  
   _before = before;
   _after  = after;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_before bound] && ![_after bound]) {
      [_before whenChangeStartPropagate: self];
      [_after whenChangeEndPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   [_after updateStart: [_before ect]];
   [_before updateEnd: [_after lst]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_before];
   [rv addObject:_after];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end

@implementation CPOptionalTaskPrecedence

-(id) initCPOptionalTaskPrecedence: (id<CPTaskVar>) before after: (id<CPTaskVar>) after
{
   self = [super initCPCoreConstraint: [before engine]];
   
   _before = before;
   _after  = after;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_before bound] && ![_after bound]) {
      [_before whenChangeStartPropagate: self];
      [_after whenChangeEndPropagate: self];
      if ([_before isOptional])
         [_before whenPresentPropagate: self];
      if ([_after isOptional])
         [_after whenPresentPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   if ([_before isPresent])
      [_after updateStart: [_before ect]];
   if ([_after isPresent])
      [_before updateEnd: [_after lst]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_before];
   [rv addObject:_after];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end

@implementation CPTaskIsFinishedBy

-(id) initCPTaskIsFinishedBy: (id<CPTaskVar>) task : (id<CPIntVar>) date
{
   self = [super initCPCoreConstraint: [task engine]];
   
   _task = task;
   _date  = date;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_task bound] && ![_date bound]) {
      [_task whenChangeStartPropagate: self];
      [_date whenChangeMaxPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   if ([_task isPresent])
      [_date updateMin: [_task ect]];
   [_task updateEnd: [_date max]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_task];
   [rv addObject:_date];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end


@implementation CPTaskDuration

-(id) initCPTaskDuration: (id<CPTaskVar>) task : (id<CPIntVar>) duration
{
   self = [super initCPCoreConstraint: [task engine]];
   
   _task = task;
   _duration  = duration;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_task bound] && ![_duration bound]) {
      [_task whenChangeDurationPropagate: self];
      [_duration whenChangeBoundsPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   [_duration updateMin: [_task minDuration]];
   [_duration updateMax: [_task maxDuration]];
   [_task updateMinDuration: [_duration min]];
   [_task updateMaxDuration: [_duration max]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_task];
   [rv addObject:_duration];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end

@implementation CPTaskAddTransitionTime

-(id) initCPTaskAddTransitionTime:(id<CPTaskVar>) normal extended:(id<CPTaskVar>)extended time:(id<CPIntVar>)time
{
   self = [super initCPCoreConstraint: [normal engine]];
   
   _normal = normal;
   _extended = extended;
   _time  = time;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   [self propagate];
   if (![_normal bound] && ![_extended bound] && ![_time bound]) {
      [_normal whenChangeStartPropagate: self];
      [_normal whenChangeEndPropagate: self];
      [_extended whenChangeStartPropagate: self];
      [_extended whenChangeEndPropagate: self];
      [_time whenChangeMinPropagate: self];
   }
   return ORSuspend;
}
-(void) propagate
{
   [_normal updateStart: [_extended est]];
   [_extended updateStart: [_normal est]];
   [_normal updateEnd: [_extended lct] - [_time min]];
   [_extended updateEnd: [_normal lct] + [_time max]];
}
-(NSSet*) allVars
{
   ORInt size = 2;
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
   [rv addObject:_normal];
   [rv addObject:_extended];
   [rv addObject:_time];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   return 2;
}
@end

