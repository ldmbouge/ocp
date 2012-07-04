/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPCrFactory.h"
#import "CPData.h"
#import "CPCreateI.h"
#import "CPConcurrency.h"
#import "ORFoundation/ORAVLTree.h"
#import "ORFoundation/ORDataI.h"

@implementation CPCrFactory
+(id<CPInteger>) integer:(CPInt) value
{
   return (id<CPInteger>)[[ORIntegerI alloc] initORIntegerI:nil value:value];    
}
+(id<CPIntInformer>) intInformer 
{
    return [CPConcurrency intInformer];
}
+(id<CPVoidInformer>) voidInformer 
{
   return [CPConcurrency voidInformer];
}
@end
