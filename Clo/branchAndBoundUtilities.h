//
//  branchAndBoundUtilities.h
//  Clo
//
//  Created by Rémy Garcia on 29/01/2020.
//

#import <ORFoundation/ORTrail.h>
#import "rationalUtilities.h"

@protocol ORModel;
@protocol ORVar;

@interface SolWrapper : NSObject {
   id<ORSolution> _sol;
}
-(id)init:(id<ORSolution>)s;
-(void)set:(id<ORSolution>)s;
-(id<ORSolution>)get;
-(void)print:(NSArray*)variables for:(NSString*)title;
-(void)print:(NSArray*)variables with:(id<ORSolution>)s for:(NSString*)title;
@end

extern ORBool RUN_IMPROVE_GUESS;
extern ORBool RUN_DISCARDED_BOX;
extern ORBool IS_GUESS_ERROR_SOLVER;

extern id<ORRational> boundDiscardedBoxes;

extern NSDate *branchAndBoundStart;
extern NSDate *branchAndBoundTime;
extern ORDouble boxCardinality;
extern TRInt limitCounter;
extern ORInt nbConstraint;

static inline ORFloat randomValue(ORFloat min, ORFloat max)
{
   return (max - min) * ((ORFloat)drand48()) + min;
}
static inline ORDouble randomValueD(ORDouble min, ORDouble max)
{
   return (max - min) * (drand48()) + min;
}
