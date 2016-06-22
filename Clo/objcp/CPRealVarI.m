/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPRealVarI.h"
#import <CPUKernel/CPUKernel.h>
#import "CPRealDom.h"

/*****************************************************************************************/
/*                        CPRealVarSnapshot                                              */
/*****************************************************************************************/

@interface CPRealVarSnapshot : NSObject
{
   ORUInt    _name;
   ORDouble   _value;
   ORBool    _bound;
}
-(CPRealVarSnapshot*) init: (CPRealVarI*) v name: (ORInt) name;
-(ORUInt) getId;
-(ORDouble) doubleValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation CPRealVarSnapshot
-(CPRealVarSnapshot*) init: (CPRealVarI*) v name: (ORInt) name
{
   self = [super init];
   _name = name;
   if ([v bound]) {
      _bound = TRUE;
      _value = [v value];
   }
   else {
      _value = 0.0;
      _bound = FALSE;
   }
   return self;
}
-(ORDouble) doubleValue
{
   return _value;
}
-(ORBool) bound
{
   return _bound;
}
-(ORUInt) getId
{
   return _name;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      CPRealVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value && _bound == other->_bound;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger)hash
{
   return (_name << 16) + (ORInt) _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"real(%d) : %f",_name,_value];
   return buf;
}
- (void) encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_bound];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_bound];
   return self;
}
@end

static void setUpNetwork(CPRealEventNetwork* net,id<ORTrail> t)
{
   net->_bindEvt   = makeTRId(t,nil);
   net->_minEvt    = makeTRId(t,nil);
   net->_maxEvt    = makeTRId(t,nil);
}

static void deallocNetwork(CPRealEventNetwork* net)
{
   freeList(net->_bindEvt);
   freeList(net->_minEvt);
   freeList(net->_maxEvt);
}

static NSMutableSet* collectConstraints(CPRealEventNetwork* net,NSMutableSet* rv)
{
   collectList(net->_bindEvt,rv);
   collectList(net->_minEvt,rv);
   collectList(net->_maxEvt,rv);
   return rv;
}

@implementation CPRealVarI

-(id)init:(CPEngineI*)engine low:(ORDouble)low up:(ORDouble)up
{
   self = [super init];
   _engine = engine;
   _dom = [[CPRealDom alloc] initCPRealDom:[engine trail] low:low up:up];
   _recv = nil;
   _hasValue = false;
   _value = 0.0;  
   setUpNetwork(&_net, [engine trail]);
   [_engine trackVariable: self];
   return self;
}
-(void)dealloc
{
   deallocNetwork(&_net);
   [super dealloc];
}
-(CPEngineI*) engine
{
   return _engine;
}
-(CPEngineI*) tracker
{
   return _engine;
}
-(id) takeSnapshot: (ORInt) id
{
   return [[CPRealVarSnapshot alloc] init: self name: id];
}
-(NSMutableSet*)constraints
{
   NSMutableSet* rv = collectConstraints(&_net,[[NSMutableSet alloc] initWithCapacity:2]);
   return rv;
}
-(ORInt)degree
{
   __block ORUInt d = 0;
   [_net._bindEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)   { d += [cstr nbVars] - 1;}];
   [_net._maxEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._minEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   return d;
}
-(NSString*)description
{
   ORIReady();
   double a,b;
   ORIBounds([_dom bounds], &a, &b);
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var<%d>=",_name];
   [buf appendString:[_dom description]];
   [buf appendFormat:@"(relaxValue:%f)",_value];
   return buf;
}
-(void)setDelegate:(id<CPRealVarNotifier>)delegate
{}
-(void) addVar:(CPRealVarI*)var
{}
-(enum CPVarClass)varClass
{
   return CPVCBare;
}
-(CPRealVarI*) findAffine: (ORDouble) scale shift:(ORDouble) shift
{
   return nil;
}

