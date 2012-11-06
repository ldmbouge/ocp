/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>
#import <ORFoundation/ORController.h>

@interface ORCoreExplorerI : NSObject

-(ORCoreExplorerI*) initORExplorer: (id<OREngine>) engine withTracer: (id<ORTracer>) tracer ctrlFactory:(id<ORControllerFactory>)cFact;

-(void)                dealloc;
-(id<ORControllerFactory>) controllerFactory;

-(ORInt)               nbChoices;
-(ORInt)               nbFailures;

-(id<ORSearchController>) controller;
-(void)                   setController: (id<ORSearchController>) controller;
-(void)                   push: (id<ORSearchController>) controller;

-(void)      optimizeModel: (id<ORASolver>) solver using: (ORClosure) search onSolution:(ORClosure)onSol onExit:(ORClosure)onExit;
-(void)         solveModel: (id<ORASolver>) solver using: (ORClosure) search onSolution:(ORClosure)onSol onExit:(ORClosure)onExit;
-(void)      solveAllModel: (id<ORASolver>) solver using: (ORClosure) search onSolution:(ORClosure)onSol onExit:(ORClosure)onExit;

-(void)                try: (ORClosure) left or: (ORClosure) right;
-(void)             tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
-(void)             tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
-(void)               fail;

// combinators
-(void)               once: (ORClosure) cl;
-(void)     limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)     limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)      limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
-(void)          limitTime: (ORLong) maxTime in: (ORClosure) cl;
-(void)    applyController: (id<ORSearchController>) controller in: (ORClosure) cl;

-(void)             search: (ORClosure) body;
-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)     nestedOptimize: (id<ORASolver>) solver using: (ORClosure) search onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)             repeat: (ORClosure) body onRepeat: (ORClosure) onRestart until: (ORVoid2Bool) isDone;
@end

@interface ORExplorerI : ORCoreExplorerI<ORExplorer>
-(ORCoreExplorerI*) initORExplorer: (id<OREngine>) engine withTracer: (id<ORTracer>) tracer ctrlFactory:(id<ORControllerFactory>)cFact;

-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)     nestedOptimize: (id<ORASolver>) solver using: (ORClosure) search onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
@end

@interface ORSemExplorerI : ORCoreExplorerI<ORExplorer>
-(ORCoreExplorerI*) initORExplorer: (id<OREngine>) engine withTracer: (id<ORTracer>) tracer ctrlFactory:(id<ORControllerFactory>)cFact;
-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)     nestedOptimize: (id<ORASolver>) solver using: (ORClosure) search onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
@end
