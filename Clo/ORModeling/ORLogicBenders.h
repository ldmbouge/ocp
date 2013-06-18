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
#import "ORRunnablePiping.h"

typedef id<ORConstraintSet> (^Void2ConstraintSet)();


@interface ORLogicBenders : ORPipedRunnable {
@protected
    id<ORRunnable> _master;
    Void2ConstraintSet _slaveBlock;
    id<ORSignature> _sig;

    NSTimeInterval timeInMaster;
    NSTimeInterval timeInSlave;
}

-(id) initWithMaster: (id<ORRunnable>)master slave: (Void2ConstraintSet)slaveBlock;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) onExit: (ORClosure)block;

@property(readwrite) NSTimeInterval timeInMaster;
@property(readwrite) NSTimeInterval timeInSlave;

@end

@interface ORFactory(ORLogicBenders)
+(id<ORRunnable>) logicBenders: (id<ORRunnable>)master slave: (Void2ConstraintSet)slaveBlock;
@end
