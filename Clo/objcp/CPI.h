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
#import <objcp/CPTracer.h>

@interface CPHeuristicStack : NSObject {
   id<CPHeuristic>* _tab;
   CPUInt       _sz;
   CPUInt       _mx;
}
-(CPHeuristicStack*)initCPHeuristicStack;
-(void)push:(id<CPHeuristic>)h;
-(id<CPHeuristic>)pop;
-(void)reset;
-(void)applyToAll:(void(^)(id<CPHeuristic> h,NSMutableArray*))closure with:(NSMutableArray*)tab;
@end

@interface CoreCPI : NSObject  {
   @protected
   id<CPEngine>          _solver;
   id<ORExplorer>        _search;
   ORTrail*              _trail;
   NSAutoreleasePool*    _pool;
   CPHeuristicStack*     _hStack;
   id<CPPortal>          _portal;
   @package
   id<ORIdxIntInformer>  _returnLabel;
   id<ORIdxIntInformer>  _failLabel;   
}
-(id)                     init;
-(id)                     initFor:(id<CPEngine>) fdm;
-(void)                   dealloc;
-(NSString*)              description;
-(ORInt)                  nbChoices;
-(ORInt)                  nbFailures;
-(CPUInt)                 nbPropagation;
-(CPUInt)                 nbVars;
-(ORTrail*)               trail;
-(id<ORSearchController>) controller;
-(void) setController: (id<ORSearchController>) controller;
-(void)               addHeuristic:(id<CPHeuristic>)h;

-(void)                 add: (id<CPConstraint>) c consistency:(CPConsistency)cons;
-(void)                 add: (id<CPConstraint>) c;
-(void)               close;
-(void)        saveSolution;
-(void)     restoreSolution;
-(void)                push: (id<ORSearchController>) c;
-(void)      nestedMinimize: (id<CPIntVar>) x in: (ORClosure) body onSolution: onSolution onExit: onExit;
-(void)      nestedMaximize: (id<CPIntVar>) x in: (ORClosure) body onSolution: onSolution onExit: onExit;
-(void)              forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
-(void)                 try: (ORClosure) left or: (ORClosure) right;
-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body; 
-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
-(CPSelect*)  selectInRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order;

-(id)               virtual: (id) obj;
-(id<CPEngine>)        solver;
-(id<ORExplorer>)    explorer;
-(void)          trackObject:(id)object;
-(ORInt)virtualOffset:(id)obj;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
-(id<CPPortal>)portal;
-(id<ORSolution>) solution;
@end

@interface CPI : CoreCPI<CPSolver> {
   DFSTracer* _tracer;
}
-(CPI*)                   init;
-(CPI*)                   initFor:(CPEngineI*)fdm;
-(void)dealloc;

-(void)               label: (id<CPIntVar>) var with: (ORInt) val;
-(void)                diff: (id<CPIntVar>) var with: (ORInt) val;
-(void)               lthen: (id<CPIntVar>) var with: (ORInt) val;
-(void)               gthen: (id<CPIntVar>) var with: (ORInt) val;
-(void)            restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S;

-(void)              search: (ORClosure) body;
-(void)               solve: (ORClosure) body;
-(void)               solve: (ORClosure) body using:(ORClosure) search;
-(void)            solveAll: (ORClosure) body;
-(void)            solveAll: (ORClosure) body using:(ORClosure) search;
-(void)            minimize: (id<CPIntVar>) x in: (ORClosure) body;
-(void)            maximize: (id<CPIntVar>) x in: (ORClosure) body;
-(void)            minimize: (id<CPIntVar>) x subjectTo: (ORClosure) body using:(ORClosure) search;
-(void)            maximize: (id<CPIntVar>) x subjectTo: (ORClosure) body using:(ORClosure) search;

-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)         nestedSolve: (ORClosure) body;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)      nestedSolveAll: (ORClosure) body;

-(void)                once: (ORClosure) cl;
-(void)      limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
-(void)      limitCondition: (CPVoid2Bool) condition in: (ORClosure) cl;
-(void)  limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
-(void)       limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
-(void)           limitTime: (CPLong) maxTime in: (ORClosure) cl;
-(void)     applyController: (id<ORSearchController>) controller in: (ORClosure) cl;
-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat;
-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone;
-(DFSTracer*)tracer;
@end

/*
@interface SemCP : CoreCPI {
   SemTracer* _tracer;
}
-(SemCP*)                   init;
-(SemCP*)                   initFor:(id<CPEngine>)fdm;
-(void)dealloc;
-(ORStatus)installCheckpoint:(Checkpoint*)cp;
-(Checkpoint*)captureCheckpoint;
-(NSData*)packCheckpoint:(Checkpoint*)cp;
-(ORStatus)installProblem:(CPProblem*)problem;

-(void)               label: (id) var with: (ORInt) val;
-(void)                diff: (id) var with: (ORInt) val;


-(void)              search: (ORClosure) body;
-(void)               solve: (ORClosure) body;
-(void)               solve: (ORClosure) body using:(ORClosure) search;
-(void)            solveAll: (ORClosure) body;
-(void)            solveAll: (ORClosure) body using:(ORClosure) search;

-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)         nestedSolve: (ORClosure) body;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
-(void)      nestedSolveAll: (ORClosure) body;


-(void)            minimize: (id<CPIntVar>) x in: (ORClosure) body;
-(void)            maximize: (id<CPIntVar>) x in: (ORClosure) body;
-(void)            minimize: (id<CPIntVar>) x subjectTo: (ORClosure) body using:(ORClosure) search;
-(void)            maximize: (id<CPIntVar>) x subjectTo: (ORClosure) body using:(ORClosure) search;
-(void)             repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone;
-(void) solveParAll:(CPUInt)nbt subjectTo:(ORClosure)body using:(CPVirtualClosure)body;
-(SemTracer*)tracer;
@end
*/





