/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORData.h>
#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORDataI.h>

@implementation ORCrFactory (OR)
+(id<ORMutableInteger>) integer:(ORInt) value
{
   return [[ORMutableIntegerI alloc] initORMutableIntegerI:nil value:value];
}
+(id<ORMutableFloat>) float:(ORFloat) value
{
   return [[ORMutableFloatI alloc] initORMutableFloatI:nil value:value];
}
+(id<ORMutableRational>) rational:(id<ORRational>) value
{
   return [[ORMutableRationalI alloc] initORMutableRationalI:nil value:value];
}
+(id<ORDoubleNumber>) double: (ORDouble) value
{
   return [[ORDoubleI alloc] init:nil value:value];
}
@end
