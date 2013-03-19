/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import "ORRunnable.h"

typedef id<ORRunnable> (^ORFloatArray2Runnable)(id<ORFloatArray>);

@interface ORColumnGeneration : NSObject<ORRunnable>
-(id) initWithMaster: (id<LPRunnable>)master slave: (ORFloatArray2Runnable)slaveClo;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) onExit: (ORClosure)block;
@end

