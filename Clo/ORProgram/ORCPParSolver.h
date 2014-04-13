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

@interface CPParSolverI : NSObject<CPProgram> {
   ORInt              _nbWorkers;
   id<ORSolutionPool> _globalPool;
   ORClosure          _onSol;
}
-(id<CPProgram>) initParSolver:(ORInt)nbt withController:(Class)ctrlClass;
-(void) setSource:(id<ORModel>)src;
-(ORInt)nbWorkers;
-(id<CPProgram>) worker;
-(void)onSolution:(ORClosure)onSolution;
-(void) doOnSolution;
-(void) doOnExit;
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
-(ORFloat) floatValue:(id<ORFloatVar>)x;
-(ORInt) intExprValue: (id<ORExpr>)e;
-(ORFloat) floatExprValue: (id<ORExpr>)e;
@end
