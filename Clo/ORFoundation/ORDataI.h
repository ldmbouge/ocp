/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORData.h"
#import "ORExprI.h"

@interface ORObjectI : NSObject<ORObject>
@end;

@interface ORIntegerI : ORExprI<NSCoding,ORInteger>
-(ORIntegerI*) initORIntegerI:(id<ORTracker>)tracker value:(ORInt) value;
-(ORInt)  value;
-(void) setValue: (ORInt) value;
-(void) incr;
-(void) decr;
-(ORInt)   min;
-(id<ORTracker>) tracker;
@end



@interface ORRandomStreamI : NSObject<ORRandomStream>
-(ORRandomStreamI*) init;
-(void) dealloc;
-(ORLong) next;
@end;

@interface ORZeroOneStreamI : NSObject<ORZeroOneStream>
-(ORZeroOneStreamI*) init;
-(void) dealloc;
-(double) next;
@end;

@interface ORUniformDistributionI : NSObject<ORUniformDistribution>
-(ORUniformDistributionI*) initORUniformDistribution: (id<ORIntRange>) r;
-(void) dealloc;
-(ORInt) next;
@end;



