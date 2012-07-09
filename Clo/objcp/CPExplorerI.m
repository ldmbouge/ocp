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
#import "CPSolver.h"
#import "CPExplorerI.h"
#import "CPController.h"
#import "DFSController.h"
#import "SemDFSController.h"
#import "CPLimit.h"
#import "CPI.h"
#import "objcp/CPFactory.h"
#import "CPObjectQueue.h"
#import "ORFoundation/ORConcurrency.h"
#if !defined(__APPLE__)
#import <values.h>
#endif

@implementation CPHStack
-(CPHStack*)initCPHStack
{
   self = [super init];
   _mx  = 2;
   _tab = malloc(sizeof(id<CPHeuristic>)*_mx);
   _sz  = 0;
   return self;
}
-(void)push:(id<CPHeuristic>)h
{
   if (_sz >= _mx) {
      _tab = realloc(_tab, _mx << 1);
      _mx <<= 1;
   }
   _tab[_sz++] = h;
}
-(id<CPHeuristic>)pop
{
   return _tab[--_sz];
}
-(void)reset
{
   for(CPUInt k=0;k<_sz;k++)
      [_tab[k] release];
   _sz = 0;
}
-(void)dealloc
{
   [self reset];
   free(_tab);
   [super dealloc];
}
-(void)applyToAll:(void(^)(id<CPHeuristic>,NSMutableArray*))closure with:(NSMutableArray*)av;
{
   for(CPUInt k=0;k<_sz;k++) 
      closure(_tab[k],av);   
}
@end

@implementation CPCoreExplorerI
-(id) initCPCoreExplorer: (id<AbstractSolver>) solver withTracer: (id<CPTracer>) tracer
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

-(CPInt) nbChoices
{
   return _nbc;
}

-(CPInt) nbFailures
{
   return _nbf;
}
-(void) setController: (id<CPSearchController>) controller
{
   assignTRId(&_controller,controller,[_tracer trail]);  
   [controller setup];
}

-(void) push: (id<CPSearchController>) controller
{
   [controller setController: _controller._val];
   assignTRId(&_controller,controller,[_tracer trail]);  
}

-(void) popController
{
   id<CPSearchController> controller = [_controller._val controller];
   assignTRId(&_controller,controller,[_tracer trail]);  
}
-(id<CPSearchController>) controller
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
-(void) search: (CPClosure) body
{
}

-(void) nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit  control:(id<CPSearchController>)newCtrl
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

