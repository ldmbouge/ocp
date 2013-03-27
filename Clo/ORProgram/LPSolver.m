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
   LPSolverI*  _lpsolver;
   id<ORModel> _model;
}
-(id<LPProgram>) initLPSolver: (id<ORModel>) model
{
   self = [super init];
#if defined(__linux__)
   _lpsolver = NULL;
#else
   _lpsolver = [LPFactory solver];
   _model = model;
#endif
   return self;
}
-(void) dealloc
{
   [_lpsolver release];
   [super dealloc];
}
-(LPSolverI*) solver
{
   return _lpsolver;
}
-(void) solve
{
   [_lpsolver solve];
   id<ORSolution> s = [_model captureSolution];
   NSLog(@"Solution = %@",s);
}
-(ORFloat) dual: (id<ORConstraint>) c
{
   ORFloat rv;
   @autoreleasepool {
      NSDictionary* cMap = [_model cMap];
      NSSet* cSet = [cMap objectForKey:@([c getId])];
      assert([cSet count] == 1);
      for(LPConstraintI* c in cSet) {
         rv = [[c dereference] dual];
      }
   }
   return rv;
}
@end


@implementation LPSolverFactory
+(id<LPProgram>) solver: (id<ORModel>) model
{
   return [[LPSolver alloc] initLPSolver: model];
}
@end
