/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPGroup.h"
#import "CPClosureEvent.h"
#import "CPConstraintI.h"
#import "CPEngineI.h"

@implementation CPGroup
-(id)init:(CPEngineI*) engine
{
   self = [super initCPCoreConstraint:engine];
   _engine = engine;
   for(ORInt i=0;i<NBPRIORITIES;i++)
      _closureQueue[i] = [[CPClosureQueue alloc] initClosureQueue:512];
   _valueClosureQueue = [[CPValueClosureQueue alloc] initValueClosureQueue:512];
   return self;
}
-(void)dealloc
{
   for(ORInt i=0;i<NBPRIORITIES;i++)
      [_closureQueue[i] release];
   [_valueClosureQueue release];
   [super dealloc];
}
-(void)add:(id<CPConstraint>)p
{
   [p setGroup:self];
}
-(void)setGroup:(id<CPGroup>)g
{
   assert(0);
}
-(id<CPGroup>)group
{
   return nil;
}
-(void) post
{
}
-(void)scheduleClosure:(CPClosureList*)evt
{
   [_closureQueue[evt->_priority] enQueue:evt->_trigger cstr:evt->_cstr];
}
-(void)scheduleValueClosure:(id<CPValueEvent>)evt
{
   [_valueClosureQueue enQueue:evt];
}
-(void) scheduleTrigger: (ORClosure) cb onBehalf:(id<CPConstraint>)c
{
    [_closureQueue[HIGHEST_PRIO] enQueue: cb cstr: c];
}
static inline ORStatus executeClosure(CPClosureEntry cb,id<CPConstraint>* last)
{
   *last = cb.cstr;
   if (cb.cb)
      cb.cb();
   else {
      CPCoreConstraint* cstr = cb.cstr;
      if (cstr->_todo == CPChecked)
         return ORSkip;
      else {
          cstr->_todo = CPChecked;
          cstr->_propagate(cstr,@selector(propagate));
      }
   }
   return ORSuspend;
}

-(ORStatus)propagate
{
   __block ORStatus status = ORSuspend;
   __block bool done = false;
   __block id<CPConstraint> last = nil;
   __block ORInt nbp = 0;
   return tryfail(^ORStatus{
      while (!done) {
         
         while (ISLOADED(_valueClosureQueue)) {
            id<CPValueEvent> evt = [_valueClosureQueue deQueue];
            nbp += [evt execute];
         }
         
         int p = HIGHEST_PRIO;
         while (p>=LOWEST_PRIO && !ISLOADED(_closureQueue[p]))
            --p;
         done = p < LOWEST_PRIO;
         while (!done) {
            status = executeClosure([_closureQueue[p] deQueue],&last);
            nbp += status !=ORSkip;
            if (ISLOADED(_valueClosureQueue))
               break;
            p = HIGHEST_PRIO;
            while (p >= LOWEST_PRIO && !ISLOADED(_closureQueue[p]))
               --p;
            done = p < LOWEST_PRIO;
         }
      }
      while (ISLOADED(_closureQueue[ALWAYS_PRIO])) {
         ORStatus as = executeClosure([_closureQueue[ALWAYS_PRIO] deQueue],&last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      [_engine incNbPropagation:nbp];
      return status;
   }, ^ORStatus{
      while (ISLOADED(_closureQueue[ALWAYS_PRIO])) {
         ORStatus as = executeClosure([_closureQueue[ALWAYS_PRIO] deQueue],&last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      for(ORInt p=NBPRIORITIES-1;p>=0;--p)
         [_closureQueue[p] reset];
      [_valueClosureQueue reset];
      [_engine incNbPropagation:nbp];
      [_engine setLastFailure:last];
      failNow();
      return ORSuspend;
   });
}
@end

@implementation CPBergeGroup
-(id)init:(CPEngineI*)engine
{
   self = [super initCPCoreConstraint:engine];
   _engine = engine;
   _max = 2;
   _inGroup = malloc(sizeof(id<CPConstraint>)*_max);
   _scanMap = malloc(sizeof(id<CPClosureList>)*_max);
   _nbIn = 0;
   return self;
}
-(void)dealloc
{
   _map += _low;
   free(_map);
   free(_scanMap);
   free(_inGroup);
   [super dealloc];
}
-(void)add:(id<CPConstraint>)p
{
   if (_nbIn == _max) {
      _inGroup = realloc(_inGroup,sizeof(id<CPConstraint>)*_max*2);
      _max <<= 1;
   }
   _inGroup[_nbIn++] = p;
   [p setGroup:self];
}
-(void) post
{
   _scanMap = realloc(_scanMap,sizeof(id<CPClosureList>)*_nbIn);
   ORInt low = MAXINT;
   ORInt up  = MININT;
   for(ORInt i=0;i<_nbIn;i++) {
      ORInt cid = [_inGroup[i] getId];
      low = cid < low ? cid : low;
      up = cid > up ? cid : up;
   }
   ORInt sz = up - low + 1;
   _low = low;
   _sz  = sz;
   _map = malloc(sizeof(ORInt)*sz);
   memset(_map,0,sizeof(ORInt)*sz);
   _map -= _low;
   for(ORInt i=0;i < _nbIn;i++) 
      _map[[_inGroup[i] getId]] = i;
   memset(_scanMap,0,sizeof(CPClosureList*)*_nbIn);
}
-(void)scheduleClosure:(CPClosureList*)evt
{
   ORInt cid = [evt->_cstr getId];
   _scanMap[_map[cid]] = evt;
}
-(void)scheduleValueClosure:(id<CPValueEvent>)evt
{
   assert(NO);
}
-(void) scheduleTrigger: (ORClosure) cb onBehalf:(id<CPConstraint>)c
{
    assert(NO);
}
-(ORStatus)propagate
{
   __block ORInt nbp = 0;
   __block id<CPConstraint> last = nil;
   return tryfail(^ORStatus{
      for(ORInt k=0;k<_nbIn;k++) {
         CPClosureList* evt = _scanMap[k];
         if (evt) {
            ORStatus status = executeClosure((CPClosureEntry){evt->_trigger,evt->_cstr},&last);
            nbp += status !=ORSkip;
         }
      }
      for(ORInt k=_nbIn-1;k>=0;k--) {
         CPClosureList* evt = _scanMap[k];
         if (evt) {
            ORStatus status = executeClosure((CPClosureEntry){evt->_trigger,evt->_cstr},&last);
            nbp += status !=ORSkip;
         }
      }
      memset(_scanMap,0,sizeof(CPClosureList*)*_nbIn);
      [_engine incNbPropagation:nbp];
      return ORSuspend;
   }, ^ORStatus{
      memset(_scanMap,0,sizeof(CPClosureList*)*_nbIn); // clear the queue
      [_engine incNbPropagation:nbp];
      [_engine setLastFailure:last];
      failNow();
      return ORSuspend;
   });
}
@end
