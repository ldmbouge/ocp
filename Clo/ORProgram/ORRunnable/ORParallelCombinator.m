//
//  ORParallelCombinator.m
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import "ORParallelCombinator.h"
#import "ORParallelRunnable.h"

@interface ORCompleteParallelCombinator(Private)
-(void) connectInternalPiping: (NSArray*)runnables;
@end

@implementation ORCompleteParallelCombinator

-(BOOL) isCompatible: (NSArray*)runnables
{
    return YES;
}

-(id<ORRunnable>) apply: (NSArray*)runnables
{
    if(![self isCompatible: runnables]) {
        // Error
        return nil;
    }
    [self connectInternalPiping: runnables];
    return [[ORCompleteParallelRunnableI alloc] initWithPrimary: runnables[0] secondary: runnables[1]];
}

-(void) connectInternalPiping: (NSArray*)runnables {
    ORAbstractRunnableI* r0 = (ORAbstractRunnableI*)runnables[0];
    ORAbstractRunnableI* r1 = (ORAbstractRunnableI*)runnables[1];
    
    [r1 performOnStart: ^() {
       id<ORSignature> r0Sig = [r0 signature];
       id<ORSignature> r1Sig = [r1 signature];
        if([r0Sig providesUpperBoundStream] && [r1Sig acceptsUpperBoundStream])
            [(id<ORUpperBoundStreamProducer>)r0 addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)r1];
        if([r0Sig providesLowerBoundStream] && [r1Sig acceptsLowerBoundStream])
            [(id<ORLowerBoundStreamProducer>)r0 addLowerBoundStreamConsumer: (id<ORLowerBoundStreamConsumer>)r1];
        if([r0Sig providesSolutionStream] && [r1Sig acceptsSolutionStream])
            [(id<ORSolutionStreamProducer>)r0 addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)r1];
    }];
    
    [r0 performOnStart: ^() {
        if([[r1 signature] providesUpperBoundStream] && [[r0 signature] acceptsUpperBoundStream])
            [(id<ORUpperBoundStreamProducer>)r1 addUpperBoundStreamConsumer: (id<ORUpperBoundStreamConsumer>)r0];
        if([[r1 signature] providesLowerBoundStream] && [[r0 signature] acceptsLowerBoundStream])
            [(id<ORLowerBoundStreamProducer>)r1 addLowerBoundStreamConsumer: (id<ORLowerBoundStreamConsumer>)r0];
        if([[r1 signature] providesSolutionStream] && [[r0 signature] acceptsSolutionStream])
            [(id<ORSolutionStreamProducer>)r1 addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)r0];
    }];
}

@end

@implementation ORFactory(ORParallelCombinator)
+(id<ORRunnable>) composeCompleteParallel: (id<ORRunnable>)r0 with: (id<ORRunnable>)r1
{
    ORCompleteParallelCombinator* par = [[ORCompleteParallelCombinator alloc] init];
    NSArray* runnables = [NSArray arrayWithObjects: r0, r1, nil];
    id<ORRunnable> product = [par apply: runnables];
    //[runnables release];
    [par release];
    return product;
}
@end