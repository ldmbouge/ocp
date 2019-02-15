/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPGroup.h"
#import "CPClosureEvent.h"
#import "CPConstraintI.h"
#import "CPEngineI.h"

@implementation CPGroup {
   CPEngineI*               _engine;
   CPValueClosureQueue*     _valueClosureQueue;
   ORInt                    _max;
   id<CPConstraint>*        _inGroup;
   ORInt                    _nbIn;
   CPClosureQueue*          _closureQueue[NBPRIORITIES];
}
-(id)init:(CPEngineI*) engine
{
   self = [super initCPCoreConstraint:engine];
   _engine = engine;
   for(ORInt i=0;i<NBPRIORITIES;i++)
      _closureQueue[i] = [[CPClosureQueue alloc] initClosureQueue:512];
   _valueClosureQueue = [[CPValueClosureQueue alloc] initValueClosureQueue:512];
   _max = 2;
   _nbIn = 0;
   _inGroup = malloc(sizeof(id<CPConstraint>)*_max);
   return self;
}
-(void)dealloc
{
   for(ORInt i=0;i<NBPRIORITIES;i++)
      [_closureQueue[i] release];
   [_valueClosureQueue release];
   free(_inGroup);
   [super dealloc];
}
-(id<ORTrail>) trail
{
   return [_engine trail];
}
-(id) trackMutable: (id) obj
{
   return [_engine trackMutable:obj];
}
-(id) trackImmutable: (id) obj
{
   return [_engine trackImmutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_engine trackVariable:obj];
}
-(id) trackObjective:(id) obj
{
   return [_engine trackObjective:obj];
}
-(id) trackConstraintInGroup:(id) cg
{
   return [_engine trackConstraintInGroup:cg];
}
-(ORStatus)add:(id<CPConstraint>)p
{
   [p setGroup:self];
   if (_nbIn >= _max) {
      _inGroup = realloc(_inGroup,sizeof(id<CPConstraint>)* _max * 2);
      _max *= 2;
   }
   _inGroup[_nbIn++] = p;
   [_engine assignIdToConstraint:p];
   return ORSuspend;
}
-(void)assignIdToConstraint:(id<ORConstraint>)c
{
   [_engine assignIdToConstraint:c];
}
-(void) enumerateWithBlock:(void(^)(ORInt,id<ORConstraint>))block
{
   for(ORInt i = 0;i <_nbIn;i++)
      block(i,_inGroup[i]);
}
-(void)setGroup:(id<CPGroup>)g
{
   [super setGroup:g];
}
-(id<CPGroup>)group
{
   return [super group];
}
-(void) post
{
   for(ORInt i=0;i<_nbIn;i++)
      [_inGroup[i] post];
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
-(void)incNbPropagation:(ORUInt)add
{
   [_engine incNbPropagation:add];
}
-(ORInt) size
{
   return _nbIn;
}
typedef id (*SELPROTO)(id,SEL,...);

static inline ORStatus executeClosure(ORClosure cb,id<CPConstraint> forCstr,id<CPConstraint>* last)
{
   *last = forCstr;
   if (cb)
      cb();
   else {
      CPCoreConstraint* cstr = forCstr;
      if (cstr->_todo == CPChecked || cstr->_active._val == 0)
         return ORSkip;
      else {
         cstr->_todo = CPChecked;
         ((SELPROTO)cstr->_propagate)(cstr,@selector(propagate));
      }
   }
   return ORSuspend;
}

-(void)propagate
{
   __block ORStatus status = ORSuspend;
   __block bool done = false;
   __block id<CPConstraint> last = nil;
   __block ORInt nbp = 0;
   tryfail(^ORStatus{
      ORClosure cb;
      id<CPConstraint> forCstr;
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
            [_closureQueue[p] deQueue:&cb forCstr:&forCstr];
            status = executeClosure(cb,forCstr,&last);
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
         [_closureQueue[ALWAYS_PRIO] deQueue:&cb forCstr:&forCstr];
         ORStatus as = executeClosure(cb,forCstr,&last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      [_engine incNbPropagation:nbp];
      ORBool allEntailed = true;
      for(ORInt k = 0;k < _nbIn && allEntailed;k++) {
         allEntailed = allEntailed && [_inGroup[k] entailed];
      }
      if (allEntailed)
         assignTRInt(&_active,NO,_trail);
      return ORSuspend;
   }, ^ORStatus{
      ORClosure cb;
      id<CPConstraint> forCstr;
      while (ISLOADED(_closureQueue[ALWAYS_PRIO])) {
         [_closureQueue[ALWAYS_PRIO] deQueue:&cb forCstr:&forCstr];
         ORStatus as = executeClosure(cb,forCstr,&last);
         nbp += as != ORSkip;
         assert(as != ORFailure);
      }
      for(ORInt p=NBPRIORITIES-1;p>=0;--p)
         [_closureQueue[p] reset];
      [_valueClosureQueue reset];
      [_engine incNbPropagation:nbp];
      [_engine setLastFailure:last];
      failNow();
      return ORFailure; // just to make compiler happy.
   });
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<CPGroup(%p): %d",self,_nbIn];
   for(ORInt i=0;i<_nbIn;i++) {
      [buf appendFormat:@"\n\t\t%3d : %@",i,[_inGroup[i] description]];
   }
   [buf appendString:@"\n\t>"];
   return buf;
}
@end

// ---------------------------
@implementation CPBergeGroup  {
   CPEngineI*               _engine;
   id<CPConstraint>*        _inGroup;
   id<CPClosureList>*       _scanMap;
   ORInt                    _nbIn;
   ORInt                    _max;
   ORInt                    _low;
   ORInt                    _sz;
   ORInt*                   _map;
}
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
-(id<ORTrail>) trail
{
   return [_engine trail];
}
-(ORStatus)add:(id<CPConstraint>)p
{
   if (_nbIn == _max) {
      _inGroup = realloc(_inGroup,sizeof(id<CPConstraint>)*_max*2);
      _max <<= 1;
   }
   _inGroup[_nbIn++] = p;
   [p setGroup:self];
   [self assignIdToConstraint:p];
   return ORSuspend;
}
-(void)assignIdToConstraint:(id<ORConstraint>)c
{
   [_engine assignIdToConstraint:c];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<CPBergeGroup(%p):",self];
   for(ORInt i=0;i<_nbIn;i++) {
      [buf appendFormat:@"\n\t\t%3d : %@",i,[_inGroup[i] description]];
   }
   [buf appendString:@"\n\t>"];
   return buf;
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
      _map[_inGroup[i].getId] = i;
   memset(_scanMap,0,sizeof(CPClosureList*)*_nbIn);
   for(ORInt i=0;i<_nbIn;i++)
      [_inGroup[i] post];
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
-(void)propagate
{
   __block ORInt nbp = 0;
   __block id<CPConstraint> last = nil;
   tryfail(^ORStatus{
      for(ORInt k=0;k<_nbIn;k++) {
         CPClosureList* evt = _scanMap[k];
         if (evt) {
            ORStatus status = executeClosure(evt->_trigger,evt->_cstr,&last);
            _scanMap[k] = nil;
            nbp += status !=ORSkip;
         }
      }
      for(ORInt k=_nbIn-1;k>=0;k--) {
         CPClosureList* evt = _scanMap[k];
         if (evt) {
            ORStatus status = executeClosure(evt->_trigger,evt->_cstr,&last);
            _scanMap[k] = nil;
            nbp += status !=ORSkip;
         }
      }
      [_engine incNbPropagation:nbp];
      return ORSuspend;
   }, ^ORStatus{
      memset(_scanMap,0,sizeof(CPClosureList*)*_nbIn); // clear the queue
      [_engine incNbPropagation:nbp];
      [_engine setLastFailure:last];
      failNow();
      return ORFailure; // just to make compiler happy.
   });
}
-(ORInt) size
{
   return _nbIn;
}
@end

