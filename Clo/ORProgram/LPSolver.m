/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// LPSolver
#import <ORFoundation/ORFoundation.h>
#import "LPProgram.h"
#import "LPSolver.h"

@implementation LPSolver 
-(id<LPProgram>) initLPSolver
{
   self = [super init];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(void) solve
{
   NSLog(@"I am pretending to solve this baby");
}
@end


@implementation LPSolverFactory
+(id<LPProgram>) solver
{
   return [[LPSolver alloc] initLPSolver];
}
@end
