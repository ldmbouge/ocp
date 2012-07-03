/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPTrail.h"
#import "CPTypes.h"
#import "CPCommand.h"
#import "CPConstraintI.h"
#import "CPI.h"
#import "CPSolverI.h"
#import "CPExplorer.h"
#import "CPExplorerI.h"
#import "CPBasicConstraint.h"
#import "CPSelector.h"
#import "CPArrayI.h"
#import "CPIntVarI.h"
#import "CPParallel.h"
#import "CPConcurrency.h"

@interface CPInformerPortal : NSObject<CPPortal> {
   CoreCPI*       _cp;
   CPSolverI* _solver;
}
-(CPInformerPortal*)initCPInformerPortal:(CoreCPI*)cp;
-(id<CPIdxIntInformer>) retLabel;
-(id<CPIdxIntInformer>) failLabel;
-(id<CPInformer>) propagateFail;
-(id<CPInformer>) propagateDone;
@end

@implementation CoreCPI
-(id) init
{
   self = [super init];
   _trail = [[CPTrail alloc] init];
   _solver = [[CPSolverI alloc] initSolver: _trail];
   _pool = [[NSAutoreleasePool alloc] init];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal:self];
   return self;
}
-(id) initFor:(CPSolverI*)fdm
{
   self = [super init];
   _solver = [fdm retain];
   _trail = [[fdm trail] retain];
   _pool = [[NSAutoreleasePool alloc] init];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal:self];
   return self;
}

-(void) dealloc
{
   NSLog(@"CP dealloc called...\n");    
   [_trail release];
   [_solver release];
   [_search release];
   [_pool release];
   [_portal release];
   [_returnLabel release];
   [_failLabel release];
   [super dealloc]; 
}
-(void)addHeuristic:(id<CPHeuristic>)h
{
   [_search addHeuristic:h];
}

-(id<CPSolver>) solver
{
   return _solver;
}
-(id<CPExplorer>) explorer
{
   return _search;
}
-(id<CPSearchController>) controller
{
    return [_search controller];
}
-(id)virtual:(id)obj
{
   return [_solver virtual:obj];
}

-(NSString*) description
{
   return [NSString stringWithFormat:@"Solver: %d vars\n\t%d choices\n\t%d fail\n\t%d propagations",[_solver nbVars],[_search nbChoices],[_search nbFailures],[_solver nbPropagation]];
}
-(CPUInt) nbPropagation
{
   return [_solver nbPropagation];
}
-(CPUInt) nbVars
{
   return [_solver nbVars];
}

-(CPInt) nbChoices
{
   return [_search nbChoices];
}
-(CPInt) nbFailures
{
   return [_search nbFailures];
}
-(CPTrail*) trail
{
   return _trail;
}
-(void) saveSolution
{
   [_solver saveSolution];
}
-(void) restoreSolution;
{
   [_solver restoreSolution];
}
-(void) try: (CPClosure) left or: (CPClosure) right 
{
   [_search try: left or: right];
}
-(void) tryall: (CPRange) range filteredBy: (CPInt2Bool) filter in: (CPInt2Void) body
{
   [_search tryall: range filteredBy: filter in: body];
}
-(void) tryall: (CPRange) range filteredBy: (CPInt2Bool) filter in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure
{
   [_search tryall: range filteredBy: filter in: body onFailure: onFailure];
}
-(void) forrange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order do: (CPInt2Void) body
{
   [_search forrange: range filteredBy: filter orderedBy: order do: body];
}
-(void) fail
{
    [_search fail];
}
-(void) setController: (id<CPSearchController>) controller
{
   [_search setController: controller];
}
-(void) push: (id<CPSearchController>) controller
{
   [_search push: controller];
}
-(void) nestedMinimize: (CPIntVarI*) x in: (CPClosure) body onSolution: onSolution onExit: onExit
{
   CPIntVarMinimize* cstr = (CPIntVarMinimize*) [CPFactory minimize: x];
   [_search    optimize: body
                   post: ^() {  [self add: cstr];  }
             canImprove: ^CPStatus(void) { return [cstr check]; } 
                 update: ^() { [cstr updatePrimalBound]; }
             onSolution: onSolution
                 onExit: onExit
   ];
   printf("Optimal Solution: %d \n",[cstr primalBound]);
   [cstr release];
}
-(void) nestedMaximize: (CPIntVarI*) x in: (CPClosure) body onSolution: onSolution onExit: onExit
{
   CPIntVarMaximize* cstr = (CPIntVarMaximize*) [CPFactory maximize: x];
   [_search    optimize: body
                   post: ^() {  [self add: cstr];  }
             canImprove: ^CPStatus(void) { return [cstr check]; } 
                 update: ^() { [cstr updatePrimalBound]; }
             onSolution: onSolution
                 onExit: onExit
    ];
   printf("Optimal Solution: %d \n",[cstr primalBound]);
   [cstr release];
}

