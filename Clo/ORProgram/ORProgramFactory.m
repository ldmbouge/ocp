/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORModeling/ORFlatten.h>
#import "ORProgramFactory.h"

// CP Solver
#import <ORProgram/CPFirstFail.h>
#import <ORProgram/ORCPParSolver.h>
#import <ORProgram/CPMultiStartSolver.h>
#import <objcp/CPFactory.h>
#import "CPSolver.h"
#import "CPConcretizer.h"
#import "CPDDeg.h"
#import "CPWDeg.h"
#import "CPIBS.h"
#import "CPABS.h"

// LP Solver
#import "LPProgram.h"
#import "LPSolver.h"
#import "LPConcretizer.h"

// MIP Solver
#import "MIPProgram.h"
#import "MIPSolver.h"
#import "MIPConcretizer.h"

// PVH to factorize this

@implementation ORFactory (Concretization)

+(id<CPProgram>)concretizeCP:(id<ORModel>)m
{
   id<CPProgram> mp = [CPSolverFactory solver];
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: mp];
   [m visit: concretizer];
   [concretizer release];
   [mp setSource:m];
   return mp;
}

+(void) createCPProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram
{
   id<ORModel> fm = [model flatten];
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   [fm visit: concretizer];
   [cpprogram setSource:model];
   [concretizer release];
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model
{
   id<CPProgram> cpprogram = [CPSolverFactory solver];
   [ORFactory createCPProgram: model program: cpprogram];
   [model setImpl: cpprogram];
   id<ORSolutionPool> sp = [cpprogram solutionPool];
   [cpprogram onSolution:^{
      id<ORSolution> s = [cpprogram captureSolution];
//      NSLog(@"Found solution with value: %@",[s objectiveValue]);
      [sp addSolution: s];
      [s release];
   }];
   return cpprogram;
}

+(id<CPSemanticProgramDFS>) createCPSemanticProgramDFS: (id<ORModel>) model
{
   id<CPSemanticProgramDFS> cpprogram = [CPSolverFactory semanticSolverDFS];
   [ORFactory createCPProgram: model program: cpprogram];
   return cpprogram;
}

+(id<CPSemanticProgram>) createCPSemanticProgram: (id<ORModel>) model with: (Class) ctrlClass
{
   id<CPSemanticProgram> cpprogram = [CPSolverFactory semanticSolver: ctrlClass];
   [ORFactory createCPProgram: model program: cpprogram];
   return cpprogram;
}

+(void) createCPOneProgram: (id<ORModel>) model multistartprogram: (CPMultiStartSolver*) cpprogram nb: (ORInt) i
{
   [NSThread setThreadID: i];
   id<CPProgram> cp = [cpprogram at: i];
   [ORFactory createCPProgram: model program: cp];
}

+(id<CPProgram>) createCPMultiStartProgram: (id<ORModel>) model nb: (ORInt) k
{
   CPMultiStartSolver* cpprogram = [[CPMultiStartSolver alloc] initCPMultiStartSolver: k];
   [model setImpl: cpprogram];
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:model];
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   [flat apply: model into: batch];
   [batch release];
   
   NSArray* objects = [flatModel objects];
   for(id<ORObject> c in objects) {
      if ([c impl] == NULL) {
         id<ORBindingArray> ba = [ORFactory bindingArray: flatModel nb: k];
         [c setImpl: ba];
      }
   }
   for(ORInt i = 0; i < k; i++) {
      // This "fakes" the thread number so that the main thread does add into the binding array at offset i
      [NSThread setThreadID: i];
      id<CPProgram> cp = [cpprogram at: i];
      [ORFactory createCPProgram: flatModel program: cp];
      id<ORSolutionPool> lp = [cp solutionPool];
      id<ORSolutionPool> gp = [cpprogram globalSolutionPool];
      [cp onSolution: ^{
         id<ORSolution> s = [model captureSolution];
         [lp addSolution: s];
         @synchronized(gp) {
            [gp addSolution: s];
         }
         id<ORSearchObjectiveFunction> objective = [cp objective];
         if (objective != NULL) {
            id<ORObjectiveValue> myBound = [objective primalBound];
            for(ORInt w=0;w < k;w++) {
               if (w == i) continue;
               id<ORSearchObjectiveFunction> wwObj = [[cpprogram at:w] objective];
               [wwObj tightenPrimalBound: myBound];
               //NSLog(@"TIGHT: %@  -- thread %d",wwObj,[NSThread threadID]);
            }
            [myBound release];
         }
         [s release];
      }];
   }
   return cpprogram;
}

+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k with: (Class) ctrlClass
{
   CPParSolverI* cpprogram = [[CPParSolverI alloc] initParSolver:k withController:ctrlClass];
   [model setImpl:cpprogram];
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:model];
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   [flat apply: model into: batch];
   [batch release];
   for(id<ORObject> c in [flatModel objects]) {
      if ([c impl] == NULL) {
         id<ORBindingArray> ba = [ORFactory bindingArray: flatModel nb: k];
         [c setImpl: ba];
      }
   }
   id<ORSolutionPool> global = [cpprogram globalSolutionPool];
   for(ORInt i=0;i< k;i++) {
      [NSThread setThreadID:i];
      id<CPProgram> pi = [cpprogram dereference];
      [pi onSolution:^{
         [[pi solutionPool] addSolution:[model captureSolution]];
      }];
      [ORFactory createCPProgram:flatModel program: pi]; // [ldm] it is already flat. This flattens _again_
   }
   [cpprogram onSolution: ^ {
      id<ORSolution> s = [model captureSolution];
      @synchronized(global) {
         [global addSolution:s];
      }
   }];
   return cpprogram;
}

+(void) createLPProgram: (id<ORModel>) model program: (id<LPProgram>) lpprogram
{
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:model];
   id<ORModelTransformation> flattener = [ORFactory createLPFlattener];
   [flattener apply: model into:batch];
   [batch release];
   
   id<ORVisitor> concretizer = [[ORLPConcretizer alloc] initORLPConcretizer: lpprogram];
   [flatModel visit: concretizer];
   [concretizer release];
   //NSLog(@"flat: %@",flatModel);
}

+(id<LPProgram>) createLPProgram: (id<ORModel>) model
{
   id<LPProgram> lpprogram = [LPSolverFactory solver: model];
   [model setImpl: lpprogram];
   [self createLPProgram: model program: lpprogram];
   return lpprogram;
}

+(void) createMIPProgram: (id<ORModel>) model program: (id<MIPProgram>) mipprogram
{
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source: model];
   id<ORModelTransformation> flattener = [ORFactory createMIPFlattener];
   [flattener apply: model into:batch];
   [batch release];
   
   id<ORVisitor> concretizer = [[ORMIPConcretizer alloc] initORMIPConcretizer: mipprogram];
   [flatModel visit: concretizer];
   [concretizer release];
   //NSLog(@"flat: %@",flatModel);
}

+(id<MIPProgram>) createMIPProgram: (id<ORModel>) model
{
   id<MIPProgram> mipprogram = [MIPSolverFactory solver: model];
   [model setImpl: mipprogram];
   [self createMIPProgram: model program: mipprogram];
   return mipprogram;
}

@end

