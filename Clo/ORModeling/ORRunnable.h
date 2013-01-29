//
//  ORRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPProgram.h"
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
-(bool) acceptsUpperBound;
-(bool) acceptsUpperBoundStream;
-(bool) acceptsLowerBound;
-(bool) acceptsLowerBoundStream;
-(bool) acceptsLowerBoundPool;
-(bool) acceptsUpperBoundPool;
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
    bool acceptsUpperBound;
    bool acceptsUpperBoundStream;
    bool acceptsLowerBound;
    bool acceptsLowerBoundStream;
    bool acceptsLowerBoundPool;
    bool acceptsUpperBoundPool;
}
-(bool) matches: (id<ORSignature>)sig;
@property(readonly) bool isComplete;
@property(readonly) bool providesUpperBound;
@property(readonly) bool providesUpperBoundStream;
@property(readonly) bool providesLowerBound;
@property(readonly) bool providesLowerBoundStream;
@property(readonly) bool providesLowerBoundPool;
@property(readonly) bool providesUpperBoundPool;
@property(readonly) bool acceptsUpperBound;
@property(readonly) bool acceptsUpperBoundStream;
@property(readonly) bool acceptsLowerBound;
@property(readonly) bool acceptsLowerBoundStream;
@property(readonly) bool acceptsLowerBoundPool;
@property(readonly) bool acceptsUpperBoundPool;
@end

@interface ORFactory(ORSignature)
+(id<ORSignature>) createSignature: (NSString*)sigString;
@end

@protocol ORRunnable<NSObject>
-(id<ORSignature>) signature;
-(void) run;
@end

@protocol ORUpperBoundStreamConsumer<ORRunnable>
-(id<ORIntInformer>) upperBoundStreamInformer;
@end

@protocol ORUpperBoundStreamProvider<ORRunnable>
-(void) addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)c;
@end

@protocol ORRunnableTransform
-(id<ORRunnable>) apply: (id<ORRunnable>)r;
@end

@protocol ORRunnableBinaryTransform
-(id<ORRunnable>) apply: (id<ORRunnable>)r0 and: (id<ORRunnable>)r1;
@end

@protocol CPRunnable<ORUpperBoundStreamConsumer, ORUpperBoundStreamProvider>
-(id<CPProgram>) solver;
@end

@interface CPRunnableI : NSObject<CPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<CPProgram>) solver;
-(void) run;
@end