-(CPSelect*) selectInRange: (CPRange) range filteredBy: (CPInt2Bool) filter orderedBy: (CPInt2Int) order
{
   return [[CPSelect alloc] initCPSelect: self 
                               withRange: range
                              filteredBy: filter
                               orderedBy: order];    
}

-(void) addRel: (id<CPRelation>) c
{
   CPStatus status = [_solver addRel: c];
   if (status == CPFailure)
      [_search fail];
}

-(void) add: (id<CPConstraint>) c
{
    CPStatus status = [_solver add: c];
    if (status == CPFailure)
        [_search fail];
}

-(void) post: (id<CPConstraint>) c
{
    CPStatus status = [_solver post: c];
    if (status == CPFailure)
        [_search fail];
    [CPConcurrency pumpEvents];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   // The idea is that we only encode the solver and an empty _shell_ (no content) of the trail
   // The decoding recreates the pool. 
   [aCoder encodeObject:_solver];
   [aCoder encodeObject:_trail];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super init];
   _solver = [[aDecoder decodeObject] retain];
   _trail  = [[aDecoder decodeObject] retain];
   _pool = [[NSAutoreleasePool alloc] init];
   return self;
}

-(void) close
{
   if ([_solver close] == CPFailure)
      [_search fail];
}
-(id<CPIdxIntInformer>) retLabel
{
   if (_returnLabel==nil) 
      _returnLabel = [CPConcurrency idxIntInformer];   
   return _returnLabel;
}
-(id<CPIdxIntInformer>) failLabel
{
   if (_failLabel==nil) 
      _failLabel = [CPConcurrency idxIntInformer];   
   return _failLabel;   
}
-(id<CPPortal>)portal
{
   return _portal;
}
@end

// ==================================================================================================================
// CPI
// ==================================================================================================================

@implementation CPI
-(CPI*) init
{
   self = [super init];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   _search = [[CPExplorerI alloc] initCPExplorer: _solver withTracer: _tracer];
   return self;
}
-(CPI*) initFor:(CPSolverI*)fdm
{
   self = [super initFor:fdm];
   _search = [[CPExplorerI alloc] initCPExplorer: _solver withTracer: _tracer];
   return self;
}
-(void)dealloc
{
   [_tracer release];
   [super dealloc];
}

