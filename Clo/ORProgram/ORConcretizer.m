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
#import <ORModeling/ORModelI.h>
#import <ORProgram/CPFirstFail.h>
#import <objcp/CPFactory.h>
#import "ORFlatten.h"
#import "ORConcretizer.h"
#import "CPSolver.h"
#import "CPConcretizer.h"
#import "CPPoster.h"
#import "CPDDeg.h"
#import "CPWDeg.h"
#import "CPIBS.h"
#import "CPABS.h"

// PVH to factorize this

@implementation ORFactory (Concretization)

+(id<CPHeuristic>) createFF: (id<CPProgram>) cp restricted: (id<ORVarArray>) rvars
{
   return [[CPFirstFail alloc] initCPFirstFail:cp restricted:rvars];
}
+(id<CPHeuristic>) createFF: (id<CPProgram>)cp
{
   return [[CPFirstFail alloc] initCPFirstFail:cp restricted:nil];
}
+(id<CPHeuristic>) createWDeg: (id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
{
   return [[CPWDeg alloc] initCPWDeg:cp restricted:rvars];
}
+(id<CPHeuristic>) createDDeg: (id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
{
   return [[CPDDeg alloc] initCPDDeg:cp restricted:rvars];
}
+(id<CPHeuristic>) createIBS: (id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
{
   return [[CPIBS alloc] initCPIBS:cp restricted:rvars];
}
+(id<CPHeuristic>) createABS: (id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
{
   return [[CPABS alloc] initCPABS:cp restricted:rvars];
}
+(id<CPHeuristic>) createWDeg: (id<CPProgram>)cp;
{
   return [[CPWDeg alloc] initCPWDeg:cp restricted:nil];
}
+(id<CPHeuristic>) createDDeg: (id<CPProgram>)cp
{
   return [[CPDDeg alloc] initCPDDeg:cp restricted:nil];
}
+(id<CPHeuristic>) createIBS: (id<CPProgram>)cp
{
   return [[CPIBS alloc] initCPIBS:cp restricted:nil];
}
+(id<CPHeuristic>) createABS: (id<CPProgram>)cp
{
   return [[CPABS alloc] initCPABS:cp restricted:nil];
}

+(void) createCPProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram
{
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [[ORBatchModel alloc] init:flatModel];
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
   __block id<CPCommonProgram> recv = cpprogram;
   [cpprogram onSolution:^{
      id<ORSolution> s = [model solution];
      [[recv solutionPool] addSolution:s];
      NSLog(@"Got a solution: %@",s);
      [s release];
   }
    ];
   [cpprogram onExit:^{
      id<ORSolution> best = [[recv solutionPool] best];
      NSLog(@"onExit called: bestObjective(pool) = %@",[best objectiveValue]);
      [model restore:best];
      NSLog(@"onExit called: best(pool) = %p",best);
      [best release];
   }
    ];
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
   
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [[ORBatchModel alloc] init: flatModel];
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   [flat apply: model into: batch];
   [batch release];
   
   NSArray* Objects = [flatModel objects];
   for(id<ORObject> c in Objects) {
      if ([c impl] == NULL) {
         id<ORBindingArray> ba = [ORFactory bindingArray: flatModel nb: k];
         [c setImpl: ba];
      }
   }
   for(ORInt i = 0; i < k; i++) {
      [NSThread setThreadID: i];
      id<CPProgram> cp = [cpprogram at: i];
      [ORFactory createCPProgram: flatModel program: cp];
      __block id<CPCommonProgram> recv = cp;
 //     __block CPMultiStartSolver* mcp = cpprogram;
      id<ORSolutionPool> gp = [cpprogram globalSolutionPool];
      [cp onSolution: ^{
         id<ORSolution> s = [model solution];
         [[recv solutionPool] addSolution: s];
//         [[mcp globalSolutionPool] addSolution: s];
         [gp addSolution: s];
         NSLog(@"Got a solution: %@ in solver %d",s,i);
         [s release];
      }
      ];
   }
   return cpprogram;
}
@end

