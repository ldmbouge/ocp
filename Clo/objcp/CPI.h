/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CP.h"
#import "CPTypes.h"
#import "CPConstraintI.h"
#import "CPExplorerI.h"
#import "CPSelector.h"
#import "CPConcurrency.h"


@interface CoreCPI : NSObject  {
   @protected
   id<CPSolver>          _solver;
   id<CPExplorer>        _search;
   CPTrail*              _trail;
   NSAutoreleasePool*    _pool;  
   id<CPIdxIntInformer>  _retLabel;
   id<CPIdxIntInformer>  _failLabel;   
}
-(id)                     init;
-(id)                     initFor:(id<CPSolver>) fdm;
-(void)                   dealloc;
-(NSString*)              description;
-(CPInt)                  nbChoices;
-(CPInt)                  nbFailures;
-(CPUInt)                 nbPropagation;
-(CPUInt)                 nbVars;
-(CPTrail*)               trail;
-(id<CPSearchController>) controller;
-(void) setController: (id<CPSearchController>) controller;
-(void)addHeuristic:(id<CPHeuristic>)h;
   
-(void)              addRel: (id<CPRelation>) c;
-(void)                 add: (id<CPConstraint>) c;
-(void)                post: (id<CPConstraint>) c;
-(void)               close;
-(void)        saveSolution;
-(void)     restoreSolution;
-(void)                push: (id<CPSearchController>) c;
-(void)      nestedMinimize: (id<CPIntVar>) x in: (CPClosure) body onSolution: onSolution onExit: onExit;
-(void)      nestedMaximize: (id<CPIntVar>) x in: (CPClosure) body onSolution: onSolution onExit: onExit;
-(void)            forrange: (CPRange) range filteredBy: (CPInt2Bool) f orderedBy: (CPInt2Int) o do: (CPInt2Void) b;
-(void)                 try: (CPClosure) left or: (CPClosure) right;
-(void)              tryall: (CPRange) range filteredBy: (CPInt2Bool) f in: (CPInt2Void) body; 
-(void)              tryall: (CPRange) range filteredBy: (CPInt2Bool) f in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure;
-(CPSelect*)  selectInRange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order;

-(id)               virtual: (id) obj;
-(id<CPSolver>)        solver;
-(id<CPExplorer>)    explorer;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
-(id<CPIdxIntInformer>) retLabel;
-(id<CPIdxIntInformer>) failLabel;
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
-(void)            restrict: (id<CPIntVar>) var to: (id<CPIntSet>) S;

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
-(void)  limitDiscrepancies: (CPInt) maxDiscrepancies in: (CPClosure) cl;
-(void)             restart: (CPClosure) body onRestart: (CPClosure) onRestart isDone: (CPVoid2Bool) isDone;
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
-(void)             restart: (CPClosure) body onRestart: (CPClosure) onRestart isDone: (CPVoid2Bool) isDone;
-(void) solveParAll:(CPUInt)nbt subjectTo:(CPClosure)body using:(CPVirtualClosure)body;
-(SemTracer*)tracer;
@end

void printnl(id object);



