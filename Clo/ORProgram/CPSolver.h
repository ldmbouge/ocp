/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORDataI.h>
#import <ORProgram/CPProgram.h>

/***************************************************************************/
/*                  This file should be private                            */
/***************************************************************************/

@interface CPHeuristicSet : NSObject
-(CPHeuristicSet*) initCPHeuristicSet;
-(void) push: (id<CPHeuristic>) h;
-(id<CPHeuristic>) pop;
-(void) reset;
-(void) applyToAll: (void(^)(id<CPHeuristic> h)) closure;
@end

// This factorizes all the common stuff

@interface CPCoreSolver : ORGamma<CPCommonProgram>
-(CPCoreSolver*) initCPCoreSolver;
-(void) add: (id<ORConstraint>) c;
-(void) setSource:(id<ORModel>)src;
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat;
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;
-(void) perform: (ORClosure) body onLimit: (ORClosure) onRestart;
-(void) portfolio: (ORClosure) s1 then: (ORClosure) s2;
-(void) switchOnDepth: (ORClosure) s1 to: (ORClosure) s2 limit: (ORInt) depth;
-(void) once: (ORClosure) cl;
-(void) limitSolutions: (ORInt) maxSolutions  in: (ORClosure) cl;
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
-(void) onSolution: (ORClosure) onSolution;
-(void) onExit: (ORClosure) onExit;
-(void) addHeuristic: (id<CPHeuristic>) h;
-(void) restartHeuristics;
-(void) doOnSolution;
-(void) doOnExit;
-(id<ORCPSolutionPool>) solutionPool;
-(id<ORCPSolution>) captureSolution;
-(ORInt) maxBound:(id<ORIdArray>) x;

-(void) addConstraintDuringSearch: (id<ORConstraint>) c annotation:(ORAnnotation) n;

// pvh: do we have to put these here. Any way to externalize them.
-(id<CPHeuristic>) createFF: (id<ORVarArray>) rvars;
-(id<CPHeuristic>) createWDeg: (id<ORVarArray>) rvars;
-(id<CPHeuristic>) createDDeg: (id<ORVarArray>) rvars;
-(id<CPHeuristic>) createIBS: (id<ORVarArray>) rvars;
-(id<CPHeuristic>) createABS: (id<ORVarArray>) rvars;
-(id<CPHeuristic>) createFF;
-(id<CPHeuristic>) createWDeg;
-(id<CPHeuristic>) createDDeg;
-(id<CPHeuristic>) createIBS;
-(id<CPHeuristic>) createABS;
@end

// Pure DFS CPSolver
@interface CPSolver : CPCoreSolver<CPProgram>
-(id<CPProgram>) initCPSolver;
@end

// SemanticPath CPSolver
@interface CPSemanticSolver : CPCoreSolver<CPSemanticProgram,CPSemanticProgramDFS>
-(id<CPSemanticProgramDFS>) initCPSemanticSolverDFS;
-(id<CPSemanticProgram>)    initCPSemanticSolver: (Class) ctrlClass;
@end

@interface CPSolverFactory : NSObject
+(id<CPProgram>) solver;
+(id<CPSemanticProgramDFS>) semanticSolverDFS;
+(id<CPSemanticProgram>) semanticSolver: (Class) ctrlClass;
@end


@interface CPInformerPortal : NSObject<CPPortal> {
   CPCoreSolver*  _cp;
}
-(CPInformerPortal*) initCPInformerPortal: (CPCoreSolver*) cp;
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end
