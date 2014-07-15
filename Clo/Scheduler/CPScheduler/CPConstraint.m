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
//@implementation CPAlternative {
//    ORInt * _idx;
//    TRInt   _size;
//}
//-(id) initCPAlternative: (id<CPActivity>) act alternatives: (id<CPActivityArray>) alter
//{
//    self = [super initCPCoreConstraint:act.startLB.engine];
//    
//    _act   = act;
//    _alter = alter;
//    _idx   = NULL;
//    
//    NSLog(@"Create alternative constraint\n");
//    
//    return self;
//}
//-(void) dealloc
//{
//    if (_idx != NULL) free(_idx);
//    [super dealloc];
//}
//-(ORStatus) post
//{
//    // Initialise trailed parameters
//    _size = makeTRInt(_trail, (ORInt)_alter.count);
//    
//    // Allocate memory
//    _idx = malloc(_alter.count * sizeof(ORInt));
//    
//    // Check whether memory allocation was successful
//    if (_idx == NULL) {
//        @throw [[ORExecutionError alloc] initORExecutionError: "CPAlternative: Out of memory!"];
//    }
//    
//    // Initialise misc
//    for (ORInt i = 0; i < _alter.count; i++) {
//        _idx[i] = i + _alter.range.low;
//    }
//    
//    // Initial propagation
//    [self propagate];
//    
//    // Subscription of variables to the constraint
//    for (ORInt i = _alter.range.low; i <= _alter.range.up; i++) {
//        assert(_alter[i].isOptional);
//        if (_alter[i].top.max == 0) continue;
//        [_alter[i].top whenBindPropagate:self priority:LOWEST_PRIO];
//        if (!_alter[i].startLB.bound)
//            [_alter[i].startLB whenChangeMinDo:^{
//                if (_alter[i].startLB.min > _act.startLB.min)
//                    [self propAlterStartMin];
//            } priority:LOWEST_PRIO + 1 onBehalf:self];
//        if (!_alter[i].startUB.bound)
//            [_alter[i].startUB whenChangeMaxDo:^{
//                if (_alter[i].startLB.max < _act.startLB.max)
//                    [self propAlterStartMax];
//            } priority:LOWEST_PRIO + 1 onBehalf:self];
//        if (!_alter[i].duration.bound) {
//            [_alter[i].duration whenChangeMinDo:^{
//                if (_alter[i].duration.min > _act.duration.min)
//                    [self propAlterDurMin];
//            } priority:LOWEST_PRIO + 1 onBehalf:self];
//            [_alter[i].duration whenChangeMaxDo:^{
//                if (_alter[i].duration.max < _act.duration.max)
//                    [self propAlterDurMax];
//            } priority:LOWEST_PRIO + 1 onBehalf:self];
//        }
//    }
//    if (_act.isOptional && !_act.top.bound)
//        [_act.top whenBindDo:^{[self bindActivity];} priority:LOWEST_PRIO onBehalf:self];
//    if (!_act.startLB.bound)
//        [_act.startLB whenChangeMinDo:^{
//            for (ORInt ii = 0; ii < _size._val; ii++)
//                [_alter[_idx[ii]] updateStartMin:_act.startLB.min];
//        } priority:LOWEST_PRIO + 1 onBehalf:self];
//    if (!_act.startUB.bound)
//        [_act.startUB whenChangeMaxDo:^{
//            for (ORInt ii = 0; ii < _size._val; ii++)
//                [_alter[_idx[ii]] updateStartMax:_act.startUB.max];
//        } priority:LOWEST_PRIO + 1 onBehalf:self];
//    if (!_act.duration.bound) {
//        [_act.duration whenChangeMinDo:^{[self propActDurMin];} priority:LOWEST_PRIO + 1 onBehalf:self];
//        [_act.duration whenChangeMaxDo:^{[self propActDurMax];} priority:LOWEST_PRIO + 1 onBehalf:self];
//    }
//
//    return ORSuspend;
//}
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
//@end
//


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
   [_extended updateEnd: [_normal lct] + [_time min]];
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

