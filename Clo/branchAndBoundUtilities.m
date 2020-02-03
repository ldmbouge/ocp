//
//  branchAndBoundUtilities.m
//  ORUtilities
//
//  Created by Rémy Garcia on 29/01/2020.
//

#import "rationalUtilities.h"
#import "branchAndBoundUtilities.h"

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
-(void)print:(id<ORModel>)m for:(NSString*)title
{
   NSLog(@"%@", title);
#warning [rg] Instance method not found: cannot add #import <ORModeling/ORModeling.h> because of cycle dependency. (Work at runtime)
   for (id<ORVar> v in [m variables]) {
      if([v prettyname] &&
         ([NSStringFromClass([v class]) isEqualToString: @"ORDoubleVarI"] || [NSStringFromClass([v class]) isEqualToString: @"ORFloatVarI"]))
         NSLog(@"    %@: %@", [v prettyname], [_sol value:v]);
   }}
@end

/* Try to improve computed error in GuessError, once all variables are set */
bool RUN_IMPROVE_GUESS = true;
/* Discard box if half-ulp limit is reached on all constraints */
bool RUN_DISCARDED_BOX = true;
/* INTERNAL - DO NOT CHANGE HERE - Disable solver output when in sub-solver for GuessError */
bool IS_GUESS_ERROR_SOLVER = false;

/* Global variables used to compute metrics about solver exploration */
int nbBoxGenerated = 1;
int nbBoxExplored = 0;
NSDate *branchAndBoundStart = nil;
NSDate *branchAndBoundTime = nil;

/* Global variables to compute when a box can be discarded */
double boxCardinality = -1;
TRInt limitCounter;
int nbConstraint = 0;

/* Global solution to output input values exercising the primal bound */
SolWrapper* solution;
