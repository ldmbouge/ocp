/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// MIPSolver
#import <ORFoundation/ORFoundation.h>
#import "MIPProgram.h"
#import "MIPSolver.h"
#import <objmp/MIPSolverI.h>


@implementation MIPSolver
{
   MIPSolverI*  _MIPsolver;
   id<ORModel> _model;
}
-(id<MIPProgram>) initMIPSolver: (id<ORModel>) model
{
   self = [super init];
#if defined(__linux__)
   _MIPsolver = NULL;
#else
   _MIPsolver = [MIPFactory solver];
   _model = model;
#endif
   return self;
}
-(void) dealloc
{
   [_MIPsolver release];
   [super dealloc];
}
-(MIPSolverI*) solver
{
   return _MIPsolver;
}
-(void) solve
{
   [_MIPsolver solve];
//   id<ORSolution> s = [_model captureSolution];
//   NSLog(@"Solution = %@",s);
}
-(void) trackObject: (id) obj
{
   [_MIPsolver trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_MIPsolver trackVariable:obj];
}
-(void) trackConstraint:(id) obj
{
   [_MIPsolver trackConstraint:obj];
}

@end


@implementation MIPSolverFactory
+(id<MIPProgram>) solver: (id<ORModel>) model
{
   return [[MIPSolver alloc] initMIPSolver: model];
}
@end
