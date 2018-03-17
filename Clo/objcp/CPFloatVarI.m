/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPFloatVarI.h"
#import <CPUKernel/CPUKernel.h>
#import "CPFloatDom.h"
#import "CPRationalDom.h"

/*****************************************************************************************/
/*                        CPFloatVarSnapshot                                              */
/*****************************************************************************************/

@interface CPFloatVarSnapshot : NSObject
{
   ORUInt    _name;
   ORFloat   _value;
   ORRational _valueError;
   ORBool    _bound;
   ORBool    _boundError;
}
-(CPFloatVarSnapshot*) init: (CPFloatVarI*) v name: (ORInt) name;
-(ORUInt) getId;
-(ORFloat) floatValue;
-(ORRational*) errorValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation CPFloatVarSnapshot
-(CPFloatVarSnapshot*) init: (CPFloatVarI*) v name: (ORInt) name
{
   self = [super init];
   _name = name;
    mpq_init(_valueError);
   if ([v bound]) {
      _bound = TRUE;
      _value = [v value];
   }
   else {
      _value = 0.0;
      _bound = FALSE;
   }
    if ([v boundError]) {
        _boundError = TRUE;
        mpq_set(_valueError, *[v errorValue]);
    }
    else {
        mpq_set_d(_valueError, 0.0f);
        _boundError = FALSE;
    }
   return self;
}
-(void) dealloc
{
   mpq_clear(_valueError);
   [super dealloc];
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORRational*) errorValue
{
    return &_valueError;
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
      CPFloatVarSnapshot* other = object;
      if (_name == other->_name) {
         //return _value == other->_value && _bound == other->_bound && mpq_cmp(_valueError, other->_valueError) == 0 && _boundError == other->_boundError;
         return _value == other->_value && _bound == other->_bound && mpq_get_d(_valueError) == mpq_get_d(other->_valueError) && _boundError == other->_boundError;
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
   [buf appendFormat:@"Float(%d) : %f±%f",_name,_value,mpq_get_d(_valueError)];
   return buf;
}
- (void) encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_bound];
   [aCoder encodeValueOfObjCType:@encode(ORRational) at:&_valueError];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_boundError];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_bound];
   [aDecoder decodeValueOfObjCType:@encode(ORRational) at:&_valueError];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_boundError];
   return self;
}
@end

static void setUpNetwork(CPFloatEventNetwork* net,id<ORTrail> t)
{
   net->_bindEvt   = makeTRId(t,nil);
   net->_minEvt    = makeTRId(t,nil);
   net->_maxEvt    = makeTRId(t,nil);
   net->_boundsEvt    = makeTRId(t,nil);
}

static void deallocNetwork(CPFloatEventNetwork* net)
{
   freeList(net->_bindEvt);
   freeList(net->_minEvt);
   freeList(net->_maxEvt);
   freeList(net->_boundsEvt);
}

static NSMutableSet* collectConstraints(CPFloatEventNetwork* net,NSMutableSet* rv)
{
   collectList(net->_bindEvt,rv);
   collectList(net->_minEvt,rv);
   collectList(net->_maxEvt,rv);
   collectList(net->_boundsEvt,rv);
   return rv;
}

@implementation CPFloatVarI

-(id)init:(CPEngineI*)engine low:(ORFloat)low up:(ORFloat)up
{
   self = [super init];
   _engine = engine;
   _dom = [[CPFloatDom alloc] initCPFloatDom:[engine trail] low:low up:up];
   if(low == up)
      _domError = [[CPRationalDom alloc] initCPRationalDom:[engine trail] low:0.0f up:0.0f];
   else
      _domError = [[CPRationalDom alloc] initCPRationalDom:[engine trail]];
   _recv = nil;
   _hasValue = false;
   _value = 0.0;
   setUpNetwork(&_net, [engine trail]);
   [_engine trackVariable: self];
   return self;
}

