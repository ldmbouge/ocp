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
#import <ORModeling/ORModeling.h>
#import <ORProgram/CPMultiStartSolver.h>
#import <ORProgram/CPBaseHeuristic.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>


/******************************************************************************************/
/*                                 MultiStartSolver                                             */
/******************************************************************************************/

@implementation CPMultiStartSolver {
   CPSolver**     _solver;
   id<ORModel>    _source;
   ORInt          _nb;
   NSCondition*   _terminated;
   ORInt          _nbDone;
   id<ORCPSolutionPool> _sPool;
}
-(CPMultiStartSolver*) initCPMultiStartSolver: (ORInt) k
{
   self = [super init];
   _source = NULL;
   _solver = (CPSolver**) malloc(k*sizeof(CPSolver*));
   _nb = k;
   for(ORInt i = 0; i < _nb; i++)
      _solver[i] = [[CPSolver alloc] initCPSolver];
   
   _terminated = [[NSCondition alloc] init];
   
   _sPool   = (id<ORCPSolutionPool>) [ORFactory createSolutionPool];
   return self;
}
-(void) dealloc
{
   [_source release];
   [_sPool release];
   for(ORInt i = 0; i < _nb; i++)
      [_solver[i] release];
   free(_solver);
   [_terminated release];
   [super dealloc];
}
-(id<ORTracker>)tracker
{
   return self;
}
-(void) setSource:(id<ORModel>)src
{
   [_source release];
   _source = [src retain];
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
-(CPSolver*) worker
{
   return _solver[[NSThread threadID]];
}
-(id<ORModelMappings>) modelMappings
{
   return [[self worker] modelMappings];
}
-(void)  restartHeuristics
{
   [[self worker] restartHeuristics];
}
-(id<CPPortal>) portal
{
   return [[self worker] portal];
}
-(ORInt) nbFailures
{
   return [[self worker] nbFailures];
}
-(id<ORSearchEngine>) engine
{
   return (id<ORSearchEngine>) [[self worker] engine];
}
-(id<ORExplorer>) explorer
{
   return [[self worker] explorer];
}
-(id<ORObjectiveFunction>) objective
{
   return [[self worker] objective];
}
-(id<ORTracer>) tracer
{
   return [[self worker] tracer];
}
-(void) close
{
   CPSolver* solver = [self worker];
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
   ORClosure objClosure = ^ {
      id<ORSearchObjectiveFunction> myObjective = [_solver[0] objective];
      if (myObjective) {
         id<ORObjectiveValue> bestPrimal = [myObjective primalBound];
         for(ORInt i=1;i < _nb;i++) {
            id<ORSearchObjectiveFunction> yourObjective = [_solver[i] objective];
            id<ORObjectiveValue> yourPrimal = [yourObjective primalBound];
            id<ORObjectiveValue> newPrimal = [bestPrimal best: yourPrimal];
            [yourPrimal release];
            [bestPrimal release];
            bestPrimal = newPrimal;
         }
         for(ORInt i=0;i < _nb;i++) {
            id<ORSearchObjectiveFunction> yourObjective = [_solver[i] objective];
            [yourObjective tightenPrimalBound: bestPrimal];
         }
         [bestPrimal release];
      }
      search();
   };
   for(ORInt i = 0; i < _nb; i++) {
      [NSThread detachNewThreadSelector:@selector(solveOne:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects: [objClosure copy],[NSNumber numberWithInt:i],nil]];
   }
   [self waitWorkers];
}

-(void) solveAll: (ORClosure) search
{
   _nbDone = 0;
   for(ORInt i = 0; i < _nb; i++) {
      [NSThread detachNewThreadSelector:@selector(solveAllOne:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects: [search copy],[NSNumber numberWithInt:i],nil]];
   }
   [self waitWorkers];
}
-(id<ORForall>) forall: (id<ORIntIterable>) S
{
   return [ORControl forall: [self worker] set: S];
}
-(void) forall: (id<ORIntIterable>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   return [[self worker] forall: S orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   return [[self worker] forall: S suchThat: filter orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterable>) S  orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: [self worker] set: S];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: [self worker] set: S];
   [forall suchThat: suchThat];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}

