//
//  CPBitVar.h
//  Clo
//
//  Created by Laurent Michel on 4/30/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "objcp/CPTrail.h"
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
