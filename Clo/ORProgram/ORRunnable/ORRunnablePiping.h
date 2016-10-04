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
-(void) receiveLowerBound: (ORDouble)bound;
@end

@protocol ORUpperBoundStreamProducer
-(void) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)c;
-(id<ORIntInformer>) upperBoundStreamInformer;
@end

@protocol ORLowerBoundStreamProducer
-(void) addLowerBoundStreamConsumer: (id<ORLowerBoundStreamConsumer>)c;
-(id<ORDoubleInformer>) lowerBoundStreamInformer;
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
-(void) produceColumn: (id<ORDoubleArray>)col;
-(id<ORDoubleArray>) retrieveColumn;
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
-(void) notifyLowerBound: (ORDouble)bound;
-(id<ORIntInformer>) upperBoundStreamInformer;
-(id<ORDoubleInformer>) lowerBoundStreamInformer;
-(void) receiveUpperBound: (ORInt)bound;
-(void) receiveLowerBound: (ORDouble)bound;
-(void) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)c;
-(void) addLowerBoundStreamConsumer: (id<ORLowerBoundStreamConsumer>)c;
-(id<ORSolutionInformer>) solutionStreamInformer;
-(void) receiveSolution: (id<ORSolution>)sol;
-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c;
-(void) notifySolution: (id<ORSolution>)sol;
-(void) produceColumn: (id<ORDoubleArray>)col;
-(id<ORDoubleArray>) retrieveColumn;
-(id<ORConstraintSetInformer>) constraintSetInformer;
-(void) receiveConstraintSet: (id<ORConstraintSet>)set;
-(void) addConstraintSetConsumer: (id<ORConstraintSetConsumer>)c;
-(void) notifyConstraintSet: (id<ORConstraintSet>)set;
@end

