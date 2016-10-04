/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORDataI.h>
#import <ORProgram/CPProgram.h>
#import <ORModeling/ORModeling.h>

/***************************************************************************/
/*                  This file should be private                            */
/***************************************************************************/

@interface ORCPTakeSnapshot  : ORNOopVisit<NSObject>
{
   id<CPCommonProgram> _solver;
   id                  _snapshot;
}
-(ORCPTakeSnapshot*) initORCPTakeSnapshot: (id<CPCommonProgram>) solver;
-(void) dealloc;
@end

@class ORRTModel;
@class CPCoreSolver;

@interface CPINCModel : NSObject<ORPost,ORAddToModel> {
   id<CPEngine>  _engine;
}
-(id)init:(id<CPCommonProgram>)theSolver;
-(ORStatus)post:(id<ORConstraint>)c;
-(void)setCurrent:(id<ORConstraint>)cstr;
@end

@interface CPHeuristicSet : NSObject
-(CPHeuristicSet*) initCPHeuristicSet;
-(void) push: (id<CPHeuristic>) h;
-(id<CPHeuristic>) pop;
-(id<CPHeuristic>) top;
-(void) reset;
-(void) applyToAll: (void(^)(id<CPHeuristic> h)) closure;
-(BOOL)empty;
@end

// This factorizes all the common stuff

@interface CPCoreSolver : ORGamma<CPCommonProgram>
-(CPCoreSolver*) initCPCoreSolver;
-(void) add: (id<ORConstraint>) c;
-(void) setSource:(id<ORModel>)src;
-(id<ORModel>)source;
-(ORBool) ground;
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat;
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;
-(void) perform: (ORClosure) body onLimit: (ORClosure) onRestart;
-(void) portfolio: (ORClosure) s1 then: (ORClosure) s2;
-(void) switchOnDepth: (ORClosure) s1 to: (ORClosure) s2 limit: (ORInt) depth;
-(void) once: (ORClosure) cl;
-(void) try: (ORClosure) left then: (ORClosure) right;
-(void) limitSolutions: (ORInt) maxSolutions  in: (ORClosure) cl;
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
-(void) onStartup:(ORClosure) onStartup;
-(void) onSolution: (ORClosure) onSolution;
-(void) onExit: (ORClosure) onExit;
-(void) clearOnSolution;
-(void) clearOnExit;
-(void) addHeuristic: (id<CPHeuristic>) h;
-(void) restartHeuristics;
-(void) doOnStartup;
-(void) doOnSolution;
-(void) doOnExit;
-(id<ORSolutionPool>) solutionPool;
-(id<ORSolution>) captureSolution;
-(ORInt) maxBound:(id<ORIdArray>) x;
-(ORBool) allBound:(id<ORIdArray>) x;
-(id<ORIntVar>)smallestDom:(id<ORIdArray>)x;
-(void) addConstraintDuringSearch: (id<ORConstraint>) c;
-(void) defaultSearch;
-(id<ORMemoryTrail>)memoryTrail;
-(void)tracer:(id<ORTracer>)tracer;
@end

// Pure DFS CPSolver
@interface CPSolver : CPCoreSolver<CPProgram>
-(id<CPProgram>) initCPSolver;
-(id<CPProgram>) initCPSolverWithEngine: (id<CPEngine>) engine;
@end

// SemanticPath CPSolver
@interface CPSemanticSolver : CPCoreSolver<CPSemanticProgram,CPSemanticProgramDFS>
-(id<CPSemanticProgramDFS>) initCPSemanticSolverDFS;
-(id<CPSemanticProgram>)    initCPSemanticSolver: (id<ORSearchController>) ctrlProto;
@end

@interface CPSolverFactory : NSObject
+(id<CPProgram>) solver;
+(id<CPSemanticProgramDFS>) semanticSolverDFS;
+(id<CPSemanticProgram>) semanticSolver: (id<ORSearchController>) ctrlProto;
@end


@interface CPInformerPortal : NSObject<CPPortal> {
   CPCoreSolver*  _cp;
}
-(CPInformerPortal*) initCPInformerPortal: (CPCoreSolver*) cp;
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) retLT;
-(id<ORIdxIntInformer>) retGT;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORIdxIntInformer>) failLT;
-(id<ORIdxIntInformer>) failGT;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end
