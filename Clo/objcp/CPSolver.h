///************************************************************************
// Mozilla Public License
// 
// Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
// 
// ***********************************************************************/
//
//#import <ORFoundation/ORFoundation.h>
//#import <ORFoundation/ORModel.h>
//#import <objcp/CPData.h>
//#import <objcp/CPVar.h>
//
//@protocol ORSearchController;
//@protocol CPEngine;
//@protocol ORExplorer;
//@protocol ORIdxIntInformer;
//@protocol ORTracer;
//
//
//@protocol CPSolver <ORASolver>
//-(ORInt)         nbFailures;
//-(id<CPEngine>)      engine;
//-(id<ORExplorer>)  explorer;
//-(id<CPPortal>)      portal;
//-(id<ORTracer>)      tracer;
//-(id<ORSolution>)  solution;
//
//-(void)                 add: (id<ORConstraint>) c;
//-(void)                 add: (id<ORConstraint>) c annotation:(ORAnnotation) cons;
//-(id<ORObjective>) minimize: (id<ORIntVar>) x;
//-(id<ORObjective>) maximize: (id<ORIntVar>) x;
//
//-(void)               label: (id<CPIntVar>) var with: (ORInt) val;
//-(void)                diff: (id<CPIntVar>) var with: (ORInt) val;
//-(void)               lthen: (id<CPIntVar>) var with: (ORInt) val;
//-(void)               gthen: (id<CPIntVar>) var with: (ORInt) val;
//-(void)            restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;
//
//-(void)               solve: (ORClosure) body;
//-(void)            solveAll: (ORClosure) body;
//-(void)               state;
//
//-(void)              forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
//-(void)              forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
//-(void)                 try: (ORClosure) left or: (ORClosure) right;
//-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
//-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
//-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart;
//-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart until: (ORVoid2Bool) isDone;
//
//-(void)                once: (ORClosure) cl;
//-(void)      limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
//-(void)      limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
//-(void)  limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
//-(void)       limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
//-(void)           limitTime: (ORLong) maxTime in: (ORClosure) cl;
//
//-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
//-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
//-(void)         nestedSolve: (ORClosure) body;
//-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
//-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
//-(void)      nestedSolveAll: (ORClosure) body;
//
//@end
//
//@protocol CPSemSolver <CPSolver>
//-(ORStatus)installCheckpoint:(id<ORCheckpoint>)cp;
//-(ORStatus)installProblem:(id<ORProblem>)problem;
//-(id<ORCheckpoint>)captureCheckpoint;
//-(NSData*)packCheckpoint:(id<ORCheckpoint>)cp;
//-(void)setController:(id<ORSearchController>)ctrl;
//@end
//
//@protocol CPParSolver <CPSemSolver>
//-(ORInt)nbWorkers;
//@end
//
//@interface NSThread (ORData)
//+(void)setThreadID:(ORInt)tid;
//+(ORInt)threadID;
//@end
//
//
//
