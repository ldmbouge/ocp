/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORParameter.h>
#import <ORProgram/CPHeuristic.h>

@protocol ORModel;
@protocol ORSearchController;
@protocol CPEngine;
@protocol ORExplorer;
@protocol ORIdxIntInformer;
@protocol ORTracer;
@protocol ORSolutionPool;
@protocol CPBitVar;
@protocol ORSTask;

PORTABLE_BEGIN

@protocol CPPortal <NSObject>
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) retLT;
-(id<ORIdxIntInformer>) retGT;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORIdxIntInformer>) failLT;
-(id<ORIdxIntInformer>) failGT;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

@protocol CPCommonProgram  <ORASearchSolver,ORGamma>
-(void) setSource:(id<ORModel>)src;
-(id<ORModel>)       source;
-(ORInt)         nbFailures;
-(ORInt)          nbChoices;
-(id<CPEngine>)      engine;
-(id<ORExplorer>)  explorer;
-(id<ORSearchObjectiveFunction>) objective;
-(id<CPPortal>)      portal;
-(id<ORTracer>)      tracer;
-(ORBool) ground;
-(void)                 add: (id<ORConstraint>) c;
-(void)               label: (id<ORIntVar>) var with: (ORInt) val;
-(void)                diff: (id<ORIntVar>) var with: (ORInt) val;
-(void)               lthen: (id<ORIntVar>) var with: (ORInt) val;
-(void)               gthen: (id<ORIntVar>) var double: (ORDouble) val;
-(void)               lthen: (id<ORIntVar>) var double: (ORDouble) val;
-(void)               gthen: (id<ORIntVar>) var with: (ORInt) val;
-(void)          realLabel: (id<ORRealVar>) var with: (ORDouble) val;
-(void)          realLthen: (id<ORRealVar>) var with: (ORDouble) val;
-(void)          realGthen: (id<ORRealVar>) var with: (ORDouble) val;
-(void)         addConstraintDuringSearch: (id<ORConstraint>) c;

-(void)            restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S;
-(void)  restartHeuristics;
-(void)        addHeuristic: (id<CPHeuristic>) h;
-(void)          splitArray: (id<ORIntVarArray>) x;
-(void)          labelArray: (id<ORIntVarArray>) x;
-(void)          labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Double) orderedBy;
-(void)        labelArrayFF: (id<ORIntVarArray>) x;
-(void)      labelHeuristic: (id<CPHeuristic>) h;
-(void)      labelHeuristic: (id<CPHeuristic>) h restricted:(id<ORIntVarArray>)av;
-(void)               label: (id<ORIntVar>) mx;
-(void)               label: (id<ORIntVar>) mx by: (ORInt2Double) o;
-(void)               label: (id<ORIntVar>) mx by: (ORInt2Double) o1 then: (ORInt2Double) o2;

-(ORInt)        selectValue: (id<ORIntVar>) v by: (ORInt2Double) o;
-(ORInt)        selectValue: (id<ORIntVar>) v by: (ORInt2Double) o1 then: (ORInt2Double) o2;

-(void)               solve: (ORClosure) body;
-(void)             solveOn: (void(^)(id<CPCommonProgram>))body;
-(void)             solveOn: (void(^)(id<CPCommonProgram>))body withTimeLimit: (ORFloat)limit;
-(void)            solveAll: (ORClosure) body;
-(void)               close;

-(id<ORForall>)      forall: (id<ORIntIterable>) S;
-(void)              forall: (id<ORIntIterable>) S
                  orderedBy: (PNULLABLE ORInt2Int) o
                         do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterable>) S
                   suchThat: (PNULLABLE ORInt2Bool) suchThat
                  orderedBy: (PNULLABLE ORInt2Int) o
                         do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterable>) S
                  orderedBy: (ORInt2Int) o1
                       then: (ORInt2Int) o2
                         do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterable>) S
                   suchThat: (PNULLABLE ORInt2Bool) suchThat
                  orderedBy: (ORInt2Int) o1
                       then: (ORInt2Int) o2
                         do: (ORInt2Void) b;
