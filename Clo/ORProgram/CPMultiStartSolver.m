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
#import <ORProgram/CPMultiStartSolver.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>


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
-(CPSolver*)dereference
{
   return _solver[[NSThread threadID]];
}
-(void)  restartHeuristics
{
   [[self dereference] restartHeuristics];
}
-(id<CPPortal>) portal
{
   return [[self dereference] portal];
}
-(ORInt) nbFailures
{
   return [[self dereference] nbFailures];
}
-(id<OREngine>) engine
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
   CPSolver* solver = [self dereference];
   [solver close];
}
-(void) addHeuristic: (id<CPHeuristic>) h
{
   assert(NO);
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
-(id<ORForall>) forall: (id<ORIntIterable>) S
{
   return [ORControl forall: [self dereference] set: S];
}
-(void) forall: (id<ORIntIterable>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   return [[self dereference] forall: S orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   return [[self dereference] forall: S suchThat: filter orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterable>) S  orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: [self dereference] set: S];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: [self dereference] set: S];
   [forall suchThat: suchThat];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}

-(void) try: (ORClosure) left or: (ORClosure) right
{
   [[self dereference] try: left or: right];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   [[self dereference] tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [[self dereference] tryall: range suchThat: filter in: body onFailure: onFailure];
}
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
-(void) trackObject: (id) object
{
   [[self dereference] trackObject: object];
}
-(void) trackVariable: (id) object
{
   [[self dereference] trackVariable: object];
}
-(void) trackConstraint:(id)object
{
   [[self dereference] trackConstraint:object];
}
-(void) addConstraintDuringSearch: (id<ORConstraint>) c annotation:(ORAnnotation)n
{
   [[self dereference] addConstraintDuringSearch: c annotation:n];
}
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
   for(ORInt k = 0; k < _nb; k++) 
      [_solver[k] onSolution: onSol];
}
-(void) onExit: (ORClosure) onExit
{
   for(ORInt k = 0; k < _nb; k++)   
      [_solver[k] onExit: onExit];
}
-(void) doOnSolution
{}
-(void) doOnExit
{}
-(id<ORSolutionPool>) solutionPool
{
   return [[self dereference] solutionPool];
}
-(id<ORSolutionPool>) globalSolutionPool
{
   return _sPool;
}

-(id<CPHeuristic>) createFF:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createFF:rvars];
  return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createWDeg:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createDDeg:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createIBS:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createABS:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createFF
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createFF];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createWDeg
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createWDeg];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createDDeg
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createDDeg];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createIBS
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createIBS];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createABS
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
  for(ORInt i=0;i < _nb;i++)
    binding[i] = [_solver[i] createABS];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
@end
