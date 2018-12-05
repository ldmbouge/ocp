/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <ORProgram/ORCPParSolver.h>
#import <ORProgram/CPSolver.h>
#import <ORProgram/CPParallel.h>
#import <ORProgram/CPBaseHeuristic.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/ORSolution.h>
#import <ORProgram/ORSTask.h>
#import <objcp/CPObjectQueue.h>

@interface ORControllerFactory : NSObject<ORControllerFactory> {
  CPSemanticSolver* _solver;
  Class         _ctrlClass;
  Class         _nestedClass;
}
-(id)initFactory:(CPSemanticSolver*)solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc;
-(id<ORSearchController>)makeRootController;
-(id<ORSearchController>)makeNestedController;
@end

@implementation CPParSolverI  {
   id<CPSemanticProgram>* _workers;
   
   PCObjectQueue*       _queue;
   NSCondition*    _terminated;
   ORInt               _nbDone;
   id<ORSearchController> _defCon;
   BOOL         _doneSearching;
   id<ORModel>        _source;
   NSCondition*      _allClosed;
   ORInt              _nbClosed;
   id<ORObjectiveValue> _primal;
   BOOL                _boundOk;
   ORLong                _sowct;
}
-(id<CPProgram>) initParSolver:(ORInt)nbt withController:(id<ORSearchController>)ctrlProto
{
   self = [super init];
   _source = NULL;
   _nbWorkers = nbt;
   _workers   = malloc(sizeof(id<CPSemanticProgram>)*_nbWorkers);
   memset(_workers,0,sizeof(id<CPSemanticProgram>)*_nbWorkers);
   _queue = [[PCObjectQueue alloc] initPCQueue:128 nbWorkers:_nbWorkers];
   _terminated = [[NSCondition alloc] init];
   _allClosed  = [[NSCondition alloc] init];
   _defCon     = ctrlProto;
   _nbDone     = 0;
   _nbClosed   = 0;
   _boundOk    = NO;
   _primal     = NULL;
   for(ORInt i=0;i<_nbWorkers;i++)
      _workers[i] = [CPSolverFactory semanticSolver:[ctrlProto copy]];
   _globalPool = [ORFactory createSolutionPool];
   _onSol = nil;
   _onStartup = nil;
   _doneSearching = NO;
   _sowct = [ORRuntimeMonitor wctime];
   _nbf = _nbc = 0;
   return self;
}
-(void)dealloc
{
   NSLog(@"CPParSolverI (%p) dealloc'd...",self);
   free(_workers);
   [_source release];
   [_queue release];
   [_terminated release];
   [_allClosed release];
   [_globalPool release];
   [_onSol release];
   [_onStartup release];
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
-(ORInt)nbWorkers
{
   return _nbWorkers;
}
-(void) waitWorkers
{
   [_terminated lock];
   while (_nbDone < _nbWorkers)
      [_terminated wait];
   [_terminated unlock];
}
-(id<CPCommonProgram>) worker
{
   return _workers[[NSThread threadID]];
}
-(void) restartHeuristics
{
   assert(NO);
}
-(id<ORModelMappings>) modelMappings
{
   return [[self worker] modelMappings];
}
-(NSMutableArray*) variables
{
   return [[[self worker] engine] variables];
}
-(id<CPPortal>) portal
{
   return [[self worker] portal];
}
-(ORInt) nbFailures
{
   if (_nbDone == _nbWorkers)
      return _nbf;
   else
      return [[self worker] nbFailures];
}
-(ORInt) nbChoices
{
   if (_nbDone == _nbWorkers)
      return _nbc;
   else
      return [[self worker] nbChoices];
}
-(id<CPEngine>) engine
{
  return [[self worker] engine];
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
  return [[self worker] close];
}
-(id<ORForall>) forall: (id<ORIntIterable>) S
{
  return [[self worker] forall:S];
}
-(void) forall: (id<ORIntIterable>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
  [[self worker] forall:S orderedBy:order do:body];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
  [[self worker] forall:S suchThat:filter orderedBy:order do:body];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedByFloat: (ORInt2Float) order do: (ORInt2Void) body
{
    [[self worker] forall:S suchThat:filter orderedByFloat:order do:body];
}
-(void) forall: (id<ORIntIterable>) S  orderedBy: (ORInt2Int) o1 then: (ORInt2Int) o2  do: (ORInt2Void) b
{
  [[self worker] forall:S orderedBy:o1 then:o2 do:b];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 then: (ORInt2Int) o2  do: (ORInt2Void) b
{
  [[self worker] forall:S suchThat:suchThat orderedBy:o1 then:o2  do:b];
}
-(void) try: (ORClosure) left alt: (ORClosure) right
{
   [[[self worker] explorer] try: left alt: right];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter do: (ORInt2Void) body
{
   [[[self worker] explorer] tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [[[self worker] explorer] tryall: range suchThat: filter in: body onFailure: onFailure];
}
-(void) tryall: (id<ORIntIterable>) range
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
-(id) trackObject: (id) object
{
   return [[self worker] trackObject: object];
}
-(id) trackObjective: (id) object
{
   return [[self worker] trackObjective: object];
}
-(id) trackConstraintInGroup:(id)object
{
   return [[self worker] trackConstraintInGroup: object];
}
-(id) trackMutable: (id) object
{
   return [[self worker] trackMutable: object];
}
-(id) trackImmutable: (id) object
{
   return [[self worker] trackImmutable: object];
}
-(id) trackVariable: (id) object
{
   return [[self worker] trackVariable: object];
}
-(void) addConstraintDuringSearch: (id<ORConstraint>) c
{
   [[self worker] addConstraintDuringSearch: c];
}
-(void)add: (id<ORConstraint>) c
{
   [[self worker] add:c];
}
-(void) addHeuristic:(id<CPHeuristic>)h
{
   assert(FALSE);
}
-(void) setGamma: (id*) gamma
{
   @throw [[ORExecutionError alloc] initORExecutionError: "setGamma never called on CPParProgram"];
}
-(void) setTau: (id<ORTau>) tau
{
   @throw [[ORExecutionError alloc] initORExecutionError: "setTau never called on CPParProgram"];
}
-(id*) gamma
{
   return [[self worker] gamma];
}
-(void) atomic:(ORClosure)body
{
   [[self worker] atomic:body];
}
// Nested
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
// ********
-(void)          specialSearch: (id<ORDisabledFloatVarArray>) x
{
   [[self worker] specialSearch:x];
}
-(void)          customSearch: (id<ORDisabledFloatVarArray>) x
{
   [[self worker] customSearch:x];
}
-(void)          maxWidthSearch: (id<ORDisabledFloatVarArray>) x  do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] maxWidthSearch:x do:b];
}
-(void)          minWidthSearch: (id<ORDisabledFloatVarArray>) x  do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] minWidthSearch:x do:b];
}
-(void)          maxCardinalitySearch: (id<ORDisabledFloatVarArray>) x  do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] maxCardinalitySearch:x do:b];
}
-(void)          minCardinalitySearch: (id<ORDisabledFloatVarArray>) x  do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] minCardinalitySearch:x do:b];
}
-(void)          maxDensitySearch: (id<ORDisabledFloatVarArray>) x  do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] maxDensitySearch:x do:b];
}
-(void)          minDensitySearch: (id<ORDisabledFloatVarArray>) x  do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] minDensitySearch:x do:b];
}
-(void)          maxMagnitudeSearch: (id<ORDisabledFloatVarArray>) x  do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] maxMagnitudeSearch:x do:b];
}
-(void)          minMagnitudeSearch: (id<ORDisabledFloatVarArray>) x  do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] minMagnitudeSearch:x do:b];
}
-(void)          maxAbsDensSearch: (id<ORDisabledFloatVarArray>) x  default:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
   [[self worker] maxAbsDensSearch:x default:b];
}
-(void)          lexicalOrderedSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] lexicalOrderedSearch:x do:b];
}
-(void)          maxDegreeSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] maxDegreeSearch:x do:b];
}
-(void)          minDegreeSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] minDegreeSearch:x do:b];
}
-(void)          maxOccurencesRatesSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
   [[self worker] maxOccurencesRatesSearch:x do:b];
}
-(void)          maxOccurencesSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] maxOccurencesSearch:x do:b];
}
-(void)          minOccurencesSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] minOccurencesSearch:x do:b];
}
-(void)          maxAbsorptionSearchAll: (id<ORDisabledFloatVarArray>) x default:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b;
{
   [[self worker] maxAbsorptionSearchAll:x default:b];
}
-(void)          maxAbsorptionSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b;
{
    [[self worker] maxAbsorptionSearch:x do:b];
}
-(void)          minAbsorptionSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] minAbsorptionSearch:x do:b];
}
-(void)          maxAbsorptionSearch: (id<ORDisabledFloatVarArray>) x default:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
   [[self worker] maxAbsorptionSearch:x default:b];
}
-(void)          maxCancellationSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] maxCancellationSearch:x do:b];
}
-(void)          minCancellationSearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
    [[self worker] minCancellationSearch:x do:b];
}
-(void) splitArray: (id<ORIntVarArray>) x
{
   [[self worker] splitArray:x];
}
-(void) split: (id<ORIntVar>)x
{
   [[self worker] split:x];
}
-(void) labelArray: (id<ORIntVarArray>) x
{
   [[self worker] labelArray: x];
}
-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Double) orderedBy
{
   [[self worker] labelArray: x orderedBy: orderedBy];
}
-(void) labelArrayFF: (id<ORIntVarArray>) x
{
   [[self worker] labelArrayFF:x];
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
-(void) labelBV: (id<ORBitVar>) var at:(ORUInt) i with:(ORBool)val
{
   [(id<CPBV>)[self worker] labelBV:var at:i with:val];
}
-(void) labelUpFromLSB:(id<ORBitVar>) x
{
   [(id<CPBV>)[self worker] labelUpFromLSB:x];
}
-(void) select: (id<ORIntVarArray>)x minimizing:(ORInt2Double)f in:(ORInt2Void)body
{
   [[self worker] select:x minimizing:f in:body];
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
-(void)          floatStaticSplit: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
    [[self worker] floatStaticSplit:i withVars:vars];
}
-(void)          floatStatic3WaySplit: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
    [[self worker] floatStatic3WaySplit:i withVars:vars];
}
-(void)          floatStatic5WaySplit: (ORUInt) i  withVars:(id<ORDisabledFloatVarArray>) vars
{
    [[self worker] floatStatic5WaySplit:i  withVars:vars];
}
-(void)          floatStatic6WaySplit: (ORUInt) i  withVars:(id<ORDisabledFloatVarArray>) vars
{
    [[self worker] floatStatic6WaySplit:i withVars:vars];
}
-(void)          floatAbsSplit: (ORUInt) i by:(id<CPFloatVar>) y  withVars:(id<ORDisabledFloatVarArray>) x  default:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
   [[self worker] floatAbsSplit:i by:y  withVars:x default:b];
}
-(void)          floatSplit: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
   [[self worker] floatSplit:i withVars:vars];
}
-(void)          float3BSplit: (ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) vars
{
   [[self worker] float3BSplit:i call:s withVars:vars];
}
-(void)          float3WaySplit: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
    [[self worker] float3WaySplit:i withVars:vars];
}
-(void)          float5WaySplit: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
    [[self worker] float5WaySplit:i withVars:vars];
}
-(void)          float6WaySplit: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
    [[self worker] float6WaySplit:i withVars:vars];
}
-(void)          floatEWaySplit: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
   [[self worker] floatEWaySplit:i withVars:vars];
}
-(void)          floatDeltaSplit: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
   [[self worker] floatDeltaSplit:i withVars:vars];
}
-(void)          floatSplitD: (ORUInt) i withVars:(id<ORDisabledFloatVarArray>) vars
{
   [[self worker] floatSplitD:i withVars:vars];
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
-(void) fail
{
   [[[self worker] explorer] fail];
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

-(ORBool) bound: (id<ORVar>) x
{
   return [[self worker] bound:x];
}
-(ORInt)  min: (id<ORIntVar>) x
{
   return [[self worker] min:x];
}
-(ORInt)  max: (id<ORIntVar>) x
{
   return [[self worker] max:x];
}
-(id<ORIdArray>) computeAbsorptionsQuantities:(id<ORDisabledFloatVarArray>) vars
{
   return [[self worker] computeAbsorptionsQuantities: vars];
}
-(ORDouble) computeAbsorptionRate:(id<ORFloatVar>) x
{
   return [[self worker] computeAbsorptionRate:x];
}
-(ORInt)  domsize: (id<ORIntVar>) x
{
   return [[self worker] domsize:x];
}
-(ORInt) regret: (id<ORIntVar>) x
{
   return [[self worker] regret:x];
}
-(ORDouble) domwidth:(id<ORRealVar>)x
{
   return [[self worker] domwidth:x];
}
-(ORUInt)  maxOccurences:(id<ORVar>) x
{
   return [[self worker] maxOccurences: x];
}
-(ORDouble) cardinality: (id<ORFloatVar>) x
{
   return [[self worker] cardinality: x];
}
-(ORDouble)  cancellationQuantity:(id<ORVar>) x
{
   return [[self worker] cancellationQuantity: x];
}
-(ORLDouble) density: (id<ORFloatVar>) x
{
   return [[self worker] density: x];
}
-(ORUInt)  countMemberedConstraints:(id<ORVar>) x
{
   return [[self worker] countMemberedConstraints: x];
}
-(ORDouble) fdomwidth:(id<ORFloatVar>) x
{
   return [[self worker] fdomwidth: x];
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
-(ORInt)memberBit:(ORInt)k value:(ORInt)v in: (id<ORBitVar>) x
{
   id<CPBV> ptr = (id<CPBV>)[self worker];
   return [ptr memberBit:k value:v in:x];
}
-(ORBool) bitAt:(ORUInt)pos in:(id<ORBitVar>)x
{
   return [(id<CPBV>)[self worker] bitAt:pos in:x];
}
-(ORBool)boundBit:(ORInt)k in:(id<ORBitVar>)x
{
   return [(id<CPBV>)[self worker] boundBit:k in:x];
}
-(ORInt)  member: (ORInt) v in: (id<ORIntVar>) x
{
   return [[self worker] member:v in:x];
}
-(ORInt) maxBound:(id<ORIdArray>) x
{
   return [[self worker] maxBound:(id)x];
}
-(ORBool) allBound:(id<ORIdArray>) x
{
   return [[self worker] allBound:x];
}
-(ORBool) ground
{
   return [[self worker] ground];
}
-(id<ORIntVar>)smallestDom:(id<ORIntVarArray>)x
{
   return [[self worker] smallestDom:x];
}
-(NSString*)stringValue:(id<ORBitVar>)x
{
   return [(id<CPBV>)[self worker] stringValue: x];
}
-(NSSet*)constraints:(id<ORVar>)x
{
   return [[self worker] constraints:x];
}
-(void)onStartup:(ORClosure)onStartup
{
   _onStartup = [onStartup copy];
}
-(void)onSolution:(ORClosure)onSolution
{
   _onSol = [onSolution copy];
}
-(void) onExit: (ORClosure) onExit
{
   for(ORInt k = 0; k < _nbWorkers; k++) 
    [_workers[k] onExit: onExit];
}
-(void) doOnSolution
{
   [[self worker] doOnSolution];
}
-(void) doOnStartup
{
   if (_onStartup)
      _onStartup();
   [[self worker] doOnStartup];
}
-(void) doOnExit
{
}
-(void) defaultSearch
{
   id<CPHeuristic> h = [self createFF];
   [self solveAll:^{
      [self labelHeuristic:h];
   }];
}
-(void) search:(void*(^)(void))stask
{
   //TODO: This is not correct yet.
   [self solve:^{
      id<ORSTask> theTask = (id<ORSTask>)stask();
      [theTask execute];
   }];
}
-(void) searchAll:(void*(^)(void))stask
{
   [self solveAll:^{
      id<ORSTask> theTask = (id<ORSTask>)stask();
      [theTask execute];
   }];
}

-(void) clearOnStartup
{
   for(ORInt k = 0; k < _nbWorkers; k++)
      [_workers[k] clearOnStartup];
}
-(void) clearOnSolution
{
   for(ORInt k = 0; k < _nbWorkers; k++)
      [_workers[k] clearOnSolution];
}
-(void) clearOnExit
{
   for(ORInt k = 0; k < _nbWorkers; k++)
      [_workers[k] clearOnExit];
}
-(id<ORSolutionPool>) solutionPool
{
   return _globalPool;
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [[self worker] objectiveValue];
}
-(void)setupWork:(id<ORProblem>)theSub forCP:(id<CPSemanticProgram>)cp
{
   //NSLog(@"***** THREAD(%d) SETUP work size: %@",[NSThread threadID],theSub);
   id<ORPost> pItf = [[CPINCModel alloc] init:_workers[[NSThread threadID]]];
   ORStatus status = [[cp tracer] restoreProblem:theSub inSolver:[cp engine] model:pItf];
   [pItf release];
   if (status == ORFailure) {
      [[cp explorer] fail];
   }
    [cp restartHeuristics];
}
-(ORLong)setupAndGo:(id<ORProblem>)root forCP:(ORInt)myID searchWith:(ORClosure)body all:(ORBool)allSols
{
   ORLong t0 = [ORRuntimeMonitor cputime];
   id<CPSemanticProgram> me  = _workers[myID];
   id<ORExplorer> ex = [me explorer];
   id<ORSearchController> nested = [[ex controllerFactory] makeNestedController];
   id<ORSearchController> parc = [[CPParallelAdapter alloc] initCPParallelAdapter:nested
                                                                         explorer:me
                                                                           onPool:_queue
                                                                    stopIndicator:&_doneSearching];
   [nested release];
   id<ORSearchObjectiveFunction> objective = [me objective];
   //NSLog(@"SetupAndGo(%d): obj* = %@",[NSThread threadID],[objective value]);
   if (objective != nil) {
      [[me explorer] nestedOptimize: me
                              using: ^ { [self setupWork:root forCP:me]; body(); }
                         onSolution: ^ {
                            [self doOnSolution];
                            id<ORObjectiveValue> myBound = [objective primalBound];
                            for(ORInt w=0;w < _nbWorkers;w++) {
                               if (w == myID) continue;
                               id<ORSearchObjectiveFunction> wwObj = [_workers[w] objective];
                               [wwObj tightenPrimalBound: myBound];
                               //NSLog(@"TIGHT: %@  -- thread %d",wwObj,[NSThread threadID]);
                            }
                            [myBound release];
                         }
                             onExit: nil
                            control: parc];
   } else {
      //NSLog(@"ALLSOL IS: %d",allSols);
      if (allSols) {
        [[me explorer] nestedSolveAll:^() { [self setupWork:root forCP:me];body();}
                           onSolution: ^ {
                              [self doOnSolution];
                              [me doOnSolution];
                           }
                               onExit:nil
                              control:parc];
      } else {
        [[me explorer] nestedSolve:^() { [self setupWork:root forCP:me];body();}
                        onSolution: ^ {
                           _doneSearching = YES;
                           [self doOnSolution];
                           [me doOnSolution];
                         }
                             onExit:nil
                            control:parc];        
      }
   }
   ORLong t1 = [ORRuntimeMonitor cputime];
   //NSLog(@"Thread %d back from sub: %lld  AT [%lld]",[NSThread threadID],t1-t0,([ORRuntimeMonitor wctime]-_sowct)/1000);
   return t1 - t0;
}

-(void) workerSolve:(NSArray*)input
{
   ORInt myID = [[input objectAtIndex:0] intValue];
   ORClosure mySearch = [input objectAtIndex:1];
   NSNumber* allSols  = [input objectAtIndex:2];
   [NSThread setThreadPriority:1.0];
   [NSThread setThreadID:myID];
   if (_onSol)
      [_workers[myID] onSolution: _onSol];
   _doneSearching = NO;
   [self doOnStartup];
   [[_workers[myID] explorer] search: ^() {
      [_workers[myID] close];
      // The probing can already tigthen the bound of the objective.
      // We want all the workers to start with the best.
      id<ORSearchObjectiveFunction> ok  = [_workers[myID] objective];
      if (ok) {
         [_allClosed lock];
         if (_nbClosed == 0)
            _primal = [ok primalBound];
         else {
            id<ORObjectiveValue> newValue = [ok primalBound];
            id<ORObjectiveValue> bestValue = [_primal best: newValue];
            [_primal release];
            [newValue release];
            _primal = bestValue;
         }
         while (_nbClosed < _nbWorkers - 1) {
            _nbClosed += 1;
            [_allClosed wait];
         }
         [_allClosed signal];
         if (_boundOk == NO) {
            _boundOk = YES;
            for(ORInt w=0;w < _nbWorkers;w++) {
               id<ORSearchObjectiveFunction> wwObj = [_workers[w] objective];
               [wwObj tightenPrimalBound: _primal];
            }
         }
         [_allClosed unlock];
      }
      
      if (myID == 0) {
         // The first guy produces a sub-problem that is the root of the whole tree.
         id<ORProblem> root = [[_workers[myID] tracer] captureProblem];
         [_queue enQueue:root];
      }
      id<ORProblem> cpRoot = nil;
      //ORLong took = 0;
      ORTimeval before = [ORRuntimeMonitor now];
      ORLong sleeping = 0;
      while (!_doneSearching && (cpRoot = [_queue deQueue]) !=nil) {
         if (!_doneSearching) {
            ORTimeval sleepy = [ORRuntimeMonitor elapsedSince:before];
            sleeping += sleepy.tv_sec* 1000 + sleepy.tv_usec / 1000;
            [self setupAndGo:cpRoot forCP:myID searchWith:mySearch all:allSols.boolValue];
            before = [ORRuntimeMonitor now];
         }
         [cpRoot release];
      }
      NSLog(@"Worker %d spent %lld sleeping",[NSThread threadID],sleeping);
      NSLog(@"IN Queue after leaving: %d (%s)",[_queue size],(_doneSearching ? "YES" : "NO"));
   }];
   // Final tear down. The worker is done with the model.
   NSLog(@"Worker[%d] = %@",myID,_workers[myID]);
   // [LDM]. Solvers are auto-released. We should never manually deallocate them.
   //[_workers[myID] release];
   _nbf += [_workers[myID] nbFailures];
   _nbc += [_workers[myID] nbChoices];
   _workers[myID] = nil;
   [mySearch release];
   [ORFactory shutdown];
   // Possibly notify the main thread if all workers are done.
   [_terminated lock];
   ++_nbDone;
   if (_nbDone == _nbWorkers)
      [_terminated signal];
   [_terminated unlock];
}

-(void) solveOn: (void(^)(id<CPCommonProgram>))body withTimeLimit: (ORFloat)limit;
{
    // Not implemented
    assert(NO);
}
-(void) solveAll:(ORClosure)search
{
   for(ORInt i=0;i<_nbWorkers;i++) {
      [NSThread detachNewThreadSelector:@selector(workerSolve:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                         [search copy],@(YES),nil]];
   }
   [self waitWorkers]; // wait until all the workers are done.
   
}
-(void) solve: (ORClosure) search
{
   for(ORInt i=0;i<_nbWorkers;i++) {
      [NSThread detachNewThreadSelector:@selector(workerSolve:)
                               toTarget:self
                             withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                         [search copy],@(NO),nil]];
   }
   [self waitWorkers]; // wait until all the workers are done.
}
-(id<CPHeuristic>) createPortfolio:(NSArray*)hs with:(id<ORVarArray>)vars
{
   assert(FALSE);
   return NULL;
}
-(void) solveOn: (void(^)(id<CPCommonProgram>))body
{
   //LDM: needs testing.
   ORClosure search = ^() { body(self); };
   [self solve: search];
}

-(id<CPHeuristic>) createFF:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createFF:rvars];
  return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createWDeg:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createDDeg:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createSDeg:(id<ORVarArray>)rvars
{
   id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
   for(ORInt i=0;i < _nbWorkers;i++)
      binding[i] = [_workers[i] createSDeg:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createIBS:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createABS:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createFDS:(id<ORVarArray>)rvars
{
   id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
   for(ORInt i=0;i < _nbWorkers;i++)
      binding[i] = [_workers[i] createFDS:rvars];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createFF
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createFF];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createWDeg
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createWDeg];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createDDeg
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createDDeg];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createSDeg
{
   id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
   for(ORInt i=0;i < _nbWorkers;i++)
      binding[i] = [_workers[i] createSDeg];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createIBS
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createIBS];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createABS
{
  id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
  for(ORInt i=0;i < _nbWorkers;i++)
    binding[i] = [_workers[i] createABS];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(id<CPHeuristic>) createFDS
{
   id<ORBindingArray> binding = [ORFactory bindingArray:self nb:_nbWorkers];
   for(ORInt i=0;i < _nbWorkers;i++)
      binding[i] = [_workers[i] createFDS];
   return [[CPVirtualHeuristic alloc] initWithBindings:binding];
}
-(ORUInt) degree:(id<ORVar>)x
{
   return [[self worker] degree:x];
}
-(ORInt) intValue: (id<ORIntVar>) x
{
   return [[self worker] intValue: x];
}
-(ORFloat) floatValue: (id<ORFloatVar>) x
{
    return [[self worker] intValue: x];
}
-(ORDouble) doubleValue: (id<ORVar>) x
{
   return [[self worker] doubleValue: x];
}
-(ORBool) boolValue: (id<ORIntVar>) x
{
   return [((id<CPCommonProgram>) [self worker]) boolValue: x];
}
-(id<ORSolution>) captureSolution
{
   return (id<ORSolution>) [[self worker] captureSolution];
}
-(ORDouble) paramValue: (id<ORRealParam>)p
{
    return [[self worker] paramValue: _gamma[p.getId]];
}
-(void) param: (id<ORRealParam>)p setValue: (ORDouble)val
{
    [[self worker] param: _gamma[p.getId] setValue: val];
}

- (void)combinedAbsWithDensSearch:(PNONNULL id<ORDisabledFloatVarArray>)x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
   [[self worker] combinedAbsWithDensSearch:x do:b];
}
- (void)combinedDensWithAbsSearch:(PNONNULL id<ORDisabledFloatVarArray>)x do:(void(^)(ORUInt,id<ORDisabledFloatVarArray>))b
{
   [[self worker] combinedDensWithAbsSearch:x do:b];
}
- (void)switchedSearch:(PNONNULL id<ORDisabledFloatVarArray>)x do:(void (^ PNONNULL )(ORUInt,id<ORDisabledFloatVarArray>))b
{
   [[self worker] switchedSearch:x do:b];
}
- (NSArray *)collectAllVarWithAbs:(id<ORFloatVarArray>)vs {
   return [[self worker] collectAllVarWithAbs:vs];
}
- (NSArray *)collectAllVarWithAbs:(id<ORFloatVarArray>)vs withLimit:(ORDouble)limit {
   return [[self worker] collectAllVarWithAbs:vs withLimit:limit];
}
-(id<ORObject>) concretize: (id<ORObject>) o
{
   return [[self worker] concretize: o];
}
- (void)visit:(ORVisitor *)visitor
{

}

@end


// *********************************************************************************************************
// Controller Factory
// *********************************************************************************************************

@implementation ORControllerFactory
-(id)initFactory:(CPSemanticSolver*)solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc
{  self = [super init];
  _solver = solver;
  _ctrlClass = class;
  _nestedClass = nc;
  return self;}
-(id<ORSearchController>)makeRootController
{
  id<ORPost> pItf = [[CPINCModel alloc] init:_solver];
  return [[_ctrlClass alloc] initTheController:[_solver tracer] engine:[_solver engine] posting:pItf];
}
-(id<ORSearchController>)makeNestedController
{
   id<ORPost> pItf = [[CPINCModel alloc] init:_solver];
   return [[_nestedClass alloc] initTheController:[_solver tracer] engine:[_solver engine] posting:pItf];
}
@end
