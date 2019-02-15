//
//  ORCombinator.h
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import <Foundation/Foundation.h>

@protocol ORRunnable;

@protocol ORCombinator<NSObject>
-(BOOL) isCompatible: (NSArray*)runnables;
-(id<ORRunnable>) apply: (NSArray*)runnables;
@end

