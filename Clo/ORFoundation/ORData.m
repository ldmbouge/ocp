/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFoundation/ORData.h"
#import "ORDataI.h"
#import "ORUtilities/ORUtilities.h"

@implementation ORCrFactory (OR)
+(id<ORInteger>) integer:(ORInt) value
{
   return [[ORIntegerI alloc] initORIntegerI:nil value:value];
}
+(id<ORFloatNumber>) float: (ORFloat) value
{
   return [[ORFloatI alloc] initORFloatI:nil value:value];
}
+(id<ORRandomStream>) randomStream
{
   return [[ORRandomStreamI alloc] init];
}
+(id<ORZeroOneStream>) zeroOneStream
{
   return [[ORZeroOneStreamI alloc] init];
}
+(id<ORUniformDistribution>) uniformDistribution: (id<ORIntRange>) r
{
   return [[ORUniformDistributionI alloc] initORUniformDistribution: r];
}
@end
