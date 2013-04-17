/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPVar.h>

@protocol CPBitVar <CPVar>
-(BOOL) bound;
-(ORInt) bitLength;
-(ORStatus) bind:(ORUInt)bit to:(BOOL)value;
-(ORStatus) bind:(ORUInt*)pat;
-(CPBitArrayDom*) domain;
-(uint64)min;
-(uint64)max;
-(ORBounds) bounds;
-(ORInt)  domsize;
-(ORULong)  numPatterns;
-(BOOL) member: (unsigned int*) v;
-(bool) isFree:(ORUInt)pos;
-(ORStatus) remove:(ORUInt)val;
-(id<CPBitVar>) dereference;
-(id<CPEngine>) engine;
@end

@class CPCoreConstraint;

@protocol CPBitVarSubscriber <NSObject>
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
@end

@class CPBitVarI;

@protocol CPBitVarNotifier <NSObject>
@optional -(void) addVar:(CPBitVarI*)var;
-(void) bindEvt;
-(void) bitFixedEvt:(unsigned int) dsz  sender:(CPBitArrayDom*)sender;
-(void) changeMinEvt:(unsigned int) dsz sender:(CPBitArrayDom*)sender;
-(void) changeMaxEvt:(unsigned int) dsz sender:(CPBitArrayDom*)sender;
@end
