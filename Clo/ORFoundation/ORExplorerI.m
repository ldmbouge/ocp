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
   //[_engine clearStatus];
   [_controller._val fail];
   assert(FALSE);
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
      // [ldm] In the case of an optimization, the startTryRight will enforce the primalBound and _may_ fail as as
      // result. Hence, we are not even guaranteed to reach the call to right() and we must letgo of the continuation
      // now or face memory leaks. *do not move the letgo further down*
      [k letgo];
      [_controller._val startTryRight];
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

struct TAOutput {
   ORInt value;
   BOOL  found;
};

struct TAOutput nextTAValue(id<IntEnumerator> ite,ORInt2Bool filter)
{
   ORInt value;
   BOOL found = [ite more];
   if(found) {
      value = [ite next];
      if (filter)
         while (!filter(value)) {
            if (![ite more]) {
               found = NO;
               break;
            }
            value = [ite next];
         }
   }
   return (struct TAOutput){value,found};
}

-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   assert([_engine status] != ORFailure);
   [_controller._val startTryall];
   assert([_engine status] != ORFailure);
   id<IntEnumerator> ite = [ORFactory intEnumerator: _engine over: range];
   // The [ite release] inserted on the trail will _not_ necessarily occur last but it will
   // consume one reference to ite, so it matches the "initial" reference.
   // Every subsequence "try" retains (increases by 1) and is matched by a trailRelease that
   // releases (decreased by 1) upon failure. So if the onfailure succeeds, it remembers it will
   // have to eventually release and it proceeds to the next iteration where the number of references
   // increases again. Naturally the subsequent retain are matched by their own releases, so it all
   // pans out. 
   struct TAOutput nv = nextTAValue(ite, filter);
   while (nv.found) {
      NSCont* k = [NSCont takeContinuation];
      if ([k nbCalls] == 0) {
         assert([_engine status] != ORFailure);
         [_controller._val startTryallBody];
         _nbc++;
         // We must retain the iterator here so that the failure block can have an unconditional release.
         [ite retain];
         [_controller._val addChoice: k];
         body(nv.value);
         [_controller._val exitTryallBody];
         break;
      }
      else {
         NSThread* me = [NSThread currentThread];
         assert([_engine status] != ORFailure);
         // [ldm] In the case of an optimization, the startTryRight will enforce the primalBound and _may_ fail as as
         // result. Hence, we are not even guaranteed to reach the call to right() and we must letgo of the continuation
         // now or face memory leaks. *do not move the letgo further down*
         [k letgo];
         // We must trust to increase the choice point identifier or the semantic path are all busted and the suffix
         // deconstruction fails.
         [_controller._val trust];
         [_controller._val startTryallOnFailure];
         // The continuation is used only twice, so we are guaranteed that it is safe and correct to letgo now. 
         [_trail trailRelease:ite];
         if (onFailure)
            onFailure(nv.value);
         // There is a caveat here. We can call "startTryallOnFailure" but *never* call its matching "exitTRyallOnFailure"
         // It all depends on the semantics we assign to this pair. Do we wish to guarantee that both are called? or that
         // the exit is called only when the onFailure succeeded?
         [_controller._val exitTryallOnFailure];
         nv = nextTAValue(ite, filter);
         if (!nv.found)
            [_controller._val fail];
      }
   }
   // A release here *should not* be necessary. Even if the filtered range is empty, the initial delayed release
   // will occur upon backtrack.
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
         // [ldm] Do *not* letgo of exit here. The cleanup call will do this automatically.
         //[exit letgo];
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

-(void) nestedOptimize: (id<ORSolver>) solver using: (ORClosure) search
            onSolution: (ORClosure) onSolution
                onExit: (ORClosure) onExit
               control:(id<ORSearchController>) newCtrl
{
   NSCont* exit = [NSCont takeContinuation];
   if ([exit nbCalls]==0) {
      [_controller._val addChoice: exit];
      [self setController:newCtrl];           // install the new controller
      id<ORObjective> obj = solver.objective;
      assert(obj);
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
-(void)     nestedOptimize: (id<ORSolver>) solver using: (ORClosure) search onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
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
-(void) nestedOptimize: (id<ORSolver>) solver using: (ORClosure) search onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   id<ORSearchController> new    = [_cFact makeNestedController];
   id<ORSearchController> nested = [[ORNestedController alloc] init:new parent:_controller._val];
   [new release];
   [self nestedOptimize:solver using:search onSolution:onSolution onExit:onExit control:nested];
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
-(void) nestedOptimize: (id<ORSolver>) solver using: (ORClosure) search onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   id<ORSearchController> new     = [_cFact makeNestedController];
   id<ORSearchController> root    = [_cFact makeRootController];
   [self push:root];
   id<ORSearchController> nested = [[ORNestedController alloc] init:new parent:_controller._val];
   [new release];
   [self nestedOptimize:solver using:search onSolution:onSolution onExit:onExit control:nested];
   [self popController];
   [root release];
}
@end
