/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPConstraint.h>

#import <objcp/CPVar.h>
#import "CPTask.h"
#import "CPTaskI.h"
#import "CPTaskSequence.h"
#import "CPFactory.h"

// [pvh: no optional tasks in this one at this point]
// [pvh: need to generalize that]
// [pvh: need to add the constraint on the end date
// [pvh: just need to prune the latest task in the path

@implementation CPTaskSequence {
   id<CPEngine> _engine;
   ORInt _low;      // Smallest index in the array '_tasks'
   ORInt _up;       // Largest index in the array '_tasks'
   ORInt _size;     // Number of tasks (size of the array '_tasks')
   id<ORTRIntArray> _assigned;
}
-(id) initCPTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
{
    NSLog(@"Create constraint CPTaskSequence\n");

    // NOTE temporary check for optional task, can be removed once the propagator
    // is extended for optional tasks
    assert(^ORBool() {
        for (ORInt i = tasks.low; i <= tasks.up; i++) {
            if ([tasks[i] isOptional])
                return false;
        }
        return true;
    }());
    assert(tasks.low == _succ.low + 1);
    assert(tasks.up  == _succ.up     );
    
    _engine = [tasks[tasks.low] engine];

    self = [super initCPCoreConstraint: _engine];
    
    _tasks    = tasks;
    _succ     = succ;
    _assigned = [CPFactory TRIntArray: _engine range: _succ.range];
    
    _priority = LOWEST_PRIO;
    
    _size = (ORUInt) _tasks.count;
    _low  = _tasks.range.low;
    _up   = _tasks.range.up;
    
    return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
    // Each task has a different successor
   [_engine addInternal:[CPFactory alldifferent: _engine over: _succ annotation: ValueConsistency]];
   [_engine addInternal:[CPFactory path: _succ]];
   for(ORInt k = _low; k <= _up; k++)
      [_assigned set: 0 at: k];
      
   
   // precedence constraints
   for(ORInt k = _low; k <= _up; k++) {
      if ([_succ[k] bound]) {
         ORInt next = [_succ[k] value];
         if (next != _up + 1)
            [_engine addInternal: [CPFactory constraint: _tasks[k] precedes: _tasks[next]]];
      }
      else {
         [_succ[k] whenBindDo: ^() {
            ORInt next = [_succ[k] value];
            if (next != _up + 1)
               [_engine addInternal: [CPFactory constraint: _tasks[k] precedes: _tasks[next]]];
         }
                     onBehalf: self];
      }
   }

   // Subscription of variables to the constraint
   for (ORInt i = _low-1; i <= _up  ; i++)
      [_succ[i] whenBindPropagate: self];
   for (ORInt i = _low; i <= _up; i++) {
      [_tasks[i] whenChangeStartPropagate: self];
      [_tasks[i] whenChangeEndPropagate: self];
   }
   
   // Initial propagation
   [self propagate];

   return ORSuspend;
}

-(void) propagate
{
   ORInt i = 0;
   ORInt start = -MAXINT;
   ORInt nb = 0;
   while (true) {
      if (![_succ[i] bound])
         break;
      nb++;
      ORInt next = [_succ[i] value];
      if (![_assigned at: i])
         [_assigned set: 1 at: i];
      i = next;   
      if (next == _up + 1)
         break;
      [_tasks[next] updateStart: start];
      start = [_tasks[next] ect];
   }
    assert(0 <= nb && nb <= _size + 1);
   ORInt maxLct = -MAXINT;
   ORInt minEct = MAXINT;
   ORInt duration = 0;
   for(ORInt k = _low; k <= _up; k++) {
      if (k != i && ![_assigned at: k]) {
         [_tasks[k] updateStart: start];
         ORInt lct = [_tasks[k] lct];
         if (lct > maxLct)
            maxLct = lct;
         ORInt ect = [_tasks[k] ect];
         if (ect < minEct)
            minEct = ect;
         duration += [_tasks[k] minDuration];
      }
   }
   if (nb <= _size) {
      if (i == _up + 1)
         failNow();
      [_succ[i] remove: _up + 1];
   }
   if (i != _up + 1) {
      ORInt min = [_succ[i] min];
      ORInt max = [_succ[i] max];
      for(ORInt k = min; k <= max; k++) {
         if ([_succ[i] member: k]) {
            if (k != _up + 1) {
               if ([_tasks[k] est] + duration > maxLct) {
                  [_succ[i] remove: k];
                  [_tasks[k] updateStart: minEct];
               }
            }
         }
      }
      if (i != 0)
         [_tasks[i] updateEnd: maxLct - duration];
   }
}

