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

// PVH to factorize this

@implementation ORFactory (Concretization)
+(void) createCPProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram
{
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel];
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   [flat apply: model into:batch];
   [batch release];
   
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   [flatModel visit: concretizer];
   [concretizer release];
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model
{
   id<CPProgram> cpprogram = [CPSolverFactory solver];
   [ORFactory createCPProgram: model program: cpprogram];
   [model setImpl: cpprogram];
   id<ORSolutionPool> sp = [cpprogram solutionPool];
   [cpprogram onSolution:^{
      id<ORSolution> s = [model captureSolution];
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
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel];
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
         [s release];
      }
      ];
   }
   return cpprogram;
}

+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k with: (Class) ctrlClass
{
   CPParSolverI* cpprogram = [[CPParSolverI alloc] initParSolver:k withController:ctrlClass];
   [model setImpl:cpprogram];
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel];
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
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel];
   id<ORModelTransformation> flat = [ORFactory createLPFlattener];
   [flat apply: model into:batch];
   [batch release];
   
   id<ORVisitor> concretizer = [[ORLPConcretizer alloc] initORLPConcretizer: lpprogram];
   [flatModel visit: concretizer];
   [concretizer release];
}

+(id<LPProgram>) createLPProgram: (id<ORModel>) model
{
   id<LPProgram> lpprogram = [LPSolverFactory solver];
   [model setImpl: lpprogram];
   [self createLPProgram: model program: lpprogram];
   return lpprogram;
}
@end

