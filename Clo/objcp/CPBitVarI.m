/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/
#import "CPBitVar.h"
#import "CPBitVarI.h"
#import "CPEngineI.h"
#import "CPTrigger.h"
#import "CPBitArrayDom.h"

/*****************************************************************************************/
/*                        Constraint Network Handling                                    */
/*****************************************************************************************/

static void setUpNetwork(CPBitEventNetwork* net,id<ORTrail> t,ORUInt low,ORUInt up, ORUInt len)
{
   for(ORInt i = 0 ; i < 2;i++) {
      net->_bitFixedEvt[i]    = makeTRId(t,nil);
      net->_bitFixedAtIEvt[i] = makeTRId(t,nil);
      net->_boundsEvt[i]      = makeTRId(t,nil);
      net->_bindEvt[i]        = makeTRId(t,nil);
      net->_domEvt[i]         = makeTRId(t,nil);
      net->_minEvt[i]         = makeTRId(t,nil);
      net->_maxEvt[i]         = makeTRId(t,nil);
      net->_ac5[i]            = makeTRId(t, nil);
   }
   net->_bitLength = len;
   net->_bitFixedAtEvt = malloc(sizeof(TRId*) * net->_bitLength);
   for (int j=0; j<len; j++){
      net->_bitFixedAtEvt[j] = malloc(sizeof(TRId)*2);
      net->_bitFixedAtEvt[j][0] = makeTRId(t, nil);
      net->_bitFixedAtEvt[j][1] = makeTRId(t, nil);
   }
}

static void deallocNetwork(CPBitEventNetwork* net)
{
   freeList(net->_bitFixedEvt[0]._val);
   freeList(net->_bitFixedAtIEvt[0]._val);
   freeList(net->_boundsEvt[0]._val);
   freeList(net->_bindEvt[0]._val);
   freeList(net->_domEvt[0]._val);
   freeList(net->_minEvt[0]._val);
   freeList(net->_maxEvt[0]._val);
   freeList(net->_ac5[0]._val);

   for (int i=0; i<net->_bitLength; i++)
      freeList(net->_bitFixedAtEvt[i][0]._val);
   free(net->_bitFixedAtEvt);
}

static NSMutableSet* collectConstraints(CPBitEventNetwork* net,NSMutableSet* rv)
{
   collectList(net->_bitFixedEvt[0]._val,rv);
   collectList(net->_bitFixedAtIEvt[0]._val,rv);
   collectList(net->_boundsEvt[0]._val,rv);
   collectList(net->_bindEvt[0]._val,rv);
   collectList(net->_domEvt[0]._val,rv);
   collectList(net->_minEvt[0]._val,rv);
   collectList(net->_maxEvt[0]._val,rv);
   collectList(net->_ac5[0]._val,rv);
   
   for (int i=0; i<net->_bitLength; i++) {
      collectList(net->_bitFixedAtEvt[i][0]._val, rv);
   }
   return rv;
}

/*****************************************************************************************/

@interface CPBitVarSnapshot : NSObject<ORSnapshot,NSCoding> {
   ORUInt    _name;
   union {
      ORInt _value;
      id<CPDom>   _dom;
   }              _rep;
   BOOL         _asDom;
}
-(CPBitVarSnapshot*)initCPBitVarSnapshot:(CPBitVarI*)v;
-(int)intValue;
-(ORBool)boolValue;
@end

// TOFIX: GREG
@implementation CPBitVarSnapshot
-(CPBitVarSnapshot*)initCPBitVarSnapshot:(CPBitVarI*)v
{
   self = [super init];
   _name = [v getId];
   _asDom = ![v bound];
//   if (_asDom) {
//      _rep._dom = [[v domain] copy];
//   } else
//      _rep._value = [v min];
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
-(ORFloat) floatValue
{
   return _asDom ? [_rep._dom min] : _rep._value;   
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORBool) at:&_asDom];
   if (_asDom) {
      [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_rep._value];
   } else {
      [aCoder encodeObject:_rep._dom];
   }
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORBool) at:&_asDom];
   if (_asDom)
      [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_rep._value];
   else {
      _rep._dom = [[aDecoder decodeObject] retain];
   }
   return self;
}
@end

