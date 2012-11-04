/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/ORProgram.h>

/***************************************************************************/
/*                  This file should be private                            */
/***************************************************************************/

// This factorizes all the common stuff

@interface ORCPCoreSolver : NSObject<CPCommonProgram>
-(ORCPCoreSolver*) initORCPCoreSolver;
@end

// Pure DFS CPSolver
@interface ORCPSolver : ORCPCoreSolver<CPProgram>
-(id<CPProgram>) initORCPSolver;
@end

// SemanticPath CPSolver
@interface ORCPSemanticSolver : ORCPCoreSolver<CPSemanticProgram>
-(id<CPDFSSemanticProgram>) initORCPSolverCheckpointing;
-(id<CPSemanticProgram>)   initORCPSemanticSolver: (Class) ctrlClass;
@end

@interface ORCPSolverFactory : NSObject
+(id<CPSemanticProgram>) initORCPSolver;
+(id<CPDFSSemanticProgram>) initORCPSolverCheckpointing;
+(id<CPSemanticProgram>) initORCPSemanticSolver: (Class) ctrlClass;
@end
