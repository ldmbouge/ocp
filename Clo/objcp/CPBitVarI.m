/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBitVarI.h"
#import "CPBitVar.h"
#import "CPEngine.h"
#import "CPEngineI.h"
#import "CPTrigger.h"
#import "CPBitArrayDom.h"
#import "CPIntVarI.h"

/*****************************************************************************************/
/*                        Constraint Network Handling                                    */
/*****************************************************************************************/

static void setUpNetwork(CPBitEventNetwork* net,ORTrail* t) 
{
    net->_boundsEvt = makeTRId(t,nil);
    net->_bitFixedEvt = makeTRId(t, nil);
    net->_minEvt    = makeTRId(t,nil);
    net->_maxEvt    = makeTRId(t,nil);
}

static void freeList(VarEventNode* list)
{
    while (list) {
        VarEventNode* next = list->_node;
        [list release];
        list = next;
    }
}

static void deallocNetwork(CPBitEventNetwork* net) 
{
    freeList(net->_boundsEvt._val);
    freeList(net->_bitFixedEvt._val);
    freeList(net->_minEvt._val);
    freeList(net->_maxEvt._val);
}

@implementation CPBitVarI
-(void) initCPBitVarCore:(CPEngineI*)fdm low: (unsigned int*) low up: (unsigned int*)up length:(int)len
{
    self = [super init];
    _fdm  = fdm;
    [_fdm trackVariable: self];
    setUpNetwork(&_net, [fdm trail]);
    _triggers = nil;
    _dom = [[CPBitArrayDom alloc] initWithLength: len withTrail:[fdm trail]];
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
-(void) setId:(CPUInt)name
{
    _name = name;
}
-(id<CPEngine>) engine
{
    return _fdm;
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

-(bool)bound
{
    return [_dom bound];
}
 
-(uint64) min
{
    return [_dom min];
}

-(uint64) max 
{ 
    return [_dom max];
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

-(void) bounds:(CPBounds*) bnd
{
    *bnd = (CPBounds){(ORInt)[_dom min],(ORInt)[_dom max]};
}

-(unsigned int)domsize
{
    return [_dom domsize];
}

-(bool)member:(unsigned int*)v
{
    return [_dom member:v];
}

-(NSString*)description
{
    return [_dom description];
}
-(bool) tracksLoseEvt
{
    return _triggers != nil;
}
// nothing to do here
-(void) setTracksLoseEvt
{
}
-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo 
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._boundsEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._boundsEvt, evt, [_fdm trail]);
    [evt release];
}
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._minEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._minEvt, evt, [_fdm trail]);
    [evt release];
}
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._maxEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._maxEvt, evt, [_fdm trail]);
    [evt release];
}

-(void) whenBitFixed: (CPCoreConstraint*)c at:(int)p do: (ConstraintCallback) todo 
{
    id evt = [[VarEventNode alloc] initVarEventNode:_net._bitFixedEvt._val
                                            trigger:todo
                                               cstr:c
                                                 at:p];
    assignTRId(&_net._bitFixedEvt, evt, [_fdm trail]);
    [evt release];   
}



-(void) createTriggers
{
    if (_triggers == nil) {
        uint64 low = [_dom min];
        uint64 up = [_dom max];
        _triggers = [CPTriggerMap triggerMapFrom:(ORInt)low to:(ORInt)up dense:(up-low+1)<256];
    }
}

-(void) bindEvt
{
   VarEventNode* mList[5];
   CPUInt k = 0;
   mList[k] = _net._boundsEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._minEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_fdm scheduleAC3:mList];
    if (_triggers != nil)
        [_triggers bindEvt:_fdm];
}

-(void) changeMinEvt: (int) dsz
{
   VarEventNode* mList[5];
   CPUInt k = 0;
   mList[k] = _net._boundsEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._minEvt._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_fdm scheduleAC3:mList];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_fdm];
}
-(void) changeMaxEvt: (int) dsz
{
   VarEventNode* mList[5];
   CPUInt k = 0;
   mList[k] = _net._boundsEvt._val;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_fdm scheduleAC3:mList];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_fdm];
}

