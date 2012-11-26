/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORExplorer.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORFlatten.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import "CPProgram.h"
#import "CPSolver.h"
#import <objcp/CPBitVar.h>
#import "CPConcretizer.h"

// to do 11/11/2012
//
// 1. For the multistart, start by putting the binding array
// 2. The CPConcretizer need to clone everything

// 5. Look how to distinguish expression and constraints
// 6. Move BindingArray in ORProgram: It is not a modelling object. Change the fact that it inherits from ModelingObject too

// to do 7/11/2012
//
// 1. Look at IncModel to implement the incremental addition of constraints
// 2. Add a feature to determine if the model is closed; needed for incrementality
// 3. Add the incremental add
// 4. Look how to distinguish expression and constraints

@implementation CPHeuristicSet
{
   id<CPHeuristic>*  _tab;
   ORUInt            _sz;
   ORUInt            _mx;
}
-(CPHeuristicSet*) initCPHeuristicSet
{
   self = [super init];
   _mx  = 2;
   _tab = malloc(sizeof(id<CPHeuristic>)*_mx);
   _sz  = 0;
   return self;
}
-(void) push: (id<CPHeuristic>) h
{
   if (_sz >= _mx) {
      _tab = realloc(_tab, _mx << 1);
      _mx <<= 1;
   }
   _tab[_sz++] = h;
}
-(id<CPHeuristic>) pop
{
   return _tab[--_sz];
}
-(void) reset
{
   for(ORUInt k=0;k<_sz;k++)
      [_tab[k] release];
   _sz = 0;
}
-(void) dealloc
{
   [self reset];
   free(_tab);
   [super dealloc];
}
-(void)applyToAll: (void(^)(id<CPHeuristic>,NSMutableArray*))closure with: (NSMutableArray*)av;
{
   for(ORUInt k=0;k<_sz;k++)
      closure(_tab[k],av);
}
@end


@interface ORControllerFactoryI : NSObject<ORControllerFactory> {
   id<CPCommonProgram> _solver;
   Class               _ctrlClass;
   Class               _nestedClass;
}
-(id)initORControllerFactoryI: (id<CPCommonProgram>) solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc;
-(id<ORSearchController>) makeRootController;
-(id<ORSearchController>) makeNestedController;
@end

@implementation ORControllerFactoryI
-(id)initORControllerFactoryI: (id<CPCommonProgram>) solver rootControllerClass: (Class) class nestedControllerClass: (Class) nc
{
   self = [super init];
   _solver = solver;
   _ctrlClass = class;
   _nestedClass = nc;
   return self;
}
-(id<ORSearchController>) makeRootController
{
   return [[_ctrlClass alloc] initTheController: [_solver tracer] engine: [_solver engine]];
}
-(id<ORSearchController>) makeNestedController
{
   return [[_nestedClass alloc] initTheController: [_solver tracer] engine: [_solver engine]];
}
@end


/******************************************************************************************/
/*                                 CoreSolver                                             */
/******************************************************************************************/

