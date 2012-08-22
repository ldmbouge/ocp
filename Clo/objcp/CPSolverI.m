/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORUtilities/ORUtilities.h"
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORExplorerI.h>
#import <ORFoundation/ORController.h>
#import <ORFoundation/ORSemDFSController.h>
#import "ORTrailI.h"
#import "CPCommand.h"
#import "CPConstraintI.h"
#import "CPSolverI.h"
#import "CPEngineI.h"
#import "ORExplorer.h"
#import "CPBasicConstraint.h"
#import "CPIntVarI.h"
#import "pthread.h"
#import "CPObjectQueue.h"
#import "CPParallel.h"

@implementation CPHeuristicStack
-(CPHeuristicStack*)initCPHeuristicStack
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
   for(ORUInt k=0;k<_sz;k++)
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
   for(ORUInt k=0;k<_sz;k++)
      closure(_tab[k],av);
}
@end

@interface CPInformerPortal : NSObject<CPPortal> {
   CPCoreSolverI*  _cp;
   CPEngineI*  _solver;
}
-(CPInformerPortal*) initCPInformerPortal:(id<CPSolver>) cp;
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

@implementation CPCoreSolverI
-(id) init
{
   self = [super init];
   _trail = [[ORTrailI alloc] init];
   _engine = [[CPEngineI alloc] initSolver: _trail];
   _pool = [[NSAutoreleasePool alloc] init];
   _hStack = [[CPHeuristicStack alloc] initCPHeuristicStack];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal:self];
   _objective = nil;
   _closed = false;
   
   return self;
}
-(id) initFor:(CPEngineI*)fdm
{
   self = [super init];
   _engine = [fdm retain];
   _trail = [[fdm trail] retain];
   _pool = [[NSAutoreleasePool alloc] init];
   _hStack = [[CPHeuristicStack alloc] initCPHeuristicStack];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal:self];
   _objective = nil;
   _closed = false;
   return self;
}

-(void) dealloc
{
   NSLog(@"CPCoreSolver (%p) dealloc called...\n",self);
   [_trail release];
   [_engine release];
   [_search release];
   [_hStack release];
   [_portal release];
   [_returnLabel release];
   [_failLabel release];
   [super dealloc]; 
}
-(void) addHeuristic: (id<CPHeuristic>)h
{
   [_hStack push:h];
}

-(id<ORSolver>) solver
{
   return self;
}
-(id<CPEngine>) engine
{
   return _engine;
}
-(id<ORExplorer>) explorer
{
   return _search;
}
-(id<ORObjective>) objective
{
   return _objective;
}
-(void) setObjective: (id<ORObjective>) o
{
   _objective = o;
}
-(id<ORSearchController>) controller
{
    return [_search controller];
}
-(id)virtual:(id)obj
{
   return [_engine virtual:obj];
}

-(NSString*) description
{
   return [NSString stringWithFormat:@"Solver: %d vars\n\t%d choices\n\t%d fail\n\t%d propagations",[_engine nbVars],[_search nbChoices],[_search nbFailures],[_engine nbPropagation]];
}
-(ORUInt) nbPropagation
{
   return [_engine nbPropagation];
}
-(ORUInt) nbVars
{
   return [_engine nbVars];
}

-(NSMutableArray*) allVars
{
   return [_engine allVars];
}
-(ORInt) nbChoices
{
   return [_search nbChoices];
}
-(ORInt) nbFailures
{
   return [_search nbFailures];
}
-(id<ORTrail>) trail
{
   return _trail;
}
-(void) saveSolution
{
   [_engine saveSolution];
}
-(void) restoreSolution;
{
   [_engine restoreSolution];
}
-(id<ORSolution>) solution
{
   return [_engine solution];
}
-(void) try: (ORClosure) left or: (ORClosure) right 
{
   [_search try: left or: right];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   [_search tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [_search tryall: range suchThat: filter in: body onFailure: onFailure];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: filter orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: nil orderedBy: order do: body];
}

