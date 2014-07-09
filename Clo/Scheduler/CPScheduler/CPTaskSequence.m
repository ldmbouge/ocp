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
#import <objcp/CPVar.h>
#import "CPTask.h"
#import "CPTaskSequence.h"

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
//   // Range of tasks
//   ORInt _low;
//   ORInt _up;
}
-(id) initCPTaskSequence: (id<CPTaskVarArray>) tasks
{   
   id<CPTaskVar> task0 = tasks[tasks.low];
   self = [super initCPCoreConstraint: [task0 engine]];
//   // TODO Changing the priority
//   _priority = LOWEST_PRIO + 3;
//   _tasks  = tasks;
//   
//   
//   _idempotent = true;
//   _dprec = true;
//   _nfnl  = true;
//   _ef    = false;
//   
//   _start0 = NULL;
//   _dur0   = NULL;
//   _idx   = NULL;
//   
//   _est         = NULL;
//   _lct         = NULL;
//   _dur_min     = NULL;
//   _task_id_est = NULL;
//   _task_id_ect = NULL;
//   _task_id_lst = NULL;
//   _task_id_lct = NULL;
//   
//   _size = (ORUInt) _tasks.count;
//   _low = _tasks.range.low;
//   _up = _tasks.range.up;
   
   return self;
}

-(void) dealloc
{
//   if (_start0 != NULL) free(_start0);
//   if (_dur0 != NULL) free(_dur0);
//   if (_idx != NULL) free(_idx);
   
   [super dealloc];
}
-(ORStatus) post
{
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
//   // Initial propagation
//   [self propagate];
//   
//   // Subscription of variables to the constraint
//   for (ORInt i = 0; i < _size; i++) {
//      [_tasks[i] whenChangePropagate: self];
//      if ([_tasks[i] isOptional])
//         [_tasks[i] whenPresentPropagate: self];
//   }
   return ORSuspend;
}
-(void) propagate
{
 
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
