/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "CPBitVarI.h"
#import "CPBitVar.h"
#import "CPSolver.h"
#import "CPSolverI.h"
#import "CPTrigger.h"
#import "CPBitArrayDom.h"

/*****************************************************************************************/
/*                        Constraint Network Handling                                    */
/*****************************************************************************************/

static void setUpNetwork(CPBitEventNetwork* net,CPTrail* t) 
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
-(void) initCPBitVarCore:(CPSolverI*)fdm low: (unsigned int*) low up: (unsigned int*)up length:(int)len
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
-(id<CPSolver>)solver
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
    *bnd = (CPBounds){[_dom min],[_dom max]};
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
        _triggers = [CPTriggerMap triggerMapFrom:low to:up dense:(up-low+1)<256];    
    }
}

-(void) bindEvt
{
    if (_net._boundsEvt._val) 
        [_fdm scheduleAC3:_net._boundsEvt._val];
    if (_net._minEvt._val) 
        [_fdm scheduleAC3:_net._minEvt._val];
    if (_net._maxEvt._val) 
        [_fdm scheduleAC3:_net._maxEvt._val];
    if (_triggers != nil)
        [_triggers bindEvt:_fdm];
}

-(void) changeMinEvt: (int) dsz
{
    if (_net._boundsEvt._val) 
        [_fdm scheduleAC3:_net._boundsEvt._val];
    if (_net._minEvt._val) 
        [_fdm scheduleAC3:_net._minEvt._val];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_fdm];
}
-(void) changeMaxEvt: (int) dsz
{
    if (_net._boundsEvt._val) 
        [_fdm scheduleAC3:_net._boundsEvt._val];
    if (_net._maxEvt._val) 
        [_fdm scheduleAC3:_net._maxEvt._val];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_fdm];
}

-(void) bitFixedEvt:(int)idx
{
    //Empty implementation
    if (_net._bitFixedEvt._val)
        [_fdm scheduleAC3:_net._bitFixedEvt._val];
}

-(CPStatus) updateMin: (uint64) newMin
{
    return [_dom updateMin:newMin for:_recv];
}

-(CPStatus) updateMax: (uint64) newMax
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

-(CPStatus) bindUInt64:(uint64)val
{
    return [_dom bind:val for:_recv];
}

-(CPStatus)bind:(unsigned int *)val{
    return [_dom bindToPat: val for:_recv];
}

-(CPBitVarI*) initCPExplicitBitVar: (id<CPSolver>)fdm withLow:(unsigned int*)low andUp:(unsigned int*)up andLen: (unsigned int) len
{
    [self initCPBitVarCore:fdm low:low up:up length:len];
    [_dom setLow: low for:self];
    [_dom setUp: up for:self];
    return self;
}

-(CPBitVarI*) initCPExplicitBitVarPat: (CPSolverI*)fdm withLow:(unsigned int*)low andUp:(unsigned int *)up andLen:(unsigned int)len
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
+(CPBitVarI*) initCPBitVar: (id<CPSolver>) fdm low: (int)low up: (int) up len: (unsigned int) len
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
+(CPBitVarI*) initCPBitVarWithPat:(CPSolverI*)fdm withLow:(unsigned int *)low andUp:(unsigned int *)up andLen:(unsigned int)len{
    
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
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_mx];
   for(CPInt k=0;k<_nb;k++)
      [aCoder encodeObject:_tab[k]];
   [aCoder encodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_mx];
   _tab = malloc(sizeof(CPIntVarI*)*_mx);
   for(CPInt k=0;k<_nb;k++)
      _tab[k] = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(BOOL) at:&_tracksLoseEvt];   
   return self;
}
@end
