/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPFactory.h>
#import "ORConcretizer.h"
#import "CPSolver.h"
#import "CPConcretizer.h"
#import "CPPoster.h"
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/CPFirstFail.h>
#import <ORProgram/CPDDeg.h>
#import <ORProgram/CPWDeg.h>
#import <ORProgram/CPIBS.h>
#import <ORProgram/CPABS.h>


// PVH to factorize this

@implementation ORFactory (Concretization)

+(id<CPHeuristic>)createFF:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars
{
   return [[CPFirstFail alloc] initCPFirstFail:cp restricted:rvars];
}
+(id<CPHeuristic>)createFF:(id<CPProgram>)cp
{
   return [[CPFirstFail alloc] initCPFirstFail:cp restricted:nil];
}
+(id<CPHeuristic>) createWDeg:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
{
   return [[CPWDeg alloc] initCPWDeg:cp restricted:rvars];
}
+(id<CPHeuristic>) createDDeg:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
{
   return [[CPDDeg alloc] initCPDDeg:cp restricted:rvars];
}
+(id<CPHeuristic>) createIBS:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
{
   return [[CPIBS alloc] initCPIBS:cp restricted:rvars];
}
+(id<CPHeuristic>) createABS:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
{
   return [[CPABS alloc] initCPABS:cp restricted:rvars];
}
+(id<CPHeuristic>) createWDeg:(id<CPProgram>)cp;
{
   return [[CPWDeg alloc] initCPWDeg:cp restricted:nil];
}
+(id<CPHeuristic>) createDDeg:(id<CPProgram>)cp
{
   return [[CPDDeg alloc] initCPDDeg:cp restricted:nil];
}
+(id<CPHeuristic>) createIBS:(id<CPProgram>)cp
{
   return [[CPIBS alloc] initCPIBS:cp restricted:nil];
}
+(id<CPHeuristic>) createABS:(id<CPProgram>)cp
{
   return [[CPABS alloc] initCPABS:cp restricted:nil];
}

+(id<CPCommonProgram>) createCPProgram: (id<ORModel>) model checkpointing: (BOOL) checkpointing
{
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   id<ORModel> flatModel = [flat apply: model];

   id<CPCommonProgram> cpprogram;
   if (!checkpointing)
      cpprogram = [CPSolverFactory solver];
   else
      cpprogram = [CPSolverFactory semanticSolverDFS];

   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   [flatModel visit: concretizer];
   [concretizer release];
   //NSLog(@"FLAT: %@",flatModel);
   
   id<ORVisitor> poster = [[ORCPPoster alloc] initORCPPoster: cpprogram];
   NSArray* Constraints = [flatModel constraints];
   id<ORObjectiveFunction> obj = [flatModel objective];
   for(id<ORObject> c in Constraints)
      [c visit: poster];
   [obj visit: poster];
   [poster release];
   
   return cpprogram;
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model
{
//   return [CPSolverFactory solver];
   return (id<CPProgram>) [ORFactory createCPProgram: model checkpointing:false];
}

+(id<CPCommonProgram>) createCPCheckpointingProgram: (id<ORModel>) model
{
//   return [CPSolverFactory checkpointingSolver];
   return (id<CPProgram>) [ORFactory createCPProgram: model checkpointing:true];
}

+(id<CPSemanticProgram>) createCPProgram: (id<ORModel>) model with: (Class) ctrlClass
{
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   id<ORModel> flatModel = [flat apply: model];
   
   id<CPSemanticProgram> cpprogram = [CPSolverFactory semanticSolver: ctrlClass];
   
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   [flatModel visit: concretizer];
   [concretizer release];
   
   id<ORVisitor> poster = [[ORCPPoster alloc] initORCPPoster: cpprogram];
   NSArray* Constraints = [flatModel constraints];
   id<ORObjectiveFunction> obj = [flatModel objective];
   for(id<ORObject> c in Constraints)
      [c visit: poster];
   [obj visit: poster];
   [poster release];
   
   return cpprogram;
}
@end

