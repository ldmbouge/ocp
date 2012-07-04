/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORTrail.h"
#import "objcp/CPSolver.h"

@protocol CPBitVar <NSObject>
-(bool) bound;
-(uint64)min;
-(uint64)max;
-(unsigned int)  domsize;
-(bool) member: (unsigned int*) v;
-(id<CPSolver>) solver;
@end


@protocol CPBitVarSubscriber <NSObject>
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
@end

@class CPBitVarI;

@protocol CPBitVarNotifier <NSObject>
@optional -(void) addVar:(CPBitVarI*)var;
-(void) bindEvt;
-(void) bitFixedEvt:(unsigned int) dsz;
-(void) changeMinEvt:(unsigned int) dsz;
-(void) changeMaxEvt:(unsigned int) dsz;
@end