-(void) bitFixedEvt:(int)idx
{
    //Empty implementation
   VarEventNode* mList[5];
   CPUInt k = 0;
   mList[k] = _net._bitFixedEvt._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_fdm scheduleAC3:mList];
}

-(ORStatus) updateMin: (uint64) newMin
{
    return [_dom updateMin:newMin for:_recv];
}

-(ORStatus) updateMax: (uint64) newMax
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

-(TRUInt*) getLow
{
    return [_dom getLow];
}
-(TRUInt*) getUp
{
    return [_dom getUp];
}

-(ORStatus) bindUInt64:(uint64)val
{
    return [_dom bind:val for:_recv];
}

-(ORStatus)bind:(unsigned int *)val{
    return [_dom bindToPat: val for:_recv];
}

-(CPBitVarI*) initCPExplicitBitVar: (id<CPEngine>)fdm withLow:(unsigned int*)low andUp:(unsigned int*)up andLen: (unsigned int) len
{
    [self initCPBitVarCore:fdm low:low up:up length:len];
    [_dom setLow: low for:self];
    [_dom setUp: up for:self];
    return self;
}

-(CPBitVarI*) initCPExplicitBitVarPat: (CPEngineI*)fdm withLow:(unsigned int*)low andUp:(unsigned int *)up andLen:(unsigned int)len
{
    self = [super init];
    _fdm  = fdm;
    [_fdm trackVariable: self];
    setUpNetwork(&_net, [fdm trail]);
    _triggers = nil;
    _dom = [[CPBitArrayDom alloc] initWithBitPat:len withLow:low andUp:up andTrail:[fdm trail]];
    _recv = self;
    return self;
}

// ------------------------------------------------------------------------
// Cluster Constructors
// ------------------------------------------------------------------------
//Integer interpretation of BitVar
+(CPBitVarI*) initCPBitVar: (id<CPEngine>) fdm low: (int)low up: (int) up len: (unsigned int) len
{
    unsigned int uLow[2];
    unsigned int uUp[2];
    uLow[0] = 0;
    uLow[1] = low;
    uUp[0] = 0;
    uUp[1] = up;
    CPBitVarI* x = [[CPBitVarI alloc] initCPExplicitBitVar: fdm withLow: uLow andUp: uUp andLen: len];
    return x;
}

//Binary bit pattern interpretation of BitVar
+(CPBitVarI*) initCPBitVarWithPat:(CPEngineI*)fdm withLow:(unsigned int *)low andUp:(unsigned int *)up andLen:(unsigned int)len{
    
    CPBitVarI* x = [[CPBitVarI alloc] initCPExplicitBitVarPat: fdm withLow: low andUp: up andLen: len];
    return x;
}

+(CPTrigger*) createTrigger: (ConstraintCallback) todo
{
    CPTrigger* trig = malloc(sizeof(CPTrigger));
    trig->_cb = [todo copy];
    return trig;
}
 
- (void)encodeWithCoder: (NSCoder *) aCoder
{
    [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_name];
    [aCoder encodeObject:_dom];
    [aCoder encodeObject:_fdm];
    [aCoder encodeObject:_recv];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
    self = [super init];
    [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_name];
    _dom = [[aDecoder decodeObject] retain];
    _fdm = [aDecoder decodeObject];
    setUpNetwork(&_net, [_fdm trail]);
    _triggers = nil;
    _recv = [[aDecoder decodeObject] retain];
    return self;
}
@end

@implementation CPBitVarMultiCast

-(id)initVarMC:(int)n 
{
    [super init];
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
-(void)bitFixedEvt: (CPUInt) dsz
{
    for(int i=0;i<_nb;i++)
        [_tab[i] bitFixedEvt:dsz];
}

- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_mx];
   for(CPInt k=0;k<_nb;k++)
      [aCoder encodeObject:_tab[k]];
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_mx];
   _tab = malloc(sizeof(CPIntVarI*)*_mx);
   for(CPInt k=0;k<_nb;k++)
      _tab[k] = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];   
   return self;
}
@end