-(void) fail
{
    [_search fail];
}
-(void) setController: (id<ORSearchController>) controller
{
   [_search setController: controller];
}
-(void) push: (id<ORSearchController>) controller
{
   [_search push: controller];
}

-(void) add: (id<ORConstraint>) c
{
    if ([[c class] conformsToProtocol:@protocol(ORRelation)]) {
       c = [_engine wrapExpr: self for: (id<ORRelation>)c consistency:ValueConsistency];
   }
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) add: (id<ORConstraint>) c consistency:(CPConsistency)cons
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)]) {
      c = [_engine wrapExpr: self for: (id<ORRelation>)c consistency:cons];
   }
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}

-(void) minimize: (id<ORIntVar>) x
{
   CPIntVarMinimize* cstr = (CPIntVarMinimize*) [CPFactory minimize: x];
   [self add: cstr];
   _objective = cstr;
}
-(void) maximize: (id<ORIntVar>) x
{
   CPIntVarMaximize* cstr = (CPIntVarMaximize*) [CPFactory maximize: x];
   [self add: cstr];
   _objective = cstr;
}
-(void) solve: (ORClosure) search
{
   if (_objective != nil) {
      [_search optimizeModel: self using: search];
      printf("Optimal Solution: %d \n",[_objective primalBound]);
   }
   else {
      [_search solveModel: self using: search];
   }
}
-(void) solveAll: (ORClosure) search
{
   [_search solveAllModel: self using: search];
}
-(void) state
{
   [_search solveModel: self using: ^{}];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   // The idea is that we only encode the solver and an empty _shell_ (no content) of the trail
   // The decoding recreates the pool. 
   [aCoder encodeObject:_engine];
   [aCoder encodeObject:_trail];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super init];
   _engine = [[aDecoder decodeObject] retain];
   _trail  = [[aDecoder decodeObject] retain];
   _pool = [[NSAutoreleasePool alloc] init];
   return self;
}
-(void) close
{
   if (!_closed) {
      _closed = true;
      if ([_engine close] == ORFailure)
         [_search fail];
      [_hStack applyToAll:^(id<CPHeuristic> h,NSMutableArray* av) { [h initHeuristic:av];}
                     with: [_engine allVars]];
      [ORConcurrency pumpEvents];
   }
}
-(BOOL) closed
{
   return _closed;
}
-(id<ORIdxIntInformer>) retLabel
{
   if (_returnLabel==nil) 
      _returnLabel = [ORConcurrency idxIntInformer];   
   return _returnLabel;
}
-(id<ORIdxIntInformer>) failLabel
{
   if (_failLabel==nil) 
      _failLabel = [ORConcurrency idxIntInformer];   
   return _failLabel;   
}
-(id<CPPortal>)portal
{
   return _portal;
}
-(void) trackObject:(id)object
{
   [_engine trackObject:object];
}
-(void) trackVariable:(id)object
{
   [_engine trackVariable:object];
}
-(ORInt)virtualOffset:(id)obj
{
   return [_engine virtualOffset:obj];
}

-(void) label: (CPIntVarI*) var with: (ORInt) val
{
   ORStatus status = [_engine label: [var dereference] with: val];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents]; 
}
-(void) diff: (CPIntVarI*) var with: (ORInt) val
{
   ORStatus status = [_engine diff: [var dereference] with: val];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];   
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine lthen:var with: val];
   if (status == ORFailure) {
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine gthen:var with:val];
   if (status == ORFailure) {
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}

-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
    ORStatus status = [_engine restrict: var to: S];
    if (status == ORFailure)
        [_search fail]; 
    [ORConcurrency pumpEvents];   
}

-(void) once: (ORClosure) cl
{
  [_search once: cl];
}

-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   [_search limitCondition: condition in:cl];
}
-(void) limitSolutions: (ORInt) nb in: (ORClosure) cl
{
   [_search limitSolutions: nb in: cl];
}