-(void)                 try: (ORClosure) left alt: (ORClosure) right;
-(void)              tryall: (id<ORIntIterable>) range suchThat: (PNULLABLE ORInt2Bool) f do: (ORInt2Void) body;
-(void)              tryall: (id<ORIntIterable>) range suchThat: (PNULLABLE ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
-(void)              tryall: (id<ORIntIterable>) range
                   suchThat: (PNULLABLE ORInt2Bool) filter
                  orderedBy: (ORInt2Double)o1
                         in: (ORInt2Void) body
                  onFailure: (ORInt2Void) onFailure;

-(void)              select: (id<ORIntVarArray>)x minimizing:(ORInt2Double)f in:(ORInt2Void)body;

-(void)           limitTime: (ORLong) maxTime in: (ORClosure) cl;
-(void)                 try: (ORClosure) body then: (ORClosure) body;
-(void)                once: (ORClosure) cl;

-(void)      nestedOptimize: (ORClosure) body onSolution: (PNULLABLE ORClosure) onSolution onExit: (PNULLABLE ORClosure) onExit  control:(id<ORSearchController>)newCtrl;
-(void)         nestedSolve: (ORClosure) body onSolution: (PNULLABLE ORClosure) onSolution onExit: (PNULLABLE ORClosure) onExit  control:(id<ORSearchController>)newCtrl;
-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)         nestedSolve: (ORClosure) body;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (PNULLABLE ORClosure) onSolution onExit: (PNULLABLE ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)      nestedSolveAll: (ORClosure) body;
-(void)           onStartup: (ORClosure) onStartup;
-(void)          onSolution: (ORClosure) onSolution;
-(void)              onExit: (ORClosure) onExit;
-(void) clearOnStartup;
-(void) clearOnSolution;
-(void) clearOnExit;
-(id<CPHeuristic>) createFF:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createSDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createFDS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createFF;
-(id<CPHeuristic>) createWDeg;
-(id<CPHeuristic>) createDDeg;
-(id<CPHeuristic>) createSDeg;
-(id<CPHeuristic>) createIBS;
-(id<CPHeuristic>) createABS;
-(id<CPHeuristic>) createFDS;
-(id<CPHeuristic>) createPortfolio:(NSArray*)hs with:(id<ORVarArray>)vars;
-(void) defaultSearch;
-(void) search:(void*(^)())stask;
-(void) searchAll:(void*(^)())stask;
-(void) doOnStartup;
-(void) doOnSolution;
-(void) doOnExit;
-(id<ORSolutionPool>) solutionPool;
-(id<ORSolution>) captureSolution;

-(ORUInt) degree:(id<ORVar>)x;
-(ORInt) intValue: (id) x;
-(ORBool) bound: (id<ORVar>) x;
-(ORInt)  min: (id<ORIntVar>) x;
-(ORInt)  max: (id<ORIntVar>) x;
-(ORInt)  domsize: (id<ORIntVar>) x;
-(ORInt)  regret:(id<ORIntVar>)x;
-(ORInt)  member: (ORInt) v in: (id<ORIntVar>) x;
-(NSSet*) constraints: (id<ORVar>)x;

-(void)    assignRelaxationValue: (ORDouble) f to: (id<ORRealVar>) x;
-(ORDouble) doubleValue: (id<ORRealVar>) x;
-(ORDouble) doubleMin: (id<ORRealVar>)x;
-(ORDouble) doubleMax: (id<ORRealVar>)x;
-(ORDouble) domwidth: (id<ORRealVar>)x;
-(ORDouble) paramValue: (id<ORRealParam>)p;
-(void) param: (id<ORRealParam>)p setValue: (ORDouble)val;

-(ORBool) boolValue: (id<ORIntVar>) x;
-(ORInt) maxBound: (id<ORIntVarArray>) x;
-(id<ORIntVar>)smallestDom:(id<ORIntVarArray>)x;
-(ORBool) allBound:(id<ORIdArray>) x;
-(void)       switchOnDepth: (ORClosure) s1 to: (ORClosure) s2 limit: (ORInt) depth;
@end

// CPSolver with syntactic DFS Search
@protocol CPProgram <CPCommonProgram>
-(void)      limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)      limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void)  limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)       limitFailures: (ORInt) maxFailures in: (ORClosure) cl;

-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart;
-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart until: (ORVoid2Bool) isDone;
-(void)             perform: (ORClosure) body onLimit: (ORClosure) onRestart;
-(void)           portfolio: (ORClosure) s1 then: (ORClosure) s2;
-(void)       switchOnDepth: (ORClosure) s1 to: (ORClosure) s2 limit: (ORInt) depth;
@end


// CPSolver with semantic DFS Search
// Initially empty but will add things here
@protocol CPSemanticProgramDFS <CPCommonProgram>
-(void)      limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)      limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void)  limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)       limitFailures: (ORInt) maxFailures in: (ORClosure) cl;

-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart;
-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRestart until: (ORVoid2Bool) isDone;
@end

// CPSolver with Semantic Path
@protocol CPSemanticProgram <CPCommonProgram>
@end

@protocol CPBV
-(void) labelBit:(int)i ofVar:(id<ORBitVar>)x;
-(void) labelUpFromLSB:(id<ORBitVar>) x;
-(void) labelBitVarsFirstFail: (NSArray*)vars;
-(NSString*)stringValue:(id<ORBitVar>)x;
@end
PORTABLE_END

