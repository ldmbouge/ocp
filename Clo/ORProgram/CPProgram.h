/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORModel.h>
#import <ORProgram/CPHeuristic.h>
#import <objcp/CPData.h>

@protocol ORSearchController;
@protocol CPEngine;
@protocol ORExplorer;
@protocol ORIdxIntInformer;
@protocol ORTracer;
@protocol ORSolutionPool;
@protocol CPBitVar;

@protocol CPPortal <NSObject>
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

@protocol CPCommonProgram <ORASolver>
-(ORInt)         nbFailures;
-(id<CPEngine>)      engine;
-(id<ORExplorer>)  explorer;
-(id<ORObjectiveFunction>) objective;
-(id<CPPortal>)      portal;
-(id<ORTracer>)      tracer;

-(void)         addInternal: (id<ORConstraint>) c annotation:(ORAnnotation)n;
-(void)                 add: (id<ORConstraint>) c;
-(void)                 add: (id<ORConstraint>) c annotation: (ORAnnotation) cons;
-(void)               label: (id<ORIntVar>) var with: (ORInt) val;
-(void)                diff: (id<ORIntVar>) var with: (ORInt) val;
-(void)               lthen: (id<ORIntVar>) var with: (ORInt) val;
-(void)               gthen: (id<ORIntVar>) var with: (ORInt) val;
-(void)            restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S;

-(void)        addHeuristic: (id<CPHeuristic>) h;
-(void)          labelArray: (id<ORIntVarArray>) x;
-(void)          labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy;
-(void)      labelHeuristic: (id<CPHeuristic>) h;
-(void)               label: (id<ORIntVar>) mx;

-(void)               solve: (ORClosure) body;
-(void)            solveAll: (ORClosure) body;
-(void)               close;

-(void)              forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
-(void)                 try: (ORClosure) left or: (ORClosure) right;
-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;

-(void)           limitTime: (ORLong) maxTime in: (ORClosure) cl;

-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)         nestedSolve: (ORClosure) body;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)      nestedSolveAll: (ORClosure) body;
-(void)          onSolution: (ORClosure)onSol onExit:(ORClosure)onExit;
-(id<ORSolutionPool>) solutionPool;
@end

// CPSolver with syntactic DFS Search
@protocol CPProgram <CPCommonProgram>

-(void)                once: (ORClosure) cl;
-(void)      limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)      limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void)  limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)       limitFailures: (ORInt) maxFailures in: (ORClosure) cl;

-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart;
-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart until: (ORVoid2Bool) isDone;
@end


// CPSolver with semantic DFS Search
// Initially empty but will add things here
@protocol CPSemanticProgramDFS <CPCommonProgram>
-(void)                once: (ORClosure) cl;
-(void)      limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)      limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void)  limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)       limitFailures: (ORInt) maxFailures in: (ORClosure) cl;

-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart;
-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart until: (ORVoid2Bool) isDone;
@end

// CPSolver with Semantic Path
@protocol CPSemanticProgram <CPCommonProgram>
@end


@protocol CPBV
-(void) labelBit:(int)i ofVar:(id<ORBitVar>)x;
-(void) labelUpFromLSB:(id<ORBitVar>) x;
@end
