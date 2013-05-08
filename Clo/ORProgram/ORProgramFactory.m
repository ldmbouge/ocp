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

+(id<CPCommonProgram>)concretizeCP:(id<ORModel>)m program: (id<CPCommonProgram>) cpprogram
{
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   [m visit: concretizer];
   [concretizer release];
   [cpprogram setSource:m];
   return cpprogram;
}

+(void) createCPProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram
{
   NSLog(@"ORIG  %ld %ld %ld",[[model variables] count],[[model mutables] count],[[model constraints] count]);
   ORLong t0 = [ORRuntimeMonitor cputime];
   id<ORModel> fm = [model flatten];
   fm = [fm flatten];
   //NSLog(@"FC: %@",[fm constraints]);
   
   ORUInt nbEntries =  [fm nbObjects];
   NSLog(@"nbEntries: %u",nbEntries);
   
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [cpprogram setGamma: gamma];
   
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   
   for(id<ORObject> c in [fm mutables])
      [c visit: concretizer];
   
   [cpprogram setSource:model];
   [concretizer release];
   ORLong t1 = [ORRuntimeMonitor cputime];
   NSLog(@"FLAT  %ld %ld %ld %lld",[[fm variables] count],[[fm mutables] count],[[fm constraints] count],t1 - t0);
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model
{
   id<CPProgram> cpprogram = [CPSolverFactory solver];
   [ORFactory createCPProgram: model program: cpprogram];
   [model setImpl: cpprogram];
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
   [model setImpl: cpprogram];
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:model];
   id<ORModelTransformation> flat = [ORFactory createFlattener:batch];
   [flat apply: model];
   [batch release];
   
   for(ORInt i = 0; i < k; i++) {
      // This "fakes" the thread number so that the main thread does add into the binding array at offset i
      [NSThread setThreadID: i];
      id<CPProgram> cp = [cpprogram at: i];
      // if you use this line, this is buggy
      //[ORFactory createCPProgram: flatModel program: cp];
      [ORFactory createCPProgram: model program: cp];
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
   [model setImpl:cpprogram];
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:model];
   id<ORModelTransformation> flat = [ORFactory createFlattener:batch];
   [flat apply: model];
   [batch release];
   for(id<ORObject> c in [flatModel mutables]) {
      if ([c impl] == NULL) {
         id<ORBindingArray> ba = [ORFactory bindingArray: flatModel nb: k];
         [c setImpl: ba];
      }
   }
   for(id<ORObject> c in [flatModel constraints]) {
      if ([c impl] == NULL) {
         id<ORBindingArray> ba = [ORFactory bindingArray: flatModel nb: k];
         [c setImpl: ba];
      }
   }
   
   id<ORSolutionPool> global = [cpprogram solutionPool];
   for(ORInt i=0;i< k;i++) {
      [NSThread setThreadID:i];
      id<CPProgram> pi = [cpprogram dereference];
      [pi onSolution:^{
         id<ORCPSolution> sol = [pi captureSolution];
         [[pi solutionPool] addSolution: sol];
         @synchronized(global) {
            [global addSolution:sol];
         }
      }];
      [ORFactory concretizeCP:flatModel program:pi];
   }
   return cpprogram;
}

+(void) createLPProgram: (id<ORModel>) model program: (id<LPProgram>) lpprogram
{
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:model];
   id<ORModelTransformation> flattener = [ORFactory createLPFlattener:batch];
   [flattener apply: model];
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
   id<ORModelTransformation> flattener = [ORFactory createMIPFlattener:batch];
   [flattener apply: model];
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

/*
_map  = [[NSMapTable alloc] initWithKeyOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                  valueOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                      capacity:32];
return self;
}
-(void)dealloc
{
   [_map release];
   [super dealloc];
}
-(id<ORAddToModel>)target
{
   return _into;
}
-(id)copyOnce:(id)obj
{
   id copy = [_map objectForKey:obj];

*/