@implementation CPCoreSolver {
@protected
   id<CPEngine>          _engine;
   id<ORExplorer>        _search;
   id<ORObjective>       _objective;
   id<ORTrail>           _trail;
   id<ORTracer>          _tracer;
   CPHeuristicSet*       _hSet;
   id<CPPortal>          _portal;

   id<ORIdxIntInformer>  _returnLabel;
   id<ORIdxIntInformer>  _failLabel;
   BOOL                  _closed;
   ORClosure             _doOnSol;
   ORClosure             _doOnExit;
   id<ORSolutionPool>    _sPool;
}
-(CPCoreSolver*) initCPCoreSolver
{
   self = [super init];
   _hSet = [[CPHeuristicSet alloc] initCPHeuristicSet];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal: self];
   _objective = nil;
   _doOnSol = _doOnExit = nil;
   _sPool   = [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   [_hSet release];
   [_portal release];
   [_returnLabel release];
   [_failLabel release];
   [_doOnSol release];
   [_doOnExit release];
   [_sPool release];
   [super dealloc];
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
-(id<CPPortal>) portal
{
   return _portal;
}
-(ORInt) nbFailures
{
   return [_search nbFailures];
}
-(id<CPEngine>) engine
{
   return _engine;
}
-(id<ORExplorer>) explorer
{
   return _search;
}
-(id<ORObjectiveFunction>) objective
{
   return [_engine objective];
}
-(id<ORTracer>) tracer
{
   return _tracer;
}
-(void) close
{
   if (!_closed) {
      _closed = true;
      if ([_engine close] == ORFailure)
         [_search fail];
      [_hSet applyToAll:^(id<CPHeuristic> h,NSMutableArray* av) { [h initHeuristic:av];} with: [_engine allVars]];
      [ORConcurrency pumpEvents];
   }
}
-(void) addHeuristic: (id<CPHeuristic>) h
{
   [_hSet push: h];
}
-(void) onSolution: (ORClosure)onSol onExit:(ORClosure)onExit
{
   [_doOnSol release];
   _doOnSol = [onSol copy];
   [_doOnExit release];
   _doOnExit = [onExit copy];
}
-(id<ORSolutionPool>) solutionPool
{
   return _sPool;
}
-(void) solve: (ORClosure) search
{
   _objective = [_engine objective];
   if (_objective != nil) {
      [_search optimizeModel: self using: search
                  onSolution: _doOnSol
                      onExit: _doOnExit];
      printf("Optimal Solution: %d \n",[_objective primalBound]);
   }
   else {
      [_search solveModel: self using: search
               onSolution: _doOnSol
                   onExit: _doOnExit];
   }
}
-(void) solveAll: (ORClosure) search
{
   [_search solveAllModel: self using: search
               onSolution: _doOnSol
                   onExit: _doOnExit];
}
-(void) forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: nil orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: filter orderedBy: order do: body];  
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
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitTime: maxTime in: cl];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolve: body onSolution: onSolution onExit: onExit
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]]; 
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [_search nestedSolve: body onSolution: onSolution onExit:nil
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolve: (ORClosure) body
{
   [_search nestedSolve: body onSolution:nil onExit:nil
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolveAll: body onSolution: onSolution onExit: onExit
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [_search nestedSolveAll: body onSolution: onSolution onExit:nil
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body
{
   [_search nestedSolveAll: body onSolution:nil onExit:nil
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) trackObject: (id) object
{
   [_engine trackObject:object];   
}
-(void) trackVariable: (id) object
{
   [_engine trackObject:object];  
}
-(void) trackConstraint: (id) obj
{
   [_engine trackConstraint:obj];
}
-(void) add: (id<ORConstraint>) c
{
   @throw [[ORExecutionError alloc] initORExecutionError: "add: not implemented"];   
}
-(void) add: (id<ORConstraint>) c annotation: (ORAnnotation) cons
{
@throw [[ORExecutionError alloc] initORExecutionError: "add:consistency: not implemented"];   
}

-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelImpl not implemented"];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method diffImpl not implemented"]; 
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method lthenImpl not implemented"];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method gthenImpl not implemented"];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method restrictImpl not implemented"];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(bool)val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelBVImpl not implemented"];
}

-(void) labelBit:(int)i ofVar:(id<CPBitVar>)x
{
   [_search try: ^() { [self labelBV:x at:i with:false];}
             or: ^() {[self labelBV:x at:i with:true];}];
}
-(void) labelUpFromLSB:(id<CPBitVar>) x
{
   int i;
   CPBitVarI* bv = (CPBitVarI*) [x dereference];
   while ((i=[bv lsFreeBit])>=0) {
      NSAssert(i>=0,@"ERROR in [labelUpFromLSB] bitVar is not bound, but no free bits found when using lsFreeBit.");
      [_search try: ^() { [self labelBV:x at:i with:false];}
                or: ^() { [self labelBV:x at:i with:true];}];
   }
}


-(void) labelArray: (id<ORIntVarArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   for(ORInt i = low; i <= up; i++)
      [self label: x[i]];
}
-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy
{
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^bool(ORInt i) { return ![[x at: i] bound]; }
                                 orderedBy: orderedBy];
   do {
      ORInt i = [select min];
      if (i == MAXINT) {
         return;
      }
      [self label: x[i]];
   } while (true);
}
-(void) labelHeuristic: (id<CPHeuristic>) h
{
   id<ORIntVarArray> av = [h allIntVars];
   id<ORSelect> select = [ORFactory selectRandom: _engine
                                           range: RANGE(_engine,[av low],[av up])
                                        suchThat: ^bool(ORInt i)    { return ![[av at: i] bound]; }
                                       orderedBy: ^ORFloat(ORInt i) { return [h varOrdering:av[i]]; }];
   do {
      ORInt i = [select max];
      if (i == MAXINT)
         return;
      //NSLog(@"Chose variable: %d",i);
      id<ORIntVar> x = av[i];
      id<ORSelect> valSelect = [ORFactory selectRandom: _engine
                                                 range:RANGE(_engine,[x min],[x max])
                                              suchThat:^bool(ORInt v)    { return [x member:v];}
                                             orderedBy:^ORFloat(ORInt v) { return [h valOrdering:v forVar:x];}];
      do {
         ORInt curVal = [valSelect max];
         if (curVal == MAXINT)
            break;
         [self try:^{
            [self label: x with: curVal];
         } or:^{
            [self diff: x with: curVal];
         }];
      } while(![x bound]);
   } while (true);
   
}
-(void) label: (id<ORIntVar>) mx
{
   id<CPIntVar> x = (id<CPIntVar>) [mx dereference];
   while (![x bound]) {
      ORInt m = [x min];
      [_search try: ^() {
         [self labelImpl: x with: m];
      }
                or: ^() {
                   [self diffImpl: x with: m];
                }];
   }
}