//****************************************************
@implementation CPBitVarI
-(CPBitVarI*) initCPBitVarCore:(CPEngineI*)engine low: (unsigned int*) low up: (unsigned int*)up length:(int)len
{
//    self = [super init];
//    _engine = engine;
//    [_engine trackVariable: self];
//    setUpNetwork(&_net, [_engine trail], *low, *up);
      _net._bitLength = len;
//    _triggers = nil;
//    _dom = [[CPBitArrayDom alloc] initWithLength: len withTrail:[_engine trail]];
//    _recv = self;
//}
   self = [super init];
//_vc = CPVCBare;
//_isBool = NO;
   _engine  = engine;
   [_engine trackVariable: self];
   
   setUpNetwork(&_net, [_engine trail],*low,*up,len);
   _triggers = nil;
//_dom = nil;
   _dom = [[CPBitArrayDom alloc] initWithLength: len withTrail:[_engine trail]];
   _vc = CPVCBare;
   _recv = nil;
return self;
}

-(void)dealloc
{
    //NSLog(@"CBitVar::dealloc %d\n",_name);
    if (_recv != nil)
        [_recv release];
    [_dom release];     
    deallocNetwork(&_net);
    if (_triggers != nil)
        [_triggers release];    
    [super dealloc];
}
-(id<CPEngine>) engine
{
    return _engine;
}

-(id<ORTracker>) tracker
{
   return _engine;
}

-(id<CPBitVarNotifier>) delegate
{
    return _recv;
}
//-(void) setDelegate:(id<CPBitVarNotifier>) d
//{
//    if (_recv != d) {
//        if (_recv != self) {
//            @throw [[NSException alloc] initWithName:@"Internal Error" 
//                                              reason:@"Trying to set a delegate that already exists" 
//                                            userInfo:nil];
//        }
//        _recv = [d retain];
//    }
//}
-(void) setDelegate:(id<CPBitVarNotifier,NSCoding>) d
{
   if (_recv != d) {
      if (_recv != nil) {
         @throw [[NSException alloc] initWithName:@"Internal Error"
                                           reason:@"Trying to set a delegate that already exists"
                                         userInfo:nil];
      }
      _recv = [d retain];
   }
}

-(NSMutableSet*)constraints
{
   NSMutableSet* rv = collectConstraints(&_net,[[NSMutableSet alloc] initWithCapacity:2]);
   if (_recv) {
      NSMutableSet* rc = [_recv constraints];
      [rv unionSet:rc];
      [rc release];
   }
   return rv;
}

-(enum CPVarClass)varClass
{
   return _vc;
}

-(ORBool)bound
{
    return [_dom bound];
}

-(ORInt) bitLength
{
   return [_dom getLength];
}
-(uint64) min
{
    return [_dom min];
}

-(uint64) max 
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
-(ORUInt) maxRank
{
   return[_dom getMaxRank];
}
-(ORUInt*) atRank:(ORULong)rnk
{
   return[_dom atRank:rnk];
}
-(ORInt)domsize
{
    return [_dom domsize];
}

-(ORULong) numPatterns  
{
   return [_dom numPatterns];
}

-(unsigned int) randomFreeBit
{
//   NSLog(@"%@",self);
   return [_dom randomFreeBit];
}

-(unsigned int) lsFreeBit
{
   return [_dom lsFreeBit];
}

