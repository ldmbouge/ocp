/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/CPProgram.h>

/***************************************************************************/
/*                  This file should be private                            */
/***************************************************************************/

@interface CPHeuristicSet : NSObject
-(CPHeuristicSet*) initCPHeuristicSet;
-(void) push: (id<CPHeuristic>) h;
-(id<CPHeuristic>) pop;
-(void) reset;
-(void) applyToAll: (void(^)(id<CPHeuristic> h,NSMutableArray*)) closure with: (NSMutableArray*) tab;
@end


// This factorizes all the common stuff

@interface CPCoreSolver : NSObject<CPCommonProgram>
-(CPCoreSolver*) initCPCoreSolver;
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat;
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;
-(void) once: (ORClosure) cl;
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
-(void) onSolution: (ORClosure)onSol onExit:(ORClosure)onExit;
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

+(id<CPProgram>) multiStartSolver: (ORInt) k;
@end

// MultiStart DFS CPSolver
@interface CPMultiStartSolver : NSObject<CPProgram>
-(id<CPProgram>) initCPMultiStartSolver: (ORInt) k;
-(id<CPProgram>) at: (ORInt) i;
-(ORInt) nb;
@end

@interface CPUtilities : NSObject
+(ORInt) maxBound: (id<ORIntVarArray>) x;
@end;

@interface CPInformerPortal : NSObject<CPPortal> {
   CPCoreSolver*  _cp;
}
-(CPInformerPortal*) initCPInformerPortal: (CPCoreSolver*) cp;
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end