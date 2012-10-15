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
#import "ORVarI.h"

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

-(id<ORASolver>) solver
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
   assert([[c class] conformsToProtocol:@protocol(ORRelation)] == NO);
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) add: (id<ORConstraint>) c consistency:(ORAnnotation)cons
{
   assert([[c class] conformsToProtocol:@protocol(ORRelation)] == NO);
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}

-(id<ORObjective>) minimize: (id<ORIntVar>) x
{
   CPIntVarMinimize* cstr = (CPIntVarMinimize*) [CPFactory minimize: x];
   [self add: cstr];
   [_engine setObjective:cstr];
   _objective = cstr;
   return _objective;
}
-(id<ORObjective>) maximize: (id<ORIntVar>) x
{
   CPIntVarMaximize* cstr = (CPIntVarMaximize*) [CPFactory maximize: x];
   [self add: cstr];
   [_engine setObjective:cstr];
   _objective = cstr;
   return _objective;
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
-(void) label: (ORIntVarI*) var with: (ORInt) val
{
   var = [var dereference];
   ORStatus status = [_engine label: var with: val];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents]; 
}
-(void) diff: (ORIntVarI*) var with: (ORInt) val
{
   var = [var dereference];
   ORStatus status = [_engine diff: var with: val];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];   
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine lthen:[var dereference] with: val];
   if (status == ORFailure) {
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine gthen:[var dereference] with:val];
   if (status == ORFailure) {
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}

-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
    ORStatus status = [_engine restrict: [var dereference] to: S];
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
   [_engine clearStatus];
   [_search limitCondition: condition in:cl];
}
-(void) limitSolutions: (ORInt) nb in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitSolutions: nb in: cl];
}

-(void) limitDiscrepancies: (ORInt) nb in: (ORClosure) cl
{
   [_engine clearStatus];
  [_search limitDiscrepancies: nb in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitFailures: maxFailures in: cl];
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   [_engine clearStatus];
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
                                                        rootControllerClass:[ORSemDFSControllerCSP class]
                                                      nestedControllerClass:ctrlClass];
   _search = [[ORSemExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
   [cFact release];
   return self;
}
-(CPCoreSolverI*) initFor: (CPEngineI*) fdm withController:(Class)ctrlClass
{
   self = [super initFor:fdm];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
                                                        rootControllerClass:[ORSemDFSControllerCSP class]
                                                      nestedControllerClass:ctrlClass];
   _search = [[ORSemExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
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
-(void) label: (ORIntVarI*) var with: (ORInt) val
{
   var = [var dereference];
   ORStatus status = [_engine label: var with: val];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_tracer addCommand:[[CPEqualc alloc] initCPEqualc:var and:val]];    // add after the fail (so if we fail, we don't bother adding it!]
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diff: (ORIntVarI*) var with: (ORInt) val
{
   var = [var dereference];
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
                                                        rootControllerClass:[ORSemDFSControllerCSP class]
                                                      nestedControllerClass:[ORSemDFSController class]];
   _search = [[ORSemExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
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
   return [[_ctrlClass alloc] initTheController:[_solver tracer] engine:[_solver engine]];
}
-(id<ORSearchController>)makeNestedController
{
   return [[_nestedClass alloc] initTheController:[_solver tracer] engine:[_solver engine]];
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
   ORInt tid = (ORInt)pthread_getspecific(threadIDKey);
   return tid;
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

// =======================================================================

