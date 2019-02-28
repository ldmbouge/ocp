/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPDoubleVarI.h"
#import <CPUKernel/CPUKernel.h>
#import <objcp/CPDoubleDom.h>

@protocol ORSplitVisitor;
@protocol ORAbsVisitor;

typedef struct  {
   TRId           _bindEvt[2];
   TRId            _minEvt[2];
   TRId            _maxEvt[2];
   TRId         _boundsEvt[2];
} CPDoubleEventNetwork;

/*****************************************************************************************/
/*                        CPDoubleVarSnapshot                                              */
/*****************************************************************************************/

@interface CPDoubleVarSnapshot : NSObject
{
   ORUInt    _name;
   ORDouble   _value;
   ORBool    _bound;
}
-(CPDoubleVarSnapshot*) init: (CPDoubleVarI*) v name: (ORInt) name;
-(ORUInt) getId;
-(ORDouble) doubleValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation CPDoubleVarSnapshot
-(CPDoubleVarSnapshot*) init: (CPDoubleVarI*) v name: (ORInt) name
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
      CPDoubleVarSnapshot* other = object;
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
   [buf appendFormat:@"Double(%d) : %f",_name,_value];
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

static void setUpNetwork(CPDoubleEventNetwork* net,id<ORTrail> t)
{
    for(int i=0;i<2;i++) {
        net->_bindEvt[i]   = makeTRId(t,nil);
        net->_minEvt[i]    = makeTRId(t,nil);
        net->_maxEvt[i]    = makeTRId(t,nil);
        net->_boundsEvt[i] = makeTRId(t,nil);
    }
}

static void deallocNetwork(CPDoubleEventNetwork* net)
{
   freeList(net->_bindEvt[0]);
   freeList(net->_minEvt[0]);
   freeList(net->_maxEvt[0]);
   freeList(net->_boundsEvt[0]);
}

static id<OROSet> collectConstraints(CPDoubleEventNetwork* net,id<OROSet> rv)
{
   collectList(net->_bindEvt[0],rv);
   collectList(net->_minEvt[0],rv);
   collectList(net->_maxEvt[0],rv);
   collectList(net->_boundsEvt[0],rv);
   return rv;
}

@implementation CPDoubleVarI {
   CPDoubleEventNetwork      _net;
}

