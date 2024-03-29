/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

@protocol ORASearchSolver;
@protocol ORSearchController;
@protocol ORControllerFactory;
@protocol ORIntIterable;
@protocol ORTracer;
@protocol ORSearchEngine;

@protocol ORExplorer <NSObject>
-(void) push: (id<ORSearchController>) c;
-(id<ORControllerFactory>) controllerFactory;

// Statistics
-(ORInt)       nbChoices;
-(ORInt)       nbFailures;

// access
-(id<ORSearchController>)    controller;
-(void)                   setController: (id<ORSearchController>) controller;

// combinators

-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)     nestedOptimize: (id<ORASearchSolver>) solver using: (ORClosure) search onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)                try: (ORClosure) left alt: (ORClosure) right;
-(void)             tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
-(void)             tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
-(void)              tryall: (id<ORIntIterable>) range
                   suchThat: (ORInt2Bool) filter
                  orderedBy: (ORInt2Double)o1
                         in: (ORInt2Void) body
                  onFailure: (ORInt2Void) onFailure;
-(void)               fail;

-(void)             repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;
-(void)            perform: (ORClosure) body onLimit: (ORClosure) action;
-(void)          portfolio: (ORClosure) s1 then: (ORClosure) s2;
-(void)      switchOnDepth: (ORClosure) s1 to: (ORClosure) s2 limit: (ORInt) depth;

-(void)               once: (ORClosure) cl;
-(void)                try: (ORClosure) left then: (ORClosure) right;
-(void)    applyController: (id<ORSearchController>) controller in: (ORClosure) cl;
-(void)     limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)     limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)      limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
-(void)          limitTime: (ORLong) maxTime in: (ORClosure) cl;

-(void)      optimizeModel: (id<ORASearchSolver>) solver using: (ORClosure) search onSolution:(ORClosure)onSol onExit:(ORClosure)onExit;
-(void)         solveModel: (id<ORASearchSolver>) solver using: (ORClosure) search onSolution:(ORClosure)onSol onExit:(ORClosure)onExit;
-(void)      solveAllModel: (id<ORASearchSolver>) solver using: (ORClosure) search onSolution:(ORClosure)onSol onExit:(ORClosure)onExit;
-(void)             search: (ORClosure) block;
@end

@interface ORExplorerFactory : NSObject
+(id<ORExplorer>) explorer: (id<ORSearchEngine>) engine withTracer: (id<ORTracer>) tracer ctrlFactory:(id<ORControllerFactory>)cFact;
+(id<ORExplorer>) semanticExplorer: (id<ORSearchEngine>) engine withTracer: (id<ORTracer>) tracer ctrlFactory:(id<ORControllerFactory>)cFact;
@end

