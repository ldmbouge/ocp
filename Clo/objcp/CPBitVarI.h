/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPEngine.h>
#import <CPUKernel/CPTrigger.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPDom.h>

@class CPBitArrayDom;
@class CPBitArrayIterator;
@class CPEngineI;
@class CPTriggerMap;
@class CPBitVarMultiCast;

typedef struct  {
   TRId         _boundsEvt;
   TRId           _bindEvt;
   TRId            _domEvt;
   TRId            _minEvt;
   TRId            _maxEvt;
   TRId               _ac5;
   TRId       _bitFixedEvt;
} CPBitEventNetwork;


@interface CPBitVarI : ORObject<CPBitVar, CPBitVarNotifier,CPBitVarSubscriber, NSCoding> {
@private
@protected
    CPEngineI*                       _engine;
    CPBitArrayDom*                      _dom;
    CPBitEventNetwork                   _net;
    CPTriggerMap*                  _triggers;
    CPBitVarMultiCast*               _recv;
}
-(CPBitVarI*) initCPBitVarCore:(id<CPEngine>)cp low:(unsigned int*)low up:(unsigned int*)up length:(int) len;
-(void) dealloc;
-(enum CPVarClass)varClass;
-(NSString*) description;
-(id<CPEngine>) engine;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(ORInt)toRestore;

// AC3 Constraint Event
-(void) whenChangePropagate:  (CPCoreConstraint*) c;

// need for speeding the code when not using AC5
-(ORBool) tracksLoseEvt;
-(void) setTracksLoseEvt;

// subscription
-(void) whenBitFixed:(CPCoreConstraint*)c at:(int) p do:(ConstraintCallback) todo;
-(void) whenChangeDo:(CPCoreConstraint*) c;
-(void) whenChangeDo: (ConstraintCallback) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c;
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo;
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 

// notification

//-(void) bindEvt;
-(ORStatus) changeMinEvt:(int)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) changeMaxEvt:(int)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedEvt:(int)dsz  sender:(CPBitArrayDom*)sender;
-(ORStatus) bindEvt:(int)dsz  sender:(CPBitArrayDom*)sender;
// access
-(ORInt) bitLength;
-(ORBool) bound;
-(uint64) min;
-(uint64) max;
-(ORUInt) maxRank;
-(CPBitArrayDom*) domain;
-(unsigned int*) minArray;
-(unsigned int*) maxArray;
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

// update
-(ORStatus)     updateMin: (uint64) newMin;
-(ORStatus)     updateMax: (uint64) newMax;
-(void)         setLow: (unsigned int*) newLow;
-(void)         setUp: (unsigned int*) newUp;
-(void)         setUp:(unsigned int*) newUp andLow:(unsigned int*)newLow;
-(TRUInt*)    getLow;
-(TRUInt*)    getUp;
-(void)        getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow;
-(ORStatus)     bind:(ORUInt*) val;
-(ORStatus)     bind:(ORUInt)bit to:(BOOL)value;
-(ORStatus)     bindUInt64:(uint64) val;
-(ORStatus)     remove:(ORUInt) val;
-(CPBitVarI*)    initCPExplicitBitVar: (id<CPEngine>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
-(CPBitVarI*)    initCPExplicitBitVarPat: (id<CPEngine>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
// Class methods
+(CPBitVarI*)   initCPBitVar: (id<CPEngine>)cp low:(int)low up:(int)up len:(unsigned int)len;
+(CPBitVarI*)   initCPBitVarWithPat:(id<CPEngine>)cp withLow:(unsigned int *)low andUp:(unsigned int *)up andLen:(unsigned int)len;
@end


/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

//@interface CPBitVarMultiCast : NSObject<CPBitVarNotifier,NSCoding> {
//    CPBitVarI**       _tab;
//    BOOL    _tracksLoseEvt;
//    ORInt          _nb;
//    ORInt          _mx;
//}
//-(id)initVarMC:(int)n;
//-(void) dealloc;
//-(void) addVar:(CPBitVarI*) v;
//-(NSMutableSet*)constraints;
//-(void) bindEvt;
//-(void) bitFixedEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender;
//@end
@interface CPBitVarMultiCast : NSObject<CPBitVarNotifier,NSCoding> {
//   id<CPIntVarNotifier>* _tab;
//   BOOL        _tracksLoseEvt;
//   ORInt                  _nb;
//   ORInt                  _mx;
//   UBType*        _loseValIMP;
//   UBType*            _minIMP;
//   UBType*            _maxIMP;
//}
//-(id)initVarMC:(ORInt)n root:(CPBitVarI*)root;
//-(void) dealloc;
//-(enum CPVarClass)varClass;
////-(CPLiterals*)literals;
//-(void) addVar:(CPBitVarI*) v;
//-(NSMutableSet*)constraints;
//-(ORStatus) bindEvt:(id<CPDom>)sender;
//-(ORStatus) changeMinEvt:(ORInt)dsz sender:(id<CPDom>)sender;
//-(ORStatus) changeMaxEvt:(ORInt)dsz sender:(id<CPDom>)sender;
//-(ORStatus) loseValEvt:(ORInt)val sender:(id<CPDom>)sender;
   id<CPBitVarNotifier>* _tab;
   BOOL        _tracksLoseEvt;
   ORInt                  _nb;
   ORInt                  _mx;
   UBType*        _loseValIMP;
   UBType*            _minIMP;
   UBType*            _maxIMP;
   UBType*       _bitFixedIMP;
}
-(id)initVarMC:(ORInt)n root:(CPBitVarI*)root;
-(void) dealloc;
-(enum CPVarClass)varClass;
//-(CPLiterals*)literals;
-(void) addVar:(CPBitVarI*) v;
-(NSMutableSet*)constraints;
-(ORStatus) bindEvt:(CPBitArrayDom*)sender;
-(ORStatus) changeMinEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) changeMaxEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) loseValEvt:(ORUInt)val sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender;
@end


