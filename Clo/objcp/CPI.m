/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "ORTrail.h"
#import "CPTypes.h"
#import "CPCommand.h"
#import "CPConstraintI.h"
#import "CPI.h"
#import "CPEngineI.h"
#import "ORExplorer.h"
#import "CPExplorerI.h"
#import "CPBasicConstraint.h"
#import "CPSelector.h"
#import "CPArrayI.h"
#import "CPIntVarI.h"
#import "ORUtilities/ORUtilities.h"
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORExplorerI.h>

@interface CPInformerPortal : NSObject<CPPortal> {
   CoreCPI*       _cp;
   CPEngineI* _solver;
}
-(CPInformerPortal*)initCPInformerPortal:(CoreCPI*)cp;
-(id<ORIdxIntInformer>) retLabel;
-(id<ORIdxIntInformer>) failLabel;
-(id<ORInformer>) propagateFail;
-(id<ORInformer>) propagateDone;
@end

@implementation CoreCPI
-(id) init
{
   self = [super init];
   _trail = [[ORTrail alloc] init];
   _solver = [[CPEngineI alloc] initSolver: _trail];
   _pool = [[NSAutoreleasePool alloc] init];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal:self];
   return self;
}
-(id) initFor:(CPEngineI*)fdm
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
//   [_pool release];
   [_portal release];
   [_returnLabel release];
   [_failLabel release];
   [super dealloc]; 
}
-(void)addHeuristic:(id<CPHeuristic>)h
{
 //  [_search addHeuristic:h];
}

-(id<CPEngine>) solver
{
   return _solver;
}
-(id<ORExplorer>) explorer
{
   return _search;
}
-(id<ORSearchController>) controller
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

-(ORInt) nbChoices
{
   return [_search nbChoices];
}
-(ORInt) nbFailures
{
   return [_search nbFailures];
}
-(ORTrail*) trail
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
-(id<CPSolution>) solution
{
   return [_solver solution];
}
-(void) try: (ORClosure) left or: (ORClosure) right 
{
   [_search try: left or: right];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   [_search tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [_search tryall: range suchThat: filter in: body onFailure: onFailure];
}
-(void) forall: (id<ORIntIterator>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: filter orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterator>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: nil orderedBy: order do: body];
}

-(void) fail
{
    [_search fail];
}
-(void) setController: (id<ORSearchController>) controller
{
   [_search setController: controller];
}
-(void) push: (id<ORSearchController>) controller
{
   [_search push: controller];
}
-(void) nestedMinimize: (CPIntVarI*) x in: (ORClosure) body onSolution: onSolution onExit: onExit
{
   CPIntVarMinimize* cstr = (CPIntVarMinimize*) [CPFactory minimize: x];
   [_search    optimize: body
                   post: ^() {  [self add: cstr];  }
             canImprove: ^ORStatus(void) { return [cstr check]; } 
                 update: ^() { [cstr updatePrimalBound]; }
             onSolution: onSolution
                 onExit: onExit
   ];
   printf("Optimal Solution: %d \n",[cstr primalBound]);
   //[cstr release]; // [ldm] Why Release? [this is tracked anyhow!]
}
-(void) nestedMaximize: (CPIntVarI*) x in: (ORClosure) body onSolution: onSolution onExit: onExit
{
   CPIntVarMaximize* cstr = (CPIntVarMaximize*) [CPFactory maximize: x];
   [_search    optimize: body
                   post: ^() {  [self add: cstr];  }
             canImprove: ^ORStatus(void) { return [cstr check]; } 
                 update: ^() { [cstr updatePrimalBound]; }
             onSolution: onSolution
                 onExit: onExit
    ];
   printf("Optimal Solution: %d \n",[cstr primalBound]);
   //[cstr release]; // [ldm] Why release? [this is tracked anyhow!]
}