-(unsigned int) msFreeBit
{
   return [_dom msFreeBit];
}
-(unsigned int) midFreeBit
{
//   unsigned int freeBits = [_dom domsize];
//   unsigned int midFreeBit = [_dom midFreeBit];
//   NSLog(@"%@ mid free bit is %u",_dom, midFreeBit);
//   return midFreeBit;
   return [_dom midFreeBit];
}
-(ORStatus) bind:(ORUInt)bit to:(BOOL)value
{
   return [_dom setBit:bit to:value for:self];
}
-(ORBool)member:(unsigned int*)v
{
    return [_dom member:v];
}
-(ORBool) isFree:(ORUInt)pos{
   ORBool temp = [_dom isFree:pos];
   return temp;
//   return [_dom isFree:pos];
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
   hookupEvent(_engine, _net._bitFixedEvt, nil, c, HIGHEST_PRIO);
}
-(void) whenChangeDo:(CPCoreConstraint*) c
{
   hookupEvent(_engine, _net._bitFixedEvt, nil, c, HIGHEST_PRIO);
}
-(void)whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_engine, _net._domEvt, todo, c, p);
}
-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo
{
   hookupEvent(_engine, _net._boundsEvt, todo, c, p);
}
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo
{
   hookupEvent(_engine, _net._minEvt, todo, c, p);
}
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo
{
   hookupEvent(_engine, _net._maxEvt, todo, c, p);
}

-(void) whenBitFixed: (CPCoreConstraint*)c at:(int)p do: (ConstraintCallback) todo
{
   hookupEvent(_engine, _net._bitFixedEvt, todo, c, p);
}
-(void) whenBitFixedAtI:(CPCoreConstraint*)c at:(int)p withI:(int)i do:(ConstraintIntCallBack) todo
{
   hookupEvent(_engine, _net._bitFixedAtIEvt, todo, c, p);
}
-(void) whenBitFixedAt:(ORUInt)i propagate:(CPCoreConstraint*) c
{
   hookupEvent(_engine, _net._bitFixedAtEvt[i], nil, c, HIGHEST_PRIO);
}

-(void) createTriggers
{
    if (_triggers == nil) {
        uint64 low = [_dom min];
        uint64 up = [_dom max];
        _triggers = [CPTriggerMap triggerMapFrom:(ORInt)low to:(ORInt)up dense:(up-low+1)<256];
    }
}

-(ORStatus) bindEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender
{
   
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:sender];
   if (s==ORFailure) return s;

   id<CPEventNode> mList[8];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = _net._minEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleAC3:mList];
    if (_triggers != nil)
        [_triggers bindEvt:_engine];
   return ORSuspend;
}

-(ORStatus) changeMinEvt: (ORUInt) dsz sender:(CPBitArrayDom*)sender
{
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:sender];
   if (s==ORFailure) return s;

   id<CPEventNode> mList[8];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = _net._minEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleAC3:mList];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_engine];
   return ORSuspend;
}
-(ORStatus) changeMaxEvt: (ORUInt) dsz sender:(CPBitArrayDom*)sender
{
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:sender];
   if (s==ORFailure) return s;

   id<CPEventNode> mList[8];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleAC3:mList];
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_engine];
   
   return ORSuspend;
}

-(ORStatus) bitFixedEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender
{
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:sender];
   if (s==ORFailure) return s;

//   [_dom updateFreeBitCount];
    //Empty implementation
   id<CPEventNode> mList[8];
   ORUInt k = 0;
   mList[k] = _net._bitFixedEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleAC3:mList];
   
   
   return ORSuspend;
}

-(ORStatus) bitFixedAtIEvt:(ORUInt)dsz at:(ORUInt)idx sender:(CPBitArrayDom*)sender
{
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:sender];
   if (s==ORFailure) return s;
   
   //Empty implementation
   id<CPEventNode> mList[8];
   ORUInt k = 0;
   mList[k] = _net._bitFixedAtIEvt[0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleAC3:mList];
   
   
   return ORSuspend;
}

-(ORStatus) bitFixedAtEvt:(ORUInt)dsz at:(ORUInt)idx sender:(CPBitArrayDom*)sender
{
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:sender];
   if (s==ORFailure) return s;
   
   //   [_dom updateFreeBitCount];
   //Empty implementation
   id<CPEventNode> mList[8];
   ORUInt k = 0;
   mList[k] = _net._bitFixedAtEvt[idx][0]._val;
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleAC3:mList];
   
   return ORSuspend;
}


-(ORStatus) updateMin: (uint64) newMin
{
    return [_dom updateMin:newMin for:self];
}

