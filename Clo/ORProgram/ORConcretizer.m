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


@implementation ORFactory (Concretization)

+(id<CPProgram>) createCPSolverWrapper
{
   return [[ORCPSolver alloc] initORCPSolver];
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model
{
   id<CPProgram> cpprogram = [ORFactory createCPSolverWrapper];

   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: cpprogram];
   [model visit: concretizer];
   [concretizer release];
   
   id<ORVisitor> poster = [[ORCPPoster alloc] initORCPPoster: cpprogram];
   [model visit: poster];
   [poster release];
   
   return cpprogram;
}
@end
