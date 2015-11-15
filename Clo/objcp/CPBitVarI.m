/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBitVarI.h"
#import "CPEngineI.h"
#import "CPTrigger.h"
#import "CPBitArrayDom.h"

/*****************************************************************************************/
/*                        Constraint Network Handling                                    */
/*****************************************************************************************/

static void setUpNetwork(CPBitEventNetwork* net,id<ORTrail> t) 
{
    net->_boundsEvt = makeTRId(t,nil);
    net->_bitFixedEvt = makeTRId(t, nil);
    net->_minEvt    = makeTRId(t,nil);
    net->_maxEvt    = makeTRId(t,nil);
}

static void deallocNetwork(CPBitEventNetwork* net) 
{
    freeList(net->_boundsEvt);
    freeList(net->_bitFixedEvt);
    freeList(net->_minEvt);
    freeList(net->_maxEvt);
}

@interface CPBitVarSnapshot : NSObject {
   ORUInt    _name;
   union {
      ORInt _value;
      id<CPDom>   _dom;
   }              _rep;
   BOOL         _asDom;
}
-(CPBitVarSnapshot*)initCPBitVarSnapshot:(CPBitVarI*)v name: (ORInt) name;
-(int)intValue;
-(ORBool)boolValue;
@end

// [pvh: Can someone fix this implementation?
@implementation CPBitVarSnapshot
-(CPBitVarSnapshot*)initCPBitVarSnapshot:(CPBitVarI*)v name: (ORInt) name
{
   self = [super init];
   _name = name;
   _asDom = YES;
   _rep._dom = [[v domain] copy];
   return self;
}
-(void)dealloc
{
   if (_asDom)
      [_rep._dom release];
   [super dealloc];
}
-(int)intValue
{
   return _asDom ? [_rep._dom min] : _rep._value;
}
-(ORBool)boolValue
{
   return _asDom ? [_rep._dom min] : _rep._value;
}
-(ORDouble) doubleValue
{
   return _asDom ? [_rep._dom min] : _rep._value;   
}
@end

//****************************************************
@implementation CPBitVarI
-(void) initCPBitVarCore:(CPEngineI*)engine low: (unsigned int*) low up: (unsigned int*)up length:(int)len
{
    self = [super init];
    _engine = engine;
    [_engine trackVariable: self];
    setUpNetwork(&_net, [_engine trail]);
    _triggers = nil;
    _dom = [[CPBitArrayDom alloc] initWithLength: len withTrail:[_engine trail]];
    _recv = self;
}
-(void)dealloc
{
    //NSLog(@"CBitVar::dealloc %d\n",_name);
    if (_recv != self) 
        [_recv release];
    [_dom release];     
    deallocNetwork(&_net);
    if (_triggers != nil)
        [_triggers release];    
    [super dealloc];
}
-(id) takeSnapshot: (ORInt) id
{
   return [[CPBitVarSnapshot alloc] initCPBitVarSnapshot: self name: id];
}
-(id<CPEngine>) engine
{
    return _engine;
}
-(id<CPBitVarNotifier>) delegate
{
    return _recv;
}
-(void) setDelegate:(id<CPBitVarNotifier>) d
{
    if (_recv != d) {
        if (_recv != self) {
            @throw [[NSException alloc] initWithName:@"Internal Error" 
                                              reason:@"Trying to set a delegate that already exists" 
                                            userInfo:nil];
        }
        _recv = [d retain];
    }
}

-(ORBool)bound
{
    return [_dom bound];
}
 
-(ORULong) min
{
    return [_dom min];
}

-(ORULong) max
{ 
    return [_dom max];
}

-(CPBitArrayDom*) domain
{
   return _dom;
}

-(unsigned int*) maxArray
{
    return [_dom maxArray];
}

-(unsigned int*) minArray
{
    return [_dom minArray];
}
-(unsigned int) getWordLength
{
    return [_dom getWordLength];
}

-(ORBounds) bounds
{
    return (ORBounds){(ORInt)[_dom min],(ORInt)[_dom max]};
}

-(ORULong)domsize
{
    return [_dom domsize];
}

-(unsigned int) randomFreeBit
{
   return [_dom randomFreeBit];
}

-(unsigned int) lsFreeBit
{
   return [_dom lsFreeBit];
}

-(ORBool)member:(unsigned int*)v
{
    return [_dom member:v];
}
-(NSString*)stringValue
{
   return [_dom description];
}
-(NSString*)description
{
    return [_dom description];
}
-(void)restoreDomain:(id<CPDom>)toRestore
{
   [_dom restoreDomain:toRestore];
}
-(void)restoreValue:(ORInt)toRestore
{
   [_dom restoreValue:toRestore];
}

-(ORBool) tracksLoseEvt
{
    return _triggers != nil;
}
// nothing to do here
-(void) setTracksLoseEvt
{
}

-(void) whenChangePropagate:  (CPCoreConstraint*) c 
{
   hookupEvent(_engine, &_net._bitFixedEvt, nil, c, HIGHEST_PRIO);
}

-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo
{
   hookupEvent(_engine, &_net._boundsEvt, todo, c, p);
}
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo
{
   hookupEvent(_engine, &_net._minEvt, todo, c, p);
}
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo
{
   hookupEvent(_engine, &_net._maxEvt, todo, c, p);
}

-(void) whenBitFixed: (CPCoreConstraint*)c at:(int)p do: (ORClosure) todo
{
   hookupEvent(_engine, &_net._bitFixedEvt, todo, c, p);
}

