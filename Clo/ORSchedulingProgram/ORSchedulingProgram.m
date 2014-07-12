/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORScheduler.h"
#import "ORSchedulingProgram.h"
#import <ORProgram/CPSolver.h>
#import <CPScheduler/CPScheduler.h>
#import <ORProgram/CPSolver.h>
#import <CPScheduler/CPTask.h>


@interface ORCPTaskVarSnapshot : NSObject<ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORInt     _start;
   ORInt     _end;
   ORInt     _present;
   ORInt     _absent;
   ORInt     _minDuration;
   ORInt     _maxDuration;
   ORBool    _bound;
}
-(ORCPTaskVarSnapshot*) initCPTaskVarSnapshot: (id<ORTaskVar>) t with: (id<CPCommonProgram>) solver;
-(NSString*) description;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation ORCPTaskVarSnapshot
-(ORCPTaskVarSnapshot*) initCPTaskVarSnapshot: (id<ORTaskVar>) t with: (id<CPProgram,CPScheduler>) solver
{
   self = [super init];
   _name = [t getId];
   _start = [solver est: t];
   _end = [solver ect: t];
   _minDuration = [solver minDuration: t];
   _maxDuration = [solver maxDuration: t];
   _present = [solver isPresent: t];
   _absent = [solver isAbsent: t];
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"task(%d,%d,%d,%d,%d,%d,%d)",_name,_start,_end,_minDuration,_maxDuration,_present,_absent];
   return buf;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORCPTaskVarSnapshot* other = object;
      if (_name == other->_name) {
         return _start == other->_start && _end == other->_end  && _minDuration == other->_minDuration &&
         _maxDuration == other->_maxDuration && _present == other->_present && _absent == other->_absent;
      }
      else
         return NO;
   } else
      return NO;
}
-(ORInt) intValue
{
   assert(false);
   return 0;
}
-(ORBool) boolValue
{
   assert(false);
   return 0;
}
-(ORFloat) floatValue
{
   assert(false);
   return 0;
}
-(NSUInteger) hash
{
   return (_name << 16) + _start * _end;
}
-(ORUInt) getId
{
   return _name;
}
- (void) encodeWithCoder: (NSCoder *) aCoder
{
   assert(false);
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   assert(false);
   return self;
}
-(ORInt) est
{
   return _start;
}
-(ORInt) ect
{
   return _start + _minDuration;
}
-(ORInt) lst
{
   return _end - _minDuration;
}
-(ORInt) lct
{
   return _end;
}
-(ORInt) minDuration
{
   return _minDuration;
}
-(ORInt) maxDuration
{
   return _maxDuration;
}
-(ORInt) isAbsent
{
   return _absent;
}
-(ORInt) isPresent
{
   return _present;
}
@end

@implementation ORCPTakeSnapshot (ORScheduler)
-(void) visitTask: (id<ORTaskVar>) v
{
   _snapshot = [[ORCPTaskVarSnapshot alloc] initCPTaskVarSnapshot: v with: _solver];
}
@end


@implementation CPSolver (CPScheduler)
//-(void) labelActivities: (id<ORActivityArray>) act
//{
//   for (ORInt i = act.range.low; i <= act.range.up; i++)
//      [self labelActivity:act[i]];
//}
//
//-(void) labelActivity: (id<ORActivity>) act
//{
//   if ((act.type & 1) == 1) {
//      [self label: act.top];
//   }
//   [self label: act.startLB ];
//   [self label: act.duration];
//   if (act.type > 1) {
//      [self labelActivities:act.composition];
//   }
//}

-(void) setTimes: (id<ORTaskVarArray>) act
{
   id<ORIntRange> R = act.range;
   ORInt low = R.low;
   ORInt up = R.up;
   ORInt m = FDMAXINT;
   ORInt im = 0;
   ORInt found = FALSE;
   ORInt hasPostponedActivities = FALSE;
   
   // optional activities
   //   for (ORInt k = low; k <= up; k++) {
   //      if ((act[k].type & 1) == 1)
   //         [self label: act[k].top];
   //   }
   
   id<ORTrailableIntArray> postponed = [ORFactory trailableIntArray: [self engine] range: R value: 0];
   id<ORTrailableIntArray> ptime = [ORFactory trailableIntArray: [self engine] range: R value: 0];
   
   while (true) {
      found = FALSE;
      m = FDMAXINT;
      hasPostponedActivities = FALSE;
      ORInt lsd = FDMAXINT;
      for(ORInt k = low; k <= up; k++) {
         
         if (![self boundActivity: act[k]]) {
            if (![[postponed at: k] value]) {
               ORInt vm = [self est:  act[k]];
               found = TRUE;
               if (vm < m) {
                  m = vm;
                  im = k;
               }
            }
            else {
               hasPostponedActivities = TRUE;
               ORInt vm = [self lst: act[k]];
               if (vm < lsd)
                  lsd = vm;
            }
         }
      }
      if (!found) {
         if (hasPostponedActivities)
            [[self explorer] fail];
         else
            break;
      }
      if (lsd <= m)
         [[self explorer] fail];
      
      for(ORInt k = low; k <= up; k++)
         if ([[postponed at: k] value])
            if ([self ect: act[k]] <= m)
               [[self explorer] fail];
      
      
      [self try:
       ^() {
          
          [self labelStart: act[im] with: m];
//          NSLog(@"labelStart[%i] %@ with %d",im,act[im],m);
          for(ORInt k = low; k <= up; k++)
             if ([[postponed at: k] value])
                if ([self est: act[k]] > [[ptime at: k] value])
                   [[postponed at: k] setValue: 0];
          
       }
             or:
       ^() {
          [[postponed at: im]  setValue: 1];
          [[ptime at: im] setValue: m];
       }
       ];
   }
}

