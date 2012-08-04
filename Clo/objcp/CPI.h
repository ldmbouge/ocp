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

@interface CoreCPI : NSObject  {
   @protected
   id<CPEngine>          _solver;
   id<ORExplorer>        _search;
   ORTrail*              _trail;
   NSAutoreleasePool*    _pool;  
   id<CPPortal>          _portal;
   @package
   id<ORIdxIntInformer>  _returnLabel;
   id<ORIdxIntInformer>  _failLabel;   
}
-(id)                     init;
-(id)                     initFor:(id<CPEngine>) fdm;
-(void)                   dealloc;
-(NSString*)              description;
-(CPInt)                  nbChoices;
-(CPInt)                  nbFailures;
-(CPUInt)                 nbPropagation;
-(CPUInt)                 nbVars;
-(ORTrail*)               trail;
-(id<ORSearchController>) controller;
-(void) setController: (id<ORSearchController>) controller;
-(void)addHeuristic:(id<CPHeuristic>)h;

-(void)                 add: (id<CPConstraint>) c consistency:(CPConsistency)cons;
-(void)                 add: (id<CPConstraint>) c;
-(void)                post: (id<CPConstraint>) c;
-(void)               close;
-(void)        saveSolution;
-(void)     restoreSolution;
-(void)                push: (id<ORSearchController>) c;
-(void)      nestedMinimize: (id<CPIntVar>) x in: (ORClosure) body onSolution: onSolution onExit: onExit;
-(void)      nestedMaximize: (id<CPIntVar>) x in: (ORClosure) body onSolution: onSolution onExit: onExit;
-(void)              forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f orderedBy: (CPInt2Int) o do: (ORInt2Void) b;
-(void)              forall: (id<ORIntIterator>) S orderedBy: (CPInt2Int) o do: (ORInt2Void) b;
-(void)                 try: (ORClosure) left or: (ORClosure) right;
-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body; 
-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
-(CPSelect*)  selectInRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order;

-(id)               virtual: (id) obj;
-(id<CPEngine>)        solver;
-(id<ORExplorer>)    explorer;
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
-(CPI*)                   initFor:(CPEngineI*)fdm;
-(void)dealloc;

-(void)               label: (id<CPIntVar>) var with: (CPInt) val;
-(void)                diff: (id<CPIntVar>) var with: (CPInt) val;
-(void)               lthen: (id<CPIntVar>) var with: (CPInt) val;
-(void)               gthen: (id<CPIntVar>) var with: (CPInt) val;
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
-(void)      limitSolutions: (CPInt) maxSolutions in: (ORClosure) cl;
-(void)      limitCondition: (CPVoid2Bool) condition in: (ORClosure) cl;
-(void)  limitDiscrepancies: (CPInt) maxDiscrepancies in: (ORClosure) cl;
-(void)       limitFailures: (CPInt) maxFailures in: (ORClosure) cl;
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

-(void)               label: (id) var with: (CPInt) val;
-(void)                diff: (id) var with: (CPInt) val;


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





