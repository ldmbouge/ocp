//
//  ORSequentialCombinator.h
//  Clo
//
//  Created by Daniel Fontaine on 12/4/16.
//
//

#import <ORProgram/ORCombinator.h>
#import <ORFoundation/ORFactory.h>

@interface ORSequentialCombinator : NSObject<ORCombinator>
-(BOOL) isCompatible: (NSArray*)runnables;
-(id<ORRunnable>) apply: (NSArray*)runnables;
@end

@interface ORFactory(ORSequentialCombinator)
+(id<ORRunnable>) composeSequnetial: (id<ORRunnable>)r0 with: (id<ORRunnable>)r1;
@end

