/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>

#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>

// LP Solver
#import "LPSolver.h"
#import "LPConcretizer.h"

// MIP Solver
#import "MIPSolver.h"
#import "MIPConcretizer.h"

// PVH to factorize this

@implementation ORGamma (Model)
-(void) initialize: (id<ORModel>) model
{
   _mappings = model.modelMappings;
}
@end


@implementation ORFactory (Concretization)
+(id<ORSolution>) solution: (id<ORModel>) m solver: (id<ORASolver>) solver
{
   return [[ORSolution alloc] initORSolution: m with: solver];
}
+(id<ORSolution>) parameterizedSolution: (id<ORParameterizedModel>) m solver: (id<ORASolver>) solver
{
   return [[ORParameterizedSolution alloc] initORParameterizedSolution: m with: solver];
}
+(id<ORSolutionPool>) createSolutionPool
{
   return [[ORSolutionPool alloc] init];
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model
{
   id<ORAnnotation> notes = [ORFactory annotation];
   id<CPProgram> program = [self createCPProgram:model annotation:notes];
   [notes release];
   return program;
}
+(id<CPProgram>) createCPSemanticProgramDFS: (id<ORModel>) model
{
   id<ORAnnotation> notes = [ORFactory annotation];
   id<CPProgram> program = [self createCPSemanticProgramDFS:model annotation:notes];
   [notes release];
   return program;
}
+(id<CPProgram>) createCPSemanticProgram: (id<ORModel>) model with: (id<ORSearchController>) ctrlClass
{
   id<ORAnnotation> notes = [ORFactory annotation];
   id<CPProgram> program = [self createCPSemanticProgram:model annotation:notes with:ctrlClass];
   [notes release];
   return program;
}
+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k with: (id<ORSearchController>) ctrlClass
{
   id<ORAnnotation> notes = [ORFactory annotation];
   id<CPProgram> program = [self createCPParProgram:model nb:k annotation:notes with:ctrlClass];
   [notes release];
   return program;
}


+(id<CPCommonProgram>) concretizeCP: (id<ORModel>) m program: (id<CPCommonProgram>) cpprogram annotation:(id<ORAnnotation>)notes
{
   ORUInt nbEntries =  [m nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [cpprogram setGamma: gamma];
   [cpprogram setModelMappings:[m modelMappings]];
   ORVisitor* concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram annotation:notes];
   for(id<ORObject> c in [m mutables])
      [c visit: concretizer];
   for(id<ORConstraint> c in [m constraints]) {
      ORCLevel n = [notes levelFor: c];
      if (n != RelaxedConsistency)
         [c visit: concretizer];
   }
   [[m objective] visit:concretizer];
   
   [concretizer release];
   [cpprogram setSource:m];
   return cpprogram;
}

+(void) createCPProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram annotation:(id<ORAnnotation>)notes
{
   //   NSLog(@"ORIG  %ld %ld %ld",[[model variables] count],[[model mutables] count],[[model constraints] count]);
   id<ORAnnotation> ncpy   = [notes copy];
   id<ORModel> fm = [model flatten: ncpy];   // models are AUTORELEASE
   [self concretizeCP:fm program:cpprogram annotation:ncpy];
   [ncpy release];
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model annotation:(id<ORAnnotation>)notes
{
   __block id<CPProgram> cpprogram = [CPSolverFactory solver];
   [ORFactory createCPProgram: model program: cpprogram annotation:notes];
   id<ORSolutionPool> sp = [cpprogram solutionPool];
   [cpprogram onSolution:^{
      id<ORSolution> s = [cpprogram captureSolution];
      //NSLog(@"Found solution with value: %@",[s objectiveValue]);
      [sp addSolution: s];
      [s release];
   }];
   return cpprogram;
}


+(id<CPProgram>) createCPSemanticProgramDFS: (id<ORModel>) model annotation:(id<ORAnnotation>)notes
{
   id<CPProgram> cpprogram = (id)[CPSolverFactory semanticSolverDFS];
   [ORFactory createCPProgram: model program: cpprogram annotation:notes];
   return cpprogram;
}

+(id<CPProgram>) createCPSemanticProgram: (id<ORModel>) model annotation:(id<ORAnnotation>)notes with: (id<ORSearchController>) ctrlProto
{
   id<CPProgram> cpprogram = (id)[CPSolverFactory semanticSolver: ctrlProto];
   [ORFactory createCPProgram: model program: cpprogram annotation:notes];
   return cpprogram;
}

+(void) createCPOneProgram: (id<ORModel>) model multistartprogram: (CPMultiStartSolver*) cpprogram nb: (ORInt) i annotation:(id<ORAnnotation>)notes
{
   [NSThread setThreadID: i];
   id<CPProgram> cp = [cpprogram at: i];
   [ORFactory createCPProgram: model program: cp annotation:notes];
}

+(id<CPProgram>) createCPMultiStartProgram: (id<ORModel>) model nb: (ORInt) k annotation:(id<ORAnnotation>)notes
{
   CPMultiStartSolver* cpprogram = [[CPMultiStartSolver alloc] initCPMultiStartSolver: k];
   id<ORAnnotation> ncpy = [notes copy];
   id<ORModel> flatModel = [model flatten:ncpy];
   
   for(ORInt i = 0; i < k; i++) {
      // This "fakes" the thread number so that the main thread does add into the binding array at offset i
      [NSThread setThreadID: i];
      id<CPProgram> cp = [cpprogram at: i];
      [ORFactory concretizeCP: flatModel program: cp annotation:ncpy];
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
   [ncpy release];
   return cpprogram;
}

+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k annotation:(id<ORAnnotation>)notes with: (id<ORSearchController>) ctrlProto
{
   CPParSolverI* cpprogram = [[CPParSolverI alloc] initParSolver:k withController:ctrlProto];
   id<ORAnnotation> ncpy = [notes copy];
   id<ORModel> flatModel = [model flatten:ncpy];
   id<ORSolutionPool> global = [cpprogram solutionPool];
#if defined(__APPLE__)
   dispatch_queue_t q = dispatch_queue_create("ocp.par", DISPATCH_QUEUE_CONCURRENT);
   dispatch_group_t group = dispatch_group_create();
#endif
   for(ORInt i=0;i< k;i++) {
#if defined(__APPLE__)
      dispatch_group_async(group,q, ^{
#endif
         [NSThread setThreadID:i];
         id<CPCommonProgram> pi = [cpprogram worker];
         [ORFactory concretizeCP:flatModel program:pi annotation:ncpy];
         [pi onSolution:^{
            id<ORSolution> sol = [[cpprogram worker] captureSolution];
            [[[cpprogram worker] solutionPool] addSolution: sol];
            @synchronized(global) {
               [global addSolution:sol];
            }
         }];
#if defined(__APPLE__)
      });
#endif
   }
#if defined(__APPLE__)
   dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
   dispatch_release(q);
   dispatch_release(group);
#endif
   [ncpy release];
   return cpprogram;
}

+(void) createLPProgram: (id<ORModel>) model program: (id<LPProgram>) lpprogram
{
   NSLog(@"inside createLPProgram:");
   id<ORModel> flatModel = [model lpflatten:nil];
   
   ORUInt nbEntries =  [flatModel nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [lpprogram setGamma: gamma];
   [lpprogram setModelMappings: flatModel.modelMappings];
   
   ORVisitor* concretizer = [[ORLPConcretizer alloc] initORLPConcretizer: lpprogram];
   
   for(id<ORObject> c in [flatModel mutables])
      [c visit: concretizer];
   for(id<ORObject> c in [flatModel constraints])
      [c visit: concretizer];
   [[flatModel objective] visit:concretizer];
   [concretizer release];
   //NSLog(@"flat: %@",flatModel);
}

+(id<LPProgram>) createLPProgram: (id<ORModel>) model
{
   id<LPProgram> lpprogram = [LPSolverFactory solver: model];
   [self createLPProgram: model program: lpprogram];
   return lpprogram;
}

+(void) createLPRelaxation: (id<ORModel>) model program: (id<LPRelaxation>) lpprogram
{
   id<ORModel> flatModel = [model lpflatten:nil];
   
   ORUInt nbEntries =  [flatModel nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [lpprogram setGamma: gamma];
   [lpprogram setModelMappings: flatModel.modelMappings];
   
   ORVisitor* concretizer = [[ORLPRelaxationConcretizer alloc] initORLPRelaxationConcretizer: lpprogram];
   
   for(id<ORObject> c in [flatModel mutables])
      [c visit: concretizer];
   for(id<ORObject> c in [flatModel constraints])
      [c visit: concretizer];
   [[flatModel objective] visit:concretizer];
   [concretizer release];
}

+(id<LPRelaxation>) createLPRelaxation: (id<ORModel>) model
{
   id<LPRelaxation> lpprogram = [LPSolverFactory relaxation: model];
   [self createLPRelaxation: model program: lpprogram];
   return lpprogram;
}

+(void) createMIPProgram: (id<ORModel>) model program: (id<MIPProgram>) mipprogram
{
   id<ORModel> flatModel = [model mipflatten:nil];
   
   ORUInt nbEntries =  [flatModel nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [mipprogram setGamma: gamma];
   [mipprogram setModelMappings: flatModel.modelMappings];
   
   ORVisitor* concretizer = [[ORMIPConcretizer alloc] initORMIPConcretizer: mipprogram];
   
   for(id<ORObject> c in [flatModel mutables])
      [c visit: concretizer];
   for(id<ORObject> c in [flatModel constraints])
      [c visit: concretizer];
   [[flatModel objective] visit:concretizer];
   
   //[mipprogram setSource:model];  // [ldm] missing API
   [concretizer release];
   //NSLog(@"flat: %@",flatModel);
}

+(id<MIPProgram>) createMIPProgram: (id<ORModel>) model
{
   id<MIPProgram> mipprogram = [MIPSolverFactory solver: model];
   [self createMIPProgram: model program: mipprogram];
   return mipprogram;
}


+(void) createCPLinearizedProgram: (id<ORModel>) model program: (id<CPCommonProgram>) cpprogram annotation:(id<ORAnnotation>)notes
{
   id<ORAnnotation> ncpy = [notes copy];
   id<ORModel> fm = [model flatten:ncpy];
   id<ORModel> lfm = [[ORMIPLinearize linearize: fm] flatten:ncpy];
   
   ORUInt nbEntries =  [lfm nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [cpprogram setGamma: gamma];
   ORVisitor* concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram annotation:ncpy];
   
   for(id<ORObject> c in [lfm mutables])
      [c visit: concretizer];
   for(id<ORObject> c in [lfm constraints])
      [c visit: concretizer];
   [[fm objective] visit:concretizer];
   
   [cpprogram setSource:model];
   [concretizer release];
   [ncpy release];
}



+(id<CPProgram>) createCPLinearizedProgram: (id<ORModel>) model annotation:(id<ORAnnotation>)notes
{
   id<CPProgram> cpprogram = [CPSolverFactory solver];
   [ORFactory createCPLinearizedProgram: model program: cpprogram annotation:notes];
   id<ORSolutionPool> sp = [cpprogram solutionPool];
   [cpprogram onSolution:^{
      id<ORSolution> s = [cpprogram captureSolution];
      //NSLog(@"Found solution with value: %@",[s objectiveValue]);
      [sp addSolution: s];
      [s release];
   }];
   return cpprogram;
}
+(id<ORRelaxation>) createLinearRelaxation: (id<ORModel>) model
{
   return [[ORLinearRelaxation alloc] initLinearRelaxation:model];
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model withRelaxation: (id<ORRelaxation>) relaxation
{
   id<ORAnnotation> notes = [ORFactory annotation];
   id<CPProgram> program = [self createCPProgram: model withRelaxation: relaxation annotation: notes];
   [notes release];
   return program;
}
+(id<CPProgram>) createCPProgram: (id<ORModel>) model withRelaxation: (id<ORRelaxation>) relaxation annotation:(id<ORAnnotation>)notes
{
   __block id<CPProgram> cpprogram = [CPSolverFactory solver];
   [ORFactory createCPProgram: model program: cpprogram annotation:notes];
   id<ORSolutionPool> sp = [cpprogram solutionPool];
   
   NSArray* mv = [model variables];
   NSMutableArray* cv = [[NSMutableArray alloc] init];
   id* gamma = [cpprogram gamma];
   for(id<ORVar> v in mv)
      [cv addObject: gamma[v.getId]];
   
   NSLog(@"Model variables %@",mv);
   NSLog(@"Concrete variables %@",cv);
   id<CPEngine> engine = [(CPSolver*) cpprogram engine];
   
   [engine add: [CPFactory relaxation: mv var: cv relaxation: relaxation]];
   [cpprogram onSolution:^{
      id<ORSolution> s = [cpprogram captureSolution];
      //NSLog(@"Found solution with value: %@",[s objectiveValue]);
      [sp addSolution: s];
      [s release];
   }];
   return cpprogram;
}

@end

@implementation ORLinearRelaxation
{
   id<ORModel> _model;
   id<LPRelaxation> _lprelaxation;
}
-(ORLinearRelaxation*) initLinearRelaxation: (id<ORModel>) m
{
   self = [super init];
   _model = m;
   _lprelaxation = [ORFactory createLPRelaxation: _model];
   return self;
}
-(ORDouble) objective
{
   return [_lprelaxation objective];
}
-(ORDouble) value: (id<ORVar>) x
{
   return [_lprelaxation doubleValue: x];
}
-(ORDouble) lowerBound: (id<ORVar>) x
{
   return [_lprelaxation lowerBound: x];
}
-(ORDouble) upperBound: (id<ORVar>) x
{
   return [_lprelaxation upperBound: x];
}
-(void) updateLowerBound: (id<ORVar>) x with: (ORDouble) f
{
   [_lprelaxation updateLowerBound: x with:f];
}
-(void) updateUpperBound: (id<ORVar>) x with: (ORDouble) f
{
   [_lprelaxation updateUpperBound: x with:f];
}
-(void) close
{
   return [_lprelaxation close];
}
-(OROutcome) solve
{
   return [_lprelaxation solve];
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [_lprelaxation objectiveValue];
}
@end