-(void) createTriggers
{
    if (_triggers == nil) {
        ORULong low = [_dom min];
        ORULong up = [_dom max];
        _triggers = [CPTriggerMap triggerMapFrom:(ORInt)low to:(ORInt)up dense:(up-low+1)<256];
    }
}

-(void) bindEvt
{
   id<CPClosureList> mList[5];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = _net._minEvt;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleClosures:mList];
    if (_triggers != nil)
        [_triggers bindEvt:_engine];
}

-(void) changeMinEvt: (int) dsz sender:(CPBitArrayDom*)sender
{
   id<CPClosureList> mList[5];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = _net._minEvt;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleClosures:mList];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_engine];
}
-(void) changeMaxEvt: (int) dsz sender:(CPBitArrayDom*)sender
{
   id<CPClosureList> mList[5];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleClosures:mList];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_engine];
}

-(void) bitFixedEvt:(int)idx sender:(CPBitArrayDom*)sender
{
   [_dom updateFreeBitCount];
    //Empty implementation
   id<CPClosureList> mList[5];
   ORUInt k = 0;
   mList[k] = _net._bitFixedEvt;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleClosures:mList];
}

-(ORStatus) updateMin: (ORULong) newMin
{
    return [_dom updateMin:newMin for:_recv];
}

-(ORStatus) updateMax: (ORULong) newMax
{
    return [_dom updateMax:newMax for:_recv];
}

-(void) setLow:(unsigned int *)newLow
{
    [_dom setLow: newLow for:_recv];
}

-(void) setUp:(unsigned int *)newUp{
    [_dom setUp: newUp for:_recv];
}

-(void) setUp:(unsigned int *)newUp andLow:(unsigned int *)newLow{
   [_dom setUp: newUp andLow:newLow for:_recv];
}

-(TRUInt*) getLow
{
    return [_dom getLow];
}
-(TRUInt*) getUp
{
    return [_dom getUp];
}
-(void)        getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow
{
   return [_dom getUp:currUp andLow:currLow];
}

-(ORStatus) bindUInt64:(ORULong)val
{
    return [_dom bind:val for:_recv];
}

-(ORStatus)bind:(unsigned int *)val{
    return [_dom bindToPat: val for:_recv];
}

-(CPBitVarI*) initCPExplicitBitVar: (id<CPEngine>)engine withLow:(unsigned int*)low andUp:(unsigned int*)up andLen: (unsigned int) len
{
    [self initCPBitVarCore:engine low:low up:up length:len];
    [_dom setLow: low for:self];
    [_dom setUp: up for:self];
    return self;
}

-(CPBitVarI*) initCPExplicitBitVarPat: (CPEngineI*)engine withLow:(unsigned int*)low andUp:(unsigned int *)up andLen:(unsigned int)len
{
    self = [super init];
    _engine  = engine;
    [_engine trackVariable: self];
    setUpNetwork(&_net, [_engine trail]);
    _triggers = nil;
    _dom = [[CPBitArrayDom alloc] initWithBitPat:len withLow:low andUp:up andTrail:[_engine trail]];
    _recv = self;
    return self;
}

// ------------------------------------------------------------------------
// Cluster Constructors
// ------------------------------------------------------------------------
//Integer interpretation of BitVar
+(CPBitVarI*) initCPBitVar: (id<CPEngine>)engine low: (int)low up: (int) up len: (unsigned int) len
{
    unsigned int uLow[2];
    unsigned int uUp[2];
    uLow[0] = 0;
    uLow[1] = low;
    uUp[0] = 0;
    uUp[1] = up;
    CPBitVarI* x = [[CPBitVarI alloc] initCPExplicitBitVar: engine withLow: uLow andUp: uUp andLen: len];
    return x;
}

//Binary bit pattern interpretation of BitVar
+(CPBitVarI*) initCPBitVarWithPat:(CPEngineI*)engine withLow:(unsigned int *)low andUp:(unsigned int *)up andLen:(unsigned int)len{
    
    CPBitVarI* x = [[CPBitVarI alloc] initCPExplicitBitVarPat:engine withLow: low andUp: up andLen: len];
    return x;
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
    [aCoder encodeObject:_dom];
    [aCoder encodeObject:_engine];
    [aCoder encodeObject:_recv];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
    _dom = [[aDecoder decodeObject] retain];
    _engine = [aDecoder decodeObject];
    setUpNetwork(&_net, [_engine trail]);
    _triggers = nil;
    _recv = [[aDecoder decodeObject] retain];
    return self;
}
@end

@implementation CPBitVarMultiCast

-(id)initVarMC:(int)n 
{
    self = [super init];
    _mx  = n;
    _tab = malloc(sizeof(CPBitVarI*)*_mx);
    _tracksLoseEvt = false;
    _nb  = 0;
    return self;
}
-(void) dealloc
{
    //NSLog(@"multicast object %p dealloc'd\n",self);
    free(_tab);
    [super dealloc];
}
-(void) addVar:(CPBitVarI*)v
{
    if (_nb >= _mx) {
        _tab = realloc(_tab,sizeof(CPBitVarI*)*(_mx<<1));
        _mx <<= 1;
    }
    _tab[_nb] = v;  // DO NOT RETAIN. v will point to us because of the delegate
    [_tab[_nb] setDelegate:self];
    _tracksLoseEvt |= [_tab[_nb] tracksLoseEvt];    
    _nb++;
}
-(void)bindEvt
{
    for(int i=0;i<_nb;i++)
        [_tab[i] bindEvt];
}
-(void)bitFixedEvt: (ORUInt) dsz sender:(CPBitArrayDom*)sender
{
    for(int i=0;i<_nb;i++)
        [_tab[i] bitFixedEvt:dsz sender:sender];
}
@end
