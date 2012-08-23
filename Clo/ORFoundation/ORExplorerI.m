/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>
#import "ORLimit.h"
#import "ORExplorerI.h"

@implementation ORCoreExplorerI
{
   @protected
   id<OREngine>           _engine;
   id<ORTrail>             _trail;
   TRId               _controller;
   ORInt                     _nbf;
   ORInt                     _nbc;
   id<ORControllerFactory> _cFact;
}
-(id) initORExplorer: (id<OREngine>) engine withTracer: (id<ORTracer>) tracer ctrlFactory:(id<ORControllerFactory>)cFact
{
   self = [super init];
   _engine = engine;
   _trail = [[tracer trail] retain];
   _nbc = _nbf = 0;
   _cFact = [cFact retain];
   return self;
}
-(void) dealloc
{
   NSLog(@"ORCoreExplorer dealloc called...\n");
   id ctrl = _controller._val;
   [ctrl release];
   [_trail release];
   [_cFact release];
   [super dealloc];
}

-(id<ORControllerFactory>) controllerFactory
{
   return _cFact;
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
   assignTRId(&_controller,controller,_trail);
   [controller setup];
}

-(void) push: (id<ORSearchController>) controller
{
   [controller setController: _controller._val];
   assignTRId(&_controller,controller,_trail);
}

-(void) popController
{
   id<ORSearchController> controller = [_controller._val controller];
   //[_controller._val release];
   //_controller._val = controller;
   assignTRId(&_controller,controller,_trail);
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
   ORInt curIte;
   ORInt foundIte;
   [_controller._val startTryall];
   NSCont* exit = [NSCont takeContinuation];
   NSCont* next = nil;
   id<IntEnumerator> ite = [ORFactory intEnumerator: _engine over: range];
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

-(void) once: (ORClosure) cl
{
   [self limitSolutions: 1 in: cl];
}

-(void) limitSolutions: (ORInt) nb in: (ORClosure) cl
{
   ORLimitSolutions* limit = [[ORLimitSolutions alloc] initORLimitSolutions: nb];
   [self push: limit];
   [limit release];
   cl();
   [limit succeeds];
   [self popController];
}

-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   ORLimitCondition* limit = [[ORLimitCondition alloc] initORLimitCondition: condition];
   [self push: limit];
   [limit release];
   cl();
   [self popController];
}

