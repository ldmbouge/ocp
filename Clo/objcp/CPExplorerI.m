/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <objc/runtime.h>
#import <objc/objc-auto.h>
#import "cont.h"
#import "CPEngine.h"
#import "CPExplorerI.h"
#import "CPController.h"
#import "SemDFSController.h"
#import "CPLimit.h"
#import "CPSolverI.h"
#import "objcp/CPFactory.h"
#import "CPObjectQueue.h"
#import "ORUtilities/ORUtilities.h"
#if !defined(__APPLE__)
#import <values.h>
#endif

/*

@implementation CPCoreExplorerI
-(id) initCPCoreExplorer: (id<OREngine>) solver withTracer: (id<ORTracer>) tracer
{
   self = [super init];
   _solver = solver;
   _tracer = [tracer retain];
   _nbc = _nbf = 0;   
   _hStack = [[CPHStack alloc] initCPHStack];
   return self;
}
-(void) dealloc
{
   NSLog(@"CPCoreExplorer dealloc called...\n");
   id ctrl = _controller._val;
   [ctrl release];
   [_tracer release];
   [_hStack release];
   [super dealloc];
}
-(void)addHeuristic:(id<CPHeuristic>)h
{
   [_hStack push:h];
}

-(ORInt) nbChoices
{
   return _nbc;
}

-(ORInt) nbFailures
{
   return _nbf;
}
-(void) setController: (id<ORSearchController>) controller
{
   assignTRId(&_controller,controller,[_tracer trail]);  
   [controller setup];
}

-(void) push: (id<ORSearchController>) controller
{
   [controller setController: _controller._val];
   assignTRId(&_controller,controller,[_tracer trail]);  
}

-(void) popController
{
   id<ORSearchController> controller = [_controller._val controller];
   assignTRId(&_controller,controller,[_tracer trail]);  
}
-(id<ORSearchController>) controller
{
   return _controller._val;
}
-(void) fail
{
   [ORConcurrency pumpEvents];
   _nbf++;
   [_controller._val fail];
}

-(void)close
{
   [_solver close];
   [_hStack applyToAll:^(id<CPHeuristic> h,NSMutableArray* av) { [h initHeuristic:av];} 
                  with:[_solver allVars]];
   [ORConcurrency pumpEvents];   
}

// this is a top-level call; not a search combinator
-(void) search: (ORClosure) body
{
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit  control:(id<ORSearchController>)newCtrl
{
   // clone the old controller chain in full. Must be done before creating the continuation
   // to make sure that newCtrl is available when we "come back". 
   NSCont* exit = [NSCont takeContinuation];
   if ([exit nbCalls]==0) {
      [_controller._val addChoice: exit];                           // add the choice in the original controller
      [self setController:newCtrl];                                 // install the new controller chain
      if (body) body();
      if (onSolution) onSolution();
      [_controller._val succeeds];                                
   } else if ([newCtrl isFinitelyFailed]) {
      [exit letgo];
      [newCtrl release];
      [_controller._val fail];
   } else {
      [exit letgo];
      [newCtrl release];
      if (onExit) onExit();
      [_controller._val fail];
   }
}

// combinator (hence needs to be embedded in top-level search)
// solve the body; Each time a solution is found, execute onSolution; restore the state as before the call; execute onExit at the end

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)newCtrl
{
   id<ORSearchController> oldCtrl = _controller._val;
   NSCont* exit = [NSCont takeContinuation];
   if ([exit nbCalls]==0) {
      [_controller._val addChoice: exit];    
      [self setController:newCtrl];           // install the new controller
      if (body) body();
      if (onSolution) onSolution();  
      [_controller._val fail];                // If fail runs out of node, it will trigger finitelyFailed. 
   } else if ([newCtrl isFinitelyFailed]) {
      [exit letgo];
      [newCtrl release];
      [_controller._val fail];
   } else {
      [exit letgo];
      [newCtrl release];
      [self setController:oldCtrl];
      if (onExit) onExit();
   }   
}

-(void) solveAll: (ORClosure) body 
{
   [self search: ^() 
    {
       body();
       [self fail];
    }
    ];
}

-(void) solveAll: (ORClosure) body using: (ORClosure) search
{
   [self search: ^() 
    {
       [self nestedSolveAll: ^() { body(); [self close]; search(); } 
                 onSolution: nil 
                     onExit: nil
                    control: [[ORNestedController alloc] initCPNestedController:_controller._val]];
    }
    ];
}

// this is a top-level call; not a search combinator

-(void) solve: (ORClosure) body
{
   [self search: ^() 
    {
       [self nestedSolve: body 
              onSolution: ^() { [_solver saveSolution]; } 
                  onExit: ^() { [_solver restoreSolution]; }
                 control: [[ORNestedController alloc] initCPNestedController:_controller._val]];
    }
    ];
}

-(void) solve: (ORClosure) body using: (ORClosure) search
{
   [self search: ^() 
    {
       [self nestedSolve: ^() { body(); [self close]; search(); } 
              onSolution: ^() { [_solver saveSolution]; } 
                  onExit: ^() { [_solver restoreSolution]; }
                 control: [[ORNestedController alloc] initCPNestedController:_controller._val]];
    }
    ];
}

-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone;
{
}


-(void)           optimize: (ORClosure) body 
                      post: (ORClosure) post 
                canImprove: (Void2ORStatus) canImprove
                    update: (ORClosure) update 
                onSolution: (ORClosure) onSolution 
                    onExit: (ORClosure) onExit
{
   NSCont* exit = [NSCont takeContinuation];
   [_controller._val addChoice: exit];    
   if ([exit nbCalls]==0) {
      CPOptimizationController* controller = [[CPOptimizationController alloc] initCPOptimizationController: canImprove];
      [self push: controller];
      [controller release];
      if (post) post();
      if (body) body();
      if (update) update();
      if (onSolution) onSolution();
      [_controller._val fail];
   }
   else {
      if (onExit) onExit();
      [exit letgo];
   }
}

-(void) optimize: (ORClosure) body 
            post: (ORClosure) post 
      canImprove: (Void2ORStatus) canImprove 
          update: (ORClosure) update
{
   [self optimize: body post: post canImprove: canImprove update: update onSolution: NULL onExit: NULL];
}

-(void) try: (ORClosure) left or: (ORClosure) right
{
   [_controller._val startTry];
   NSCont* k = [NSCont takeContinuation];
   if ([k nbCalls] == 0) {
      [_controller._val startTryLeft];   
      _nbc++;
      [_controller._val addChoice: k];
      left();
      [_controller._val exitTryLeft];     
   } 
   else {
      [_controller._val startTryRight];  
      [k letgo];
      [_controller._val trust];
      right();
      [_controller._val exitTryRight];     
   }
   [_controller._val exitTry];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body 
{
   [self tryall: range suchThat: filter in: body onFailure: NULL];
}


-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   CPInt curIte;
   CPInt foundIte;
   [_controller._val startTryall];
   NSCont* exit = [NSCont takeContinuation];
   NSCont* next = nil;
   id<IntEnumerator> ite = [ORFactory intEnumerator: _solver over: range];
   if ([exit nbCalls] == 0) {
      [_controller._val addChoice: exit];
      next = [NSCont takeContinuation];
      [exit setFieldId: next];
      if ([next nbCalls] != 0) { 
         [_controller._val startTryallOnFailure];
         if (onFailure)
            onFailure([next field]);
         [_controller._val exitTryallOnFailure];
      }
      foundIte = [ite more];
      if (foundIte) {
         curIte = [ite next];
         if (filter) 
            while (!filter(curIte)) {
               if (![ite more]) {
                  foundIte = false;
                  break;
               }
               curIte = [ite next];
            }
      }
      if (foundIte) {
         [next setField: curIte];
         _nbc++;
         [_controller._val addChoice: next];
         [_controller._val startTryallBody];
         body(curIte);
         [_controller._val exitTryallBody];
      }
      else
         [_controller._val fail];
   }
   else {
      [[exit fieldId] letgo];
      [exit letgo];
      [_controller._val fail];
   }
   [_controller._val exitTryall];
}

@end

// ====================================================================================================
// DFS style explorer.

@implementation CPExplorerI
-(CPExplorerI*) initCPExplorer: (id<OREngine>) solver withTracer: (id<ORTracer>) tracer
{
   self = [super initCPCoreExplorer:solver withTracer:tracer];
   return self;
}

-(void)dealloc
{
   [super dealloc];
}

-(void) once: (ORClosure) cl
{
  [self limitSolutions: 1 in: cl];
}

-(void) limitSolutions: (ORInt) nb in: (ORClosure) cl
{
  CPLimitSolutions* limit = [[CPLimitSolutions alloc] initCPLimitSolutions: nb];
  [self push: limit];
  [limit release];
  cl();
  [limit succeeds];  
  [self popController]; 
}

-(void) limitCondition: (CPVoid2Bool) condition in: (ORClosure) cl
{
   CPLimitCondition* limit = [[CPLimitCondition alloc] initCPLimitCondition: condition];
   [self push: limit];
   [limit release];
   cl();
   [self popController];
}

-(void) limitDiscrepancies: (ORInt) nb in: (ORClosure) cl
{
  CPLimitDiscrepancies* limit = [[CPLimitDiscrepancies alloc] initCPLimitDiscrepancies: nb withTrail: [_tracer trail]];
  [self push: limit];
  [limit release];
  cl();
  [self popController]; 
}
-(void) limitFailures: (ORInt) nb in: (ORClosure) cl
{
   CPLimitFailures* limit = [[CPLimitFailures alloc] initCPLimitFailures: nb];
   [self push: limit];
   [limit release];
   cl();
   [self popController];
}
-(void) limitTime: (CPLong) maxTime in: (ORClosure) cl
{
   CPLimitTime* limit = [[CPLimitTime alloc] initCPLimitTime: maxTime];
   [self push: limit];
   [limit release];
   cl();
   [self popController];
}
-(void) applyController: (id<ORSearchController>) controller in: (ORClosure) cl
{
   [self push: controller];
   [controller release];
   cl();
   [self popController];
}
-(void) search: (ORClosure) body
{
  int to;
  initContinuationLibrary(&to);
  @try {
     ORDFSController* dfs = [[ORDFSController alloc] initDFSController:_tracer];
     NSCont* exit = [NSCont takeContinuation];
     if ([exit nbCalls]==0) {
        [dfs addChoice: exit];
        _controller = makeTRId([_tracer trail],dfs);
        [dfs setup];
        body();
     } else {
        NSLog(@"back from search...\n");
        [exit letgo];
     }
  }
  @catch (CPSearchError* ee) {
    printf("Execution Error: %s \n",[ee msg]);
  }
}

// combinator (hence needs to be embedded in top-level search)
// solve the body; when a solution is found, execute onSolution; restore the state as before the call

-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone;
{
//   id<CPInteger> nbRestarts = [CPFactory integer: _solver value: -1];
   NSCont* enter = [NSCont takeContinuation];
   if (isDone) 
      if (isDone()) {
         [enter letgo];
         [_controller._val fail];            
      }
    [_controller._val addChoice: enter];
   if ([enter nbCalls]!=0) 
      if (onRepeat) onRepeat();
   if (body) body();
}


@end

// ====================================================================================================
// Semantic Search Explorer.
// Uses explicit path representation (e.g., for // code
// ====================================================================================================


@implementation CPSemExplorerI

-(CPSemExplorerI*) initCPSemExplorer: (id<OREngine>) solver withTracer:(id<ORTracer>)tracer
{
   self = [super initCPCoreExplorer:solver withTracer:tracer];
   return self;
}

-(void)dealloc
{
   [super dealloc];
}

-(void) search: (ORClosure) body
{
   int to;
   initContinuationLibrary(&to);
   @try {
      SemDFSController* dfs = [[SemDFSController alloc] initSemController:_tracer andSolver:(id<CPEngine>)_solver];
      NSCont* exit = [NSCont takeContinuation];
      if ([exit nbCalls]==0) {
         [dfs addChoice: exit];
         _controller = makeTRId([_tracer trail],dfs);
         body();
      } else {
         [exit letgo];
      }
      [dfs cleanup];
   }
   @catch (CPSearchError* ee) {
      printf("Execution Error: %s \n",[ee msg]);
   }
}

// combinator (hence needs to be embedded in top-level search)
// solve the body; when a solution is found, execute onSolution; restore the state as before the call

-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone
{
   NSCont* enter = [NSCont takeContinuation];
   if (isDone) 
      if (isDone()) {
         [enter letgo];
         [_controller._val fail];            
      }
   [_controller._val addChoice: enter];    
   if ([enter nbCalls]!=0) 
      if (onRepeat) onRepeat();
   if (body) body();
}

-(Checkpoint*)captureCheckpoint
{
   return [_tracer captureCheckpoint];
}

-(ORStatus)restoreCheckpoint:(Checkpoint*)cp
{
   return [_tracer restoreCheckpoint:cp inSolver:_solver];
}
-(NSData*)packCheckpoint:(Checkpoint*)cp
{
   return [cp packFromSolver:(id<CPEngine>)_solver];
}
-(NSData*)captureAndPackProblem
{
   CPProblem* theProb = [_tracer captureProblem];
   NSData* theData = [theProb packFromSolver:(id<CPEngine>)_solver];
   [theProb release];
   return theData;
}

@end
*/
