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

@protocol  CPVisitor;

/*****************************************************************************************/
/*                        CPFloatVarSnapshot                                              */
/*****************************************************************************************/

@interface CPFloatVarSnapshot : NSObject
{
    ORUInt    _name;
    ORFloat   _value;
    id<ORRational> _valueError;
    ORBool    _bound;
    ORBool    _boundError;
}
-(CPFloatVarSnapshot*) init: (CPFloatVarI*) v name: (ORInt) name;
-(ORUInt) getId;
-(ORFloat) floatValue;
-(id<ORRational>) errorValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation CPFloatVarSnapshot
-(CPFloatVarSnapshot*) init: (CPFloatVarI*) v name: (ORInt) name
{
    self = [super init];
    _name = name;
    _valueError = [[ORRational alloc] init];
    if ([v bound]) {
        _bound = TRUE;
        _value = [v value];
    }
    else {
        _value = 0.0f;
        _bound = FALSE;
    }
    if ([v boundError]) {
        _boundError = TRUE;
       [_valueError set: [v errorValue]];
    }
    else {
       [_valueError set_d: 0.0];
       _boundError = FALSE;
    }
    return self;
}
-(void) dealloc
{
    [_valueError release];
    [super dealloc];
}
-(ORFloat) floatValue
{
    return _value;
}
-(id<ORRational>) errorValue
{
    return _valueError;
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
           return _value == other->_value && _bound == other->_bound && [_valueError eq: other->_valueError] && _boundError == other->_boundError;
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
//    [buf appendFormat:@"Float(%d) : %20.20e±%@",_name,_value,_valueError];
   [buf appendFormat:@"%20.20e±%@",_value,_valueError];

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

typedef struct  {
   TRId           _bindEvt[2];
   TRId            _minEvt[2];
   TRId            _maxEvt[2];
   TRId         _boundsEvt[2];
   TRId        _bindEvtErr;
   TRId         _maxEvtErr;
   TRId         _minEvtErr;
   TRId      _boundsEvtErr;
} CPFloatEventNetwork;

static void setUpNetwork(CPFloatEventNetwork* net,id<ORTrail> t)
{
    for(int i=0;i < 2;i++) {
        net->_bindEvt[i]   = makeTRId(t,nil);
        net->_minEvt[i]    = makeTRId(t,nil);
        net->_maxEvt[i]    = makeTRId(t,nil);
        net->_boundsEvt[i] = makeTRId(t,nil);
    }
}

static void deallocNetwork(CPFloatEventNetwork* net)
{
    freeList(net->_bindEvt[0]);
    freeList(net->_minEvt[0]);
    freeList(net->_maxEvt[0]);
    freeList(net->_boundsEvt[0]);
}

static id<OROSet> collectConstraints(CPFloatEventNetwork* net,id<OROSet> rv)
{
collectList(net->_bindEvt[0],rv);
collectList(net->_minEvt[0],rv);
collectList(net->_maxEvt[0],rv);
collectList(net->_boundsEvt[0],rv);
return rv;
}

@implementation CPFloatVarI{
   CPFloatEventNetwork      _net;
   ORBool _inputVar;
}

-(id)init:(CPEngineI*)engine low:(ORFloat)low up:(ORFloat)up errLow:(id<ORRational>)elow errUp:(id<ORRational>) eup inputVar:(ORBool)inputVar
{
    self = [super init];
    _engine = engine;
    _dom = [[CPFloatDom alloc] initCPFloatDom:[engine trail] low:low up:up];
    _domError = [[CPRationalDom alloc] initCPRationalDom:[engine trail] low:elow up:eup];
    _recv = nil;
    _hasValue = false;
    _value = 0.0f;
   _valueError = [[ORRational alloc] init];
   [_valueError setZero];
    setUpNetwork(&_net, [engine trail]);
    [_engine trackVariable: self];
   
   _inputVar = inputVar;

    return self;
}

-(id)init:(CPEngineI*)engine low:(ORFloat)low up:(ORFloat)up errLowF:(ORDouble)elow errUpF:(ORDouble) eup inputVar:(ORBool)inputVar
{
    self = [super init];
    _engine = engine;
    _dom = [[CPFloatDom alloc] initCPFloatDom:[engine trail] low:low up:up];
    _domError = [[CPRationalDom alloc] initCPRationalDom:[engine trail] lowF:elow upF:eup];
    _recv = nil;
    _hasValue = false;
    _value = 0.0f;
   _valueError = [[ORRational alloc] init];
   [_valueError setZero];
    setUpNetwork(&_net, [engine trail]);
    [_engine trackVariable: self];
   
   _inputVar = inputVar;

    return self;
}

-(id)init:(CPEngineI*)engine low:(ORFloat)low up:(ORFloat)up inputVar:(ORBool)inputVar
{
    self = [super init];
    _engine = engine;
    _dom = [[CPFloatDom alloc] initCPFloatDom:[engine trail] low:low up:up];
    if(low == up)
        _domError = [[CPRationalDom alloc] initCPRationalDom:[engine trail] lowF:0.0 upF:0.0];
    else
        _domError = [[CPRationalDom alloc] initCPRationalDom:[engine trail]];
    _recv = nil;
    _hasValue = false;
    _value = 0.0f;
   _valueError = [[ORRational alloc] init];
   [_valueError setZero];
    setUpNetwork(&_net, [engine trail]);
    [_engine trackVariable: self];
   
   _inputVar = inputVar;

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
    _value = 0.0f;
   _valueError = [[ORRational alloc] init];
   [_valueError setZero];
    setUpNetwork(&_net, [engine trail]);
    [_engine trackVariable: self];
   
   _inputVar = false;

    return self;
}
-(void)dealloc
{
    deallocNetwork(&_net);
   [_valueError release];
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
    [buf appendFormat:@"±%@",[_domError description]];
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
    hookupEvent((id)_engine, &_net._bindEvt[0], todo, c, p);
    hookupEvent((id)_engine, &_net._bindEvtErr, todo, c, p);
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    hookupEvent((id)_engine, &_net._minEvt[0], todo, c, p);
    hookupEvent((id)_engine, &_net._minEvtErr, todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    hookupEvent((id)_engine, &_net._maxEvt[0], todo, c, p);
    hookupEvent((id)_engine, &_net._maxEvtErr, todo, c, p);
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    hookupEvent((id)_engine, &_net._boundsEvt[0], todo, c, p);
    hookupEvent((id)_engine, &_net._boundsEvtErr, todo, c, p);
}
- (void)whenChangeDo:(ORClosure)todo priority:(ORInt)p onBehalf:(CPCoreConstraint*)c
{
    hookupEvent((id)_engine, &_net._boundsEvt[0], todo, c, p);
    hookupEvent((id)_engine, &_net._boundsEvtErr, todo, c, p);
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
    hookupEvent((id)_engine, &_net._bindEvtErr, nil, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
    hookupEvent((id)_engine, &_net._minEvt[0], nil, c, p);
    hookupEvent((id)_engine, &_net._minEvtErr, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
    hookupEvent((id)_engine, &_net._maxEvt[0], nil, c, p);
    hookupEvent((id)_engine, &_net._maxEvtErr, nil, c, p);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
    hookupEvent((id)_engine, &_net._boundsEvt[0], nil, c, p);
    hookupEvent((id)_engine, &_net._boundsEvtErr, nil, c, p);
}
- (void)whenChangePropagate:(CPCoreConstraint*)c priority:(ORInt)p
{
    hookupEvent((id)_engine, &_net._boundsEvt[0], nil, c, p);
    hookupEvent((id)_engine, &_net._boundsEvtErr, nil, c, p);
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
    mList[k] = _net._bindEvt[0];
    k += mList[k] != NULL;
    mList[k] = _net._boundsEvt[0];
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
    id<CPClosureList> mList[4];
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
    id<CPClosureList> mList[4];
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
-(void) updateMin: (ORFloat) newMin propagate:(ORBool)p
{
   if(newMin > [self min] || (is_plus_zerof(newMin) &&  is_minus_zerof([self min])))
      [_dom updateMin:newMin for:self propagate:p];
}
-(void) updateMax: (ORFloat) newMax propagate:(ORBool)p
{
   if(newMax < [self max] || (is_plus_zerof([self max]) &&  is_minus_zerof(newMax)))
      [_dom updateMax:newMax for:self propagate:p];
}
-(void) updateMin: (ORFloat) newMin
{
   if(newMin > [self min] || (is_plus_zerof(newMin) &&  is_minus_zerof([self min])))
      [_dom updateMin:newMin for:self];
}
-(void) updateMax: (ORFloat) newMax
{
   if(newMax < [self max] || (is_plus_zerof([self max]) &&  is_minus_zerof(newMax)))
      [_dom updateMax:newMax for:self];
}
-(void) updateInterval: (ORFloat) newMin and:(ORFloat)newMax
{
    if(newMin > newMax || (is_plus_zerof(newMin) && is_minus_zerof(newMax)))
        failNow();
    [self updateMin:newMin];
    [self updateMax:newMax];
}

- (void)bindError:(id<ORRational>)valError
{
    [_domError bind:valError for:self];
}
- (void)updateIntervalError:(id<ORRational>)newMinError and:(id<ORRational>)newMaxError
{
    if([newMinError isNAN] || [newMaxError isNAN])
       failNow();
    if([newMinError gt: newMaxError])
        failNow();
    [self updateMinError:newMinError];
    [self updateMaxError:newMaxError];
}
- (void)updateMaxError:(id<ORRational>)newMaxError
{
   if([newMaxError lt: [self maxErr]])
        [_domError updateMax:newMaxError for:self];
}
- (void)updateMinError:(id<ORRational>)newMinError
{
    if([newMinError gt: [self minErr]])
        [_domError updateMin:newMinError for:self];
}
- (void)updateMaxErrorF:(ORDouble)newMaxError {
   id<ORRational> mError = [[ORRational alloc ] init];
   [mError set_d: newMaxError];
   [_domError updateMax:mError for:self];
   [mError release];
}
- (void)updateMinErrorF:(ORDouble)newMinError
{
   id<ORRational> mError = [[ORRational alloc ] init];
   [mError set_d: newMinError];
   [_domError updateMin:mError for:self];
   [mError release];
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
-(id<ORRational>) errorValue
{
    if ([_domError bound])
        return [_domError min];
    return _valueError;
}
- (id<ORRational>)maxErr {
    return [_domError max];
}
- (id<ORRational>)minErr {
    return [_domError min];
}
- (ORDouble)maxErrF {
   return [[_domError max] get_d];
}
- (ORDouble)minErrF {
   return [[_domError min] get_d];
}
-(id<CPFloatDom>) domain
{
    return [_dom retain];
}
-(id<CPRationalDom>) domainError
{
    return _domError;
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
-(ORBool) isInputVar
{
   return _inputVar;
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
- (void)visit:(id<CPVisitor>)visitor
{
   [(id)visitor applyFloatVar:self];
}
@end

@implementation CPFloatViewOnIntVarI {
   CPFloatEventNetwork _net;
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
    hookupEvent((id)_engine, &_net._bindEvtErr, todo, c, p);
}
-(void) whenChangeMinDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    hookupEvent((id)_engine, &_net._minEvt[0], todo, c, p);
    hookupEvent((id)_engine, &_net._minEvtErr, todo, c, p);
}
-(void) whenChangeMaxDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    hookupEvent((id)_engine, &_net._maxEvt[0], todo, c, p);
    hookupEvent((id)_engine, &_net._maxEvtErr, todo, c, p);
}
-(void) whenChangeBoundsDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
    hookupEvent((id)_engine, &_net._boundsEvt[0], todo, c, p);
    hookupEvent((id)_engine, &_net._boundsEvtErr, todo, c, p);
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
    hookupEvent((id)_engine, &_net._bindEvtErr, nil, c, p);
}
-(void) whenChangeMinPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
    hookupEvent((id)_engine, &_net._minEvt[0], nil, c, p);
    hookupEvent((id)_engine, &_net._minEvtErr, nil, c, p);
}
-(void) whenChangeMaxPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
    hookupEvent((id)_engine, &_net._maxEvt[0], nil, c, p);
    hookupEvent((id)_engine, &_net._maxEvtErr, nil, c, p);
}
-(void) whenChangeBoundsPropagate: (CPCoreConstraint*) c priority: (ORInt) p
{
    hookupEvent((id)_engine, &_net._boundsEvt[0], nil, c, p);
    hookupEvent((id)_engine, &_net._maxEvtErr, nil, c, p);
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
    // [ldm]. There is nothing to do here. We lost a value _inside_ the domain, but FloatVars are intervals
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
-(void) changeMaxEvt:(ORInt) dsz sender:(id<CPFloatDom>)sender
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
- (void)updateMax:(ORFloat)newMax propagate:(ORBool)p
{
[self updateMax:newMax];
}
- (void)updateMin:(ORFloat)newMin propagate:(ORBool)p
{
[self updateMin:newMin];
}
- (void)bindError:(id<ORRational>)valError {
}


- (void)updateIntervalError:(id<ORRational>)newMinError and:(id<ORRational>)newMaxError { // nonsense (cpjm)
}


- (void)updateMaxError:(id<ORRational>)newMaxError {
}


- (void)updateMinError:(id<ORRational>)newMinError {
}

- (void)updateMaxErrorF:(ORDouble)newMaxError {
}


- (void)updateMinErrorF:(ORDouble)newMinError {
}


-(ORFloat) min
{
    return [_theVar min];
}
-(ORFloat) max
{
    return [_theVar max];
}
- (id<ORRational>)maxErr { // Probably wrong (cpjm)
   id<ORRational> maxErr = [[ORRational alloc] init];
   [maxErr autorelease];
    return maxErr;
}
- (id<ORRational>)minErr
{
    id<ORRational> minErr = [[ORRational alloc] init];
    [minErr autorelease];
     return minErr;
}
- (ORDouble)maxErrF
{
    return [_theVar max];
}
- (ORDouble)minErrF
{
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
    return 0.0f;
}
- (ORBool)boundError
{
   return [_theVar bound];
}
- (ORBool)isInputVar {
   return FALSE;
}
- (id<ORRational>)errorValue
{
   id<ORRational> errorValue = [[ORRational alloc] init];
   [errorValue autorelease];
    return errorValue;
}
- (void)visit:(id<CPVisitor>)visitor
{
   [(id)visitor applyFloatVar:self];
}
@end

