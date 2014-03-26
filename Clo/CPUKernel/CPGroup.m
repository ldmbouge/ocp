/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPGroup.h"
#import "CPAC3Event.h"
#import "CPConstraintI.h"
#import "CPEngineI.h"

@implementation CPGroup
-(id)init:(CPEngineI*) engine
{
   self = [super initCPCoreConstraint:engine];
   _engine = engine;
   for(ORInt i=0;i<NBPRIORITIES;i++)
      _ac3[i] = [[CPAC3Queue alloc] initAC3Queue:512];
   _ac5 = [[CPAC5Queue alloc] initAC5Queue:512];
   return self;
}
-(void)dealloc
{
   for(ORInt i=0;i<NBPRIORITIES;i++)
      [_ac3[i] release];
   [_ac5 release];
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
-(void)scheduleAC3:(CPEventNode*)evt
{
   [_ac3[evt->_priority] enQueue:evt->_trigger cstr:evt->_cstr];
}
-(void)scheduleAC5:(id<CPAC5Event>)evt
{
   [_ac5 enQueue:evt];
}
static inline ORStatus executeAC3(AC3Entry cb,id<CPConstraint>* last)
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
         // AC5 manipulates the list
         while (AC5LOADED(_ac5)) {
            id<CPAC5Event> evt = [_ac5 deQueue];
            nbp += [evt execute];
         }
         // Processing AC3
         int p = HIGHEST_PRIO;
         while (p>=LOWEST_PRIO && !ISLOADED(_ac3[p]))
            --p;
         done = p < LOWEST_PRIO;
         while (!done) {
            status = executeAC3([_ac3[p] deQueue],&last);
            nbp += status !=ORSkip;
            if (AC5LOADED(_ac5))
               break;
            p = HIGHEST_PRIO;
            while (p >= LOWEST_PRIO && !ISLOADED(_ac3[p]))
               --p;
            done = p < LOWEST_PRIO;
         }
      }
      while (ISLOADED(_ac3[ALWAYS_PRIO])) {
         ORStatus as = executeAC3([_ac3[ALWAYS_PRIO] deQueue],&last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      [_engine incNbPropagation:nbp];
      return status;
   }, ^ORStatus{
      while (ISLOADED(_ac3[ALWAYS_PRIO])) {
         ORStatus as = executeAC3([_ac3[ALWAYS_PRIO] deQueue],&last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      for(ORInt p=NBPRIORITIES-1;p>=0;--p)
         [_ac3[p] reset];
      [_ac5 reset];
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
   _scanMap = malloc(sizeof(id<CPEventNode>)*_max);
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
   _scanMap = realloc(_scanMap,sizeof(id<CPEventNode>)*_nbIn);
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
   memset(_scanMap,0,sizeof(CPEventNode*)*_nbIn);
}
-(void)scheduleAC3:(CPEventNode*)evt
{
   ORInt cid = [evt->_cstr getId];
   _scanMap[_map[cid]] = evt;
}
-(void)scheduleAC5:(id<CPAC5Event>)evt
{
   assert(NO);
}
-(ORStatus)propagate
{
   __block ORInt nbp = 0;
   __block id<CPConstraint> last = nil;
   return tryfail(^ORStatus{
      for(ORInt k=0;k<_nbIn;k++) {
         CPEventNode* evt = _scanMap[k];
         if (evt) {
            ORStatus status = executeAC3((AC3Entry){evt->_trigger,evt->_cstr},&last);
            nbp += status !=ORSkip;
         }
      }
      for(ORInt k=_nbIn-1;k>=0;k--) {
         CPEventNode* evt = _scanMap[k];
         if (evt) {
            ORStatus status = executeAC3((AC3Entry){evt->_trigger,evt->_cstr},&last);
            nbp += status !=ORSkip;
         }
      }
      memset(_scanMap,0,sizeof(CPEventNode*)*_nbIn);
      [_engine incNbPropagation:nbp];
      return ORSuspend;
   }, ^ORStatus{
      memset(_scanMap,0,sizeof(CPEventNode*)*_nbIn); // clear the queue
      [_engine incNbPropagation:nbp];
      [_engine setLastFailure:last];
      failNow();
      return ORSuspend;
   });
}
@end
