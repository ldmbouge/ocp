//
//  ORParallelCombinator.h
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import <ORProgram/ORCombinator.h>

@interface ORCompleteParallelCombinator : NSObject<ORCombinator>
-(BOOL) isCompatible: (NSArray*)runnables;
-(id<ORRunnable>) apply: (NSArray*)runnables;
@end

@interface ORFactory(ORParallelCombinator)
+(id<ORRunnable>) composeCompleteParallel: (id<ORRunnable>)r0 with: (id<ORRunnable>)r1;
@end