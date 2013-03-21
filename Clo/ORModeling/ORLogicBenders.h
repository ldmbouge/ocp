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

typedef id<ORRunnable> (^ORSolution2Runnable)(id<ORSolution>);
typedef id<ORConstraint> (^ORRunnable2Constraint)(id<ORRunnable>);

@protocol ORConstraintConsumer<ORRunnable>
-(id<ORConstraintInformer>) constraintInformer;
@end

@protocol ORConstraintProvider<ORRunnable>
-(void) addConstraintConsumer: (id<ORConstraintConsumer>)c;
@end

@interface ORLogicBenders : NSObject<ORConstraintConsumer>
-(id) initWithMaster: (id<ORRunnable>)master slave: (ORSolution2Runnable)slaveBlock;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) onExit: (ORClosure)block;
@end

@interface ORCutGenerator : NSObject<ORConstraintProvider>
-(id) initWithRunnable: (id<ORRunnable>)r cutTransform: (ORRunnable2Constraint)block;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) onExit: (ORClosure)block;
-(void) addColumnConsumer: (id<ORSolutionStreamConsumer>)c;
@end

@interface ORFactory(ORLogicBenders)
+(id<ORRunnable>) logicBenders: (id<ORRunnable>)master slave: (ORSolution2Runnable)slaveBlock;
+(id<ORRunnable>) generateCut: (id<ORRunnable>)r using: (ORRunnable2Constraint)block;
@end
