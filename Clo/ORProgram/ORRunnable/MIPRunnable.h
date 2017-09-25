//
//  MIPRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import <Foundation/Foundation.h>
#import <ORProgram/MIPProgram.h>
#import "ORRunnablePiping.h"

@protocol MIPRunnable <ORRunnable>
-(id<MIPProgram>) solver;
-(void) addCuts: (id<ORConstraintSet>) cuts;
@end

@interface MIPRunnableI : ORPipedRunnable<MIPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id) initWithModel: (id<ORModel>)m numThreads: (ORInt)nth;
-(id<ORSignature>) signature;
-(id<MIPProgram>) solver;
-(void) addCuts: (id<ORConstraintSet>) cuts;
-(id<ORModel>) model;
-(void) run;
-(ORDouble) bestBound;
-(id<ORSolution>) bestSolution;
@end
