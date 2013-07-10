/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPFloatVarI.h"
#import <CPUKernel/CPUKernel.h>

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

@implementation CPFloatVarI {
   ORFloat _ilow;
   ORFloat _iup;
}
-(id)initCPFloatVar:(CPEngineI*)engine low:(ORFloat)low up:(ORFloat)up
{
   self = [super init];
   _engine = engine;
   _ilow = low;
   _iup = up;
   _dom = nil;
   _recv = nil;
   setUpNetwork(&_net, [engine trail]);
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


-(ORStatus) bindEvt:(id<CPFDom>)sender
{
   return ORSuspend;
}
-(ORStatus) changeMinEvt:(ORBool) bound sender:(id<CPFDom>)sender
{
   return ORSuspend;
}
-(ORStatus) changeMaxEvt:(ORBool) bound sender:(id<CPFDom>)sender
{
   return ORSuspend;
}

-(ORStatus) bind:(ORFloat) val
{
   return ORSuspend;
}
-(ORStatus) updateMin: (ORFloat) newMin
{
   return ORSuspend;
}
-(ORStatus) updateMax: (ORFloat) newMax
{
   return ORSuspend;
}
-(ORStatus) updateInterval: (ORInterval)nb
{
   return ORSuspend;
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
