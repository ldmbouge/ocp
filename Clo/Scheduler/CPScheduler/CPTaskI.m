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

typedef struct  {
   TRId _anyEvt[2];
   TRId _startEvt[2];
   TRId _endEvt[2];
} CPTaskVarEventNetwork;

@implementation CPTaskVar
{
   CPEngineI*         _engine;
   id<ORTrail>        _trail;
   id<ORIntRange>     _horizon;
   ORInt              _duration;
   TRInt              _startMin;
   TRInt              _startMax;
   TRInt              _endMin;
   TRInt              _endMax;
   CPTaskVarEventNetwork _net;
}
-(id<CPTaskVar>) initCPTaskVar: (CPEngineI*) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   self = [super init];
   _engine = engine;
   _trail = [engine trail];
   
   // domain [who said I do not write comments?]
   _startMin = makeTRInt(_trail,horizon.low);
   _startMax = makeTRInt(_trail,horizon.up - duration);
   _endMin = makeTRInt(_trail,horizon.low + duration);
   _endMax = makeTRInt(_trail,horizon.up);
   _duration = duration;
   
   // network
   for(ORInt i = 0;i < 2;i++) {
      _net._anyEvt[i] = makeTRId(_trail,nil);
      _net._startEvt[i] = makeTRId(_trail,nil);
      _net._endEvt[i] = makeTRId(_trail,nil);
   }
   return self;
}
-(ORInt) est
{
   return _startMin._val;
}
-(ORInt) lst
{
   return _startMax._val;
}
-(ORInt) ect
{
   return _endMin._val;
}
-(ORInt) lct
{
   return _endMax._val;
}
-(ORInt) minDuration
{
   return _duration;
}
-(ORInt) maxDuration
{
   return _duration;
}
-(ORBool) bound
{
   return _startMin._val == _startMax._val;
}
-(void) updateStart: (ORInt) newStart
{
   if (newStart > _startMin._val) {
      if (newStart > _startMax._val)
         failNow();
      [self changeStartEvt];
      assignTRInt(&_startMin,newStart,_trail);
      assignTRInt(&_endMin,newStart+_duration,_trail);
   }
}
-(void) updateEnd: (ORInt) newEnd
{
   if (newEnd < _endMax._val) {
      if (newEnd < _endMin._val)
         failNow();
      [self changeEndEvt];
      assignTRInt(&_endMax,newEnd,_trail);
      assignTRInt(&_startMax,newEnd-_duration,_trail);
   }
}
-(void) updateMinDuration: (ORInt) newMinDuration
{
   if (newMinDuration != _duration)
      failNow();
}
-(void) updateMaxDuration: (ORInt) newMaxDuration
{
   if (newMaxDuration != _duration)
      failNow();
}
-(NSString*) description
{
   if ([self bound])
      return [NSString stringWithFormat:@"[%d -(%d)-> %d]",_startMin._val,_duration,_endMin._val];
   else
      return [NSString stringWithFormat:@"[%d..%d -(%d)-> %d..%d]",_startMin._val,_startMax._val,_duration,_endMin._val,_endMax._val];
}


// AC3 Closure Event
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   hookupEvent(_engine, _net._anyEvt, todo, c, p);
}
-(void) whenChangeStartDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   hookupEvent(_engine, _net._startEvt, todo, c, p);
}
-(void) whenChangeEndDo: (ORClosure) todo priority: (ORInt) p onBehalf: (id<CPConstraint>) c
{
   hookupEvent(_engine, _net._endEvt, todo, c, p);
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

// AC3 Constraint Event
-(void) whenChangePropagate:  (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._anyEvt, nil, c, p);
}
-(void) whenChangeStartPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._startEvt, nil, c, p);
}
-(void) whenChangeEndPropagate: (id<CPConstraint>) c priority: (ORInt) p
{
   hookupEvent(_engine, _net._endEvt, nil, c, p);
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

-(void) changeStartEvt
{
   id<CPClosureList> mList[2];
   ORUInt k = 0;
   mList[k] = _net._anyEvt[0]._val;
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
   mList[k] = _net._anyEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = _net._endEvt[0]._val;
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
   collectList(_net._anyEvt[0]._val,rv);
   collectList(_net._startEvt[0]._val,rv);
   collectList(_net._endEvt[0]._val,rv);
   return rv;
}
-(ORInt) degree
{
   __block ORUInt d = 0;
   [_net._anyEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._startEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   [_net._endEvt[0]._val scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   return d;
}

@end
