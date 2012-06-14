/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "cont.h"
#import "CPTypes.h"
#import "CPError.h"
#import "CPTrail.h"
#import "CPController.h"
#import "CPTracer.h"
#import "CPDataI.h"
#import "CPExplorer.h"


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
-(void)            restart: (CPClosure) body onRestart: (CPClosure) onRestart isDone: (CPVoid2Bool) isDone;

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


-(void)           forrange: (CPRange) range filteredBy: (CPInt2Bool) f orderedBy: (CPInt2Int) o do: (CPInt2Void) b;
-(void)                try: (CPClosure) left or: (CPClosure) right;
-(void)             tryall: (CPRange) range filteredBy: (CPInt2Bool) f in: (CPInt2Void) body;
-(void)             tryall: (CPRange) range filteredBy: (CPInt2Bool) f in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure;
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
-(void) limitDiscrepancies: (CPInt) maxDiscrepancies in: (CPClosure) cl;
-(void)            restart: (CPClosure) body onRestart: (CPClosure) onRestart isDone: (CPVoid2Bool) isDone;
@end

@interface CPSemExplorerI : CPCoreExplorerI<CPExplorer> {
}
-(CPSemExplorerI*)initCPSemExplorer: (id<AbstractSolver>) solver withTracer: (id<CPTracer>) tracer;
-(void)dealloc;
// top level calls
-(void)             search: (CPClosure) body;
// combinators
-(void)            restart: (CPClosure) body onRestart: (CPClosure) onRestart isDone: (CPVoid2Bool) isDone;
-(CPStatus)restoreCheckpoint:(Checkpoint*)cp;
-(Checkpoint*)captureCheckpoint;
-(NSData*)packCheckpoint:(Checkpoint*)cp;
-(NSData*)captureAndPackProblem;
@end
