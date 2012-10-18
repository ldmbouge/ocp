/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORProgram.h"
#import "ORCPSolver.h"
#import <objcp/CPFactory.h>
#import <objcp/CPSolver.h>
#import <objcp/CPLabel.h>


// TODO by PVH 13/10/2012

// 1. replace the id<CPSolver> by the engine and the search and start replacing the methods one at a time
//    this does the delegation and the dispatching to the right place
// 2. Make sure that the portal and heuristic stack are moved here. This is the proper place
//    note that this includes both the protocols and the interfaces/implementations
// 3. Remove the protocol and interface for CPSolver
// 4. Rename ORCPSolver into CPSolver
// 5. Clean les ORIntVar et les dereferences de objcp

// once these steps are done, I have deconnected the search from objcp

// TODO after that

// 6. Try a model with an objective function to understand that aspect
// 7. Allows the concretization to create a semantic DFS solver
// 8. Clean tous les warnings




// PVH: all methods on modeling objects must dereference
// PVH: this is also true for label qui doit etre ici maintenant
// PVH: everything must go through the labeling

// PVH: Need to reorganize the CPSolver class: DFS, notDFTSem, PAR
// PVH: Also need to remove methods that are now in the model


@interface CPHeuristicSet : NSObject {
   id<CPHeuristic>*  _tab;
   ORUInt            _sz;
   ORUInt            _mx;
}
-(CPHeuristicSet*) initCPHeuristicSet;
-(void)push: (id<CPHeuristic>) h;
-(id<CPHeuristic>) pop;
-(void) reset;
-(void)applyToAll: (void(^)(id<CPHeuristic> h,NSMutableArray*)) closure with: (NSMutableArray*) tab;
@end

@implementation CPHeuristicSet
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

@interface CPInformerPortalI : NSObject<CPPortal> {
   ORCPSolver*  _cp;
}
-(CPInformerPortalI*) initCPInformerPortalI: (ORCPSolver*) cp;
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

@implementation ORCPSolver {
   id<CPSolver> _solver;
   id<CPEngine>          _engine;
   id<ORExplorer>        _search;
   id<ORObjective>       _objective;
   id<ORTrail>           _trail;
   CPHeuristicSet*       _hSet;
   id<CPPortal>          _portal;
   @package
   id<ORIdxIntInformer>  _returnLabel;
   id<ORIdxIntInformer>  _failLabel;
   BOOL                  _closed;
}
-(id<CPProgram>) initORCPSolver: (id<CPSolver>) solver
{
   self = [super init];
   _solver = [solver retain];
   _engine = [_solver engine];
   _search = [_solver explorer];
   _hSet = [[CPHeuristicSet alloc] initCPHeuristicSet];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortalI alloc] initCPInformerPortalI: self];
   _objective = nil;
   return self;
}
-(void) dealloc
{
   [_solver release];
   [_hSet release];
   [_portal release];
   [_returnLabel release];
   [_failLabel release];
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
-(id<ORTracer>) tracer
{
   // pvh: not sure what this does
   assert(false);
   return nil;
}
-(id<ORSolution>)  solution
{
   // pvh: will have to change
   return [_engine solution];
}
-(void) add: (id<ORConstraint>) c
{
   // PVH: Need to flatten/concretize
   assert([[c class] conformsToProtocol:@protocol(ORRelation)] == NO);
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) add: (id<ORConstraint>) c consistency:(ORAnnotation) cons
{
   // PVH: Need to flatten/concretize
   assert([[c class] conformsToProtocol:@protocol(ORRelation)] == NO);
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
 // PVH: These guys will need to go
-(id<ORObjective>) minimize: (id<ORIntVar>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method not useful in wrapper"];
}
-(id<ORObjective>) maximize: (id<ORIntVar>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method not useful in wrapper"];
}
-(void) state
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method not useful in wrapper"];  
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
-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine label: (id<CPIntVar>) [var dereference] with: val];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine diff: (id<CPIntVar>) [var dereference] with: val];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine lthen: (id<CPIntVar>) [var dereference] with: val];
   if (status == ORFailure) {
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine gthen: (id<CPIntVar>) [var dereference] with: val];
   if (status == ORFailure) {
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine restrict: (id<CPIntVar>) [var dereference] to: S];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
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
-(void) labelArray: (id<ORIntVarArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   for(ORInt i = low; i <= up; i++)
      [self label: x[i]];
}
-(void) label: (id<ORIntVar>) mx
{
   id<CPIntVar> x = (id<CPIntVar>) [mx dereference];
   while (![x bound]) {
      ORInt m = [x min];
      [_search try: ^() {
         [self label: x with: m];
      }
      or: ^() {
         [self diff: x with: m];
      }];
   }
}

@end

@implementation CPInformerPortalI
-(CPInformerPortalI*) initCPInformerPortalI: (ORCPSolver*) cp
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
