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
   id<ORSolutionPool> _sPool;
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
   _sPool = [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   [_lpsolver release];
   [_sPool release];
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
   [_sPool addSolution: s];
//   NSLog(@"Solution = %@",s);
}
-(ORFloat) dual: (id<ORConstraint>) c
{
   return [_lpsolver dual: [c dereference]];
}
-(ORFloat) reducedCost: (id<ORFloatVar>) v
{
   return [_lpsolver reducedCost: [v dereference]];
}
-(void) trackObject: (id) obj
{
   [_lpsolver trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_lpsolver trackVariable:obj];
}
-(void) trackConstraint:(id) obj
{
   [_lpsolver trackConstraint:obj];
}
-(id<ORSolutionPool>) solutionPool
{
   return _sPool;
}
-(id<ORSolutionPool>) globalSolutionPool
{
   return _sPool;
}

@end


@implementation LPSolverFactory
+(id<LPProgram>) solver: (id<ORModel>) model
{
   return [[LPSolver alloc] initLPSolver: model];
}
@end
