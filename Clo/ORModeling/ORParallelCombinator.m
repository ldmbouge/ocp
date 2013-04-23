//
//  ORParallelCombinator.m
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import "ORParallelCombinator.h"
#import "ORParallelRunnable.h"

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
    return [[[ORCompleteParallelRunnableI alloc] initWithPrimary: runnables[0] secondary: runnables[1]] autorelease];
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