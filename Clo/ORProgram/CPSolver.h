/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/CPProgram.h>

/***************************************************************************/
/*                  This file should be private                            */
/***************************************************************************/

// This factorizes all the common stuff

@interface CPCoreSolver : NSObject<CPCommonProgram>
-(CPCoreSolver*) initCPCoreSolver;
@end

// Pure DFS CPSolver
@interface CPSolver : CPCoreSolver<CPProgram>
-(id<CPProgram>) initCPSolver;
@end

// SemanticPath CPSolver
@interface CPSemanticSolver : CPCoreSolver<CPSemanticProgram>
-(id<CPSemanticProgramDFS>) initCPSemanticSolverDFS;
-(id<CPSemanticProgram>)   initCPSemanticSolver: (Class) ctrlClass;
@end

@interface CPSolverFactory : NSObject
+(id<CPSemanticProgram>) solver;
+(id<CPSemanticProgramDFS>) semanticSolverDFS;
+(id<CPSemanticProgram>) semanticSolver: (Class) ctrlClass;
@end
