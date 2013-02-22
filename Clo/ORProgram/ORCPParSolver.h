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
-(ORInt)nbWorkers;
-(id<CPProgram>)dereference;
-(id<ORSolutionPool>)globalSolutionPool;
-(void)onSolution:(ORClosure)onSolution;
-(void) doOnSolution;
-(void) doOnExit;
@end