-(id)init:(CPEngineI*)engine
{
   self = [super init];
   _engine = engine;
   _dom = [[CPFloatDom alloc] initCPFloatDom:[engine trail] low:-INFINITY up:INFINITY];
   _domError = [[CPRationalDom alloc] initCPRationalDom:[engine trail]];
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
   return [[CPFloatVarSnapshot alloc] init: self name: id];
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
   [_net._boundsEvt scanCstrWithBlock:^(CPCoreConstraint* cstr) { d += [cstr nbVars] - 1;}];
   return d;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var<%d>=",_name];
   [buf appendString:[_dom description]];
   [buf appendString:[_domError description]];
   return buf;
}
-(void)setDelegate:(id<CPFloatVarNotifier>)delegate
{}
-(void) addVar:(CPFloatVarI*)var
{}
-(enum CPVarClass)varClass
{
   return CPVCBare;
}
-(CPFloatVarI*) findAffine: (ORFloat) scale shift:(ORFloat) shift
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
- (void)whenChangeDo:(ORClosure)todo priority:(ORInt)p onBehalf:(CPCoreConstraint*)c
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
- (void)whenChangePropagate:(CPCoreConstraint*)c priority:(ORInt)p
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
- (void)whenChangePropagate:(id<CPConstraint>)c
{
   [self whenChangePropagate: c priority:HIGHEST_PRIO];
}
- (void)whenChangeDo:(ORClosure)todo onBehalf:(id<CPConstraint>)c
{
     [self whenChangeDo: todo priority: HIGHEST_PRIO onBehalf:c];
}
-(void) bindEvt:(id<CPFloatDom>)sender
{
   id<CPClosureList> mList[3];
   ORUInt k = 0;
   mList[k] = _net._bindEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) bindEvtErr:(id<CPRationalDom>)sender
{
    id<CPClosureList> mList[2];
    ORUInt k = 0;
    mList[k] = _net._bindEvtErr;
    k += mList[k] != NULL;
    mList[k] = NULL;
    scheduleClosures(_engine,mList);
}
-(void) changeMinEvt:(ORBool) bound sender:(id<CPFloatDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._minEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMinEvtErr:(ORBool) bound sender:(id<CPRationalDom>)sender
{
    id<CPClosureList> mList[6];
    ORUInt k = 0;
    mList[k] = _net._minEvtErr;
    k += mList[k] != NULL;
    mList[k] = _net._boundsEvtErr;
    k += mList[k] != NULL;
    mList[k] = bound ? _net._bindEvtErr : NULL;
    k += mList[k] != NULL;
    mList[k] = NULL;
    scheduleClosures(_engine,mList);
}
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPFloatDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._maxEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = bound ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMaxEvtErr:(ORBool) bound sender:(id<CPRationalDom>)sender
{
    id<CPClosureList> mList[6];
    ORUInt k = 0;
    mList[k] = _net._maxEvtErr;
    k += mList[k] != NULL;
    mList[k] = _net._boundsEvtErr;
    k += mList[k] != NULL;
    mList[k] = bound ? _net._bindEvtErr : NULL;
    k += mList[k] != NULL;
    mList[k] = NULL;
    scheduleClosures(_engine,mList);
}
-(void) bind:(ORFloat) val
{
   [_dom bind:val for:self];
}
-(void) updateMin: (ORFloat) newMin
{
   if(newMin > [self min])
      [_dom updateMin:newMin for:self];
}
-(void) updateMax: (ORFloat) newMax
{
   if(newMax < [self max])
      [_dom updateMax:newMax for:self];
}
-(void) updateInterval: (ORFloat) newMin and:(ORFloat)newMax
{
   if(newMin > newMax || (is_plus_zerof(newMin) && is_minus_zerof(newMax)))
      failNow();
   [self updateMin:newMin];
   [self updateMax:newMax];
}

- (void)bindError:(ORRational)valError {
    [_domError bind:valError for:self];
}


- (void)updateIntervalError:(ORRational)newMinError and:(ORRational)newMaxError {
    //if(mpq_cmp(newMinError,newMaxError)>0)
   if(mpq_get_d(newMinError) > mpq_get_d(newMaxError))
        failNow();
    [self updateMinError:newMinError];
    [self updateMaxError:newMaxError];
}


- (void)updateMaxError:(ORRational)newMaxError {
    //if(mpq_cmp(newMaxError, *[self maxErr]) < 0)
   if(mpq_get_d(newMaxError) < mpq_get_d(*[self maxErr]))
        [_domError updateMax:newMaxError for:self];
}


- (void)updateMinError:(ORRational)newMinError {
    //if(mpq_cmp(newMinError, *[self minErr]) > 0)
   if(mpq_get_d(newMinError) > mpq_get_d(*[self minErr]))
        [_domError updateMin:newMinError for:self];
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
    if ([_dom bound])
        return [_dom min];
    return _value;
}
-(ORFloat) floatValue
{
    if ([_dom bound])
        return [_dom min];
    return _value;
}
-(ORRational*) errorValue
{
    if ([_domError bound])
        return [_domError min];
    return &_valueError;
}
- (ORRational*)maxErr {
    return [_domError max];
}
- (ORRational*)minErr {
    return [_domError min];
}
- (ORFloat)maxErrF {
    return mpq_get_d(*[_domError max]);
}
- (ORFloat)minErrF {
    return mpq_get_d(*[_domError min]);
}
-(id<CPFloatDom>) domain
{
   return [_dom retain];
}
-(TRRationalInterval) domainError
{
    return [_domError domain];
}
-(void) assignRelaxationValue: (ORFloat) f
{
    if (f < [_dom min] && f > [_dom max])
        @throw [[ORExecutionError alloc] initORExecutionError: "Assigning a relaxation value outside the bounds"];
    _value = f;
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
-(ORBool) boundError
{
    return [_domError bound];
}
- (ORInt)domsize
{
    @throw [[ORExecutionError alloc] initORExecutionError: "CPFloatVar: method domsize  not defined"];
    return 0;
}
- (ORBool)sameDomain:(CPFloatVarI*)x
{
    return [_dom isEqual:x->_dom];
}
- (void)subsumedBy:(id<CPFloatVar>)x
{
   [self updateInterval:[x min] and:[x max]];
}
- (void)subsumedByDomain:(id<CPFloatDom>)dom
{
   [self updateInterval:[dom min] and:[dom max]];
}
-(ORLDouble) domwidth
{
    return [_dom domwidth];
}
-(ORFloat) magnitude
{
    return [_dom magnitude];
}

- (void)visit:(ORVisitor *)visitor
{}
@end

@implementation CPFloatViewOnIntVarI
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

-(void) setDelegate:(id<CPFloatVarNotifier>)delegate
{
}
-(void) addVar:(CPFloatVarI*)var
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

-(void) bindEvt: (id<CPFloatDom>) sender
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
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) domEvt:(id<CPDom>)sender
{
   // [ldm]. There is nothing to do here. We lost a value _inside_ the domain, but FloatVars are intervals
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
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}
-(void) changeMaxEvt:(ORInt) dsz sender:(id<CPFloatDom>)sender
{
   id<CPClosureList> mList[6];
   ORUInt k = 0;
   mList[k] = _net._maxEvt;
   k += mList[k] != NULL;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = (dsz==1) ? _net._bindEvt : NULL;
   k += mList[k] != NULL;
   mList[k] = NULL;
   scheduleClosures(_engine,mList);
}

-(void) bind:(ORFloat) val
{
   [_theVar updateMin:(ORInt)ceil(val) andMax:(ORInt)floor(val)];
}
-(void) updateMin: (ORFloat) newMin
{
   [_theVar updateMin:(ORInt)ceil(newMin)];
}
-(void) updateMax: (ORFloat) newMax
{
   [_theVar updateMax:(ORInt)floor(newMax)];
}
-(void) updateInterval: (ORFloat) newMin and: (ORFloat)newMax
{
   [self updateMax:newMax];
   [self updateMin:newMin];
}

- (void)bindError:(__mpq_struct *)valError {
}


- (void)updateIntervalError:(__mpq_struct *)newMinError and:(__mpq_struct *)newMaxError {
}


- (void)updateMaxError:(__mpq_struct *)newMaxError {
}


- (void)updateMinError:(__mpq_struct *)newMinError {
}

-(ORFloat) min
{
    return [_theVar min];
}
-(ORFloat) max
{
    return [_theVar max];
}
- (ORRational *)maxErr {
    ORRational* maxE = NULL;
    mpq_set_d(*maxE, [_theVar max]);
    return maxE;
}
- (ORRational *)minErr {
    ORRational* minE = NULL;
    mpq_set_d(*minE, [_theVar min]);
    return minE;
}
- (ORFloat)maxErrF {
   return [_theVar max];
}


- (ORFloat)minErrF {
   return [_theVar min];
}

-(ORFloat) value
{
    return [_theVar min];
}
-(ORFloat)floatValue
{
    return [_theVar min];
}
-(void) assignRelaxationValue: (ORFloat) f
{
    @throw [[ORExecutionError alloc] initORExecutionError: "Assigning a relaxation value on a view"];
}
-(ORInterval) bounds
{
    ORBounds b = [_theVar bounds];
    return createORI2(b.min, b.max);
}
-(ORBool) member:(ORFloat)v
{
    ORFloat tv = trunc(v);
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
    @throw [[ORExecutionError alloc] initORExecutionError: "CPFloatVar: method domsize  not defined"];
    return 0;
}

- (id<CPADom>)domain
{
   return [_theVar flatDomain];
}
- (ORBool)sameDomain:(id<CPFloatVar>)x
{
   return [self min] == [x min] && [self max] == [x max];
}
- (void)subsumedBy:(id<CPFloatVar>)x
{
   [self updateInterval:[x min] and:[x max]];
}
- (void)subsumedByDomain:(id<CPDom>)dom
{
   [self updateInterval:[dom min] and:[dom max]];
}

-(ORFloat) magnitude
{
    @throw [[ORExecutionError alloc] initORExecutionError: "CPFloatViewOnIntVarI: magnitude not definied for a view"];
    return 0.0;
}
- (ORBool)boundError {
    return [_theVar bound];
}
- (ORRational *)errorValue {
    ORRational* errV = NULL;
    mpq_set_d(*errV, [_theVar min]);
    return errV;
}
- (void)visit:(ORVisitor *)visitor
{}

@end
