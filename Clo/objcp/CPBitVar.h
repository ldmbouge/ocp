/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPEngine.h>

@protocol CPBitVar <NSObject>
-(bool) bound;
-(uint64)min;
-(uint64)max;
-(unsigned int)  domsize;
-(bool) member: (unsigned int*) v;
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
-(void) bindEvt:(id)sender;
-(void) bitFixedEvt:(unsigned int) dsz sender:(id)sender;
-(void) changeMinEvt:(unsigned int) dsz sender:(id)sender;
-(void) changeMaxEvt:(unsigned int) dsz sender:(id)sender;
@end
