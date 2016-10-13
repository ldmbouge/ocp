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
#import "CPBitVarHeuristic.h"
#import <ORProgram/CPDDeg.h>
#import <ORProgram/CPDeg.h>
#import <ORProgram/CPWDeg.h>
#import <ORProgram/CPIBS.h>
#import <ORProgram/CPABS.h>
//<<<<<<< HEAD
#import <ORProgram/CPBitVarABS.h>
#import <ORProgram/CPBitVarIBS.h>
#import <ORProgram/CPFirstFail.h>
#import <ORProgram/CPBitVarFirstFail.h>
//=======
#import <ORProgram/CPFDS.h>
#import <ORProgram/CPFirstFail.h>
#import <ORProgram/CPConcretizer.h>
#import <ORProgram/CPMultiStartSolver.h>
#import <ORProgram/CPParallel.h>
#import <ORProgram/ORCPParSolver.h>
#import <ORProgram/ORSTask.h>
//>>>>>>> master

#import <ORProgram/ORCombinator.h>
#import <ORProgram/ORRunnable.h>
#import <ORProgram/ORSignature.h>
#import <ORProgram/ORParallelCombinator.h>

#import <ORProgram/PCBranching.h>

//The headers below are _not_ public
//project: #import <ORProgram/CPRunnable.h>
//project: #import <ORProgram/LPRunnable.h>
//project: #import <ORProgram/MIPRunnable.h
//project: #import <ORProgram/ORColumnGeneration.h>
#import <ORProgram/ORLagrangeRelax.h>
#import <ORProgram/ORLagrangianTransform.h>
//project: #import <ORProgram/ORLogicBenders.h>
//project: #import <ORProgram/ORParallelRunnable.h>
//project: #import <ORProgram/ORRunnablePiping.h>


@interface ORGamma (Model)
-(void) initialize: (PNONNULL id<ORModel>) model;
@end

