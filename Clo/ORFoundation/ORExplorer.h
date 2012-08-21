/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <Foundation/Foundation.h>

@protocol ORSolver;

@protocol ORExplorer <NSObject>
-(void) push: (id<ORSearchController>) c;

// Statistics
-(ORInt)       nbChoices;
-(ORInt)       nbFailures;

// access
-(id<ORSearchController>)    controller;
-(void)                   setController: (id<ORSearchController>) controller;

// combinators

-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)                try: (ORClosure) left or: (ORClosure) right;
-(void)             tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
-(void)             tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
-(void)               fail;
-(void)            repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;

-(void)               once: (ORClosure) cl;
-(void)    applyController: (id<ORSearchController>) controller in: (ORClosure) cl;
-(void)     limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)     limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)      limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
-(void)          limitTime: (ORLong) maxTime in: (ORClosure) cl;

-(void)      optimizeModel: (id<ORSolver>) solver using: (ORClosure) search; 
-(void)         solveModel: (id<ORSolver>) solver using: (ORClosure) search;
-(void)      solveAllModel: (id<ORSolver>) solver using: (ORClosure) search;
-(void)             search: (ORClosure) block;
@end

