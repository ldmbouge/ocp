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

typedef struct  {
   TRId         _boundsEvt;
   TRId       _bitFixedEvt;
   TRId            _minEvt;
   TRId            _maxEvt;
} CPBitEventNetwork;


@interface CPBitVarI : ORObject<CPBitVar, CPBitVarNotifier,CPBitVarSubscriber, NSCoding> {
@private
@protected
    CPEngineI*                       _engine;
    CPBitArrayDom*                      _dom;
    CPBitEventNetwork                   _net;
    CPTriggerMap*                  _triggers;
    id<CPBitVarNotifier>               _recv;
}
-(void) initCPBitVarCore:(id<CPEngine>)cp low:(unsigned int*)low up:(unsigned int*)up length:(int) len;
-(void) dealloc;
-(NSString*) description;
-(id<CPBitVar>) dereference;
-(id<CPEngine>) engine;
-(void)restoreDomain:(id<CPDom>)toRestore;
-(void)restoreValue:(ORInt)toRestore;

// AC3 Constraint Event
-(void) whenChangePropagate:  (CPCoreConstraint*) c;

// need for speeding the code when not using AC5
-(bool) tracksLoseEvt;
-(void) setTracksLoseEvt;

// subscription
-(void) whenBitFixed:(CPCoreConstraint*)c at:(int) p do:(ConstraintCallback) todo;
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 

// notification

//-(void) bindEvt;
-(void) changeMinEvt:(int)dsz sender:(CPBitArrayDom*)sender;
-(void) changeMaxEvt:(int)dsz sender:(CPBitArrayDom*)sender;
-(void) bitFixedEvt:(int)dsz  sender:(CPBitArrayDom*)sender;
// access
-(BOOL) bound;
-(uint64) min;
-(uint64) max;
-(CPBitArrayDom*) domain;
-(unsigned int*) minArray;
-(unsigned int*) maxArray;
-(unsigned int) getWordLength;
-(ORBounds) bounds;
-(ORULong) domsize;
-(unsigned int) lsFreeBit;
-(BOOL) member:(unsigned int*)v;
// update
-(ORStatus)     updateMin: (uint64) newMin;
-(ORStatus)     updateMax: (uint64) newMax;
-(void)         setLow: (unsigned int*) newLow;
-(void)         setUp: (unsigned int*) newUp;
-(void)         setUp:(unsigned int*) newUp andLow:(unsigned int*)newLow;
-(TRUInt*)    getLow;
-(TRUInt*)    getUp;
-(void)        getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow;
-(ORStatus)     bind:(unsigned int*) val;
-(ORStatus)     bindUInt64:(uint64) val;
//-(ORStatus)     remove:(int) val;
-(CPBitVarI*)    initCPExplicitBitVar: (id<CPEngine>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
-(CPBitVarI*)    initCPExplicitBitVarPat: (id<CPEngine>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
// Class methods
+(CPBitVarI*)   initCPBitVar: (id<CPEngine>)cp low:(int)low up:(int)up len:(unsigned int)len;
+(CPBitVarI*)   initCPBitVarWithPat:(id<CPEngine>)cp withLow:(unsigned int *)low andUp:(unsigned int *)up andLen:(unsigned int)len;
@end


/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@interface CPBitVarMultiCast : NSObject<CPBitVarNotifier,NSCoding> {
    CPBitVarI**       _tab;
    BOOL    _tracksLoseEvt;
    ORInt          _nb;
    ORInt          _mx;
}
-(id)initVarMC:(int)n;
-(void) dealloc;
-(void) addVar:(CPBitVarI*) v;
-(void) bindEvt;
-(void) bitFixedEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender;
@end

