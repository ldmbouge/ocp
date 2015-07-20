/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// MIPSolver
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModelTransformation.h>

#import "MIPProgram.h"
#import "MIPSolver.h"
#import <objmp/MIPSolverI.h>
#import "ORSolution.h"
#import "ORProgramFactory.h"

@implementation MIPSolver
{
   MIPSolverI*  _MIPsolver;
   id<ORModel> _model;
   id<ORSolutionPool> _sPool;
}
-(id<MIPProgram>) initMIPSolver: (id<ORModel>) model
{
   self = [super init];
   _MIPsolver = [MIPFactory solver];
   _model = model;
   _sPool = (id<ORSolutionPool>) [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   [_MIPsolver release];
   [_sPool release];
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return self;
}
-(id<ORExplorer>)  explorer
{
   return nil;
}
-(void) close
{}

-(id<OREngine>) engine
{
   return _MIPsolver;
}
-(MIPSolverI*) solver
{
   return _MIPsolver;
}
-(void) solve
{
   [_MIPsolver solve];
   id<ORSolution> s = [self captureSolution];
   [_sPool addSolution: s];
   [s release];
}
-(ORFloat) floatValue: (id<ORFloatVar>) v
{
   return [_MIPsolver floatValue: _gamma[v.getId]];
}
-(ORInt) intValue: (id<ORIntVar>) v
{
   return [_MIPsolver intValue: _gamma[v.getId]];
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [_MIPsolver objectiveValue];
}
-(id<ORSolution>) captureSolution
{
   return [ORFactory solution: _model solver: self];
}
-(id) trackObject: (id) obj
{
   return [_MIPsolver trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_MIPsolver trackConstraintInGroup:obj];
}
-(id) trackObjective: (id) obj
{
   return [_MIPsolver trackObjective:obj];
}
-(id) trackMutable: (id) obj
{
   return [_MIPsolver trackMutable:obj];
}
-(id) trackImmutable:(id)obj
{
   return [_MIPsolver trackImmutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_MIPsolver trackVariable:obj];
}
-(id<ORSolutionPool>) solutionPool
{
   return _sPool;
}
@end

@implementation MIPSolverFactory
+(id<MIPProgram>) solver: (id<ORModel>) model
{
   return [[MIPSolver alloc] initMIPSolver: model];
}
@end
