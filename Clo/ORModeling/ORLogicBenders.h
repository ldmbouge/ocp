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

typedef id<ORProcess> (^ORSolution2Process)(id<ORSolution>);
typedef id<ORConstraintSet> (^ORVoid2ConstraintSet)();


@interface ORLogicBenders : NSObject<ORConstraintSetConsumer, ORRunnable>
-(id) initWithMaster: (id<ORRunnable>)master slave: (ORSolution2Process)slaveBlock;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) onExit: (ORClosure)block;
@end

@interface ORCutGenerator : NSObject<ORConstraintSetProducer>
-(id) initWithBlock: (ORVoid2ConstraintSet)block;
-(id<ORSignature>) signature;
-(void) run;
-(void) addConstraintSetConsumer: (id<ORConstraintSetConsumer>)c;
@end

@interface ORFactory(ORLogicBenders)
+(id<ORRunnable>) logicBenders: (id<ORRunnable>)master slave: (ORSolution2Process)slaveBlock;
+(id<ORProcess>) generateCuts: (ORVoid2ConstraintSet)block;
@end
