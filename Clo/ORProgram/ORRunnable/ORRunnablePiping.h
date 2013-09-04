//
//  ORRunnablePiping.h
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import <Foundation/Foundation.h>
#import <ORProgram/ORRunnable.h>

@protocol ORBoundStreamConsumer<ORRunnable>
-(id<ORIntInformer>) boundStreamInformer;
@end

@protocol ORUpperBoundStreamConsumer<ORBoundStreamConsumer>
-(void) receiveUpperBound: (ORInt)bound;
@end

@protocol ORLowerBoundStreamConsumer<ORBoundStreamConsumer>
-(void) receiveLowerBound: (ORInt)bound;
@end

@protocol ORUpperBoundStreamProducer<ORRunnable>
-(void) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)c;
@end

@protocol ORLowerBoundStreamProducer<ORRunnable>
-(void) addLowerBoundStreamConsumer: (id<ORLowerBoundStreamConsumer>)c;
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
-(id) initWithModel: (id<ORModel>)m;
-(void) doExit;

-(void) notifyUpperBound: (ORInt)bound;
-(void) notifyLowerBound: (ORInt)bound;
-(id<ORIntInformer>) boundStreamInformer;
-(void) receiveUpperBound: (ORInt)bound;
-(void) receiveLowerBound: (ORInt)bound;
-(void) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)c;
-(void) addLowerBoundStreamConsumer: (id<ORLowerBoundStreamConsumer>)c;
-(id<ORSolutionInformer>) solutionStreamInformer;
-(void) receiveSolution: (id<ORSolution>)sol;
-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c;
-(void) notifySolution: (id<ORSolution>)sol;
-(void) produceColumn: (id<ORFloatArray>)col;
-(id<ORFloatArray>) retrieveColumn;
-(id<ORConstraintSetInformer>) constraintSetInformer;
-(void) receiveConstraintSet: (id<ORConstraintSet>)set;
-(void) addConstraintSetConsumer: (id<ORConstraintSetConsumer>)c;
-(void) notifyConstraintSet: (id<ORConstraintSet>)set;
@end

