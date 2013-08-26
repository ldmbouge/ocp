//
//  CPRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import <Foundation/Foundation.h>
#import "ORRunnablePiping.h"
#import "CPProgram.h"

@protocol CPRunnable <ORUpperBoundStreamConsumer, ORUpperBoundStreamProducer,
                      ORLowerBoundStreamConsumer, ORSolutionStreamConsumer,
                      ORSolutionStreamProducer>
-(id<CPProgram>) solver;
@end

@interface CPRunnableI : ORPipedRunnable<CPRunnable>
-(id) initWithModel: (id<ORModel>)m;
@end

