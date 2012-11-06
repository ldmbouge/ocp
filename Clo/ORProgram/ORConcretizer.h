/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORModeling.h"
#import "CPSolver.h"

@interface ORFactory (Concretization)
+(id<CPProgram>) createCPProgram: (id<ORModel>) model;
+(id<CPSemanticProgramDFS>) createCPSemanticProgramDFS: (id<ORModel>) model;
+(id<CPSemanticProgram>) createCPSemanticProgram: (id<ORModel>) model with: (Class) ctrlClass;

+(id<CPHeuristic>) createFF:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createWDeg:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createDDeg:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createIBS:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createABS:(id<CPProgram>)cp restricted:(id<ORVarArray>)rvars;
+(id<CPHeuristic>) createFF:(id<CPProgram>)cp;
+(id<CPHeuristic>) createWDeg:(id<CPProgram>)cp;
+(id<CPHeuristic>) createDDeg:(id<CPProgram>)cp;
+(id<CPHeuristic>) createIBS:(id<CPProgram>)cp;
+(id<CPHeuristic>) createABS:(id<CPProgram>)cp;

@end