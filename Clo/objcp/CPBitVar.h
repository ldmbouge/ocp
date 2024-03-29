/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPVar.h>
#import <objcp/CPDom.h>


@protocol CPBitVar <CPVar>
-(ORInt) bitLength;
-(ORStatus) bind:(ORUInt)bit to:(BOOL)value;
-(ORStatus) bind:(ORUInt*)pat;
-(ORUInt) getId;
-(ORBool) bound;
-(CPBitArrayDom*) domain;
-(ORULong)min;
-(ORULong)max;
-(ORInt)  domsize;
-(ORULong)  numPatterns;
-(ORUInt) msFreeBit;
-(ORUInt) lsFreeBit;
-(ORUInt) midFreeBit;
-(ORUInt) randomFreeBit;
-(ORBool) isFree:(ORUInt)pos;
-(ORBool) bitAt:(ORUInt)pos;
-(ORStatus) remove:(ORUInt)val;
//-(id<CPBitVar>) dereference;
-(ORBool) member: (unsigned int*) v;
-(id<CPBitVar>) dereference;
-(id<CPEngine>) engine;

-(ORFloat) getVSIDSCount;
-(void) incrementActivity:(ORUInt)i;
-(void) reduceVSIDS;
-(ORFloat) getVSIDSActivity:(ORUInt)i;
@end

@class CPCoreConstraint;

@protocol CPBitVarSubscriber <NSObject>
-(void) whenBitFixed:(CPCoreConstraint*)c at:(ORUInt) idx do:(ORClosure) todo;
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
-(void) whenChangeDo: (ORClosure) todo priority: (ORInt) p onBehalf: (CPCoreConstraint*)c;
-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ORClosure) todo;
@end

@class CPBitVarI;

@protocol CPBitVarNotifier <NSObject>
@optional -(void) addVar:(CPBitVarI*)var;
-(ORUInt)getId;
-(enum CPVarClass)varClass;
-(NSMutableSet*)constraints;
-(ORBool) tracksLoseEvt:(CPBitArrayDom*)sender;
-(ORStatus) bindEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) bitFixedEvt:(ORUInt) dsz  sender:(CPBitArrayDom*)sender;
-(ORStatus) changeMinEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender;
-(ORStatus) changeMaxEvt:(ORUInt) dsz sender:(CPBitArrayDom*)sender;
@end
