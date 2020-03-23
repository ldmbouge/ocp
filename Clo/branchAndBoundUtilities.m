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

@implementation ORGammaError
- (id)init
{
   self = [super init];
   _dic = [NSMutableDictionary dictionary];
   return self;
}
- (void) dealloc
{
   [_dic dealloc];
   [super dealloc];
}
- (id)concretizeError:(NSUInteger)index
{
   return [_dic objectForKey:[NSNumber numberWithLong:index]];
}
- (id)saveError:(id<CPRationalVar>)error of:(NSUInteger)index
{
   [_dic setObject:error forKey:[NSNumber numberWithLong:index]];
   return self;
}
- (NSString*)description
{
   return [_dic description];
}
@end

/* Try to improve computed error in GuessError, once all variables are set */
ORBool RUN_IMPROVE_GUESS = true;
/* Discard box if half-ulp limit is reached on all constraints */
ORBool RUN_DISCARDED_BOX = true;

/* Run 3B filtering over errors - state constraint over rational to compute error operation at the constraint level */
ORBool RUN_3B_ERROR = false;


/* Emulate _gamma behaviour for error -> considering a CPFLoatVar/CPDoubleVar _gammaE return its error (as a CPRationalVar) if it exist or create it with concretizeError */
/* Initalized in ORModeling.m in createModel method -- as it is used immediatly when solver is build */
ORGammaError* _gammaE = nil;

/* Global variables used to compute branch-and-bound running time */
NSDate *branchAndBoundStart = nil;
NSDate *branchAndBoundTime = nil;

/* Global variables to compute when a box can be discarded */
ORDouble boxCardinality = -1;
TRInt limitCounter;
TRInt indexSplit;
ORInt nbConstraint = 0;

ORInt nbBoxExplored = 0;
ORInt nbBoxGenerated = 1;


id<ORRational> boundDiscardedBoxes = nil;
id<ORRational> boundDegeneratedBoxes = nil;
id<ORRational> boundTopOfQueue = nil;
id<CPEngine> errorGroup = nil;
