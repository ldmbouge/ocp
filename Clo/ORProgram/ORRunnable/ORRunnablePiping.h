//
//  ORRunnablePiping.h
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import <Foundation/Foundation.h>
#import <ORProgram/ORRunnable.h>

@protocol ORUpperBoundStreamConsumer
-(void) receiveUpperBound: (ORInt)bound;
@end

@protocol ORLowerBoundStreamConsumer
-(void) receiveLowerBound: (ORFloat)bound;
@end

@protocol ORUpperBoundStreamProducer
-(void) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)c;
-(id<ORIntInformer>) upperBoundStreamInformer;
@end

@protocol ORLowerBoundStreamProducer
-(void) addLowerBoundStreamConsumer: (id<ORLowerBoundStreamConsumer>)c;
-(id<ORFloatInformer>) lowerBoundStreamInformer;
@end

@protocol ORSolutionStreamConsumer
-(id<ORSolutionInformer>) solutionStreamInformer;
-(void) receiveSolution: (id<ORSolution>)sol;
@end

@protocol ORSolutionStreamProducer
-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c;
-(void) notifySolution: (id<ORSolution>)sol;
@end

@protocol ORColumnConsumer
@end

@protocol ORColumnProducer
-(void) produceColumn: (id<ORFloatArray>)col;
-(id<ORFloatArray>) retrieveColumn;
@end

@protocol ORConstraintSetConsumer
-(id<ORConstraintSetInformer>) constraintSetInformer;
-(void) receiveConstraintSet: (id<ORConstraintSet>)set;
@end

@protocol ORConstraintSetProducer
-(void) addConstraintSetConsumer: (id<ORConstraintSetConsumer>)c;
-(void) notifyConstraintSet: (id<ORConstraintSet>)set;
@end

@interface ORPipedRunnable : ORAbstractRunnableI<ORRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(void) doExit;

-(void) notifyUpperBound: (ORInt)bound;
-(void) notifyLowerBound: (ORFloat)bound;
-(id<ORIntInformer>) upperBoundStreamInformer;
-(id<ORFloatInformer>) lowerBoundStreamInformer;
-(void) receiveUpperBound: (ORInt)bound;
-(void) receiveLowerBound: (ORFloat)bound;
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

