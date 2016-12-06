//
//  ORSequentialCombinator.m
//  Clo
//
//  Created by Daniel Fontaine on 12/4/16.
//
//

#import "ORSequentialCombinator.h"
#import "ORSequentialRunnable.h"

@implementation ORSequentialCombinator

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
    return [[ORSequentialRunnableI alloc] initWithPrimaryRunnable: runnables[0] boundingRunnable: runnables[1]];
}

@end

@implementation ORFactory(ORSequentialCombinator)
+(id<ORRunnable>) composeSequnetial: (id<ORRunnable>)r0 with: (id<ORRunnable>)r1
{
    ORSequentialCombinator* seq = [[ORSequentialCombinator alloc] init];
    NSArray* runnables = [NSArray arrayWithObjects: r1, r0, nil];
    id<ORRunnable> product = [seq apply: runnables];
    //[runnables release];
    [seq release];
    return product;
}
@end