/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORExplorer.h>
#import <ORFoundation/ORSemDFSController.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import "CPProgram.h"
#import "CPSolver.h"


/******************************************************************************************/
/*                                 CoreSolver                                             */
/******************************************************************************************/

@implementation CPMultiStartSolver {
   CPSolver** _solver;
   ORInt      _nb;
}
-(CPMultiStartSolver*) initCPMultiStartSolver: (ORInt) k
{
   self = [super init];
   _solver = (CPSolver**) malloc(k*sizeof(CPSolver*));
   _nb = k;
   for(ORInt i = 0; i < _nb; i++)
      _solver[i] = [[CPSolver alloc] initCPSolver];
   return self;
}
-(void) dealloc
{
   for(ORInt i = 0; i < _nb; i++)
      [_solver[i] release];
   [super dealloc];
}
-(ORInt) nb
{
   return _nb;
}
-(id<CPProgram>) at: (ORInt) i
{
   if (i >= 0 && i < _nb)
      return _solver[i];
   else
      return 0;
}
-(id<CPPortal>) portal
{
   ORInt k = 0;
   return [_solver[k] portal];
}

-(ORInt) nbFailures
{
   ORInt k = 0;
   return [_solver[k] nbFailures];
}
-(id<CPEngine>) engine
{
   ORInt k = 0;
   return [_solver[k] engine];
}
-(id<ORExplorer>) explorer
{
   ORInt k = 0;
   return [_solver[k] explorer];
}
-(id<ORObjectiveFunction>) objective
{
   ORInt k = 0;
   return [_solver[k] objective];
}
-(id<ORTracer>) tracer
{
   ORInt k = 0;
   return [_solver[k] tracer];
}
-(void) close
{
   ORInt k = 0;
   return [_solver[k] close];
}
-(void) addHeuristic: (id<CPHeuristic>) h
{
   ORInt k = 0;
   return [_solver[k] addHeuristic: h];
}
-(void) solve: (ORClosure) search
{
   ORInt k = 0;
   return [_solver[k] solve: search];
}
-(void) solveAll: (ORClosure) search
{
   ORInt k = 0;
   return [_solver[k] solveAll: search];
}
-(void) forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   ORInt k = 0;
   return [_solver[k] forall: S orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   ORInt k = 0;
   return [_solver[k] forall: S suchThat: filter orderedBy: order do: body];
}
-(void) try: (ORClosure) left or: (ORClosure) right
{
   ORInt k = 0;
   return [_solver[k] try: left or: right];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   ORInt k = 0;
   return [_solver[k] tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   ORInt k = 0;
   return [_solver[k] tryall: range suchThat: filter in: body onFailure: onFailure];
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   ORInt k = 0;
   return [_solver[k] limitTime: maxTime in: cl];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   ORInt k = 0;
   return [_solver[k] nestedSolve: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution
{
   ORInt k = 0;
   return [_solver[k] nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolve: (ORClosure) body
{
   ORInt k = 0;
   return [_solver[k] nestedSolve: body];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   ORInt k = 0;
   return [_solver[k] nestedSolveAll: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution
{
   ORInt k = 0;
   return [_solver[k] nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolveAll: (ORClosure) body
{
   ORInt k = 0;
   return [_solver[k] nestedSolveAll: body];
}
-(void) trackObject: (id) object
{
   ORInt k = 0;
   return [_solver[k] trackObject: object];
}
-(void) trackVariable: (id) object
{
   ORInt k = 0;
   return [_solver[k] trackVariable: object];
}
-(void) trackConstraint:(id)object
{
   ORInt k = 0;
   return [_solver[k] trackConstraint:object];
}
-(void) add: (id<ORConstraint>) c
{
   ORInt k = 0;
   return [_solver[k] add: c];
}
-(void) addInternal: (id<ORConstraint>) c annotation:(ORAnnotation)n
{
   ORInt k = 0;
   [_solver[k] addInternal: c annotation:n];
}
-(void) add: (id<ORConstraint>) c annotation: (ORAnnotation) cons
{
   ORInt k = 0;
   return [_solver[k] add: c annotation: cons];
}
-(void) labelArray: (id<ORIntVarArray>) x
{
   ORInt k = 0;
   return [_solver[k] labelArray: x];
}
-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy
{
   ORInt k = 0;
   return [_solver[k] labelArray: x orderedBy: orderedBy];
}
-(void) labelHeuristic: (id<CPHeuristic>) h
{
   ORInt k = 0;
   return [_solver[k] labelHeuristic: h];
}
-(void) label: (id<ORIntVar>) mx
{
   ORInt k = 0;
   return [_solver[k] label: mx];
}
-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   ORInt k = 0;
   return [_solver[k] label: var with: val];
}
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   ORInt k = 0;
   return [_solver[k] diff: var with: val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORInt k = 0;
   return [_solver[k] lthen: var with: val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORInt k = 0;
   return [_solver[k] gthen: var with: val];
}
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   ORInt k = 0;
   return [_solver[k] restrict: var to: S];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
   ORInt k = 0;
   return [_solver[k] repeat: body onRepeat: onRepeat];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone
{
   ORInt k = 0;
   return [_solver[k] repeat: body onRepeat: onRepeat until: isDone];
}
-(void) once: (ORClosure) cl
{
   ORInt k = 0;
   return [_solver[k] once: cl];
}
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   ORInt k = 0;
   return [_solver[k] limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   ORInt k = 0;
   return [_solver[k] limitCondition: condition in: cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   ORInt k = 0;
   return [_solver[k] limitDiscrepancies: maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   ORInt k = 0;
   return [_solver[k] limitFailures: maxFailures in: cl];
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
-(void) onSolution: (ORClosure)onSol onExit:(ORClosure)onExit
{
   
}
-(id<ORSolutionPool>)solutionPool
{
   return NULL;
}
@end