-(NSSet*) allVars
{
   NSUInteger nb = [_tasks count] + [_succ count];
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:nb];
   for(ORInt i = _low; i <= _up; i++)
      [rv addObject:_tasks[i]];
   for(ORInt i = _succ.low; i <= _succ.up; i++)
      [rv addObject:_succ[i]];
   [rv autorelease];
   return rv;
}
-(ORUInt) nbUVars
{
   ORUInt nb = 0;
   for(ORInt i = _low; i <= _up; i++)
      if (![_tasks[i] bound])
         nb++;
   for(ORInt i = _succ.low; i <= _succ.up; i++)
       if (![_succ[i] bound])
          nb++;
   return nb;
   return 0;
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"CPTaskSequence"];
}
@end


@implementation CPOptionalTaskSequence {
    id<CPEngine> _engine;
    ORInt   _low;       // Smallest index in the array '_tasks'
    ORInt   _up;        // Largest index in the array '_tasks'
    ORInt   _size;      // Number of tasks (size of the array '_tasks')
    TRInt   _last;      // Index of first absent task or sink index
    id<ORTRIntArray> _assigned;
}
-(id) initCPTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
{
    NSLog(@"Create constraint CPTaskSequence\n");
    
    assert(tasks.low == _succ.low + 1);
    assert(tasks.up  == _succ.up     );
    
    _engine = [tasks[tasks.low] engine];
    
    self = [super initCPCoreConstraint: _engine];
    
    _tasks    = tasks;
    _succ     = succ;
    _assigned = [CPFactory TRIntArray: _engine range: _succ.range];
    
    _priority = LOWEST_PRIO;
    
    _size = (ORUInt) _tasks.count;
    _low  = _tasks.range.low;
    _up   = _tasks.range.up;
    _last = makeTRInt(_trail, _up + 1);
    
    return self;
}

-(void) dealloc
{
    [super dealloc];
}
-(ORStatus) post
{
    // Each task has a different successor
    [_engine addInternal:[CPFactory alldifferent: _engine over: _succ annotation: ValueConsistency]];
    [_engine addInternal:[CPFactory path: _succ]];
    for(ORInt k = _low; k <= _up; k++)
        [_assigned set: 0 at: k];

    // precedence constraints
    for(ORInt k = _low; k <= _up; k++) {
        if ([_succ[k] bound])
            [self postPrecedenceConstraint:k];
        else
            [_succ[k] whenBindDo: ^(){[self postPrecedenceConstraint:k];} onBehalf: self];
    }
    
    // Subscription of variables to the constraint
    for (ORInt i = _low - 1; i <= _up; i++)
        [_succ[i] whenBindPropagate: self];
    for (ORInt i = _low; i <= _up; i++) {
        if (![_tasks[i] isAbsent]) {
            [_tasks[i] whenChangeStartPropagate: self];
            [_tasks[i] whenChangeEndPropagate: self];
            if (![_tasks[i] isPresent]) {
                [_tasks[i] whenAbsentDo:^(){[self propagateAbsent:i];} priority:_priority + 1 onBehalf:self];
                [_tasks[i] whenPresentDo:^(){[self propagatePresence:i];} priority:_priority + 1 onBehalf:self];
            }
        }
    }
    
    // Initial propagation
    [self propagate];
    
    return ORSuspend;
}