-(void) limitDiscrepancies: (ORInt) nb in: (ORClosure) cl
{
  [_search limitDiscrepancies: nb in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
  [_search limitFailures: maxFailures in: cl];
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
  [_search limitTime: maxTime in: cl];
}
-(void) applyController: (id<ORSearchController>) controller in: (ORClosure) cl
{
   [_search applyController: controller in: cl];
}

// pvh: this nested controller should be created in the nested solve
-(void) nestedSolve: (ORClosure) body
{
  [_search nestedSolve: body onSolution:nil onExit:nil 
               control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
{
  [_search nestedSolve: body onSolution: onSolution onExit:nil 
               control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolve: body onSolution: onSolution onExit: onExit 
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body
{
  [_search nestedSolveAll: body onSolution:nil onExit:nil 
                  control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
{
   [_search nestedSolveAll: body onSolution: onSolution onExit:nil 
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
  [_search nestedSolveAll: body onSolution: onSolution onExit: onExit 
                  control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}

-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
  [_search repeat: body onRepeat: onRepeat until: nil];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone
{
  [_search repeat: body onRepeat: onRepeat until: isDone];
}
-(id<ORTracer>)tracer
{
   return nil;
}
-(CPConcretizerI*) concretizer
{
   return [[CPConcretizerI alloc] initCPConcretizerI: self];
}
-(void) addModel: (id<ORModel>) model
{
   [model instantiate: self];
}
@end

@interface ORControllerFactory : NSObject<ORControllerFactory> {
   CPSemSolverI* _solver;
   Class         _ctrlClass;
   Class         _nestedClass;
}
-(id)initFactory:(CPCoreSolverI*)solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc;
-(id<ORSearchController>)makeRootController;
-(id<ORSearchController>)makeNestedController;
@end

// *********************************************************************************************************
// CPSolver
// *********************************************************************************************************

@implementation CPSolverI
-(CPSolverI*)             init
{
   self = [super init];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
                                                        rootControllerClass:[ORDFSController class]
                                                      nestedControllerClass:[ORDFSController class]];
   _search = [[ORExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
   [cFact release];
   return self;
}
-(CPCoreSolverI*)         initFor: (CPEngineI*) fdm
{
   self = [super initFor:fdm];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
                                                        rootControllerClass:[ORDFSController class]
                                                      nestedControllerClass:[ORDFSController class]];
   _search = [[ORExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
   [cFact release];
   return self;
}
-(id<ORTracer>) tracer
{
   return _tracer;
}
-(void)dealloc
{
   [_tracer release];
   [super dealloc];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   // The idea is that we only encode the solver and an empty _shell_ (no content) of the trail
   // The decoding recreates the pool.
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
                                                        rootControllerClass:[ORDFSController class]
                                                      nestedControllerClass:[ORDFSController class]];
   _search = [[ORExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
   [cFact release];
   return self;
}
@end

// ****************************************************************************************************************************
// Semantic Solver
// ****************************************************************************************************************************

@implementation CPSemSolverI 
-(CPSemSolverI*) initWithController:(Class)ctrlClass
{
   self = [super init];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
                                                        rootControllerClass:[ORSemDFSController class]
                                                      nestedControllerClass:ctrlClass];
   _search = [[ORExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
   [cFact release];
   return self;
}
-(CPCoreSolverI*) initFor: (CPEngineI*) fdm withController:(Class)ctrlClass
{
   self = [super initFor:fdm];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
                                                        rootControllerClass:[ORSemDFSController class]
                                                      nestedControllerClass:ctrlClass];
   _search = [[ORExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
   [cFact release];
   return self;
}
-(id<ORTracer>) tracer
{
   return _tracer;
}
-(void)dealloc
{
   [_tracer release];
   [super dealloc];
}
-(void) label: (CPIntVarI*) var with: (ORInt) val
{
   ORStatus status = [_engine label: var with: val];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_tracer addCommand:[[CPEqualc alloc] initCPEqualc:var and:val]];    // add after the fail (so if we fail, we don't bother adding it!]
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diff: (CPIntVarI*) var with: (ORInt) val
{
   ORStatus status = [_engine diff: var with: val];
   if (status == ORFailure)
      [_search fail];
   // add after the fail (so if we fail, we don't bother adding it!]
   [_tracer addCommand:[[CPDiffc alloc] initCPDiffc:var and:val]];
   [ORConcurrency pumpEvents];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
                                                        rootControllerClass:[ORSemDFSController class]
                                                      nestedControllerClass:[ORSemDFSController class]];
   _search = [[ORExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
   [cFact release];
   return self;
}
-(ORStatus)installCheckpoint:(id<ORCheckpoint>)cp
{
   return [_tracer restoreCheckpoint:cp inSolver:_engine];
}
-(ORStatus)installProblem:(id<ORProblem>)problem
{
   return [_tracer restoreProblem:problem inSolver:_engine];
}
-(id<ORCheckpoint>)captureCheckpoint
{
   return [_tracer captureCheckpoint];
}
-(NSData*)packCheckpoint:(id<ORCheckpoint>)cp
{
   id<ORCheckpoint> theCP = [_tracer captureCheckpoint];
   NSData* thePack = [theCP packFromSolver:_engine];
   [theCP release];
   return thePack;
}
@end

// *********************************************************************************************************
// Controller Factory
// *********************************************************************************************************

@implementation ORControllerFactory
-(id)initFactory:(CPSemSolverI*)solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc
{
   self = [super init];
   _solver = solver;
   _ctrlClass = class;
   _nestedClass = nc;
   return self;
}
-(id<ORSearchController>)makeRootController
{
   return [[_ctrlClass alloc] initSemController:_solver];
}
-(id<ORSearchController>)makeNestedController
{
   return [[_nestedClass alloc] initSemController:_solver];
}
@end

@implementation NSThread (ORData)

static pthread_key_t threadIDKey;
static pthread_once_t block = PTHREAD_ONCE_INIT;

static void init_pthreads_key()
{
   pthread_key_create(&threadIDKey,NULL);
}
+(void)setThreadID:(ORInt)tid
{
   pthread_once(&block,init_pthreads_key);
   pthread_setspecific(threadIDKey,(void*)tid);
}
+(ORInt)threadID
{
   pthread_once(&block,init_pthreads_key);
   ORInt tid = (ORInt)pthread_getspecific(threadIDKey);
   return tid;
}
@end

@interface ORParIntVarI : ORExprI<ORIntVar> {
   id<ORIntVar>* _concrete;
   ORInt               _nb;
}
-(ORParIntVarI*)init:(ORInt)nb;
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds)bounds;
-(BOOL) member: (ORInt) v;
-(BOOL) isBool;
-(id<ORIntVar>) dereference;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(void)setConcrete:(ORInt)k to:(id<ORIntVar>)v;
@end

@interface ORParConstraintI : NSObject<ORConstraint> {
   id<ORConstraint>* _concrete;
   ORInt                   _nb;
   ORInt                   _id;
}
-(ORParConstraintI*) initORParConstraintI:(ORInt)nb;
-(void) setId: (ORUInt) name;
-(ORInt)getId;
-(void)setConcrete:(ORInt)k to:(id<ORConstraint>)c;
-(id<ORConstraint>)dereference;
-(void) concretize: (id<ORSolverConcretizer>) concretizer;
@end

@interface ORParIdArrayI : NSObject<ORIdArray> {
   id<ORIdArray>*    _concrete;
   ORInt                   _nb;
}
-(ORParIdArrayI*) initORParIdArrayI:(ORInt)nb;
-(void)setConcrete:(ORInt)k to:(id<ORIdArray>)c;
-(id<ORIdArray>)dereference;
-(void) concretize: (id<ORSolverConcretizer>) concretizer;
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(id)objectAtIndexedSubscript:(NSUInteger)key;
-(void)setObject:(id)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntRange>) range;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

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
-(id<ORSolverConcretizer>) concretizer
{
   return [[CPParConcretizerI alloc] initCPParConcretizerI: self];
}
-(void)dealloc
{
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
-(void) addModel: (id<ORModel>) model
{
   [model instantiate: self];
   NSMutableArray* vars = [[NSMutableArray alloc] initWithCapacity:8];
   NSMutableArray* cons = [[NSMutableArray alloc] initWithCapacity:8];
   // First, copy the "parallel" variables / constraints into a data structure on the side.
   [model applyOnVar:^(id v) {
      [vars addObject:[v impl]];
      [v setImpl:nil];
   }  onObjects:^(id o) {
      
   } onConstraints:^(id c) {
      [cons addObject:[c impl]];
      [c setImpl:nil];
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
      }];
   }
   // Now put the parallel dispatchers back inside the modeling objects.
   [model applyOnVar:^(id v) {
      [v setImpl:[vars objectAtIndex:[v getId]]];
   }  onObjects:^(id o) {
      
   } onConstraints:^(id c) {
      [c setImpl:[cons objectAtIndex:[c getId]]];
   }];
   [vars release];
   [cons release];
}
-(id<CPSolver>)dereference
{
   return _workers[[NSThread threadID]];
}
-(void) try: (ORClosure) left or: (ORClosure) right
{
   [[[self dereference] explorer] try: left or: right];
}
-(void) label: (CPIntVarI*) var with: (ORInt) val
{
   [[self dereference] label:var with:val];
}
-(void) diff: (CPIntVarI*) var with: (ORInt) val
{
   [[self dereference] diff:var with:val];
}
-(void)setupWork:(NSData*)root forCP:(id<CPSemSolver>)cp
{
   id<ORProblem> theSub = [[SemTracer unpackProblem:root fOREngine:cp] retain];
   ORStatus status = [cp installProblem:theSub];
   [theSub release];
   if (status == ORFailure)
      [[cp explorer] fail];
}
-(void)setupAndGo:(NSData*)root forCP:(ORInt)myID searchWith:(ORClosure)body
{
   id<ORProblem> theSub = [SemTracer unpackProblem:root fOREngine:_workers[myID]];
   id<CPSemSolver> me  = _workers[myID];
   ORExplorerI* ex = [me explorer];
   id<ORSearchController> nested = [[ex controllerFactory] makeNestedController];
   id<ORSearchController> parc = [[CPParallelAdapter alloc] initCPParallelAdapter:nested
                                                                         explorer:me
                                                                           onPool:_queue];
   [nested release];
   [[me explorer] nestedSolveAll:^() {  [self setupWork:root forCP:me];
                                          body();
                                     }
                                  onSolution:nil
                                      onExit:nil
                                     control:parc];
   //NSLog(@"BACK from subproblem [%@]",theSub);
   [theSub release];
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
   assert(_objective == nil); // [ldm] why is the objective embedded in the solver and *not* in the model?
   for(ORInt i=0;i<_nbWorkers;i++) {
      [NSThread detachNewThreadSelector:@selector(workerSolve:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                                                  [search copy],nil]];
   }
   [self waitWorkers]; // wait until all the workers are done. 
/*
   if (_objective != nil) {
      [_search optimizeModel: self using: search
                  onSolution: ^() { [_engine saveSolution]; }
                      onExit: ^() { [_engine restoreSolution]; }];
      NSLog(@"Optimal Solution: %d \n",[_objective primalBound]);
   }
   else {
      [_search solveModel: self using: search];
   }*/
}
@end

@implementation CPInformerPortal
-(CPInformerPortal*) initCPInformerPortal: (id<CPSolver>) cp
{
   self = [super init];
   _cp = cp;
   _solver = (CPEngineI*)[cp engine];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<ORIdxIntInformer>) retLabel
{
   return [_cp retLabel];
}
-(id<ORIdxIntInformer>) failLabel
{
   return [_cp failLabel];
}
-(id<ORInformer>) propagateFail
{
   return [_solver propagateFail];
}
-(id<ORInformer>) propagateDone
{
   return [_solver propagateDone];
}
@end

@implementation CPConcretizerI
{
   id<CPSolver> _solver;
}
-(CPConcretizerI*) initCPConcretizerI: (id<CPSolver>) solver
{
   self = [super init];
   _solver = solver;
   return self;
}
-(id<ORIntVar>) intVar: (ORIntVarI*) v
{
   return [CPFactory intVar: _solver domain: [v domain]];
}
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v
{
   id<ORIntVar> mBase = [v base];
   ORInt a = [v scale];
   ORInt b = [v shift];
   return [CPFactory intVar:[mBase dereference] scale:a shift:b];
}
-(id<ORConstraint>) alldifferent: (ORAlldifferentI*) cstr
{
   id<ORIntVarArray> dx = [ORFactory intVarArrayDereference: _solver array: [cstr array]];
   id<ORConstraint> ncstr = [CPFactory alldifferent: _solver over: dx];
   [_solver add: ncstr];
   return ncstr;
}
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr
{
   id<ORIntVarArray> ditem = [ORFactory intVarArrayDereference: _solver array: [cstr item]];
   id<ORIntVarArray> dbinSize = [ORFactory intVarArrayDereference: _solver array: [cstr binSize]];
   id<ORConstraint> ncstr = [CPFactory packing: ditem itemSize: [cstr itemSize] load: dbinSize];
   [_solver add: ncstr];
   return ncstr;
}
-(id<ORConstraint>) algebraicConstraint: (ORAlgebraicConstraintI*) cstr
{
   id<ORConstraint> c = [CPFactory relation2Constraint:_solver expr: [cstr expr]];
   [_solver add: c];
   return c;
}
-(id<ORIdArray>) idArray: (id<ORIdArray>) a
{
   id<ORIntRange> R = [a range];
   id<ORIdArray> impl = [ORFactory idArray: _solver range: R];
   ORInt low = R.low;
   ORInt up = R.up;
   for(ORInt i = low; i <= up; i++) {
      [a[i] concretize: self];
      impl[i] = [a[i] dereference];
   }
   return impl;
}
-(void) expr: (id<ORExpr>) e
{
   
}
@end
// =======================================================================

@implementation ORParIntVarI
-(ORParIntVarI*)init:(ORInt)nb
{
   self = [super init];
   _nb = nb;
   _concrete = malloc(sizeof(id<ORIntVar>)*_nb);
   return self;
}
-(void)dealloc
{
   free(_concrete);
   [super dealloc];
}
-(void)setConcrete:(ORInt)k to:(id<ORIntVar>)v
{
   _concrete[k] = v;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"PAR(%d)[",_nb];
   for(int k=0;k<_nb;k++)
      [buf appendFormat:@"%@%c",_concrete[k],k<_nb-1 ? ',' : ']'];   
   return buf;
}
-(ORUInt) getId
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] getId];
}
-(BOOL) bound
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] bound];
}
-(id<ORSolver>) solver
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] solver];
}
-(NSSet*)constraints
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] constraints];
}
-(id<ORIntRange>) domain
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] domain];
}
-(ORInt) value
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] value];
}
-(ORInt) min
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] min];
}
-(ORInt) max
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] max];
}
-(ORInt) domsize
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] domsize];
}
-(ORBounds)bounds
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] bounds];
}
-(BOOL) member: (ORInt) v
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] member:v];
}
-(BOOL) isBool
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return [_concrete[tid] isBool];
}
-(id<ORIntVar>) dereference
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return _concrete[tid];
}
-(ORInt)scale
{
   return 1;
}
-(ORInt)shift
{
   return 0;
}
-(id<ORIntVar>)base
{
   return self;
}
@end

