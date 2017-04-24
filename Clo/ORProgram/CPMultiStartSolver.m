/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPMultiStartSolver.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORModeling.h>

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
   id<ORSolutionPool> _sPool;
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
   
   _sPool   = (id<ORSolutionPool>) [ORFactory createSolutionPool];
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
-(id<ORModel>)       source
{
   return _source;
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
-(ORInt)          nbChoices
{
   return [[self worker] nbChoices];
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
-(ORDouble) paramValue:(id<ORRealParam>)p
{
    return  [[self worker] paramValue: p];
}
-(void) param:(id<ORRealParam>)p setValue:(ORDouble)val
{
    [[self worker] param: p setValue: val];
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

-(void) solveOn:(void (^)(id<CPCommonProgram>))body withTimeLimit:(ORFloat)limit
{
    // Not implemented
    assert(NO);
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
-(void) solveOn: (void(^)(id<CPCommonProgram>))body
{
   id<CPCommonProgram> w = [self worker];
   ORClosure search = ^() { body(w); };
   [self solve: search];
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
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedByFloat:(ORInt2Float)o do:(ORInt2Void)b
{
    return [[self worker] forall: S suchThat: filter orderedByFloat: o do: b];
}
-(void) forall: (id<ORIntIterable>) S  orderedBy: (ORInt2Int) o1 then: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: [self worker] set: S];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 then: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: [self worker] set: S];
   [forall suchThat: suchThat];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}

-(void) try: (ORClosure) left alt: (ORClosure) right
{
   [[self worker] try: left alt: right];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter do: (ORInt2Void) body
{
   [[self worker] tryall: range suchThat: filter do: body];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [[self worker] tryall: range suchThat: filter in: body onFailure: onFailure];
}
-(void)              tryall: (id<ORIntIterable>) range
                   suchThat: (ORInt2Bool) filter
                  orderedBy: (ORInt2Double)o1
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
-(void) nestedOptimize: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit  control:(id<ORSearchController>)newCtrl
{
   [[self worker] nestedOptimize:body onSolution:onSolution onExit:onExit control:newCtrl];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit  control:(id<ORSearchController>)newCtrl
{
   [[self worker] nestedSolve:body onSolution:onSolution onExit:onExit control:newCtrl];
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
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc
{
   [[self worker] nestedSolveAll:body onSolution:onSolution onExit:onExit control:sc];
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
-(void) select: (id<ORIntVarArray>)x minimizing:(ORInt2Double)f in:(ORInt2Void)body
{
   [[self worker] select:x minimizing:f in:body];
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
-(void) atomic: (ORClosure)body
{
   [[self worker] atomic:body];
}
-(void) add: (id<ORConstraint>) c
{
   [(CPSolver*)[self worker] add:c];
}
-(void) addConstraintDuringSearch: (id<ORConstraint>) c
{
   [[self worker] addConstraintDuringSearch: c];
}
-(void)split:(id<ORIntVar>)x
{
   [[self worker] split:x];
}
-(void) splitArray: (id<ORIntVarArray>) x
{
   [[self worker] splitArray:x];
}
-(void) maxWidthSearch:(id<ORFloatVarArray>)x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] maxWidthSearch:x do:b];
}
-(void) minWidthSearch:(id<ORFloatVarArray>)x  do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] minWidthSearch:x do:b];
}
-(void) maxCardinalitySearch:(id<ORFloatVarArray>)x  do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] maxCardinalitySearch:x do:b];
}
-(void) minCardinalitySearch:(id<ORFloatVarArray>)x  do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] minCardinalitySearch:x do:b];
}
-(void) maxDensitySearch:(id<ORFloatVarArray>)x  do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] maxDensitySearch:x do:b];
}
-(void) minDensitySearch:(id<ORFloatVarArray>)x  do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] minDensitySearch:x do:b];
}
-(void) maxMagnitudeSearch:(id<ORFloatVarArray>)x  do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] maxMagnitudeSearch:x do:b];
}
-(void) minMagnitudeSearch:(id<ORFloatVarArray>)x  do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] minDensitySearch:x do:b];
}
-(void)  alternateMagnitudeSearch: (id<ORFloatVarArray>) x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] alternateMagnitudeSearch:x do:b];
}
-(void)  floatSplitArrayOrderedByDomSize: (id<ORFloatVarArray>) x
{
    [[self worker] floatSplitArrayOrderedByDomSize:x];
}
-(void)  floatSplitNoOrder: (id<ORFloatVarArray>) x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] floatSplitNoOrder:x do:b];
}
-(void)  maxDegreeSearch: (id<ORFloatVarArray>) x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] maxDegreeSearch:x do:b];
}
-(void)  minDegreeSearch: (id<ORFloatVarArray>) x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] minDegreeSearch:x do:b];
}
-(void)          maxOccurencesSearch: (id<ORFloatVarArray>) x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] maxOccurencesSearch:x do:b];
}
-(void)          minOccurencesSearch: (id<ORFloatVarArray>) x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] minOccurencesSearch:x do:b];
}
-(void)          maxAbsorptionSearch: (id<ORFloatVarArray>) x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] maxAbsorptionSearch:x do:b];
}
-(void)          minAbsorptionSearch: (id<ORFloatVarArray>) x do:(void(^)(id<ORFloatVar>))b
{
    [[self worker] minAbsorptionSearch:x do:b];
}
-(void)          floatStaticSplit: (id<ORFloatVar>) x
{
    [[self worker] floatStaticSplit:x];
}
-(void)          floatStatic3WaySplit: (id<ORFloatVar>) x
{
    [[self worker] floatStatic3WaySplit:x];
}
-(void)          floatStatic5WaySplit: (id<ORFloatVar>) x
{
    [[self worker] floatStatic5WaySplit:x];
}
-(void)          floatStatic6WaySplit: (id<ORFloatVar>) x
{
    [[self worker] floatStatic6WaySplit:x];
}
-(void)          floatSplit: (id<ORFloatVar>) x
{
    [[self worker] floatSplit:x];
}
-(void)          float3WaySplit: (id<ORFloatVar>) x
{
    [[self worker] float3WaySplit:x];
}
-(void)          float5WaySplit: (id<ORFloatVar>) x
{
    [[self worker] float5WaySplit:x];
}
-(void)          float6WaySplit: (id<ORFloatVar>) x
{
    [[self worker] float6WaySplit:x];
}
-(void) labelArray: (id<ORIntVarArray>) x
{
   [[self worker] labelArray: x];
}
-(void) labelArrayFF: (id<ORIntVarArray>) x
{
   [[self worker] labelArrayFF:x];
}
-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Double) orderedBy
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
-(ORInt) selectValue: (id<ORIntVar>) v by: (ORInt2Double) o
{
   return [[self worker] selectValue: v by: o];
}
-(ORInt) selectValue: (id<ORIntVar>) v by: (ORInt2Double) o1 then: (ORInt2Double) o2
{
   return [[self worker] selectValue: v by: o1 then: o2];
}
-(void) label: (id<ORIntVar>) v by: (ORInt2Double) o1 then: (ORInt2Double) o2
{
   return [[self worker] label: v by:o1 then:o2];
}
-(void) label: (id<ORIntVar>) v by: (ORInt2Double) o
{
   return [[self worker] label: v by: o];
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
-(void) lthen: (id<ORIntVar>) var double: (ORDouble) val
{
   [[self worker] lthen: var with: val];
}
-(void) gthen: (id<ORIntVar>) var double: (ORDouble) val
{
   [[self worker] gthen: var with: val];
}

-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   [[self worker] restrict: var to: S];
}
-(void) realLabel: (id<ORRealVar>) var with: (ORDouble) val
{
   [[self worker] realLabel:var with:val];
}
-(void) realLthen: (id<ORRealVar>) var with: (ORDouble) val
{
   [[self worker] realLthen: var with: val];
}
-(void) realGthen: (id<ORRealVar>) var with: (ORDouble) val
{
   [[self worker] realGthen: var with: val];
}
-(void) floatSplitArray:(id<ORFloatVarArray>)x
{
    [[self worker] floatSplitArray:x];
}
-(void) floatLthen:(id<ORFloatVar>)var with:(ORFloat)val
{
    [[self worker] floatLthen:var with:val];
}
-(void) floatGthen:(id<ORFloatVar>)var with:(ORFloat)val
{
    [[self worker] floatGthen:var with:val];
}
-(void) floatGEqual:(id<ORFloatVar>)var with:(ORFloat)val
{
    [[self worker] floatGEqual:var with:val];
}
-(void) floatLEqual:(id<ORFloatVar>)var with:(ORFloat)val
{
    [[self worker] floatLEqual:var with:val];
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
-(void) try: (ORClosure) left then: (ORClosure) right
{
   [[self worker] try: left then: right];
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
-(void) onStartup: (ORClosure) onStartup
{
   for(ORInt k = 0; k < _nb; k++)
      [_solver[k] onStartup: onStartup];
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
-(void) clearOnStartup
{
   for(ORInt k = 0; k < _nb; k++)
      [_solver[k] clearOnStartup];
}
-(void) clearOnSolution
{
   for(ORInt k = 0; k < _nb; k++)
      [_solver[k] clearOnSolution];
}
-(void) clearOnExit
{
   for(ORInt k = 0; k < _nb; k++)
      [_solver[k] clearOnExit];
}
-(void) doOnStartup
{
   @throw [[ORExecutionError alloc] initORExecutionError: "do OnStartup never called on CPMultiStartProgram"];
}
-(void) doOnSolution
{
   @throw [[ORExecutionError alloc] initORExecutionError: "do OnSolution never called on CPMultiStartProgram"];
}
-(void) doOnExit
{
   @throw [[ORExecutionError alloc] initORExecutionError: "do OnSolution never called on CPMultiStartProgram"];
}
-(void) defaultSearch
{
   id<CPHeuristic> h = [self createFF];
   [self solveAll:^{
      [self labelHeuristic:h];
   }];
}
-(void) search:(void*(^)())stask
{
   //TODO: This is not correct yet.
   [self solve:^{
      id<ORSTask> theTask = (id)stask();
      [theTask execute];
   }];
}
-(void) searchAll:(void*(^)())stask
{
   [self solveAll:^{
      id<ORSTask> theTask = (id)stask();
      [theTask execute];
   }];
}

-(id<ORSolutionPool>) solutionPool
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
-(id<CPHeuristic>) createFDS:(id<ORVarArray>)rvars
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
-(id<CPHeuristic>) createFDS
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
-(ORFloat) floatValue: (id<ORFloatVar>) x
{
    return [(id<CPProgram>)[self worker] floatValue: x];
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
-(ORInt) regret: (id<ORIntVar>) x
{
   return [[self worker] regret:x];
}
-(ORInt)  member: (ORInt) v in: (id<ORIntVar>) x
{
   return [[self worker] member: v in: x];
}
-(ORDouble) doubleValue: (id<ORRealVar>) x
{
   return [((id<CPProgram>)[self worker]) doubleValue: x];
}
-(ORDouble) domwidth:(id<ORRealVar>)x
{
   return [[self worker] domwidth: x];
}
-(ORDouble) doubleMin:(id<ORRealVar>)x
{
   return [[self worker] doubleMin:x];
}
-(ORDouble) doubleMax:(id<ORRealVar>)x
{
   return [[self worker] doubleMax:x];
}
-(void) assignRelaxationValue: (ORDouble) f to: (id<ORRealVar>) x
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
-(ORBool) ground
{
   return [[self worker] ground];
}
-(ORBool) allBound:(id<ORIdArray>) x
{
   return [[self worker] allBound:x];
}
-(id<ORIntVar>)smallestDom:(id<ORIntVarArray>)x
{
   return [[self worker] smallestDom:x];
}
-(NSSet*)constraints:(id<ORVar>)x
{
   return [[self worker] constraints:x];
}
-(id<ORSolution>) captureSolution
{
   return (id<ORSolution>) [[self worker] captureSolution];
}
-(id<ORObject>) concretize: (id<ORObject>) o
{
   return [[self worker] concretize: o];
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [[self worker] objectiveValue];
}
@end
