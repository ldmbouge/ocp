/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORModel.h>
#import <ORProgram/CPHeuristic.h>
#import <objcp/CPData.h>

@protocol ORModel;
@protocol ORSearchController;
@protocol CPEngine;
@protocol ORExplorer;
@protocol ORIdxIntInformer;
@protocol ORTracer;
@protocol ORSolutionPool;
@protocol CPBitVar;

@protocol CPPortal <NSObject>
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

@protocol ORCPSolution <ORSolution>
@end

@protocol ORCPSolutionPool <ORSolutionPool>
-(void) addSolution: (id<ORCPSolution>) s;
-(void) enumerateWith: (void(^)(id<ORCPSolution>)) block;
-(id<ORInformer>) solutionAdded;
-(id<ORCPSolution>) best;
@end

@protocol CPCommonProgram <ORASolver>
-(void) setSource:(id<ORModel>)src;
-(ORInt)         nbFailures;
-(id<CPEngine>)      engine;
-(id<ORExplorer>)  explorer;
-(id<ORSearchObjectiveFunction>) objective;
-(id<CPPortal>)      portal;
-(id<ORTracer>)      tracer;

-(void)         addConstraintDuringSearch: (id<ORConstraint>) c annotation:(ORAnnotation)n;
-(void)                 add: (id<ORConstraint>) c;
//-(void)                 add: (id<ORConstraint>) c annotation: (ORAnnotation) cons;
-(void)               label: (id<ORIntVar>) var with: (ORInt) val;
-(void)                diff: (id<ORIntVar>) var with: (ORInt) val;
-(void)               lthen: (id<ORIntVar>) var with: (ORInt) val;
-(void)               gthen: (id<ORIntVar>) var with: (ORInt) val;
-(void)            restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S;
-(void)  restartHeuristics;
-(void)        addHeuristic: (id<CPHeuristic>) h;
-(void)          labelArray: (id<ORIntVarArray>) x;
-(void)          labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy;
-(void)      labelHeuristic: (id<CPHeuristic>) h;
-(void)               label: (id<ORIntVar>) mx;

-(void)               solve: (ORClosure) body;
-(void)            solveAll: (ORClosure) body;
-(void)               close;

-(id<ORForall>)      forall: (id<ORIntIterable>) S;
-(void)              forall: (id<ORIntIterable>) S orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterable>) S orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b;
-(void)                 try: (ORClosure) left or: (ORClosure) right;
-(void)              tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
-(void)              tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;

-(void)           limitTime: (ORLong) maxTime in: (ORClosure) cl;

-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)         nestedSolve: (ORClosure) body;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)      nestedSolveAll: (ORClosure) body;
-(void)          onSolution: (ORClosure) onSolution;
-(void)              onExit: (ORClosure) onExit;
-(id<CPHeuristic>) createFF:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars;
-(id<CPHeuristic>) createFF;
-(id<CPHeuristic>) createWDeg;
-(id<CPHeuristic>) createDDeg;
-(id<CPHeuristic>) createIBS;
-(id<CPHeuristic>) createABS;
-(id<CPHeuristic>) createPortfolio:(NSArray*)hs with:(id<ORVarArray>)vars;
-(void) doOnSolution;
-(void) doOnExit;
-(id<ORCPSolutionPool>) solutionPool;
-(id<ORCPSolution>) captureSolution;

-(ORInt) intValue: (id<ORIntVar>) x;
-(ORBool) bound: (id<ORIntVar>) x;
-(ORInt)  min: (id<ORIntVar>) x;
-(ORInt)  max: (id<ORIntVar>) x;
-(ORInt)  domsize: (id<ORIntVar>) x;
-(ORInt)  member: (ORInt) v in: (id<ORIntVar>) x;


-(ORFloat) floatValue: (id<ORFloatVar>) x;
-(ORBool) boolValue: (id<ORIntVar>) x;

@end

// CPSolver with syntactic DFS Search
@protocol CPProgram <CPCommonProgram>

-(void)                once: (ORClosure) cl;
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
-(void)                once: (ORClosure) cl;
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
@end
