/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/
#import <ORFoundation/ORTrail.h>
#import <CPUKernel/CPLEngine.h>
#import "CPBitVar.h"
#import "CPBitVarI.h"
#import "CPEngineI.h"
#import "CPTrigger.h"
#import "CPBitArrayDom.h"

typedef struct  {
   TRId         _boundsEvt[2];
   TRId           _bindEvt[2];
   TRId            _domEvt[2];
   TRId            _minEvt[2];
   TRId            _maxEvt[2];
   TRId               _ac5[2];
   TRId       _bitFixedEvt[2];
   TRId    _bitFixedAtIEvt[2];
   TRId**      _bitFixedAtEvt;
   ORUInt          _bitLength;
} CPBitEventNetwork;


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
   freeList(net->_bitFixedEvt[0]);
   freeList(net->_bitFixedAtIEvt[0]);
   freeList(net->_boundsEvt[0]);
   freeList(net->_bindEvt[0]);
   freeList(net->_domEvt[0]);
   freeList(net->_minEvt[0]);
   freeList(net->_maxEvt[0]);
   freeList(net->_ac5[0]);

   for (int i=0; i<net->_bitLength; i++)
      freeList(net->_bitFixedAtEvt[i][0]);
   free(net->_bitFixedAtEvt);
}

static NSMutableSet* collectConstraints(CPBitEventNetwork* net,NSMutableSet* rv)
{
   collectList(net->_bitFixedEvt[0],rv);
   collectList(net->_bitFixedAtIEvt[0],rv);
   collectList(net->_boundsEvt[0],rv);
   collectList(net->_bindEvt[0],rv);
   collectList(net->_domEvt[0],rv);
   collectList(net->_minEvt[0],rv);
   collectList(net->_maxEvt[0],rv);
   collectList(net->_ac5[0],rv);
   
   for (int i=0; i<net->_bitLength; i++) {
      collectList(net->_bitFixedAtEvt[i][0], rv);
   }
   return rv;
}

/*****************************************************************************************/

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
-(ORInt)intValue
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
@implementation CPBitVarI {
@public
   CPBitEventNetwork   _net;
   TRId*      _implications;
}
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
   _trail = [engine trail];
//_vc = CPVCBare;
//_isBool = NO;
   _engine  = engine;
   [_engine trackVariable: self];
   
   setUpNetwork(&_net, _trail,*low,*up,len);
   _triggers = nil;
//_dom = nil;
//   _dom = [[CPBitArrayDom alloc] initWithLength:len withTrail:_trail];
   _dom = [[CPBitArrayDom alloc] initWithLength:len withEngine:_engine withTrail:_trail];
   _levels = malloc(sizeof(TRUInt)*len);
   _implications = malloc(sizeof(TRId)*len);
   for (int i=0; i<len; i++) {
      _levels[i] = makeTRUInt(_trail, -1);
      _implications[i] = makeTRId(_trail, 0);
   }
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

