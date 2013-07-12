/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPFloatVarI.h"
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPEngineI.h>
#import "CPFloatDom.h"

static void setUpNetwork(CPFloatEventNetwork* net,id<ORTrail> t)
{
   net->_bindEvt   = makeTRId(t,nil);
   net->_minEvt    = makeTRId(t,nil);
   net->_maxEvt    = makeTRId(t,nil);
}

static void deallocNetwork(CPFloatEventNetwork* net)
{
   freeList(net->_bindEvt._val);
   freeList(net->_minEvt._val);
   freeList(net->_maxEvt._val);
}

static NSMutableSet* collectConstraints(CPFloatEventNetwork* net,NSMutableSet* rv)
{
   collectList(net->_bindEvt._val,rv);
   collectList(net->_minEvt._val,rv);
   collectList(net->_maxEvt._val,rv);
   return rv;
}

@implementation CPFloatVarI

-(id)initCPFloatVar:(CPEngineI*)engine low:(ORFloat)low up:(ORFloat)up
{
   self = [super init];
   _engine = engine;
   _dom = [[CPFloatDom alloc] initCPFloatDom:[engine trail] low:low up:up];
   _recv = nil;
   setUpNetwork(&_net, [engine trail]);
   [_engine trackVariable: self];
   return self;
}
-(CPEngineI*) engine
{
   return _engine;
}
-(CPEngineI*) tracker
{
   return _engine;
}
-(NSMutableSet*)constraints
{
   NSMutableSet* rv = collectConstraints(&_net,[[NSMutableSet alloc] initWithCapacity:2]);
   return rv;
}
-(void)setDelegate:(id<CPFloatVarNotifier>)delegate
{}
-(void) addVar:(CPFloatVarI*)var
{}
-(enum CPVarClass)varClass
{
   return CPVCBare;
}
-(CPFloatVarI*)findAffine:(ORInt)scale shift:(ORInt)shift
{
   return nil;
}

-(void) whenBindDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._bindEvt, todo, c, p);
}
-(void) whenChangeMinDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._minEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._maxEvt, todo, c, p);
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._boundsEvt, todo, c, p);
}
-(void) whenBindDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenBindDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMinDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMinDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMaxDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMaxDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeBoundsDo: (ConstraintCallback) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeBoundsDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
// AC3 Constraint Event
-(void) whenBindPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._bindEvt, nil, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._minEvt, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._maxEvt, nil, c, p);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._boundsEvt, nil, c, p);
}
-(void) whenBindPropagate: (CPCoreConstraint*) c
{
   [self whenBindPropagate:c priority:HIGHEST_PRIO];
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c
{
   [self whenChangeMinPropagate:c priority:HIGHEST_PRIO];
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c
{
   [self whenChangeMaxPropagate:c priority:HIGHEST_PRIO];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c
{
   [self whenChangeBoundsPropagate:c priority:HIGHEST_PRIO];
}

-(ORStatus) bindEvt:(id<CPFDom>)sender
{
   id<CPEventNode> mList[6];
   ORUInt k = 0;
   mList[k] = _net._bindEvt._val;
   k += mList[k] != NULL;
   scheduleAC3(_engine,mList);
   return ORSuspend;
}
-(ORStatus) changeMinEvt:(ORBool) bound sender:(id<CPFDom>)sender
{
   id<CPEventNode> mList[6];
   ORUInt k = 0;
   mList[k] = _net._minEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt._val;
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt._val : NULL;
   k += mList[k] != NULL;
   scheduleAC3(_engine,mList);
   return ORSuspend;
}
-(ORStatus) changeMaxEvt:(ORBool) bound sender:(id<CPFDom>)sender
{
   id<CPEventNode> mList[6];
   ORUInt k = 0;
   mList[k] = _net._maxEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt._val;
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt._val : NULL;
   k += mList[k] != NULL;
   scheduleAC3(_engine,mList);
   return ORSuspend;
}

-(ORStatus) bind:(ORFloat) val
{
   return [_dom bind:val for:self];
}
-(ORStatus) updateMin: (ORFloat) newMin
{
   return [_dom updateMin:newMin for:self];
}
-(ORStatus) updateMax: (ORFloat) newMax
{
   return [_dom updateMax:newMax for:self];
}
-(ORStatus) updateInterval: (ORInterval)nb
{
   return [_dom updateInterval:nb for:self];
}
-(ORFloat) min
{
   return [_dom min];
}
-(ORFloat) max
{
   return [_dom max];
}
-(ORFloat) value
{
   assert([_dom bound]);
   return [_dom min];
}
-(ORInterval) bounds
{
   return [_dom bounds];
}
-(ORBool) member:(ORFloat)v
{
   return [_dom member:v];
}
-(ORBool) bound
{
   return [_dom bound];
}
@end
