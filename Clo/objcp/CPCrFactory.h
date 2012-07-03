/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPTypes.h>
#import "CPSolver.h"
#import "CP.h"

@protocol CPInteger;
@protocol CPInformer;
@protocol CPIntInformer;
@protocol CPVoidInformer;
@class CPAVLTree;

@interface CPCrFactory : NSObject
+(id<CPInteger>) integer: (CPInt) value;
+(id<CPIntInformer>) intInformer;
+(id<CPVoidInformer>) voidInformer;
@end
