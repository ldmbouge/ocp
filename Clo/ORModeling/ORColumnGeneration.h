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

typedef id<ORRunnable> (^ORFloatArray2Runnable)(id<ORFloatArray>);
typedef id<ORFloatArray> (^Void2FloatArray)();

@interface ORColumnGeneration : ORPipedRunnable<ORColumnConsumer>
-(id) initWithMaster: (id<ORRunnable>)master slave: (Void2FloatArray)slaveBlock;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) onExit: (ORClosure)block;
@end

@interface ORColumnGenerator : ORPipedRunnable
-(id) initWithRunnable: (id<ORRunnable>)r solutionTransform: (Void2FloatArray)block;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) onExit: (ORClosure)block;
-(void) addColumnConsumer: (id<ORSolutionStreamConsumer>)c;
@end

@interface ORFactory(ORColumnGeneration)
+(id<ORRunnable>) columnGeneration: (id<ORRunnable>)master slave: (Void2FloatArray)slaveBlock;
@end