-(void) propagate
{
    // Absent tasks are pushed to the end of the chain
    NSMutableArray * removeVals = [[NSMutableArray alloc] initWithCapacity:4];
    ORInt last = _last._val;
    for (ORInt k = _low; k <= _up; k++) {
        if (![_assigned at: k] && [_tasks[k] isAbsent]) {
            [_succ[k] bind:last];
            [_assigned set: 1 at: k];
            [removeVals addObject:@(last)];
            last = k;
        }
    }
    // Update trail integer
    if (last != _last._val)
        assignTRInt(&(_last), last, _trail);
    // Removal of invalid values
    for (ORInt j = _low - 1; j <= _up; j++) {
        if (![_assigned at: j] && ![_tasks[j] isAbsent]) {
            for (ORInt k = 0; k < [removeVals count]; k++)
                [_succ[j] remove: [removeVals[k] intValue]];
        }
    }
    
    // Updating start times
    ORInt i = 0;
    ORInt start = -MAXINT;
    ORInt nb = 0;
    while (true) {
        if (![_succ[i] bound] || (i > 0 && [_tasks[i] isAbsent]))
            break;
        nb++;
        ORInt next = [_succ[i] value];
        if (![_assigned at: i])
            [_assigned set: 1 at: i];
        i = next;
        if (next == _up + 1)
            break;
        if (i == 0 || [_tasks[i] isPresent])
            [_tasks[next] updateStart: start];
        if ([_tasks[next] isPresent])
            start = [_tasks[next] ect];
    }
    assert(0 <= nb && nb <= _size + 1);
    ORInt maxLct = -MAXINT;
    ORInt minEct = MAXINT;
    ORInt duration = 0;
    for(ORInt k = _low; k <= _up; k++) {
        if (k != i && ![_assigned at: k] && [_tasks[k] isPresent]) {
            [_tasks[k] updateStart: start];
            ORInt lct = [_tasks[k] lct];
            if (lct > maxLct)
                maxLct = lct;
            ORInt ect = [_tasks[k] ect];
            if (ect < minEct)
                minEct = ect;
            duration += [_tasks[k] minDuration];
        }
    }
    if (nb <= _size) {
        if (i == _up + 1)
            failNow();
        [_succ[i] remove: _up + 1];
    }
    if (i != _up + 1) {
        ORInt min = [_succ[i] min];
        ORInt max = [_succ[i] max];
        for(ORInt k = min; k <= max; k++) {
            if ([_succ[i] member: k]) {
                if (k != _up + 1 && [_tasks[k] isPresent]) {
                    if ([_tasks[k] est] + duration > maxLct) {
                        [_succ[i] remove: k];
                        [_tasks[k] updateStart: minEct];
                    }
                }
            }
        }
        if (i != 0)
            [_tasks[i] updateEnd: maxLct - duration];
    }
}
-(void) propagateAbsent: (ORInt) k
{
    if ([_succ[k] bound]) {
        const ORInt next = [_succ[k] value];
        if (next != _up + 1)
            [_tasks[next] labelPresent:FALSE];
    }
}
-(void) propagatePresence: (ORInt) k
{
    for (ORInt i = _low; i <= _up; i++) {
        if (i != k && [_succ[i] bound] && k == [_succ[i] value])
            [_tasks[i] labelPresent:TRUE];
    }
}
-(void) postPrecedenceConstraint: (ORInt) k
{
    ORInt next = [_succ[k] value];
    if (next != _up + 1) {
        if ([_tasks[next] isPresent]) {
            [_tasks[k] labelPresent:TRUE];
            [_engine addInternal: [CPFactory constraint: _tasks[k] precedes: _tasks[next]]];
        }
        else if ([_tasks[k] isAbsent])
            [_tasks[next] labelPresent:FALSE];
        else if (![_tasks[next] isAbsent])
            [_engine addInternal: [CPFactory constraint: _tasks[k] optionalPrecedes: _tasks[next]]];
    }
}
-(NSSet*) allVars
{
    NSUInteger nb = [_tasks count] + [_succ count];
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:nb];
    for(ORInt i = _low; i <= _up; i++)
        [rv addObject:_tasks[i]];
    for(ORInt i = _succ.low; i <= _succ.up; i++)
        [rv addObject:_succ[i]];
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    ORUInt nb = 0;
    for(ORInt i = _low; i <= _up; i++)
        if (![_tasks[i] bound])
            nb++;
    for(ORInt i = _succ.low; i <= _succ.up; i++)
        if (![_succ[i] bound])
            nb++;
    return nb;
    return 0;
}
-(NSString*) description
{
    return [NSString stringWithFormat:@"CPTaskSequence"];
}
@end
