/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import "ORCPParSolver.h"
#import <ORProgram/CPParallel.h>
#import <ORProgram/CPBaseHeuristic.h>
#import <ORModeling/ORModeling.h>
#import <objcp/CPObjectQueue.h>

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
   id<CPSemanticProgram>* _workers;
   PCObjectQueue*       _queue;
   NSCondition*    _terminated;
   ORInt               _nbDone;
   Class               _defCon;
   BOOL         _doneSearching;
   
   NSCondition*      _allClosed;
   ORInt              _nbClosed;
   id<ORObjectiveValue> _primal;
   BOOL                _boundOk;
}
-(id<CPProgram>) initParSolver:(ORInt)nbt withController:(Class)ctrlClass
{
   self = [super init];
   _nbWorkers = nbt;
   _workers   = malloc(sizeof(id<CPSemanticProgram>)*_nbWorkers);
   memset(_workers,0,sizeof(id<CPSemanticProgram>)*_nbWorkers);
   _queue = [[PCObjectQueue alloc] initPCQueue:128 nbWorkers:_nbWorkers];
   _terminated = [[NSCondition alloc] init];
   _allClosed  = [[NSCondition alloc] init];
   _defCon     = ctrlClass;
   _nbDone     = 0;
   _nbClosed   = 0;
   _boundOk    = NO;
   _primal     = NULL;
   for(ORInt i=0;i<_nbWorkers;i++)
      _workers[i] = [CPSolverFactory semanticSolver:ctrlClass];
   _globalPool = [ORFactory createSolutionPool];
   _onSol = nil;
   _doneSearching = NO;
   return self;
}
-(void)dealloc
{
   NSLog(@"CPParSolverI (%p) dealloc'd...",self);
   free(_workers);
   [_queue release];
   [_terminated release];
   [_allClosed release];
   [_globalPool release];
   [_onSol release];
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
-(void) restartHeuristics
{
   assert(NO);
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
-(id<ORForall>) forall: (id<ORIntIterable>) S
{
  return [[self dereference] forall:S];
}
-(void) forall: (id<ORIntIterable>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
  [[self dereference] forall:S orderedBy:order do:body];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
  [[self dereference] forall:S suchThat:filter orderedBy:order do:body];
}
-(void) forall: (id<ORIntIterable>) S  orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
  [[self dereference] forall:S orderedBy:o1 and:o2 do:b];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
  [[self dereference] forall:S suchThat:suchThat orderedBy:o1 and:o2  do:b];
}
-(void) try: (ORClosure) left or: (ORClosure) right
{
   [[[self dereference] explorer] try: left or: right];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   [[[self dereference] explorer] tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [[[self dereference] explorer] tryall: range suchThat: filter in: body onFailure: onFailure];
}
-(void) trackObject: (id) object
{
   return [[self dereference] trackObject: object];
}
-(void) trackVariable: (id) object
{
   return [[self dereference] trackVariable: object];
}
-(void) trackConstraint:(id)object
{
   return [[self dereference] trackConstraint:object];
}
-(void) addConstraintDuringSearch: (id<ORConstraint>) c annotation:(ORAnnotation)n
{
   [[self dereference] addConstraintDuringSearch: c annotation:n];
}
-(void) addHeuristic:(id<CPHeuristic>)h
{
   assert(FALSE);
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
-(void)onSolution:(ORClosure)onSolution
{
   _onSol = [onSolution copy];
}
-(void) onExit: (ORClosure) onExit
{
   for(ORInt k = 0; k < _nbWorkers; k++) 
    [_workers[k] onExit: onExit];
}
-(void) doOnSolution
{
   _onSol();
}
-(void) doOnExit
{
}

-(id<ORSolutionPool>) solutionPool
{
   return [[self dereference] solutionPool];
}
-(id<ORSolutionPool>) globalSolutionPool
{
   return _globalPool;
}

-(void)setupWork:(NSData*)root forCP:(id<CPSemanticProgram>)cp
{
   id<ORProblem> theSub = [SemTracer unpackProblem:root forEngine:[cp engine]];
   //NSLog(@"***** THREAD(%p) SETUP work: %@",[NSThread currentThread],theSub);
   ORStatus status = [[cp tracer] restoreProblem:theSub inSolver:[cp engine]];
   [theSub release];
   if (status == ORFailure)
      [[cp explorer] fail];
    [cp restartHeuristics];
}
-(void)setupAndGo:(NSData*)root forCP:(ORInt)myID searchWith:(ORClosure)body all:(BOOL)allSols
{
   id<CPSemanticProgram> me  = _workers[myID];
   id<ORExplorer> ex = [me explorer];
   id<ORSearchController> nested = [[ex controllerFactory] makeNestedController];
   id<ORSearchController> parc = [[CPParallelAdapter alloc] initCPParallelAdapter:nested
                                                                         explorer:me
                                                                           onPool:_queue];
   [nested release];
   id<ORObjective> objective = [[me objective] dereference];
   if (objective != nil) {
      [[me explorer] nestedOptimize: me
                              using: ^ { [self setupWork:root forCP:me]; body(); }
                         onSolution: ^ {
                            [self doOnSolution];
                            [me doOnSolution];
                            ORInt myBound = [objective primalBound];
                            for(ORInt w=0;w < _nbWorkers;w++) {
                               if (w == myID) continue;
                               id<ORObjective> wwObj = [[_workers[w] objective] dereference];
                               [wwObj tightenPrimalBound:myBound];
                               //NSLog(@"TIGHT: %@  -- thread %d",wwObj,[NSThread threadID]);
                            }
                         }
                             onExit: nil
                            control: parc];
   } else {
      NSLog(@"ALLSOL IS: %d",allSols);
      if (allSols) {
        [[me explorer] nestedSolveAll:^() { [self setupWork:root forCP:me];body();}
                           onSolution: ^ {
                              [self doOnSolution];
                              [me doOnSolution];
                           }
                               onExit:nil
                              control:parc];
      } else {
        [[me explorer] nestedSolve:^() { [self setupWork:root forCP:me];body();}
                        onSolution: ^ {
                            [self doOnSolution];
                            [me doOnSolution];
                            _doneSearching = YES;
                         }
                             onExit:nil
                            control:parc];        
      }
   }
}

-(void) workerSolve:(NSArray*)input
{
   ORInt myID = [[input objectAtIndex:0] intValue];
   ORClosure mySearch = [input objectAtIndex:1];
   NSNumber* allSols  = [input objectAtIndex:2];
   [NSThread setThreadID:myID];
   _doneSearching = NO;
   [[_workers[myID] explorer] search: ^() {
      [_workers[myID] close];
      // The probing can already tigthen the bound of the objective.
      // We want all the workers to start with the best.
      id<ORObjectiveFunction> ok  = [_workers[myID] objective];
      if (ok) {
         [_allClosed lock];
         if (_nbClosed == 0)
            _primal = [ok value];
         else
            [_primal updateWith:[ok value]];
         while (_nbClosed < _nbWorkers - 1) {
            _nbClosed += 1;
            [_allClosed wait];
         }
         [_allClosed signal];
         if (_boundOk == NO) {
            _boundOk = YES;
            for(ORInt w=0;w < _nbWorkers;w++) {
               id<ORObjective> wwObj = [[_workers[w] objective] dereference];
               [wwObj tightenPrimalBound:[_primal primal]];
            }
         }
         [_allClosed unlock];
      }
      
      if (myID == 0) {
         // The first guy produces a sub-problem that is the root of the whole tree.
         id<ORProblem> root = [[_workers[myID] tracer] captureProblem];
         NSData* rootSerial = [root packFromSolver:[_workers[myID] engine]];
         [root release];
         [_queue enQueue:rootSerial];
      }
      NSData* cpRoot = nil;
      while ((cpRoot = [_queue deQueue]) !=nil) {
         if (!_doneSearching)
            [self setupAndGo:cpRoot forCP:myID searchWith:mySearch all:allSols.boolValue];
         [cpRoot release];
      }
      NSLog(@"IN Queue after leaving: %d (%s)",[_queue size],(_doneSearching ? "YES" : "NO"));
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
                                         [search copy],@(YES),nil]];
   }
   [self waitWorkers]; // wait until all the workers are done.
   
}
-(void) solve: (ORClosure) search
{
   for(ORInt i=0;i<_nbWorkers;i++) {
      [NSThread detachNewThreadSelector:@selector(workerSolve:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                         [search copy],@(NO),nil]];
   }
   [self waitWorkers]; // wait until all the workers are done.
}
-(id<CPHeuristic>) createPortfolio:(NSArray*)hs with:(id<ORVarArray>)vars
{
   assert(FALSE);
   return NULL;
}

-(id<CPHeuristic>) createFF:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createFF:rvars];
  return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createWDeg:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createDDeg:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createIBS:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createABS:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createFF
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createFF];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createWDeg
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createWDeg];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createDDeg
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createDDeg];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createIBS
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createIBS];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createABS
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createABS];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
@end


// *********************************************************************************************************
// Controller Factory
// *********************************************************************************************************

@implementation ORControllerFactory
-(id)initFactory:(CPSemanticSolver*)solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc
{  self = [super init];
  _solver = solver;
  _ctrlClass = class;
  _nestedClass = nc;
  return self;}
-(id<ORSearchController>)makeRootController
{
  return [[_ctrlClass alloc] initTheController:[_solver tracer] engine:[_solver engine]];
}-(id<ORSearchController>)makeNestedController
{
  return [[_nestedClass alloc] initTheController:[_solver tracer] engine:[_solver engine]];
}
@end
