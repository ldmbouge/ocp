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
#import <objmp/LPSolverI.h>


@implementation LPSolver
{
   LPSolverI* _lpsolver;
}
-(id<LPProgram>) initLPSolver
{
   self = [super init];
#if defined(__linux__)
   _lpsolver = NULL;
#else
   _lpsolver = [LPFactory solver];
#endif
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(LPSolverI*) solver
{
   return _lpsolver;
}
-(void) solve
{
    NSLog(@"I am pretending to solve this baby");
    [_lpsolver solve];
}
@end


@implementation LPSolverFactory
+(id<LPProgram>) solver
{
   return [[LPSolver alloc] initLPSolver];
}
@end
