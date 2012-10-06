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
#import <ORModeling/ORModeling.h>


@implementation ORFactory (Concretization)

+(id<CPProgram>) createCPSolverWrapper: (id<CPSolver>) concreteCPSolver
{
   return [[ORCPSolver alloc] initORCPSolver: concreteCPSolver];
}

+(id<CPProgram>) createCPProgram: (id<ORModel>) model
{
   id<CPSolver> concreteCPSolver = [CPFactory createSolver];
   id<CPProgram> wrapperCPSolver = [ORFactory createCPSolverWrapper: concreteCPSolver];
   id<ORVisitor> concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: concreteCPSolver];
   [model visit: concretizer];
   return wrapperCPSolver;
}
@end
