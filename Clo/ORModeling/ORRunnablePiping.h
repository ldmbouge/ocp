//
//  ORRunnablePiping.h
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import <Foundation/Foundation.h>
#import "ORRunnable.h"

@protocol ORBoundStreamConsumer<ORRunnable>
-(id<ORIntInformer>) boundStreamInformer;
@end

@protocol ORUpperBoundStreamConsumer<ORBoundStreamConsumer>
-(void) receiveUpperBound: (ORInt)bound;
@end

@protocol ORLowerBoundStreamConsumer<ORBoundStreamConsumer>
-(void) receiveLowerBound: (ORInt)bound;
@end

@protocol ORBoundStreamProducer<ORRunnable>
-(void) addBoundStreamConsumer: (id<ORBoundStreamConsumer>)c;
@end

@protocol ORUpperBoundStreamProducer<ORBoundStreamProducer>
-(void) notifyUpperBound: (ORInt)bound;
@end

@protocol ORLowerBoundStreamProducer<ORBoundStreamProducer>
-(void) notifyLowerBound: (ORInt)bound;
@end

@protocol ORSolutionStreamConsumer<ORRunnable>
-(id<ORSolutionInformer>) solutionStreamInformer;
-(void) receiveSolution: (id<ORSolution>)sol;
@end

@protocol ORSolutionStreamProducer<ORRunnable>
-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c;
-(void) notifySolution: (id<ORSolution>)sol;
@end

@protocol ORColumnConsumer<ORRunnable>
@end

@protocol ORColumnProducer<ORRunnable>
-(void) produceColumn: (id<ORFloatArray>)col;
-(id<ORFloatArray>) retrieveColumn;
@end

@protocol ORConstraintSetConsumer<ORRunnable>
-(id<ORConstraintSetInformer>) constraintSetInformer;
-(void) receiveConstraintSet: (id<ORConstraintSet>)set;
@end

@protocol ORConstraintSetProducer<ORRunnable>
-(void) addConstraintSetConsumer: (id<ORConstraintSetConsumer>)c;
-(void) notifyConstraintSet: (id<ORConstraintSet>)set;
@end

@interface ORPipedRunnable : ORAbstractRunnableI<ORRunnable>
-(id) initWithModel: (id<ORModel>)m children: (NSArray*)child;
-(void) doExit;
@end