-(void) whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._bindEvt, todo, c, p);
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._minEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._maxEvt, todo, c, p);
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._boundsEvt, todo, c, p);
}
-(void) whenBindDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenBindDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMinDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMinDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMaxDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMaxDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeBoundsDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
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
   [self whenBindPropagate:c priority:c->_priority];
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c
{
   [self whenChangeMinPropagate:c priority:c->_priority];
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c
{
   [self whenChangeMaxPropagate:c priority:c->_priority];
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c
{
   [self whenChangeBoundsPropagate:c priority:c->_priority];
}

-(void) bindEvt:(id<CPFDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._bindEvt;
   k += mList[k] != NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMinEvt:(ORBool) bound sender:(id<CPFDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._minEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPFDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._maxEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   scheduleClosures(_engine,mList);
}

-(void) bind:(ORDouble) val
{
   [_dom bind:val for:self];
}
-(void) updateMin: (ORDouble) newMin
{
   [_dom updateMin:newMin for:self];
}
-(void) updateMax: (ORDouble) newMax
{
   [_dom updateMax:newMax for:self];
}
-(ORNarrowing) updateInterval: (ORInterval) nb
{
   return [_dom updateInterval:nb for:self];
}
-(ORDouble) min
{
   return [_dom min];
}
-(ORDouble) max
{
   return [_dom max];
}
-(ORDouble) doubleMin
{
   return [_dom min];
}
-(ORDouble) doubleMax
{
   return [_dom max];
}
-(ORDouble) value
{
   if ([_dom bound])
      return [_dom min];
   return _value;
}
-(ORDouble) doubleValue
{
   if ([_dom bound])
      return [_dom min];
   return _value;
}
-(void) assignRelaxationValue: (ORDouble) f
{
   if (f < [_dom min] && f > [_dom max])
      @throw [[ORExecutionError alloc] initORExecutionError: "Assigning a relaxation value outside the bounds"];
   _value = f;
}
-(ORInterval) bounds
{
   return [_dom bounds];
}
-(ORBool) member:(ORDouble)v
{
   return [_dom member:v];
}
-(ORBool) bound
{
   return [_dom bound];
}
-(ORDouble) domwidth
{
   return [_dom domwidth];
}
@end

@implementation CPRealViewOnIntVarI
-(id)init:(id<CPEngine>)engine intVar:(CPIntVar*)iv
{
   self = [super init];
   _engine = (id)engine;
   _theVar = iv;
   setUpNetwork(&_net, [engine trail]);
   [_engine trackVariable: self];
   CPMultiCast* xDeg = [iv delegate];
   if (xDeg == nil) {
      CPMultiCast* mc = [[CPMultiCast alloc] initVarMC:2 root:iv];
      [mc addVar: self];
      [mc release]; // we no longer need the local ref. The addVar call has increased the retain count.
   }
   else {
      [xDeg addVar:self];
   }
   return self;
}
-(CPEngineI*) engine
{
   return _engine;
}
-(id<ORTracker>) tracker
{
   return [_engine tracker];
}
-(NSMutableSet*)constraints
{
   NSMutableSet* rv = collectConstraints(&_net,[[NSMutableSet alloc] initWithCapacity:2]);
   return rv;
}
-(ORInt)degree
{
   __block ORUInt d = 0;
   [_net._bindEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)   { d += [cstr nbVars] - 1;}];
   [_net._maxEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._minEvt scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   return d;
}
-(NSString*)description
{
   ORIReady();
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var(view)<%d>=",_name];
   [buf appendString:[_theVar description]];
   return buf;
}
-(void) whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._bindEvt, todo, c, p);
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._minEvt, todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._maxEvt, todo, c, p);
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._boundsEvt, todo, c, p);
}
-(void) whenBindDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenBindDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMinDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMinDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeMaxDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
{
   [self whenChangeMaxDo:todo priority:HIGHEST_PRIO onBehalf:c];
}
-(void) whenChangeBoundsDo: (ORClosure) todo onBehalf:(CPCoreConstraint*)c
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
-(void) setDelegate:(id<CPRealVarNotifier>)delegate
{
}
-(void) addVar:(CPRealVarI*)var
{
}
-(enum CPVarClass)varClass
{
   return CPVCCast;
}
-(CPIntVarI*) findAffine:(ORInt)scale shift:(ORInt)shift
{
   return nil;
}
// ----------------------------------------------------------------------------------------------------

-(void) setTracksLoseEvt
{
}
-(ORBool) tracksLoseEvt
{
   return NO;
}
-(void) loseValEvt: (ORInt) val sender:(id<CPDom>)sender
{

}

-(void) bindEvt: (id<CPFDom>) sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._minEvt;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = _net._bindEvt;
   k += mList[k] != NULL;
   scheduleClosures(_engine,mList);
}
-(void) domEvt:(id<CPDom>)sender
{
   // [ldm]. There is nothing to do here. We lost a value _inside_ the domain, but realVars are intervals
   // So no hope of propagating. 
}
-(void) changeMinEvt: (ORInt) dsz sender: (id<CPDom>) sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._minEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = (dsz==1) ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMaxEvt:(ORInt) dsz sender:(id<CPFDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._maxEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = (dsz==1) ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   scheduleClosures(_engine,mList);
}

-(void) bind:(ORDouble) val
{
   [_theVar updateMin:(ORInt)ceil(val) andMax:(ORInt)floor(val)];
}
-(void) updateMin: (ORDouble) newMin
{
   [_theVar updateMin:(ORInt)ceil(newMin)];
}
-(void) updateMax: (ORDouble) newMax
{
   [_theVar updateMax:(ORInt)floor(newMax)];
}
-(ORNarrowing) updateInterval: (ORInterval) nb
{
   double a,b;
   ORIBounds(nb, &a, &b);
   ORBounds bb = [_theVar bounds];
   [_theVar updateMin: (ORInt) ceil(a) andMax: (ORInt) floor(b)];
   ORBounds ba = [_theVar bounds];
   if (ba.min > bb.min && ba.max < bb.max) 
      return ORBoth;
   else if (ba.min > bb.min) 
      return ORLow;
   else if (ba.max < bb.max) 
      return ORUp;
   else
      return ORNone;
}
-(ORDouble) min
{
   return [_theVar min];
}
-(ORDouble) max
{
   return [_theVar max];
}
-(ORDouble) value
{
   return [_theVar min];
}
-(ORDouble)doubleValue
{
   return [_theVar min];
}
-(void) assignRelaxationValue: (ORDouble) f
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Assigning a relaxation value on a view"];
}
-(ORInterval) bounds
{
   ORBounds b = [_theVar bounds];
   return createORI2(b.min, b.max);
}
-(ORBool) member:(ORDouble)v
{
   ORDouble tv = trunc(v);
   if (tv == v)
      return [_theVar member:(ORInt)tv];
   else return NO;
}
-(ORBool) bound
{
   return [_theVar bound];
}
-(ORDouble) domwidth
{
   ORBounds b = [_theVar bounds];
   return b.max - b.min;
}
@end

@implementation CPRealParamI
-(id)initCPRealParam:(id<CPEngine>)engine initialValue:(ORDouble)v
{
    self = [super init];
    _engine = (CPEngineI*)engine;
    _value = v;
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
-(NSMutableSet*) constraints
{
    return [NSMutableSet set];
}
-(ORDouble) value
{
    return _value;
}
-(void) setValue: (ORDouble)val
{
    _value = val;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<PARAM(%d) = %lf>",_name,_value];
   return buf;
}
@end
