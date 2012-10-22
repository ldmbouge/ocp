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
#import "ORCPSolver.h"
#import "ORCPConcretizer.h"
#import "ORCPPoster.h"
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>


// PVH to factorize this

@implementation ORFactory (Concretization)

+(id<CPProgram>) createCPCommonProgram: (Class) ctrlClass
{
   return [[ORCPSolver alloc] initORCPSemanticSolver: ctrlClass];
}


+(id<CPProgram>) createCPProgram: (id<ORModel>) model checkpointing: (BOOL) checkpointing
{
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   id<ORModel> flatModel = [flat apply: model];

   id<CPProgram> cpprogram;
   if (!checkpointing)
      cpprogram = [[ORCPSolver alloc] initORCPSolver];
   else
      cpprogram = [[ORCPSolver alloc] initORCPSolverCheckpointing];

   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   [flatModel visit: concretizer];
   [concretizer release];
   NSLog(@"FLAT: %@",flatModel);
   
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
   return [ORFactory createCPProgram: model checkpointing: false];
}

+(id<CPProgram>) createCPCheckpointingProgram: (id<ORModel>) model
{
   return [ORFactory createCPProgram: model checkpointing: true];
}

+(id<CPCommonProgram>) createCPProgram: (id<ORModel>) model with: (Class) ctrlClass
{
   id<ORModelTransformation> flat = [ORFactory createFlattener];
   id<ORModel> flatModel = [flat apply: model];
   
   id<CPProgram> cpprogram = [ORFactory createCPCommonProgram: ctrlClass];
   
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

