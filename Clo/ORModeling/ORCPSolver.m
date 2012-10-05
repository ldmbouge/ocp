/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORCPSolver.h"

// PVH: all methods on modeling objects must dereference
// PVH: this is also true for label qui doit etre ici maintenant
// PVH: everything must go through the labeling

// PVH: Need to reorganize the CPSolver class: DFS, notDFTSem, PAR
// PVH: Also need to remove methods that are now in the model

@implementation ORCPSolver {
   id<CPSolver> _solver;
}
-(id<CPSolver>) initORCPSolver: (id<CPSolver>) solver
{
   self = [super init];
   _solver = [solver retain];
   return self;
}
-(void) dealloc
{
   [_solver release];
   [super dealloc];
}
-(ORInt) nbFailures
{
   return [_solver nbFailures];
}
-(id<CPEngine>) engine
{
   return [_solver engine];
}
-(id<ORExplorer>) explorer
{
   return [_solver explorer];
}
-(id<CPPortal>) portal
{
   return [_solver portal];
}
-(id<ORTracer>) tracer
{
   return [_solver tracer];
}
-(id<ORSolution>)  solution
{
   return [_solver solution];
}
-(void) add: (id<ORConstraint>) c
{
   // PVH: Need to flatten/concretize
   return [_solver add: c];
}
-(void) add: (id<ORConstraint>) c consistency:(CPConsistency) cons
{
   // PVH: Need to flatten/concretize
   return [_solver add: c consistency: cons];
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

-(void) addHeuristic: (id<CPHeuristic>) h
{
   return [_solver addHeuristic:h];
}
-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   return [_solver label: [var dereference] with: val];
}
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   return [_solver diff: [var dereference] with: val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   return [_solver lthen: [var dereference] with: val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   return [_solver gthen: [var dereference] with: val];
}
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   return [_solver restrict: [var dereference] to: S];
}
-(void) solve: (ORClosure) body
{
   return [_solver solve: body];
}
-(void) solveAll: (ORClosure) body
{
   return [_solver solveAll: body];
}
-(void) forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) o do: (ORInt2Void) b
{
   return [_solver forall: S orderedBy:o do: b];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f orderedBy: (ORInt2Int) o do: (ORInt2Void) b
{
   return [_solver forall: S suchThat: f orderedBy: o do: b ];
}
-(void) try: (ORClosure) left or: (ORClosure) right
{
   return [_solver try: left or: right];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body
{
   return [_solver tryall: range suchThat: f in: body];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   return [_solver tryall: range suchThat: f in: body  onFailure: onFailure];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRestart
{
   return [_solver repeat: body onRepeat: onRestart];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRestart until: (ORVoid2Bool) isDone
{
   return [_solver repeat: body onRepeat: onRestart until: isDone];
}
-(void) once: (ORClosure) cl
{
   return [_solver once: cl];
}
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   return [_solver limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   return [_solver limitCondition: condition in: cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   return [_solver limitDiscrepancies:maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   return [_solver limitFailures: maxFailures in:cl];
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   return [_solver limitTime: maxTime in: cl];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   return [_solver nestedSolve: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution
{
   return [_solver nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolve: (ORClosure) body
{
   return [_solver nestedSolve: body];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   return [_solver nestedSolveAll: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution
{
   return [_solver nestedSolveAll: body onSolution: onSolution];
}
-(void) nestedSolveAll: (ORClosure) body
{
   return [_solver nestedSolveAll: body];
}
-(void) trackObject: (id) object
{
   [_solver trackObject:object];
}
-(void) trackVariable: (id) object
{
   [_solver trackVariable: object];
}

@end
