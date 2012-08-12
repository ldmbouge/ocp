/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTrail.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPTypes.h>
#import <objcp/CPEngine.h>
#import <objcp/CPTrigger.h>

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


@interface CPBitVarI : NSObject<CPBitVar, CPBitVarNotifier,CPBitVarSubscriber, NSCoding> {
@private
@protected
    ORUInt                         _name;
    CPEngineI*                          _fdm;
    CPBitArrayDom*                      _dom;
    CPBitEventNetwork                   _net;
    CPTriggerMap*                  _triggers;
    id<CPBitVarNotifier>               _recv;
}
-(void) initCPBitVarCore:(id<CPEngine>)fdm low:(unsigned int*)low up:(unsigned int*)up length:(int) len;
//-(CPBitVarI*) initCPBitVarView: (id<CPEngine>) fdm low: (int) low up: (int) up for: (CPBitVarI*) x;
-(void) dealloc;
-(void) setId:(ORUInt)name;
-(NSString*) description;
-(id<CPEngine>) engine;

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
-(void) changeMinEvt:(int)dsz;
-(void) changeMaxEvt:(int)dsz;
-(void) bitFixedEvt:(int)dsz;
// access
-(bool) bound;
-(uint64) min;
-(uint64) max;
-(unsigned int*) minArray;
-(unsigned int*) maxArray;
-(unsigned int) getWordLength;
-(void) bounds:(ORBounds*)bnd;
-(unsigned int) domsize;
-(bool) member:(unsigned int*)v;
// update
-(ORStatus)     updateMin: (uint64) newMin;
-(ORStatus)     updateMax: (uint64) newMax;
-(void)         setLow: (unsigned int*) newLow;
-(void)         setUp: (unsigned int*) newUp;
-(TRUInt*)    getLow;
-(TRUInt*)    getUp;
-(ORStatus)     bind:(unsigned int*) val;
-(ORStatus)     bindUInt64:(uint64) val;
//-(ORStatus)     remove:(int) val;
-(CPBitVarI*)    initCPExplicitBitVar: (id<CPEngine>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
-(CPBitVarI*)    initCPExplicitBitVarPat: (id<CPEngine>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
// Class methods
+(CPBitVarI*)   initCPBitVar: (id<CPEngine>)fdm low:(int)low up:(int)up len:(unsigned int)len;
+(CPBitVarI*)   initCPBitVarWithPat:(id<CPEngine>)fdm withLow:(unsigned int *)low andUp:(unsigned int *)up andLen:(unsigned int)len;
+(CPTrigger*)   createTrigger: (ConstraintCallback) todo;
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
-(void) bitFixedEvt:(ORUInt) dsz;
@end

