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
-(bool) acceptsUpperBound;
-(bool) acceptsUpperBoundStream;
-(bool) acceptsLowerBound;
-(bool) acceptsLowerBoundStream;
-(bool) acceptsLowerBoundPool;
-(bool) acceptsUpperBoundPool;
-(bool) acceptsSolutionStream;
-(bool) acceptsColumn;
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
    bool acceptsUpperBound;
    bool acceptsUpperBoundStream;
    bool acceptsLowerBound;
    bool acceptsLowerBoundStream;
    bool acceptsLowerBoundPool;
    bool acceptsUpperBoundPool;
    bool acceptsSolutionStream;
    bool acceptsColumn;
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
@property(readonly) bool acceptsUpperBound;
@property(readonly) bool acceptsUpperBoundStream;
@property(readonly) bool acceptsLowerBound;
@property(readonly) bool acceptsLowerBoundStream;
@property(readonly) bool acceptsLowerBoundPool;
@property(readonly) bool acceptsUpperBoundPool;
@property(readonly) bool acceptsSolutionStream;
@property(readonly) bool acceptsColumn;
@end

@interface ORFactory(ORSignature)
+(id<ORSignature>) createSignature: (NSString*)sigString;
@end

@protocol ORRunnable<NSObject>
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) onExit: (ORClosure)block;
@end

@protocol ORUpperBoundStreamConsumer<ORRunnable>
-(id<ORIntInformer>) upperBoundStreamInformer;
@end

@protocol ORUpperBoundStreamProvider<ORRunnable>
-(void) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)c;
@end

@protocol ORSolutionStreamConsumer<ORRunnable>
-(id<ORSolutionInformer>) solutionStreamInformer;
@end

@protocol ORSolutionStreamProvider<ORRunnable>
-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c;
@end

@protocol ORRunnableTransform
-(id<ORRunnable>) apply: (id<ORRunnable>)r;
@end

@protocol ORRunnableBinaryTransform
-(id<ORRunnable>) apply: (id<ORRunnable>)r0 and: (id<ORRunnable>)r1;
@end

@protocol ORUpperBoundedRunnable<ORUpperBoundStreamConsumer, ORUpperBoundStreamProvider,
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
@end

@protocol CPRunnable<ORUpperBoundedRunnable>
-(id<CPProgram>) solver;
@end

@interface CPRunnableI : ORUpperBoundedRunnableI<CPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<CPProgram>) solver;
-(id<ORModel>) model;
-(void) run;
-(void) restore: (id<ORSolution>)s;
@end

@protocol LPRunnable <ORRunnable>
-(id<LPProgram>) solver;
-(id<ORFloatArray>) duals;
@end

@interface LPRunnableI : NSObject<LPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<LPProgram>) solver;
-(id<ORFloatArray>) duals;
-(id<ORModel>) model;
-(void) run;
@end