-(id<CPBitVar>) dereference{
   //This is defined in the CPBitVar protocol. Not sure what it is supposed to do...
   return self;
}
-(ORInt) degree{
   //required for the CPVar protocol, not sure of its use.
   return 0;
}
-(id) takeSnapshot: (ORInt) id
{
   return [[CPBitVarSnapshot alloc] initCPBitVarSnapshot: self name: id];
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

-(unsigned int*) smaxArray
{
   return [_dom smaxArray];
}

-(unsigned int*) minArray
{
    return [_dom minArray];
}

-(unsigned int*) sminArray
{
   return [_dom sminArray];
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
-(ORStatus) bind:(ORUInt)bit to:(ORBool)value
{
   return [_dom setBit:bit to:value for:self];
}
-(ORBool)member:(unsigned int*)v
{
    return [_dom member:v];
}

-(ORBool) getBit:(ORUInt) index
{
   return[_dom getBit:index];
}

-(ORUInt) getLevelBitWasSet:(ORUInt)bit{
   return [_dom getLevelForBit:bit];
//   return _levels[bit]._val;
}
-(void) bit:(ORUInt)i setAtLevel:(ORUInt)l
{
   assignTRUInt(&_levels[i], l, _trail);
}
-(id<CPBVConstraint>) getImplicationForBit:(ORUInt)i
{
   return (id<CPBVConstraint>)_implications[i];
}

-(ORBool) isFree:(ORUInt)pos{
//   ORBool temp = [_dom isFree:pos];
//   return temp;
   return [_dom isFree:pos];
}
-(NSString*)stringValue
{
   return [_dom description];
}
-(NSString*)description
{
   NSString* domStr = [_dom description];
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   [buf appendFormat:@"<CPBitVar : %p  dom = %@ >",self,domStr];
   return buf;
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
//-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo
//{
//   hookupEvent(_engine, _net._bitFixedEvt, nil, c, HIGHEST_PRIO);
//}
-(void)whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf:(CPCoreConstraint*)c
{
   hookupEvent(_engine, _net._domEvt, todo, c, p);
}
-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo
{
   hookupEvent(_engine, _net._boundsEvt, todo, c, p);
}
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo
{
   hookupEvent(_engine, _net._minEvt, todo, c, p);
}
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo
{
   hookupEvent(_engine, _net._maxEvt, todo, c, p);
}

-(void) whenBitFixed: (CPCoreConstraint*)c at:(ORUInt)p do: (ORClosure) todo
{
   hookupEvent(_engine, _net._bitFixedEvt, todo, c, p);
}
//-(void) whenBitFixedAtI:(CPCoreConstraint*)c at:(int)p withI:(int)i do:(ConstraintCallback) todo
-(void) whenBitFixedAtI:(CPCoreConstraint*)c at:(ORUInt)p do:(ORClosure) todo
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
        ORULong low = [_dom min];
        ORULong up = [_dom max];
        _triggers = [CPTriggerMap triggerMapFrom:(ORInt)low to:(ORInt)up dense:(up-low+1)<256];
    }
}

-(ORStatus) bindEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender
{
//<<<<<<< HEAD
   
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:dsz sender:sender];
   if (s==ORFailure) return s;

//   id<CPEventNode> mList[8];
//   ORUInt k = 0;
//   mList[k] = _net._boundsEvt[0]._val;
//   k += mList[k] != NULL;
//   mList[k] = _net._minEvt[0]._val;
//   k += mList[k] != NULL;
//   mList[k] = _net._maxEvt[0]._val;
//=======
   id<CPClosureList> mList[5];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._minEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt[0];
//>>>>>>> master
   k += mList[k] != NULL;
   mList[k] = NULL;
   [_engine scheduleClosures:mList];
    if (_triggers != nil)
        [_triggers bindEvt:_engine];
   return ORSuspend;
}

-(ORStatus) changeMinEvt: (ORUInt) dsz sender:(CPBitArrayDom*)sender
{
//<<<<<<< HEAD
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:dsz sender:sender];
   if (s==ORFailure) return s;

//   id<CPEventNode> mList[8];
//   ORUInt k = 0;
//   mList[k] = _net._boundsEvt[0]._val;
//   k += mList[k] != NULL;
//   mList[k] = _net._minEvt[0]._val;
//=======
   id<CPClosureList> mList[5];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._minEvt[0];
//>>>>>>> master
   k += mList[k] != NULL;
   mList[k] = NULL;
//   [_engine scheduleClosures:mList];
   scheduleClosures(_engine, mList);
   
   if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_engine];
   return ORSuspend;
}
-(ORStatus) changeMaxEvt: (ORUInt) dsz sender:(CPBitArrayDom*)sender
{
//<<<<<<< HEAD
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:dsz sender:sender];
   if (s==ORFailure) return s;

//   id<CPEventNode> mList[8];
//   ORUInt k = 0;
//   mList[k] = _net._boundsEvt[0]._val;
//   k += mList[k] != NULL;
//   mList[k] = _net._maxEvt[0]._val;
//=======
   id<CPClosureList> mList[5];
   ORUInt k = 0;
   mList[k] = _net._boundsEvt[0];
   k += mList[k] != NULL;
   mList[k] = _net._maxEvt[0];
//>>>>>>> master
   k += mList[k] != NULL;
   mList[k] = NULL;
