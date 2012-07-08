/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORTypes.h>
#import <ORFoundation/ORData.h>

@protocol ORInteger;
@protocol ORInformer;
@protocol ORIntInformer;
@protocol ORVoidInformer;
@class CPAVLTree;

@interface ORCrFactory : NSObject
+(id<ORInteger>) integer:(ORInt) value;
+(id<ORIntInformer>) intInformer;
+(id<ORVoidInformer>) voidInformer;

+(id<ORRandomStream>) randomStream;
+(id<ORZeroOneStream>) zeroOneStream;
+(id<ORUniformDistribution>) uniformDistribution: (ORRange) r;
@end