-(ORStatus) updateMax: (uint64) newMax
{
    return [_dom updateMax:newMax for:self];
}

-(void) setLow:(unsigned int *)newLow
{
    [_dom setLow: newLow for:self];
}

-(void) setUp:(unsigned int *)newUp{
    [_dom setUp: newUp for:self];
}

-(void) setUp:(unsigned int *)newUp andLow:(unsigned int *)newLow
{
   [_dom setUp: newUp andLow:newLow for:self];
}

-(TRUInt*) getLow
{
    return [_dom getLow];
}
-(TRUInt*) getUp
{
    return [_dom getUp];
}
-(void) getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow
{
   return [_dom getUp:currUp andLow:currLow];
}

-(ORStatus) bindUInt64:(uint64)val
{
    return [_dom bind:val for:self];
}

-(ORStatus)bind:(ORUInt*)val{
    return [_dom bindToPat: val for:self];
}
-(ORStatus) remove:(ORUInt)val
{
   return [_dom remove:val];
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
    setUpNetwork(&_net, [_engine trail], *low, *up,len);
    _triggers = nil;
    _dom = [[CPBitArrayDom alloc] initWithBitPat:len withLow:low andUp:up andTrail:[_engine trail]];
    _recv = nil;
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
    setUpNetwork(&_net, [_engine trail], [_dom getLow]->_val, [_dom getUp]->_val,[_dom getLength]);
    _triggers = nil;
    _recv = [[aDecoder decodeObject] retain];
    return self;
}
@end

