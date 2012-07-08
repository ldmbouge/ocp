/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORCrFactory.h"
#import "ORData.h"
#import "ORConcurrency.h"
#import "ORFoundation/ORAVLTree.h"
#import "ORFoundation/ORDataI.h"

@implementation ORCrFactory
+(id<ORInteger>) integer:(ORInt) value
{
   return [[ORIntegerI alloc] initORIntegerI:nil value:value];    
}
+(id<ORIntInformer>) intInformer 
{
    return [ORConcurrency intInformer];
}
+(id<ORVoidInformer>) voidInformer 
{
   return [ORConcurrency voidInformer];
}
+(id<ORRandomStream>) randomStream
{
   return [[ORRandomStreamI alloc] init];
}
+(id<ORZeroOneStream>) zeroOneStream
{
   return [[ORZeroOneStreamI alloc] init];
}
+(id<ORUniformDistribution>) uniformDistribution: (ORRange) r
{
   return [[ORUniformDistributionI alloc] initORUniformDistribution: r];
}
@end
