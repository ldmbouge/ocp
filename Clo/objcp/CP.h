/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>

#import <objcp/CPData.h>
#import <objcp/CPArray.h>
#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>

@protocol CPSearchController;
@protocol CPSolver;
@protocol CPExplorer;
@protocol CPHeuristic;
@protocol ORIdxIntInformer;
@protocol CPTracer;

@protocol CPSolutionProtocol <NSObject>
-(void)        saveSolution;
-(void)     restoreSolution;
@end

@protocol CPPortal <NSObject>
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

@protocol CP <CPSolutionProtocol,ORTracker> 

-(id<CPSearchController>) controller;

-(void)                push: (id<CPSearchController>) c;
-(void)      nestedMinimize: (id<CPIntVar>) x in: (CPClosure) body onSolution: onSolution onExit: onExit;
-(void)      nestedMaximize: (id<CPIntVar>) x in: (CPClosure) body onSolution: onSolution onExit: onExit;
-(void)              forall: (id<ORIntIterator>) S orderedBy: (CPInt2Int) o do: (CPInt2Void) b;
-(void)              forall: (id<ORIntIterator>) S suchThat: (CPInt2Bool) f orderedBy: (CPInt2Int) o do: (CPInt2Void) b;
-(void)                 try: (CPClosure) left or: (CPClosure) right;
-(void)              tryall: (id<ORIntIterator>) range suchThat: (CPInt2Bool) f in: (CPInt2Void) body;
-(void)              tryall: (id<ORIntIterator>) range suchThat: (CPInt2Bool) f in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure;

-(void)                 add: (id<CPConstraint>) c;
-(void)                 add: (id<CPConstraint>) c consistency:(CPConsistency)cons;
-(void)               label: (id<CPIntVar>) var with: (CPInt) val;
-(void)                diff: (id<CPIntVar>) var with: (CPInt) val;
-(void)               lthen: (id<CPIntVar>) var with: (CPInt) val;
-(void)               gthen: (id<CPIntVar>) var with: (CPInt) val;
-(void)            restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;

-(void)              search: (CPClosure) body;
-(void)               solve: (CPClosure) body;
-(void)               solve: (CPClosure) body using:(CPClosure) search;
-(void)            solveAll: (CPClosure) body;
-(void)            solveAll: (CPClosure) body using:(CPClosure) search;
-(void)            minimize: (id<CPIntVar>) x in: (CPClosure) body;
-(void)            maximize: (id<CPIntVar>) x in: (CPClosure) body;
-(void)            minimize: (id<CPIntVar>) x subjectTo: (CPClosure) body using:(CPClosure) search;
-(void)            maximize: (id<CPIntVar>) x subjectTo: (CPClosure) body using:(CPClosure) search;

-(void)         nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit;
-(void)         nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution;
-(void)         nestedSolve: (CPClosure) body;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution;
-(void)      nestedSolveAll: (CPClosure) body;

-(void)                once: (CPClosure) cl;
-(void)      limitSolutions: (CPInt) maxSolutions in: (CPClosure) cl;
-(void)      limitCondition: (CPVoid2Bool) condition in: (CPClosure) cl;
-(void)  limitDiscrepancies: (CPInt) maxDiscrepancies in: (CPClosure) cl;
-(void)      limitFailures: (CPInt) maxFailures in: (CPClosure) cl;
-(void)      limitTime: (CPLong) maxTime in: (CPClosure) cl;
-(void)    applyController: (id<CPSearchController>) controller in: (CPClosure) cl;

-(void)             repeat: (CPClosure) body onRepeat: (CPClosure) onRestart;
-(void)             repeat: (CPClosure) body onRepeat: (CPClosure) onRestart until: (CPVoid2Bool) isDone;
-(id<CPPortal>) portal;
-(id<CPTracer>) tracer;
-(id<CPSolution>) solution;

@optional -(void) solveParAll:(CPUInt)nbt subjectTo:(CPClosure)body using:(CPVirtualClosure)body;
-(id<CPSolver>)       solver;
-(id<CPExplorer>)   explorer;
-(void)addHeuristic:(id<CPHeuristic>)h;
@optional -(id)virtual:(id)obj;
@end


