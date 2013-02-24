/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <ORProgram/CPProgram.h> 
#import <ORProgram/CPSolver.h>

// MultiStart DFS CPSolver
@interface CPMultiStartSolver : NSObject<CPProgram>
-(id<CPProgram>) initCPMultiStartSolver: (ORInt) k;
-(id<CPProgram>) at: (ORInt) i;
-(ORInt) nb;
-(id<ORSolutionPool>) globalSolutionPool;
-(id<CPHeuristic>) createFF:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createFF;
-(id<CPHeuristic>) createWDeg;
-(id<CPHeuristic>) createDDeg;
-(id<CPHeuristic>) createIBS;
-(id<CPHeuristic>) createABS;
@end
