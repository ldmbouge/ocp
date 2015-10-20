//
//  MIPRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import <Foundation/Foundation.h>
#import "ORRunnablePiping.h"
#import "MIPProgram.h"

@protocol MIPRunnable <ORRunnable>
-(id<MIPProgram>) solver;
-(void) injectColumn: (id<ORDoubleArray>) col;
@end

@interface MIPRunnableI : ORPipedRunnable<MIPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<MIPProgram>) solver;
-(void) injectColumn: (id<ORDoubleArray>) col;
-(id<ORModel>) model;
-(void) run;
-(void) setTimeLimit: (ORDouble) secs;
-(ORDouble) bestBound;
-(id<ORSolution>) bestSolution;
@end