@implementation CPBitVarMultiCast
-(id)initVarMC:(ORInt)n root:(CPBitVarI*)root
{
   self = [super init];
   _mx  = n;
   _tab = malloc(sizeof(id<CPBitVarNotifier>)*_mx);
   _loseValIMP   = malloc(sizeof(UBType)*_mx);
   _minIMP   = malloc(sizeof(UBType)*_mx);
   _maxIMP   = malloc(sizeof(UBType)*_mx);
   _bitFixedIMP   = malloc(sizeof(UBType)*_mx);
   for (int i = 0; i<_bitLength; i++) {
      _bitFixedAtIMP[i]   = malloc(sizeof(UBType)*_mx);
   }
   _tracksLoseEvt = false;
   [root setDelegate:self];
   _nb = 0;
   return self;
}
-(ORInt)getId
{
   assert(FALSE);
   return 0;
}
-(void)setDelegate:(id<CPBitVarNotifier>)delegate
{}
-(void) dealloc
{
   /*
    for(ORInt i=0;i<_nb;i++) {
    if ([_tab[i] isKindOfClass:[CPLiterals class]])
    [_tab[i] release];
    }
    */
   free(_tab);
   free(_minIMP);
   free(_maxIMP);
   free(_loseValIMP);
   free(_bitFixedIMP);
   free(_bitFixedAtIIMP);
   for (int i = 0; i<_bitLength; i++) {
      free(_bitFixedAtIMP[i]);
   }
   free(_bitFixedAtIMP);
   [super dealloc];
}
//-(CPBitVarLiterals*) findLiterals: (CPBitVarI*) ref
//{
//   if (_literals)
//      return _literals;
//   CPBitVarLiterals* newLits = [[CPBitVarLiterals alloc] initCPBitVarLiterals:ref];
//   _tracksLoseEvt = YES;
//   id<ORTrail> theTrail = [[ref engine] trail];
//   [theTrail trailClosure: ^{
//      _literals = NULL;
//   }];
//   _literals = newLits;
//   return newLits;
//}
-(void) addVar:(CPBitVarI*)v
{
   if (_nb >= _mx) {
      _tab = realloc(_tab,sizeof(id<CPBitVarNotifier>)*(_mx<<1));
      _loseValIMP = realloc(_loseValIMP,sizeof(UBType)*(_mx << 1));
      _minIMP     = realloc(_minIMP,sizeof(UBType)*(_mx << 1));
      _maxIMP     = realloc(_maxIMP,sizeof(UBType)*(_mx << 1));
      _bitFixedIMP = realloc(_bitFixedIMP, sizeof(UBType)*(_mx << 1));
      for (int i=0; i<_bitLength; i++) {
         _bitFixedAtIMP[i] = realloc(_bitFixedAtIMP[i], sizeof(UBType)*(_mx << 1)*_bitLength);
      }
      _mx <<= 1;
   }
   _tab[_nb] = v;  // DO NOT RETAIN. v will point to us because of the delegate
   _tracksLoseEvt |= [_tab[_nb] tracksLoseEvt:nil];
   _loseValIMP[_nb] = (UBType)[v methodForSelector:@selector(loseValEvt:sender:)];
   _minIMP[_nb] = (UBType)[v methodForSelector:@selector(changeMinEvt:sender:)];
   _maxIMP[_nb] = (UBType)[v methodForSelector:@selector(changeMaxEvt:sender:)];
   _bitFixedIMP[_nb] = (UBType)[v methodForSelector:@selector(bitFixedEvt:sender:)];
   for (int i=0; i<_bitLength; i++) {
      _bitFixedAtIMP[i][_nb] = (UBType)[v methodForSelector:@selector(bitFixedAtEvt:sender:)];
   }
//   _bitFixedAtIMP[_nb] = (UBType)[v methodForSelector:@selector(bitFixedEvt:sender:)];
   id<ORTrail> theTrail = [[v engine] trail];
   ORInt toFix = _nb;
   __block CPBitVarMultiCast* me = self;
   [theTrail trailClosure:^{
      me->_tab[toFix] = NULL;
      me->_loseValIMP[toFix] = NULL;
      me->_minIMP[toFix] = NULL;
      me->_maxIMP[toFix] = NULL;
      me->_bitFixedIMP[toFix] = NULL;
      for (int i=0; i<_bitLength; i++) {
         me->_bitFixedAtIMP[i][toFix] = NULL;
      }
//      me->_bitFixedAtIMP[toFix] = NULL;
      me->_nb = toFix;  // [ldm] This is critical (see comment below in bindEvt)
   }];
   _nb++;
   ORInt nbBare = 0;
   for(ORInt i=0;i<_nb;i++) {
      if (_tab[i] !=nil)
         nbBare += ([_tab[i] varClass] == CPVCBare);
   }
   assert(nbBare<=1);
}
-(NSMutableSet*)constraints
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:8];
   for(ORInt i=0;i<_nb;i++) {
      NSMutableSet* ti = [_tab[i] constraints];
      [rv unionSet:ti];
      [ti release];
   }
   return rv;
}



-(NSString*)description
{
   static const char* classes[] = {"Bare","Shift","Affine","EQLit","Literals","Flip","NEQLit"};
   NSMutableString* buf = [NSMutableString stringWithCapacity:64];
   [buf appendFormat:@"MC:<%d>[",_nb];
   for(ORUInt k=0;k<_nb;k++) {
      if (_tab[k] == nil)
         [buf appendFormat:@"nil %c",k < _nb -1 ? ',' : ']'];
      else
         [buf appendFormat:@"%d-%s %c",[_tab[k] getId],classes[[_tab[k] varClass]],k < _nb -1 ? ',' : ']'];
   }
   return buf;
}
-(void) setTracksLoseEvt
{
   _tracksLoseEvt = true;
}
-(ORBool) tracksLoseEvt:(CPBitArrayDom*)sender
{
   return _tracksLoseEvt;
}
-(ORStatus)bindEvt:(CPBitArrayDom*)sender
{
   // If _nb > 0 but the _tab entries are nil, this would inadvertently
   // set ok to ORFailure which is wrong. Hence it is critical to also
   // backtrack the size of the array in addVar.
   for(ORInt i=0;i<_nb;i++) {
      ORStatus ok = [_tab[i] bindEvt:sender];
      if (!ok) return ok;
   }
   return ORSuspend;
}

