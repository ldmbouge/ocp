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
#import <ORModeling/ORMIPLinearize.h>
#import "ORProgramFactory.h"

// CP Solver
#import <ORProgram/ORProgram.h>
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
#import "CPBitVarABS.h"
#import "CPBitVarIBS.h"
// LP Solver
#import "LPProgram.h"
#import "LPSolver.h"
#import "LPConcretizer.h"

// MIP Solver
#import "MIPProgram.h"
#import "MIPSolver.h"
#import "MIPConcretizer.h"

// PVH to factorize this

@implementation ORGamma (Model)
-(void) initialize: (id<ORModel>) model
{
   _mappings = model.mappings;
}
@end


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

+(id<CPCommonProgram>) concretizeCP: (id<ORModel>) m program: (id<CPCommonProgram>) cpprogram
{
   ORUInt nbEntries =  [m nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [cpprogram setGamma: gamma];
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   for(id<ORObject> c in [m mutables])
      [c visit: concretizer];
   for(id<ORObject> c in [m constraints])
      [c visit: concretizer];
   [[m objective] visit:concretizer];
   
   [concretizer release];
   [cpprogram setSource:m];
   return cpprogram;
}

+(void) createCPProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram
{
//   NSLog(@"ORIG  %ld %ld %ld",[[model variables] count],[[model mutables] count],[[model constraints] count]);
//   ORLong t0 = [ORRuntimeMonitor cputime];
   id<ORModel> fm = [model flatten];   // models are AUTORELEASE
   ORUInt nbEntries =  [fm nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [cpprogram setGamma: gamma];

   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   for(id<ORObject> c in [fm mutables])
      [c visit: concretizer];
   for(id<ORObject> c in [fm constraints])
      [c visit: concretizer];
   [[fm objective] visit:concretizer];
   [cpprogram setSource:fm];
   [concretizer release];
//   ORLong t1 = [ORRuntimeMonitor cputime];
//   NSLog(@"FLAT  %ld %ld %ld %lld",[[fm variables] count],[[fm mutables] count],[[fm constraints] count],t1 - t0);
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model
{
   __block id<CPProgram> cpprogram = [CPSolverFactory solver];
   [ORFactory createCPProgram: model program: cpprogram];
   id<ORSolutionPool> sp = [cpprogram solutionPool];
   [cpprogram onSolution:^{
      id<ORSolution> s = [cpprogram captureSolution];
      //NSLog(@"Found solution with value: %@",[s objectiveValue]);
      [sp addSolution: s];
      [s release];
   }];
   return cpprogram;
}


+(id<CPProgram>) createCPSemanticProgramDFS: (id<ORModel>) model
{
   id<CPProgram> cpprogram = (id)[CPSolverFactory semanticSolverDFS];
   [ORFactory createCPProgram: model program: cpprogram];
   return cpprogram;
}

+(id<CPProgram>) createCPSemanticProgram: (id<ORModel>) model with: (Class) ctrlClass
{
   id<CPProgram> cpprogram = (id)[CPSolverFactory semanticSolver: ctrlClass];
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
   id<ORModel> flatModel = [model flatten];
   
   for(ORInt i = 0; i < k; i++) {
      // This "fakes" the thread number so that the main thread does add into the binding array at offset i
      [NSThread setThreadID: i];
      id<CPProgram> cp = [cpprogram at: i];
      [ORFactory concretizeCP: flatModel program: cp];
      id<ORSolutionPool> lp = [cp solutionPool];
      id<ORSolutionPool> gp = [cpprogram solutionPool];
      [cp onSolution: ^{
         id<ORSolution> s = [cp captureSolution];
         [lp addSolution: s];
         @synchronized(gp) {
//            NSLog(@"Adding a global solution with cost %@",[s objectiveValue]);
//            NSLog(@"Solution %@",s);
            [gp addSolution: s];
         }
//         id<ORSearchObjectiveFunction> objective = [cp objective];
//         if (objective != NULL) {
//            id<ORObjectiveValue> myBound = [objective primalBound];
//            for(ORInt w=0;w < k;w++) {
//               if (w == i) continue;
//               id<ORSearchObjectiveFunction> wwObj = [[cpprogram at:w] objective];
//               [wwObj tightenPrimalBound: myBound];
//               //NSLog(@"TIGHT: %@  -- thread %d",wwObj,[NSThread threadID]);
//            }
//            [myBound release];
//         }
         [s release];
      }];
   }
   return cpprogram;
}

+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k with: (Class) ctrlClass
{
   CPParSolverI* cpprogram = [[CPParSolverI alloc] initParSolver:k withController:ctrlClass];
   id<ORModel> flatModel = [model flatten];   
   id<ORSolutionPool> global = [cpprogram solutionPool];
   dispatch_queue_t q = dispatch_queue_create("ocp.par", DISPATCH_QUEUE_CONCURRENT);
   dispatch_group_t group = dispatch_group_create();
   for(ORInt i=0;i< k;i++) {
      dispatch_group_async(group,q, ^{
         [NSThread setThreadID:i];
         id<CPCommonProgram> pi = [cpprogram worker];
         [ORFactory concretizeCP:flatModel program:pi];
         [pi onSolution:^{
            id<ORCPSolution> sol = [[cpprogram worker] captureSolution];
            [[[cpprogram worker] solutionPool] addSolution: sol];
            @synchronized(global) {
               [global addSolution:sol];
            }
         }];
      });
   }
   dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
   dispatch_release(q);
   dispatch_release(group);
   return cpprogram;
}

+(void) createLPProgram: (id<ORModel>) model program: (id<LPProgram>) lpprogram
{
   id<ORModel> flatModel = [model lpflatten];
//   id<ORModel> flatModel = [ORFactory createModel: [model nbObjects] tau: model.tau];
//   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:model];
//   id<ORModelTransformation> flattener = [ORFactory createLPFlattener:batch];
//   [flattener apply: model];
//   [batch release];
//   NSLog(@"model is %@",flatModel);
   
   ORUInt nbEntries =  [flatModel nbObjects];
//   NSLog(@" NbEntries: %d",nbEntries);
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [lpprogram setGamma: gamma];
   [lpprogram setTau: model.tau];
 
   id<ORVisitor> concretizer = [[ORLPConcretizer alloc] initORLPConcretizer: lpprogram];

   for(id<ORObject> c in [flatModel mutables])
      [c visit: concretizer];   
   [concretizer release];
   //NSLog(@"flat: %@",flatModel);
}

+(id<LPProgram>) createLPProgram: (id<ORModel>) model
{
   id<LPProgram> lpprogram = [LPSolverFactory solver: model];
   [self createLPProgram: model program: lpprogram];
   return lpprogram;
}

+(void) createMIPProgram: (id<ORModel>) model program: (id<MIPProgram>) mipprogram
{
//   id<ORModel> flatModel = [ORFactory createModel: [model nbObjects] tau: model.tau];
//   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source: model];
//   id<ORModelTransformation> flattener = [ORFactory createMIPFlattener:batch];
//   [flattener apply: model];
//   [batch release];
   
   id<ORModel> flatModel = [model mipflatten];
   
   ORUInt nbEntries =  [flatModel nbObjects];
//   NSLog(@" NbEntries: %d",nbEntries);
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [mipprogram setGamma: gamma];
   [mipprogram setTau: model.tau];
   
   id<ORVisitor> concretizer = [[ORMIPConcretizer alloc] initORMIPConcretizer: mipprogram];
  
   for(id<ORObject> c in [flatModel mutables])
      [c visit: concretizer];
   [concretizer release];
   //NSLog(@"flat: %@",flatModel);
}

+(id<MIPProgram>) createMIPProgram: (id<ORModel>) model
{
   id<MIPProgram> mipprogram = [MIPSolverFactory solver: model];
   [self createMIPProgram: model program: mipprogram];
   return mipprogram;
}


+(void) createCPLinearizedProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram
{
   id<ORModel> fm = [model flatten];
   id<ORModel> lfm = [[ORMIPLinearize linearize: fm] flatten];
   
   ORUInt nbEntries =  [lfm nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [cpprogram setGamma: gamma];
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];

   for(id<ORObject> c in [lfm mutables])
      [c visit: concretizer];
   for(id<ORObject> c in [lfm constraints])
      [c visit: concretizer];
   [[fm objective] visit:concretizer];
   
   [cpprogram setSource:model];
   [concretizer release];
}



+(id<CPProgram>) createCPLinearizedProgram: (id<ORModel>) model
{
   id<CPProgram> cpprogram = [CPSolverFactory solver];
   [ORFactory createCPLinearizedProgram: model program: cpprogram];
   id<ORSolutionPool> sp = [cpprogram solutionPool];
   [cpprogram onSolution:^{
      id<ORSolution> s = [cpprogram captureSolution];
      //NSLog(@"Found solution with value: %@",[s objectiveValue]);
      [sp addSolution: s];
      [s release];
   }];
   return cpprogram;
}

@end
