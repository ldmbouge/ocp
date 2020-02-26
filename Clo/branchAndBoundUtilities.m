//
//  branchAndBoundUtilities.m
//  ORUtilities
//
//  Created by Rémy Garcia on 29/01/2020.
//

#import "rationalUtilities.h"
#import "branchAndBoundUtilities.h"
#import <ORFoundation/ORFoundation.h>

@implementation SolWrapper
-(id)init:(id<ORSolution>)s
{
   self = [super init];
   _sol = s;
   return self;
}
-(void)set:(id<ORSolution>)s
{
   _sol = s;
}
-(id<ORSolution>)get
{
   return _sol;
}
-(void)print:(NSArray*)variables for:(NSString*)title
{
   NSLog(@"%@", title);
   for (id<ORVar> v in variables) {
      if([v prettyname] &&
         ([NSStringFromClass([v class]) isEqualToString: @"ORDoubleVarI"] || [NSStringFromClass([v class]) isEqualToString: @"ORFloatVarI"]))
         NSLog(@"    %@: %@", [v prettyname], [_sol value:v]);
   }
}
-(void)print:(NSArray*)variables with:(id<ORSolution>)s for:(NSString*)title
{
   NSLog(@"%@", title);
   for (id<ORVar> v in variables) {
      if([v prettyname] &&
         ([NSStringFromClass([v class]) isEqualToString: @"ORDoubleVarI"] || [NSStringFromClass([v class]) isEqualToString: @"ORFloatVarI"]))
         NSLog(@"    %@: %@", [v prettyname], [s value:v]);
   }
}
@end

/* Try to improve computed error in GuessError, once all variables are set */
ORBool RUN_IMPROVE_GUESS = false;
/* Discard box if half-ulp limit is reached on all constraints */
ORBool RUN_DISCARDED_BOX = true;
/* DO NOT CHANGE HERE - Disable solver output when in sub-solver for GuessError */
ORBool IS_GUESS_ERROR_SOLVER = false;

/* Global variables used to compute branch-and-bound running time */
NSDate *branchAndBoundStart = nil;
NSDate *branchAndBoundTime = nil;

/* Global variables to compute when a box can be discarded */
ORDouble boxCardinality = -1;
TRInt limitCounter;
ORInt nbConstraint = 0;

ORInt nbBoxExplored = 0;
ORInt nbBoxGenerated = 1;


id<ORRational> boundDiscardedBoxes = nil;