@implementation ORParConstraintI
-(ORParConstraintI*) initORParConstraintI:(ORInt)nbc
{
   self = [super init];
   _nb = nbc;
   _concrete = malloc(sizeof(id<ORConstraint>)*_nb);
   return self;
}
-(void) setId: (ORUInt) name
{
   _id = name;
}
-(ORInt)getId
{
   return _id;
}
-(void)setConcrete:(ORInt)k to:(id<ORConstraint>)c
{
   _concrete[k] = c;
}
-(id<ORConstraint>)dereference
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return _concrete[tid];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"PAR(%d)[",_nb];
   for(int k=0;k<_nb;k++)
      [buf appendFormat:@"%@%c",_concrete[k],k<_nb-1 ? ',' : ']'];
   return buf;
}
-(void) concretize: (id<ORSolverConcretizer>) concretizer
{
   @throw [[ORExecutionError alloc] initORExecutionError:"Should never concrete a par-constraint"];
}
@end

@implementation ORParIdArrayI
-(ORParIdArrayI*) initORParIdArrayI:(ORInt)nbc
{
   self = [super init];
   _nb = nbc;
   _concrete = malloc(sizeof(id<ORIdArray>)*_nb);
   return self;
}
-(void)setConcrete:(ORInt)k to:(id<ORIdArray>)c
{
   _concrete[k] = c;
}
-(id<ORIdArray>)dereference
{
   ORInt tid = [NSThread threadID];
   assert(tid >= 0 && tid < _nb);
   return _concrete[tid];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"PAR(%d)[",_nb];
   for(int k=0;k<_nb;k++)
      [buf appendFormat:@"%@%c",_concrete[k],k<_nb-1 ? ',' : ']'];
   return buf;
}
-(void) concretize: (id<ORSolverConcretizer>) concretizer
{
   @throw [[ORExecutionError alloc] initORExecutionError:"Should never concrete a par-constraint"];
}

