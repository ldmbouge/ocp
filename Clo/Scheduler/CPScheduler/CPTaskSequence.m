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
   id<CPTaskVar> task0 = tasks[tasks.low];
   _engine = [task0 engine];
   self = [super initCPCoreConstraint: _engine];
   _tasks = tasks;
   _succ = succ;
   _assigned = [CPFactory TRIntArray: _engine range: _succ.range];
   
   _priority = HIGHEST_PRIO-1;

   _size = (ORUInt) _tasks.count;
   _low = _tasks.range.low;
   _up = _tasks.range.up;
   
   assert(_low == _succ.low + 1);
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
   for (ORInt i = _low-1; i <= _up; i++)
      [_succ[i] whenBindPropagate: self];
   
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
   ORInt duration = 0;
   for(ORInt k = _low; k <= _up; k++) {
      if (k != i && ![_assigned at: k]) {
         [_tasks[k] updateStart: start];
         ORInt lct = [_tasks[k] lct];
         if (lct > maxLct)
            maxLct = lct;
         duration += [_tasks[k] minDuration];
      }
   }
   if (nb <= _size) {
      if (i == _up + 1)
         failNow();
//      NSLog(@"_succ[%d] = %@",i,_succ[i]);
//      NSLog(@"_succ[%d] = %@",i,_succ[i]);
      [_succ[i] remove: _up + 1];
   }
   if (i != _up + 1) {
      ORInt min = [_succ[i] min];
      ORInt max = [_succ[i] max];
      for(ORInt k = min; k <= max; k++) {
         if ([_succ[i] member: k] && k != _up + 1) {
            if ([_tasks[k] est] + duration > maxLct)
               [_succ[i] remove: k];
         }
      }
   }
}

-(NSSet*) allVars
{
//   NSUInteger nb = 2 * _size;
//   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:nb];
//   for(ORInt i = _low; i <= _up; i++)
//      [rv addObject:_tasks[i]];
//   [rv autorelease];
//   return rv;
   return 0;
}
-(ORUInt) nbUVars
{
//   ORUInt nb = 0;
//   for(ORInt i = _low; i <= _up; i++)
//      if ([_tasks[i] bound])
//         nb++;
//   return nb;
   return 0;
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"CPTaskSequence"];
}
@end