-(void) limitDiscrepancies: (ORInt) nb in: (ORClosure) cl
{
   ORLimitDiscrepancies* limit = [[ORLimitDiscrepancies alloc] initORLimitDiscrepancies: nb withTrail: _trail];
   [self push: limit];
   [limit release];
   cl();
   [self popController];
}
-(void) limitFailures: (ORInt) nb in: (ORClosure) cl
{
   ORLimitFailures* limit = [[ORLimitFailures alloc] initORLimitFailures: nb];
   [self push: limit];
   [limit release];
   cl();
   [self popController];
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   ORLimitTime* limit = [[ORLimitTime alloc] initORLimitTime: maxTime];
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

// combinator (hence needs to be embedded in top-level search)
// solve the body; when a solution is found, execute onSolution; restore the state as before the call

-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;
{
   //   id<ORInteger> nbRestarts = [ORFactory integer: _solver value: -1];
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

-(void) search: (ORClosure) body
{
   int to;
   initContinuationLibrary(&to);
   @try {
      id<ORSearchController> dfs = [_cFact makeRootController];
      NSCont* exit = [NSCont takeContinuation];
      if ([exit nbCalls]==0) {
         _controller = makeTRId(_trail,dfs);
         [dfs addChoice: exit];
         [dfs setup];
         body();
         [exit letgo];
         [_controller._val cleanup];
         [_controller._val release];
         _controller._val = nil;
         NSLog(@"top-level success");
      }
      else {
         NSLog(@"top-level fail");
         [exit letgo];
      }
   }
   @catch (ORSearchError* ee) {
      printf("Execution Error: %s \n",[ee msg]);
   }
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit  control:(id<ORSearchController>)newCtrl
{
   NSCont* exit = [NSCont takeContinuation];
   if ([exit nbCalls]==0) {
      [_controller._val addChoice: exit];                           // add the choice in the original controller
      [self setController:newCtrl];                                 // install the new controller chain
      if (body) body();
      if (onSolution) onSolution();
      [_controller._val succeeds];
   }
   else if ([newCtrl isFinitelyFailed]) {
      [exit letgo];
      [newCtrl release];
      [_controller._val fail];
   }
   else {
      [exit letgo];
      [newCtrl release];
      if (onExit) onExit();
   }
}

// combinator (hence needs to be embedded in top-level search)
// solve the body; Each time a solution is found, execute onSolution; restore the state as before the call; execute onExit at the end

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>) newCtrl
{
   NSCont* exit = [NSCont takeContinuation];
   if ([exit nbCalls]==0) {
      [_controller._val addChoice: exit];
      [self setController:newCtrl];           // install the new controller
      if (body) body();
      if (onSolution) onSolution();
      [_controller._val fail];                // If fail runs out of node, it will trigger finitelyFailed.
   }
   else { // if ([newCtrl isFinitelyFailed]) {
      [exit letgo];
      [newCtrl release];
      if (onExit) onExit();
      // [ldm] we *cannot* fail here. A solveAll always succeeds. This is expected for the parallel code to work fine.
   }
}

-(void) nestedOptimize: (id<ORSolver>) solver using: (ORClosure) search onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   id<ORSearchController> newCtrl = [[ORNestedController alloc] init:[_cFact makeNestedController] parent:_controller._val];
   NSCont* exit = [NSCont takeContinuation];
   if ([exit nbCalls]==0) {
      [_controller._val addChoice: exit];
      [self setController:newCtrl];           // install the new controller
      id<ORObjective> obj = solver.objective;
      OROptimizationController* controller = [[OROptimizationController alloc] initOROptimizationController: ^ORStatus(void) { return [obj check]; }];
      [self push: controller];
      [controller release];
      if (search) search();
      [obj updatePrimalBound];
      if (onSolution) onSolution();
      [_controller._val fail];
   }
   else { // if ([newCtrl isFinitelyFailed]) {
      [exit letgo];
      [newCtrl release];
      if (onExit) onExit();
      // [ldm] we *cannot* fail here. A solveAll always succeeds. This is expected for the parallel code to work fine.
      //[_controller._val fail];
   }
}

-(void)        nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{}
-(void)     nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{}


-(void) optimizeModel: (id<ORSolver>) solver using: (ORClosure) search 
{
   [self search: ^{
      [self nestedOptimize: solver
                     using: ^ { [solver close]; search(); }
                onSolution: ^ { [_engine saveSolution]; }
                    onExit: ^ { [_engine restoreSolution]; }
       ];
   }];
}

-(void) solveModel: (id<ORSolver>) solver using: (ORClosure) search
{
   [self search: ^()
    {
       [self nestedSolve: ^() { [solver close]; search(); }
              onSolution: ^() { [_engine saveSolution]; }
                  onExit: ^() { [_engine restoreSolution]; }];
    }
    ];
}
-(void) solveAllModel: (id<ORSolver>) solver using: (ORClosure) search
{
   [self search: ^()
    {
       [self nestedSolveAll: ^() { [solver close]; search(); }
                 onSolution: ^() { [_engine saveSolution]; }
                     onExit: ^() { [_engine restoreSolution]; }];
    }
    ];
}
@end

@implementation ORExplorerI
-(ORExplorerI*) initORExplorer: (id<OREngine>) engine withTracer: (id<ORTracer>) tracer ctrlFactory:(id<ORControllerFactory>)cFact
{
   self = [super initORExplorer:engine withTracer:tracer ctrlFactory:cFact];
   return self;
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   id<ORSearchController> base    = [_cFact makeNestedController];
   id<ORSearchController> newCtrl = [[ORNestedController alloc] init:base parent:_controller._val];
   [base release];
   [self nestedSolve:body onSolution:onSolution onExit:onExit control:newCtrl];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   id<ORSearchController> base    = [_cFact makeNestedController];
   id<ORSearchController> newCtrl = [[ORNestedController alloc] init:base parent:_controller._val];
   [base release];
   [self nestedSolveAll:body onSolution:onSolution onExit:onExit control:newCtrl];
}
@end

@implementation ORSemExplorerI
-(ORSemExplorerI*) initORExplorer: (id<OREngine>) engine withTracer: (id<ORTracer>) tracer ctrlFactory:(id<ORControllerFactory>)cFact
{
   self = [super initORExplorer:engine withTracer:tracer ctrlFactory:cFact];
   return self;
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   id<ORSearchController> new     = [_cFact makeNestedController];  // The controller to use in the nested search
   id<ORSearchController> root    = [_cFact makeRootController];    // The chronological controller to guarantee correct nesting of nested search
   [self push:root];                                                // Install chronological controller
   id<ORSearchController> nested  = [[ORNestedController alloc] init:new parent:root]; // Setup a nested delegation controller.
   [new release];
   [self nestedSolve:body onSolution:onSolution onExit:onExit control:nested];         // do the nested search controlled by nested(new)
   [self popController];                                                               // pop the chronological controller now that we are done.
   [root release];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   id<ORSearchController> new     = [_cFact makeNestedController];
   id<ORSearchController> root    = [_cFact makeRootController];
   [self push:root];
   id<ORSearchController> nested  = [[ORNestedController alloc] init:new parent:root];
   [new release];
   [self nestedSolveAll:body onSolution:onSolution onExit:onExit control:nested];
   [self popController];
   [root release];
}
@end
