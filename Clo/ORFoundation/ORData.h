/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORUtilities/ORCrFactory.h"

@protocol ORExpr;
@protocol ORIntRange;

@protocol ORInteger <NSObject,ORExpr>
-(ORInt)  value;
-(void) setValue: (ORInt) value;
-(void) incr;
-(void) decr;
@end


@protocol ORTrailIableInt <NSObject>
-(ORInt) value;
-(void)  setValue: (ORInt) value;
-(void)  incr;
-(void)  decr;
@end


@interface ORRuntimeMonitor : NSObject
+(ORLong) cputime;
+(ORLong) microseconds;
@end;

@interface ORStreamManager : NSObject
+(void) initialize;
+(void) setDeterministic;
+(void) setRandomized;
+(ORInt) deterministic;
+(void) initSeed: (unsigned short*) seed;
@end

@protocol ORRandomStream <NSObject>
-(ORLong) next;
@end;

@protocol ORZeroOneStream <NSObject>
-(double) next;
@end;

@protocol ORUniformDistribution <NSObject>
-(ORInt) next;
@end;

@interface ORCrFactory (OR)
+(id<ORInteger>) integer:(ORInt) value;
+(id<ORRandomStream>) randomStream;
+(id<ORZeroOneStream>) zeroOneStream;
+(id<ORUniformDistribution>) uniformDistribution: (id<ORIntRange>) r;
@end
