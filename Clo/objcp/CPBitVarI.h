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
    CPTriggerMap*                  _triggers;
    CPBitVarMultiCast*                 _recv;
    enum CPVarClass                      _vc;
    TRUInt*                          _levels;
}
-(CPBitVarI*) initCPBitVarCore:(id<CPEngine>)cp low:(ORUInt*)low up:(ORUInt*)up length:(int) len;
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
-(void) whenBitFixed:(CPCoreConstraint*)c at:(ORUInt) idx do:(ORClosure) todo;
-(void) whenBitFixedAtI:(CPCoreConstraint*)c at:(ORUInt)p do:(ORClosure) todo;
-(void) whenBitFixedAt:(ORUInt)i propagate:(CPCoreConstraint*) c;
//-(void) whenBitFixed:(CPCoreConstraint*)c at:(ORUInt)p do:(ConstraintIntCallBack)todo;

//-(void) whenChangeDo:(CPCoreConstraint*) c;
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
-(ORULong) min;
-(ORULong) max;
-(ORUInt) maxRank;

-(CPBitArrayDom*) domain;
-(ORUInt*) minArray;
-(ORUInt*) maxArray;
-(ORUInt*) sminArray;
-(ORUInt*) smaxArray;
-(ORUInt) getWordLength;
-(ORBounds) bounds;
-(ORInt) domsize;
-(ORULong)  numPatterns;
-(ORUInt) lsFreeBit;
-(ORUInt) msFreeBit;
-(ORUInt) randomFreeBit;
-(ORUInt) midFreeBit;
-(ORBool) isFree:(ORUInt)pos;
-(ORBool) member:(ORUInt*)v;
-(ORBool) getBit:(ORUInt) index;
-(ORUInt) getLevelBitWasSet:(ORUInt)bit;
-(void) bit:(ORUInt)i setAtLevel:(ORUInt)l;
-(id<CPBVConstraint>) getImplicationForBit:(ORUInt)i;

// update
-(ORStatus)     updateMin: (ORULong) newMin;
-(ORStatus)     updateMax: (ORULong) newMax;
-(void)         setLow: (ORUInt*) newLow;
-(void)         setUp: (ORUInt*) newUp;
-(void)         setUp:(ORUInt*) newUp andLow:(ORUInt*)newLow for:(CPCoreConstraint*)constraint;
-(void)         setLow: (ORUInt*) newLow for:(CPCoreConstraint*)constraint;
-(void)         setUp: (ORUInt*) newUp for:(CPCoreConstraint*)constraint;
-(void)         setUp:(ORUInt*) newUp andLow:(ORUInt*)newLow;
-(TRUInt*)    getLow;
-(TRUInt*)    getUp;
-(void)        getUp:(TRUInt**)currUp andLow:(TRUInt**)currLow;
-(ORStatus)     bind:(ORUInt*) val;
-(ORStatus)     bind:(ORUInt)bit to:(ORBool)value;
-(ORStatus)     bindUInt64:(ORULong) val;
-(ORStatus)     remove:(ORUInt*) val;

-(CPBitVarI*)    initCPExplicitBitVar: (id<CPEngine>)fdm withLow: (ORUInt*) low andUp: (ORUInt*) up andLen:(ORUInt) len;
-(CPBitVarI*)    initCPExplicitBitVarPat: (id<CPEngine>)fdm withLow: (ORUInt*) low andUp: (ORUInt*) up andLen:(ORUInt) len;
// Class methods
+(CPBitVarI*)   initCPBitVar: (id<CPEngine>)cp low:(int)low up:(int)up len:(ORUInt)len;
+(CPBitVarI*)   initCPBitVarWithPat:(id<CPEngine>)cp withLow:(ORUInt *)low andUp:(ORUInt *)up andLen:(ORUInt)len;


@end

@interface CPBitVarConstantView : CPBitVarI

@end

/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/
@interface CPBitVarMultiCast : NSObject<CPBitVarNotifier,NSCoding> 
-(id)initVarMC:(ORInt)n root:(CPBitVarI*)root;
-(void) dealloc;
//-(CPBitVarLiterals*)findLiterals:(CPBitVarI*)ref;
-(void) addVar:(CPBitVarI*) v;
-(NSMutableSet*)constraints;
-(ORStatus) bindEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) changeMinEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) changeMaxEvt:(ORUInt)dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) loseValEvt:(ORUInt)val sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender;
//-(ORStatus) bitFixedAtEvt:(ORUInt) i sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedAtEvt:(ORUInt)dsz at:(ORUInt) i sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedAtIEvt:(ORUInt)dsz at:(ORUInt)i sender:(CPBitArrayDom *)sender;
@end



