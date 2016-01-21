/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPProgram.h>
#import <ORProgram/LPProgram.h>
#import <ORProgram/MIPProgram.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/CPSolver.h>
#import <ORProgram/ORSolution.h>
#import <ORProgram/CPHeuristic.h>
#import <ORProgram/CPDDeg.h>
#import <ORProgram/CPDeg.h>
#import <ORProgram/CPWDeg.h>
#import <ORProgram/CPIBS.h>
#import <ORProgram/CPABS.h>
#import <ORProgram/CPFirstFail.h>
#import <ORProgram/CPConcretizer.h>
#import <ORProgram/CPMultiStartSolver.h>
#import <ORProgram/CPParallel.h>
#import <ORProgram/ORCPParSolver.h>
#import <ORProgram/ORSTask.h>

#import <ORProgram/ORCombinator.h>
#import <ORProgram/ORParallelCombinator.h>

@interface ORGamma (Model)
-(void) initialize: (PNONNULL id<ORModel>) model;
@end