//-(void) labelTimes: (id<ORActivityArray>) act
//{
//   id<ORIntRange> R = act.range;
//   ORInt low = R.low;
//   ORInt up = R.up;
//   ORInt m = FDMAXINT;
//   ORInt im = FDMAXINT;
//   ORInt found = FALSE;
//   while (true) {
//      found = FALSE;
//      m = FDMAXINT;
//      for (ORInt k = low; k <= up; k++) {
//         if ((act[k].type & 1) == 1)
//            [self label: act[k].top];
//      }
//      for(ORInt k = low; k <= up; k++) {
//         ORInt vm = [self min: act[k].startLB];
//         if (![self bound: act[k].startLB]) {
//            found = TRUE;
//            if (vm < m) {
//               m = vm;
//               im = k;
//            }
//         }
//      }
//      if (!found)
//         break;
//      [self try: ^() { [self label: act[im].startLB with: m]; } or: ^() { [self diff: act[im].startLB with: m]; } ];
//   }
//}

-(void) sequence: (id<ORIntVarArray>) succ by: (ORInt2Float) o
{
   ORInt low = succ.range.low;
   ORInt size = succ.range.size - 1;
   ORInt k = low;
   for(ORInt j = 1; j <= size; j++) {
      [self label: succ[k] by: o];
      k = [self intValue: succ[k]];
   }
}
-(void) printSequence: (id<ORIntVarArray>) succ
{
   ORInt low = succ.range.low;
   ORInt up = succ.range.up;
   ORInt k = low;
   while (true) {
      printf("%d -> ",k);
      if (k == up+1)
         break;
      if (![self bound: succ[k]])
         break;
      k = [self intValue: succ[k]];
   }
   printf("\n");
}
-(void) sequence: (id<ORIntVarArray>) succ by: (ORInt2Float) o1 then: (ORInt2Float) o2
{
   ORInt low = succ.range.low;
   ORInt up = succ.range.up;
   ORInt size = succ.range.size - 1;
   ORInt k = low;
   for(ORInt j = 1; j <= size; j++) {
      assert(0 <= k && k <= up + 1);
//      [self printSequence: succ];
//      NSLog(@"succ[%d] = %@",k,_gamma[succ[k].getId]);
      [self label: succ[k] by: o1 then: o2];
      k = [self intValue: succ[k]];
      if (k == up+1 && j <= size)
         [[self explorer] fail];
   }
}
-(ORInt) est: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) est];
}
-(ORInt) ect: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) ect];
}
-(ORInt) lst: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) lst];
}
-(ORInt) lct: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) lct];
}
-(ORBool) boundActivity: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) bound];
}
-(ORInt) minDuration: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) minDuration];
}
-(ORInt) maxDuration: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) maxDuration];
}
-(ORInt) isPresent: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) isPresent];
}
-(ORInt) isAbsent: (id<ORTaskVar>) task
{
   return [((id<CPTaskVar>)_gamma[task.getId]) isAbsent];
}
-(void) updateStart: (id<ORTaskVar>) task with: (ORInt) newStart
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) updateStart: newStart]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) updateEnd: (id<ORTaskVar>) task with: (ORInt) newEnd
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) updateEnd: newEnd]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) updateMinDuration: (id<ORTaskVar>) task with: (ORInt) newMinDuration
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) updateMinDuration: newMinDuration]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) updateMaxDuration: (id<ORTaskVar>) task with: (ORInt) newMaxDuration
{
    ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) updateMaxDuration: newMaxDuration]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) labelStart: (id<ORTaskVar>) task with: (ORInt) start
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) labelStart: start]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) labelEnd: (id<ORTaskVar>) task with: (ORInt) end
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) labelEnd: end]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) labelDuration: (id<ORTaskVar>) task with: (ORInt) duration
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) labelDuration: duration]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(void) labelPresent: (id<ORTaskVar>) task with: (ORBool) present
{
   ORStatus status = [[self engine] enforce:^{ [((id<CPTaskVar>) _gamma[task.getId]) labelPresent: present]; }];
   if (status == ORFailure)
      [[self explorer] fail];
   [ORConcurrency pumpEvents];
}
-(ORInt) globalSlack: (id<ORTaskDisjunctive>) d
{
   ORInt gs = [((CPDisjunctive*)_gamma[d.getId]) globalSlack];
//   NSLog(@"Global slack: %d",gs);
   return gs;
}
-(ORInt) localSlack: (id<ORTaskDisjunctive>) d
{
   ORInt gs = [((CPDisjunctive*)_gamma[d.getId]) localSlack];
   //   NSLog(@"Global slack: %d",gs);
   return gs;
}

-(NSString*) description: (id<ORObject>) o
{
   return [_gamma[o.getId] description];
}
@end

