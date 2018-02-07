/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPRationalVarI.h"
#import <CPUKernel/CPUKernel.h>
#import "CPRationalDom.h"


/*****************************************************************************************/
/*                        CPFloatVarSnapshot                                              */
/*****************************************************************************************/

/*@interface CPRationalVarSnapshot : NSObject
{
    ORUInt      _name;
    ORRational  _value;
    ORBool      _bound;
}
-(CPRationalVarSnapshot*) init: (CPRationalVarI*) v name: (ORInt) name;
-(ORUInt) getId;
-(ORRational*) RationalValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation CPRationalVarSnapshot
-(CPRationalVarSnapshot*) init: (CPRationalVarI*) v name: (ORInt) name
{
    self = [super init];
    _name = name;
    if ([v bound]) {
        _bound = TRUE;
        mpq_set(_value, *[v value]);
    }
    else {
        mpq_set_d(_value, 0.0);
        _bound = FALSE;
    }
    return self;
}
-(ORRational*) RationalValue
{
    return &_value;
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
        CPRationalVarSnapshot* other = object;
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
    [buf appendFormat:@"Rational(%d) : %f",_name,mpq_get_d(_value)];
    return buf;
}
- (void) encodeWithCoder: (NSCoder *) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
    [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_bound];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
    [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_bound];
    return self;
}
@end

static void setUpNetwork(CPRationalEventNetwork* net,id<ORTrail> t)
{
    net->_bindEvt   = makeTRId(t,nil);
    net->_minEvt    = makeTRId(t,nil);
    net->_maxEvt    = makeTRId(t,nil);
    net->_boundsEvt    = makeTRId(t,nil);
}

static void deallocNetwork(CPRationalEventNetwork* net)
{
    freeList(net->_bindEvt);
    freeList(net->_minEvt);
    freeList(net->_maxEvt);
    freeList(net->_boundsEvt);
}

static NSMutableSet* collectConstraints(CPRationalEventNetwork* net,NSMutableSet* rv)
{
    collectList(net->_bindEvt,rv);
    collectList(net->_minEvt,rv);
    collectList(net->_maxEvt,rv);
    collectList(net->_boundsEvt,rv);
    return rv;
}

@implementation CPRationalVarI

-(id)init:(CPEngineI*)engine low:(ORRational)low up:(ORRational)up
{
    self = [super init];
    _engine = engine;
    _dom = [[CPRationalDom alloc] initCPRationalDom:[engine trail] low:low up:up];
    _recv = nil;
    _hasValue = false;
    mpq_set_d(_value,0.0);
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
    return [[CPRationalVarSnapshot alloc] init: self name: id];
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
    return buf;
}
-(void)setDelegate:(id<CPFloatVarNotifier>)delegate
{}
-(void) addVar:(CPRationalVarI*)var
{}
-(enum CPVarClass)varClass
{
    return CPVCBare;
}
-(CPRationalVarI*) findAffine: (ORRational) scale shift:(ORRational) shift
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
-(void) bindEvt:(id<CPRationalDom>)sender
{
    id<CPClosureList> mList[2];
    ORUInt k = 0;
    mList[k] = _net._bindEvt;
    k += mList[k] != NULL;
    mList[k] = NULL;
    scheduleClosures(_engine,mList);
}
-(void) changeMinEvt:(ORBool) bound sender:(id<CPRationalDom>)sender
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
-(void) changeMaxEvt:(ORBool) bound sender:(id<CPRationalDom>)sender
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

-(void) bind:(ORRational) val
{
    [_dom bind:val for:self];
}
-(void) updateMin: (ORRational) newMin
{
    if(mpq_cmp(newMin, *[self min]) > 0)
        [_dom updateMin:newMin for:self];
}
-(void) updateMax: (ORRational) newMax
{
    if(mpq_cmp(newMax, *[self max]) < 0)
        [_dom updateMax:newMax for:self];
}
-(void) updateInterval: (ORRational) newMin and:(ORRational)newMax
{
    if(newMin > newMax)
        failNow();
    [self updateMin:newMin];
    [self updateMax:newMax];
}
-(ORRational*) min
{
    return [_dom min];
}
-(ORRational*) max
{
    return [_dom max];
}
-(ORRational*) value
{
    if ([_dom bound])
        return [_dom min];
    return &_value;
}
-(ORRational*) rationalValue
{
    if ([_dom bound])
        return [_dom min];
    return &_value;
}
-(TRRationalInterval) domain
{
    return [_dom domain];
}
-(void) assignRelaxationValue: (ORRational) f
{
    if (mpq_cmp(f, *[_dom min]) < 0 && mpq_cmp(f, *[_dom max]) > 0 )
        @throw [[ORExecutionError alloc] initORExecutionError: "Assigning a relaxation value outside the bounds"];
    mpq_set(_value, f);
}
-(ORInterval) bounds
{
    return [_dom bounds];
}
-(ORBool) member:(ORRational)v
{
    return [_dom member:v];
}
-(ORBool) bound
{
    return [_dom bound];
}
- (ORInt)domsize
{
    @throw [[ORExecutionError alloc] initORExecutionError: "CPRationalVar: method domsize  not defined"];
    return 0;
}

- (ORBool)sameDomain:(id<CPVar>)x {
    # warning todo
}


- (void)subsumedBy:(id<CPVar>)x {
    # warning todo
}


- (void)subsumedByDomain:(id<CPADom>)dom {
    # warning todo
}

-(ORLDouble) domwidth
 {
 return [_dom domwidth];
 }
 -(ORRational*) magnitude
 {
 return [_dom magnitude];
 }*/