-(id) at: (ORInt) value
{
   return [[self dereference] at:value];
}
-(void) set: (id) x at: (ORInt) value
{
   [[self dereference] set:x at:value];
}
-(id)objectAtIndexedSubscript:(NSUInteger)key
{
   return [[self dereference] objectAtIndexedSubscript:key];
}
-(void)setObject:(id)newValue atIndexedSubscript:(NSUInteger)idx
{
   [[self dereference] setObject:newValue atIndexedSubscript:idx];
}
-(ORInt) low
{
   return [[self dereference] low];
}
-(ORInt) up
{
   return [[self dereference] up];
}
-(id<ORIntRange>) range
{
   return [[self dereference] range];
}
-(NSUInteger)count
{
   return [[self dereference] count];
}
-(id<ORTracker>) tracker
{
   return [[self dereference] tracker];
}
@end

@implementation CPParConcretizerI {
   id<CPParSolver> _solver;
   CPConcretizerI* _cc;
}
-(CPParConcretizerI*) initCPParConcretizerI: (id<CPParSolver>) solver
{
   self = [super init];
   _solver = solver;
   _cc = [[CPConcretizerI alloc] initCPConcretizerI:solver];
   return self;
}
-(void)dealloc
{
   [_cc release];
   [super dealloc];
}
-(id<ORIntVar>) intVar: (id<ORIntVar>) v
{
   int nbw = [_solver nbWorkers];
   ORParIntVarI* pVar = [[ORParIntVarI alloc] init:nbw];
   return pVar;
}
-(id<ORIntVar>) affineVar:(id<ORIntVar>) v
{
   int nbw = [_solver nbWorkers];
   ORParIntVarI* pVar = [[ORParIntVarI alloc] init:nbw];
   return pVar;
}
-(id<ORIdArray>) idArray: (id<ORIdArray>) a
{
   return [[ORParIdArrayI alloc] initORParIdArrayI:[_solver nbWorkers]];
}
-(id<ORConstraint>) alldifferent: (id<ORAlldifferent>) cstr
{
   return [[ORParConstraintI alloc] initORParConstraintI:[_solver nbWorkers]];
}
-(id<ORConstraint>) binPacking: (id<ORBinPacking>) cstr
{
   return [[ORParConstraintI alloc] initORParConstraintI:[_solver nbWorkers]];
}
-(id<ORConstraint>) algebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   return [[ORParConstraintI alloc] initORParConstraintI:[_solver nbWorkers]];
}
-(void) expr: (id<ORExpr>) e
{
   
}
@end
