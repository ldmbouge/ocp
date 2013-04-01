/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/MIPProgram.h>

// MIPSolver
@interface MIPSolver : NSObject<MIPProgram>
-(id<MIPProgram>) initMIPSolver: (id<ORModel>) model;
-(id<ORObjectiveValue>) objectiveValue;
-(id<ORMIPSolutionPool>) solutionPool;
-(id<ORMIPSolution>) captureSolution;
@end

// MIPSolverFactory
@interface MIPSolverFactory : NSObject
+(id<MIPProgram>) solver: (id<ORModel>) model;
@end
