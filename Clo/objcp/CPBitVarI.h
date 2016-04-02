/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPEngine.h>
#import <CPUKernel/CPTrigger.h>
#import <objcp/CPVar.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPDom.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPBitMacros.h>

@class CPBitArrayDom;
@class CPBitArrayIterator;
@class CPEngineI;
@class CPLearningEngineI;
@class CPTriggerMap;
@class CPBitVarMultiCast;
@class CPBitVarLiterals;

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

//<<<<<<< HEAD
@interface CPBitVarI : ORObject<CPBitVar, CPBitVarNotifier,CPBitVarSubscriber, NSCoding> {
//=======
//
//@interface CPBitVarI : ORObject<CPBitVar, CPBitVarNotifier,CPBitVarSubscriber> {
//>>>>>>> master
@private
@protected
    CPEngineI*                       _engine;
    id<ORTrail>                       _trail;
    CPBitArrayDom*                      _dom;
    CPBitEventNetwork                   _net;
    CPTriggerMap*                  _triggers;
    CPBitVarMultiCast*                 _recv;
    enum CPVarClass                      _vc;
   
    TRUInt*                          _levels;
    TRId*                       _implications;
}
-(CPBitVarI*) initCPBitVarCore:(id<CPEngine>)cp low:(unsigned int*)low up:(unsigned int*)up length:(int) len;
-(void) dealloc;
-(enum CPVarClass)varClass;
-(NSString*) description;
-(id<CPEngine>) engine;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(ORInt)toRestore;

// Constraint Event
-(void) whenChangePropagate:  (CPCoreConstraint*) c;

// needed for speeding the code when not using value notifications
-(ORBool) tracksLoseEvt;
-(void) setTracksLoseEvt;

// subscription
//<<<<<<< HEAD
-(void) whenBitFixed:(CPCoreConstraint*)c at:(ORUInt) idx do:(ORClosure) todo;
-(void) whenBitFixedAtI:(CPCoreConstraint*)c at:(ORUInt)p do:(ORClosure) todo;
-(void) whenBitFixedAt:(ORUInt)i propagate:(CPCoreConstraint*) c;
//-(void) whenBitFixed:(CPCoreConstraint*)c at:(ORUInt)p do:(ConstraintIntCallBack)todo;

-(void) whenChangeDo:(CPCoreConstraint*) c;
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c;
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
//=======
//-(void) whenBitFixed:(CPCoreConstraint*)c at:(int) p do:(ORClosure) todo;
//-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
//-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
//-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
//>>>>>>> master

// notification

//-(void) bindEvt;
-(ORStatus) changeMinEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) changeMaxEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedEvt:(ORUInt)dsz  sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedAtEvt:(ORUInt)dsz at:(ORUInt)idx sender:(CPBitArrayDom*)sender;
//-(ORStatus) bitFixedAtEvt:(ORUInt)dsz  sender:(CPBitArrayDom*)sender;
-(ORStatus) bindEvt:(ORUInt)dsz  sender:(CPBitArrayDom*)sender;
// access
-(ORInt) bitLength;
-(ORBool) bound;
//<<<<<<< HEAD
-(ORULong) min;
-(ORULong) max;
-(ORUInt) maxRank;

-(CPBitArrayDom*) domain;
-(unsigned int*) minArray;
-(unsigned int*) maxArray;
-(unsigned int*) sminArray;
-(unsigned int*) smaxArray;
-(unsigned int) getWordLength;
-(ORBounds) bounds;
-(ORInt) domsize;
-(ORULong)  numPatterns;
-(ORUInt) lsFreeBit;
-(ORUInt) msFreeBit;
-(ORUInt) randomFreeBit;
-(ORUInt) midFreeBit;
-(ORBool) isFree:(ORUInt)pos;
-(ORBool) member:(unsigned int*)v;
-(ORBool) getBit:(ORUInt) index;
-(ORUInt) getLevelBitWasSet:(ORUInt)bit;
-(void) bit:(ORUInt)i setAtLevel:(ORUInt)l;
-(CPCoreConstraint*) getImplicationForBit:(ORUInt)i;

// update
-(ORStatus)     updateMin: (ORULong) newMin;
-(ORStatus)     updateMax: (ORULong) newMax;
-(void)         setLow: (unsigned int*) newLow;
-(void)         setUp: (unsigned int*) newUp;
-(void)         setUp:(unsigned int*) newUp andLow:(unsigned int*)newLow for:(CPCoreConstraint*)constraint;
-(void)         setLow: (unsigned int*) newLow for:(CPCoreConstraint*)constraint;
-(void)         setUp: (unsigned int*) newUp for:(CPCoreConstraint*)constraint;
-(void)         setUp:(unsigned int*) newUp andLow:(unsigned int*)newLow;
-(TRUInt*)    getLow;
-(TRUInt*)    getUp;
-(void)        getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow;
-(ORStatus)     bind:(ORUInt*) val;
-(ORStatus)     bind:(ORUInt)bit to:(ORBool)value;
-(ORStatus)     bindUInt64:(ORULong) val;
-(ORStatus)     remove:(ORUInt) val;

-(CPBitVarI*)    initCPExplicitBitVar: (id<CPEngine>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
-(CPBitVarI*)    initCPExplicitBitVarPat: (id<CPEngine>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
// Class methods
+(CPBitVarI*)   initCPBitVar: (id<CPEngine>)cp low:(int)low up:(int)up len:(unsigned int)len;
+(CPBitVarI*)   initCPBitVarWithPat:(id<CPEngine>)cp withLow:(unsigned int *)low andUp:(unsigned int *)up andLen:(unsigned int)len;


@end

@interface CPBitVarConstantView : CPBitVarI

@end

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/
@interface CPBitVarMultiCast : NSObject<CPBitVarNotifier,NSCoding> {
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
-(id)initVarMC:(ORInt)n root:(CPBitVarI*)root;
-(void) dealloc;
//-(CPBitVarLiterals*)findLiterals:(CPBitVarI*)ref;
-(void) addVar:(CPBitVarI*) v;
-(NSMutableSet*)constraints;
-(ORStatus) bindEvt:(CPBitArrayDom*)sender;
-(ORStatus) changeMinEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) changeMaxEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) loseValEvt:(ORUInt)val sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender;
//-(ORStatus) bitFixedAtEvt:(ORUInt) i sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedAtEvt:(ORUInt)dsz at:(ORUInt) i sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedAtIEvt:(ORUInt)i sender:(CPBitArrayDom *)sender;
@end



