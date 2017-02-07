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
#import <ORProgram/ORRunnablePiping.h>

typedef id<ORConstraintSet> (^ORSolution2ConstraintSet)(id<ORSolution>);


@interface ORLogicBenders : ORPipedRunnable {
@protected
    id<ORRunnable> _master;
    ORSolution2ConstraintSet _slaveBlock;
    id<ORSolution> _bestSol;

    NSTimeInterval timeInMaster;
    NSTimeInterval timeInSlave;
}

-(id) initWithMaster: (id<ORRunnable>)master slave: (ORSolution2ConstraintSet)slaveBlock;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;

@property(readwrite) NSTimeInterval timeInMaster;
@property(readwrite) NSTimeInterval timeInSlave;

@end

@interface ORFactory(ORLogicBenders)
+(id<ORRunnable>) logicBenders: (id<ORRunnable>)master slave: (ORSolution2ConstraintSet)slaveBlock;
@end
