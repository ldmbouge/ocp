/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import "ORCPParSolver.h"
#import <objcp/CPObjectQueue.h>
#import <objcp/CPParallel.h>

@interface ORControllerFactory : NSObject<ORControllerFactory> {
  CPSemanticSolver* _solver;
  Class         _ctrlClass;
  Class         _nestedClass;
}
-(id)initFactory:(CPSemanticSolver*)solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc;
-(id<ORSearchController>)makeRootController;
-(id<ORSearchController>)makeNestedController;
@end

@implementation CPParSolverI {
   CPSemanticSolver** _workers;
   PCObjectQueue*       _queue;
   NSCondition*    _terminated;
   ORInt               _nbDone;
   Class               _defCon;
}
-(id<CPProgram>) initParSolver:(ORInt)nbt withController:(Class)ctrlClass
{
   self = [super init];
   _nbWorkers = nbt;
   _workers   = malloc(sizeof(CPSemanticSolver*)*_nbWorkers);
   _queue = [[PCObjectQueue alloc] initPCQueue:128 nbWorkers:_nbWorkers];
   _terminated = [[NSCondition alloc] init];
   _defCon     = ctrlClass;
   _nbDone     = 0;
   return self;
}
-(void)dealloc
{
   NSLog(@"CPParSolverI (%p) dealloc'd...",self);
   free(_workers);
   [_queue release];
   [_terminated release];
   [super dealloc];
}
-(ORInt)nbWorkers
{
   return _nbWorkers;
}
-(void) waitWorkers
{
   [_terminated lock];
   while (_nbDone < _nbWorkers)
      [_terminated wait];
   [_terminated unlock];
}
-(id<CPCommonProgram>)dereference
{
   return _workers[[NSThread threadID]];
}
-(NSMutableArray*) variables
{
   return [[[self dereference] engine] variables];
}
-(id<CPPortal>) portal
{
   return [[self dereference] portal];
}
-(ORInt) nbFailures
{
  return [[self dereference] nbFailures];
}
-(id<CPEngine>) engine
{
  return [[self dereference] engine];
}
-(id<ORExplorer>) explorer
{
  return [[self dereference] explorer];
}
-(id<ORObjectiveFunction>) objective
{
  return [[self dereference] objective];
}
-(id<ORTracer>) tracer
{
  return [[self dereference] tracer];
}
-(void) close
{
  return [[self dereference] close];
}
-(void) addHeuristic: (id<CPHeuristic>) h
{
  [[self dereference] addHeuristic:h];
}
-(id<ORForall>) forall: (id<ORIntIterator>) S
{
  return [[self dereference] forall:S];
}
-(void) forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
  [[self dereference] forall:S orderedBy:order do:body];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
  [[self dereference] forall:S suchThat:filter orderedBy:order do:body];
}
-(void) forall: (id<ORIntIterator>) S  orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
  [[self dereference] forall:S orderedBy:o1 and:o2 do:b];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
  [[self dereference] forall:S suchThat:suchThat orderedBy:o1 and:o2  do:b];
}
-(void) try: (ORClosure) left or: (ORClosure) right
{
   [[[self dereference] explorer] try: left or: right];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   [[[self dereference] explorer] tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [[[self dereference] explorer] tryall: range suchThat: filter in: body onFailure: onFailure];
}
// Nested
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   [[self dereference] limitTime: maxTime in: cl];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [[self dereference] nestedSolve: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [[self dereference] nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolve: (ORClosure) body
{
   [[self dereference] nestedSolve: body];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [[self dereference] nestedSolveAll: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [[self dereference] nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolveAll: (ORClosure) body
{
   [[self dereference] nestedSolveAll: body];
}
// ********

-(void) labelArray: (id<ORIntVarArray>) x
{
   [[self dereference] labelArray: x];
}
-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy
{
   [[self dereference] labelArray: x orderedBy: orderedBy];
}
-(void) labelHeuristic: (id<CPHeuristic>) h
{
   [[self dereference] labelHeuristic: h];
}
-(void) label: (id<ORIntVar>) mx
{
   [[self dereference] label: mx];
}
-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   [[self dereference] label: var with: val];
}
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   [[self dereference] diff: var with: val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   [[self dereference] lthen: var with: val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   [[self dereference] gthen: var with: val];
}
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   [[self dereference] restrict: var to: S];
}
-(void) fail
{
   [[[self dereference] explorer] fail];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
   [[self dereference] repeat: body onRepeat: onRepeat];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone
{
   [[self dereference] repeat: body onRepeat: onRepeat until: isDone];
}
-(void) once: (ORClosure) cl
{
   [[self dereference] once: cl];
}
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   [[self dereference] limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   [[self dereference] limitCondition: condition in: cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   [[self dereference] limitDiscrepancies: maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   [[self dereference] limitFailures: maxFailures in: cl];
}
-(void) onSolution: (ORClosure) onSol 
{
   for(ORInt k = 0; k < _nbWorkers; k++) 
    [_workers[k] onSolution: onSol];
}
-(void) onExit: (ORClosure) onExit
{
   for(ORInt k = 0; k < _nbWorkers; k++) 
    [_workers[k] onExit: onExit];
}
-(id<ORSolutionPool>) solutionPool
{
   return [[self dereference] solutionPool];
}

-(void)setupWork:(NSData*)root forCP:(CPSemanticSolver*)cp
{
   id<ORProblem> theSub = [SemTracer unpackProblem:root fOREngine:[cp engine]];
   //NSLog(@"***** THREAD(%p) SETUP work: %@",[NSThread currentThread],theSub);
   ORStatus status = [[cp tracer] restoreProblem:theSub inSolver:[cp engine]];
   [theSub release];
   if (status == ORFailure)
      [[cp explorer] fail];
}
-(void)setupAndGo:(NSData*)root forCP:(ORInt)myID searchWith:(ORClosure)body
{
   CPSemanticSolver* me  = _workers[myID];
   id<ORExplorer> ex = [me explorer];
   id<ORSearchController> nested = [[ex controllerFactory] makeNestedController];
   id<ORSearchController> parc = [[CPParallelAdapter alloc] initCPParallelAdapter:nested
                                                                         explorer:me
                                                                           onPool:_queue];
   [nested release];
   id<ORObjectiveFunction> objective = [me objective];
   if (objective != nil) {
      [[me explorer] nestedOptimize: me
                              using: ^ { [self setupWork:root forCP:me]; body(); }
                         onSolution: ^ {
                            //[[me engine] saveSolution];
                            ORInt myBound = [objective primalBound];
                            //[_objective tightenPrimalBound:myBound];
                         }
                             onExit: nil //^ { [[me engine] restoreSolution];}
                            control: parc];
   } else {
      [[me explorer] nestedSolveAll:^() { [self setupWork:root forCP:me];body();}
                         onSolution:nil
                             onExit:nil
                            control:parc];
   }
}

-(void) workerSolve:(NSArray*)input
{
   ORInt myID = [[input objectAtIndex:0] intValue];
   ORClosure mySearch = [input objectAtIndex:1];
   [NSThread setThreadID:myID];
   //[[_workers[myID] explorer] solveModel:_workers[myID] using:mySearch];
   //[[_workers[myID] explorer] performSelector:todo withObject:_workers[myID] withObject:mySearch];
   [[_workers[myID] explorer] search: ^() {
      [_workers[myID] close];
      if (myID == 0) {
         // The first guy produces a sub-problem that is the root of the whole tree.
         id<ORProblem> root = [[_workers[myID] tracer] captureProblem];
         NSData* rootSerial = [root packFromSolver:[_workers[myID] engine]];
         [root release];
         [_queue enQueue:rootSerial];
      }
      NSData* cpRoot = nil;
      while ((cpRoot = [_queue deQueue]) !=nil) {
         [self setupAndGo:cpRoot forCP:myID searchWith:mySearch];
         [cpRoot release];
      }
   }];
   // Final tear down. The worker is done with the model.
   NSLog(@"Worker[%d] = %@",myID,_workers[myID]);
   [_workers[myID] release];
   _workers[myID] = nil;
   [mySearch release];
   [ORFactory shutdown];
   // Possibly notify the main thread if all workers are done.
   [_terminated lock];
   ++_nbDone;
   if (_nbDone == _nbWorkers)
      [_terminated signal];
   [_terminated unlock];
}

-(void) solveAll:(ORClosure)search
{
   for(ORInt i=0;i<_nbWorkers;i++) {
      [NSThread detachNewThreadSelector:@selector(workerSolve:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                         [search copy],nil]];
   }
   [self waitWorkers]; // wait until all the workers are done.
   
}
-(void) solve: (ORClosure) search
{
   for(ORInt i=0;i<_nbWorkers;i++) {
      [NSThread detachNewThreadSelector:@selector(workerSolve:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                         [search copy],nil]];
   }
   [self waitWorkers]; // wait until all the workers are done.
}
@end


// *********************************************************************************************************
// Controller Factory
// *********************************************************************************************************

@implementation ORControllerFactory
-(id)initFactory:(CPSemanticSolver*)solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc
{
  self = [super init];
  _solver = solver;
  _ctrlClass = class;
  _nestedClass = nc;
  return self;
}
-(id<ORSearchController>)makeRootController
{
  return [[_ctrlClass alloc] initTheController:[_solver tracer] engine:[_solver engine]];
}
-(id<ORSearchController>)makeNestedController
{
  return [[_nestedClass alloc] initTheController:[_solver tracer] engine:[_solver engine]];
}
@end
