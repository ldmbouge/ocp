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

@implementation CPTaskSequence {
   // Attributs of tasks
//   CPIntVar **  _start0;   // Start times
//   CPIntVar **  _dur0;     // Durations
//   ORInt    *   _idx;      // Indices of activities
//   
//   ORUInt       _size;     // Number of considered tasks
//   TRInt        _cIdx;     // Size of present activities
//   TRInt        _uIdx;     // Size of present and non-present activities
//   
//   // Variables needed for the propagation
//   // NOTE: Memory is dynamically allocated by alloca/1 each time the propagator
//   //      is called.
//   ORInt * _est;           // Earliest start times
//   ORInt * _lct;           // Latest completion times
//   ORInt * _dur_min;       // Minimal durations
//   ORInt * _new_est;       // New earliest start times
//   ORInt * _new_lct;       // New latest completion times
//   ORInt * _task_id_est;   // Task's ID sorted according the earliest start times
//   ORInt * _task_id_ect;   // Task's ID sorted according the earliest completion times
//   ORInt * _task_id_lst;   // Task's ID sorted according the latest start times
//   ORInt * _task_id_lct;   // Task's ID sorted according the latest completion times
//   
//   // Filtering options
//   ORBool _idempotent;
//   ORBool _dprec;          // Detectable precedences filtering
//   ORBool _nfnl;           // Not-first/not-last filtering
//   ORBool _ef;             // Edge-finding
//   
//   // Additional informations
//   TRInt _global_slack; // Global slack of the disjunctive constraint
//   
   // Range of tasks
   
   ORInt _low;
   ORInt _up;
   ORInt _size;
   id<CPEngine> _engine;
   
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
   [_engine addInternal:[CPFactory alldifferent: _engine over: _succ]];
//   _cIdx         = makeTRInt(_trail, 0     );
//   _uIdx         = makeTRInt(_trail, _size );
//   _global_slack = makeTRInt(_trail, MAXINT);
//   
//   // Allocating memory
//   _start0 = malloc(_size * sizeof(CPIntVar*));
//   _dur0   = malloc(_size * sizeof(CPIntVar*));
//   _idx    = malloc(_size * sizeof(ORInt    ));
//   
//   // Checking whether memory allocation was successful
//   if (_start0 == NULL || _dur0 == NULL || _idx == NULL) {
//      @throw [[ORExecutionError alloc] initORExecutionError: "CPTaskDisjunctive: Out of memory!"];
//   }
//   
//   // [pvh: can we remove this index?]
//   for (ORInt i = 0; i < _size; i++)
//      _idx[i] = i + _tasks.low;
//
   
   for(ORInt k = _low; k <= _up; k++)
      [_assigned set: 0 at: k];
      
   // Initial propagation
   [self propagate];

   // Subscription of variables to the constraint
   for (ORInt i = _low; i <= _up; i++)
      [_tasks[i] whenChangePropagate: self];
   for (ORInt i = _low-1; i <= _up; i++)
      [_succ[i] whenBindPropagate: self];
   return ORSuspend;
}
-(void) propagate
{
   ORInt i = 0;
   ORInt start = -MAXINT;
   while (true) {
      if (![_succ[i] bound])
         break;
      ORInt next = [_succ[i] value];
      if (![_assigned at: i]) {
         [_assigned set: 1 at: i];
         if (i != 0 && next != _up + 1)
            [_engine addInternal: [CPFactory constraint: _tasks[i] precedes: _tasks[next]]];
      }
      if (next == _up + 1)
         break;
      i = next;
      [_tasks[next] updateStart: start];
      start = [_tasks[next] ect];
   }
   for(ORInt k = _low; k <= _up; k++) {
      if (k != i && ![_assigned at: k])
         [_tasks[k] updateStart: start];
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
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   assert(false);
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   assert(false);
}
@end