/*- (void)visit:(ORVisitor *)visitor {
    # warning todo
}

@end

@implementation CPRationalViewOnIntVarI
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
-(void) setDelegate:(id<CPRationalVarNotifier>)delegate
{
}
-(void) addVar:(CPRationalVarI*)var
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

-(void) bind:(ORRational) val
{
    [_theVar updateMin:(ORInt)ceil(mpq_get_d(val)) andMax:(ORInt)floor(mpq_get_d(val))];
}
-(void) updateMin: (ORRational) newMin
{
    [_theVar updateMin:(ORInt)ceil(mpq_get_d(newMin))];
}
-(void) updateMax: (ORRational) newMax
{
    [_theVar updateMax:(ORInt)floor(mpq_get_d(newMax))];
}
-(void) updateInterval: (ORRational) newMin and: (ORRational)newMax
{
    [self updateMax:newMax];
    [self updateMin:newMin];
}
-(ORRational*) min
{
    ORRational * _min = NULL;
    mpq_set_d(*_min, [_theVar min]);
    return _min;
}
-(ORRational*) max
{
    ORRational * _max = NULL;
    mpq_set_d(*_max, [_theVar max]);
    return _max;
}
-(ORRational*) value
{
    ORRational * _value = NULL;
    mpq_set_d(*_value, [_theVar min]);
    return _value;
}
-(ORRational*)rationalValue
{
    ORRational * _rationalValue = NULL;
    mpq_set_d(*_rationalValue, [_theVar min]);
    return _rationalValue;
}
-(void) assignRelaxationValue: (ORRational) f
{
    @throw [[ORExecutionError alloc] initORExecutionError: "Assigning a relaxation value on a view"];
}
-(ORInterval) bounds
{
    ORBounds b = [_theVar bounds];
    return createORI2(b.min, b.max);
}
-(ORBool) member:(ORRational)v
{
    ORRational tv;
    mpq_set_d(tv, trunc(mpq_get_d(v)));
    if (mpq_cmp(tv, v) == 0)
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

- (id<CPADom>)domain {
    # warning todo
}


- (ORBool)sameDomain:(id<CPVar>)x {
    # warning todo
}


- (void)subsumedBy:(id<CPVar>)x {
    # warning todo
}


- (void)subsumedByDomain:(id<CPADom>)dom {
    # warning todo
}

-(ORFloat) magnitude
{
    @throw [[ORExecutionError alloc] initORExecutionError: "CPFloatViewOnIntVarI: magnitude not definied for a view"];
    return 0.0;
}
- (void)visit:(ORVisitor *)visitor {
    # warning todo
}

@end
*/

