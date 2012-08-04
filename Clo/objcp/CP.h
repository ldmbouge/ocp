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

@protocol ORSearchController;
@protocol CPEngine;
@protocol ORExplorer;
@protocol CPHeuristic;
@protocol ORIdxIntInformer;
@protocol ORTracer;


@protocol CPPortal <NSObject>
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

@protocol CP <ORSolutionProtocol,ORTracker>

-(id<ORSearchController>) controller;

-(void)                push: (id<ORSearchController>) c;
-(void)      nestedMinimize: (id<CPIntVar>) x in: (ORClosure) body onSolution: onSolution onExit: onExit;
-(void)      nestedMaximize: (id<CPIntVar>) x in: (ORClosure) body onSolution: onSolution onExit: onExit;
-(void)              forall: (id<ORIntIterator>) S orderedBy: (CPInt2Int) o do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f orderedBy: (CPInt2Int) o do: (ORInt2Void) b;
-(void)                 try: (ORClosure) left or: (ORClosure) right;
-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;

-(void)                 add: (id<CPConstraint>) c;
-(void)                 add: (id<CPConstraint>) c consistency:(CPConsistency)cons;
-(void)               label: (id<CPIntVar>) var with: (CPInt) val;
-(void)                diff: (id<CPIntVar>) var with: (CPInt) val;
-(void)               lthen: (id<CPIntVar>) var with: (CPInt) val;
-(void)               gthen: (id<CPIntVar>) var with: (CPInt) val;
-(void)            restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;

-(void)              search: (ORClosure) body;
-(void)               solve: (ORClosure) body;
-(void)               solve: (ORClosure) body using:(ORClosure) search;
-(void)            solveAll: (ORClosure) body;
-(void)            solveAll: (ORClosure) body using:(ORClosure) search;
-(void)            minimize: (id<CPIntVar>) x in: (ORClosure) body;
-(void)            maximize: (id<CPIntVar>) x in: (ORClosure) body;
-(void)            minimize: (id<CPIntVar>) x subjectTo: (ORClosure) body using:(ORClosure) search;
-(void)            maximize: (id<CPIntVar>) x subjectTo: (ORClosure) body using:(ORClosure) search;

-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)         nestedSolve: (ORClosure) body;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)      nestedSolveAll: (ORClosure) body;

-(void)                once: (ORClosure) cl;
-(void)      limitSolutions: (CPInt) maxSolutions in: (ORClosure) cl;
-(void)      limitCondition: (CPVoid2Bool) condition in: (ORClosure) cl;
-(void)  limitDiscrepancies: (CPInt) maxDiscrepancies in: (ORClosure) cl;
-(void)      limitFailures: (CPInt) maxFailures in: (ORClosure) cl;
-(void)      limitTime: (CPLong) maxTime in: (ORClosure) cl;
-(void)    applyController: (id<ORSearchController>) controller in: (ORClosure) cl;

-(void)             repeat: (ORClosure) body onRepeat: (ORClosure) onRestart;
-(void)             repeat: (ORClosure) body onRepeat: (ORClosure) onRestart until: (CPVoid2Bool) isDone;
-(id<CPPortal>) portal;
-(id<ORTracer>) tracer;
-(id<CPSolution>) solution;

@optional -(void) solveParAll:(CPUInt)nbt subjectTo:(ORClosure)body using:(CPVirtualClosure)body;
-(id<CPEngine>)       solver;
-(id<ORExplorer>)   explorer;
-(void)addHeuristic:(id<CPHeuristic>)h;
@optional -(id)virtual:(id)obj;
@end


