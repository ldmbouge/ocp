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
#import <objcp/CPTracer.h>
#import <objcp/CPExplorer.h>


@protocol AbstractSolver;
@protocol CPHeuristic;

@interface CPHStack : NSObject {
   id<CPHeuristic>* _tab;
   CPUInt       _sz;
   CPUInt       _mx;
}
-(CPHStack*)initCPHStack;
-(void)push:(id<CPHeuristic>)h;
-(id<CPHeuristic>)pop;
-(void)reset;
-(void)applyToAll:(void(^)(id<CPHeuristic> h,NSMutableArray*))closure with:(NSMutableArray*)tab;
@end


@interface CPCoreExplorerI : NSObject<CPExplorer> {
   id<AbstractSolver> _solver;
   id<CPTracer>       _tracer;
   TRId               _controller;
   CPHStack*          _hStack;
   CPInt          _nbf;
   CPInt          _nbc;   
}
-(id)            initCPCoreExplorer: (id<AbstractSolver>) solver withTracer: (id<CPTracer>) tracer;
-(void)                   dealloc;
-(CPInt)              nbChoices;
-(CPInt)              nbFailures;
-(id<CPSearchController>) controller;
-(void)      setController: (id<CPSearchController>) controller;
-(void)               push: (id<CPSearchController>) controller;
-(void)addHeuristic:(id<CPHeuristic>)h;


-(void)             search: (CPClosure) body;
-(void)        nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit control:(id<CPSearchController>)sc;
-(void)     nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit control:(id<CPSearchController>)sc;
-(void)            repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone;

-(void)          solve: (CPClosure) body;
-(void)       solveAll: (CPClosure) body;
-(void)          solve: (CPClosure) body using: (CPClosure) search;
-(void)       solveAll: (CPClosure) body using: (CPClosure) search;

-(void)           optimize: (CPClosure) body 
                      post: (CPClosure) post 
                canImprove: (CPVoid2CPStatus) canImprove 
                    update: (CPClosure) update;

-(void)           optimize: (CPClosure) body 
                      post: (CPClosure) post 
                canImprove: (CPVoid2CPStatus) canImprove 
                    update: (CPClosure) update 
                onSolution: (CPClosure) onSolution 
                    onExit: (CPClosure) onExit;


-(void)                try: (CPClosure) left or: (CPClosure) right;
-(void)             tryall: (id<ORIntIterator>) range suchThat: (CPInt2Bool) f in: (CPInt2Void) body;
-(void)             tryall: (id<ORIntIterator>) range suchThat: (CPInt2Bool) f in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure;
-(void)               fail;
-(void)              close;
@end


@interface CPExplorerI : CPCoreExplorerI <CPExplorer> {
}
-(CPExplorerI*)initCPExplorer: (id<AbstractSolver>) solver withTracer: (id<CPTracer>) tracer;
-(void)dealloc;
// top level calls
-(void)         search: (CPClosure) body;

// combinators
-(void)               once: (CPClosure) cl;
-(void)     limitSolutions: (CPInt) masSolutions in: (CPClosure) cl;
-(void)     limitCondition: (CPVoid2Bool) condition in: (CPClosure) cl;
-(void) limitDiscrepancies: (CPInt) maxDiscrepancies in: (CPClosure) cl;
-(void)      limitFailures: (CPInt) maxFailures in: (CPClosure) cl;
-(void)          limitTime: (CPLong) maxTime in: (CPClosure) cl;
-(void)    applyController: (id<CPSearchController>) controller in: (CPClosure) cl;
-(void)            repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone;
@end

@interface CPSemExplorerI : CPCoreExplorerI<CPExplorer> {
}
-(CPSemExplorerI*)initCPSemExplorer: (id<AbstractSolver>) solver withTracer: (id<CPTracer>) tracer;
-(void)dealloc;
// top level calls
-(void)             search: (CPClosure) body;
// combinators
-(void)            repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone;
-(CPStatus)restoreCheckpoint:(Checkpoint*)cp;
-(Checkpoint*)captureCheckpoint;
-(NSData*)packCheckpoint:(Checkpoint*)cp;
-(NSData*)captureAndPackProblem;
@end
