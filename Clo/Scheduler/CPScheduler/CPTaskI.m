/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <CPUKernel/CPClosureEvent.h>
#import <CPUKernel/CPEngineI.h>
#import <objcp/CPError.h>
#import "CPTaskI.h"
#import "CPFactory.h"

typedef struct  {
   TRId _boundEvt[2];
   TRId _startEvt[2];
   TRId _endEvt[2];
   TRId _durationEvt[2];
} CPTaskVarEventNetwork;

@implementation CPTaskVar
{
   CPEngineI*         _engine;
   id<ORTrail>        _trail;
   id<ORIntRange>     _horizon;
   TRInt              _start;
   TRInt              _end;
   TRInt              _durationMin;
   TRInt              _durationMax;
   ORBool             _constantDuration;
   CPTaskVarEventNetwork _net;
}
-(id<CPTaskVar>) initCPTaskVar: (CPEngineI*) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   self = [super init];
   _engine = engine;
   _trail = [engine trail];
   
   // domain [who said I do not write comments?]
   _start = makeTRInt(_trail,horizon.low);
   _end = makeTRInt(_trail,horizon.up);
   _durationMin = makeTRInt(_trail,duration);
   _durationMax = makeTRInt(_trail,duration);
   _constantDuration = TRUE;

   // need a consistency check
   assert(_start._val + _durationMax._val <= _end._val);

   // network
   for(ORInt i = 0;i < 2;i++) {
      _net._boundEvt[i] = makeTRId(_trail,nil);
      _net._startEvt[i] = makeTRId(_trail,nil);
      _net._endEvt[i] = makeTRId(_trail,nil);
      _net._durationEvt[i] = makeTRId(_trail,nil);
   }
   return self;
}
-(ORInt) est
{
   return _start._val;
}
-(ORInt) lst
{
   return _end._val - _durationMin._val;
}
-(ORInt) ect
{
   return _start._val + _durationMin._val;
}
-(ORInt) lct
{
   return _end._val;
}
-(ORInt) minDuration
{
   return _durationMin._val;
}
-(ORInt) maxDuration
{
   return _durationMax._val;
}
-(ORBool) bound
{
   return (_start._val + _durationMin._val == _end._val) && (_durationMin._val == _durationMax._val);
}
-(ORBool) isPresent
{
   return TRUE;
}
-(ORBool) isOptional
{
   return FALSE;
}
-(ORBool) isAbsent
{
   return FALSE;
}
-(void) updateStart: (ORInt) newStart
{
   if (newStart > _start._val) {
      if (newStart + _durationMin._val > _end._val)
         failNow();
      [self changeStartEvt];
      assignTRInt(&_start,newStart,_trail);
      
      if (_constantDuration) {
         ORInt newDurationMax = _end._val - _start._val;
         [self updateMaxDuration: newDurationMax];
      }
   }
}
-(void) updateEnd: (ORInt) newEnd
{
   if (newEnd < _end._val) {
      if (newEnd < _start._val + _durationMin._val)
         failNow();
      [self changeEndEvt];
      assignTRInt(&_end,newEnd,_trail);
      
      if (_constantDuration) {
         ORInt newDurationMax = _end._val - _start._val;
         [self updateMaxDuration: newDurationMax];
      }
   }
}
-(void) updateMinDuration: (ORInt) newDurationMin
{
   if (newDurationMin > _durationMin._val) {
      if (newDurationMin > _durationMax._val)
         failNow();
      if (_start._val + newDurationMin > _end._val)
         failNow();
      [self changeDurationEvt];
      assignTRInt(&_durationMin,newDurationMin,_trail);
   }
}
-(void) updateMaxDuration: (ORInt) newDurationMax
{
   if (newDurationMax < _durationMax._val) {
      if (newDurationMax < _durationMin._val)
         failNow();
      [self changeDurationEvt];
      assignTRInt(&_durationMax,newDurationMax,_trail);
   }
}
-(void) labelStart: (ORInt) start
{
   [self updateStart: start];
   [self updateEnd: start + _durationMax._val];
}
-(void) labelEnd: (ORInt) end
{
   [self updateEnd: end];
   [self updateStart: end - _durationMax._val];
}
-(void) labelDuration: (ORInt) duration
{
   [self updateMinDuration: duration];
   [self updateMaxDuration: duration];
}
-(void) labelPresent: (ORBool) present
{
   if (!present)
      failNow();
}
-(NSString*) description
{
   if ([self bound])
      return [NSString stringWithFormat:@"[%d -(%d)-> %d]",[self est],_durationMin._val,[self ect]];
   else if (_constantDuration)
      return [NSString stringWithFormat:@"[%d..%d -(%d)-> %d..%d]",[self est],[self lst],_durationMin._val,[self ect],[self lct]];
   else
      return [NSString stringWithFormat:@"[%d..%d -(%d..%d)-> %d..%d]",[self est],[self lst],_durationMin._val,_durationMax._val,[self ect],[self lct]];
}