-(id)init:(CPEngineI*)engine low:(ORDouble)low up:(ORDouble)up
{
   self = [super init];
   _engine = engine;
   _dom = [[CPDoubleDom alloc] initCPDoubleDom:[engine trail] low:low up:up];
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
   return [[CPDoubleVarSnapshot alloc] init: self name: id];
}
-(id<OROSet>)constraints
{
   id<OROSet> rv = collectConstraints(&_net,[ORFactory objectSet]);
   return rv;
}
-(ORInt)degree
{
   __block ORUInt d = 0;
   [_net._bindEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)   { d += [cstr nbVars] - 1;}];
   [_net._maxEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._minEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._boundsEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   return d;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var<%d>=",_name];
   [buf appendString:[_dom description]];
   return buf;
}
-(void)setDelegate:(id<CPDoubleVarNotifier>)delegate
{}
-(void) addVar:(CPDoubleVarI*)var
{}
-(enum CPVarClass)varClass
{
   return CPVCBare;
}
-(CPDoubleVarI*) findAffine: (ORDouble) scale shift:(ORDouble) shift
{
   return nil;
}
-(void) whenBindDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._bindEvt[0], todo, c, p);
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._minEvt[0], todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._maxEvt[0], todo, c, p);
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._boundsEvt[0], todo, c, p);
}
- (void)whenChangeDo:(ORClosure)todo priority:(ORInt)p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._boundsEvt[0], todo, c, p);
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
   hookupEvent((id)_engine, &_net._bindEvt[0], nil, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._minEvt[0], nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._maxEvt[0], nil, c, p);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._boundsEvt[0], nil, c, p);
}
- (void)whenChangePropagate:(CPCoreConstraint*)c priority:(ORInt)p
{
   hookupEvent((id)_engine, &_net._boundsEvt[0], nil, c, p);
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
- (void)whenChangePropagate:(id<CPConstraint>)c
{
   [self whenChangePropagate: c priority:HIGHEST_PRIO];
}
- (void)whenChangeDo:(ORClosure)todo onBehalf:(id<CPConstraint>)c
{
   [self whenChangeDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) bindEvt:(id<CPDoubleDom>)sender
{
   id<CPClosureList> mList[3];
   ORUInt k = 0;
   mList[k] = _net._bindEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMinEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._minEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt[0] : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPDoubleDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._maxEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt[0] : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) bind:(ORDouble) val
{
   [_dom bind:val for:self];
}
-(void) updateMin: (ORDouble) newMin
{
   if(newMin > [self min] || (is_plus_zero(newMin) &&  is_minus_zero([self min])))
      [_dom updateMin:newMin for:self];
}
-(void) updateMax: (ORDouble) newMax
{
   if(newMax < [self max] || (is_plus_zero([self max]) &&  is_minus_zero(newMax)))
      [_dom updateMax:newMax for:self];
}
-(void) updateInterval: (ORDouble) newMin and:(ORDouble)newMax
{
   if(newMin > newMax || (is_plus_zero(newMin) && is_minus_zero(newMax)))
      failNow();
   [self updateMin:newMin];
   [self updateMax:newMax];
}
-(ORDouble) min
{
   return [_dom min];
}
-(ORDouble) max
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
-(id<CPDoubleDom>) domain
{
   return [_dom retain];
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
- (ORInt)domsize
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPDoubleVar: method domsize  not defined"];
   return 0;
}
- (ORBool)sameDomain:(CPDoubleVarI*)x
{
   return [_dom isEqual:x->_dom];
}
- (void)subsumedBy:(id<CPDoubleVar>)x
{
   [self updateInterval:[x min] and:[x max]];
}
- (void)subsumedByDomain:(id<CPDoubleDom>)dom
{
   [self updateInterval:[dom min] and:[dom max]];
}
-(ORLDouble) domwidth
{
   return [_dom domwidth];
}
-(ORDouble) magnitude
{
   return [_dom magnitude];
}
- (void)visit:(id<ORSplitVisitor>)visitor
{
   [(id)visitor applyDoubleSplit:self];
}
- (void)visitAbs:(id<ORAbsVisitor>)visitor
{
   [(id)visitor applyDoubleAbs:self];
}
@end

@implementation CPDoubleViewOnIntVarI {
   CPDoubleEventNetwork _net;
}

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
-(id<OROSet>)constraints
{
   id<OROSet> rv = collectConstraints(&_net,[ORFactory objectSet]);
   return rv;
}
-(ORInt)degree
{
   __block ORUInt d = 0;
   [_net._bindEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)   { d += [cstr nbVars] - 1;}];
   [_net._maxEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
   [_net._minEvt[0] scanCstrWithBlock:^(CPCoreConstraint* cstr)    { d += [cstr nbVars] - 1;}];
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
   hookupEvent((id)_engine, &_net._bindEvt[0], todo, c, p);
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._minEvt[0], todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._maxEvt[0], todo, c, p);
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent((id)_engine, &_net._boundsEvt[0], todo, c, p);
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
   hookupEvent((id)_engine, &_net._bindEvt[0], nil, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._minEvt[0], nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._maxEvt[0], nil, c, p);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
   hookupEvent((id)_engine, &_net._boundsEvt[0], nil, c, p);
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
- (void)whenChangeDo:(ORClosure)todo onBehalf:(id<CPConstraint>)c
{
}
- (void)whenChangeDo:(ORClosure)todo priority:(ORInt)p onBehalf:(id<CPConstraint>)c
{
}
- (void)whenChangePropagate:(id<CPConstraint>)c
{
}
- (void)whenChangePropagate:(id<CPConstraint>)c priority:(ORInt)p
{
}

-(void) setDelegate:(id<CPDoubleVarNotifier>)delegate
{
}
-(void) addVar:(CPDoubleVarI*)var
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

-(void) bindEvt: (id<CPDoubleDom>) sender
{
   id<CPClosureList> mList[4];
   ORUInt k = 0;
   mList[k] = _net._minEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._bindEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) domEvt:(id<CPDom>)sender
{
   // [ldm]. There is nothing to do here. We lost a value _inside_ the domain, but DoubleVars are intervals
   // So no hope of propagating.
}
-(void) changeMinEvt: (ORInt) dsz sender: (id<CPDom>) sender
{
   id<CPClosureList> mList[4];
   ORUInt k = 0;
   mList[k] = _net._minEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = (dsz==1) ? _net._bindEvt[0] : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMaxEvt:(ORInt) dsz sender:(id<CPDoubleDom>)sender
{
   id<CPClosureList> mList[4];
   ORUInt k = 0;
   mList[k] = _net._maxEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = (dsz==1) ? _net._bindEvt[0] : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
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
-(void) updateInterval: (ORDouble) newMin and: (ORDouble)newMax
{
   [self updateMax:newMax];
   [self updateMin:newMin];
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
-(ORLDouble) domwidth
{
   ORBounds b = [_theVar bounds];
   return b.max - b.min;
}
- (ORInt)domsize
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPDoubleVar: method domsize  not defined"];
   return 0;
}

- (id<CPADom>)domain
{
   return [_theVar flatDomain];
}
- (ORBool)sameDomain:(id<CPDoubleVar>)x
{
   return [self min] == [x min] && [self max] == [x max];
}
- (void)subsumedBy:(id<CPDoubleVar>)x
{
   [self updateInterval:[x min] and:[x max]];
}
- (void)subsumedByDomain:(id<CPDom>)dom
{
   [self updateInterval:[dom min] and:[dom max]];
}

-(ORDouble) magnitude
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPDoubleViewOnIntVarI: magnitude not definied for a view"];
   return 0.0;
}
- (void)visit:(id<ORSplitVisitor>)visitor
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPDoubleViewOnIntVarI: visitSplit not definied for a view"];
}
- (void)visitAbs:(id<ORAbsVisitor>)visitor
{
   @throw [[ORExecutionError alloc] initORExecutionError: "CPDoubleViewOnIntVarI: visitAbs not definied for a view"];
}
@end

