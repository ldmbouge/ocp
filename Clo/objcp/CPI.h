/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CP.h"
#import "CPTypes.h"
#import "CPConstraintI.h"
#import "CPExplorerI.h"
#import "CPSelector.h"
#import "ORUtilities/ORUtilities.h"


@interface CoreCPI : NSObject  {
   @protected
   id<CPSolver>          _solver;
   id<CPExplorer>        _search;
   ORTrail*              _trail;
   NSAutoreleasePool*    _pool;  
   id<CPPortal>          _portal;
   @package
   id<ORIdxIntInformer>  _returnLabel;
   id<ORIdxIntInformer>  _failLabel;   
}
-(id)                     init;
-(id)                     initFor:(id<CPSolver>) fdm;
-(void)                   dealloc;
-(NSString*)              description;
-(CPInt)                  nbChoices;
-(CPInt)                  nbFailures;
-(CPUInt)                 nbPropagation;
-(CPUInt)                 nbVars;
-(ORTrail*)               trail;
-(id<CPSearchController>) controller;
-(void) setController: (id<CPSearchController>) controller;
-(void)addHeuristic:(id<CPHeuristic>)h;

// immediate RHS
-(void)                 add: (id<CPExpr>)lhs leqi: (CPInt)rhs;
-(void)                 add: (id<CPExpr>)lhs leqi: (CPInt)rhs consistency:(CPConsistency)cons;
-(void)                 add: (id<CPExpr>)lhs eqi: (CPInt)rhs;
-(void)                 add: (id<CPExpr>)lhs eqi: (CPInt)rhs consistency:(CPConsistency)cons;
// expression RHS
-(void)                 add: (id<CPExpr>)lhs leq: (id<CPExpr>)rhs;
-(void)                 add: (id<CPExpr>)lhs leq: (id<CPExpr>)rhs consistency:(CPConsistency)cons;
-(void)                 add: (id<CPExpr>)lhs equal: (id<CPExpr>)rhs;
-(void)                 add: (id<CPExpr>)lhs equal: (id<CPExpr>)rhs consistency:(CPConsistency)cons;
-(void)                 add: (id<CPConstraint>) c consistency:(CPConsistency)cons;
-(void)                 add: (id<CPConstraint>) c;
-(void)                post: (id<CPConstraint>) c;
-(void)               close;
-(void)        saveSolution;
-(void)     restoreSolution;
-(void)                push: (id<CPSearchController>) c;
-(void)      nestedMinimize: (id<CPIntVar>) x in: (CPClosure) body onSolution: onSolution onExit: onExit;
-(void)      nestedMaximize: (id<CPIntVar>) x in: (CPClosure) body onSolution: onSolution onExit: onExit;
-(void)            forrange: (CPRange) range suchThat: (CPInt2Bool) f orderedBy: (CPInt2Int) o do: (CPInt2Void) b;
-(void)            forrange: (CPRange) range orderedBy: (CPInt2Int) o do: (CPInt2Void) b;
-(void)                 try: (CPClosure) left or: (CPClosure) right;
-(void)              tryall: (CPRange) range suchThat: (CPInt2Bool) f in: (CPInt2Void) body; 
-(void)              tryall: (CPRange) range suchThat: (CPInt2Bool) f in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure;
-(CPSelect*)  selectInRange: (CPRange) range suchThat: (CPInt2Bool) filter orderedBy: (CPInt2Int) order;

-(id)               virtual: (id) obj;
-(id<CPSolver>)        solver;
-(id<CPExplorer>)    explorer;
-(void)trackObject:(id)object;
-(CPInt)virtualOffset:(id)obj;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
-(id<CPPortal>)portal;
-(id<CPSolution>) solution;
@end

@interface CPI : CoreCPI<CP> {
   DFSTracer* _tracer;
}
-(CPI*)                   init;
-(CPI*)                   initFor:(CPSolverI*)fdm;
-(void)dealloc;

-(void)               label: (id<CPIntVar>) var with: (CPInt) val;
-(void)                diff: (id<CPIntVar>) var with: (CPInt) val;
-(void)               lthen: (id<CPIntVar>) var with: (CPInt) val;
-(void)               gthen: (id<CPIntVar>) var with: (CPInt) val;
-(void)            restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;

-(void)              search: (CPClosure) body;
-(void)               solve: (CPClosure) body;
-(void)               solve: (CPClosure) body using:(CPClosure) search;
-(void)            solveAll: (CPClosure) body;
-(void)            solveAll: (CPClosure) body using:(CPClosure) search;
-(void)            minimize: (id<CPIntVar>) x in: (CPClosure) body;
-(void)            maximize: (id<CPIntVar>) x in: (CPClosure) body;
-(void)            minimize: (id<CPIntVar>) x subjectTo: (CPClosure) body using:(CPClosure) search;
-(void)            maximize: (id<CPIntVar>) x subjectTo: (CPClosure) body using:(CPClosure) search;

-(void)         nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit;
-(void)         nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution;
-(void)         nestedSolve: (CPClosure) body;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution;
-(void)      nestedSolveAll: (CPClosure) body;

-(void)                once: (CPClosure) cl;
-(void)      limitSolutions: (CPInt) maxSolutions in: (CPClosure) cl;
-(void)      limitCondition: (CPVoid2Bool) condition in: (CPClosure) cl;
-(void)  limitDiscrepancies: (CPInt) maxDiscrepancies in: (CPClosure) cl;
-(void)       limitFailures: (CPInt) maxFailures in: (CPClosure) cl;
-(void)           limitTime: (CPLong) maxTime in: (CPClosure) cl;
-(void)     applyController: (id<CPSearchController>) controller in: (CPClosure) cl;
-(void)              repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat;
-(void)              repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone;
-(DFSTracer*)tracer;
@end

@interface SemCP : CoreCPI {
   SemTracer* _tracer;
}
-(SemCP*)                   init;
-(SemCP*)                   initFor:(id<CPSolver>)fdm;
-(void)dealloc;
-(CPStatus)installCheckpoint:(Checkpoint*)cp;
-(Checkpoint*)captureCheckpoint;
-(NSData*)packCheckpoint:(Checkpoint*)cp;
-(CPStatus)installProblem:(CPProblem*)problem;

-(void)               label: (id) var with: (CPInt) val;
-(void)                diff: (id) var with: (CPInt) val;


-(void)              search: (CPClosure) body;
-(void)               solve: (CPClosure) body;
-(void)               solve: (CPClosure) body using:(CPClosure) search;
-(void)            solveAll: (CPClosure) body;
-(void)            solveAll: (CPClosure) body using:(CPClosure) search;

-(void)         nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit;
-(void)         nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution;
-(void)         nestedSolve: (CPClosure) body;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit control:(id<CPSearchController>)sc;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution;
-(void)      nestedSolveAll: (CPClosure) body;


-(void)            minimize: (id<CPIntVar>) x in: (CPClosure) body;
-(void)            maximize: (id<CPIntVar>) x in: (CPClosure) body;
-(void)            minimize: (id<CPIntVar>) x subjectTo: (CPClosure) body using:(CPClosure) search;
-(void)            maximize: (id<CPIntVar>) x subjectTo: (CPClosure) body using:(CPClosure) search;
-(void)             repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone;
-(void) solveParAll:(CPUInt)nbt subjectTo:(CPClosure)body using:(CPVirtualClosure)body;
-(SemTracer*)tracer;
@end

void printnl(id object);



