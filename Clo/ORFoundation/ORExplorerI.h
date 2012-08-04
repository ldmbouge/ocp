/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>


@interface ORExplorerI : NSObject<ORExplorer>
{
   id<ORSolver> _solver;
   id<ORTracer> _tracer;
   TRId         _controller;
   ORInt        _nbf;
   ORInt        _nbc;
}

-(ORExplorerI*) initORExplorer: (id<ORSolver>) solver withTracer: (id<ORTracer>) tracer;
-(void)                dealloc;
-(ORInt)             nbChoices;
-(ORInt)            nbFailures;

-(id<ORSearchController>) controller;
-(void)                setController: (id<ORSearchController>) controller;
-(void)                         push: (id<ORSearchController>) controller;

-(void)             search: (ORClosure) body;
-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)            repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;

-(void)          solve: (ORClosure) body;
-(void)       solveAll: (ORClosure) body;
-(void)          solve: (ORClosure) body using: (ORClosure) search;
-(void)       solveAll: (ORClosure) body using: (ORClosure) search;

-(void)           optimize: (ORClosure) body
                      post: (ORClosure) post
                canImprove: (Void2ORStatus) canImprove
                    update: (ORClosure) update;

-(void)           optimize: (ORClosure) body
                      post: (ORClosure) post
                canImprove: (Void2ORStatus) canImprove
                    update: (ORClosure) update
                onSolution: (ORClosure) onSolution
                    onExit: (ORClosure) onExit;

-(void)                try: (ORClosure) left or: (ORClosure) right;
-(void)             tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
-(void)             tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
-(void)               fail;
-(void)              close;

// top level calls
-(void)         search: (ORClosure) body;

// combinators
-(void)               once: (ORClosure) cl;
-(void)     limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)     limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)      limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
-(void)          limitTime: (ORLong) maxTime in: (ORClosure) cl;
-(void)    applyController: (id<ORSearchController>) controller in: (ORClosure) cl;
-(void)            repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;
@end