-(void) label: (id<CPIntVar>) var with: (ORInt) val
{
   return [self labelImpl: (id<CPIntVar>) [var dereference] with: val];
}
-(void) diff: (id<CPIntVar>) var with: (ORInt) val
{
   [self diffImpl: (id<CPIntVar>) [var dereference] with: val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   [self lthenImpl: (id<CPIntVar>) [var dereference] with: val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   [self gthenImpl: (id<CPIntVar>) [var dereference] with: val];
}
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   [self restrictImpl: (id<CPIntVar>) [var dereference] to: S];
}
-(void) labelBV: (id<CPBitVar>) var at:(ORUInt) i with:(bool)val
{
   return [self labelBVImpl: (id<CPBitVar,CPBitVarNotifier>)[var dereference] at:i with: val];
}

-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
   [_search repeat: body onRepeat: onRepeat until: nil];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone
{
   [_search repeat: body onRepeat: onRepeat until: isDone];
}
-(void) once: (ORClosure) cl
{
   [_search once: cl];
}
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitCondition: condition in:cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitDiscrepancies: maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitFailures: maxFailures in: cl];
   
}

//- (void) encodeWithCoder:(NSCoder *)aCoder
//{
//   // The idea is that we only encode the solver and an empty _shell_ (no content) of the trail
//   // The decoding recreates the pool.
//   [aCoder encodeObject:_engine];
//   [aCoder encodeObject:_trail];
//}
//- (id) initWithCoder:(NSCoder *)aDecoder;
//{
//   self = [super init];
//   _engine = [[aDecoder decodeObject] retain];
//   _trail  = [[aDecoder decodeObject] retain];
//   _pool = [[NSAutoreleasePool alloc] init];
//   return self;
//}

-(void) addInternal: (id<ORConstraint>) c
{
   // LDM: This is the true addition of the constraint into the solver during the search.
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}

@end

/******************************************************************************************/
/*                                   CPSolver                                             */
/******************************************************************************************/

@interface ORRTModel : NSObject<ORINCModel> {
   CPSolver* _solver;
   id<ORVisitor> _concretizer;
}
-(ORRTModel*)init:(CPSolver*)solver;
-(void)addVariable:(id<ORVar>)var;
-(void)addObject:(id)object;
-(void)addConstraint:(id<ORConstraint>)cstr;
-(void)minimize:(id<ORIntVar>)x;
-(void)maximize:(id<ORIntVar>)x;
-(id<ORModel>)model;
-(void) trackObject: (id) obj;
-(void) trackVariable: (id) obj;
-(void) trackConstraint:(id)obj;
@end