//   [_engine scheduleClosures:mList];
   scheduleClosures(_engine, mList);
    if (dsz==1 && _triggers != nil)
        [_triggers bindEvt:_engine];
   
   return ORSuspend;
}

-(ORStatus) bitFixedEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender
{
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:dsz sender:sender];
   if (s==ORFailure) return s;

//   [_dom updateFreeBitCount];
    //Empty implementation
//<<<<<<< HEAD
   id<CPClosureList> mList[5];
   ORUInt k = 0;
   mList[k] = _net._bitFixedEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
//   [_engine scheduleClosures:mList];
   scheduleClosures(_engine, mList);
   
   return ORSuspend;
}

-(ORStatus) bitFixedAtIEvt:(ORUInt)dsz at:(ORUInt)idx sender:(CPBitArrayDom*)sender
{
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:dsz sender:sender];
   if (s==ORFailure) return s;
   
   //Empty implementation
   id<CPClosureList> mList[8];
   ORUInt k = 0;
   mList[k] = _net._bitFixedAtIEvt[0];
   k += mList[k] != NULL;
   mList[k] = NULL;
//   [_engine scheduleAC3:mList];
   scheduleClosures(_engine, mList);
   
   return ORSuspend;
}

-(ORStatus) bitFixedAtEvt:(ORUInt)dsz at:(ORUInt)idx sender:(CPBitArrayDom*)sender
{
   ORStatus s = _recv==nil ? ORSuspend : [_recv bindEvt:dsz sender:sender];
   if (s==ORFailure) return s;
   
   //   [_dom updateFreeBitCount];
   //Empty implementation
   id<CPClosureList> mList[8];
   ORUInt k = 0;
   mList[k] = _net._bitFixedAtEvt[idx][0];
   k += mList[k] != NULL;
   mList[k] = NULL;
//   [_engine scheduleAC3:mList];
   scheduleClosures(_engine, mList);
   
   return ORSuspend;
}


//-(ORStatus) updateMin: (uint64) newMin
////=======
//   id<CPClosureList> mList[5];
//   ORUInt k = 0;
//   mList[k] = _net._bitFixedEvt;
//   k += mList[k] != NULL;
//   mList[k] = NULL;
//   [_engine scheduleClosures:mList];
//}

-(ORStatus) updateMin: (ORULong) newMin
//>>>>>>> master
{
    return [_dom updateMin:newMin for:self];
}

-(ORStatus) updateMax: (ORULong) newMax
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


//versions of setUp and setLow for learning nogoods

-(void) setLow:(unsigned int *)newLow for:(CPCoreConstraint*) constraint
{
   TRUInt* oldLow = [_dom getLow];
   ORUInt changedLow;
   
   for (int i=0; i<[_dom getWordLength]; i++) {
      changedLow = oldLow[i]._val ^ newLow[i];
      for(int j=0;j<BITSPERWORD; j++){
         if (changedLow & 0x1) {
//            if([_engine isKindOfClass:[CPLearningEngineI class]])
              // assignTRUInt(&_levels[i*BITSPERWORD+j],[(CPLearningEngineI*)_engine getLevel], _trail);
//               _levels[i*BITSPERWORD+j] = [(CPLearningEngineI*)_engine getLevel];
//            _implications[i*BITSPERWORD+j] = constraint;
               assignTRId(&_implications[i*BITSPERWORD+j], constraint, _trail);

         }
         changedLow >>= 1;
      }
   }
   [_dom setLow: newLow for:self];

}

-(void) setUp:(unsigned int *)newUp for:(CPCoreConstraint*) constraint
{
   TRUInt* oldUp = [_dom getUp];
   ORUInt changedUp;
   
   for (int i=0; i<[_dom getWordLength]; i++) {
      changedUp = oldUp[i]._val ^ newUp[i];
      for(int j=0;j<BITSPERWORD; j++){
         if (changedUp & 0x1) {
//            if([_engine isKindOfClass:[CPLearningEngineI class]])
               //assignTRUInt(&_levels[i*BITSPERWORD+j],[(CPLearningEngineI*)_engine getLevel], _trail);
            //_implications[i*BITSPERWORD+j] = constraint;
               assignTRId(&_implications[i*BITSPERWORD+j], constraint, _trail);
         }
         changedUp >>= 1;
      }
   }
   [_dom setUp: newUp for:self];
}

