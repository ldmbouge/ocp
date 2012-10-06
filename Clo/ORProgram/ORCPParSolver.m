/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


//#import "CPParSolver.h"
/*
@implementation CPParSolverI {
   id<CPSemSolver>*  _workers;
   PCObjectQueue*      _queue;
   NSCondition*   _terminated;
   ORInt              _nbDone;
   Class              _defCon;
}
-(CPParSolverI*) initForWorkers:(ORInt)nbt withController:(Class)ctrlClass
{
   self = [super init];
   _nbWorkers = nbt;
   _workers   = malloc(sizeof(id<CPSemSolver>)*_nbWorkers);
   _queue = [[PCObjectQueue alloc] initPCQueue:128 nbWorkers:_nbWorkers];
   _terminated = [[NSCondition alloc] init];
   _defCon     = ctrlClass;
   _nbDone     = 0;
   return self;
}
-(CPCoreSolverI*)         initFor: (CPEngineI*) fdm
{
   self = [super initFor:fdm];
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
-(void)waitWorkers
{
   [_terminated lock];
   while (_nbDone < _nbWorkers)
      [_terminated wait];
   [_terminated unlock];
}
-(void) addModel: (id) model
{
   [model instantiate: self];
   NSMutableArray* vars = [[NSMutableArray alloc] initWithCapacity:8];
   NSMutableArray* cons = [[NSMutableArray alloc] initWithCapacity:8];
   __block id obj = nil;
   // First, copy the "parallel" variables / constraints into a data structure on the side.
   [model applyOnVar:^(id v) {
      [vars addObject:[v impl]];
      [v setImpl:nil];
   }  onObjects:^(id o) {
   } onConstraints:^(id c) {
      [cons addObject:[c impl]];
      [c setImpl:nil];
   } onObjective:^(id o) {
      obj = [o impl];
      [o setImpl:nil];
   }];
   // Now loop _nbWorkers times and instantiate using a bare concretizer
   for(ORInt i=0;i<_nbWorkers;i++) {
      _workers[i] = [CPFactory createSemSolver:_defCon];     // _defCon will be the nested controller factory for _workers[i]
      [model instantiate:_workers[i]];
      [model applyOnVar:^(id v) {
         ORParIntVarI* pari = [vars objectAtIndex:[v getId]];
         [pari setConcrete:i to:(id<ORIntVar>)[v dereference]];
         [v setImpl:nil];
      }  onObjects:^(id o) {
         
      } onConstraints:^(id c) {
         ORParConstraintI* parc = [cons objectAtIndex:[c getId]];
         [parc setConcrete:i to:(id<ORConstraint>)[c dereference]];
         [c setImpl:nil];
      }onObjective:^(id o) {
         ORParObjectiveI* pobj = obj;
         [pobj setConcrete:i to:(id<ORObjective>)[o dereference]];
         [o setImpl:nil];
      }];
   }
   // Now put the parallel dispatchers back inside the modeling objects.
   [model applyOnVar:^(id v) {
      [v setImpl:[vars objectAtIndex:[v getId]]];
   }  onObjects:^(id o) {
      
   } onConstraints:^(id c) {
      [c setImpl:[cons objectAtIndex:[c getId]]];
   } onObjective:^(id o) {
      [o setImpl: obj];
   }];
   _objective = obj;
   [vars release];
   [cons release];
}
-(id<CPSolver>)dereference
{
   return _workers[[NSThread threadID]];
}
-(NSMutableArray*) allVars
{
   return [[[self dereference] engine] allVars];
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
-(void) label: (CPIntVarI*) var with: (ORInt) val
{
   [[self dereference] label:[var dereference] with:val];
}
-(void) diff: (CPIntVarI*) var with: (ORInt) val
{
   [[self dereference] diff:[var dereference] with:val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   [[self dereference] lthen:[var dereference] with:val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   [[self dereference] gthen:[var dereference] with:val];
}
-(void) fail
{
   [[[self dereference] explorer] fail];
}
-(void)setupWork:(NSData*)root forCP:(id<CPSemSolver>)cp
{
   id<ORProblem> theSub = [SemTracer unpackProblem:root fOREngine:cp];
   //NSLog(@"***** THREAD(%p) SETUP work: %@",[NSThread currentThread],theSub);
   ORStatus status = [cp installProblem:theSub];
   [theSub release];
   if (status == ORFailure)
      [[cp explorer] fail];
}
-(void)setupAndGo:(NSData*)root forCP:(ORInt)myID searchWith:(ORClosure)body
{
   id<CPSemSolver> me  = _workers[myID];
   ORExplorerI* ex = [me explorer];
   id<ORSearchController> nested = [[ex controllerFactory] makeNestedController];
   id<ORSearchController> parc = [[CPParallelAdapter alloc] initCPParallelAdapter:nested
                                                                         explorer:me
                                                                           onPool:_queue];
   [nested release];
   if (_objective != nil) {
      [[me explorer] nestedOptimize: me
                              using: ^ { [self setupWork:root forCP:me]; body(); }
                         onSolution: ^ {
                            //[[me engine] saveSolution];
                            ORInt myBound = [[me objective] primalBound];
                            [_objective tightenPrimalBound:myBound];
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
   [CPFactory shutdown];
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
*/