-(void) try: (ORClosure) left or: (ORClosure) right
{
   [[self worker] try: left or: right];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   [[self worker] tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [[self worker] tryall: range suchThat: filter in: body onFailure: onFailure];
}
-(void)              tryall: (id<ORIntIterable>) range
                   suchThat: (ORInt2Bool) filter
                  orderedBy: (ORInt2Float)o1
                         in: (ORInt2Void) body
                  onFailure: (ORInt2Void) onFailure
{
   [[self worker] tryall:range suchThat:filter orderedBy:o1 in:body onFailure:onFailure];
}
-(void) perform: (ORClosure) body onLimit: (ORClosure) onRestart
{
   [[[self worker] explorer] perform:body onLimit:onRestart];
}
-(void) portfolio: (ORClosure) s1 then: (ORClosure) s2
{
   [[[self worker] explorer] portfolio:s1 then:s2];
}
-(void) switchOnDepth: (ORClosure) s1 to: (ORClosure) s2 limit: (ORInt) depth
{
   [[[self worker] explorer] switchOnDepth:s1 to:s2 limit:depth];
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   [[self worker] limitTime: maxTime in: cl];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [[self worker] nestedSolve: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [[self worker] nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolve: (ORClosure) body
{
   [[self worker] nestedSolve: body];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [[self worker] nestedSolveAll: body onSolution: onSolution onExit: onExit];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [[self worker] nestedSolve: body onSolution: onSolution];
}
-(void) nestedSolveAll: (ORClosure) body
{
   [[self worker] nestedSolveAll: body];
}
-(id) trackObject: (id) object
{
   return [[self worker] trackObject: object];
}
-(id) trackMutable: (id) object
{
   return [[self worker] trackMutable: object];
}
-(id) trackObjective:(id) object
{
   return [[self worker] trackObjective: object];
}
-(id) trackConstraintInGroup:(id)object
{
   return [[self worker] trackConstraintInGroup: object];
}
-(id) trackImmutable: (id) object
{
   return [[self worker] trackImmutable: object];
}
-(id) trackVariable: (id) object
{
   return [[self worker] trackVariable: object];
}
-(void) add: (id<ORConstraint>) c
{
   [(CPSolver*)[self worker] add:c];
}
-(void) addConstraintDuringSearch: (id<ORConstraint>) c
{
   [[self worker] addConstraintDuringSearch: c];
}
-(void) labelArray: (id<ORIntVarArray>) x
{
   [[self worker] labelArray: x];
}
-(void) labelArrayFF: (id<ORIntVarArray>) x
{
   [[self worker] labelArrayFF:x];
}
-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy
{
   [[self worker] labelArray: x orderedBy: orderedBy];
}
-(void) labelHeuristic: (id<CPHeuristic>) h restricted:(id<ORIntVarArray>)av
{
   [[self worker] labelHeuristic: h restricted:av];
}
-(void) labelHeuristic: (id<CPHeuristic>) h
{
   [[self worker] labelHeuristic: h];
}
-(void) label: (id<ORIntVar>) mx
{
   [[self worker] label: mx];
}
-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   [[self worker] label: var with: val];
}
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   [[self worker] diff: var with: val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   [[self worker] lthen: var with: val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   [[self worker] gthen: var with: val];
}
-(void) lthen: (id<ORIntVar>) var float: (ORFloat) val
{
   [[self worker] lthen: var with: val];
}
-(void) gthen: (id<ORIntVar>) var float: (ORFloat) val
{
   [[self worker] gthen: var with: val];
}

-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   [[self worker] restrict: var to: S];
}
-(void) floatLthen: (id<ORFloatVar>) var with: (ORFloat) val
{
   [[self worker] floatLthen: var with: val];
}
-(void) floatGthen: (id<ORFloatVar>) var with: (ORFloat) val
{
   [[self worker] floatGthen: var with: val];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
   [[self worker] repeat: body onRepeat: onRepeat];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone
{
   [[self worker] repeat: body onRepeat: onRepeat until: isDone];
}
-(void) once: (ORClosure) cl
{
   [[self worker] once: cl];
}
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   [[self worker] limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   [[self worker] limitCondition: condition in: cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   [[self worker] limitDiscrepancies: maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   [[self worker] limitFailures: maxFailures in: cl];
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
{
   @throw [[ORExecutionError alloc] initORExecutionError: "do OnSolution never called on CPMultiStartProgram"];
}
-(void) doOnExit
{
   @throw [[ORExecutionError alloc] initORExecutionError: "do OnSolution never called on CPMultiStartProgram"];
}
-(id<ORCPSolutionPool>) solutionPool
{
   return _sPool;
}
-(void) setGamma: (id*) gamma
{
   @throw [[ORExecutionError alloc] initORExecutionError: "setGamma never called on CPMultiStartProgram"];
}
-(void) setTau: (id<ORTau>) tau
{
   @throw [[ORExecutionError alloc] initORExecutionError: "setTau never called on CPMultiStartProgram"];
}
-(id*) gamma
{
   @throw [[ORExecutionError alloc] initORExecutionError: "gamma never called on CPMultiStartProgram"];
   return NULL;
}

-(id<CPHeuristic>)setupHeuristic:(SEL)selector with:(id<ORVarArray>)rvars
{
   id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
   for(ORInt i=0;i < _nb;i++) {
      binding[i] = [_solver[i] performSelector:selector withObject:rvars];
   }
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}

-(id<CPHeuristic>)setupHeuristic:(SEL)selector
{
   id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
   for(ORInt i=0;i < _nb;i++) {
      binding[i] = [_solver[i] performSelector:selector];
   }
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createPortfolio:(NSArray*)hs with:(id<ORVarArray>)vars
{
   assert([hs count] >= _nb);
   id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nb];
   for(ORInt i=0;i < _nb;i++) {
      SEL todo = NSSelectorFromString([hs objectAtIndex:i]);
      binding[i] = [_solver[i] performSelector:todo withObject:vars];
   }
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}

-(id<CPHeuristic>) createFF:(id<ORVarArray>)rvars
{
   return [self setupHeuristic:_cmd with:rvars];
}
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars
{
   return [self setupHeuristic:_cmd with:rvars];
}
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars
{
   return [self setupHeuristic:_cmd with:rvars];
}
-(id<CPHeuristic>) createSDeg:(id<ORVarArray>)rvars
{
   return [self setupHeuristic:_cmd with:rvars];
}
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars
{
   return [self setupHeuristic:_cmd with:rvars];
}
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars
{
   return [self setupHeuristic:_cmd with:rvars];
}
-(id<CPHeuristic>) createFF
{
   return [self setupHeuristic:_cmd];
}
-(id<CPHeuristic>) createWDeg
{
   return [self setupHeuristic:_cmd];
}
-(id<CPHeuristic>) createDDeg
{
   return [self setupHeuristic:_cmd];
}
-(id<CPHeuristic>) createSDeg
{
   return [self setupHeuristic:_cmd];
}
-(id<CPHeuristic>) createIBS
{
   return [self setupHeuristic:_cmd];
}
-(id<CPHeuristic>) createABS
{
   return [self setupHeuristic:_cmd];
}
-(ORUInt) degree:(id<ORVar>)x
{
   return [[self worker] degree:x];
}
-(ORInt) intValue: (id<ORIntVar>) x
{
   return [(id<CPProgram>)[self worker] intValue: x];
}
-(ORBool) bound: (id<ORVar>) x
{
   return [[self worker] bound: x];
}
-(ORInt)  min: (id<ORIntVar>) x
{
   return [[self worker] min: x];
}
-(ORInt)  max: (id<ORIntVar>) x
{
   return [[self worker] max: x];
}
-(ORInt)  domsize: (id<ORIntVar>) x
{
   return [[self worker] domsize: x];
}
-(ORInt)  member: (ORInt) v in: (id<ORIntVar>) x
{
   return [[self worker] member: v in: x];
}
-(ORFloat) floatValue: (id<ORFloatVar>) x
{
   return [((id<CPProgram>)[self worker]) floatValue: x];
}
-(ORFloat) domwidth:(id<ORFloatVar>)x
{
   return [[self worker] domwidth: x];
}
-(ORFloat) floatMin:(id<ORFloatVar>)x
{
   return [[self worker] floatMin:x];
}
-(ORFloat) floatMax:(id<ORFloatVar>)x
{
   return [[self worker] floatMax:x];
}
-(void) assignRelaxationValue: (ORFloat) f to: (id<ORFloatVar>) x
{
   return [[self worker] assignRelaxationValue:  f to:  x];
}
-(ORBool) boolValue: (id<ORIntVar>)x
{
   return [[self worker] boolValue: x];
}
-(ORInt) maxBound:(id<ORIdArray>) x
{
   return [[self worker] maxBound:(id)x];
}
-(ORBool) allBound:(id<ORIdArray>) x
{
   return [[self worker] allBound:x];
}
-(NSSet*)constraints:(id<ORVar>)x
{
   return [[self worker] constraints:x];
}
-(id<ORCPSolution>) captureSolution
{
   return (id<ORCPSolution>) [[self worker] captureSolution];
}
-(id<ORObject>) concretize: (id<ORObject>) o
{
   return [[self worker] concretize: o];
}
@end
