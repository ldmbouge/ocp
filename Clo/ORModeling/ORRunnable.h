//
//  ORRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPProgram.h"
#import "LPProgram.h"
#import "ORTypes.h"

//Forward Declarations
@protocol  ORModel;

@protocol ORSignature<NSObject>
-(bool) matches: (id<ORSignature>)sig;
-(bool) isComplete;
-(bool) providesUpperBound;
-(bool) providesUpperBoundStream;
-(bool) providesLowerBound;
-(bool) providesLowerBoundStream;
-(bool) providesLowerBoundPool;
-(bool) providesUpperBoundPool;
-(bool) providesSolutionStream;
-(bool) providesColumn;
-(bool) providesConstraint;
-(bool) providesConstraintSet;
-(bool) acceptsUpperBound;
-(bool) acceptsUpperBoundStream;
-(bool) acceptsLowerBound;
-(bool) acceptsLowerBoundStream;
-(bool) acceptsLowerBoundPool;
-(bool) acceptsUpperBoundPool;
-(bool) acceptsSolutionStream;
-(bool) acceptsColumn;
-(bool) acceptsConstraint;
-(bool) acceptsConstraintSet;
@end

@interface ORSignatureI : NSObject<ORSignature> {
    @protected
    bool isComplete;
    bool providesUpperBound;
    bool providesUpperBoundStream;
    bool providesLowerBound;
    bool providesLowerBoundStream;
    bool providesLowerBoundPool;
    bool providesUpperBoundPool;
    bool providesSolutionStream;
    bool providesColumn;
    bool providesConstraint;
    bool providesConstraintSet;
    bool acceptsUpperBound;
    bool acceptsUpperBoundStream;
    bool acceptsLowerBound;
    bool acceptsLowerBoundStream;
    bool acceptsLowerBoundPool;
    bool acceptsUpperBoundPool;
    bool acceptsSolutionStream;
    bool acceptsColumn;
    bool acceptsConstraint;
    bool acceptsConstraintSet;
}
-(bool) matches: (id<ORSignature>)sig;
@property(readonly) bool isComplete;
@property(readonly) bool providesUpperBound;
@property(readonly) bool providesUpperBoundStream;
@property(readonly) bool providesLowerBound;
@property(readonly) bool providesLowerBoundStream;
@property(readonly) bool providesLowerBoundPool;
@property(readonly) bool providesUpperBoundPool;
@property(readonly) bool providesSolutionStream;
@property(readonly) bool providesColumn;
@property(readonly) bool providesConstraint;
@property(readonly) bool providesConstraintSet;
@property(readonly) bool acceptsUpperBound;
@property(readonly) bool acceptsUpperBoundStream;
@property(readonly) bool acceptsLowerBound;
@property(readonly) bool acceptsLowerBoundStream;
@property(readonly) bool acceptsLowerBoundPool;
@property(readonly) bool acceptsUpperBoundPool;
@property(readonly) bool acceptsSolutionStream;
@property(readonly) bool acceptsColumn;
@property(readonly) bool acceptsConstraint;
@property(readonly) bool acceptsConstraintSet;
@end

@interface ORMutableSignatureI : ORSignatureI
-(id) init;
-(id) initFromSignature: (id<ORSignature>)sig;
-(void) copy: (id<ORSignature>)sig;
-(void) clear;
-(ORMutableSignatureI*) complete;
-(ORMutableSignatureI*) upperOut;
-(ORMutableSignatureI*) upperStreamOut;
-(ORMutableSignatureI*) upperPoolOut;
-(ORMutableSignatureI*) lowerOut;
-(ORMutableSignatureI*) lowerStreamOut;
-(ORMutableSignatureI*) lowerPoolOut;
-(ORMutableSignatureI*) solutionStreamOut;
-(ORMutableSignatureI*) columnOut;
-(ORMutableSignatureI*) constraintOut;
-(ORMutableSignatureI*) constraintSetOut;
-(ORMutableSignatureI*) upperIn;
-(ORMutableSignatureI*) upperStreamIn;
-(ORMutableSignatureI*) upperPoolIn;
-(ORMutableSignatureI*) lowerIn;
-(ORMutableSignatureI*) lowerStreamIn;
-(ORMutableSignatureI*) lowerPoolIn;
-(ORMutableSignatureI*) solutionStreamIn;
-(ORMutableSignatureI*) columnIn;
-(ORMutableSignatureI*) constraintIn;
-(ORMutableSignatureI*) constraintSetIn;
@end

@interface ORFactory(ORSignature)
+(id<ORSignature>) createSignature: (NSString*)sigString;
@end

@protocol ORProcess<NSObject>
-(id<ORSignature>) signature;
-(void) run;
@end

@protocol ORRunnable<ORProcess>
-(id<ORModel>) model;
-(void) onExit: (ORClosure)block;
@end

@protocol ORUpperBoundStreamConsumer<ORProcess>
-(id<ORIntInformer>) upperBoundStreamInformer;
@end

@protocol ORUpperBoundStreamProvider<ORProcess>
-(void) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)c;
@end

@protocol ORSolutionStreamConsumer<ORProcess>
-(id<ORSolutionInformer>) solutionStreamInformer;
@end

@protocol ORSolutionStreamProvider<ORProcess>
-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c;
@end

@protocol ORConstraintSetConsumer<ORProcess>
-(id<ORConstraintSetInformer>) constraintSetInformer;
@end

@protocol ORConstraintSetProducer<ORProcess>
-(void) addConstraintSetConsumer: (id<ORConstraintSetConsumer>)c;
@end

@protocol ORRunnableTransform
-(id<ORRunnable>) apply: (id<ORRunnable>)r;
@end

@protocol ORRunnableBinaryTransform
-(id<ORRunnable>) apply: (id<ORRunnable>)r0 and: (id<ORRunnable>)r1;
@end

@protocol ORUpperBoundedRunnable<ORRunnable, ORUpperBoundStreamConsumer, ORUpperBoundStreamProvider,
                                    ORSolutionStreamConsumer, ORSolutionStreamProvider>
@end

@interface ORUpperBoundedRunnableI : NSObject<ORUpperBoundedRunnable> {
@protected
    id<ORModel> _model;
    id<ORSignature> _sig;
    ORClosure _exitBlock;
    id<ORIntInformer> _upperBoundStreamInformer;
    id<ORSolutionInformer> _solutionStreamInformer;
    NSMutableArray* _upperBoundStreamConsumers;
    NSMutableArray* _solutionStreamConsumers;
}

-(id) initWithModel: (id<ORModel>)m;
-(id<ORModel>) model;
-(id<ORSignature>) signature;
@end

@protocol CPRunnable<ORUpperBoundedRunnable, ORRunnable>
-(id<CPProgram>) solver;
@end

@interface CPRunnableI : ORUpperBoundedRunnableI<CPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<CPProgram>) solver;
-(void) run;
//-(void) restore: (id<ORSolution>)s;
@end

@protocol LPRunnable <ORRunnable>
-(id<LPProgram>) solver;
-(id<ORFloatArray>) duals;
-(void) injectColumn: (id<ORFloatArray>) col;
@end

@interface LPRunnableI : NSObject<LPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<LPProgram>) solver;
-(id<ORFloatArray>) duals;
-(void) injectColumn: (id<ORFloatArray>) col;
-(id<ORModel>) model;
-(void) run;
@end

@interface ORFactory(ORRunnable)
+(id<CPRunnable>) CPRunnable: (id<ORModel>)m;
+(id<LPRunnable>) LPRunnable: (id<ORModel>)m;
@end