@implementation ORRTModel
-(ORRTModel*)init:(CPSolver*)solver
{
   self = [super init];
   _solver = solver;
   _concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: solver];
   return self;
}
-(void)dealloc
{
   [_concretizer release];
   [super dealloc];
}
-(void)addVariable:(id<ORVar>)var
{
   [_solver trackVariable:var];
}
-(void)addObject:(id)object
{
   [_solver trackObject:object];
}
-(void)addConstraint:(id<ORConstraint>)cstr
{
   [cstr visit:_concretizer];
   id<CPConstraint> c = [cstr dereference];
   [_solver addInternal:c];
}
-(void)minimize:(id<ORIntVar>)x
{   
   assert(FALSE);
}
-(void)maximize:(id<ORIntVar>)x
{
   assert(FALSE);
}
-(void) trackObject: (id) obj
{
   [_solver trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_solver trackVariable:obj];
}
-(void) trackConstraint:(id)obj
{
   [_solver trackConstraint:obj];
}
@end

@implementation CPSolver
-(id<CPProgram>) initCPSolver
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _engine = [CPFactory engine: _trail];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORDFSController class]
                                                                  nestedControllerClass: [ORDFSController class]];
   _search = [ORExplorerFactory explorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(void) dealloc
{
   [_trail release];
   [_engine release];
   [_search release];
   [_tracer release];
   [super dealloc];
}

-(void) add: (id<ORConstraint>) c
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   // LDM: DONE. Have not checked the variable creation/deallocation logic though. 
   id<ORINCModel> trg = [[ORRTModel alloc] init:self];
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      [ORFlatten flattenExpression:c into:trg];
   else
      [ORFlatten flatten:c into:trg];
   [trg release];
}
-(void) add: (id<ORConstraint>) c annotation: (ORAnnotation) cons
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   // LDM: See above. 
   id<ORINCModel> trg = [[ORRTModel alloc] init:self];
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      [ORFlatten flattenExpression:c into:trg];
   else
      [ORFlatten flatten:c into:trg];
   [trg release];
}
-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine impose: ^ORStatus { return [var bind: val];}];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine impose:^ORStatus { return [var remove:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine impose:^ORStatus { return  [var updateMax:val-1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine impose:^ORStatus { return [var updateMin:val+1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine impose:^ORStatus { return [var inside:S];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(bool)val
{
   ORStatus status = [_engine impose:^ORStatus { return [[var domain] setBit:i to:val for:var];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];   
}
@end

/******************************************************************************************/
/*                                   CPSemanticSolver                                     */
/******************************************************************************************/

@implementation CPSemanticSolver
-(id<CPSemanticProgram>) initCPSemanticSolver
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _engine = [CPFactory engine: _trail];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORDFSController class]
                                                                  nestedControllerClass: [ORDFSController class]];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}

-(id<CPSemanticProgram>) initCPSemanticSolverDFS
{
   self = [super init];
   _trail = [ORFactory trail];
   _engine = [CPFactory engine: _trail];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORSemDFSControllerCSP class]
                                                                  nestedControllerClass: [ORSemDFSControllerCSP class]];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(id<CPSemanticProgram>) initCPSemanticSolver: (Class) ctrlClass
{
   self = [super initCPCoreSolver]; 
   _trail = [ORFactory trail];
   _engine = [CPFactory engine: _trail];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORSemDFSControllerCSP class]
                                                                  nestedControllerClass: ctrlClass];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(void) dealloc
{
   [_trail release];
   [_engine release];
   [_search release];
   [_tracer release];
   [super dealloc];
}
-(void) add: (id<ORConstraint>) c
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) add: (id<ORConstraint>) c annotation:(ORAnnotation) cons
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine impose: ^ORStatus { return [var bind: val];}];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_tracer addCommand: [CPSearchFactory equalc: var to: val]];
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine impose:^ORStatus { return [var remove:val];}];
   if (status == ORFailure)
      [_search fail];
   [_tracer addCommand: [CPSearchFactory notEqualc: var to: val]];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine impose:^ORStatus { return  [var updateMax:val-1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine impose:^ORStatus { return [var updateMin:val+1];}];
   if (status == ORFailure)
      [_search fail];   
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine impose:^ORStatus { return [var inside:S];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(bool)val
{
   ORStatus status = [_engine impose:^ORStatus { return [[var domain] setBit:i to:val for:var];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}

//- (void) encodeWithCoder:(NSCoder *)aCoder
//{
//   [super encodeWithCoder:aCoder];
//}
//- (id) initWithCoder:(NSCoder *)aDecoder;
//{
//   self = [super initWithCoder:aDecoder];
//   _tracer = [[SemTracer alloc] initSemTracer: _trail];
//   id<ORControllerFactory> cFact = [[ORControllerFactory alloc] initFactory:self
//                                                        rootControllerClass:[ORSemDFSControllerCSP class]
//                                                      nestedControllerClass:[ORSemDFSController class]];
//   _search = [[ORSemExplorerI alloc] initORExplorer: _engine withTracer: _tracer ctrlFactory:cFact];
//   [cFact release];
//   return self;
//}
//-(ORStatus)installCheckpoint:(id<ORCheckpoint>)cp
//{
//   return [_tracer restoreCheckpoint:cp inSolver:_engine];
//}
//-(ORStatus)installProblem:(id<ORProblem>)problem
//{
//   return [_tracer restoreProblem:problem inSolver:_engine];
//}
//-(id<ORCheckpoint>)captureCheckpoint
//{
//   return [_tracer captureCheckpoint];
//}
//-(NSData*)packCheckpoint:(id<ORCheckpoint>)cp
//{
//   id<ORCheckpoint> theCP = [_tracer captureCheckpoint];
//   NSData* thePack = [theCP packFromSolver:_engine];
//   [theCP release];
//   return thePack;
//}
@end


@implementation CPInformerPortal
-(CPInformerPortal*) initCPInformerPortal: (CPSolver*) cp
{
   self = [super init];
   _cp = cp;
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
   return [[_cp engine] propagateFail];
}
-(id<ORInformer>) propagateDone
{
   return [[_cp engine] propagateDone];
}
@end

@implementation CPSolverFactory 
+(id<CPProgram>) solver
{
   return [[CPSolver alloc] initCPSolver];
}
+(id<CPSemanticProgramDFS>) semanticSolverDFS
{
   return [[CPSemanticSolver alloc] initCPSemanticSolverDFS];
}
+(id<CPSemanticProgram>) semanticSolver: (Class) ctrlClass
{
   return [[CPSemanticSolver alloc] initCPSemanticSolver: ctrlClass];
}
+(id<CPProgram>) multiStartSolver: (ORInt) k
{
   return [[CPMultiStartSolver alloc] initCPMultiStartSolver: k];
}
@end

@implementation CPUtilities

+(ORInt) maxBound: (id<ORIdArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   ORInt M = -MAXINT;
   for(ORInt i = low; i <= up; i++) {
      id<CPIntVar> xi = [x[i] dereference];
      if ([xi bound] && [xi value] > M)
         M = [xi value];
   }
   return M;
}
@end


//id<ORBindingArray> ba = [ORFactory bindingArray: _tracker nb: _nb];
//[v setImpl: ba];


//@implementation NSThread (ORData)
//
//static pthread_key_t threadIDKey;
//static pthread_once_t block = PTHREAD_ONCE_INIT;
//
//static void init_pthreads_key()
//{
//   pthread_key_create(&threadIDKey,NULL);
//}
//+(void)setThreadID:(ORInt)tid
//{
//   pthread_once(&block,init_pthreads_key);
//   pthread_setspecific(threadIDKey,(void*)tid);
//}
//+(ORInt)threadID
//{
//   ORInt tid = (ORInt)pthread_getspecific(threadIDKey);
//   return tid;
//}
//@end
