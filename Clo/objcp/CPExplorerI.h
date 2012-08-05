/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>
#import <objcp/CPTypes.h>
#import <objcp/CPError.h>
#import <objcp/CPController.h>
#import <objcp/CPExplorer.h>

/*
@protocol CPHeuristic;




@interface CPCoreExplorerI : NSObject<ORExplorer> {
   id<OREngine> _solver;
   id<ORTracer>       _tracer;
   TRId               _controller;
   CPHStack*          _hStack;
   CPInt          _nbf;
   CPInt          _nbc;   
}
-(id)            initCPCoreExplorer: (id<OREngine>) solver withTracer: (id<ORTracer>) tracer;
-(void)                   dealloc;
-(CPInt)              nbChoices;
-(CPInt)              nbFailures;
-(id<ORSearchController>) controller;
-(void)      setController: (id<ORSearchController>) controller;
-(void)               push: (id<ORSearchController>) controller;
-(void)addHeuristic:(id<CPHeuristic>)h;


-(void)             search: (ORClosure) body;
-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)            repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone;

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
@end


@interface CPExplorerI : CPCoreExplorerI <ORExplorer>
{
}
-(CPExplorerI*)initCPExplorer: (id<OREngine>) solver withTracer: (id<ORTracer>) tracer;
-(void)dealloc;
// top level calls
-(void)         search: (ORClosure) body;

// combinators
-(void)               once: (ORClosure) cl;
-(void)     limitSolutions: (CPInt) masSolutions in: (ORClosure) cl;
-(void)     limitCondition: (CPVoid2Bool) condition in: (ORClosure) cl;
-(void) limitDiscrepancies: (CPInt) maxDiscrepancies in: (ORClosure) cl;
-(void)      limitFailures: (CPInt) maxFailures in: (ORClosure) cl;
-(void)          limitTime: (CPLong) maxTime in: (ORClosure) cl;
-(void)    applyController: (id<ORSearchController>) controller in: (ORClosure) cl;
-(void)            repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone;
@end

@interface CPSemExplorerI : CPCoreExplorerI<ORExplorer> {
}
-(CPSemExplorerI*)initCPSemExplorer: (id<OREngine>) solver withTracer: (id<ORTracer>) tracer;
-(void)dealloc;
// top level calls
-(void)             search: (ORClosure) body;
// combinators
-(void)            repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone;
-(ORStatus)restoreCheckpoint:(Checkpoint*)cp;
-(Checkpoint*)captureCheckpoint;
-(NSData*)packCheckpoint:(Checkpoint*)cp;
-(NSData*)captureAndPackProblem;
@end
*/