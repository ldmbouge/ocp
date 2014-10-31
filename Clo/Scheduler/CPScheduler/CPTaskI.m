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

/*****************************************************************************************/
/*                        CPTaskVarSnapshot                                              */
/*****************************************************************************************/

@interface CPTaskVarSnapshot : NSObject {
   ORUInt    _name;
   ORInt     _start;
   ORInt     _end;
   ORBool    _present;
   ORBool    _absent;
   ORInt     _minDuration;
   ORInt     _maxDuration;
   ORBool    _bound;
}
-(CPTaskVarSnapshot*) initCPTaskVarSnapshot: (id<CPTaskVar>) t name: (ORInt) name;
-(NSString*) description;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation CPTaskVarSnapshot
-(CPTaskVarSnapshot*) initCPTaskVarSnapshot: (id<CPTaskVar>) t name: (ORInt) name;
{
   self = [super init];
   _name = name;
   _start = [t est];
   _end = [t ect];
   _minDuration = [t minDuration];
   _maxDuration = [t maxDuration];
   _present = [t isPresent];
   _absent = [t isAbsent];
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
      CPTaskVarSnapshot* other = object;
      if (_name == other->_name) {
         return _start == other->_start && _end == other->_end  && _minDuration == other->_minDuration &&
         _maxDuration == other->_maxDuration && _present == other->_present && _absent == other->_absent;
      }
      else
         return NO;
   } else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + _start * _end;
}
-(ORUInt) getId
{
   return _name;
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
-(ORBool) isAbsent
{
   return _absent;
}
-(ORBool) isPresent
{
   return _present;
}
-(ORBool) bound
{
   return (_start + _minDuration == _end) && (_minDuration == _maxDuration);
}
@end

typedef struct  {
   TRId _boundEvt[2];
   TRId _startEvt[2];
   TRId _endEvt[2];
   TRId _durationEvt[2];
} CPTaskVarEventNetwork;

@implementation CPTaskVar
{
   @protected CPEngineI*  _engine;
   @protected id<ORTrail> _trail;
   id<ORIntRange>     _horizon;
   TRInt              _start;
   TRInt              _end;
   TRInt              _durationMin;
   TRInt              _durationMax;
   ORBool             _constantDuration;
   CPTaskVarEventNetwork _net;
}
-(id<CPTaskVar>) initCPTaskVar: (CPEngineI*) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
   self = [super init];
   _engine = engine;
   _trail = [engine trail];
   
   // domain [who said I do not write comments?]
   _start = makeTRInt(_trail,horizon.low);
   _end = makeTRInt(_trail,horizon.up);
   _durationMin = makeTRInt(_trail,duration.low);
   _durationMax = makeTRInt(_trail,duration.up);
   _constantDuration = (duration.low == duration.up);
   
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

-(id) takeSnapshot: (ORInt) id
{
   return [[CPTaskVarSnapshot alloc] initCPTaskVarSnapshot: self name: id];
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
-(void) readEssentials:(ORBool *)bound est:(ORInt *)est lct:(ORInt *)lct minDuration:(ORInt *)minD maxDuration:(ORInt *)maxD present:(ORBool *)present absent:(ORBool *)absent
{
    *bound   = (_start._val + _durationMin._val == _end._val) && (_durationMin._val == _durationMax._val);
    *est     = _start._val;
    *lct     = _end._val;
    *minD    = _durationMin._val;
    *maxD    = _durationMax._val;
    *present = TRUE;
    *absent  = FALSE;
}
-(void) updateStart: (ORInt) newStart
{
   if (newStart > _start._val) {
      if (newStart + _durationMin._val > _end._val)
         failNow();
      [self changeStartEvt];
      assignTRInt(&_start,newStart,_trail);
      
      if (!_constantDuration) {
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
      
      if (!_constantDuration) {
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
   id<CPClosureList> mList[3];
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
   id<CPClosureList> mList[3];
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
   id<CPClosureList> mList[3];
   ORUInt k = 0;
   mList[k] = _net._boundEvt[0]._val;
   k += mList[k] != NULL;
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
-(id<CPTaskVar>) initCPOptionalTaskVar: (CPEngineI*) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
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
-(void) readEssentials:(ORBool *)bound est:(ORInt *)est lct:(ORInt *)lct minDuration:(ORInt *)minD maxDuration:(ORInt *)maxD present:(ORBool *)present absent:(ORBool *)absent
{
    [_task readEssentials:bound est:est lct:lct minDuration:minD maxDuration:maxD present:present absent:absent];
    *bound   = [self bound    ];
    *present = [self isPresent];
    *absent  = [self isAbsent ];
}
-(void) handleFailure: (ORClosure) cl
{
}
-(void) updateStart: (ORInt) newStart
{
   if (_presentMin._val)
      [_task updateStart: newStart];
   else if (_presentMax._val)
      tryfail(
           ^ORStatus() { [_task updateStart: newStart]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) updateEnd: (ORInt) newEnd
{
   if (_presentMin._val)
      [_task updateEnd: newEnd];
   else if (_presentMax._val)
      tryfail(
           ^ORStatus() { [_task updateEnd: newEnd]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) updateMinDuration: (ORInt) newMinDuration
{
   if (_presentMin._val)
      [_task updateMinDuration: newMinDuration];
   else if (_presentMax._val)
      tryfail(
           ^ORStatus() { [_task updateMinDuration: newMinDuration]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) updateMaxDuration: (ORInt) newMaxDuration
{
   if (_presentMin._val)
      [_task updateMaxDuration: newMaxDuration];
   else if (_presentMax._val)
      tryfail(
           ^ORStatus() { [_task updateMaxDuration: newMaxDuration];  return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) labelStart: (ORInt) start
{
   if (_presentMin._val)
      [_task labelStart: start];
   else if (_presentMax._val)
      tryfail(
           ^ORStatus() { [_task labelStart: start]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) labelEnd: (ORInt) end
{
   if (_presentMin._val)
      [_task labelEnd: end];
   else if (_presentMax._val)
      tryfail(
           ^ORStatus() {  [_task labelEnd: end]; return ORSuccess;},
           ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
           );
}
-(void) labelDuration: (ORInt) duration
{
   if (_presentMin._val)
      [_task labelDuration: duration];
   else if (_presentMax._val)
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
//
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
-(void) whenChangeDurationDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   [_task whenChangeDurationDo: todo priority: p onBehalf: c];
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
-(void) whenChangeDurationDo: (ORClosure) todo onBehalf: (id<CPConstraint>) c
{
   [_task whenChangeDurationDo: todo priority: HIGHEST_PRIO onBehalf:c];
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
-(void) whenChangeDurationPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   [_task whenChangeDurationPropagate: c priority: p];
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
-(void) whenChangeDurationPropagate: (CPCoreConstraint*) c
{
   [_task whenChangeDurationPropagate: c priority: c->_priority];
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
   id<CPClosureList> mList[2];
   ORUInt k = 0;
   mList[k] = _net._presentEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) absentEvt
{
   id<CPClosureList> mList[2];
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


@implementation CPAlternativeTask
{
    id<CPTaskVarArray> _alt;
}
-(id<CPAlternativeTask>) initCPAlternativeTask:(id<CPEngine>)engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration alternatives:(id<CPTaskVarArray>)alternatives
{
    self = [super initCPTaskVar:engine horizon:horizon duration:duration];
    _alt = alternatives;
    return self;
}
-(id<CPTaskVarArray>) alternatives
{
    return _alt;
}
@end


@implementation CPOptionalAlternativeTask
{
    id<CPTaskVarArray> _alt;
}
-(id<CPAlternativeTask>) initCPOptionalAlternativeTask:(id<CPEngine>)engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration alternatives:(id<CPTaskVarArray>)alternatives
{
    self = [super initCPOptionalTaskVar:engine horizon:horizon duration:duration];
    _alt = alternatives;
    return self;
}
-(id<CPTaskVarArray>) alternatives
{
    return _alt;
}
@end


@implementation CPMachineTask
{
    id<CPDisjunctiveArray> _disj;
    id<ORIntArray> _durArray;
    ORInt * _index;
    TRInt   _uSize;
    ORInt   _size;
    TRInt   _bind;
}
-(id<CPMachineTask>) initCPMachineTask:(id<CPEngine>)engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration durationArray:(id<ORIntArray>)durationArray runsOnOneOf:(id<CPDisjunctiveArray>)disjunctives
{
    assert(durationArray.low == disjunctives.low);
    assert(durationArray.up  == disjunctives.up );
    self = [super initCPTaskVar:engine horizon:horizon duration:duration];
    _disj = disjunctives;
    _durArray = durationArray;
    _size = (ORInt)[disjunctives count];
    _index = NULL;
    _index = malloc(_size * sizeof(ORInt));
    if (_index == NULL)
         @throw [[ORExecutionError alloc] initORExecutionError: "CPMachineTask: Out of memory!"];
    _uSize = makeTRInt(_trail, _size);
    _bind  = makeTRInt(_trail, 0);
    
    // Initialisation of the index array
    for (ORInt i = 0; i < _size; i++)
        _index[i] = i + _disj.low;
    
    return self;
}
-(void) dealloc
{
    if (_index != NULL) free(_index);
    [super dealloc];
}
-(id<CPDisjunctiveArray>) disjunctives
{
    return _disj;
}
-(void) set:(id<CPConstraint>)disjunctive at:(ORInt)idx
{
    assert(_disj.low <= idx && idx <= _disj.up);
    assert([disjunctive isMemberOfClass: [CPTaskDisjunctive class]]);
    [_disj set:(CPTaskDisjunctive*) disjunctive at:idx];
}
-(id<ORIntArray>) getAvailDisjunctives
{
    // XXX Maybe sort in order to return in the same order
    return [ORFactory intArray:_engine range:RANGE(_engine, 0, _uSize._val) with:^ORInt(ORInt k) {return _index[k];}];
}
-(ORBool) isAssigned
{
    return (_uSize._val == 1);
}
-(ORBool) bound
{
    if (_uSize._val != 1)
        return false;
    return [super bound];
}
-(ORBool) isPresentOn: (CPTaskDisjunctive*) disjunctive
{
    return (_uSize._val == 1 && _index[0] == [self getIndex:disjunctive]);
}
-(ORBool) isAbsentOn: (CPTaskDisjunctive*) disjunctive
{
    const ORInt idx = [self getIndex:disjunctive];
    for (ORInt i = 0; i < _uSize._val; i++)
        if (_index[i] == idx)
            return FALSE;
    return TRUE;
}
-(ORInt) runsOn
{
    if (_uSize._val != 1)
        @throw [[ORExecutionError alloc] initORExecutionError: "The task is not assigned to any machine"];
    return _index[0];
}
-(void) readEssentials:(ORBool *)bound est:(ORInt *)est lct:(ORInt *)lct minDuration:(ORInt *)minD maxDuration:(ORInt *)maxD present:(ORBool *)present absent:(ORBool *)absent forMachine:(CPTaskDisjunctive *)disjunctive
{
    [super readEssentials:bound est:est lct:lct minDuration:minD maxDuration:maxD present:present absent:absent];
    *bound   = [self bound    ];
    *present = [self isPresentOn:disjunctive];
    *absent  = [self isAbsentOn:disjunctive ];
}
-(void) updateMinDuration:(ORInt)newMinDuration
{
    if (newMinDuration > _durationMin._val) {
        [super updateMinDuration:newMinDuration];
        ORInt uSize = _uSize._val;
        for (ORInt i = 0; i < uSize; i++) {
            const ORInt idx = _index[i];
            if ([_durArray at:idx] < newMinDuration) {
                uSize--;
                _index[i]     = _index[uSize];
                _index[uSize] = idx;
            }
        }
        if (uSize == 0)
            failNow();
        if (uSize < _uSize._val)
            assignTRInt(&(_uSize), uSize, _trail);
        if (uSize == 1 && !_bind._val)
            [self bindWithIndex:_index[0]];
    }
}
-(void) updateMaxDuration:(ORInt)newMaxDuration
{
    if (newMaxDuration < _durationMax._val) {
        [super updateMaxDuration:newMaxDuration];
        ORInt uSize = _uSize._val;
        for (ORInt i = 0; i < uSize; i++) {
            const ORInt idx = _index[i];
            if ([_durArray at:idx] > newMaxDuration) {
                uSize--;
                _index[i]     = _index[uSize];
                _index[uSize] = idx;
            }
        }
        if (uSize == 0)
            failNow();
        if (uSize < _uSize._val)
            assignTRInt(&(_uSize), uSize, _trail);
        if (uSize == 1 && !_bind._val)
            [self bindWithIndex:_index[0]];
    }
}
-(void) bind: (CPTaskDisjunctive*) disjunctive
{
    const ORInt idx = [self getIndex:disjunctive];
    [self bindWithIndex: idx];
}
-(void) bindWithIndex: (const ORInt) idx
{
    if (_uSize._val == 1) {
        if (_index[0] != idx)
            failNow();
    }
    else {
        ORInt i = 0;
        for (; i < _uSize._val; i++) {
            if (_index[i] == idx) {
                _index[i] = _index[0];
                _index[0] = idx;
                break;
            }
        }
        if (i >= _uSize._val)
            failNow();
        assignTRInt(&(_uSize), 1, _trail);
    }
    assert(_index[0] == idx);
    if (!_bind._val) {
        assignTRInt(&(_bind), 1, _trail);
        [self updateMinDuration:[_durArray at: idx]];
        [self updateMaxDuration:[_durArray at: idx]];
        // TODO queue disjunctive propagator
        [_disj[idx] propagate];
    }
}
-(void) remove: (CPTaskDisjunctive*) disjunctive
{
    const ORInt idx = [self getIndex:disjunctive];
    [self removeWithIndex:idx];
}
-(void) removeWithIndex: (const ORInt) idx
{
    if (_uSize._val == 1) {
        if (_index[0] == idx)
            failNow();
    }
    else {
        ORBool newDur = false;
        for (ORInt i = 0; i < _uSize._val; i++) {
            if (_index[i] == idx) {
                const ORInt j = _uSize._val - 1;
                assignTRInt(&(_uSize), j, _trail);
                _index[i] = _index[j];
                _index[j] = idx;
                newDur = true;
                break;
            }
        }
        if (_uSize._val == 1) {
            assert(!_bind._val);
            [self bindWithIndex:_index[0]];
        }
        else if (newDur && _durationMin._val < _durationMax._val) {
            // XXX With "watches" on the disjunctive holding the minimal and maximal
            // duration the above test can be refined
            
            // Checking for new duration bounds
            ORInt minDur = MAXINT;
            ORInt maxDur = MININT;
            for (ORInt i = 0; i < _uSize._val; i++) {
                minDur = min(minDur, [_durArray at: _index[i]]);
                maxDur = max(maxDur, [_durArray at: _index[i]]);
            }
            assert(minDur < MAXINT);
            assert(maxDur > MININT);
            [self updateMinDuration:minDur];
            [self updateMaxDuration:maxDur];
        }
    }
}
-(ORInt) getIndex: (CPTaskDisjunctive*) disjunctive
{
    ORInt idx = _disj.low;
    for (; idx <= _disj.up; idx++)
        if (_disj[idx] == disjunctive)
            return idx;
    // Program never should reach this point
    assert(false);
    return ++idx;
}
@end