-(ORStatus) changeMinEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender
{
   SEL ms = @selector(changeMinEvt:sender:);
   for(ORInt i=0;i<_nb;i++) {
      //ORStatus ok = [_tab[i] changeMinEvt:dsz sender:sender];
      assert(_minIMP[i]);
      ORStatus ok = _minIMP[i](_tab[i],ms,dsz,sender);
      if (!ok) return ok;
   }
   return ORSuspend;
}
-(ORStatus) changeMaxEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender
{
   SEL ms = @selector(changeMaxEvt:sender:);
   for(ORInt i=0;i<_nb;i++) {
      //ORStatus ok = [_tab[i] changeMaxEvt:dsz sender:sender];
      assert(_maxIMP[i]);
      ORStatus ok = _maxIMP[i](_tab[i],ms,dsz,sender);
      if (!ok) return ok;
   }
   return ORSuspend;
}
-(ORStatus) loseValEvt:(ORUInt)val sender:(id<CPDom>)sender
{
   if (!_tracksLoseEvt) return ORSuspend;
   ORStatus ok = ORSuspend;
   for(ORInt i=0;i<_nb;i++) {
      //ORStatus ok = [_tab[i] loseValEvt:val sender:sender];
      if (_loseValIMP[i])
         ok = _loseValIMP[i](_tab[i],@selector(loseValEvt:sender:),val,sender);
      if (ok == ORFailure) return ok;
   }
   return ORSuspend;
}
-(ORStatus)bitFixedEvt: (ORUInt) dsz sender:(CPBitArrayDom*)sender
{
   ORStatus ok = ORSuspend;
   for(ORInt i=0;i<_nb;i++) {
      if (_bitFixedIMP[i])
         ok = _bitFixedIMP[i](_tab[i],@selector(bitFixedEvt:sender:),dsz,sender);
      if (ok == ORFailure)
         return ok;
   }
   return ORSuspend;
}

-(ORStatus) bitFixedEvt:(ORUInt)dsz at:(ORUInt)i sender:(CPBitArrayDom *)sender{
   NSLog(@"BitFixedEvt at:%d\n",i);
   ORStatus ok = ORSuspend;
   for(ORInt j=0;j<_nb;j++) {
      if (_bitFixedAtIMP[i][j])
         ok = _bitFixedAtIMP[i][j](_tab[i],@selector(bitFixedAtEvt:sender:),dsz,sender);
      if (ok == ORFailure)
         return ok;
   }
   return ORSuspend;
}
-(ORStatus) bitFixedAtEvt:(ORUInt)dsz at:(ORUInt)i sender:(CPBitArrayDom *)sender{
   NSLog(@"BitFixedEvt at:%d\n",i);
   ORStatus ok = ORSuspend;
   for(ORInt j=0;j<_nb;j++) {
      if (_bitFixedAtIMP[i][j])
         ok = _bitFixedAtIMP[i][j](_tab[i],@selector(bitFixedAtEvt:sender:),dsz,sender);
      if (ok == ORFailure)
         return ok;
   }
   return ORSuspend;
}
-(ORStatus) bitFixedAtIEvt:(ORUInt)dsz at:(ORUInt)i sender:(CPBitArrayDom *)sender{
   NSLog(@"BitFixedAtIEvt at:%d\n",i);
   ORStatus ok = ORSuspend;
   for(ORInt i=0;i<_nb;i++) {
      //ORStatus ok = [_tab[i] loseValEvt:val sender:sender];
      if (_bitFixedAtIIMP[i])
         ok = _bitFixedAtIIMP[i](_tab[i],@selector(bitFixedAtIEvt:at:sender:),dsz,i,sender);
      if (ok == ORFailure) return ok;
   }
   return ORSuspend;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_mx];
   for(ORInt k=0;k<_nb;k++)
      [aCoder encodeObject:_tab[k]];
   [aCoder encodeValueOfObjCType:@encode(ORBool) at:&_tracksLoseEvt];
}
- (id)initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_mx];
   _tab = malloc(sizeof(CPBitVarI*)*_mx);
   for(ORInt k=0;k<_nb;k++)
      _tab[k] = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORBool) at:&_tracksLoseEvt];
   return self;
}
@end


