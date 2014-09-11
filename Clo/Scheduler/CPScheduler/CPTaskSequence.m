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
   ORInt _low;
   ORInt _up;
   ORInt _size;
   id<ORTRIntArray> _assigned;
}
-(id) initCPTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
{
    // NOTE temporary check for optional task, can be removed once the propagator
    // is extended for optional tasks
    assert(^ORBool() {
        for (ORInt i = tasks.low; i <= tasks.up; i++) {
            if (![tasks[i] isMemberOfClass: [CPTaskVar class]])
                return false;
        }
        return true;
    });
   id<CPTaskVar> task0 = tasks[tasks.low];
   _engine = [task0 engine];
   self = [super initCPCoreConstraint: _engine];
   _tasks = tasks;
   _succ = succ;
   _assigned = [CPFactory TRIntArray: _engine range: _succ.range];
   
   _priority = LOWEST_PRIO;

   _size = (ORUInt) _tasks.count;
   _low = _tasks.range.low;
   _up = _tasks.range.up;
   
   assert(_low == _succ.low + 1);
    NSLog(@"Create constraint CPTaskSequence\n");
   return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
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