-(void) setUp:(unsigned int *)newUp andLow:(unsigned int *)newLow for:(CPCoreConstraint*) constraint
{
   TRUInt* oldUp = [_dom getUp];
   TRUInt* oldLow = [_dom getLow];
   ORUInt changedUp;
   ORUInt changedLow;
   ORUInt mask;
   ORUInt bitLength = [self bitLength];
   ORUInt wordLength = [self getWordLength];
   
   mask = CP_UMASK >> (BITSPERWORD-(bitLength%BITSPERWORD));
   
   newUp[wordLength-1] &= mask;
   newLow[wordLength-1] &= mask;
   
   for (int i=0; i<wordLength; i++) {
      changedUp = oldUp[i]._val ^ newUp[i];
      changedLow = oldLow[i]._val ^ newLow[i];
      mask = 0x1;
      for(int j=0;j<BITSPERWORD; j++){
         if ((i*BITSPERWORD)+j >=bitLength) {
            break;
         }
         if ((changedUp & mask) || (changedLow & mask)) {
//            NSLog(@"Update of bit %u by %@", j, constraint);
            if([_engine conformsToProtocol:@protocol(CPLEngine)]){
               //assignTRUInt(&_levels[i*BITSPERWORD+j],[(CPLearningEngineI*)_engine getLevel], _trail);
               //_implications[i*BITSPERWORD+j] = constraint;
               assignTRId(&_implications[i*BITSPERWORD+j], constraint, _trail);
//               NSLog(@"Updating %@[%d] for %@ \@ %ld",self, i*BITSPERWORD+j,constraint,[_engine getLevel]);
            }
            
         }
         mask <<= 1;
      }
   }
//   NSLog(@"done.");
   [_dom setUp: newUp andLow:newLow for:self];
//   if(changedUp | changedLow)
//      NSLog(@"%lx=%@ updated by %@",self,self,constraint);
   
}
//end of setup and setlow for nogoods



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

-(ORStatus) bindUInt64:(ORULong)val
{
    return [_dom bind:val for:self];
}

-(ORStatus)bind:(ORUInt*)val{
    return [_dom bindToPat: val for:self];
}
-(ORStatus) remove:(ORUInt*) val
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
   _trail = [engine trail];
    setUpNetwork(&_net, _trail, *low, *up,len);
    _triggers = nil;
   _dom = [[CPBitArrayDom alloc] initWithBitPat:len withLow:low andUp:up andEngine:_engine andTrail:_trail];
    [_dom setEngine:engine];
   _levels = malloc(sizeof(TRUInt)*len);
   _implications = malloc(sizeof(TRId)*len);
   for (int i=0; i<len; i++) {
      _levels[i] = makeTRUInt(_trail, 0);
      _implications[i] = makeTRId(_trail, 0);
   }
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

@implementation CPBitVarMultiCast {
   id<CPBitVarNotifier>*     _tab;
   BOOL            _tracksLoseEvt;
   ORUInt              _bitLength;
   ORInt                      _nb;
   ORInt                      _mx;
   UBType*            _loseValIMP;
   UBType*                _minIMP;
   UBType*                _maxIMP;
   UBType*           _bitFixedIMP;
   UBType*        _bitFixedAtIIMP;
   UBType**        _bitFixedAtIMP;
   CPBitVarLiterals*    _literals;
}
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
-(ORUInt)getId
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
-(ORStatus)bindEvt:(ORUInt)dsz  sender:(CPBitArrayDom*)sender
{
   // If _nb > 0 but the _tab entries are nil, this would inadvertently
   // set ok to ORFailure which is wrong. Hence it is critical to also
   // backtrack the size of the array in addVar.
   for(ORInt i=0;i<_nb;i++) {
      ORStatus ok = [_tab[i] bindEvt:dsz sender:sender];
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
//<<<<<<< HEAD

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
//=======
//>>>>>>> master
@end