-(void) label: (CPIntVarI*) var with: (CPInt) val
{
   CPStatus status = [_solver label: var with: val];  
   if (status == CPFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [CPConcurrency pumpEvents]; 
}
-(void) diff: (CPIntVarI*) var with: (CPInt) val
{
   CPStatus status = [_solver diff: var with: val];  
   if (status == CPFailure)
      [_search fail];
   [CPConcurrency pumpEvents];   
}
-(void) lthen: (id<CPIntVar>) var with: (CPInt) val
{
   CPStatus status = [_solver lthen:var with: val];
   if (status == CPFailure) {
      [_search fail];
   }
   [CPConcurrency pumpEvents];
}
-(void) gthen: (id<CPIntVar>) var with: (CPInt) val
{
   CPStatus status = [_solver gthen:var with:val];
   if (status == CPFailure) {
      [_search fail];
   }
   [CPConcurrency pumpEvents];
}

-(void) restrict: (id<CPIntVar>) var to: (id<CPIntSet>) S
{
    CPStatus status = [_solver restrict: var to: S];  
    if (status == CPFailure)
        [_search fail]; 
    [CPConcurrency pumpEvents];   
}

-(void) once: (CPClosure) cl
{
  [_search once: cl];
}

-(void) limitSolutions: (CPInt) nb in: (CPClosure) cl
{
  [_search limitSolutions: nb in: cl];
}

-(void) limitDiscrepancies: (CPInt) nb in: (CPClosure) cl
{
  [_search limitDiscrepancies: nb in: cl];
}

-(void) search: (CPClosure) body 
{
  [_search search: body];
}


-(void) solve: (CPClosure) body 
{
  [_search solve: body];
}
-(void) solve: (CPClosure) body using: (CPClosure) search    
{
    [_search solve: body using: search];
}

-(void) solveAll: (CPClosure) body 
{
  [_search solveAll: body];
}

-(void) solveAll: (CPClosure) body using: (CPClosure) search    
{
    [_search solveAll: body using: search];
}

-(void) nestedSolve: (CPClosure) body
{
  [_search nestedSolve: body onSolution:nil onExit:nil 
               control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution;
{
  [_search nestedSolve: body onSolution: onSolution onExit:nil 
               control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit
{
   [_search nestedSolve: body onSolution: onSolution onExit: onExit 
                control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (CPClosure) body
{
  [_search nestedSolveAll: body onSolution:nil onExit:nil 
                  control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution;
{
   [_search nestedSolveAll: body onSolution: onSolution onExit:nil 
                   control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit
{
  [_search nestedSolveAll: body onSolution: onSolution onExit: onExit 
                  control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}


-(void) minimize: (id<CPIntVar>) x in: (CPClosure) body 
{
  [_search search: ^() { [self nestedMinimize: x 
                                           in: body 
                                   onSolution: ^() { [_solver saveSolution]; }
                                       onExit: ^() { [_solver restoreSolution]; }
			  ]; }
  ];
}

-(void) minimize: (id<CPIntVar>) x subjectTo: (CPClosure) body using: (CPClosure) search
{
    [_search search: ^() { [self nestedMinimize: x 
                                             in: ^() { body(); [self close]; search(); } 
                                     onSolution: ^() { [_solver saveSolution]; }
                                         onExit: ^() { [_solver restoreSolution]; }
                            ]; }
     ];
}
-(void) maximize: (id<CPIntVar>) x in: (CPClosure) body 
{
  [_search search: ^() { [self nestedMaximize: x 
                                           in: body 
                                   onSolution: ^() { [_solver saveSolution]; }
                                       onExit: ^() { [_solver restoreSolution]; }
			  ]; }
  ];
}

-(void) maximize: (id<CPIntVar>) x subjectTo: (CPClosure) body using: (CPClosure) search
{
    [_search search: ^() { [self nestedMaximize: x 
                                             in: ^() { body(); [self close]; search(); } 
                                     onSolution: ^() { [_solver saveSolution]; }
                                         onExit: ^() { [_solver restoreSolution]; }
                            ]; }
     ];
}

-(void) restart: (CPClosure) body onRestart: (CPClosure) onRestart isDone: (CPVoid2Bool) isDone
{
  [_search restart: body onRestart: onRestart isDone: isDone];
}
-(DFSTracer*)tracer
{
   return _tracer;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   // Nothing special here. Simply delegate back up. (We could remove the method, 
   // but I prefer to keep it to remind me that the encode/decode pair ought to be present
   // and that is it intentional to not encode anything here.
   // The decoder also delegates up and _recreates_ a fresh tracer and a fresh search
   // based on the decoded empty shell of the trail. 
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail];
   _search = [[CPExplorerI alloc] initCPExplorer: _solver withTracer: _tracer];
   return self;
}

@end

@implementation SemCP
-(SemCP*) init
{
   self = [super init];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   _search = [[CPSemExplorerI alloc] initCPSemExplorer: _solver withTracer: _tracer];
   return self;
}
-(SemCP*) initFor:(CPSolverI*)fdm
{
   self = [super initFor:fdm];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   _search = [[CPSemExplorerI alloc] initCPSemExplorer: _solver withTracer: _tracer];
   return self;
}
-(void)dealloc
{
   [_tracer release];
   [super dealloc];
}

-(SemTracer*)tracer
{
   return _tracer;
}

-(CPStatus)installCheckpoint:(Checkpoint*)cp
{
   return [_tracer restoreCheckpoint:cp inSolver:_solver];
}
-(CPStatus)installProblem:(CPProblem*)problem
{
   return [_tracer restoreProblem:problem inSolver:_solver];
}
-(Checkpoint*)captureCheckpoint
{
   return [_tracer captureCheckpoint];
}
-(NSData*)packCheckpoint:(Checkpoint*)cp
{
   return [_search packCheckpoint:cp];
}

-(NSString*) description
{
   return [NSString stringWithFormat:@"Solver: %d vars\n\t%d choices\n\t%d fail\n\t%d propagations",[_solver nbVars],
           [_search nbChoices],[_search nbFailures],[_solver nbPropagation]];
}

-(void) label: (CPIntVarI*) var with: (CPInt) val
{
   CPStatus status = [_solver label: var with: val];  
   if (status == CPFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_tracer addCommand:[[CPEqualc alloc] initCPEqualc:var and:val]];    // add after the fail (so if we fail, we don't bother adding it!]
   [_returnLabel notifyWith:var andInt:val];
   [CPConcurrency pumpEvents]; 
}
-(void) diff: (CPIntVarI*) var with: (CPInt) val
{
   CPStatus status = [_solver diff: var with: val];  
   if (status == CPFailure)
      [_search fail];
   // add after the fail (so if we fail, we don't bother adding it!]
   [_tracer addCommand:[[CPDiffc alloc] initCPDiffc:var and:val]]; 
   [CPConcurrency pumpEvents]; 
}

-(void) search: (CPClosure) body 
{
   [_search search: body];
}

-(void) solve: (CPClosure) body 
{
   [_search solve: body];
}
-(void) solve: (CPClosure) body using: (CPClosure) search    
{
   [_search solve: body using: search];
}

-(void) solveAll: (CPClosure) body 
{
   [_search solveAll: body];
}

-(void) solveAll: (CPClosure) body using: (CPClosure) search    
{
   [_search solveAll: body using: search];
}

-(void)solveParAll:(CPUInt)nbt subjectTo:(CPClosure)body using:(CPVirtualClosure)search
{
   [self search:^() {
      body();
      SemParallel* parSearch = [[SemParallel alloc] initSemParallel:self nbWorkers:nbt];
      [parSearch parallel:search];
      [parSearch release];      
      [_solver close];
   }];
}

-(void) nestedSolve: (CPClosure) body
{
   [_search nestedSolve: body onSolution:nil onExit:nil 
                control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];   
}
-(void) nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution;
{
   [_search nestedSolve: body onSolution: onSolution onExit:nil 
                control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit
{
   [_search nestedSolve: body onSolution: onSolution onExit: onExit 
                control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (CPClosure) body
{
   [_search nestedSolveAll: body onSolution:nil onExit:nil 
                   control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution;
{
   [_search nestedSolveAll: body onSolution: onSolution onExit:nil 
                   control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit
{
   [_search nestedSolveAll: body onSolution: onSolution onExit: onExit 
                   control:[[CPNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit control:(id<CPSearchController>)sc
{
   [_search nestedSolveAll: body onSolution: onSolution onExit: onExit control:sc];   
}

-(void) minimize: (id<CPIntVar>) x in: (CPClosure) body 
{
   [_search search: ^() { [self nestedMinimize: x 
                                            in: body 
                                    onSolution: ^() { [_solver saveSolution]; }
                                        onExit: ^() { [_solver restoreSolution]; }
                           ]; }
    ];
}

-(void) minimize: (id<CPIntVar>) x subjectTo: (CPClosure) body using: (CPClosure) search
{
   [_search search: ^() { [self nestedMinimize: x 
                                            in: ^() { body(); [self close]; search(); } 
                                    onSolution: ^() { [_solver saveSolution]; }
                                        onExit: ^() { [_solver restoreSolution]; }
                           ]; }
    ];
}
-(void) maximize: (id<CPIntVar>) x in: (CPClosure) body 
{
   [_search search: ^() { [self nestedMaximize: x 
                                            in: body 
                                    onSolution: ^() { [_solver saveSolution]; }
                                        onExit: ^() { [_solver restoreSolution]; }
                           ]; }
    ];
}

-(void) maximize: (id<CPIntVar>) x subjectTo: (CPClosure) body using: (CPClosure) search
{
   [_search search: ^() { [self nestedMaximize: x 
                                            in: ^() { body(); [self close]; search(); } 
                                    onSolution: ^() { [_solver saveSolution]; }
                                        onExit: ^() { [_solver restoreSolution]; }
                           ]; }
    ];
}

-(void) restart: (CPClosure) body onRestart: (CPClosure) onRestart isDone: (CPVoid2Bool) isDone
{
   [_search restart: body onRestart: onRestart isDone: isDone];
}


- (void) encodeWithCoder:(NSCoder *)aCoder
{
   // Nothing special here. Simply delegate back up. (We could remove the method, 
   // but I prefer to keep it to remind me that the encode/decode pair ought to be present
   // and that is it intentional to not encode anything here.
   // The decoder also delegates up and _recreates_ a fresh tracer and a fresh search
   // based on the decoded empty shell of the trail. 
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   _search = [[CPSemExplorerI alloc] initCPSemExplorer: _solver withTracer: _tracer];
   return self;
}
@end


@implementation CPInformerPortal
-(CPInformerPortal*)initCPInformerPortal:(CoreCPI*)cp
{
   self = [super init];
   _cp = cp;
   _solver = (CPSolverI*)[cp solver];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<CPIdxIntInformer>) retLabel
{
   return [_cp retLabel];
}
-(id<CPIdxIntInformer>) failLabel
{
   return [_cp failLabel];
}
-(id<CPInformer>) propagateFail
{
   return [_solver propagateFail];
}
-(id<CPInformer>) propagateDone
{
   return [_solver propagateDone];
}
@end

void printnl(id x)
{
    printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);        
}