-(void) nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit control:(id<CPSearchController>)newCtrl
{
   id<CPSearchController> oldCtrl = _controller._val;
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

-(void) solveAll: (CPClosure) body 
{
   [self search: ^() 
    {
       body();
       [self fail];
    }
    ];
}

-(void) solveAll: (CPClosure) body using: (CPClosure) search
{
   [self search: ^() 
    {
       [self nestedSolveAll: ^() { body(); [self close]; search(); } 
                 onSolution: nil 
                     onExit: nil
                    control: [[CPNestedController alloc] initCPNestedController:_controller._val]];
    }
    ];
}

// this is a top-level call; not a search combinator

-(void) solve: (CPClosure) body
{
   [self search: ^() 
    {
       [self nestedSolve: body 
              onSolution: ^() { [_solver saveSolution]; } 
                  onExit: ^() { [_solver restoreSolution]; }
                 control: [[CPNestedController alloc] initCPNestedController:_controller._val]];
    }
    ];
}

-(void) solve: (CPClosure) body using: (CPClosure) search
{
   [self search: ^() 
    {
       [self nestedSolve: ^() { body(); [self close]; search(); } 
              onSolution: ^() { [_solver saveSolution]; } 
                  onExit: ^() { [_solver restoreSolution]; }
                 control: [[CPNestedController alloc] initCPNestedController:_controller._val]];
    }
    ];
}

-(void) repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone;
{
}


-(void)           optimize: (CPClosure) body 
                      post: (CPClosure) post 
                canImprove: (CPVoid2CPStatus) canImprove 
                    update: (CPClosure) update 
                onSolution: (CPClosure) onSolution 
                    onExit: (CPClosure) onExit
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

-(void) optimize: (CPClosure) body 
            post: (CPClosure) post 
      canImprove: (CPVoid2CPStatus) canImprove 
          update: (CPClosure) update
{
   [self optimize: body post: post canImprove: canImprove update: update onSolution: NULL onExit: NULL];
}


-(void) forrange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order do: (CPInt2Void) body
{
   CPInt sz = range.up - range.low + 1;
   bool*  used = alloca(sizeof(bool)*sz);
   for(CPInt i=range.low;i<=range.up;i++) 
      used[i-range.low] = !filter(i);         
   bool done = false;
   while (!done) {
      float best = MAXFLOAT;
      CPInt chosen = range.low-1;
      CPInt i=range.low;
      while (i <= range.up) {
         if (!(used[i-range.low]) && filter(i)) {
            CPInt efi = order(i);
            if (efi < best) {
               chosen = i;
               best = efi;
            }
         }
         ++i;
      }
      done = chosen < range.low;
      if (!done) {
         used[chosen-range.low] = YES;
         body(chosen);
      }
   }
}

-(void) try: (CPClosure) left or: (CPClosure) right
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
-(void) tryall: (CPRange) range filteredBy: (CPInt2Bool) filter in: (CPInt2Void) body 
{
   [self tryall: range filteredBy: filter in: body onFailure: NULL];
}

-(void) tryall: (CPRange) range filteredBy: (CPInt2Bool) filter in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure
{
   CPInt cur;
   [_controller._val startTryall];
   NSCont* exit = [NSCont takeContinuation];
   NSCont* next = nil;
   if ([exit nbCalls] == 0) {
      [_controller._val addChoice: exit];
      next = [NSCont takeContinuation];
      [exit setFieldId: next];
      if ([next nbCalls]== 0) { // This is the first call to the continuation.
         [next setField: range.low];
         cur = range.low;
      } 
      else {
         cur = [next field] + 1;
         [_controller._val startTryallOnFailure];	
         if (onFailure)
            onFailure([next field]);
         [_controller._val exitTryallOnFailure];	
      }
      if (filter) {
         while (!filter(cur) && cur <= range.up) 
            ++cur;
      }
      if (cur <= range.up) {
         [next setField: cur];
         _nbc++;
         [_controller._val addChoice: next];
         [_controller._val startTryallBody];	
         body(cur);
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
-(CPExplorerI*) initCPExplorer: (id<AbstractSolver>) solver withTracer: (id<CPTracer>) tracer
{
   self = [super initCPCoreExplorer:solver withTracer:tracer];
   return self;
}

-(void)dealloc
{
   [super dealloc];
}

-(void) once: (CPClosure) cl
{
  [self limitSolutions: 1 in: cl];
}

-(void) limitSolutions: (CPInt) nb in: (CPClosure) cl
{
  CPLimitSolutions* limit = [[CPLimitSolutions alloc] initCPLimitSolutions: nb];
  [self push: limit];
  [limit release];
  cl();
  [limit succeeds];  
  [self popController]; 
}

-(void) limitCondition: (CPVoid2Bool) condition in: (CPClosure) cl
{
   CPLimitCondition* limit = [[CPLimitCondition alloc] initCPLimitCondition: condition];
   [self push: limit];
   [limit release];
   cl();
   [self popController];
}

-(void) limitDiscrepancies: (CPInt) nb in: (CPClosure) cl
{
  CPLimitDiscrepancies* limit = [[CPLimitDiscrepancies alloc] initCPLimitDiscrepancies: nb withTrail: [_tracer trail]];
  [self push: limit];
  [limit release];
  cl();
  [self popController]; 
}
-(void) limitFailures: (CPInt) nb in: (CPClosure) cl
{
   CPLimitFailures* limit = [[CPLimitFailures alloc] initCPLimitFailures: nb withTrail: [_tracer trail]];
   [self push: limit];
   [limit release];
   cl();
   [self popController];
}
-(void) applyController: (id<CPSearchController>) controller in: (CPClosure) cl
{
   [self push: controller];
   [controller release];
   cl();
   [self popController];
}
-(void) search: (CPClosure) body
{
  int to;
  initContinuationLibrary(&to);
  @try {
     DFSController* dfs = [[DFSController alloc] initDFSController:_tracer];
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

-(void) repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone;
{
//   id<CPInteger> nbRestarts = [CPFactory integer: _solver value: -1];
   NSCont* enter = [NSCont takeContinuation];
   if (isDone) 
      if (isDone()) {
         [enter letgo];
         [_controller._val fail];            
      }
   /*
   [nbRestarts incr];
   if ([nbRestarts value] == 2000) {
      [enter letgo];
      [_controller._val fail];
   }
    */
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

-(CPSemExplorerI*) initCPSemExplorer: (id<AbstractSolver>) solver withTracer:(id<CPTracer>)tracer
{
   self = [super initCPCoreExplorer:solver withTracer:tracer];
   return self;
}

-(void)dealloc
{
   [super dealloc];
}

-(void) search: (CPClosure) body
{
   int to;
   initContinuationLibrary(&to);
   @try {
      SemDFSController* dfs = [[SemDFSController alloc] initSemController:_tracer andSolver:(id<CPSolver>)_solver];
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

-(void) repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone
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

-(CPStatus)restoreCheckpoint:(Checkpoint*)cp
{
   return [_tracer restoreCheckpoint:cp inSolver:_solver];
}
-(NSData*)packCheckpoint:(Checkpoint*)cp
{
   return [cp packFromSolver:(id<CPSolver>)_solver];
}
-(NSData*)captureAndPackProblem
{
   CPProblem* theProb = [_tracer captureProblem];
   NSData* theData = [theProb packFromSolver:(id<CPSolver>)_solver];
   [theProb release];
   return theData;
}

@end
