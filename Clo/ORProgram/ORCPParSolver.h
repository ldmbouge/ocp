/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPProgram.h> 

@interface CPParSolverI : ORGamma<CPProgram> {
   ORInt              _nbWorkers;
   id<ORSolutionPool> _globalPool;
   ORClosure          _onSol;
}
-(id<CPProgram>) initParSolver:(ORInt)nbt withController:(id<ORSearchController>)ctrlProto;
-(void) setSource:(id<ORModel>)src;
-(ORInt)nbWorkers;
-(id<CPProgram>) worker;
-(void)onSolution:(ORClosure)onSolution;
-(void) doOnSolution;
-(void) doOnExit;
-(void) clearOnSolution;
-(id<CPHeuristic>) createFF:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createFF;
-(id<CPHeuristic>) createWDeg;
-(id<CPHeuristic>) createDDeg;
-(id<CPHeuristic>) createSDeg;
-(id<CPHeuristic>) createIBS;
-(id<CPHeuristic>) createABS;
-(ORInt)intValue:(id<ORIntVar>)x;
@end