-(CPSelect*) selectInRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order
{
   return [[CPSelect alloc] initCPSelect: (id<CPSolver>)self
                               withRange: range
                              suchThat: filter
                               orderedBy: order];    
}

-(void) add: (id<CPConstraint>) c
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)]) {
      c = [_solver wrapExpr:(id<CPRelation>)c consistency:ValueConsistency];
   }
   ORStatus status = [_solver add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) add: (id<CPConstraint>) c consistency:(CPConsistency)cons
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)]) {
      c = [_solver wrapExpr:(id<CPRelation>)c consistency:cons];
   }
   ORStatus status = [_solver add: c];
   if (status == ORFailure)
      [_search fail];
}

-(void) post: (id<CPConstraint>) c
{
    ORStatus status = [_solver post: c];
    if (status == ORFailure)
        [_search fail];
    [ORConcurrency pumpEvents];
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
   if ([_solver close] == ORFailure)
      [_search fail];
}
-(id<ORIdxIntInformer>) retLabel
{
   if (_returnLabel==nil) 
      _returnLabel = [ORConcurrency idxIntInformer];   
   return _returnLabel;
}
-(id<ORIdxIntInformer>) failLabel
{
   if (_failLabel==nil) 
      _failLabel = [ORConcurrency idxIntInformer];   
   return _failLabel;   
}
-(id<CPPortal>)portal
{
   return _portal;
}
-(void)trackObject:(id)object
{
   [_solver trackObject:object];
}
-(ORInt)virtualOffset:(id)obj
{
   return [_solver virtualOffset:obj];
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
   _search = [[ORExplorerI alloc] initORExplorer: _solver withTracer: _tracer];
   return self;
}
-(CPI*) initFor:(CPEngineI*)fdm
{
   self = [super initFor:fdm];
   _search = [[ORExplorerI alloc] initORExplorer: _solver withTracer: _tracer];
   return self;
}
-(void)dealloc
{
   [_tracer release];
   [super dealloc];
}

-(void) label: (CPIntVarI*) var with: (ORInt) val
{
   ORStatus status = [_solver label: var with: val];  
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents]; 
}
-(void) diff: (CPIntVarI*) var with: (ORInt) val
{
   ORStatus status = [_solver diff: var with: val];  
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];   
}
-(void) lthen: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_solver lthen:var with: val];
   if (status == ORFailure) {
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) gthen: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_solver gthen:var with:val];
   if (status == ORFailure) {
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}

-(void) restrict: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
    ORStatus status = [_solver restrict: var to: S];  
    if (status == ORFailure)
        [_search fail]; 
    [ORConcurrency pumpEvents];   
}

-(void) once: (ORClosure) cl
{
  [_search once: cl];
}

-(void) limitCondition: (CPVoid2Bool) condition in: (ORClosure) cl
{
   [_search limitCondition: condition in:cl];
}
-(void) limitSolutions: (ORInt) nb in: (ORClosure) cl
{
  [_search limitSolutions: nb in: cl];
}

