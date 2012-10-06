/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

//#import <ORFoundation/ORFoundation.h>
//#import "CPSolver.h"
//#import "CPTypes.h"
//#import "CPConstraintI.h"
//
//@interface CPHeuristicStack : NSObject {
//   id<CPHeuristic>* _tab;
//   ORUInt       _sz;
//   ORUInt       _mx;
//}
//-(CPHeuristicStack*)initCPHeuristicStack;
//-(void)push:(id<CPHeuristic>)h;
//-(id<CPHeuristic>)pop;
//-(void)reset;
//-(void)applyToAll:(void(^)(id<CPHeuristic> h,NSMutableArray*))closure with:(NSMutableArray*)tab;
//@end
//
//
//@interface CPCoreProgramI : NSObject<CPSolver>
//{
//@protected
//   id<CPEngine>          _engine;
//   id<ORExplorer>        _search;
//   id<ORObjective>       _objective;
//   id<ORTrail>           _trail;
//   NSAutoreleasePool*    _pool;
//   CPHeuristicStack*     _hStack;
//   id<CPPortal>          _portal;
//   @package
//   id<ORIdxIntInformer>  _returnLabel;
//   id<ORIdxIntInformer>  _failLabel;
//   BOOL                  _closed;
//}
//-(CPCoreSolverI*)         init;
//-(CPCoreSolverI*)         initFor: (CPEngineI*) fdm;
//-(void)                   dealloc;
//
//-(NSString*)              description;
//-(ORInt)                  nbChoices;
//-(ORInt)                  nbFailures;
//-(ORUInt)                 nbPropagation;
//-(ORUInt)                 nbVars;
//-(id<ORTrail>)               trail;
//
//-(id<ORSearchController>) controller;
//-(void)                   setController: (id<ORSearchController>) controller;
//-(void)                   push: (id<ORSearchController>) c;
//
//-(id<CPSolver>)           solver;
//-(id<CPEngine>)           engine;
//-(id<ORExplorer>)         explorer;
//-(id<ORTracer>)           tracer;
//-(id<CPPortal>)           portal;
//-(id<ORSolution>)         solution;
//
//-(void)                  add: (id<ORConstraint>) c consistency:(CPConsistency)cons;
//-(void)                  add: (id<ORConstraint>) c;
//-(id<ORObjective>)  minimize: (id<ORIntVar>) x;
//-(id<ORObjective>)  maximize: (id<ORIntVar>) x;
//-(void)         addHeuristic: (id<CPHeuristic>) h;
//
//-(void)                close;
//-(BOOL)               closed;
//-(void)         saveSolution;
//-(void)      restoreSolution;
//
//-(void)                solve: (ORClosure) body;
//-(void)             solveAll: (ORClosure) body;
//-(void)                state;
//-(id<ORObjective>) objective;
//
//-(void)               label: (id<ORIntVar>) var with: (ORInt) val;
//-(void)                diff: (id<ORIntVar>) var with: (ORInt) val;
//-(void)               lthen: (id<ORIntVar>) var with: (ORInt) val;
//-(void)               gthen: (id<ORIntVar>) var with: (ORInt) val;
//-(void)            restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S;
//
//-(void)              forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
//-(void)              forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) o do: (ORInt2Void) b;
//-(void)                 try: (ORClosure) left or: (ORClosure) right;
//-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body;
//-(void)              tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) f in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure;
//
//-(void)                once: (ORClosure) cl;
//-(void)      limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl;
//-(void)      limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl;
//-(void)  limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl;
//-(void)       limitFailures: (ORInt) maxFailures in: (ORClosure) cl;
//-(void)           limitTime: (ORLong) maxTime in: (ORClosure) cl;
//-(void)     applyController: (id<ORSearchController>) cOORSemontroller in: (ORClosure) cl;
//-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat;
//-(void)              repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone;
//
//-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
//-(void)         nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
//-(void)         nestedSolve: (ORClosure) body;
//-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit;
//-(void)      nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
//-(void)      nestedSolveAll: (ORClosure) body;
//
//-(void)         trackObject: (id)object;
//-(void)         trackVariable: (id) object;
//- (void)    encodeWithCoder: (NSCoder *)aCoder;
//- (id)        initWithCoder: (NSCoder *)aDecoder;
//
//-(void)           addModel: (id) model;
//@end
//
//@interface CPSolverI : CPCoreSolverI<CPSolver,ORTracker> {
//   DFSTracer*            _tracer;
//}
//-(CPSolverI*)             init;
//-(CPCoreSolverI*)         initFor: (CPEngineI*) fdm;
//-(id<ORTracer>)           tracer;
//-(void)                   dealloc;
//@end
//
//@interface CPSemSolverI : CPCoreSolverI<CPSemSolver> {
//   SemTracer*          _tracer;
//}
//-(CPSemSolverI*)          initWithController:(Class)ctrlClass;
//-(CPCoreSolverI*)         initFor: (CPEngineI*) fdm withController:(Class)ctrlClass;
//-(id<ORTracer>)           tracer;
//-(void)                   dealloc;
//@end
//
//
