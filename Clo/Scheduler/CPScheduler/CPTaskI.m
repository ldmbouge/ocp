/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
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
    ORUInt  _name;
    ORInt   _start;
    ORInt   _lst;
    ORInt   _ect;
    ORInt   _end;
    ORBool  _present;
    ORBool  _absent;
    ORInt   _minDuration;
    ORInt   _maxDuration;
    ORBool  _bound;
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
    _lst   = [t lst];
    _ect   = [t ect];
    _end   = [t lct];
    _minDuration = [t minDuration];
    _maxDuration = [t maxDuration];
    _present = [t isPresent];
    _absent = [t isAbsent];
    return self;
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"task(%d: s[%d,%d]; e[%d,%d]; d[%d,%d]; p[%d,%d])",_name,_start,_lst,_ect,_end,_minDuration,_maxDuration,_present,_absent];
    return buf;
}
-(ORBool) isEqual: (id) object
{
    if ([object isKindOfClass:[self class]]) {
        CPTaskVarSnapshot* other = object;
        if (_name == other->_name) {
            return _start == other->_start && _end == other->_end  && _minDuration == other->_minDuration &&
            _maxDuration == other->_maxDuration && _present == other->_present && _absent == other->_absent &&
            _lst == other->_lst && _ect == other->_ect;
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
   return _ect;
}
-(ORInt) lst
{
   return _lst;
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
    id<ORIntRange>  _horizon;
    // Trailed values
    TRInt _start;       // Earliest start time
    TRInt _lst;         // Latest start time
    TRInt _ect;         // Earliest completion time
    TRInt _end;         // Latest completion time
    TRInt _durationMin; // Minimal duration
    TRInt _durationMax; // Maximal duration
    
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
    _lst = makeTRInt(_trail, horizon.up - duration.low);
    _ect = makeTRInt(_trail, horizon.low + duration.low);
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
-(ORBool)vertical
{
   return YES;
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
    return _lst._val;
//   return _end._val - _durationMin._val;
}
-(ORInt) ect
{
    return _ect._val;
//   return _start._val + _durationMin._val;
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
-(ORBool) readEst:(ORInt *)est lst:(ORInt *)lst ect:(ORInt *)ect lct:(ORInt *)lct minDuration:(ORInt *)minD maxDuration:(ORInt *)maxD present:(ORBool *)present absent:(ORBool *)absent forResource:(id)resource
{
    ORBool bound   = (_start._val + _durationMin._val == _end._val) && (_durationMin._val == _durationMax._val);
    *est     = _start._val;
    *lst     = _lst._val;
    *ect     = _ect._val;
    *lct     = _end._val;
    *minD    = _durationMin._val;
    *maxD    = _durationMax._val;
    *present = TRUE;
    *absent  = FALSE;
    return bound;
}
-(void) updateStart: (ORInt) newStart
{
    if (newStart > _start._val) {
        if (newStart > _lst._val)
            failNow();
        assert(newStart + _durationMin._val <= _end._val);
//      if (newStart + _durationMin._val > _end._val)
//         failNow();
        [self changeStartEvt];
        assignTRInt(&_start, newStart, _trail);
        if (newStart + _durationMin._val > _ect._val)
            assignTRInt(&_ect, newStart + _durationMin._val, _trail);
        
        if (!_constantDuration) {
            ORInt newDurationMax = _end._val - _start._val;
            [self updateMaxDuration: newDurationMax];
        }
    }
}
-(void) updateLst:(ORInt)newLst
{
    if (newLst < _lst._val) {
        if (newLst < _start._val)
            failNow();
        [self changeStartEvt];
        assignTRInt(&_lst, newLst, _trail);
        if (newLst + _durationMax._val < _end._val)
            [self updateEnd:newLst + _durationMax._val];
    }
}
-(void) updateEct:(ORInt)newEct
{
    if (newEct > _ect._val) {
        if (newEct > _end._val)
            failNow();
        [self changeEndEvt];
        assignTRInt(&_ect, newEct, _trail);
        if (newEct - _durationMax._val > _start._val)
            [self updateStart:newEct - _durationMax._val];
    }
}
-(void) updateEnd: (ORInt) newEnd
{
   if (newEnd < _end._val) {
       if (newEnd < _ect._val)
           failNow();
       assert(newEnd >= _start._val + _durationMin._val);
//      if (newEnd < _start._val + _durationMin._val)
//         failNow();
      [self changeEndEvt];
      assignTRInt(&_end,newEnd,_trail);
       if (newEnd - _durationMin._val < _lst._val)
           assignTRInt(&_lst, newEnd - _durationMin._val, _trail);
      
      if (!_constantDuration) {
         ORInt newDurationMax = _end._val - _start._val;
         [self updateMaxDuration: newDurationMax];
      }
   }
}
-(void) updateStart: (ORInt) newStart end:(ORInt) newEnd
{
   ORBool work = newStart > _start._val || newEnd < _end._val;
   if (work) {
      newStart = max(_start._val,newStart);
      newEnd   = min(_end._val,newEnd);
       if (newStart > _lst._val || newEnd < _ect._val)
           failNow();
      if (newStart + _durationMin._val > newEnd || newEnd < newStart + _durationMin._val)
         failNow();
      [self changeStartEvt];
      [self changeEndEvt];
      assignTRInt(&_start, newStart, _trail);
      assignTRInt(&_end, newEnd, _trail);
       if (newStart + _durationMin._val > _ect._val)
           assignTRInt(&_ect, newStart + _durationMin._val, _trail);
       if (newEnd - _durationMin._val < _lst._val)
           assignTRInt(&_lst, newEnd - _durationMin._val, _trail);
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
       if (_start._val + newDurationMin > _ect._val) {
           [self changeEndEvt];
           assignTRInt(&_ect, _start._val + newDurationMin, _trail);
       }
       if (_end._val - newDurationMin < _lst._val) {
           [self changeStartEvt];
           assignTRInt(&_lst, _end._val - newDurationMin, _trail);
       }
   }
}
-(void) updateMaxDuration: (ORInt) newDurationMax
{
   if (newDurationMax < _durationMax._val) {
      if (newDurationMax < _durationMin._val)
         failNow();
      [self changeDurationEvt];
      assignTRInt(&_durationMax,newDurationMax,_trail);
       if (_lst._val + newDurationMax < _end._val)
           [self updateEnd:_lst._val + newDurationMax];
       if (_ect._val - newDurationMax > _start._val)
           [self updateStart:_ect._val - newDurationMax];
   }
}
-(void) labelStart: (ORInt) start
{
   [self updateStart: start];
    if (_lst._val > start) {
        [self changeStartEvt];
        assignTRInt(&_lst, start, _trail);
    }
   [self updateEnd: start + _durationMax._val];
}
-(void) labelEnd: (ORInt) end
{
   [self updateEnd: end];
    if (_ect._val < end) {
        [self changeEndEvt];
        assignTRInt(&_ect, end, _trail);
    }
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
   mList[k] = _net._boundEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._startEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeEndEvt
{
   id<CPClosureList> mList[3];
   ORUInt k = 0;
   mList[k] = _net._boundEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._endEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeDurationEvt
{
   id<CPClosureList> mList[3];
   ORUInt k = 0;
   mList[k] = _net._boundEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._durationEvt[0];
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
   collectList(_net._boundEvt[0],rv);
   collectList(_net._startEvt[0],rv);
   collectList(_net._endEvt[0],rv);
   collectList(_net._durationEvt[0],rv);
   return rv;
}
-(ORInt) degree
{
   __block ORUInt d = 0;
   [_net._boundEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._startEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._endEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._durationEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   return d;
}
@end

typedef struct  {
   TRId _presentEvt[2];
   TRId _absentEvt[2];
} CPOptionalTaskVarEventNetwork;

@implementation CPOptionalTaskVar
{
   @protected CPEngineI*    _engine;
   @protected id<ORTrail>   _trail;
   @protected id<CPTaskVar> _task;
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
-(ORBool)vertical
{
   return YES;
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
-(ORBool) readEst:(ORInt *)est lst:(ORInt *)lst ect:(ORInt *)ect lct:(ORInt *)lct minDuration:(ORInt *)minD maxDuration:(ORInt *)maxD present:(ORBool *)present absent:(ORBool *)absent forResource:(id)res
{
    [_task readEst:est lst:lst ect:ect lct:lct minDuration:minD maxDuration:maxD present:present absent:absent forResource:res];
    *present = [self isPresent];
    *absent  = [self isAbsent ];
   return [self bound];
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
-(void) updateLst:(ORInt)newLst
{
    if (_presentMin._val)
        [_task updateLst: newLst];
    else if (_presentMax._val)
        tryfail(
                ^ORStatus() { [_task updateLst: newLst]; return ORSuccess; },
                ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
                );
}
-(void) updateEct:(ORInt)newEct
{
    if (_presentMin._val)
        [_task updateEct: newEct];
    else if (_presentMax._val)
        tryfail(
                ^ORStatus() { [_task updateEct: newEct]; return ORSuccess; },
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
-(void) updateStart: (ORInt) newStart end:(ORInt) newEnd
{
   if (_presentMin._val) {
      [_task updateStart:newStart end:newEnd];
   } else if (_presentMax._val) {
      tryfail(
              ^ORStatus() { [_task updateStart:newStart end: newEnd]; return ORSuccess;},
              ^ORStatus() { [self labelPresent: FALSE]; return ORSuccess; }
              );
   }
   
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
   mList[k] = _net._presentEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) absentEvt
{
   id<CPClosureList> mList[2];
   ORUInt k = 0;
   mList[k] = _net._absentEvt[0];
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
   collectList(_net._absentEvt[0],rv);
   collectList(_net._presentEvt[0],rv);
   return rv;
}
-(ORInt) degree
{
   __block ORUInt d = [_task degree];
   [_net._absentEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._presentEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
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


@implementation CPSpanTask
{
    id<CPTaskVarArray> _compound;
}
-(id<CPSpanTask>) initCPSpanTask:(id<CPEngine>)engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration compound:(id<CPTaskVarArray>)compound
{
    self      = [super initCPTaskVar:engine horizon:horizon duration:duration];
    _compound = compound;
    return self;
}
-(id<CPTaskVarArray>) compound
{
    return _compound;
}
@end


@implementation CPOptionalSpanTask
{
    id<CPTaskVarArray> _compound;
}
-(id<CPSpanTask>) initCPOptionalSpanTask:(id<CPEngine>)engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration compound:(id<CPTaskVarArray>)compound
{
    self      = [super initCPOptionalTaskVar:engine horizon:horizon duration:duration];
    _compound = compound;
    return self;
}
-(id<CPTaskVarArray>) compound
{
    return _compound;
}
@end


@implementation CPResourceTask
{
    id<CPResourceArray> _res;
    id<ORIntRangeArray>   _durArray;
//    id<ORIntArray> _usageArray;
//    TRInt   _usageMin;
//    TRInt   _usageMax;
    ORInt * _index;
    TRInt   _uSize;
    ORInt   _size;
    TRInt   _bind;
}
-(id<CPResourceTask>) initCPResourceTask:(id<CPEngine>)engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration durationArray:(id<ORIntRangeArray>)durationArray runsOnOneOf:(id<CPResourceArray>)resources
{
    assert(durationArray.low == resources.low);
    assert(durationArray.up  == resources.up );
    self = [super initCPTaskVar:engine horizon:horizon duration:duration];
    _res = resources;
    _durArray = durationArray;
//    _usageArray = 0;
    _size = (ORInt)[resources count];
    _index = NULL;
    _index = malloc(_size * sizeof(ORInt));
    if (_index == NULL)
        @throw [[ORExecutionError alloc] initORExecutionError: "CPResourceTask: Out of memory!"];
//    _usageMin = makeTRInt(_trail, 0);
//    _usageMax = makeTRInt(_trail, 0);
    _uSize = makeTRInt(_trail, _size);
    _bind  = makeTRInt(_trail, 0);
    
    // Initialisation of the index array
    for (ORInt i = 0; i < _size; i++)
        _index[i] = i + _res.low;
    
    return self;
}
-(void) dealloc
{
    if (_index != NULL) free(_index);
    [super dealloc];
}
-(id<CPResourceArray>) resources
{
    return _res;
}
-(void) set:(id<CPConstraint>) resource at:(ORInt)idx
{
    assert(_res.low <= idx && idx <= _res.up);
    assert([resource isMemberOfClass: [CPTaskDisjunctive class]] || [resource isMemberOfClass: [CPTaskCumulative class]]);
    [_res set:resource at:idx];
}
-(id<ORIntArray>) getAvailResources
{
    // XXX Maybe sort in order to return in the same order
    return [ORFactory intArray:_engine range:RANGE(_engine, 0, _uSize._val) with:^ORInt(ORInt k) {return _index[k];}];
}
-(const ORInt *) getInternalIndexArray:(ORInt *)size
{
    *size = _uSize._val;
    return _index;
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
-(ORBool) isPresentOn: (id<CPConstraint>) resource
{
    return (_uSize._val == 1 && _index[0] == [self getIndex:resource]);
}
-(ORBool) isAbsentOn: (id<CPConstraint>) resource
{
    const ORInt idx = [self getIndex:resource];
    for (ORInt i = 0; i < _uSize._val; i++)
        if (_index[i] == idx)
            return FALSE;
    return TRUE;
}
-(ORInt) runsOn
{
    if (_uSize._val != 1)
        @throw [[ORExecutionError alloc] initORExecutionError: "The task is not assigned to any resource"];
    return _index[0];
}
-(ORBool) readEst:(ORInt *)est lst:(ORInt *)lst ect:(ORInt *)ect lct:(ORInt *)lct minDuration:(ORInt *)minD maxDuration:(ORInt *)maxD present:(ORBool *)present absent:(ORBool *)absent forResource:(id<CPConstraint>) resource
{
    [super readEst:est lst:lst ect:ect lct:lct minDuration:minD maxDuration:maxD present:present absent:absent forResource:resource];
    const ORInt idx = [self getIndex:resource];
    *minD    = max(*minD, [_durArray at: idx].low);
    *maxD    = min(*maxD, [_durArray at: idx].up);
    *present = [self isPresentOn:resource];
    *absent  = [self isAbsentOn :resource];
   return [self bound    ];
}
-(void) labelDuration: (ORInt) duration
{
    [self updateMinDuration: duration];
    [self updateMaxDuration: duration];
}
-(void) updateMinDuration:(ORInt)newMinDuration
{
    if (newMinDuration > _durationMin._val) {
        [super updateMinDuration:newMinDuration];
        ORInt uSize = _uSize._val;
        for (ORInt i = 0; i < uSize; i++) {
            const ORInt idx = _index[i];
            if ([_durArray at:idx].up < newMinDuration) {
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
            if ([_durArray at:idx].low > newMaxDuration) {
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
//-(void) updateMinUsage:(ORInt)newMinUsage
//{
//    assert(false);
//    if (newMinUsage > _usageMin._val) {
//        // Update usage
//        if (newMinUsage > _usageMax._val)
//            failNow();
//        // TODO trigger propagation events
//        [self changeDurationEvt];
//        assignTRInt(&_usageMin, newMinUsage, _trail);
//        // Update resource task
//        ORInt uSize = _uSize._val;
//        for (ORInt i = 0; i < uSize; i++) {
//            const ORInt idx = _index[i];
//            if ([_usageArray at:idx] < newMinUsage) {
//                uSize--;
//                _index[i]     = _index[uSize];
//                _index[uSize] = idx;
//            }
//        }
//        if (uSize == 0)
//            failNow();
//        if (uSize < _uSize._val)
//            assignTRInt(&(_uSize), uSize, _trail);
//        if (uSize == 1 && !_bind._val)
//            [self bindWithIndex:_index[0]];
//    }
//}
//-(void) updateMaxUsage:(ORInt)newMaxUsage
//{
//    assert(false);
//    if (newMaxUsage < _usageMax._val) {
//        // Update max usage
//        if (newMaxUsage < _usageMin._val)
//            failNow();
//        // TODO trigger propagation events
//        [self changeDurationEvt];
//        assignTRInt(&_usageMax, newMaxUsage, _trail);
//        // Update resource task
//        ORInt uSize = _uSize._val;
//        for (ORInt i = 0; i < uSize; i++) {
//            const ORInt idx = _index[i];
//            if ([_usageArray at:idx] > newMaxUsage) {
//                uSize--;
//                _index[i]     = _index[uSize];
//                _index[uSize] = idx;
//            }
//        }
//        if (uSize == 0)
//            failNow();
//        if (uSize < _uSize._val)
//            assignTRInt(&(_uSize), uSize, _trail);
//        if (uSize == 1 && !_bind._val)
//            [self bindWithIndex:_index[0]];
//    }
//}
-(void) bind: (id<CPConstraint>) resource
{
    const ORInt idx = [self getIndex:resource];
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
        [self updateMinDuration:[_durArray   at: idx].low];
        [self updateMaxDuration:[_durArray   at: idx].up];
//        [self updateMinUsage   :[_usageArray at: idx]];
//        [self updateMaxUsage   :[_usageArray at: idx]];
        // TODO queue propagator
        if ([_res[idx] isMemberOfClass: [CPTaskDisjunctive class]])
            [(CPTaskDisjunctive*)_res[idx] propagate];
        else {
            assert([_res[idx] isMemberOfClass: [CPTaskCumulative class]]);
            [(CPTaskCumulative*)_res[idx] propagate];
        }
    }
}
-(void) remove: (id<CPConstraint>) resource
{
    const ORInt idx = [self getIndex: resource];
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
        else if (newDur) {
            if (_durationMin._val < _durationMax._val) {
                // XXX With "watches" on the disjunctive holding the minimal and maximal
                // duration the above test can be refined
                
                // Checking for new duration bounds
                ORInt minDur = MAXINT;
                ORInt maxDur = MININT;
                for (ORInt i = 0; i < _uSize._val; i++) {
                    minDur = min(minDur, [_durArray at: _index[i]].low);
                    maxDur = max(maxDur, [_durArray at: _index[i]].up );
                }
                assert(minDur < MAXINT);
                assert(maxDur > MININT);
                [self updateMinDuration:minDur];
                [self updateMaxDuration:maxDur];
            }
//            // Currently, their is no resource usage in the concept of a task
//            if (_usageMin._val < _usageMax._val) {
//                // Checking for new usage bounds
//                ORInt minUsage = MAXINT;
//                ORInt maxUsage = MININT;
//                for (ORInt i = 0; i < _uSize._val; i++) {
//                    minUsage = min(minUsage, [_usageArray at: _index[i]]);
//                    maxUsage = max(maxUsage, [_usageArray at: _index[i]]);
//                }
//                assert(minUsage < MAXINT);
//                assert(maxUsage > MININT);
//                [self updateMinUsage:minUsage];
//                [self updateMaxUsage:maxUsage];
//            }
        }
    }
}
-(ORInt) getIndex: (id<CPConstraint>) resource
{
    ORInt idx = _res.low;
    for (; idx <= _res.up; idx++)
        if (_res[idx] == resource)
            return idx;
    // Program never should reach this point
    assert(false);
    return ++idx;
}
@end

@implementation CPOptionalResourceTask
{
    id<CPResourceArray> _res;
    id<ORIntRangeArray> _durArray;
//    id<ORIntArray> _usageArray;
//    TRInt   _usageMin;
//    TRInt   _usageMax;
    ORInt * _index;
    TRInt   _uSize;
    ORInt   _size;
    TRInt   _bind;
}
-(id<CPResourceTask>) initCPOptionalResourceTask:(id<CPEngine>)engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration durationArray:(id<ORIntRangeArray>)durationArray runsOnOneOf:(id<CPResourceArray>)resources
{
    assert(durationArray.low == resources.low);
    assert(durationArray.up  == resources.up );
    self = [super initCPOptionalTaskVar:engine horizon:horizon duration:duration];
    _res = resources;
    _durArray = durationArray;
//    _usageArray = 0;
    _size = (ORInt)[resources count];
    _index = NULL;
    _index = malloc(_size * sizeof(ORInt));
    if (_index == NULL)
        @throw [[ORExecutionError alloc] initORExecutionError: "CPResourceTask: Out of memory!"];
//    _usageMin = makeTRInt(_trail, 0);
//    _usageMax = makeTRInt(_trail, 0);
    _uSize = makeTRInt(_trail, _size);
    _bind  = makeTRInt(_trail, 0);
    
    // Initialisation of the index array
    for (ORInt i = 0; i < _size; i++)
        _index[i] = i + _res.low;
    
    return self;
}
-(void) dealloc
{
    if (_index != NULL) free(_index);
    [super dealloc];
}
-(id<CPResourceArray>) resources
{
    return _res;
}
-(void) set:(id<CPConstraint>) resource at:(ORInt)idx
{
    assert(_res.low <= idx && idx <= _res.up);
    assert([resource isMemberOfClass: [CPTaskDisjunctive class]] || [resource isMemberOfClass: [CPTaskCumulative class]]);
    [_res set:resource at:idx];
}
-(id<ORIntArray>) getAvailResources
{
    // XXX Maybe sort in order to return in the same order
    return [ORFactory intArray:_engine range:RANGE(_engine, 0, _uSize._val) with:^ORInt(ORInt k) {return _index[k];}];
}
-(const ORInt *) getInternalIndexArray:(ORInt *)size
{
    *size = _uSize._val;
    return _index;
}
-(ORBool) isAssigned
{
    if ([self isAbsent])
        @throw [[ORExecutionError alloc] initORExecutionError: "The task is absent"];
    return ([self isPresent] && _uSize._val == 1);
}
-(ORBool) bound
{
    if (_uSize._val > 1)
        return false;
    return [super bound];
}
-(ORBool) isPresentOn: (id<CPConstraint>) resource
{
    return (_uSize._val == 1 && [self isPresent] && _index[0] == [self getIndex:resource]);
}
-(ORBool) isAbsentOn: (id<CPConstraint>) resource
{
    if (_uSize._val == 0)
        return TRUE;
    const ORInt idx = [self getIndex:resource];
    for (ORInt i = 0; i < _uSize._val; i++)
        if (_index[i] == idx)
            return FALSE;
    return TRUE;
}
-(ORInt) runsOn
{
    if ([self isAbsent])
        @throw [[ORExecutionError alloc] initORExecutionError: "The task is absent"];
    else if (_uSize._val != 1)
            @throw [[ORExecutionError alloc] initORExecutionError: "The task is not assigned to any resource"];
    return _index[0];
}
-(ORBool) readEst:(ORInt *)est lst:(ORInt *)lst ect:(ORInt *)ect lct:(ORInt *)lct minDuration:(ORInt *)minD maxDuration:(ORInt *)maxD present:(ORBool *)present absent:(ORBool *)absent forResource:(id<CPConstraint>) resource
{
    [super readEst:est lst:lst ect:ect lct:lct minDuration:minD maxDuration:maxD present:present absent:absent forResource:resource];
    const ORInt idx = [self getIndex:resource];
    *minD    = max(*minD, [_durArray at: idx].low);
    *maxD    = min(*maxD, [_durArray at: idx].up );
    *present = [self isPresentOn:resource];
    *absent  = [self isAbsentOn :resource];
   return [self bound    ];
}
-(void) labelPresent: (ORBool) present
{
    [super labelPresent:present];
    if (!present)
        assignTRInt(&(_uSize), 0, _trail);
    else if (present && _uSize._val == 1)
        [self bindWithIndex:_index[0]];
}
-(void) labelDuration: (ORInt) duration
{
    [super labelDuration: duration];
    if (_presentMax._val == 0)
        [self labelPresent: FALSE];
    [self updateMinDuration: duration];
    [self updateMaxDuration: duration];
}
-(void) updateMinDuration:(ORInt)newMinDuration
{
    if (_presentMax._val > 0 && newMinDuration > [_task minDuration]) {
        [super updateMinDuration:newMinDuration];
        if (_presentMax._val == 0)
            [self labelPresent: FALSE];
        ORInt uSize = _uSize._val;
        for (ORInt i = 0; i < uSize; i++) {
            const ORInt idx = _index[i];
            if ([_durArray at:idx].up < newMinDuration) {
                uSize--;
                _index[i]     = _index[uSize];
                _index[uSize] = idx;
            }
        }
        if (uSize == 0)
            [self labelPresent: FALSE];
        if (uSize < _uSize._val)
            assignTRInt(&(_uSize), uSize, _trail);
        if (uSize == 1 && [self isPresent] && !_bind._val)
            [self bindWithIndex:_index[0]];
    }
}
-(void) updateMaxDuration:(ORInt)newMaxDuration
{
    if (_presentMax._val > 0 && newMaxDuration < [_task maxDuration]) {
        [super updateMaxDuration:newMaxDuration];
        if (_presentMax._val == 0)
            [self labelPresent: FALSE];
        ORInt uSize = _uSize._val;
        for (ORInt i = 0; i < uSize; i++) {
            const ORInt idx = _index[i];
            if ([_durArray at:idx].low > newMaxDuration) {
                uSize--;
                _index[i]     = _index[uSize];
                _index[uSize] = idx;
            }
        }
        if (uSize == 0)
            [self labelPresent: FALSE];
        if (uSize < _uSize._val)
            assignTRInt(&(_uSize), uSize, _trail);
        if (uSize == 1 && [self isPresent] && !_bind._val)
            [self bindWithIndex:_index[0]];
    }
}
//-(void) updateMinUsage:(ORInt)newMinUsage
//{
//    assert(false);
//    if (newMinUsage > _usageMin._val) {
//        // Update usage
//        if (newMinUsage > _usageMax._val)
//            failNow();
//        // TODO trigger propagation events
////        [self changeDurationEvt];
//        assignTRInt(&_usageMin, newMinUsage, _trail);
//        // Update resource task
//        ORInt uSize = _uSize._val;
//        for (ORInt i = 0; i < uSize; i++) {
//            const ORInt idx = _index[i];
//            if ([_usageArray at:idx] < newMinUsage) {
//                uSize--;
//                _index[i]     = _index[uSize];
//                _index[uSize] = idx;
//            }
//        }
//        if (uSize == 0)
//            [self labelPresent: FALSE];
//        if (uSize < _uSize._val)
//            assignTRInt(&(_uSize), uSize, _trail);
//        if (uSize == 1 && [self isPresent] && !_bind._val)
//            [self bindWithIndex:_index[0]];
//    }
//}
//-(void) updateMaxUsage:(ORInt)newMaxUsage
//{
//    assert(false);
//    if (newMaxUsage < _usageMax._val) {
//        // Update max usage
//        if (newMaxUsage < _usageMin._val)
//            failNow();
//        // TODO trigger propagation events
////        [self changeDurationEvt];
//        assignTRInt(&_usageMax, newMaxUsage, _trail);
//        // Update resource task
//        ORInt uSize = _uSize._val;
//        for (ORInt i = 0; i < uSize; i++) {
//            const ORInt idx = _index[i];
//            if ([_usageArray at:idx] > newMaxUsage) {
//                uSize--;
//                _index[i]     = _index[uSize];
//                _index[uSize] = idx;
//            }
//        }
//        if (uSize == 0)
//            [self labelPresent: FALSE];
//        if (uSize < _uSize._val)
//            assignTRInt(&(_uSize), uSize, _trail);
//        if (uSize == 1 && [self isPresent] && !_bind._val)
//            [self bindWithIndex:_index[0]];
//    }
//}
-(void) bind: (id<CPConstraint>) resource
{
    const ORInt idx = [self getIndex:resource];
    [self bindWithIndex: idx];
}
-(void) bindWithIndex: (const ORInt) idx
{
    [self labelPresent:TRUE];
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
        [self updateMinDuration:[_durArray   at: idx].low];
        [self updateMaxDuration:[_durArray   at: idx].up ];
//        [self updateMinUsage   :[_usageArray at: idx]];
//        [self updateMaxUsage   :[_usageArray at: idx]];
        // TODO queue propagator
        if ([_res[idx] isMemberOfClass: [CPTaskDisjunctive class]])
            [(CPTaskDisjunctive*)_res[idx] propagate];
        else {
            assert([_res[idx] isMemberOfClass: [CPTaskCumulative class]]);
            [(CPTaskCumulative*)_res[idx] propagate];
        }
    }
}
-(void) remove: (id<CPConstraint>) resource
{
    const ORInt idx = [self getIndex: resource];
    [self removeWithIndex:idx];
}
-(void) removeWithIndex: (const ORInt) idx
{
    if (_uSize._val == 0)
        return;

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
    if (_uSize._val == 0)
        [self labelPresent: FALSE];
    else if (_uSize._val == 1 && [self isPresent]) {
        assert(!_bind._val);
        [self bindWithIndex:_index[0]];
    }
    else if (newDur) {
        if ([_task minDuration] < [_task maxDuration]) {
            // XXX With "watches" on the disjunctive holding the minimal and maximal
            // duration the above test can be refined
            
            // Checking for new duration bounds
            ORInt minDur = MAXINT;
            ORInt maxDur = MININT;
            for (ORInt i = 0; i < _uSize._val; i++) {
                minDur = min(minDur, [_durArray at: _index[i]].low);
                maxDur = max(maxDur, [_durArray at: _index[i]].up );
            }
            assert(minDur < MAXINT);
            assert(maxDur > MININT);
            [self updateMinDuration:minDur];
            [self updateMaxDuration:maxDur];
        }
//        // Currently, their is no resource usage in the concept of a task
//        if (_usageMin._val < _usageMax._val) {
//            // Checking for new usage bounds
//            ORInt minUsage = MAXINT;
//            ORInt maxUsage = MININT;
//            for (ORInt i = 0; i < _uSize._val; i++) {
//                minUsage = min(minUsage, [_usageArray at: _index[i]]);
//                maxUsage = max(maxUsage, [_usageArray at: _index[i]]);
//            }
//            assert(minUsage < MAXINT);
//            assert(maxUsage > MININT);
//            [self updateMinUsage:minUsage];
//            [self updateMaxUsage:maxUsage];
//        }
    }
}
-(ORInt) getIndex: (id<CPConstraint>) resource
{
    ORInt idx = _res.low;
    for (; idx <= _res.up; idx++)
        if (_res[idx] == resource)
            return idx;
    // Program never should reach this point
    assert(false);
    return ++idx;
}
@end