-(void) limitDiscrepancies: (ORInt) nb in: (ORClosure) cl
{
  [_search limitDiscrepancies: nb in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
  [_search limitFailures: maxFailures in: cl];
}
-(void) limitTime: (CPLong) maxTime in: (ORClosure) cl
{
  [_search limitTime: maxTime in: cl];
}
-(void) applyController: (id<ORSearchController>) controller in: (ORClosure) cl
{
   [_search applyController: controller in: cl];
}
-(void) search: (ORClosure) body 
{
  [_search search: body];
}


-(void) solve: (ORClosure) body 
{
  [_search solve: body];
}
-(void) solve: (ORClosure) body using: (ORClosure) search    
{
    [_search solve: body using: search];
}

-(void) solveAll: (ORClosure) body 
{
  [_search solveAll: body];
}

-(void) solveAll: (ORClosure) body using: (ORClosure) search    
{
    [_search solveAll: body using: search];
}

-(void) nestedSolve: (ORClosure) body
{
  [_search nestedSolve: body onSolution:nil onExit:nil 
               control:[[ORNestedController alloc] initORNestedController:[_search controller]]];
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
{
  [_search nestedSolve: body onSolution: onSolution onExit:nil 
               control:[[ORNestedController alloc] initORNestedController:[_search controller]]];
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolve: body onSolution: onSolution onExit: onExit 
                control:[[ORNestedController alloc] initORNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body
{
  [_search nestedSolveAll: body onSolution:nil onExit:nil 
                  control:[[ORNestedController alloc] initORNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
{
   [_search nestedSolveAll: body onSolution: onSolution onExit:nil 
                   control:[[ORNestedController alloc] initORNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
  [_search nestedSolveAll: body onSolution: onSolution onExit: onExit 
                  control:[[ORNestedController alloc] initORNestedController:[_search controller]]];
}


-(void) minimize: (id<CPIntVar>) x in: (ORClosure) body 
{
  [_search search: ^() { [self nestedMinimize: x 
                                           in: body 
                                   onSolution: ^() { [_solver saveSolution]; }
                                       onExit: ^() { [_solver restoreSolution]; }
			  ]; }
  ];
}

-(void) minimize: (id<CPIntVar>) x subjectTo: (ORClosure) body using: (ORClosure) search
{
    [_search search: ^() { [self nestedMinimize: x 
                                             in: ^() { body(); [self close]; search(); } 
                                     onSolution: ^() { [_solver saveSolution]; }
                                         onExit: ^() { [_solver restoreSolution]; }
                            ]; }
     ];
}
-(void) maximize: (id<CPIntVar>) x in: (ORClosure) body 
{
  [_search search: ^() { [self nestedMaximize: x 
                                           in: body 
                                   onSolution: ^() { [_solver saveSolution]; }
                                       onExit: ^() { [_solver restoreSolution]; }
			  ]; }
  ];
}

-(void) maximize: (id<CPIntVar>) x subjectTo: (ORClosure) body using: (ORClosure) search
{
    [_search search: ^() { [self nestedMaximize: x 
                                             in: ^() { body(); [self close]; search(); } 
                                     onSolution: ^() { [_solver saveSolution]; }
                                         onExit: ^() { [_solver restoreSolution]; }
                            ]; }
     ];
}


-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
  [_search repeat: body onRepeat: onRepeat until: nil];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone
{
  [_search repeat: body onRepeat: onRepeat until: isDone];
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
   _search = [[ORExplorerI alloc] initORExplorer: _solver withTracer: _tracer];
   return self;
}

@end

/*
@implementation SemCP
-(SemCP*) init
{
   self = [super init];
   _tracer = [[SemTracer alloc] initSemTracer: _trail];
   _search = [[CPSemExplorerI alloc] initCPSemExplorer: _solver withTracer: _tracer];
   return self;
}
-(SemCP*) initFor:(CPEngineI*)fdm
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

-(ORStatus)installCheckpoint:(Checkpoint*)cp
{
   return [_tracer restoreCheckpoint:cp inSolver:_solver];
}
-(ORStatus)installProblem:(CPProblem*)problem
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

-(void) label: (CPIntVarI*) var with: (ORInt) val
{
   ORStatus status = [_solver label: var with: val];  
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_tracer addCommand:[[CPEqualc alloc] initCPEqualc:var and:val]];    // add after the fail (so if we fail, we don't bother adding it!]
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents]; 
}
-(void) diff: (CPIntVarI*) var with: (ORInt) val
{
   ORStatus status = [_solver diff: var with: val];  
   if (status == ORFailure)
      [_search fail];
   // add after the fail (so if we fail, we don't bother adding it!]
   [_tracer addCommand:[[CPDiffc alloc] initCPDiffc:var and:val]]; 
   [ORConcurrency pumpEvents]; 
}

-(void) search: (ORClosure) body 
{
   [_search search: body];
}

-(void) solve: (ORClosure) body 
{
   [_search solve: body];
}
-(void) solve: (ORClosure) body using: (ORClosure) search    
{
   [_search solve: body using: search];
}

-(void) solveAll: (ORClosure) body 
{
   [_search solveAll: body];
}

-(void) solveAll: (ORClosure) body using: (ORClosure) search    
{
   [_search solveAll: body using: search];
}

-(void)solveParAll:(CPUInt)nbt subjectTo:(ORClosure)body using:(CPVirtualClosure)search
{
   [self search:^() {
      body();
      SemParallel* parSearch = [[SemParallel alloc] initSemParallel:self nbWorkers:nbt];
      [parSearch parallel:search];
      [parSearch release];      
      [_solver close];
   }];
}

-(void) nestedSolve: (ORClosure) body
{
   [_search nestedSolve: body onSolution:nil onExit:nil 
                control:[[ORNestedController alloc] initCPNestedController:[_search controller]]];   
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution;
{
   [_search nestedSolve: body onSolution: onSolution onExit:nil 
                control:[[ORNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolve: body onSolution: onSolution onExit: onExit 
                control:[[ORNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body
{
   [_search nestedSolveAll: body onSolution:nil onExit:nil 
                   control:[[ORNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution;
{
   [_search nestedSolveAll: body onSolution: onSolution onExit:nil 
                   control:[[ORNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolveAll: body onSolution: onSolution onExit: onExit 
                   control:[[ORNestedController alloc] initCPNestedController:[_search controller]]];
}

-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc
{
   [_search nestedSolveAll: body onSolution: onSolution onExit: onExit control:sc];   
}

-(void) minimize: (id<CPIntVar>) x in: (ORClosure) body 
{
   [_search search: ^() { [self nestedMinimize: x 
                                            in: body 
                                    onSolution: ^() { [_solver saveSolution]; }
                                        onExit: ^() { [_solver restoreSolution]; }
                           ]; }
    ];
}

-(void) minimize: (id<CPIntVar>) x subjectTo: (ORClosure) body using: (ORClosure) search
{
   [_search search: ^() { [self nestedMinimize: x 
                                            in: ^() { body(); [self close]; search(); } 
                                    onSolution: ^() { [_solver saveSolution]; }
                                        onExit: ^() { [_solver restoreSolution]; }
                           ]; }
    ];
}
-(void) maximize: (id<CPIntVar>) x in: (ORClosure) body 
{
   [_search search: ^() { [self nestedMaximize: x 
                                            in: body 
                                    onSolution: ^() { [_solver saveSolution]; }
                                        onExit: ^() { [_solver restoreSolution]; }
                           ]; }
    ];
}

-(void) maximize: (id<CPIntVar>) x subjectTo: (ORClosure) body using: (ORClosure) search
{
   [_search search: ^() { [self nestedMaximize: x 
                                            in: ^() { body(); [self close]; search(); } 
                                    onSolution: ^() { [_solver saveSolution]; }
                                        onExit: ^() { [_solver restoreSolution]; }
                           ]; }
    ];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
   [_search repeat: body onRepeat: onRepeat until: nil];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (CPVoid2Bool) isDone
{
   [_search repeat: body onRepeat: onRepeat until: isDone];
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



void printnl(id x)
{
    printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);        
}
*/

@implementation CPInformerPortal
-(CPInformerPortal*)initCPInformerPortal:(CoreCPI*)cp
{
   self = [super init];
   _cp = cp;
   _solver = (CPEngineI*)[cp solver];
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<ORIdxIntInformer>) retLabel
{
   return [_cp retLabel];
}
-(id<ORIdxIntInformer>) failLabel
{
   return [_cp failLabel];
}
-(id<ORInformer>) propagateFail
{
   return [_solver propagateFail];
}
-(id<ORInformer>) propagateDone
{
   return [_solver propagateDone];
}
@end