// AC3 Closure Event
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   hookupEvent(_engine, _net._boundEvt, todo, c, p);
}
-(void) whenChangeStartDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   hookupEvent(_engine, _net._startEvt, todo, c, p);
}
-(void) whenChangeEndDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   hookupEvent(_engine, _net._endEvt, todo, c, p);
}
-(void) whenChangeDurationDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   hookupEvent(_engine, _net._durationEvt, todo, c, p);
}
-(void) whenAbsentDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
}
-(void) whenPresentDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
}
-(void) whenChangeDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [self whenChangeDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeStartDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [self whenChangeStartDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeEndDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [self whenChangeEndDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeDurationDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [self whenChangeDurationDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenAbsentDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
}
-(void) whenPresentDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
}

// AC3 Constraint Event
-(void) whenChangePropagate:  (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._boundEvt, nil, c, p);
}
-(void) whenChangeStartPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._startEvt, nil, c, p);
}
-(void) whenChangeEndPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._endEvt, nil, c, p);
}
-(void) whenChangeDurationPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._durationEvt, nil, c, p);
}
-(void) whenAbsentPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
}
-(void) whenPresentPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
}
-(void) whenChangePropagate: (CPCoreConstraint*) c
{
   [self whenChangePropagate: c priority: c->_priority];
}
-(void) whenChangeStartPropagate: (CPCoreConstraint*) c
{
   [self whenChangeStartPropagate: c priority: c->_priority];
}
-(void) whenChangeEndPropagate: (CPCoreConstraint*) c
{
   [self whenChangeEndPropagate: c priority: c->_priority];
}
-(void) whenChangeDurationPropagate: (CPCoreConstraint*) c
{
   [self whenChangeDurationPropagate: c priority: c->_priority];
}
-(void) whenAbsentPropagate: (id<CPConstraint>) c
{
}
-(void) whenPresentPropagate: (id<CPConstraint>) c
{
}
-(void) changeStartEvt
{
   id<CPClosureList> mList[2];
   ORUInt k = 0;
   mList[k] = _net._boundEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = _net._startEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeEndEvt
{
   id<CPClosureList> mList[2];
   ORUInt k = 0;
   mList[k] = _net._boundEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = _net._endEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeDurationEvt
{
   id<CPClosureList> mList[1];
   ORUInt k = 0;
   mList[k] = _net._durationEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(id<ORTracker>) tracker
{
   return _engine;
}
-(id<CPEngine>) engine
{
   return _engine;
}
-(NSSet*) constraints
{
   NSMutableSet* rv = [[[NSMutableSet alloc] initWithCapacity:2] autorelease];
   collectList(_net._boundEvt[0]._val,rv);
   collectList(_net._startEvt[0]._val,rv);
   collectList(_net._endEvt[0]._val,rv);
   collectList(_net._durationEvt[0]._val,rv);
   return rv;
}
-(ORInt) degree
{
   __block ORUInt d = 0;
   [_net._boundEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._startEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._endEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._durationEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   return d;
}
@end


typedef struct  {
   TRId _presentEvt[2];
   TRId _absentEvt[2];
} CPOptionalTaskVarEventNetwork;

@implementation CPOptionalTaskVar
{
   CPEngineI*         _engine;
   id<ORTrail>        _trail;
   id<CPTaskVar>      _task;
   TRInt              _presentMin;
   TRInt              _presentMax;
   
   CPOptionalTaskVarEventNetwork _net;
}
-(id<CPTaskVar>) initCPOptionalTaskVar: (CPEngineI*) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   self = [super init];
   _engine = engine;
   _trail = [engine trail];
   
   _task = [CPFactory task: engine horizon: horizon duration: duration];
   _presentMin = makeTRInt(_trail,0);
   _presentMax = makeTRInt(_trail,1);
   // network
   for(ORInt i = 0;i < 2;i++) {
      _net._presentEvt[i] = makeTRId(_trail,nil);
      _net._absentEvt[i] = makeTRId(_trail,nil);
   }
   return self;
}
-(ORInt) est
{
   return [_task est];
}
-(ORInt) lst
{
   return [_task lst];
}
-(ORInt) ect
{
   return [_task ect];
}
-(ORInt) lct
{
   return [_task lct];
}
-(ORInt) minDuration
{
   return [_task minDuration];
}
-(ORInt) maxDuration
{
   return [_task maxDuration];
}
-(ORBool) isPresent
{
   return _presentMin._val == 1;
}
-(ORBool) isAbsent
{
   return _presentMax._val == 0;
}
-(ORBool) isOptional
{
   return _presentMin._val != _presentMax._val;
}
-(ORBool) bound
{
   return ([_task bound] && (_presentMin._val == 1)) || (_presentMax._val == 0);
}
-(void) handleFailure: (ORClosure) cl
{
}
-(void) updateStart: (ORInt) newStart
{
   tryfail(
           ^ORStatus() { [_task updateStart: newStart]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) updateEnd: (ORInt) newEnd
{
   tryfail(
           ^ORStatus() { [_task updateEnd: newEnd]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) updateMinDuration: (ORInt) newMinDuration
{
   tryfail(
           ^ORStatus() { [_task updateMinDuration: newMinDuration]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) updateMaxDuration: (ORInt) newMaxDuration
{
   tryfail(
           ^ORStatus() { [_task updateMaxDuration: newMaxDuration];  return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) labelStart: (ORInt) start
{
   tryfail(
           ^ORStatus() { [_task labelStart: start]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) labelEnd: (ORInt) end
{
   tryfail(
           ^ORStatus() {  [_task labelEnd: end]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) labelDuration: (ORInt) duration
{
   tryfail(
           ^ORStatus() { [_task labelDuration: duration]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) labelPresent: (ORBool) present
{
   if (present) {
      if (_presentMax._val == 0)
         failNow();
      else if (_presentMin._val == 0) {
         [self presentEvt];
         assignTRInt(&_presentMin,1,_trail);
      }
   }
   else {
      if (_presentMin._val == 1)
         failNow();
      else if (_presentMax._val == 1) {
         [self absentEvt];
         assignTRInt(&_presentMax,0,_trail);
      }
   }
}

-(NSString*) description
{
   if ([self bound]) {
      if ([self isPresent])
         return [NSString stringWithFormat:@"[%d -(%d)-> %d]",[self est],[self minDuration],[self ect]];
      else if ([self isAbsent])
         return [NSString stringWithFormat:@"[absent]"];
      else
         return [NSString stringWithFormat:@"opt[%d -(%d)-> %d]",[self est],[self minDuration],[self ect]];
   }
   else {
      if ([self isPresent])
         return [NSString stringWithFormat:@"[%d..%d -(%d..%d)-> %d..%d]",[self est],[self lst],[self minDuration],[self maxDuration],[self ect],[self lct]];
      else // cannot be absent; would be bound otherwise
         return [NSString stringWithFormat:@"opt[%d..%d -(%d..%d)-> %d..%d]",[self est],[self lst],[self minDuration],[self maxDuration],[self ect],[self lct]];
   }
}

// AC3 Closure Event
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   [_task whenChangeDo: todo priority: p onBehalf: c];
}
-(void) whenChangeStartDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   [_task whenChangeStartDo: todo priority: p onBehalf: c];
}
-(void) whenChangeEndDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   [_task whenChangeEndDo: todo priority: p onBehalf: c];
}
-(void) whenAbsentDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   hookupEvent(_engine, _net._absentEvt, todo, c, p);
}
-(void) whenPresentDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
    hookupEvent(_engine, _net._presentEvt, todo, c, p);
}
-(void) whenChangeDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [_task whenChangeDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeStartDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [_task whenChangeStartDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeEndDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [_task whenChangeEndDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenAbsentDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [self whenAbsentDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) whenPresentDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [self whenPresentDo: todo priority: HIGHEST_PRIO onBehalf:c];
}

// AC3 Constraint Event
-(void) whenChangePropagate:  (id<CPConstraint>) c priority: (ORInt) p
{
   [_task whenChangePropagate: c priority: p];
}
-(void) whenChangeStartPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   [_task whenChangeStartPropagate: c priority: p];
}
-(void) whenChangeEndPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   [_task whenChangeEndPropagate: c priority: p];
}
-(void) whenAbsentPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._absentEvt, nil, c, p);
}
-(void) whenPresentPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._presentEvt, nil, c, p);
}

-(void) whenChangePropagate: (CPCoreConstraint*) c
{
   [_task whenChangePropagate: c priority: c->_priority];
}
-(void) whenChangeStartPropagate: (CPCoreConstraint*) c
{
   [_task whenChangeStartPropagate: c priority: c->_priority];
}
-(void) whenChangeEndPropagate: (CPCoreConstraint*) c
{
   [_task whenChangeEndPropagate: c priority: c->_priority];
}
-(void) whenAbsentPropagate: (CPCoreConstraint*) c
{
   [self whenAbsentPropagate: c priority: c->_priority];
}
-(void) whenPresentPropagate: (CPCoreConstraint*) c
{
   [self whenPresentPropagate: c priority: c->_priority];
}
-(void) presentEvt
{
   id<CPClosureList> mList[1];
   ORUInt k = 0;
   mList[k] = _net._presentEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) absentEvt
{
   id<CPClosureList> mList[1];
   ORUInt k = 0;
   mList[k] = _net._absentEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(id<ORTracker>) tracker
{
   return _engine;
}
-(id<CPEngine>) engine
{
   return _engine;
}
-(NSSet*) constraints
{
   NSMutableSet* rv = (NSMutableSet*) [_task constraints];
   collectList(_net._absentEvt[0]._val,rv);
   collectList(_net._presentEvt[0]._val,rv);
   return rv;
}
-(ORInt) degree
{
   __block ORUInt d = [_task degree];
   [_net._absentEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._presentEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   return d;
}
@end
