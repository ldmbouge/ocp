/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORConcurrency.h>
#import <ORFoundation/ORExplorer.h>
#import <ORFoundation/ORSemDFSController.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import "CPProgram.h"
#import "CPSolver.h"


/******************************************************************************************/
/*                                 MultiStartSolver                                             */
/******************************************************************************************/

@implementation CPMultiStartSolver {
   CPSolver**     _solver;
   ORInt          _nb;
   NSCondition*   _terminated;
   ORInt          _nbDone;
   id<ORSolutionPool> _sPool;
}
-(CPMultiStartSolver*) initCPMultiStartSolver: (ORInt) k
{
   self = [super init];
   _solver = (CPSolver**) malloc(k*sizeof(CPSolver*));
   _nb = k;
   for(ORInt i = 0; i < _nb; i++)
      _solver[i] = [[CPSolver alloc] initCPSolver];
   
   _terminated = [[NSCondition alloc] init];
   
   _sPool   = [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   [_sPool release];
   for(ORInt i = 0; i < _nb; i++)
      [_solver[i] release];
   free(_solver);
   [_terminated release];
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
   ORInt k = [NSThread threadID];
   return [_solver[k] portal];
}

-(ORInt) nbFailures
{
   ORInt k = [NSThread threadID];
   return [_solver[k] nbFailures];
}
-(id<CPEngine>) engine
{
   ORInt k = [NSThread threadID];
   return [_solver[k] engine];
}
-(id<ORExplorer>) explorer
{
   ORInt k = [NSThread threadID];
   return [_solver[k] explorer];
}
-(id<ORObjectiveFunction>) objective
{
   ORInt k = [NSThread threadID];
   return [_solver[k] objective];
}
-(id<ORTracer>) tracer
{
   ORInt k = [NSThread threadID];
   return [_solver[k] tracer];
}
-(void) close
{
   ORInt k = [NSThread threadID];
   return [_solver[k] close];
}
-(void) addHeuristic: (id<CPHeuristic>) h
{
   ORInt k = [NSThread threadID];
   return [_solver[k] addHeuristic: h];
}

-(void) waitWorkers
{
   [_terminated lock];
   while (_nbDone < _nb)
      [_terminated wait];
   [_terminated unlock];
}

-(void) solveOne: (NSArray*) input
{
   ORClosure search = [input objectAtIndex: 0];
   ORInt i = [[input objectAtIndex:1] intValue];
   [NSThread setThreadID: i];
   [_solver[i] solve: search];
   [search release];
   [NSCont shutdown];
   [_terminated lock];
   ++_nbDone;
   if (_nbDone == _nb)
      [_terminated signal];
   [_terminated unlock];
}

-(void) solveAllOne: (NSArray*) input
{
   ORClosure search = [input objectAtIndex: 0];
   ORInt i = [[input objectAtIndex:1] intValue];
   [NSThread setThreadID: i];
   [_solver[i] solveAll: search];
   [search release];
   [_terminated lock];
   ++_nbDone;
   if (_nbDone == _nb)
      [_terminated signal];
   [_terminated unlock];
}

-(void) solve: (ORClosure) search
{
   _nbDone = 0;
   for(ORInt i = 0; i < _nb; i++) {
      [NSThread detachNewThreadSelector:@selector(solveOne:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects: [search copy],[NSNumber numberWithInt:i],nil]];
   }
   [self waitWorkers];
   [_sPool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution found with value %@",[s objectiveValue]); } ];
}

-(void) solveAll: (ORClosure) search
{
   _nbDone = 0;
   for(ORInt i = 0; i < _nb; i++) {
      [NSThread detachNewThreadSelector:@selector(solveOne:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects: [search copy],[NSNumber numberWithInt:i],nil]];
   }
   [self waitWorkers];
}
-(id<ORForall>) forall: (id<ORIntIterator>) S
{
   ORInt k = [NSThread threadID];
   return [ORControl forall: _solver[k] set: S];
}
-(void) forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   ORInt k = [NSThread threadID];
   return [_solver[k] forall: S orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   ORInt k = [NSThread threadID];
   return [_solver[k] forall: S suchThat: filter orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterator>) S  orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   ORInt k = [NSThread threadID];
   id<ORForall> forall = [ORControl forall: _solver[k] set: S];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   ORInt k = [NSThread threadID];
   id<ORForall> forall = [ORControl forall: _solver[k] set: S];
   [forall suchThat: suchThat];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}

-(void) try: (ORClosure) left or: (ORClosure) right
{
   ORInt k = [NSThread threadID];
   return [_solver[k] try: left or: right];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   ORInt k = [NSThread threadID];
   return [_solver[k] tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   ORInt k = [NSThread threadID];
   return [_solver[k] tryall: range suchThat: filter in: body onFailure: onFailure];
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   ORInt k = [NSThread threadID];
   return [_solver[k] limitTime: maxTime in: cl];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   ORInt k = [NSThread threadID];
   return [_solver[k] nestedSolve: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution
{
   ORInt k = [NSThread threadID];
   return [_solver[k] nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolve: (ORClosure) body
{
   ORInt k = [NSThread threadID];
   return [_solver[k] nestedSolve: body];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   ORInt k = [NSThread threadID];
   return [_solver[k] nestedSolveAll: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution
{
   ORInt k = [NSThread threadID];
   return [_solver[k] nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolveAll: (ORClosure) body
{
   ORInt k = [NSThread threadID];
   return [_solver[k] nestedSolveAll: body];
}
-(void) trackObject: (id) object
{
   ORInt k = [NSThread threadID];
   return [_solver[k] trackObject: object];
}
-(void) trackVariable: (id) object
{
   ORInt k = [NSThread threadID];
   return [_solver[k] trackVariable: object];
}
-(void) trackConstraint:(id)object
{
   ORInt k = [NSThread threadID];
   return [_solver[k] trackConstraint:object];
}
//-(void) add: (id<ORConstraint>) c
//{
//   ORInt k = [NSThread threadID];
//   return [_solver[k] add: c];
//}
-(void) addConstraintDuringSearch: (id<ORConstraint>) c annotation:(ORAnnotation)n
{
   ORInt k = [NSThread threadID];
   [_solver[k] addConstraintDuringSearch: c annotation:n];
}
//-(void) add: (id<ORConstraint>) c annotation: (ORAnnotation) cons
//{
//   ORInt k = [NSThread threadID];
//   return [_solver[k] add: c annotation: cons];
//}
-(void) labelArray: (id<ORIntVarArray>) x
{
   ORInt k = [NSThread threadID];
   return [_solver[k] labelArray: x];
}
-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy
{
   ORInt k = [NSThread threadID];
   return [_solver[k] labelArray: x orderedBy: orderedBy];
}
-(void) labelHeuristic: (id<CPHeuristic>) h
{
   ORInt k = [NSThread threadID];
   return [_solver[k] labelHeuristic: h];
}
-(void) label: (id<ORIntVar>) mx
{
   ORInt k = [NSThread threadID];
   return [_solver[k] label: mx];
}
-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   ORInt k = [NSThread threadID];
   return [_solver[k] label: var with: val];
}
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   ORInt k = [NSThread threadID];
   return [_solver[k] diff: var with: val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORInt k = [NSThread threadID];
   return [_solver[k] lthen: var with: val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   ORInt k = [NSThread threadID];
   return [_solver[k] gthen: var with: val];
}
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   ORInt k = [NSThread threadID];
   return [_solver[k] restrict: var to: S];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
   ORInt k = [NSThread threadID];
   return [_solver[k] repeat: body onRepeat: onRepeat];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone
{
   ORInt k = [NSThread threadID];
   return [_solver[k] repeat: body onRepeat: onRepeat until: isDone];
}
-(void) once: (ORClosure) cl
{
   ORInt k = [NSThread threadID];
   return [_solver[k] once: cl];
}
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   ORInt k = [NSThread threadID];
   return [_solver[k] limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   ORInt k = [NSThread threadID];
   return [_solver[k] limitCondition: condition in: cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   ORInt k = [NSThread threadID];
   return [_solver[k] limitDiscrepancies: maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   ORInt k = [NSThread threadID];
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
-(void) onSolution: (ORClosure) onSol 
{
   for(ORInt k = 0; k < _nb; k++) 
      [_solver[k] onSolution: onSol];
}
-(void) onExit: (ORClosure) onExit
{
   for(ORInt k = 0; k < _nb; k++)   
      [_solver[k] onExit: onExit];
}
-(id<ORSolutionPool>) solutionPool
{
   ORInt k = [NSThread threadID];
   return [_solver[k] solutionPool];
}
-(id<ORSolutionPool>) globalSolutionPool
{
   return _sPool;
}
@end
