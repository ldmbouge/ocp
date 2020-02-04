/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/
#import <ORUtilities/ORConcurrency.h>
#import <ORFoundation/ORFoundation.h>
/*
 #import <ORFoundation/ORExplorer.h>
 #import <ORFoundation/ORConstraint.h>
 #import <ORFoundation/ORController.h>
 #import <ORFoundation/ORSemDFSController.h>
 #import <ORFoundation/ORBackjumpingDFSController.h>
 */
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORFlatten.h>
#import <ORProgram/ORProgram.h>
#import <ORProgram/CPProgram.h>
#import <ORFoundation/ORConstraint.h>

#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPIntVarI.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>
#import <objcp/CPFloatVarI.h>
#import <objcp/CPDoubleVarI.h>
#import <objcp/CPRationalVarI.h>

#import "ORSplitVisitor.h"

#if defined(__linux__)
#import <values.h>
#endif

#import <ORFoundation/fpi.h>

#if __clang_major__<=3 && __clang_minor__<=6
#define _Nonnull
#endif

// [pvh: this is from a long time ago]
//
// 1. Look at IncModel to implement the incremental addition of constraints
// 2. Need to check how variables/constraints/objects are created during the search
// 3. Need to concretize them directly

@implementation CPHeuristicSet
{
   id<CPHeuristic>*  _tab;
   ORUInt            _sz;
   ORUInt            _mx;
}
-(CPHeuristicSet*) initCPHeuristicSet
{
   self = [super init];
   _mx  = 2;
   _tab = malloc(sizeof(id<CPHeuristic>)*_mx);
   _sz  = 0;
   return self;
}
-(void) push: (id<CPHeuristic>) h
{
   if (_sz >= _mx) {
      _tab = realloc(_tab, sizeof(id<CPHeuristic>) * (_mx << 1));
      _mx <<= 1;
   }
   _tab[_sz++] = h;
}
-(id<CPHeuristic>) pop
{
   return _tab[--_sz];
}
-(id<CPHeuristic>) top
{
   return _tab[_sz - 1];
}
-(void) reset
{
   for(ORUInt k=0;k<_sz;k++)
      [_tab[k] release];
   _sz = 0;
}
-(void) dealloc
{
   [self reset];
   free(_tab);
   [super dealloc];
}
-(void)applyToAll: (void(^)(id<CPHeuristic>))closure;
{
   for(ORUInt k=0;k<_sz;k++)
      closure(_tab[k]);
}
-(BOOL)empty
{
   return _sz == 0;
}
@end


@interface ORControllerFactoryI : NSObject<ORControllerFactory> {
   id<CPCommonProgram> _solver;
   id<ORSearchController>  _ctrlProto;
   id<ORSearchController>  _nestedProto;
}
-(id)initORControllerFactoryI: (id<CPCommonProgram>) solver
          rootControllerClass: (id<ORSearchController>)class
        nestedControllerClass: (id<ORSearchController>)nc;
-(id<ORSearchController>) makeRootController;
-(id<ORSearchController>) makeNestedController;
@end

@implementation ORControllerFactoryI
-(id)initORControllerFactoryI: (id<CPCommonProgram>) solver
          rootControllerClass: (id<ORSearchController>) ctrl
        nestedControllerClass: (id<ORSearchController>) nc
{
   self = [super init];
   _solver = solver;
   _ctrlProto = ctrl;
   _nestedProto = nc;
   return self;
}
-(id<ORSearchController>) makeRootController
{
   id<ORPost> pItf = [[CPINCModel alloc] init:_solver];
   return [[_ctrlProto clone] tuneWith:[_solver tracer] engine:[_solver engine] pItf:pItf];
   //   return [[_ctrlClass alloc] initTheController: [_solver tracer] engine: [_solver engine] posting:pItf];
}
-(id<ORSearchController>) makeNestedController
{
   id<ORPost> pItf = [[CPINCModel alloc] init:_solver];
   return [[_nestedProto clone] tuneWith:[_solver tracer] engine:[_solver engine] pItf:pItf];
   //   return [[_nestedClass alloc] initTheController: [_solver tracer] engine: [_solver engine] posting:pItf];
}
@end


/******************************************************************************************/
/*                                 CoreSolver                                             */
/******************************************************************************************/

@implementation CPCoreSolver {
@protected
   id<ORModel>           _model;
   id<CPEngine>          _engine;
   id<ORExplorer>        _search;
   id<ORSearchObjectiveFunction>  _objective;
   id<ORTrail>           _trail;
   id<ORMemoryTrail>     _mt;
   id<ORTracer>          _tracer;
   CPHeuristicSet*       _hSet;
   id<CPPortal>          _portal;
   
   ORInt                  _level;
   ORInt                 _unique;
   ORFloat                _split3Bpercent;
   ORInt                  _searchNBFloats;
   SEL                    _subcut;
   ORDouble               _absRate;
   ORDouble               _occRate;
   ORDouble               _absRateLimitModelVars;
   ORDouble               _absTRateLimitModelVars;
   ORDouble               _absRateLimitAdditionalVars;
   //[hzi] should we remove it ? An additional variable appear only in one wonstraint as operand
   ORDouble               _absTRateLimitAdditionalVars;
   ORInt                 _variationSearch;
   NSMutableArray*       _absconstraints;
   
   id<ORIdxIntInformer>  _returnLabel;
   id<ORIdxIntInformer>  _returnLT;
   id<ORIdxIntInformer>  _returnGT;
   id<ORIdxIntInformer>  _failLabel;
   id<ORIdxIntInformer>  _failLT;
   id<ORIdxIntInformer>  _failGT;
   TRInt                 _closed;
   BOOL                  _oneSol;
   NSMutableArray*       _doOnStartupArray;
   NSMutableArray*       _doOnSolArray;
   NSMutableArray*       _doOnExitArray;
   id<ORSolutionPool>    _sPool;
}
-(CPCoreSolver*) initCPCoreSolver
{
   self = [super init];
   _model = NULL;
   _hSet = [[CPHeuristicSet alloc] initCPHeuristicSet];
   _returnLabel = _failLabel = _returnLT = _returnGT = _failLT = _failGT = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal: self];
   _objective = nil;
   _sPool   = [ORFactory createSolutionPool];
   _oneSol = YES;
   _level = 0;
   _absRateLimitModelVars = 0.3;
   _absTRateLimitModelVars = 0.8;
   _absRateLimitAdditionalVars = 0.92;
   _absTRateLimitAdditionalVars = 0.0;
   _split3Bpercent = 10.f;
   _searchNBFloats = 2;
   _subcut = @selector(float3BSplit:call:withVars:);
   _unique = 0;
   _absRate = 0.1;
   _occRate = 0.1;
   _doOnStartupArray = [[NSMutableArray alloc] initWithCapacity: 1];
   _doOnSolArray     = [[NSMutableArray alloc] initWithCapacity: 1];
   _doOnExitArray    = [[NSMutableArray alloc] initWithCapacity: 1];
   return self;
}
-(void) dealloc
{
   NSLog(@"CPSolver dealloc'd %p",self);
   if(_absconstraints != nil) [_absconstraints release];
   [_hSet release];
   [_model release];
   [_portal release];
   [_returnLabel release];
   [_returnLT release];
   [_returnGT release];
   [_failLabel release];
   [_failLT release];
   [_failGT release];
   [_sPool release];
   [_doOnStartupArray release];
   [_doOnSolArray release];
   [_doOnExitArray release];
   [super dealloc];
}
-(id<ORMemoryTrail>)memoryTrail
{
   return _mt;
}
-(id<ORTracker>)tracker
{
   return _engine;
}
-(void) setSource:(id<ORModel>)src
{
   [_model release];
   _model = [src retain];
}
-(id<ORModel>)source
{
   return _model;
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"Solver: %d vars\n\t%d constraints\n\t%d choices\n\t%d fail\n\t%d propagations",
           [_engine nbVars],[_engine nbConstraints],[self nbChoices],[self nbFailures],[_engine nbPropagation]];
}
-(id<ORIdxIntInformer>) retLabel
{
   if (_returnLabel==nil)
      _returnLabel = [ORConcurrency idxIntInformer];
   return _returnLabel;
}
-(id<ORIdxIntInformer>) retLT
{
   if (_returnLT==nil)
      _returnLT = [ORConcurrency idxIntInformer];
   return _returnLT;
}
-(id<ORIdxIntInformer>) retGT
{
   if (_returnGT==nil)
      _returnGT = [ORConcurrency idxIntInformer];
   return _returnGT;
}
-(id<ORIdxIntInformer>) failLabel
{
   if (_failLabel==nil)
      _failLabel = [ORConcurrency idxIntInformer];
   return _failLabel;
}
-(id<ORIdxIntInformer>) failLT
{
   if (_failLT==nil)
      _failLT = [ORConcurrency idxIntInformer];
   return _failLT;
}
-(id<ORIdxIntInformer>) failGT
{
   if (_failGT==nil)
      _failGT= [ORConcurrency idxIntInformer];
   return _failGT;
}
-(id<CPPortal>) portal
{
   return _portal;
}
-(ORInt) nbFailures
{
   return [_engine nbFailures];
}
-(ORInt) nbChoices
{
   return [_search nbChoices];
}
-(id<CPEngine>) engine
{
   return _engine;
}
-(id<ORExplorer>) explorer
{
   return _search;
}
-(id<ORSearchObjectiveFunction>) objective
{
   return [_engine objective];
}
-(id<ORObjectiveValue>) objectiveValue
{
   return [[_engine objective] primalValue];
}
-(id<ORTracer>) tracer
{
   return _tracer;
}
-(void)tracer:(id<ORTracer>)tracer
{
   _tracer = tracer;
}
-(void) close
{
   if (!_closed._val) {
      assignTRInt(&_closed, YES, _trail);
      if ([_engine close] == ORFailure)
         [_search fail];
      if (![_hSet empty]) {
         @autoreleasepool {
            NSArray* svar = [_model variables];
            NSMutableArray* mvar = [[NSMutableArray alloc] initWithCapacity: svar.count];
            for(id<ORVar> x in svar) {
               if ([x conformsToProtocol: @protocol(ORIntVar)] || [x conformsToProtocol:@protocol(ORBitVar)])
                  [mvar addObject:x];
            }
            NSMutableArray* cvar = [[NSMutableArray alloc] initWithCapacity: mvar.count];
            for(id<ORVar> v in mvar)
               [cvar addObject:_gamma[v.getId]];
            tryfail(^ORStatus{
               [_hSet applyToAll:^(id<CPHeuristic> h) {
                  [h initHeuristic:mvar concrete:cvar oneSol:_oneSol tracker:self];
               }];
               [cvar release];
               [mvar release];
               return ORSuspend;
            }, ^ORStatus{
               [cvar release];
               [mvar release];
               [_search fail];
               return ORFailure;
            });
         }
      }
      [ORConcurrency pumpEvents];
   }
}
-(ORInt) debugLevel
{
   return _level;
}
-(void) setAbsComputationFunction:(ABS_FUN) f
{
   [ABSElement setFunChoice:f];
}
-(void) setAbsLimitModelVars:(ORDouble)local total:(ORDouble)global
{
   _absRateLimitModelVars = local;
   _absTRateLimitModelVars = global;
}
-(void) setAbsLimitAdditionalVars:(ORDouble) local total:(ORDouble)global
{
   _absRateLimitAdditionalVars = local;
   _absTRateLimitAdditionalVars = global;
}
-(void) setAbsRate:(ORDouble) r
{
   _absRate = r;
}
-(void) setOccRate:(ORDouble) r
{
   _occRate = r;
}
-(void) setVariation:(ORInt) variation
{
   _variationSearch = variation;
}
-(void) setLevel:(ORInt) level
{
   _level = level;
}
-(void) setUnique:(ORInt) u
{
   _unique = u;
}
-(void) set3BSplitPercent:(ORFloat) p
{
   _split3Bpercent = p;
}
-(void) setSearchNBFloats:(ORInt) p
{
   _searchNBFloats = p;
}
-(void) setSubcut:(SEL) s
{
   _subcut = s;
}
-(void) addHeuristic: (id<CPHeuristic>) h
{
   [_hSet push: h];
}
-(void) restartHeuristics
{
   [_hSet applyToAll:^(id<CPHeuristic> h) { [h restart];}];
}
-(void) clearOnStartup
{
   [_doOnStartupArray removeAllObjects];
}
-(void) clearOnSolution
{
   [_doOnSolArray removeAllObjects];
}
-(void) clearOnExit
{
   [_doOnExitArray removeAllObjects];
}
-(void) onSolution: (ORClosure) onSolution
{
   id block = [onSolution copy];
   [_doOnSolArray addObject: block];
   [block release];
}
-(void) onStartup:(ORClosure) onStartup
{
   id block = [onStartup copy];
   [_doOnStartupArray addObject: block];
   [block release];
}
-(void) onExit: (ORClosure) onExit
{
   id block = [onExit copy];
   [_doOnExitArray addObject: block];
   [block release];
}
-(id<ORSolutionPool>) solutionPool
{
   return _sPool;
}
// [pvh: This method should be higher; no need to repeat for all solvers]
-(id<ORSolution>) captureSolution
{
   if([_model conformsToProtocol: @protocol(ORParameterizedModel)])
      return [ORFactory parameterizedSolution: (id<ORParameterizedModel>)_model solver: self];
   return [ORFactory solution: _model solver: self];
}
-(void) doOnStartup
{
   for(ORClosure block in _doOnStartupArray) {
      block();
   }
}
-(void) doOnSolution
{
   for(ORClosure block in _doOnSolArray) {
      block();
   }
}
-(void) doOnExit
{
   for(ORClosure block in _doOnExitArray) {
      block();
   }
}
-(void) solve: (ORClosure) search
{
   _objective = [_engine objective];
   [self doOnStartup];
   if (_objective != nil) {
      _oneSol = NO;
      [_search optimizeModel: self using: search
                  onSolution: ^{ [self doOnSolution];}
                      onExit: ^{ [self doOnExit];}
       ];
      branchAndBoundTime = [NSDate date];
      if(!IS_GUESS_ERROR_SOLVER){
         SolWrapper* s = [[SolWrapper alloc] init:[_sPool objectAtIndexedSubscript:[_sPool count] - 1]];
         [s print:[_model variables] for:@"Input Values:"];
         NSLog(@"Optimal Solution: %@ (%@) thread: %d time: %.3f\n",[_objective primalBound],[_objective dualBound],[NSThread threadID],[branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart]);
      }
   }
   else {
      _oneSol = YES;
      [_search solveModel: self using: search
               onSolution: ^{ [self doOnSolution];}
                   onExit: ^{ [self doOnExit];}
       ];
   }
}
-(void) solveOn: (void(^)(id<CPCommonProgram>))body
{
   ORClosure search = ^() { body(self); };
   [self solve: search];
}
-(void) solveOn: (void(^)(id<CPCommonProgram>))body withTimeLimit: (ORFloat)limit;
{
   ORClosure newSearch = ^() { [self limitTime: limit * 1000 in: ^(){ body(self); }]; };
   [self doOnStartup];
   _objective = [_engine objective];
   if (_objective != nil) {
      _oneSol = NO;
      [_search optimizeModel: self using: newSearch
                  onSolution: ^{ [self doOnSolution];}
                      onExit: ^{ [self doOnExit];}
       ];
      NSLog(@"Optimal Solution: %@ thread:%d\n",[_objective primalBound],[NSThread threadID]);
   }
   else {
      _oneSol = YES;
      [_search solveModel: self using: newSearch
               onSolution: ^{ [self doOnSolution];}
                   onExit: ^{ [self doOnExit];}
       ];
   }
}
-(void) solveAll: (ORClosure) search
{
   _oneSol = NO;
   [self doOnStartup];
   [_search solveAllModel: self using: search
               onSolution: ^{ [self doOnSolution];[_engine incNbFailures:1];}
                   onExit: ^{ [self doOnExit];}
    ];
}
-(id<ORForall>) forall: (id<ORIntIterable>) S
{
   return [ORControl forall: self set: S];
}
-(void) forall: (id<ORIntIterable>) S orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   [ORControl forall: S suchThat: nil orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   filter = [_mt track:[filter copy]];
   order = [_mt track:[order copy]];
   body = [_mt track:[body copy]];
   [ORControl forall: S suchThat: filter orderedBy: order do: body];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) filter orderedByFloat: (ORInt2Float) order do: (ORInt2Void) body
{
   filter = [_mt track:[filter copy]];
   order = [_mt track:[order copy]];
   body = [_mt track:[body copy]];
   [ORControl forall: S suchThat: filter orderedByFloat: order do: body];
}
-(void) forall: (id<ORIntIterable>) S  orderedBy: (ORInt2Int) o1 then: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: self set: S];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 then: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: self set: S];
   [forall suchThat: suchThat];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) try: (ORClosure) left alt: (ORClosure) right
{
   [_search try: left alt: right];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter do: (ORInt2Void) body
{
   if (filter) filter = [_mt track:[filter copy]];
   if (body)   body   = [_mt track:[body copy]];
   [_search tryall: range suchThat: filter in: body];
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [_search tryall: range suchThat: filter in: body onFailure: onFailure];
}

-(void) tryall: (id<ORIntIterable>) range
      suchThat: (ORInt2Bool) filter
     orderedBy: (ORInt2Double)o1
in: (ORInt2Void) body
onFailure: (ORInt2Void) onFailure
{
   [_search tryall:range suchThat:filter orderedBy:o1 in:body onFailure:onFailure];
}

-(void) atomic:(ORClosure)body
{
   ORStatus status = [_engine atomic:body];
   if (status == ORFailure) {
      [_search fail];
   }
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   [_search limitTime: maxTime in: cl];
}

-(void)      nestedOptimize: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit  control:(id<ORSearchController>)newCtrl
{
   [_search nestedOptimize:self
                     using:body
                onSolution:onSolution
                    onExit:onExit
                   control:[[ORNestedController alloc] init:newCtrl
                                                     parent:[_search controller]]];
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit  control:(id<ORSearchController>)newCtrl
{
   [_search nestedSolve: body
             onSolution: onSolution
                 onExit: onExit
                control:[[ORNestedController alloc] init:newCtrl
                                                  parent:[_search controller]]];
}

-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolve: body onSolution: onSolution onExit: onExit
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolve: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [_search nestedSolve: body onSolution: onSolution onExit:nil
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolve: (ORClosure) body
{
   [_search nestedSolve: body onSolution:nil onExit:nil
                control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit control:(id<ORSearchController>)sc
{
   [_search nestedSolveAll:body onSolution:onSolution onExit:onExit
                   control:[[ORNestedController alloc] init:sc parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution onExit: (ORClosure) onExit
{
   [_search nestedSolveAll: body onSolution: onSolution onExit: onExit
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body onSolution: (ORClosure) onSolution
{
   [_search nestedSolveAll: body onSolution: onSolution onExit:nil
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(void) nestedSolveAll: (ORClosure) body
{
   [_search nestedSolveAll: body onSolution:nil onExit:nil
                   control:[[ORNestedController alloc] init:[_search controller] parent:[_search controller]]];
}
-(id) trackObject: (id) object
{
   return [_engine trackObject:object];
}
-(id) trackMutable: (id) object
{
   return [_engine trackMutable:object];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_engine trackConstraintInGroup:obj];
}
-(id) trackObjective:(id) object
{
   return [_engine trackObjective: object];
}
-(id) trackImmutable: (id) object
{
   return [_engine trackImmutable:object];
}
-(id) trackVariable: (id) object
{
   return [_engine trackMutable:object];
}

-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelImpl not implemented"];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method diffImpl not implemented"];
}
-(void) labelImplRational: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelImplRational not implemented"];
}
-(void) diffImplRational: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method diffImplRational not implemented"];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method lthenImpl not implemented"];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method gthenImpl not implemented"];
}
-(void) realLabelImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method realLabelImpl: not implemented"];
}
-(void) realLthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method realLthenImpl: not implemented"];
}
-(void) realGthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method realGthenImpl: not implemented"];
}
-(void) floatLthenImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method floatLthenImpl: not implemented"];
}
-(void) floatGthenImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method floatGthenImpl: not implemented"];
}
-(void) rationalLthenImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method rationalLthenImpl: not implemented"];
}
-(void) rationalGthenImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method rationalGthenImpl: not implemented"];
}
-(void) rationalLEqualImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method rationalLEqualImpl: not implemented"];
}
-(void) rationalGEqualImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method rationalGEqualImpl: not implemented"];
}
-(void) floatLEqualImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method floatLEqualImpl: not implemented"];
}
-(void) floatGEqualImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method floatGEqualImpl: not implemented"];
}
-(void) floatIntervalImpl: (id<CPFloatVar>) var low: (ORFloat) low up:(ORFloat) u
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method floatIntervalImpl: not implemented"];
}
-(void) errorLEqualImpl: (id<CPFloatVar>) var with: (id<ORRational>) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method floatLEqualImpl: not implemented"];
}
-(void) errorGEqualImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method floatGEqualImpl: not implemented"];
}
-(void) errorsIntervalImpl: (id<CPFloatVar>) var low: (id<ORRational>) low up:(id<ORRational>) u
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method floatIntervalImpl: not implemented"];
}
-(void) doubleLthenImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method doubleLthenImpl: not implemented"];
}
-(void) doubleGthenImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method doubleGthenImpl: not implemented"];
}
-(void) doubleLEqualImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method doubleLEqualImpl: not implemented"];
}
-(void) doubleGEqualImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method doubleGEqualImpl: not implemented"];
}
-(void) doubleIntervalImpl: (id<CPDoubleVar>) var low: (ORDouble) low up:(ORDouble) u
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method doubleIntervalImpl: not implemented"];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method restrictImpl not implemented"];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelBVImpl not implemented"];
}
-(void) labelBitsImpl:(id<ORBitVar>)x withValue:(ORInt) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelBitsImpl not implemented"];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var with:(ORUInt)val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelBVImpl not implemented"];
}
-(void) diffBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(bool)val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method diffBVImpl not implemented"];
}
-(void) diffBVImpl:(id<CPBitVar,CPBitVarNotifier>)var with:(ORUInt)val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method diffBVImpl not implemented"];
}
-(ORInt) maxBound:(id<ORIdArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   ORInt M = -MAXINT;
   for(ORInt i = low; i <= up; i++) {
      if ([self bound:x[i]]) {
         ORInt v = [self intValue:x[i]];
         if (v > M)
            M = v;
      }
   }
   return M;
}

-(ORBool) ground
{
   ORBool holdsVertical = [_engine holdsVertical];
   if (holdsVertical)
      return YES;
   NSMutableArray* av = [_engine variables];
   for(id<CPVar> xi in av) {
      if (![xi bound] && [xi degree] > 0)
         return NO;
   }
   return YES;
}
-(ORBool) allBound:(id<ORIdArray>) x
{
   ORInt low = x.low,up = x.up;
   for(ORInt i =low;i <= up;i++) {
      if (![self bound:x[i]])
         return NO;
   }
   return YES;
}
-(id<ORIntVar>)smallestDom:(id<ORIdArray>)x
{
   ORInt low = x.low,up = x.up;
   ORInt M = FDMAXINT,best = low-1;
   for(ORInt i=low;i <= up;i++) {
      ORInt dsz = [self domsize:x[i]];
      if (dsz == 1) continue;
      if (dsz < M) {
         best = i;
         M = dsz;
      }
   }
   if (best != low-1)
      return x[best];
   else return nil;
}

-(void) labelBit:(int)i ofVar:(id<ORBitVar>)x
//>>>>>>> master
{
   [_search try: ^() { [self labelBV:x at:i with:false];}
            alt: ^() { [self labelBV:x at:i with:true];}];
}
-(void) labelBits:(id<ORBitVar>)x withValue:(ORInt) v
{
   [self labelBitsImpl:_gamma[x.getId] withValue:v];
}


-(void) labelUpFromLSB:(id<ORBitVar>) x
{
   int i=-1;
   id<CPBitVar> bv = _gamma[x.getId];
   
   __block long long int domainBefore;
   __block long long int domainAfter;
   __block long long int domainDiff;
   __block id<ORBasicModel> mdl = [_engine model];
   NSArray* variables = [mdl variables];
   //   CPBitVarI* bv = (CPBitVarI*) _gamma[x.getId];
   while ((i=[bv lsFreeBit])>=0) {
      NSAssert(i>=0,@"ERROR in [labelUpFromLSB] bitVar is not bound, but no free bits found when using lsFreeBit.");
      //<<<<<<< HEAD
      [_search try: ^() {  domainBefore = domainAfter = 0;
         for(int j=0;j<[variables count];j++)
            domainBefore += [variables[j] domsize];
         [self labelBV:x at:i with:false];
         //                           [self labelBVImpl: (id<CPBitVar,CPBitVarNotifier>)_gamma[x.getId] at:i with: false];
         for(int j=0;j<[variables count];j++)
            domainBefore += [variables[j] domsize];
         domainDiff = domainBefore-domainAfter;
         //if ((domainDiff = domainBefore-domainAfter)>20000)
         //NSLog(@"Setting bit %i to false of %@ reduced search space by %lli",i,x,domainDiff);
      }
       
               alt: ^() { domainBefore = domainAfter = 0;
         for(int j=0;j<[variables count];j++)
            domainBefore += [variables[j] domsize];
         [self labelBV:x at:i with:true];
         //                   [self labelBVImpl: (id<CPBitVar,CPBitVarNotifier>)_gamma[x.getId] at:i with: true];
         for(int j=0;j<[variables count];j++)
            domainBefore += [variables[j] domsize];
         domainDiff = domainBefore-domainAfter;
         //if ((domainDiff = domainBefore-domainAfter)>20000)
         //NSLog(@"Setting bit %i to true  of %@ reduced search space by %lli",i,x,domainDiff);
      }
       ];
      //=======
      //      [_search try: ^() { [self labelBV:x at:i with:false];}
      //               alt: ^() { [self labelBV:x at:i with:true];}];
      //>>>>>>> master
   }
}

-(void) labelDownFromMSB:(id<ORBitVar>) x
{
   int i;
   
   id<CPBitVar> bv = _gamma[x.getId];
   while ((i=[bv msFreeBit])>=0) {
      //      i=[bv msFreeBit];
      //      NSLog(@"%@ shows MSB as %d",bv,i);
      NSAssert(i>=0,@"ERROR in [labelDownFromMSB] bitVar is not bound, but no free bits found when using msFreeBit.");
      [_search try: ^() { [self labelBV:x at:i with:true];}
               alt: ^() { [self labelBV:x at:i with:false];}];
   }
}

//<<<<<<< HEAD
//-(void) labelOutFromMidFreeBit:(id<ORBitVar>) x
//{
//   int i=-1;
//   id<CPBitVar> bv = _gamma[x.getId];
//
//   __block long long int domainBefore;
//   __block long long int domainAfter;
//   __block long long int domainDiff;
//   __block id<ORBasicModel> mdl = [_engine model];
//   NSArray* variables = [mdl variables];
//   //   CPBitVarI* bv = (CPBitVarI*) _gamma[x.getId];
//   while (![bv bound]) {
//      i=[bv midFreeBit];
//      NSAssert(i>=0,@"ERROR in [labelUpFromLSB] bitVar is not bound, but no free bits found when using lsFreeBit.");
//      [_search try: ^() {  domainBefore = domainAfter = 0;
//         for(int j=0;j<[variables count];j++)
//            domainBefore += [variables[j] domsize];
//         [self labelBV:x at:i with:false];
//         for(int j=0;j<[variables count];j++)
//            domainBefore += [variables[j] domsize];
//         domainDiff = domainBefore-domainAfter;
//         //if ((domainDiff = domainBefore-domainAfter)>20000)
//         //NSLog(@"Setting bit %i to false of %@ reduced search space by %lli",i,x,domainDiff);
//=======
////   NSLog(@"%lld unbound variables.",numVars);
//   while (freeVars) {
//      freeVars = false;
//      numBound = 0;
//      for(int i=0;i<numVars;i++){
//         if ([vars[i] bound]){
//            numBound++;
//            continue;
//         }
//         if ([vars[i] domsize] <= 0)
//            continue;
//         if (!freeVars) {
//            minDom = vars[i];
//            minDomSize = [minDom domsize];
//            freeVars = true;
//            continue;
//         }
//         thisDomSize= [vars[i] domsize];
//         if(thisDomSize==0)
//            continue;
//         if (thisDomSize < minDomSize) {
//            minDom = vars[i];
//            minDomSize = thisDomSize;
//         }
//      }
//      if (!freeVars)
//         break;
//      //NSLog(@"%d//%lld bound.",numBound, numVars);
////      j=[minDom randomFreeBit];
//
//      //NSLog(@"Labeling %@ at %d.", minDom, j);
//      while ([minDom domsize] > 0) {
//         j= [minDom randomFreeBit];
//         [_search try: ^() { [self labelBVImpl:(id)minDom at:j with:false];}
//                  alt: ^() { [self labelBVImpl:(id)minDom at:j with:true];}];
//>>>>>>> master
//      }
//
//                or: ^() { domainBefore = domainAfter = 0;
//                   for(int j=0;j<[variables count];j++)
//                      domainBefore += [variables[j] domsize];
//                   [self labelBV:x at:i with:true];
//                   for(int j=0;j<[variables count];j++)
//                      domainBefore += [variables[j] domsize];
//                   domainDiff = domainBefore-domainAfter;
//                   //if ((domainDiff = domainBefore-domainAfter)>20000)
//                   //NSLog(@"Setting bit %i to true  of %@ reduced search space by %lli",i,x,domainDiff);
//                }
//       ];
//   }
//}
//
-(void) labelRandomFreeBit:(id<ORBitVar>) x
{
   //   NSLog(@"Labeling bitvars by selecting unbound bits uniformly at random");
   int i=-1;
   id<CPBitVar> bv = _gamma[x.getId];
   
   //   CPBitVarI* bv = (CPBitVarI*) _gamma[x.getId];
   while (![bv bound]) {
      i=[bv randomFreeBit];
      //      NSLog(@"Labeling Bit at index %d",i);
      // LDM: TODO: This needs fixing! We should be using distributions here!
#if defined(__APPLE__)
      int rand = arc4random();
#else
      int rand = random();
#endif
      if (rand > 0.5){
         //         NSLog(@"Labeling Bit at index %d with false first",i);
         [_search try: ^() { [self labelBV:x at:i with:false];}
                 then: ^() { [self labelBV:x at:i with:true];}];
      }
      else {
         //         NSLog(@"Labeling Bit at index %d with true first",i);
         [_search try: ^() { [self labelBV:x at:i with:true];}
                 then: ^() { [self labelBV:x at:i with:false];}];
      }
   }
}

-(void) labelBitsMixedStrategy:(id<ORBitVar>) x
{
   int i=-1;
   id<CPBitVar> bv = _gamma[x.getId];
   
   //   CPBitVarI* bv = (CPBitVarI*) _gamma[x.getId];
   while (![bv bound]) {
      i=[bv midFreeBit];
      //      NSLog(@"%@ shows MSB as %d",bv,i);
      NSAssert(i>=0,@"ERROR in [labelDownFromMSB] bitVar is not bound, but no free bits found when using msFreeBit.");
      [_search try: ^() { [self labelBV:x at:i with:false];}
              then: ^() { [self labelBV:x at:i with:true];}];
      
      
      if (![bv bound]) {
         i = [bv lsFreeBit];
         [_search try: ^() { [self labelBV:x at:i with:false];}
                 then: ^() { [self labelBV:x at:i with:true];}];
      }
      if (![bv bound]) {
         i = [bv msFreeBit];
         [_search try: ^() { [self labelBV:x at:i with:false];}
                 then: ^() { [self labelBV:x at:i with:true];}];
      }
   }
}

-(void)splitArray:(id<ORIntVarArray>)x
{
   id<ORIntRange> R = x.range;
   id<CPHeuristic> h = [_hSet empty] ? nil : _hSet.top;
   while (![self allBound:x]) {
      ORDouble ld = FDMAXINT;
      ORInt bi = R.low - 1;
      for(ORInt i=R.low;i <= R.up;i++) {
         CPIntVar* cxi = _gamma[getId(x[i])];
         if (bound(cxi)) continue;
         ORDouble ds = h ? [h varOrdering:cxi] : - [cxi domsize];
         ld = ld < ds ? ld : ds;
         if (ld == ds) bi = i;
      }
      CPIntVar* bxi = _gamma[getId(x[bi])];
      ORInt lb =bxi.min,ub = bxi.max;
      ORInt mp = lb + (ub - lb)/2;
      [self try: ^{ [self lthen:x[bi] with:mp+1];}
            alt: ^{ [self gthen:x[bi] with:mp];}];
   }
}

-(void)split:(id<ORIntVar>)x
{
   CPIntVar* cx = _gamma[getId(x)];
   while (!bound(cx)) {
      ORInt lb =cx.min,ub = cx.max;
      ORInt mp = lb + (ub - lb)/2;
      [self try: ^{ [self lthen:x with:mp+1];}
            alt: ^{ [self gthen:x with:mp];}];
   }
}

-(void) labelArray: (id<ORIntVarArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   for(ORInt i = low; i <= up; i++) {
      CPIntVar* xi = _gamma[getId(x[i])];
      while (!bound(xi)) {
         ORInt m = minDom(xi);
         [_search try: ^{  [self label: x[i] with: m]; }
                  alt: ^{  [self  diff: x[i] with: m]; }
          ];
      }
   }
}

-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Double) orderedBy
{
   // [ldm] there is no leak whatsoever. the range and the selector both get added
   // to the memory trail. When backtracking the objects on the memory trail are released.
   // If, instead, the code uses a non-chronological controller, the checkpoint captures the
   // memory stack and therefore the object won't be released either until the checkpoint itself
   // disappears.
   const ORInt sz = x.range.size;
   id<CPIntVar> cx[sz];
   for(ORInt i=0;i < sz;i++)
      cx[i]  = _gamma[x[i + x.range.low].getId];
   id<CPIntVar>* cxp = cx;
   ORInt low = [x low];
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,low,[x up])
                                  suchThat: ^ORBool(ORInt i) { return ![cxp[i - low] bound]; }
                                 orderedBy: orderedBy];
   do {
      ORSelectorResult i = [select min];
      if (!i.found)
         break;
      [self label: x[i.index]];
   } while (true);
}

-(void) labelArrayFF:(id<ORIntVarArray>) x
{
   const ORInt sz = x.range.size;
   id<CPIntVar> cx[sz];
   for(ORInt i=0;i < sz;i++)
      cx[i]  = _gamma[x[i + x.range.low].getId];
   id<ORRandomStream> tie = [ORFactory randomStream:_engine];
   do {
      ORInt sd  = FDMAXINT;
      id<CPIntVar> sx = NULL;
      ORInt        bi = -1;
      ORLong bestRand = 0x7fffffffffffffff;
      for(ORInt i=0;i<sz;i++) {
         ORInt cds = [cx[i] domsize];
         if (cds==1) continue;
         if (cds < sd) {
            sd = cds;
            sx = cx[i];
            bi = i;
            bestRand = [tie next];
         } else if (cds==sd) {
            ORLong nr = [tie next];
            if (nr < bestRand) {
               sx = cx[i];
               bi = i;
               bestRand = nr;
            }
         }
      }
      if (sx == NULL) break;
      ORBounds xb = [sx bounds];
      while (xb.min != xb.max) {
         assert(_gamma[x[bi+x.range.low].getId] == sx);
         [_search try:^{
            [self label:x[bi+x.range.low] with:xb.min];
         } alt:^{
            [self diff:x[bi+x.range.low] with:xb.min];
         }];
         xb = [sx bounds];
      }
   } while(true);
}

-(void) select:(id<ORIntVarArray>)x minimizing:(ORInt2Double)f in:(ORInt2Void)body
{
   const ORInt sz = x.range.size;
   id<CPIntVar> cx[sz];
   for(ORInt i=0;i < sz;i++)
      cx[i]  = _gamma[x[i + x.range.low].getId];
   id<ORRandomStream> tie = [ORFactory randomStream:_engine];
   ORDouble     sd = MAXDBL;
   ORInt        bi = -1;
   ORLong bestRand = 0x7fffffffffffffff;
   for(ORInt i=0;i<sz;i++) {
      if (cx[i].bound) continue;
      ORDouble cds = f(i);
      if (cds < sd) {
         sd = cds;
         bi = i;
         bestRand = [tie next];
      } else if (cds==sd) {
         ORLong nr = [tie next];
         if (nr < bestRand) {
            bi = i;
            bestRand = nr;
         }
      }
   }
   if (bi == -1)
      return;
   body(bi + x.range.low);
}

-(void) labelHeuristic: (id<CPHeuristic>) h
{
   [self labelHeuristic:h withVars:(id)[h allIntVars]];
}
-(void) labelHeuristic: (id<CPHeuristic>) h restricted:(id<ORIntVarArray>)av
{
   [self labelHeuristic:h withVars:av];
}

-(void) labelHeuristic: (id<CPHeuristic>) h withVars:(id<ORIntVarArray>)av
{
   // [ldm] All four objects below are on the memory trail (+range of selector)
   // Note, the two mutables are created during the search, hence never concretized.
   id<CPIntVarArray> cav = [CPFactory intVarArray:self range:av.range with:^id<CPIntVar>(ORInt i) {
      CPIntVar* sv =_gamma[av[i].getId];
      assert([sv isKindOfClass:[CPIntVar class]]);
      return sv;
   }];
   
   id<ORSelect> select = [ORFactory selectRandom: _engine
                                           range: RANGE(_engine,[av low],[av up])
                                        suchThat: ^ORBool(ORInt i) { return ![cav[i] bound]; }
                                       orderedBy: ^ORDouble(ORInt i) {
      ORDouble rv = [h varOrdering:cav[i]];
      return rv;
   }];
   id<ORRandomStream>   valStream = [ORFactory randomStream:_engine];
   ORMutableIntegerI*   failStamp = [ORFactory mutable:_engine value:-1];
   ORMutableId*              last = [ORFactory mutableId:_engine value:nil];
   do {
      id<ORIntVar> x = [last idValue];
      //NSLog(@"at top: last = %p",x);
      if ([failStamp intValue]  == [self nbFailures] || (x == nil || [self bound:x])) {
         ORSelectorResult i = [select max];
         if (!i.found)
            return;
         x = av[i.index];
         //NSLog(@"-->Chose variable: %p",x);
         [last setIdValue:x];
      }/* else {
        NSLog(@"STAMP: %d  - %d",[failStamp value],[self nbFailures]);
        }*/
      [failStamp setValue:[self nbFailures]];
      ORDouble bestValue = - MAXDBL;
      ORLong bestRand = 0x7fffffffffffffff;
      ORInt low = x.min;
      ORInt up  = x.max;
      ORInt bestIndex = low - 1;
      id<CPIntVar> cx = _gamma[x.getId];
      for(ORInt v = low;v <= up;v++) {
         if ([cx member:v]) {
            ORDouble vValue = [h valOrdering:v forVar:cx];
            if (vValue > bestValue) {
               bestValue = vValue;
               bestIndex = v;
               bestRand  = [valStream next];
            } else if (vValue == bestValue) {
               ORLong rnd = [valStream next];
               if (rnd < bestRand) {
                  bestIndex = v;
                  bestRand = rnd;
               }
            }
         }
      }
      if (bestIndex != low - 1)  {
         [_search try: ^{
            [self label:x with: bestIndex];
         } alt: ^{
            [self diff:x with: bestIndex];
         }];
      }
   } while (true);
}

-(void) labelBitVarHeuristic: (id<CPBitVarHeuristic>) h
{
   [self labelBitVarHeuristic:h withConcrete:(id)[h allBitVars]];
}
-(void) labelBitVarHeuristicCDCL: (id<CPBitVarHeuristic>) h
{
   [self labelBitVarHeuristicCDCL:h withConcrete:(id)[h allBitVars]];
}
-(void) labelBitVarHeuristic: (id<CPBitVarHeuristic>) h restricted:(id<ORBitVarArray>)av
{
   id<CPBitVarArray> cav = (id<CPBitVarArray>)[ORFactory varArray:self range:av.range with:^id<ORBitVar>(ORInt k) {
      return _gamma[av[k].getId];
   }];
   [self labelBitVarHeuristic:h withConcrete:cav];
}
-(void) labelBitVarHeuristic: (id<CPBitVarHeuristic>) h withConcrete:(id<CPBitVarArray>)av
{
   id<ORSelect> select = [ORFactory selectRandom: _engine
                                           range: RANGE(_engine,[av low],[av up])
                                        suchThat: ^ORBool(ORInt i) { return ![av[i] bound]; }
                                       orderedBy: ^ORDouble(ORInt i) {
      ORDouble rv = [h varOrdering:av[i]];
      return rv;
   }];
   id<ORRandomStream>   valStream = [ORFactory randomStream:_engine];
   ORMutableIntegerI*   failStamp = [ORFactory mutable:_engine value:-1];
   ORMutableId*              last = [ORFactory mutableId:_engine value:nil];
   __block ORSelectorResult i ;
   do {
      id<CPBitVar> x = [last idValue];
      i = [select max];
      if (i.found)
         return;
      x =av[i.index];
      [last setIdValue:x];
      NSAssert2([x isKindOfClass:[CPBitVarI class]], @"%@ should be kind of class %@", x, [[CPBitVarI class] description]);
      [failStamp setValue:[self nbFailures]];
      ORFloat bestValue = - MAXFLOAT;
      ORLong bestRand = 0x7fffffffffffffff;
      ORInt low = [x lsFreeBit];
      ORInt up  = [x msFreeBit];
      ORInt bestIndex = - 1;
      for(ORInt v = up;v >= low;v--) {
         if ([x isFree:v]) {
            ORFloat vValue = [h valOrdering:v forVar:x];
            if (vValue > bestValue) {
               bestValue = vValue;
               bestIndex = v;
               bestRand  = [valStream next];
            } else if (vValue == bestValue) {
               ORLong rnd = [valStream next];
               if (rnd < bestRand) {
                  bestIndex = v;
                  bestRand = rnd;
               }
            }
         }
      }
      if (bestIndex != - 1)  {
         [_search try: ^{
            [self labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)x at: bestIndex with:true];
         } alt: ^{
            [self labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)x at: bestIndex with:false];
         }];
      }
   } while (true);
}


-(void) labelBitVarHeuristicCDCL: (id<CPBitVarHeuristic>) h withConcrete:(id<CPBitVarArray>)av
{
   __block id<ORSelect> select = [ORFactory selectRandom: _engine
                                                   range: RANGE(_engine,[av low],[av up])
                                  //                                        suchThat: ^bool(ORInt i)    { return ![_gamma[[av at: i].getId] bound]; }
                                                suchThat: ^ORBool(ORInt i) { return ![av[i] bound]; }
                                               orderedBy: ^ORDouble(ORInt i) {
      ORDouble rv = [h varOrdering:av[i]];
      return rv;
   }];
   
   id<ORRandomStream>   valStream = [ORFactory randomStream:_engine];
   ORMutableIntegerI*   failStamp = [ORFactory mutable:_engine value:-1];
   ORMutableId*              last = [ORFactory mutableId:_engine value:nil];
   __block ORSelectorResult i ;
   do {
      id<CPBitVar> x = [last idValue];
      //NSLog(@"at top: last = %p",x);
      if ([failStamp intValue]  == [self nbFailures] || (x == nil || [x bound])) {
         i = [select max];
         if (!i.found)
            return;
         x = av[i.index];
         //                  NSLog(@"-->Chose variable: %p=%@",x,x);
         [last setIdValue:x];
      } else {
         //         NSLog(@"STAMP: %d  - %d",[failStamp value],[self nbFailures]);
      }
      NSAssert2([x isKindOfClass:[CPBitVarI class]], @"%@ should be kind of class %@", x, [[CPBitVarI class] description]);
      [failStamp setValue:[self nbFailures]];
      ORFloat bestValue = - MAXFLOAT;
      ORLong bestRand = 0x7fffffffffffffff;
      ORInt low = [x lsFreeBit];
      ORInt up  = [x msFreeBit];
      __block ORInt bestIndex = 0;
      for(ORInt v = low;v <= up;v++) {
         if ([x isFree:v]) {
            ORFloat vValue = [h valOrdering:v forVar:x];
            if (vValue > bestValue) {
               bestValue = vValue;
               bestIndex = v;
               bestRand  = [valStream next];
            } else if (vValue == bestValue) {
               ORLong rnd = [valStream next];
               if (rnd < bestRand) {
                  bestIndex = v;
                  bestRand = rnd;
               }
            }
         }
      }
      
      if (bestIndex != - 1)  {
         [_search try: ^{
            //            NSLog(@"Choicepoint: setting %lx[%d] = false",(unsigned long)x, bestIndex);
            [self labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)x at: bestIndex with:false];
         } alt: ^{
            //            NSLog(@"Choicepoint: setting %lx[%d] = true",(unsigned long)x, bestIndex);
            [self labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)x at: bestIndex with:true];
         }];
      }
   } while (true);
}




-(void) labelBitVar: (id<ORBitVar>) var at:(ORUInt)idx with: (ORUInt) val
{
   
   return [self labelBVImpl: _gamma[var.getId] at:idx with: val];
}
-(void) bitVarDiff: (id<ORBitVar>) var with: (ORUInt) val
{
   [self diffBVImpl:_gamma[var.getId] with: val];
}

-(void) label: (id<ORIntVar>) mx
{
   id<CPIntVar> x = _gamma[mx.getId];
   while (![x bound]) {
      ORInt m = [x min];
      [_search try: ^{  [self label: mx with: m]; }
               alt: ^{ [self  diff: mx with: m]; }
       ];
   }
}
-(void) labelRational: (id<ORRationalVar>) mx
{
   id<CPRationalVar> x = _gamma[mx.getId];
   id<ORRational> mid = [[[ORRational alloc] init] autorelease];
   id<ORRational> two = [[[ORRational alloc] init] autorelease];
   [two set_d:2];
   while (![x bound]) {
      mid = [[[x min] div: two] add: [[x max] div: two]];
      [_search try: ^{
         [self rationalGEqual: mx with: mid];
      } alt: ^{
         [self rationalLEqual: mx with: mid];
      }
       ];
   }
}
-(void) labelFloat: (id<ORFloatVar>) mx
{
   id<CPFloatVar> x = _gamma[mx.getId];
   while (![x bound]) {
      ORFloat mid = ([x min] / 2.0f) + ([x max] / 2.0f);
      [_search try: ^{
         [self floatGEqual: mx with: mid];
      } alt: ^{
         
         [self floatLthen: mx with: mid];
      }
       ];
   }
}
-(ORInt) selectValue: (id<ORIntVar>) v by: (ORInt2Double) o
{
   return [self selectValueImpl: _gamma[v.getId] by: o];
}
-(ORInt) selectValueImpl: (id<CPIntVar>) x by: (ORInt2Double) o
{
   ORDouble bestFound = MAXDBL;
   ORInt indexFound = MAXINT;
   ORInt low = [x min];
   ORInt up = [x max];
   for(ORInt i = low; i <= up; i++) {
      if ([x member: i]) {
         ORDouble v = o(i);
         if (v < bestFound) {
            bestFound = v;
            indexFound = i;
         }
      }
   }
   return indexFound;
}
-(ORInt) selectValue: (id<ORIntVar>) v by: (ORInt2Double) o1 then: (ORInt2Double) o2
{
   return [self selectValueImpl: _gamma[v.getId] by: o1 then: o2];
}
-(ORInt) selectValueImpl: (id<CPIntVar>) x by: (ORInt2Double) o1 then: (ORInt2Double) o2
{
   ORDouble bestFound1 = MAXDBL;
   ORDouble bestFound2 = MAXDBL;
   ORInt indexFound = MAXINT;
   ORInt low = [x min];
   ORInt up = [x max];
   for(ORInt i = low; i <= up; i++) {
      if ([x member: i]) {
         ORDouble v = o1(i);
         if (v < bestFound1) {
            bestFound1 = v;
            bestFound2 = o2(i);
            indexFound = i;
         }
         else if (v == bestFound1) {
            ORDouble w = o2(i);
            if (w < bestFound2) {
               bestFound2 = w;
               indexFound = i;
            }
         }
      }
   }
   return indexFound;
}

-(void) label: (id<ORIntVar>) var by: (ORInt2Double) o1 then: (ORInt2Double) o2
{
   id<CPIntVar> x = _gamma[getId(var)];
   while (![x bound]) {
      ORInt val = [self selectValueImpl: x by: o1 then: o2];
      [self try: ^() { [self label: var with: val]; }
            alt: ^() { [self diff: var with: val]; }];
   }
}
-(void) label: (id<ORIntVar>) var by: (ORInt2Double) o
{
   id<CPIntVar> x = _gamma[getId(var)];
   while (![x bound]) {
      ORInt val = [self selectValueImpl: x by: o];
      [self try: ^() { [self label: var with: val]; }
            alt: ^() { [self diff: var with: val]; }];
   }
}
-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   return [self labelImpl: _gamma[var.getId] with: val];
}
-(void) labelRational: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   return [self labelImplRational: _gamma[var.getId] with: val];
}
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   [self diffImpl: _gamma[var.getId] with: val];
}
-(void) diffRational: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   [self diffImplRational: _gamma[var.getId] with: val];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   [self lthenImpl: _gamma[var.getId] with: val];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   [self gthenImpl: _gamma[var.getId] with: val];
}
-(void) lthen: (id<ORIntVar>) var double: (ORDouble) val
{
   [self lthenImpl: _gamma[var.getId] with: rint(ceil(val))];
}
-(void) gthen: (id<ORIntVar>) var double: (ORDouble) val
{
   [self gthenImpl: _gamma[var.getId] with: rint(floor(val))];
}
-(void) rationalLthen: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   [self rationalLthenImpl: _gamma[var.getId] with: val];
}
-(void) rationalGthen: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   [self rationalGthenImpl: _gamma[var.getId] with: val];
}
-(void) rationalLEqual: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   [self rationalLEqualImpl: _gamma[var.getId] with: val];
}
-(void) rationalGEqual: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   [self rationalGEqualImpl: _gamma[var.getId] with: val];
}
-(void) floatLthen: (id<ORFloatVar>) var with: (ORFloat) val
{
   [self floatLthenImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory floatLThenc:self var:var lt: val]];
}
-(void) floatGthen: (id<ORFloatVar>) var with: (ORFloat) val
{
   [self floatGthenImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory floatGThenc:self var:var gt: val]];
}
-(void) floatLEqual: (id<ORFloatVar>) var with: (ORFloat) val
{
   [self floatLEqualImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory floatLEqualc:self var:var leq: val]];
}
-(void) floatGEqual: (id<ORFloatVar>) var with: (ORFloat) val
{
   [self floatGEqualImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory floatGEqualc:self var:var geq: val]];
}
-(void) floatInterval: (id<ORFloatVar>) var low: (ORFloat) low up:(ORFloat) up
{
   [self floatIntervalImpl: _gamma[var.getId] low: low up:up];
   [_tracer addCommand: [ORFactory floatLEqualc:self var:var leq: up]];
   [_tracer addCommand: [ORFactory floatGEqualc:self var:var geq: low]];
}
-(void) errorGEqual: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   [self errorGEqualImpl:_gamma[var.getId] with:val];
   [_tracer addCommand: [ORFactory rationalGEqualc:self var:var geq:val]];
}
-(void) errorLEqual: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   [self errorLEqualImpl:_gamma[var.getId] with:val];
   [_tracer addCommand: [ORFactory rationalLEqualc:self var:var leq:val]];
}
-(void) doubleLthen: (id<ORDoubleVar>) var with: (ORDouble) val
{
   [self doubleLthenImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory doubleLThenc:self var:var lt: val]];
}
-(void) doubleGthen: (id<ORDoubleVar>) var with: (ORDouble) val
{
   [self doubleGthenImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory doubleGThenc:self var:var gt: val]];
}
-(void) doubleLEqual: (id<ORDoubleVar>) var with: (ORDouble) val
{
   [self doubleLEqualImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory doubleLEqualc:self var:var leq: val]];
}
-(void) doubleGEqual: (id<ORDoubleVar>) var with: (ORDouble) val
{
   [self doubleGEqualImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory doubleGEqualc:self var:var geq: val]];
}
-(void) doubleInterval: (id<ORDoubleVar>) var low: (ORDouble) low up:(ORDouble) up
{
   [self doubleIntervalImpl: _gamma[var.getId] low: low up:up];
   [_tracer addCommand: [ORFactory doubleLEqualc:self var:var leq: up]];
   [_tracer addCommand: [ORFactory doubleGEqualc:self var:var geq: low]];
}
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   [self restrictImpl: _gamma[var.getId] to: S];
}
-(void) labelBV: (id<ORBitVar>) var at:(ORUInt) i with:(ORBool)val
{
   [self labelBVImpl: (id<CPBitVar,CPBitVarNotifier>)_gamma[var.getId] at:i with: val];
}
-(void) realLabel: (id<ORRealVar>) var with: (ORDouble) val
{
   [self realLabelImpl:_gamma[var.getId] with:val];
}
-(void) realLthen: (id<ORRealVar>) var with: (ORDouble) val
{
   [self realLthenImpl: _gamma[var.getId] with: val];
}
-(void) realGthen: (id<ORRealVar>) var with: (ORDouble) val
{
   [self realGthenImpl: _gamma[var.getId] with: val];
}
//-------------------------------------------------------
-(void) genericSearch: (id<ORDisabledVarArray>) x selection:(ORSelectorResult(^)(void)) s do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   __block ORBool goon = YES;
   while(goon) {
      [_search probe:^{
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = s();
         if (!i.found){
            if(![x hasDisabled]){
               goon = NO;
               return;
            }else{
               do{
                  i.index = [x enableFirst];
               } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
               if([_gamma[getId(x[i.index])] bound]){
                  goon = NO;
                  return;
               }
            }
         } else if(_unique){
            if([x isFullyDisabled]){
               [x enableFirst];
            }
            [x disable:i.index];
         }
         id<CPVar> cx = _gamma[getId(x[i.index])];
         LOG(_level,2,@"selected variables: %@ %@",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],[cx domain]);
         b(i.index,x);
      }];
   }
}
-(void) searchWithCriteria:  (id<ORDisabledVarArray>) x criteria:(ORInt2Double)crit switchOnCondtion:(ORBool(^)(void))c criteria:(ORInt2Double)crit2 do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   ORInt2Bool f = ^(ORInt i) {
      id<CPVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) %@ bounded:%s fixed:%s occ=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],[v domain],([v bound])?"YES":"NO",([x isDisabled:i])?"YES":"NO",[_model occurences:x[i]]);
      return (ORBool)(![v bound] && [x isEnabled:i]);
   };
   id<ORSelect> select1 = [ORFactory select: _engine range: x.range suchThat: f orderedBy: crit];
   id<ORSelect> select2 = [ORFactory select: _engine range: x.range suchThat: f orderedBy: crit2];
   [self genericSearch:x selection:(ORSelectorResult(^)(void))^{
      return (c()) ? [select2 max] : [select1 max];
   } do:b];
}


-(void) searchWithCriteria:  (id<ORDisabledVarArray>) x criteria:(ORInt2Double)c do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   __block id<ORIdArray> abs = nil;
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
      id<CPVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) %@ bounded:%s fixed:%s occ=%16.16e abs=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],[v domain],([v bound])?"YES":"NO",([x isDisabled:i])?"YES":"NO",[_model occurences:x[i]],[abs[i] quantity]);
      return ![v bound] && [x isEnabled:i];
   }
                                 orderedBy: c
                          ];
   [self genericSearch:x selection:(ORSelectorResult(^)(void))^{
      ONLY_DEBUG(_level,2,abs = [self computeAbsorptionsQuantities:x]);
      return [select max];
   } do:b];
   
}
//float search
-(void) maxCardinalitySearch: (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      CPFloatVarI* v = _gamma[getId(x[i])];
      return cardinality(v);
   } do:b];
}
-(void) minCardinalitySearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      CPFloatVarI* v = _gamma[getId(x[i])];
      return -cardinality(v);
   } do:b];
}
-(void) maxDensitySearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return [self density:x[i]];
   } do:b];
}
-(void) minDensitySearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return -[self density:x[i]];
   } do:b];
}
-(void) maxWidthSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      return [v domwidth];
   } do:b];
}
-(void) minWidthSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      return -[v domwidth];
   } do:b];
}
-(void) maxMagnitudeSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      return [v magnitude];
   } do:b];
}
-(void) minMagnitudeSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      return -[v magnitude];
   } do:b];
}
-(void) lexicalOrderedSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return (ORDouble)i;
   } do:b];
}
// Branch & Bound on error of FloatVar
-(void) branchAndBoundSearch:  (id<ORDisabledVarArray>) x out: (id<ORRationalVar>) ez do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   TRInt _index;
   id<ORRational> tmp0 = [[ORRational alloc] init];
   id<ORRational> tmp1 = [[ORRational alloc] init];
   id<ORRational> tmp2 = [[ORRational alloc] init];
   id<ORRational> halfulp = [[ORRational alloc] init];
   [tmp0 autorelease];
   [tmp1 autorelease];
   [tmp2 autorelease];
   [halfulp autorelease];
   
   
   /* Variables used in GuessError */
   SolWrapper* tmp_solution = [[SolWrapper alloc] init:[self captureSolution]];
   NSMutableArray* arrayVarValueMin = [[NSMutableArray alloc] initWithCapacity:0];
   NSMutableArray* arrayVarValueMax = [[NSMutableArray alloc] initWithCapacity:0];
   NSMutableArray* arrayVarError = [[NSMutableArray alloc] initWithCapacity:0];
   
   id<CPProgram> cpGuessError = [ORFactory createCPProgram:_model];
   
   boundDiscardedBoxes = [[[ORRational alloc] init] setNegInf];
   branchAndBoundStart = [NSDate date];
   
   id<ORSelect> select = [ORFactory select: _engine // need to be out of inner loop to go through all possible variables
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e] bounded:%s ",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max,([v bound])?"YES":"NO");
      return ![v bound];
   }
                                 orderedBy:
                          ^ORDouble(ORInt i) {
      return (ORDouble)i;
   }
                          ];
   
   id<ORSelect> guess_select = [ORFactory select: [cpGuessError engine] // need to be out of inner loop to go through all possible variables
                                           range: RANGE(self,[x low],[x up])
                                        suchThat: ^ORBool(ORInt i) {
      id<CPFloatVar> v = [cpGuessError concretize:x[i]];
      LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e] bounded:%s ",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max,([v bound])?"YES":"NO");
      return ![v bound];
   }
                                       orderedBy:
                                ^ORDouble(ORInt i) {
      return (ORDouble)i;
   }
                                ];
   
   assignTRInt(&_index, [select min].index, _trail);
   do {
      [self errorGEqualImpl:_gamma[getId(ez)] with:[[[_engine objective] primalBound] rationalValue]];
      [[_engine objective] updateDualBound];
      
      ORBool isBound = true;
      id<CPFloatVar> xc;
      for (id<ORFloatVar> v in x) { // Only check that abstract floating point variables are bound
         xc = _gamma[v.getId];
         isBound &= [xc bound];
      }
      if(isBound){
         if([[[[_engine objective] primalBound] rationalValue] lt: [[[_engine objective] primalValue] rationalValue]]){ // Check that it is a better solution   <=========== !
            [[_engine objective] updatePrimalBound];
            [_sPool addSolution:[self captureSolution]]; // Keep it as a solution
            [tmp_solution print:[_model variables] with:[_sPool objectAtIndexedSubscript:[_sPool count] - 1] for:@"Bounded Box"];
         }
         break;
      } else {
         /* ********* GuessError ********* */
         LOG(_level, 2, @"Starting GuessError");
         for(id<ORFloatVar> v in x){
            id<CPFloatVar> vC = _gamma[[v getId]];
            [arrayVarValueMin addObject:[NSNumber numberWithFloat:[vC min]]];
            [arrayVarValueMax addObject:[NSNumber numberWithFloat:[vC max]]];
            id<ORRationalInterval> vError = [[ORRationalInterval alloc] init];
            [vError set_q:[vC minErr] and:[vC maxErr]];
            [arrayVarError addObject:vError];
         }
         
         ORInt iteration = 0;
         ORInt nbIteration = -1;
         if([((id<ORRational>)[[[_engine objective] primalBound] rationalValue]) lt: [[[ORRational alloc] init] setZero]]){
            nbIteration = 30;
         } else {
            nbIteration = 20;
         }
         
         IS_GUESS_ERROR_SOLVER = true;
         while(iteration < nbIteration){
            [cpGuessError solve:^()
             {
               ORStatus isFailed = ORSuccess;
               ORSelectorResult index = [guess_select min];
               id<ORRationalInterval> currentVarError = [[ORRationalInterval alloc] init];
               do {
                  id<CPFloatVar> currentVar = [cpGuessError concretize:x[index.index]];
                  ORFloat currentVarMin = [[arrayVarValueMin objectAtIndex:index.index] doubleValue];
                  ORFloat currentVarMax = [[arrayVarValueMax objectAtIndex:index.index] doubleValue];
                  [currentVarError set:[arrayVarError objectAtIndex:index.index]];
                  LOG(_level,2, @"Choosen var: %@",currentVar);
                  if(![currentVar bound]){
                     ORFloat v;
                     v = randomValueD(currentVarMin, currentVarMax);
                     if([currentVar isInputVar]) {
                        [tmp0 set_d: nextafter(v, +INFINITY)];
                        [tmp1 set_d: v];
                        [tmp0 set: [tmp0 sub: tmp1]];
                        [tmp1 set_d: 2.0];
                        [tmp2 set: [tmp0 div: tmp1]];
                        if (drand48() < 0.5) {
                           [halfulp set:[tmp2 neg]];
                        } else {
                           [halfulp set:tmp2];
                        }
                        if ([halfulp lt: [currentVarError low]])
                           [halfulp set: [currentVarError low]];
                        if ([halfulp gt: [currentVarError up]])
                           [halfulp set: [currentVarError up]];
                     }
                     if([currentVar isInputVar])
                        isFailed = [[cpGuessError engine] enforce:^{ [currentVar bind:v]; [currentVar bindError:halfulp];}];
                     else
                        isFailed = [[cpGuessError engine] enforce:^{ [currentVar bind:v];}];
                  }
                  index = [guess_select min];
               } while(index.found);
               [currentVarError release];
               
               if((isFailed != ORFailure) && [[[[[cpGuessError engine] objective] primalValue] rationalValue] gt: [[[tmp_solution get] value:ez] rationalValue]]){
                  [tmp_solution set: [cpGuessError captureSolution]];
                  [tmp_solution print:[_model variables] for:[NSString stringWithFormat:@"GuessError %d/%d", iteration, nbIteration]];
               }
            }];
            iteration++;
         }
         IS_GUESS_ERROR_SOLVER = false;
         [arrayVarValueMin removeAllObjects];
         [arrayVarValueMax removeAllObjects];
         [arrayVarError removeAllObjects];
         
         if ([[[[_engine objective] primalBound] rationalValue] lt: [[[tmp_solution get] value:ez] rationalValue]]) {
            id<ORObjectiveValue> objv = [ORFactory objectiveValueRational:[[[tmp_solution get] value:ez] rationalValue] minimize:FALSE];
            [[_engine objective] tightenPrimalBound:objv];
            [_sPool addSolution:[tmp_solution get]];
         }
         
         LOG(_level, 2, @"Ending GuessError");
         /******************************/
         
         /* When a new box is discarded, boundDiscardedBoxes is updated with the maximal error upper bound of all discarded boxes */
         if(RUN_DISCARDED_BOX){
            if(limitCounter._val >= nbConstraint){
               if([[[[_engine objective] dualValue] rationalValue] gt: boundDiscardedBoxes])
                  [boundDiscardedBoxes set:[[[_engine objective] dualValue] rationalValue]];
               
               break;
            }
         }
         
         /* Do not split current box if primalBound is greater than or equal to its local error upper bound or if local error upper bound is less than or equal to the maximal error upper bound of discarded boxes
          */
         if ([[[[_engine objective] primalBound] rationalValue] geq: [[[_engine objective] dualValue] rationalValue]]) break;
         if (RUN_DISCARDED_BOX && ![boundDiscardedBoxes isNegInf] && [[[[_engine objective] dualValue] rationalValue] lt: boundDiscardedBoxes]) break;
         
         
         /* call b to use splitting strategy passed as parameter of branchAndBoundSearch */
         ORSelectorResult i = [select min]; // select variable minimizing criteria from defined in select
         ORSelectorResult I = [select max]; // select variable maximizing criteria from defined in select
         
         b(_index._val, x);
         
         /* update index of variable chosen for splitting */
         if (_index._val + 1 > I.index)
            assignTRInt(&_index, i.index, _trail);
         else
            assignTRInt(&_index, _index._val+1, _trail);
      }
   } while ([[[[_engine objective] primalBound] rationalValue] lt: [[[_engine objective] dualBound] rationalValue]]);
   
}

-(void) branchAndBoundSearchD:  (id<ORDisabledVarArray>) x out: (id<ORRationalVar>) ez do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   TRInt _index;
   id<ORRational> tmp0 = [[ORRational alloc] init];
   id<ORRational> tmp1 = [[ORRational alloc] init];
   id<ORRational> tmp2 = [[ORRational alloc] init];
   id<ORRational> halfulp = [[ORRational alloc] init];
   [tmp0 autorelease];
   [tmp1 autorelease];
   [tmp2 autorelease];
   [halfulp autorelease];
   
   /* Variables used in GuessError */
   SolWrapper* tmp_solution = [[SolWrapper alloc] init:[self captureSolution]];
   NSMutableArray* arrayVarValueMin = [[NSMutableArray alloc] initWithCapacity:0];
   NSMutableArray* arrayVarValueMax = [[NSMutableArray alloc] initWithCapacity:0];
   NSMutableArray* arrayVarError = [[NSMutableArray alloc] initWithCapacity:0];
   
   IS_GUESS_ERROR_SOLVER = true;
   id<CPProgram> cpGuessError = [ORFactory createCPProgram:_model];
   IS_GUESS_ERROR_SOLVER = false;
   
   boundDiscardedBoxes = [[[ORRational alloc] init] setNegInf];
   branchAndBoundStart = [NSDate date];
   
   id<ORSelect> select = [ORFactory select: _engine // need to be out of inner loop to go through all possible variables
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
      id<CPDoubleVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e] bounded:%s ",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max,([v bound])?"YES":"NO");
      return ![v bound];
   }
                                 orderedBy:
                          ^ORDouble(ORInt i) {
      return (ORDouble)i;
   }
                          ];
   
   id<ORSelect> guess_select = [ORFactory select: [cpGuessError engine] // need to be out of inner loop to go through all possible variables
                                           range: RANGE(self,[x low],[x up])
                                        suchThat: ^ORBool(ORInt i) {
      id<CPDoubleVar> v = [cpGuessError concretize:x[i]];
      LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e] bounded:%s ",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max,([v bound])?"YES":"NO");
      return ![v bound];
   }
                                       orderedBy:
                                ^ORDouble(ORInt i) {
      return (ORDouble)i;
   }
                                ];
   
   assignTRInt(&_index, [select min].index, _trail);
   do {
      [self errorGEqualImpl:_gamma[getId(ez)] with:[[[_engine objective] primalBound] rationalValue]];
      [[_engine objective] updateDualBound];
      
      ORBool isBound = true;
      id<CPDoubleVar> xc;
      for (id<ORDoubleVar> v in x) { // Only check that abstract floating point variables are bound
         xc = _gamma[v.getId];
         isBound &= [xc bound];
      }
      
      if(isBound){
         if([[[[_engine objective] primalBound] rationalValue] lt: [[[_engine objective] primalValue] rationalValue]]){
            [[_engine objective] updatePrimalBound];
            [_sPool addSolution:[self captureSolution]]; // Keep it as a solution
            [tmp_solution print:[_model variables] with:[_sPool objectAtIndexedSubscript:[_sPool count] - 1] for:@"Bounded Box"];
         }
         break; // branch-and-bound stop exploring current box
      } else {
         /* ********* GuessError ********* */
         LOG(_level, 2, @"Starting GuessError");
         for(id<ORDoubleVar> v in x){
            id<CPDoubleVar> vC = _gamma[[v getId]];
            [arrayVarValueMin addObject:[NSNumber numberWithDouble:[vC min]]];
            [arrayVarValueMax addObject:[NSNumber numberWithDouble:[vC max]]];
            id<ORRationalInterval> vError = [[ORRationalInterval alloc] init];
            [vError set_q:[vC minErr] and:[vC maxErr]];
            [arrayVarError addObject:vError];
         }
         
         ORInt iteration = 0;
         ORInt nbIteration = -1;
         if([((id<ORRational>)[[[_engine objective] primalBound] rationalValue]) lt: [[[ORRational alloc] init] setZero]]){
            nbIteration = 30;
         } else {
            nbIteration = 20;
         }
         
         IS_GUESS_ERROR_SOLVER = true;
         while(iteration < nbIteration){
            [cpGuessError solve:^()
             {
               id<ORSolution> tmp_solution_improve;
               ORStatus isFailed = ORSuccess;
               ORSelectorResult index = [guess_select min];
               id<ORRationalInterval> currentVarError = [[ORRationalInterval alloc] init];
               [[cpGuessError tracer] pushNode];
               do {
                  id<CPDoubleVar> currentVar = [cpGuessError concretize:x[index.index]];
                  ORDouble currentVarMin = [[arrayVarValueMin objectAtIndex:index.index] doubleValue];
                  ORDouble currentVarMax = [[arrayVarValueMax objectAtIndex:index.index] doubleValue];
                  [currentVarError set:[arrayVarError objectAtIndex:index.index]];
                  LOG(_level,2, @"Choosen var: %@",currentVar);
                  if(![currentVar bound]){
                     ORDouble v;
                     v = randomValueD(currentVarMin, currentVarMax);
                     if([currentVar isInputVar]) {
                        [tmp0 set_d: nextafter(v, +INFINITY)];
                        [tmp1 set_d: v];
                        [tmp0 set: [tmp0 sub: tmp1]];
                        [tmp1 set_d: 2.0];
                        [tmp2 set: [tmp0 div: tmp1]];
                        if (drand48() < 0.4) {
                           [halfulp set:[tmp2 neg]];
                        } else {
                           [halfulp set:tmp2];
                        }
                        if ([halfulp lt: [currentVarError low]])
                           [halfulp set: [currentVarError low]];
                        if ([halfulp gt: [currentVarError up]])
                           [halfulp set: [currentVarError up]];
                     }
                     if([currentVar isInputVar])
                        isFailed = [[cpGuessError engine] enforce:^{ [currentVar bind:v]; [currentVar bindError:halfulp];}];
                     else
                        isFailed = [[cpGuessError engine] enforce:^{ [currentVar bind:v];}];
                  }
                  index = [guess_select min];
               } while(index.found);
               
               if (RUN_IMPROVE_GUESS) {
                  tmp_solution_improve = [cpGuessError captureSolution];
                  [[cpGuessError tracer] popNode];
                  id<CPDoubleVar> xc;
                  ORBool improved = FALSE, improved_var = FALSE;
                  ORInt nvar = 0, nv, nbiter = 0;
                  ORInt direction = 1;
                  ORStatus s;
                  while (nbiter < 200) {
                     [[cpGuessError tracer] pushNode];
                     nbiter++;
                     nv = 0;
                     index = [guess_select min];
                     do {
                        id<ORDoubleVar> v = (id<ORDoubleVar>) x[index.index];
                        xc = [cpGuessError concretize:v];
                        nv++;
                        if (![xc bound]) {
                           ORDouble value = [[tmp_solution_improve value:v] doubleValue];
                           [currentVarError set_q:[_gamma[v.getId] minErr] and:[_gamma[v.getId] maxErr]];
                           if (nv == nvar)
                              value = nextafter(value, (direction == 1) ? (+INFINITY) : (-INFINITY));
                           if([xc isInputVar]){
                              [tmp0 set_d: nextafter(value, +INFINITY)];
                              [tmp1 set_d: value];
                              [tmp0 set: [tmp0 sub: tmp1]];
                              [tmp1 set_d: 2.0];
                              [tmp2 set: [tmp0 div: tmp1]];
                              if (drand48() < 0.4) {
                                 [halfulp set:[tmp2 neg]];
                              } else {
                                 [halfulp set:tmp2];
                              }
                              if ([halfulp lt: [currentVarError low]])
                                 [halfulp set: [currentVarError low]];
                              if ([halfulp gt: [currentVarError up]])
                                 [halfulp set: [currentVarError up]];
                              
                              s = [[cpGuessError engine] enforce:^{ [xc bind:value];  [xc bindError:halfulp];}];
                           } else {
                              s = [[cpGuessError engine] enforce:^{ [xc bind:value];}];
                           }
                           if (s == ORFailure)
                              break;
                        }
                        index = [guess_select min];
                     } while(index.found);
                     id<CPRationalVar> ezi = [cpGuessError concretize:ez];
                     if ((s != ORFailure) && ([[[tmp_solution_improve value:ez] rationalValue] lt: [ezi min]])) { // Better err
                        tmp_solution_improve = [cpGuessError captureSolution];
                        improved_var = TRUE;
                        improved = TRUE;
                     } else {
                        if ((!improved_var) && (direction == 1)) {
                           direction = -1;
                        } else {
                           direction = 1;
                           improved_var = FALSE;
                           nv = 0;
                           ORInt old_nvar = nvar;
                           for (id<ORDoubleVar> v in x) {
                              xc = [cpGuessError concretize:v];
                              nv++;
                              if ((nv > nvar) && (![xc bound])) {
                                 nvar = nv;
                                 break;
                              }
                           }
                           if (nvar == old_nvar)
                              break;
                        }
                     }
                     [[cpGuessError tracer] popNode];
                  }
               } else {
                  tmp_solution_improve = [cpGuessError captureSolution];
               }
               
               if((isFailed != ORFailure) && [[[tmp_solution_improve value:ez] rationalValue] gt: [[[tmp_solution get] value:ez] rationalValue]]){
                  [tmp_solution set: tmp_solution_improve];
                  [tmp_solution print:[_model variables] for:[NSString stringWithFormat:@"GuessError %d/%d", iteration, nbIteration]];
               }
               [currentVarError release];
            }];
            iteration++;
         }
         IS_GUESS_ERROR_SOLVER = false;
         [arrayVarValueMin removeAllObjects];
         [arrayVarValueMax removeAllObjects];
         [arrayVarError removeAllObjects];
         
         if ([[[[_engine objective] primalBound] rationalValue] lt: [[[tmp_solution get] value:ez] rationalValue]]) {
            id<ORObjectiveValue> objv = [ORFactory objectiveValueRational:[[[tmp_solution get] value:ez] rationalValue] minimize:FALSE];
            [[_engine objective] tightenPrimalBound:objv];
            //[solution set: [tmp_solution get]];
            [_sPool addSolution:[tmp_solution get]];
         }
         
         LOG(_level, 2, @"Ending GuessError");
         /* ********* End GuessError ********* */
         
         /* When a new box is discarded, boundDiscardedBoxes is updated with the maximal error upper bound of all discarded boxes */
         if(RUN_DISCARDED_BOX){
            if(limitCounter._val >= nbConstraint){
               if([[[[_engine objective] dualValue] rationalValue] gt: boundDiscardedBoxes])
                  [boundDiscardedBoxes set:[[[_engine objective] dualValue] rationalValue]];
               
               break;
            }
         }
         
         /* Do not split current box if primalBound is greater than or equal to its local error upper bound or if local error upper bound is less than or equal to the maximal error upper bound of discarded boxes
          */
         if ([[[[_engine objective] primalBound] rationalValue] geq: [[[_engine objective] dualValue] rationalValue]]) break;
         if (RUN_DISCARDED_BOX && ![boundDiscardedBoxes isNegInf] && [[[[_engine objective] dualValue] rationalValue] lt: boundDiscardedBoxes]) break;
         
         
         /* call b to use splitting strategy passed as parameter of branchAndBoundSearch */
         ORSelectorResult i = [select min]; // select variable minimizing criteria from defined in select
         ORSelectorResult I = [select max]; // select variable maximizing criteria from defined in select
         
         b(_index._val, x);
         
         /* update index of variable chosen for splitting */
         if (_index._val + 1 > I.index)
            assignTRInt(&_index, i.index, _trail);
         else
            assignTRInt(&_index, _index._val+1, _trail);
      }
   } while ([[[[_engine objective] primalBound] rationalValue] lt: [[[_engine objective] dualBound] rationalValue]]);
}

//-------------------------------------------------
-(void) maxDegreeSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return (ORDouble)[self countMemberedConstraints:x[i]];
   } do:b];
}
-(void) minDegreeSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return (ORDouble)(-[self countMemberedConstraints:x[i]]);
   } do:b];
}
-(void) maxOccurencesRatesSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return [_model occurences:x[i]];
   } do:b];
}
-(void) maxOccurencesSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return [self maxOccurences:x[i]];
   } do:b];
}
-(void) minOccurencesSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return -[self maxOccurences:x[i]];
   } do:b];
}
//----------Special search--------//
-(void) specialSearchStatic:  (id<ORDisabledVarArray>) x
{
   __block id<ORIdArray> abs = [self computeAbsorptionsQuantities:x];
   __block id<ORIntArray> occ = [self computeAllOccurrences:x];
   __block ORDouble sum = (ORDouble)[occ sum];
   __block ORDouble ao, aa;
   ORDouble so = 0.0;
   ORDouble sa = 0.0;
   ORInt nb = 0;
   for(ORUInt i = 0; i < [x count]; i++){
      id<CPFloatVar> v = _gamma[getId(x[i])];
      if ([v bound]) continue;
      if(([x isInitial:i] && [abs[i] quantity] >= _absTRateLimitModelVars) || (![x isInitial:i] && [abs[i] quantity] >= _absTRateLimitAdditionalVars)){
         sa += [abs[i] quantity];
      }
      so += [occ at:i]/sum;
      nb++;
      NSLog(@"abs %16.16e s:%16.16e",[abs[i] quantity],sa);
      NSLog(@"occ %16.16e s:%16.16e",[occ at:i]/sum,so);
   }
   ao = (nb) ? so / nb : 0;
   aa = (nb) ? sa / nb : 0;
   NSLog(@"ao:%16.16e aa:%16.16e",ao,aa);
   if(ao < 0.1 && aa < 0.1){
      NSLog(@"search selected : maxDens");
      [self maxDensitySearch:x  do:^(ORUInt i,id<ORDisabledVarArray> x) {
         [self float5WaySplit:i withVars:x];
      }];
   }else if(ao > aa){
      NSLog(@"search selected : maxOcc");
      [self maxOccurencesRatesSearch:x  do:^(ORUInt i,id<ORDisabledVarArray> x) {
         [self float5WaySplit:i withVars:x];
      }];
   }else{
      NSLog(@"search selected : maxAbs");
      [self maxAbsorptionSearch:x default:^(ORUInt i, id<ORDisabledVarArray> x) {
         [self float5WaySplit:i withVars:x];
      }];
   }
}

-(void) specialSearch:  (id<ORDisabledVarArray>) x
{
   __block id<ORIdArray> abs = nil;
   __block id<ORIntArray> occ = nil;
   __block ORDouble sum, ao, aa, so, sa;
   __block ORInt nb,nb2;
   
   ORInt2Bool f = ^(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      return (ORBool)(![v bound] && [x isEnabled:i]);
   };
   
   id<ORSelect> select_a = [ORFactory select: _engine range: x.range suchThat: f
                                   orderedBy: ^ORDouble(ORInt i) {
      if(([x isInitial:i] && [abs[i] quantity] >= _absTRateLimitModelVars) || (![x isInitial:i] && [abs[i] quantity] >= _absTRateLimitAdditionalVars)){
         return [abs[i] quantity];
      }else{
         return 0.0;
      }
   }
                            ];
   id<ORSelect> select_o = [ORFactory select: _engine range: x.range suchThat: f
                                   orderedBy: ^ORDouble(ORInt i) {
      return (!sum) ? 0.0 : ((ORDouble)[occ at:i]) / sum;
   }
                            ];
   id<ORSelect> select_c = [ORFactory select: _engine range: x.range suchThat: f
                                   orderedBy: ^ORDouble(ORInt i) {
      ORDouble card = [self cardinality:x[i]];
      return card;
   }
                            ];
   
   id<ORSelect> select_d = [ORFactory select: _engine range: x.range suchThat: f
                                   orderedBy: ^ORDouble(ORInt i) {
      ORDouble dens = [self density:x[i]];
      return dens;
   }
                            ];
   id<ORSelect> select_l = [ORFactory  select: _engine range: x.range suchThat: f
                                    orderedBy: ^ORDouble(ORInt i) {
      return i;
   }
                            ];
   
   __block ORBool goon = YES;
   __block ORBool choice;
   while(goon) {
      [_search try:^{
         abs = [self computeAbsorptionsQuantities:x];
         occ = [self computeAllOccurrences:x];
         sum = (ORDouble)[occ sum];
         so = 0.0;
         sa = 0.0;
         nb = 0;
         nb2 = 0;
         choice = NO;
         LOG(_level,2,@"State before selection");
         for(ORUInt i = 0; i < [x count]; i++){
            id<CPFloatVar> v = _gamma[getId(x[i])];
            ORDouble card = [self cardinality:x[i]];
            ORDouble dens = [self density:x[i]];
            LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e] bounded:%s fixed:%s  rate : abs=%16.16e  occ=%16.16e card=%16.16e dens=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max,([v bound])?"YES":"NO",([x isDisabled:i])?"YES":"NO",[abs[i] quantity],(sum==0)? 0.0 : ((ORDouble)[occ at:i]) / sum, card,dens);
            if ([v bound] || [x isDisabled:i]) continue;
            if(([x isInitial:i] && [abs[i] quantity] >= _absTRateLimitModelVars) || (![x isInitial:i] && [abs[i] quantity] >= _absTRateLimitAdditionalVars)){
               sa += [abs[i] quantity];
            }
            so += [occ at:i]/sum;
            nb++;
            LOG(_level,3,@"abs %16.16e s:%16.16e",[abs[i] quantity],sa);
            LOG(_level,3,@"occ %16.16e s:%16.16e",[occ at:i]/sum,so);
         }
         ao = (nb) ? so / nb : 0;
         aa = (nb) ? sa / nb : 0;
         ORSelectorResult i;
         if(nb == 0){
            i = (ORSelectorResult) {NO,0};
            LOG(_level, 2, @"all free variables are bounded");
         }else{
            LOG(_level,2,@"average_occ:%16.16e average_abs:%16.16e",ao,aa);
            if(ao < _occRate && aa < _absRate){
               switch (_variationSearch) {
                  case 15:
                     LOG(_level,2,@"selected search : minDens");
                     i = [select_d min];
                     break;
                  case 14:
                     LOG(_level,2,@"selected search : maxDens");
                     i = [select_d max];
                     break;
                  case 29:
                     LOG(_level,2,@"selected search : lex");
                     i = [select_l min];
                     break;
                  default:
                     LOG(_level,2,@"selected search : mincard");
                     i = [select_c min];
                     break;
               }
            }else if(aa > fp_next_float(ao)){
               LOG(_level,2,@"selected search : maxAbs");
               i = [select_a max];
               choice = YES;
            }else{
               LOG(_level,2,@"selected search : maxOcc");
               i = [select_o max];
            }
         }
         if (!i.found){
            if(![x hasDisabled]){
               goon = NO;
               return;
            }else{
               do{
                  i.index = [x enableFirst];
               } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
               if([_gamma[getId(x[i.index])] bound]){
                  goon = NO;
                  return;
               }
            }
         } else if(_unique){
            if([x isFullyDisabled]){
               [x enableFirst];
            }
            [x disable:i.index];
         }
         id<CPVar> cx = _gamma[getId(x[i.index])];
         if(choice){
            id<CPVar> v = [abs[i.index] bestChoice];
            if(v != nil){
               LOG(_level,2,@"selected variables: %@ %@ bounded:%s and %@ %@ bounded:%s",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx,([cx bound])?"YES":"NO",[NSString stringWithFormat:@"var<%d>", [v getId]],v,([v bound])?"YES":"NO");
            }else{
               LOG(_level,2,@"selected variables: %@ %@ bounded:%s and no other variable to split with",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx,([cx bound])?"YES":"NO");
            }
            [self floatAbsSplit:i.index by:v withVars:x default:^(ORUInt i,id<ORDisabledVarArray> x) {
               [self float5WaySplit:i withVars:x];
            }];
         }else{
            LOG(_level,2,@"selected variables: %@  %@ bounded:%s",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx,([cx bound])?"YES":"NO");
            [self float5WaySplit:i.index withVars:x];
         }
      } alt:^{
      }];
   }
}
-(void) maxAbsorptionSearchAll: (id<ORDisabledVarArray>) x default:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   @autoreleasepool {
      __block id<ORIdArray> abs = nil;
      //[hzi] just for experiments
      __block id<ORIntArray> occ;
      __block ORInt sum;
      id<ORSelect> select = [ORFactory select: _engine
                                        range: RANGE(self,[x low],[x up])
                                     suchThat: ^ORBool(ORInt i) {
         id<CPFloatVar> v = _gamma[getId(x[i])];
         return ![v bound] && [x isEnabled:i];
      }
                                    orderedBy: ^ORDouble(ORInt i) {
         id<CPFloatVar> v = _gamma[getId(x[i])];
         LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e] isInitial ? %s rate : abs=%16.16e  occ=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max, [x isInitial:i]?"YES":"NO",[abs[i] quantity],(sum==0)? 0.0 : ((ORDouble)[occ at:i]) / sum);
         if(([x isInitial:i] && [abs[i] quantity] >= _absTRateLimitModelVars) || (![x isInitial:i] && [abs[i] quantity] >= _absTRateLimitAdditionalVars)){
            return [abs[i] quantity];
         }else{
            return 0.0;
         }
      }
                             ];
      __block ORBool goon = YES;
      while(goon) {
         [_search try:^{
            abs = [self computeAbsorptionsQuantities:x];
            occ = [self computeAllOccurrences:x];
            sum = [occ sum];
            LOG(_level,2,@"State before selection");
            ORSelectorResult i = [select max];
            if (!i.found){
               if(![x hasDisabled]){
                  goon = NO;
                  return;
               }else{
                  do{
                     i.index = [x enableFirst];
                  } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
                  if([_gamma[getId(x[i.index])] bound]){
                     goon = NO;
                     return;
                  }
               }
            } else if(_unique){
               if([x isFullyDisabled]){
                  [x enableFirst];
               }
               [x disable:i.index];
            }
            if([abs[i.index] quantity] == 0.0){
               LOG(_level,1,@"current search has switched");
               //[hzi] just for experiments
               //after experiments shoulds be cleaner
               switch (_variationSearch) {
                  case 0:
                     [self lexicalOrderedSearch:[x initialVars:_engine maxFixed:1]  do:^(ORUInt i,id<ORDisabledVarArray> x) {
                        [self float6WaySplit:i withVars:x];
                     }];
                     break;
                  case 1:
                     [self maxDensitySearch:[x initialVars:_engine maxFixed:1]  do:^(ORUInt i,id<ORDisabledVarArray> x) {
                        [self float6WaySplit:i withVars:x];
                     }];
                     break;
                  case 2:
                     [self maxOccurencesSearch:[x initialVars:_engine maxFixed:1]  do:^(ORUInt i,id<ORDisabledVarArray> x) {
                        [self float6WaySplit:i withVars:x];
                     }];
                     break;
                  case 3:
                     [self maxOccurencesRatesSearch:[x initialVars:_engine maxFixed:1]  do:^(ORUInt i,id<ORDisabledVarArray> x) {
                        [self float6WaySplit:i  withVars:x];
                     }];
                  case 4:
                  default:
                     [self maxOccurencesRatesSearch:[x initialVars:_engine maxFixed:1]  do:^(ORUInt i,id<ORDisabledVarArray> x) {
                        [self float5WaySplit:i withVars:x];
                     }];
               }
               
            }else{
               id<CPVar> v = [abs[i.index] bestChoice];
               id<CPVar> cx = _gamma[getId(x[i.index])];
               LOG(_level,3,@"selected variables: %@ and %@",cx,v);
               LOG(_level,2,@"selected variables: %@ %@ and %@ %@",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx,[NSString stringWithFormat:@"var<%d>", [v getId]],v);
               
               [self floatAbsSplit:i.index by:v withVars:x default:b];
               
            }
         } alt:^{}];
      }
   }
}
-(void) customSearch:  (id<ORDisabledVarArray>) x
{
   __block id<ORIdArray> abs = nil;
   __block ORInt nb;
   id<ORSelect> select_a = [ORFactory select: _engine
                                       range: x.range
                                    suchThat: ^ORBool(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e]  bounded:%s fixed:%s rate : abs=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max, [v bound]?"YES":"NO", [x isDisabled:i]?"YES":"NO",[abs[i] quantity]);
      nb += ![v bound];
      return ![v bound] && [x isEnabled:i] && [abs[i] quantity] >= _absTRateLimitModelVars && [abs[i] quantity] != 0.0;
   }
                                   orderedBy: ^ORDouble(ORInt i) {
      return [abs[i] quantity];
   }
                            ];
   __block ORBool goon = YES;
   while(goon) {
      [_search probe:^{
         abs = [self computeAbsorptionsQuantities:x];
         nb = 0;
         ORSelectorResult i = [select_a max];
         if(i.found){
            LOG(_level,1,@"maxAbs");
            [x disable:i.index];
            id<CPVar> cx = _gamma[getId(x[i.index])];
            id<CPVar> v = [abs[i.index] bestChoice];
            LOG(_level,2,@"selected variables: %@ %@ bounded:%s and %@ %@ bounded:%s",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx,([cx bound])?"YES":"NO",[NSString stringWithFormat:@"var<%d>", [v getId]],v,([v bound])?"YES":"NO");
            [self floatAbsSplit:i.index by:v vars:x];
         } else{
            if(nb == 0){
               goon = NO;
               return;
            }
            LOG(_level,1,@"current search has switched");
            [self maxOccurencesRatesSearch:[x initialVars:_engine maxFixed:_unique]  do:^(ORUInt i,id<ORDisabledVarArray> x) {
               [self float5WaySplit:i withVars:x];
            }];
         }
      }];
   }
}
-(void) customSearchD:  (id<ORDisabledVarArray>) x
{
   __block id<ORIdArray> abs = nil;
   __block ORInt nb;
   id<ORSelect> select_occ = [ORFactory select: _engine
                                         range: x.range
                                      suchThat: ^ORBool(ORInt i) {
      id<CPVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) %@  bounded:%s fixed:%s rate : occ=%16.16e abs=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v, [v bound]?"YES":"NO", [x isDisabled:i]?"YES":"NO",[_model occurences:x[i]],[abs[i] quantity]);
      nb += ![v bound];
      return ![v bound] && [x isEnabled:i];
   }
                                     orderedBy: ^ORDouble(ORInt i) {
      return [_model occurences:x[i]];
   }
                              ];
   id<ORSelect> select_abs = [ORFactory select: _engine
                                         range: x.range
                                      suchThat: ^ORBool(ORInt i) {
      id<CPVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) %@  bounded:%s fixed:%s rate : occ=%16.16e abs=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v, [v bound]?"YES":"NO", [x isDisabled:i]?"YES":"NO",[_model occurences:x[i]],[abs[i] quantity]);
      nb += ![v bound];
      return ![v bound] && [x isEnabled:i] && [abs[i] quantity] >= _absTRateLimitModelVars && [abs[i] quantity] != 0.0  && [abs[i] quantity] != 1.0;
   }
                                     orderedBy: ^ORDouble(ORInt i) {
      return [abs[i] quantity];
   }
                              ];
   __block ORBool goon = YES;
   while(goon) {
      [_search probe: ^{
         LOG(_level,2,@"State before selection");
         abs = [self computeAbsorptionsQuantities:x];
         ORBool c = NO;
         for (ORInt i = 0; i < [abs count]; i++) {
            id<CPFloatVar> v = _gamma[getId(x[i])];
            if(![v bound] && [x isEnabled:i] && [abs[i] quantity] >= _absTRateLimitModelVars && [abs[i] quantity] != 0.0 && [abs[i] quantity] != 1.0){
               c = YES;
               break;
            }
         }
         ORSelectorResult i;
         if(c){
            LOG(_level,1,@"maxAbs");
            //            NSLog(@"ICI");
            i = [select_abs max];
         }else{
            LOG(_level,1,@"maxOcc");
            i = [select_occ max];
         }
         if (!i.found){
            if(![x hasDisabled]){
               goon = NO;
               return;
            }else{
               do{
                  i.index = [x enableFirst];
               } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
               if([_gamma[getId(x[i.index])] bound]){
                  goon = NO;
                  return;
               }
            }
         } else if(_unique){
            if([x isFullyDisabled]){
               [x enableFirst];
            }
            [x disable:i.index];
         }
         id<CPVar> cx = _gamma[getId(x[i.index])];
         if(c){
            id<CPVar> v = [abs[i.index] bestChoice];
            LOG(_level,2,@"selected variables: %@ %@ bounded:%s and %@ %@ bounded:%s",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx,([cx bound])?"YES":"NO",[NSString stringWithFormat:@"var<%d>", [v getId]],v,([v bound])?"YES":"NO");
            [self floatAbsSplit:i.index by:v vars:x];
         }else{
            LOG(_level,2,@"selected variables: %@ %@",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx);
            [self float5WaySplit:i.index withVars:x];
         }
      }];
   }
}

-(void) customSearchWeightedD:  (id<ORDisabledVarArray>) x
{
   __block id<ORIdArray> abs = nil;
   __block ORInt nb;
   __block ORInt maxNbAbs;
   id<ORSelect> select_occ = [ORFactory select: _engine
                                         range: x.range
                                      suchThat: ^ORBool(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e]  bounded:%s fixed:%s rate : occ=%16.16e abs=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max, [v bound]?"YES":"NO", [x isDisabled:i]?"YES":"NO",[_model occurences:x[i]],[abs[i] quantity]);
      nb += ![v bound];
      return ![v bound] && [x isEnabled:i];
   }
                                     orderedBy: ^ORDouble(ORInt i) {
      return [_model occurences:x[i]];
   }
                              ];
   id<ORSelect> select_abs = [ORFactory select: _engine
                                         range: x.range
                                      suchThat: ^ORBool(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e]  bounded:%s fixed:%s rate : occ=%16.16e abs=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max, [v bound]?"YES":"NO", [x isDisabled:i]?"YES":"NO",[_model occurences:x[i]],([abs[i] quantity] > 0.0)?[abs[i] quantity]*[abs[i] nbAbs]/maxNbAbs:[abs[i] quantity]);
      nb += ![v bound];
      return ![v bound] && [x isEnabled:i] && [abs[i] quantity] >= _absTRateLimitModelVars && [abs[i] quantity] != 0.0  && [abs[i] quantity] != 1.0;
   }
                                     orderedBy: ^ORDouble(ORInt i) {
      return ([abs[i] quantity] > 0.0)?[abs[i] quantity]*[abs[i] nbAbs]/maxNbAbs:[abs[i] quantity];
   }
                              ];
   __block ORBool goon = YES;
   while(goon) {
      [_search probe:^{
         LOG(_level,2,@"State before selection");
         maxNbAbs = 1;
         abs = [self computeAbsorptionsQuantities:x];
         ORBool c = NO;
         for (ORInt i = 0; i < [abs count]; i++) {
            id<CPFloatVar> v = _gamma[getId(x[i])];
            if(![v bound] && [x isEnabled:i] && [abs[i] quantity] >= _absTRateLimitModelVars && [abs[i] quantity] != 0.0 && [abs[i] quantity] != 1.0){
               c = YES;
               maxNbAbs = max(maxNbAbs,[abs[i] nbAbs]);
               //               break;
            }
         }
         ORSelectorResult i ;
         if(c){
            LOG(_level,1,@"maxAbs");
            i = [select_abs max];
         }else{
            LOG(_level,1,@"maxOcc");
            i = [select_occ max];
         }
         if (!i.found){
            if(![x hasDisabled]){
               goon = NO;
               return;
            }else{
               do{
                  i.index = [x enableFirst];
               } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
               if([_gamma[getId(x[i.index])] bound]){
                  goon = NO;
                  return;
               }
            }
         } else if(_unique){
            if([x isFullyDisabled]){
               [x enableFirst];
            }
            [x disable:i.index];
         }
         id<CPVar> cx = _gamma[getId(x[i.index])];
         if(c){
            id<CPVar> v = [abs[i.index] bestChoice];
            LOG(_level,2,@"selected variables: %@ %@ bounded:%s and %@ %@ bounded:%s",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx,([cx bound])?"YES":"NO",[NSString stringWithFormat:@"var<%d>", [v getId]],v,([v bound])?"YES":"NO");
            [self floatAbsSplit:i.index by:v vars:x];
         }else{
            LOG(_level,2,@"selected variables: %@ %@",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx);
            [self float5WaySplit:i.index withVars:x];
         }
      }];
   }
   
}
-(void) maxAbsorptionSearch: (id<ORDisabledVarArray>) x default:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   @autoreleasepool {
      __block id<ORIdArray> abs = nil;
      id<ORSelect> select = [ORFactory select: _engine
                                        range: RANGE(self,[x low],[x up])
                                     suchThat: ^ORBool(ORInt i) {
         id<CPFloatVar> v = _gamma[getId(x[i])];
         return ![v bound] && [x isEnabled:i];
      }
                                    orderedBy: ^ORDouble(ORInt i) {
         id<CPFloatVar> v = _gamma[getId(x[i])];
         LOG(_level,2,@"%@ (var<%d>) [%16.16e,%16.16e] isInitial ? %s rate : abs=%16.16e",([x[i] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [v getId]]:[x[i] prettyname],[v getId],v.min,v.max, [x isInitial:i]?"YES":"NO",[abs[i] quantity]);
         if(([x isInitial:i] && [abs[i] quantity] >= _absTRateLimitModelVars) || (![x isInitial:i] && [abs[i] quantity] >= _absTRateLimitAdditionalVars)){
            return [abs[i] quantity];
         }else{
            return 0.0;
         }
      }
                             ];
      __block ORBool goon = YES;
      while(goon) {
         [_search try:^{
            abs = [self computeAbsorptionsQuantities:x];
            LOG(_level,2,@"State before selection");
            ORSelectorResult i = [select max];
            if (!i.found){
               if(![x hasDisabled]){
                  goon = NO;
                  return;
               }else{
                  do{
                     i.index = [x enableFirst];
                  } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
                  if([_gamma[getId(x[i.index])] bound]){
                     goon = NO;
                     return;
                  }
               }
            } else if(_unique){
               if([x isFullyDisabled]){
                  [x enableFirst];
               }
               [x disable:i.index];
            }
            if([abs[i.index] quantity] == 0.0){
               LOG(_level,1,@"current search has switched");
               [self maxOccurencesRatesSearch:[x initialVars:_engine]  do:^(ORUInt i,id<ORDisabledVarArray> x) {
                  [self float5WaySplit:i withVars:x];
               }];
            }else{
               id<CPVar> v = [abs[i.index] bestChoice];
               id<CPVar> cx = _gamma[getId(x[i.index])];
               LOG(_level,3,@"selected variables: %@ and %@",cx,v);
               LOG(_level,2,@"selected variables: %@ %@ and %@ %@",([x[i.index] prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[x[i.index] prettyname],cx,[NSString stringWithFormat:@"var<%d>", [v getId]],v);
               
               [self floatAbsSplit:i.index by:v withVars:x default:b];
               
            }
         } alt:^{}];
      }
   }
}
//[hzi] classic search based on abs
//does not handle multiple abs
-(void) maxAbsorptionSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return [self computeAbsorptionRate:x[i]];
   } do:b];
}
//------- min ------//
-(void) minAbsorptionSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return -[self computeAbsorptionRate:x[i]];
   } do:b];
}
-(void) maxCancellationSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return [self cancellationQuantity:x[i]];
   } do:b];
}
-(void) minCancellationSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self searchWithCriteria:x criteria:^ORDouble(ORInt i) {
      return -[self cancellationQuantity:x[i]];
   } do:b];
}
-(void) combinedAbsWithDensSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   id<ORIntArray> considered = [ORFactory intArray:self range:x.range value:0];
   __block ORDouble taux = 0.0;
   __block ORBool found = NO;
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x  up])
                                  suchThat: ^ORBool(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      return ![v bound] && [x isEnabled:i];
   }
                                 orderedBy: ^ORDouble(ORInt i) {
      LOG(_level,2,@"%@",_gamma[getId(x[i])]);
      ORDouble c = [self computeAbsorptionRate:x[i]];
      if(c > taux){
         [considered set:1 at:i];
         found = YES;
      }else
         [considered set:0 at:i];
      return c;
   }];
   
   
   [[self explorer] applyController:t in:^{
      do {
         found = NO;
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select max];
         if(!found){
            taux = -1.0;
            i = [select max];
         }if (!i.found){
            if(![x hasDisabled]){
               break;
            }else{
               do{
                  i.index = [x enableFirst];
               } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
               if([_gamma[getId(x[i.index])] bound]) break;
            }
         } else if(_unique){
            if([x isFullyDisabled]){
               [x enableFirst];
            }
            [x disable:i.index];
         }
         ORDouble choosed = 0.0;
         ORDouble val = 0.0; //max density is 1
         for (ORInt j = 0; j < [considered count]; j++) {
            if(!considered[j]) continue;
            val = [self density:x[j]];
            if (val > choosed) {
               choosed = val;
               i.index = j;
            }
            if(val == 1.0) break;//max density is 1
         }
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,x);
      } while (true);
   }];
}

-(void) combinedDensWithAbsSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   id<ORIntArray> considered = [ORFactory intArray:self range:x.range value:0];
   id<ORDoubleArray> dens = [ORFactory doubleArray:self range:x.range value:0.0];
   __block ORDouble min = 0.0;
   __block ORDouble max = 0.0;
   __block id<CPFloatVar> cv;
   ORDouble d = 0.0;
   for(ORUInt i = 0; i < [x count]; i++){
      cv = _gamma[getId(x[i])];
      if([cv bound]){
         continue;
      }
      [dens set:[self density:x[i]] at:i];
      if(i == 0)
         min = max = d;
      else if(d < min)
         min = d;
      else if (d > max)
         max = d;
   }
   __block ORDouble mid = min/2 + max/2;
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x  up])
                                  suchThat: ^ORBool(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      return ![v bound] && [x isEnabled:i];
   }
                                 orderedBy: ^ORDouble(ORInt i) {
      LOG(_level,2,@"%@",_gamma[getId(x[i])]);
      [considered set:([dens at:i] >= mid) at:i];
      return [dens at:i];
   }];
   
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(![x hasDisabled]){
               break;
            }else{
               do{
                  i.index = [x enableFirst];
               } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
               if([_gamma[getId(x[i.index])] bound]) break;
            }
         } else if(_unique){
            if([x isFullyDisabled]){
               [x enableFirst];
            }
            [x disable:i.index];
         }
         ORDouble choosed = 0.0;
         ORDouble val = 0.0;
         for (ORInt j = 0; j < [considered count]; j++) {
            if(!considered[j]) continue;
            val = [self computeAbsorptionRate:x[j]];
            if (val > choosed) {
               choosed = val;
               i.index = j;
            }
         }
         LOG(_level,2,@"selected variable : %@",_gamma[getId(x[i.index])]);
         b(i.index,x);
         ORDouble d = 0.0;
         min = max = 0.0;
         for(ORUInt k = 0; k < [x count]; k++){
            cv = _gamma[getId(x[k])];
            if([cv bound]){
               [dens set:0.0 at:k];
               continue;
            }
            [dens set:[self density:x[k]] at:k];
            if(k == 0)
               min = max = d;
            else if(d < min)
               min = d;
            else if (d > max)
               max = d;
         }
         mid = min/2 + max/2;
      } while (true);
   }];
}


-(void) switchedSearch:  (id<ORDisabledVarArray>) x do:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   [self switchSearchOnDepthUsingProperties:
    ^ORDouble(id<ORFloatVar> v) {
      CPFloatVarI* cv = _gamma[getId(v)];
      return cardinality(cv);
   } to:^ORDouble(id<ORFloatVar> v) {
      CPFloatVarI* cv = _gamma[getId(v)];
      return -cardinality(cv);
   } do:b limit:2 restricted:x];
}

-(void) maxAbsDensSearch:  (id<ORDisabledVarArray>) x default:(void(^)(ORUInt,id<ORDisabledVarArray>))b
{
   @autoreleasepool {
      __block id<ORIdArray> abs = [self computeAbsorptionsQuantities:x];
      ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
      __block ORInt switchneeded = true;
      id<ORSelect> select = [ORFactory select: _engine
                                        range: RANGE(self,[x low],[x up])
                                     suchThat: ^ORBool(ORInt i) {
         id<CPFloatVar> v = _gamma[getId(x[i])];
         return ![v bound] && [x isEnabled:i];
      }
                                    orderedBy: ^ORDouble(ORInt i) {
         LOG(_level,2,@"%@ rate : %16.16e",_gamma[getId(x[i])], [abs[i] quantity]);
         switchneeded = switchneeded && !([abs[i] quantity] > 0.f);
         return [abs[i] quantity];
      }];
      
      
      [[self explorer] applyController:t in:^{
         do {
            LOG(_level,2,@"State before selection");
            ORSelectorResult i = [select max];
            if(switchneeded){
               [self maxDensitySearch:x do:^(ORUInt i,id<ORDisabledVarArray> x) {
                  [self float6WaySplit:i withVars:x];
               }];
            }else{
               if (!i.found){
                  if(![x hasDisabled]){
                     break;
                  }else{
                     do{
                        i.index = [x enableFirst];
                     } while([x hasDisabled] && [_gamma[getId(x[i.index])] bound]);
                     if([_gamma[getId(x[i.index])] bound]) break;
                  }
               } else if(_unique){
                  if([x isFullyDisabled]){
                     [x enableFirst];
                  }
                  [x disable:i.index];
               }
               id<CPVar> v = [abs[i.index] bestChoice];
               LOG(_level,2,@"selected variables: %@ and %@",_gamma[getId(x[i.index])],v);
               [self floatAbsSplit:i.index by:v withVars:x default:b];
               abs = [self computeAbsorptionsQuantities:x];
               switchneeded = true;
            }
         } while (true);
      }];
   }
}

//-------------------------------------------------
//Value ordering
//split until value
-(void) floatStaticSplit: (ORUInt) i withVars:(id<ORDisabledVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   while (![xi bound]) {
      [self floatSplit:i withVars:x];
   }
}
//static 3 split
-(void) floatStatic3WaySplit: (ORUInt) i  withVars:(id<ORDisabledVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   while (![xi bound]) {
      [self float3WaySplit:i withVars:x];
   }
}
//static split in 5 way until the var is bound
-(void) floatStatic5WaySplit: (ORUInt) i withVars:(id<ORDisabledVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   while (![xi bound]) {
      [self float5WaySplit:i withVars:x];
   }
}
//static split in 6 way until the var is bound
-(void) floatStatic6WaySplit: (ORUInt) i withVars:(id<ORDisabledVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   while (![xi bound]) {
      [self float6WaySplit:i withVars:x];
   }
}
-(void) floatAbsSplit:(ORUInt)i by:(id<CPVar>) y vars:(id<ORDisabledVarArray>) x
{
   id<CPVar> xi = _gamma[getId(x[i])];
   id<CPVisitor> splitVisit = [[ORAbsSplitVisitor alloc] initWithProgram:self variable:x[i] other:y];
   [self trackObject:splitVisit];
   [xi visit:splitVisit];
}
- (void)floatAbsSplit:(ORUInt)x by:(nonnull id<CPVar>)y withVars:(nonnull id<ORDisabledVarArray>)vars default:(nonnull void (^)(ORUInt, id<ORDisabledVarArray> _Nonnull))b {
   [self floatAbsSplit:x by:y vars:vars];
}
- (void)setGamma:(id *)gamma {
   _gamma = gamma;
}

- (void)visit:(ORVisitor *)visitor {
}
-(void) float3BSplit:(ORUInt)index call:(SEL)s withVars:(id<ORDisabledVarArray>)x
{
   id<CPFloatVar> xi = _gamma[getId(x[index])];
   if([xi bound]) return;
   ORFloat tmpMax = (xi.max == +infinityf()) ? maxnormalf() : xi.max;
   ORFloat tmpMin = (xi.min == -infinityf()) ? -maxnormalf() : xi.min;
   if(fp_next_float(tmpMin) == tmpMax){
      [_search try:^{
         [self floatIntervalImpl:xi low:tmpMin up:tmpMin];
      } alt:^{
         [self floatIntervalImpl:xi low:tmpMax up:tmpMax];
      }];
   }else{
      [self shave:index direction:-1 percent:_split3Bpercent coef:2 call:s withVars:x];
      [self shave:index direction:1 percent:_split3Bpercent coef:2 call:s withVars:x];
      //for splitting percent 50 and coef 0.5 ?
      // now x is shaved on both-end. Proceed with a normal dichotomy
      // on x and recur.
      [self floatSplit:index  withVars:x];
   }
}
-(void) shave :(ORUInt) index direction:(ORInt) d percent:(ORFloat)p coef:(ORInt)c  call:(SEL)s withVars:(id<ORDisabledVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[index])];
   if([xi bound]) return;
   ORFloat tmpMax = (xi.max == +infinityf()) ? maxnormalf() : xi.max;
   ORFloat tmpMin = (xi.min == -infinityf()) ? -maxnormalf() : xi.min;
   __block id<ORMutableFloat> percent = [ORFactory mutable:_engine fvalue:p];
   __block ORTrackDepth* t ;
   __block id<ORMutableFloat> min,max;
   ORDouble size = [xi domwidth];
   __block ORDouble step = size * ([percent value]/100);
   if(d > 0) //shave sup side
   {
      max = [ORFactory mutable:_engine fvalue:tmpMax];
      min = [ORFactory mutable:_engine fvalue:(tmpMax - step > tmpMin) ? tmpMax - step : tmpMin];
   }else{
      min = [ORFactory mutable:_engine fvalue:tmpMin];
      max = [ORFactory mutable:_engine fvalue:(tmpMin + step < tmpMax) ? tmpMin + step : tmpMax];
   }
   __block ORMutableIntegerI* depth = [ORFactory mutable:_engine value:0];
   __block ORBool goon = YES;
   t = [[ORTrackDepth alloc] initORTrackDepth:_trail with:depth];
   while (goon) {
      [self nestedSolve:^{
         [_search applyController:t in:^{
            LOG(_level,1,@"(3Bsplit) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[self explorer] nbChoices],xi,[min value],[max value]);
            [self floatIntervalImpl:xi low:[min value] up:[max value]];
            // The call above triggers propagation. Either this will succeed, suspend or it will fail
            // If it fails, there are provably no solution in the slice, so onSolution won't
            // be called and onExit will do the right thing.
            // If there is a solution, onSolution sets goon = NO and onExit attempts to go
            // to the next iteration but the outer loop stops.
            // If it suspends, then without branching we can't tell what happening inside the slide.
            // So we carry on and reach this point (right here) where we should *BRANCH* on the
            // variables in the slide. That is within the nested search and this array of vars
            // should be accessible.
            // ultimately that nested search will succeed or fail.
            // If it succeeds, goon = NO.
            // If it fails, onSolution is never called and you can check the depth of the
            // search with the controller t.
            [self performSelector:s withObject:x withObject:^(ORUInt ind, SEL call,id<ORDisabledVarArray> vs){
               SELPROTO subcut = (SELPROTO)[self methodForSelector:_subcut];
               subcut(self,_subcut,ind,call,vs);
            }];
         }];
      } onSolution:^{
         LOG(_level,1,@"solution found! in depth %d",[depth intValue]);
         if(_oneSol){
            goon = NO;
         }
         [self doOnSolution];
      } onExit:^{
         LOG(_level,1,@"fail on depth:%d",[depth intValue]);
         if (max.value == min.value || [depth intValue] > 1){
            goon = NO;
            if(d>0){
               [max setValue:maxFlt(fp_previous_float([min value]),xi.min)];
               [min setValue:xi.min];
            }else{
               [min setValue:minFlt(fp_next_float([max value]),xi.max)];
               [max setValue:xi.max];
            }
            [self floatIntervalImpl:xi low:min.value up:max.value];
         }else{
            [depth setValue:0];
            t = [[ORTrackDepth alloc] initORTrackDepth:_trail with:depth];
            [percent setValue: percent.value * c];
            step = size * percent.value / 100;
            if(d > 0){ //shave sup side
               [max setValue:maxFlt(fp_previous_float([min value]),xi.min)];
               [min setValue:([max value] - step > xi.min) ? [max value] - step : xi.max];
            }else{
               [min setValue:minFlt(fp_next_float([max value]),xi.max)];
               [max setValue:([min value] + step < xi.max) ? [min value] + step : xi.max];
            }
         }
      }];
   }
   LOG(_level,1,@"quit goon on depth %d",[depth intValue]);
   // Note that you will always reach this point.
   // so you will return from this shave method normally.
   // Hence the caller should shave left, shave right and when that is all
   // done, it can resume branching. So the top-level should also change.
}
//split in 2 intervals Once
-(void) floatSplit:(ORUInt) i  withVars:(id<ORDisabledVarArray>) x
{
   //NSLog(@"CHOOSE: %@", [x[i] prettyname]);
   id<CPVar> xi = _gamma[getId(x[i])];
   id<CPVisitor> splitVisit = [[ORSplitVisitor alloc] initWithProgram:self variable:x[i]];
   [self trackObject:splitVisit];
   [xi visit:splitVisit];
}
//split in 3 intervals Once
-(void) float3WaySplit:(ORUInt) i withVars:(id<ORDisabledVarArray>) x
{
   id<CPVar> xi = _gamma[getId(x[i])];
   id<CPVisitor> splitVisit = [[OR3WaySplitVisitor alloc] initWithProgram:self variable:x[i]];
   [self trackObject:splitVisit];
   [xi visit:splitVisit];
}
//split in 5 intervals Once
-(void) float5WaySplit:(ORUInt) i withVars:(id<ORDisabledVarArray>) x
{
   id<CPVar> xi = _gamma[getId(x[i])];
   id<CPVisitor> splitVisit = [[OR5WaySplitVisitor alloc] initWithProgram:self variable:x[i]];
   [self trackObject:splitVisit];
   [xi visit:splitVisit];
}
//split in 6 intervals Once
-(void) float6WaySplit: (ORUInt) i withVars:(id<ORDisabledVarArray>) x
{
   id<CPVar> xi = _gamma[getId(x[i])];
   id<CPVisitor> splitVisit = [[OR6WaySplitVisitor alloc] initWithProgram:self variable:x[i]];
   [self trackObject:splitVisit];
   [xi visit:splitVisit];
}
-(void) floatDeltaSplit:(ORUInt) i withVars:(id<ORDisabledVarArray>) x
{
   id<CPVar> xi = _gamma[getId(x[i])];
   id<CPVisitor> splitVisit = [[ORDeltaSplitVisitor alloc] initWithProgram:self variable:x[i] nb:_searchNBFloats];
   [self trackObject:splitVisit];
   [xi visit:splitVisit];
}
-(void) floatEWaySplit: (ORUInt) i withVars:(id<ORDisabledVarArray>) x
{
   id<CPVar> xi = _gamma[getId(x[i])];
   id<CPVisitor> splitVisit = [[OREnumSplitVisitor alloc] initWithProgram:self variable:x[i] nb:_searchNBFloats];
   [self trackObject:splitVisit];
   [xi visit:splitVisit];
}
//----------------------------------------------------------
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat
{
   [_search repeat: body onRepeat: onRepeat until: nil];
}
-(void) repeat: (ORClosure) body onRepeat: (ORClosure) onRepeat until: (ORVoid2Bool) isDone
{
   [_search repeat: body onRepeat: onRepeat until: isDone];
}
-(void) perform: (ORClosure) body onLimit: (ORClosure) onLimit;
{
   [_search perform: body onLimit: onLimit];
}
-(void) portfolio: (ORClosure) s1 then: (ORClosure) s2
{
   [_search portfolio: s1 then: s2];
}
-(void) switchOnDepth: (ORClosure) s1 to: (ORClosure) s2 limit: (ORInt) depth
{
   [_search switchOnDepth: s1 to: s2 limit: depth];
}
-(void) switchSearchOnDepthUsingProperties:(ORDouble(^)(id<ORVar>)) criteria1 to: (ORDouble(^)(id<ORVar>)) criteria2 do:(void(^)(ORUInt,id<ORDisabledVarArray>))b limit: (ORInt) depth restricted:(id<ORDisabledVarArray>) x
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
      id<CPVar> v = _gamma[getId(x[i])];
      return ![v bound];
   }
                                 orderedBy: ^ORDouble(ORInt i) {
      return criteria1(x[i]);
   }];
   id<ORSelect> select2 = [ORFactory select: _engine
                                      range: RANGE(self,[x low],[x up])
                                   suchThat: ^ORBool(ORInt i) {
      id<CPFloatVar> v = _gamma[getId(x[i])];
      return ![v bound];
   }
                                  orderedBy: ^ORDouble(ORInt i) {
      return criteria2(x[i]);
   }];
   
   [[self explorer] applyController:t in:^{
      do {
         ORSelectorResult i;
         if([t maxDepth] > depth)
            i = [select min];
         else
            i = [select2 min];
         if (!i.found)
            break;
         b(i.index,x);
      } while (true);
   }];
}
-(void) once: (ORClosure) cl
{
   [_search once: cl];
}
-(void) probe: (ORClosure) cl
{
   [_search probe:cl];
}
-(void) try: (ORClosure) left then: (ORClosure) right
{
   [_search try: left then: right];
}
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   [_search limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   [_search limitCondition: condition in:cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   [_search limitDiscrepancies: maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   [_search limitFailures: maxFailures in: cl];
}
-(void) addConstraintDuringSearch: (id<ORConstraint>) c
{
   // LDM: This is the true addition of the constraint into the solver during the search.
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) add: (id<ORConstraint>) c
{}

-(id<CPHeuristic>) createPortfolio:(NSArray*)hs with:(id<ORVarArray>)vars
{
   @throw [[ORExecutionError alloc] initORExecutionError:"reached createdPortfolio: in CPSolver"];
   return NULL;
}

-(id<CPHeuristic>) createFF: (id<ORVarArray>) rvars
{
   id<CPHeuristic> h = [[CPFirstFail alloc] initCPFirstFail:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPWDeg alloc] initCPWDeg:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPDDeg alloc] initCPDDeg:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createSDeg:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPDeg alloc] initCPDeg:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPIBS alloc] initCPIBS:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarFF
{
   id<CPBitVarHeuristic> h = [[CPBitVarFirstFail alloc] initCPBitVarFirstFail:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarFF: (id<ORVarArray>) rvars
{
   id<CPBitVarHeuristic> h = [[CPBitVarFirstFail alloc] initCPBitVarFirstFail:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarVSIDS
{
   id<CPBitVarHeuristic> h = [[CPBitVarVSIDS alloc] initCPBitVarVSIDS:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarVSIDS: (id<ORVarArray>) rvars
{
   id<CPBitVarArray> cav = [CPFactory bitVarArray:self range:rvars.range with:^id<CPBitVar>(ORInt i) {
      CPBitVarI* sv =_gamma[rvars[i].getId];
      assert([sv isKindOfClass:[CPBitVarI class]]);
      return sv;
   }];
   
   id<CPBitVarHeuristic> h = [[CPBitVarVSIDS alloc] initCPBitVarVSIDS:self restricted:cav];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPABS alloc] initCPABS:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarABS:(id<ORVarArray>)rvars
{
   id<CPBitVarHeuristic> h = [[CPBitVarABS alloc] initCPBitVarABS:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarIBS:(id<ORVarArray>)rvars
{
   id<CPBitVarHeuristic> h = [[CPBitVarIBS alloc] initCPBitVarIBS:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createFDS:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPFDS alloc] initCPFDS:self restricted:rvars];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createFF
{
   id<CPHeuristic> h = [[CPFirstFail alloc] initCPFirstFail:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createWDeg
{
   id<CPHeuristic> h = [[CPWDeg alloc] initCPWDeg:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createDDeg
{
   id<CPHeuristic> h = [[CPDDeg alloc] initCPDDeg:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createSDeg
{
   id<CPHeuristic> h = [[CPDeg alloc] initCPDeg:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createIBS
{
   id<CPHeuristic> h = [[CPIBS alloc] initCPIBS:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createABS
{
   id<CPHeuristic> h = [[CPABS alloc] initCPABS:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarABS
{
   id<CPBitVarHeuristic> h = [[CPBitVarABS alloc] initCPBitVarABS:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarIBS
{
   id<CPBitVarHeuristic> h = [[CPBitVarIBS alloc] initCPBitVarIBS:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createFDS
{
   id<CPHeuristic> h = [[CPFDS alloc] initCPFDS:self restricted:nil];
   [self addHeuristic:h];
   return h;
}
-(NSString*)stringValue:(id<ORBitVar>)x
{
   return [_gamma[x.getId] stringValue];
}
-(ORInt)memberBit:(ORInt)k value:(ORInt)v in: (id<ORBitVar>) x
{
   CPBitVarI* cx = _gamma[x.getId];
   return [cx isFree:k] ? YES : [cx getBit:k] == v;
}
-(ORBool)boundBit:(ORInt)k in:(id<ORBitVar>)x
{
   CPBitVarI* cx = _gamma[x.getId];
   return ![cx isFree:k];
}
-(ORBool)bitAt:(ORInt)k in:(id<ORBitVar>)x
{
   CPBitVarI* cx = _gamma[x.getId];
   return [cx bitAt:k];
}

-(ORUInt) degree:(id<ORVar>)x
{
   return [_gamma[x.getId] degree];
}
-(ORInt)intValue:(id<ORIntVar>)x
{
   return [_gamma[[x getId]] intValue];
}
-(ORBool) boolValue: (id<ORIntVar>) x
{
   return [_gamma[x.getId] intValue];
}
-(ORDouble) doubleValue: (id<ORVar>) x
{
   return [(id<CPDoubleVar>)_gamma[x.getId] value];
}
-(ORFloat) floatValue:(id<ORVar>)x
{
   return [((id<CPFloatVar>)_gamma[x.getId]) value];
}
-(ORFloat) minF:(id<ORVar>)x
{
   CPFloatVarI* cx = _gamma[x.getId];
   return [cx min];
}
-(ORFloat) maxF:(id<ORVar>)x
{
   CPFloatVarI* cx = _gamma[x.getId];
   return [cx max];
}
-(ORDouble) minErrorFD:(id<ORVar>)x
{
   CPFloatVarI* cx = _gamma[x.getId];
   return [cx minErrF];
}
-(ORDouble) maxErrorFD:(id<ORVar>)x
{
   CPFloatVarI* cx = _gamma[x.getId];
   return [cx maxErrF];
}
-(void) setMinErrorFD:(id<ORVar>)x minErrorF:(ORDouble) minError
{
   CPFloatVarI* cx = _gamma[x.getId];
   [cx updateMinErrorF:minError];
}
-(void) setMaxErrorFD:(id<ORVar>)x maxErrorF:(ORDouble) maxError
{
   CPFloatVarI* cx = _gamma[x.getId];
   [cx updateMaxErrorF:maxError];
}
-(id<ORRational>) minErrorFQ:(id<ORVar>)x
{
   CPFloatVarI* cx = _gamma[x.getId];
   return [cx minErr];
}
-(id<ORRational>) maxErrorFQ:(id<ORVar>)x
{
   CPFloatVarI* cx = _gamma[x.getId];
   return [cx maxErr];
}
-(void) setMinErrorFQ:(id<ORVar>)x minError:(id<ORRational>) minError
{
   CPFloatVarI* cx = _gamma[x.getId];
   [cx updateMinError:minError];
}
-(void) setMaxErrorFQ:(id<ORVar>)x maxError:(id<ORRational>) maxError
{
   CPFloatVarI* cx = _gamma[x.getId];
   [cx updateMaxError:maxError];
}
-(ORDouble) minD:(id<ORVar>)x
{
   CPDoubleVarI* cx = _gamma[x.getId];
   return [cx min];
}
-(ORDouble) maxD:(id<ORVar>)x
{
   CPDoubleVarI* cx = _gamma[x.getId];
   return [cx max];
}
-(NSString*) maxQ:(id<ORVar>)x
{
   CPRationalVarI* cx = _gamma[x.getId];
   return [[cx max] description];
}
-(NSString*) minQ:(id<ORVar>)x
{
   CPRationalVarI* cx = _gamma[x.getId];
   return [[cx min] description];
}
-(NSString*) maxFQ:(id<ORVar>)x
{
   CPFloatVarI* cx = _gamma[x.getId];
   return [[cx maxErr] description];
}
-(NSString*) minFQ:(id<ORVar>)x
{
   CPFloatVarI* cx = _gamma[x.getId];
   return [[cx minErr] description];
}
-(NSString*) maxDQ:(id<ORVar>)x
{
   CPDoubleVarI* cx = _gamma[x.getId];
   return [[cx maxErr] description];
}
-(NSString*) minDQ:(id<ORVar>)x
{
   CPDoubleVarI* cx = _gamma[x.getId];
   return [[cx minErr] description];
}
-(ORDouble) minErrorDD:(id<ORVar>)x
{
   CPDoubleVarI* cx = _gamma[x.getId];
   return [cx minErrF];
}
-(ORDouble) maxErrorDD:(id<ORVar>)x
{
   CPDoubleVarI* cx = _gamma[x.getId];
   return [cx maxErrF];
}
-(void) setMinErrorDD:(id<ORVar>)x minErrorF:(ORDouble) minError
{
   CPDoubleVarI* cx = _gamma[x.getId];
   [cx updateMinErrorF:minError];
}
-(void) setMaxErrorDD:(id<ORVar>)x maxErrorF:(ORDouble) maxError
{
   CPDoubleVarI* cx = _gamma[x.getId];
   [cx updateMaxErrorF:maxError];
}
-(id<ORRational>) minErrorDQ:(id<ORVar>)x
{
   CPDoubleVarI* cx = _gamma[x.getId];
   return [cx minErr];
}
-(id<ORRational>) maxErrorDQ:(id<ORVar>)x
{
   CPDoubleVarI* cx = _gamma[x.getId];
   return [cx maxErr];
}
-(void) setMinErrorDQ:(id<ORVar>)x minError:(id<ORRational>) minError
{
   CPDoubleVarI* cx = _gamma[x.getId];
   [cx updateMinError:minError];
}
-(void) setMaxErrorDQ:(id<ORVar>)x maxError:(id<ORRational>) maxError
{
   CPDoubleVarI* cx = _gamma[x.getId];
   [cx updateMaxError:maxError];
}
-(ORDouble) paramValue: (id<ORRealParam>)x
{
   id<CPRealParam> p = _gamma[x.getId];
   return [p value];
}
-(void) param: (id<ORRealParam>)p setValue: (ORDouble)val
{
   id<CPRealParam> param = _gamma[p.getId];
   [param setValue: val];
}
-(void)  assignRelaxationValue: (ORDouble) f to: (id<ORRealVar>) x
{
   [(id<CPRealVar>)_gamma[x.getId] assignRelaxationValue: f];
}
-(ORBool) bound: (id<ORVar>) x
{
   return [_gamma[x.getId] bound];
}
-(ORInt)  min: (id<ORIntVar>) x
{
   return [((id<CPIntVar>) _gamma[x.getId]) min];
}
-(ORInt)  max: (id<ORIntVar>) x
{
   return [((id<CPIntVar>) _gamma[x.getId]) max];
}
-(ORInt)  domsize: (id<ORIntVar>) x
{
   return [((id<CPVar>) _gamma[x.getId]) domsize];
}
-(ORDouble) cardinality: (id<ORFloatVar>) x
{
   CPFloatVarI* cx = _gamma[[x getId]];
   ORDouble c = cardinality(cx);
   return c;
}
-(ORDouble) cardinalityD: (id<ORDoubleVar>) x
{
   CPDoubleVarI* cx = _gamma[[x getId]];
   ORDouble c = cardinalityD(cx);
   return c;
}
-(ORLDouble) density: (id<ORFloatVar>) x
{
   CPFloatVarI* cx = _gamma[[x getId]];
   ORDouble c = cardinality(cx);
   ORDouble w = [self fdomwidth:x];
   return (ORLDouble) (c / w);
}
-(ORUInt)  countMemberedConstraints:(id<ORVar>) x
{
   CPFloatVarI* cx = _gamma[[x getId]];
   id<OROSet> cstr = [cx constraints];
   ORUInt cpt = (ORUInt) [cstr count];
   [cstr release];
   return cpt;
}
//[hzi] not useful any more ?
-(ORUInt)  maxOccurences:(id<ORVar>) x
{
   NSArray* csts = [_model constraints];
   ORUInt max = 0;
   ORUInt cur = 0;
   for (ORInt i = 0; i < [csts count];i++)
   {
      cur = [csts[i] nbOccurences:x];
      max = (cur > max) ? cur : max;
   }
   return max;
}
-(id<ORIntArray>) computeAllOccurrences:(id<ORDisabledVarArray>) vars
{
   NSArray* csts = [_model constraints];
   ORInt max = 0;
   for(id<ORVar> v in vars){
      max = (getId(v) > max) ? [v getId] : max;
   }
   id<ORIntArray> occ = [ORFactory intArray:self range:RANGE(self,0,max) value:0];
   ORInt index = 0;
   @autoreleasepool {
      NSArray* vc;
      for (ORInt i = 0; i < [csts count];i++)
      {
         vc = [csts[i] allVarsArray];
         for(id<ORVar> v in vc){
            index = getId(v);
            if(index < [occ count]){
               ORInt oldv = [occ at:index];
               occ[index] = @(oldv+1);
            }
         }
      }
   }
   id<ORIntArray> res = [ORFactory intArray:self range:vars.range value:0];
   for(ORInt i = 0; i < [vars count];i++){
      res[i] = occ[getId(vars[i])];
   }
   return res;
}

-(ORDouble) computeAbsorptionQuantity:(id<CPFloatVar>)y by:(id<ORFloatVar>)x
{
   CPFloatVarI* cx = _gamma[getId(x)];
   CPFloatVarI* cy = (CPFloatVarI*) y;
   float_interval ax = computeAbsordedInterval(cx);
   if(![cy bound] && isIntersectingWithV(ax.inf, ax.sup, [cy min], [cy max])){
      return cardinalityV(maxFlt(ax.inf, [cy min]),minFlt(ax.sup, [cy max]))/cardinality(cy);
   }
   return 0.0;
}


-(void) initializeAbsConstraints:(id<ORDisabledVarArray>) vars
{
   if(_absconstraints == nil){
      ORInt maxId = [vars maxId];
      _absconstraints = [[NSMutableArray alloc] initWithCapacity:maxId+1];
      for(ORInt i = 0; i <= maxId; i++){
         [_absconstraints addObject:[NSNull null]];
      }
      id<CPVar> cx;
      for (id<ORVar> x in vars) {
         cx = _gamma[[x getId]];
         id<OROSet> cstr = [cx constraints];
         id<OROSet> set = [ORFactory objectSet];
         if([cstr count]){
            for(id<CPConstraint> c in cstr){
               if([c canLeadToAnAbsorption]){
                  [set add:c];
               }
            }
         }
         _absconstraints[x.getId] = set;
      }
   }
}
-(id<ORIdArray>) computeAbsorptionsQuantities:(id<ORDisabledVarArray>) vars
{
   id<ORIdArray> abs = [ORFactory idArray:self range:vars.range];
   ORDouble absV;
   for(ORInt i = 0; i < [abs count]; i++){
      ABSElement* ae = [[ABSElement alloc] init];
      [self trackObject:ae];
      abs[i] = ae;
   }
   ORUInt i = 0;
   id<CPVar> cx;
   id<CPVar> v;
   [self initializeAbsConstraints:vars];
   @autoreleasepool {
      for (id<ORVar> x in vars) {
         cx = _gamma[x.getId];
         id<OROSet> cstr = _absconstraints[x.getId];
         for(id<CPConstraint> c in cstr){
            v = [c varSubjectToAbsorption:cx];
            if(v == nil) continue;
            ORAbsVisitor* absVisit = [[ORAbsVisitor alloc] init:v];
            [cx visit:absVisit];
            absV = [absVisit rate];
            [absVisit release];
            assert(absV >= 0.0f && absV <= 1.f);
            //second test can be reduce to !isInitial()
            if(([vars isInitial:i] && absV >= _absRateLimitModelVars) || (![vars isInitial:i] && absV >= _absRateLimitAdditionalVars)){
               [abs[i] addQuantity:absV for:v];
            }
         }
         i++;
      }
   }
   return  abs;
}

-(ORDouble) computeAbsorptionRate:(id<ORVar>) x
{
   CPFloatVarI* cx = _gamma[[x getId]];
   id<OROSet> cstr = [cx constraints];
   ORDouble rate = 0.0;
   id<CPVar> v;
   for(id<CPConstraint> c in cstr){
      if([c canLeadToAnAbsorption]){
         v = [c varSubjectToAbsorption:cx];
         rate += [self computeAbsorptionQuantity:(id<CPFloatVar>)v by:(id<ORFloatVar>)x];
      }
   }
   [cstr release];
   return rate;
}
//[hzi] collect all additionals variables leading to abs
-(NSArray*)  collectAllVarWithAbs:(id<ORFloatVarArray>) vs withLimit:(ORDouble) limit
{
   NSMutableArray *res = [[NSMutableArray alloc] init];
   id<OROSet> cstr = nil;
   id<CPFloatVar> cx = nil;
   id<CPVar> v = nil;
   ORDouble absV = 0.0;
   id<ORFloatVarArray> vars = [_model floatVars];
   for(id<ORFloatVar> x in vars){
      if([vs contains:x]) continue;
      cx = _gamma[[x getId]];
      cstr = [cx constraints];
      for(id<CPConstraint> c in cstr){
         if([c canLeadToAnAbsorption]){
            v = [c varSubjectToAbsorption:cx];
            if(v == nil) continue;
            absV = [self computeAbsorptionQuantity:(CPFloatVarI*)v by:x];
            assert(absV >= 0.0f && absV <= 1.f);
            if(absV > 0.0f && absV >= limit){
               [res addObject:x];
            }
         }
      }
      [cstr release];
   }
   return res;
}
-(NSArray*)  collectAllVarWithAbs:(id<ORFloatVarArray>) vs
{
   return [self collectAllVarWithAbs:vs withLimit:0.0f];
}
-(ORDouble)  cancellationQuantity:(id<ORVar>) x
{
   CPFloatVarI* cx = _gamma[[x getId]];
   id<OROSet> cstr = [cx constraints];
   ORDouble rate = 0.0;
   for(id<CPConstraint> c in cstr){
      if([c canLeadToAnAbsorption]){
         rate += [c leadToACancellation:x];
      }
   }
   [cstr release];
   assert(rate != NAN);
   return rate;
}
-(ORInt)  regret:(id<ORIntVar>)x
{
   return [((id<CPIntVar>) _gamma[x.getId]) regret];
}
-(ORInt)  member: (ORInt) v in: (id<ORIntVar>) x
{
   return [((id<CPIntVar>) _gamma[x.getId]) member: v];
}
-(ORDouble) domwidth:(id<ORRealVar>) x
{
   return [((id<CPRealVar>)_gamma[x.getId]) domwidth];
}
-(ORDouble) fdomwidth:(id<ORFloatVar>) x
{
   return [((id<CPFloatVar>)_gamma[x.getId]) domwidth];
}
-(ORDouble) doubleMin:(id<ORRealVar>)x
{
   return [((id<CPRealVar>)_gamma[x.getId]) min];
}
-(ORDouble) doubleMax:(id<ORRealVar>)x
{
   return [((id<CPRealVar>)_gamma[x.getId]) max];
}

-(id<OROSet>) constraints: (id<ORVar>)x
{
   return [(id<CPVar>)_gamma[x.getId] constraints];
}
-(void) incr: (id<ORMutableInteger>) i
{
   [((ORMutableIntegerI*) _gamma[i.getId]) incr];
}

-(void) defaultSearch
{
   id<CPHeuristic> h = [self createFF];
   [self solveAll:^{
      [self labelHeuristic:h];
   }];
   [_engine open];
}

-(void) search:(void*(^)(void))stask
{
   [self solve:^{
      id<ORSTask> theTask = (id<ORSTask>)stask();
      [theTask execute];
   }];
   [_engine open];
}

-(void) searchAll:(void*(^)(void))stask
{
   [self solveAll:^{
      id<ORSTask> theTask = (id<ORSTask>)stask();
      [theTask execute];
   }];
   [_engine open];
}
@end

/******************************************************************************************/
/*                                   CPSolver                                             */
/******************************************************************************************/

@implementation CPINCModel {
   id<ORModelMappings> _maps;
   ORVisitor*    _concretizer;
}
-(id)init:(id<CPCommonProgram>)theSolver
{
   self = [super init];
   _engine  = [theSolver engine];
   _maps    = [theSolver modelMappings];
   _concretizer = [[ORCPSearchConcretizer alloc] initORCPConcretizer: _engine gamma:theSolver];
   return self;
}
-(void)dealloc
{
   [_concretizer release];
   [super dealloc];
}
-(void)setCurrent:(id<ORConstraint>)cstr
{}

-(ORStatus) post: (id<ORConstraint>)c
{
   return tryfail(^ORStatus {
      if ([[c class] conformsToProtocol:@protocol(ORRelation)])
         [ORFlatten flattenExpression:(id<ORExpr>) c
                                 into: self];
      else
         [ORFlatten flatten: c into:self];
      return [_engine currentStatus];
   }, ^ORStatus {
      return ORFailure;
   });
}

-(id<ORModelMappings>) modelMappings
{
   return _maps;
}
-(id<ORVar>) addVariable: (id<ORVar>) var
{
   return [_engine trackVariable:var];
}
-(id) addMutable: (id) object
{
   return [_engine trackMutable: object];
}
-(id) addImmutable:(id)object
{
   return [_engine trackImmutable:object];
}
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr
{
   [cstr visit: _concretizer];
   return cstr;
}
-(id<ORTracker>)tracker
{
   return _engine;
}
-(id<ORObjectiveFunction>) minimizeVar:(id<ORVar>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to minimizeVar: not allowed during search"];
}
-(id<ORObjectiveFunction>) maximizeVar:(id<ORVar>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to maximizeVar: not allowed during search"];
}
-(id<ORObjectiveFunction>) minimize:(id<ORExpr>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to minimize: not allowed during search"];
}
-(id<ORObjectiveFunction>) maximize:(id<ORExpr>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to maximize: not allowed during search"];
}
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORDoubleArray>) coef
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to minimize:coef: not allowed during search"];
}
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORDoubleArray>) coef
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to maximize:coef: not allowed during search"];
}
- (id<ORFloatVarArray>)floatVars
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Not implemented yet"];
}
- (void)incrOccurences:(nonnull id<ORVar>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Not implemented yet"];
}
- (void)addEqualityRelation:(id<ORVar>)v with:(id<ORExpr>)e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Not implemented yet"];
}
-(id) trackObject: (id) obj
{
   return [_engine trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_engine trackConstraintInGroup:obj];
}
-(id) trackObjective:(id) object
{
   return [_engine trackObjective: object];
}
-(id) trackMutable: (id) obj
{
   return [_engine trackMutable:obj];
}
-(id) trackImmutable:(id)obj
{
   return [_engine trackImmutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_engine trackVariable:obj];
}
@end

@implementation CPSolver
-(id<CPProgram>) initCPSolver
{
   _trail = [ORFactory trail];
   _mt    = [ORFactory memoryTrail];
   _closed = makeTRInt(_trail, NO);
   _engine = [CPFactory engine: _trail memory:_mt];
   return [self initCPSolverWithEngine: _engine];
}
-(id<CPProgram>) initCPSolverWithEngine: (id<CPEngine>) engine
{
   self = [super initCPCoreSolver];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail memory:_mt];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORDFSController proto]
                                                                  nestedControllerClass: [ORDFSController proto]];
   _search = [ORExplorerFactory explorer: engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}

-(void) dealloc
{
   NSLog(@"CPSolver dealloc'd (%p)",self);
   [_trail release];
   [_mt release];
   [_engine release];
   [_search release];
   [_tracer release];
   [super dealloc];
}

-(void) add: (id<ORConstraint>) c
{
   // PVH: Need to flatten/concretize
   // PVH: Only used    during search
   // LDM: DONE. Have not checked the variable creation/deallocation logic though.
   CPINCModel* trg = [[CPINCModel alloc] init:self];
   ORStatus status = [trg post:c];
   [trg release];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) add: (id<ORConstraint>) c annotation: (ORCLevel) cons
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   // LDM: See above.
   CPINCModel* trg = [[CPINCModel alloc] init:self];
   ORStatus status = [trg post:c];
   [trg release];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^{ bindDom((CPIntVarI*)var, val);}];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^{ [var remove:val];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) labelImplRational: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   ORStatus status = [_engine enforce: ^{ [(CPRationalVarI*)var bind:val];}];
   if (status == ORFailure) {
      //[_failLabel notifyWith:var andInt:val];
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   //[_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^{ [var updateMax:val-1];}];
   if (status == ORFailure) {
      [_failLT notifyWith:var andInt:val];
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [_returnLT notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val+1];}];
   if (status == ORFailure) {
      [_failGT notifyWith:var andInt:val];
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [_returnGT notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine enforce:^{ [var inside:S];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   
   //   ORStatus status = [_engine enforce:^{ [[var domain] setBit:i to:val for:var];}];
   ORStatus status = [_engine enforce:^{ [var bind:i to:val];}];
   if (status == ORFailure ){
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) labelBitsImpl:(id<CPBitVar>)x withValue:(ORInt) v
{
   ORStatus status = [_engine enforce:^{ [(CPBitVarI*)x bindUInt64:(ORULong)v];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) realLabelImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateInterval:createORI1(val)];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) realLthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) realGthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) rationalLthenImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   // WRONG: use LEqual
   //ORRational pval = fp_previous_float(val);
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) rationalGthenImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   // WRONG: use GEqual
   //ORFloat nval = fp_next_float(val);
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) rationalLEqualImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) rationalGEqualImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatLthenImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   ORFloat pval = fp_previous_float(val);
   ORStatus status = [_engine enforce:^{ [var updateMax:pval];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatGthenImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   ORFloat nval = fp_next_float(val);
   ORStatus status = [_engine enforce:^{ [var updateMin:nval];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatLEqualImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatGEqualImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatIntervalImpl: (id<CPFloatVar>) var low: (ORFloat) low up:(ORFloat) up
{
   ORStatus status = [_engine enforce:^{ [var updateInterval:low and:up];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
//--
-(void) doubleLthenImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   ORDouble pval = fp_previous_double(val);
   ORStatus status = [_engine enforce:^{ [var updateMax:pval];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleGthenImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   ORDouble nval = fp_next_double(val);
   ORStatus status = [_engine enforce:^{ [var updateMin:nval];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleLEqualImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleGEqualImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleIntervalImpl: (id<CPDoubleVar>) var low: (ORDouble) low up:(ORDouble) up
{
   ORStatus status = [_engine enforce:^{ [var updateInterval:low and:up];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
@end

/******************************************************************************************/
/*                                   CPSemanticSolver                                     */
/******************************************************************************************/

@implementation CPSemanticSolver {
   CPINCModel* _imdl;
}
-(id<CPSemanticProgram>) initCPSemanticSolver
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _mt   = [ORFactory memoryTrail];
   _closed = makeTRInt(_trail, NO);
   _engine = [CPFactory engine: _trail memory:_mt];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail memory:_mt];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORDFSController proto]
                                                                  nestedControllerClass: [ORDFSController proto]];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}

-(id<CPSemanticProgram>) initCPSemanticSolverDFS
{
   self = [super init];
   _trail = [ORFactory trail];
   _mt    = [ORFactory memoryTrail];
   _engine = [CPFactory engine: _trail memory:_mt];
   _tracer = [[SemTracer alloc] initSemTracer: _trail memory:_mt];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORSemDFSControllerCSP proto]
                                                                  nestedControllerClass: [ORSemDFSControllerCSP proto]];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(id<CPSemanticProgram>) initCPSemanticSolver: (id<ORSearchController>) ctrlProto
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _mt    = [ORFactory memoryTrail];
   _closed = makeTRInt(_trail, NO);
   _engine = [CPFactory engine: _trail memory:_mt];
   _tracer = [[SemTracer alloc] initSemTracer: _trail memory:_mt];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORSemDFSControllerCSP proto]
                                                                  nestedControllerClass: ctrlProto];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(id<CPSemanticProgram>) initCPSolverBackjumpingDFS
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _mt    = [ORFactory memoryTrail];
   _tracer = [[SemTracer alloc] initSemTracer:_trail memory:_mt];
   _engine = [CPFactory learningEngine: _trail memory:_mt tracer:_tracer];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORSemDFSController proto]
                                                                  nestedControllerClass: [ORBackjumpingDFSController proto]];
   
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   _imdl   = [[CPINCModel alloc] init:self];
   [cFact release];
   return self;
}
-(void) dealloc
{
   NSLog(@"CPSemanticSolver dealloc'd [%p]  model RC [%d]",self,(int)[_model retainCount]);
   [_imdl  release];
   [_trail release];
   [_engine release];
   [_search release];
   [_tracer release];
   [super dealloc];
}
-(void) close
{
   [super close];
   _imdl   = [[CPINCModel alloc] init:self];
}
-(void) add: (id<ORConstraint>) c
{
   if ([_imdl post:c] == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
   
}
-(void) add: (id<ORConstraint>) c annotation:(ORCLevel) cons
{
   if ([_imdl post:c] == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   [self labelImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory equalc:self var:var to: val]];
}
-(void) labelRational: (id<ORRationalVar>) var with: (id<ORRational>) val
{
   [self labelImplRational: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory rationalEqualc:self var:var eqc: val]];
}
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   [self diffImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory notEqualc:self var:var to: val]];
}
-(void) lthen: (id<ORIntVar>) var with: (ORInt) val
{
   [self lthenImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory lEqualc:self var:var to:val-1]];
}
-(void) gthen: (id<ORIntVar>) var with: (ORInt) val
{
   [self gthenImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory gEqualc:self var:var to:val+1]];
}
-(void) lthen: (id<ORIntVar>) var double: (ORDouble) val
{
   ORInt iVal = rint(ceil(val));
   [self lthenImpl: _gamma[var.getId] with: iVal];
   [_tracer addCommand: [ORFactory lEqualc:self var:var to:iVal-1]];
}
-(void) gthen: (id<ORIntVar>) var double: (ORDouble) val
{
   ORInt iVal = rint(floor(val));
   [self gthenImpl: _gamma[var.getId] with: iVal];
   [_tracer addCommand: [ORFactory gEqualc:self var:var to:iVal+1]];
}
-(void) realLabel:(id<ORRealVar>)var with:(ORDouble)val
{
   [self realLabelImpl: _gamma[var.getId] with: val];
   [_tracer addCommand: [ORFactory realEqualc:self var:var to:val]];
}
-(void) labelBV: (id<ORBitVar>) var at:(ORUInt) i with:(ORBool)val
{
   [self labelBVImpl: (id<CPBitVar,CPBitVarNotifier>)_gamma[var.getId] at:i with: val];
   [_tracer addCommand: [ORFactory bvEqualBit:self var:var bit:i with:val]];
}

-(void) labelBits:(id<ORBitVar>)x withValue:(ORInt) val
{
   [self labelBitsImpl: _gamma[x.getId] withValue:val];
   [_tracer addCommand: [ORFactory bvEqualc:self var:x to:val]];
}


-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^ {
      bindDom((id)var, val);
      //[var bind: val];
   }];
   if (status == ORFailure) {
      if ([_engine isPropagating])
         failNow();
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ { [var remove:val];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ {  [var updateMax:val-1];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      [_failLT notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLT notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ { [var updateMin:val+1];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      [_failGT notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnGT notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine enforce:^{[var inside:S];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   ORStatus status = [_engine enforce:^{ [var bind:i to:val];}];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      else
         [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) realLabelImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce: ^ {
      [var updateInterval:createORI1(val)];
   }];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) realLthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce: ^ {
      [var updateMax:val];
   }];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) realGthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce: ^ {
      [var updateMin:val];
   }];
   if (status == ORFailure) {
      if (_engine.isPropagating)
         failNow();
      [_search fail];
   }
   [ORConcurrency pumpEvents];
}
-(void) floatLthenImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   ORFloat pval = fp_previous_float(val);
   ORStatus status = [_engine enforce:^{ [var updateMax:pval];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatGthenImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   ORFloat nval = fp_next_float(val);
   ORStatus status = [_engine enforce:^{ [var updateMin:nval];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatLEqualImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatGEqualImpl: (id<CPFloatVar>) var with: (ORFloat) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) floatIntervalImpl: (id<CPFloatVar>) var low: (ORFloat) low up:(ORFloat) up
{
   ORStatus status = [_engine enforce:^{ [var updateInterval:low and:up];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleLthenImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   ORDouble pval = fp_previous_double(val);
   ORStatus status = [_engine enforce:^{ [var updateMax:pval];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleGthenImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   ORDouble nval = fp_next_double(val);
   ORStatus status = [_engine enforce:^{ [var updateMin:nval];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleLEqualImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleGEqualImpl: (id<CPDoubleVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) doubleIntervalImpl: (id<CPDoubleVar>) var low: (ORDouble) low up:(ORDouble) up
{
   ORStatus status = [_engine enforce:^{ [var updateInterval:low and:up];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) rationalLthenImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   // WRONG: use LEqual
   //ORRational pval = fp_previous_float(val);
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) rationalGthenImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   // WRONG: use GEqual
   //ORFloat nval = fp_next_float(val);
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) rationalLEqualImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) rationalGEqualImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) errorLEqualImpl: (id<CPFloatVar>) var with: (id<ORRational>) val
{
   ORStatus status = [_engine enforce:^{ [var updateMaxError:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) errorGEqualImpl: (id<CPRationalVar>) var with: (id<ORRational>) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}

@end


@implementation CPInformerPortal
-(CPInformerPortal*) initCPInformerPortal: (CPSolver*) cp
{
   self = [super init];
   _cp = cp;
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
-(id<ORIdxIntInformer>) retLT
{
   return [_cp retLT];
}
-(id<ORIdxIntInformer>) retGT
{
   return [_cp retGT];
}
-(id<ORIdxIntInformer>) failLabel
{
   return [_cp failLabel];
}
-(id<ORIdxIntInformer>) failLT
{
   return [_cp failLT];
}
-(id<ORIdxIntInformer>) failGT
{
   return [_cp failGT];
}
-(id<ORInformer>) propagateFail
{
   return [[_cp engine] propagateFail];
}
-(id<ORInformer>) propagateDone
{
   return [[_cp engine] propagateDone];
}
@end

@implementation CPSolverFactory
+(id<CPProgram>) solver
{
   return [[[CPSolver alloc] initCPSolver] autorelease];
}

+(id<CPSemanticProgramDFS>) solverBackjumpingDFS
{
   return [[CPSemanticSolver alloc] initCPSolverBackjumpingDFS];
}
+(id<CPSemanticProgramDFS>) semanticSolverDFS
{
   return [[[CPSemanticSolver alloc] initCPSemanticSolverDFS] autorelease];
}
+(id<CPSemanticProgram>) semanticSolver: (id<ORSearchController>) ctrlProto
{
   return [[[CPSemanticSolver alloc] initCPSemanticSolver: ctrlProto] autorelease];
}
@end


@implementation ABSElement
static ABS_FUN funChoice;

-(id) init:(ORDouble)quantity
{
   self = [super init];
   _quantity = quantity;
   _min = 1.0;
   _pquantity = 1.0;
   _quantity = quantity;
   _max = quantity;
   _choice = nil;
   _nb = 0;
   return self;
}
-(id) init
{
   self = [self init:0.0];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORDouble) quantity
{
   switch(funChoice){
      case MIN: return (_nb > 0)?_min:0.0;
      case MAX: return _max;
      case GMEAN: return (_nb > 0)?pow(_pquantity,1./_nb) : 0.0;
      case AMEAN:
      default: return (_nb > 0)?(_quantity/_nb) : 0.0;
   }
}
-(void) addQuantity:(ORFloat) c for:(id<CPVar>)v
{
   if(c > 0.0 && c < 1.0){
      _nb++;
      if(c > _max){
         [self setChoice:v];
      }
      _min = minFlt(c,_min);
      _max = maxFlt(c,_max);
      _pquantity *= c;
      _quantity += c;
   }
}
-(void) setChoice:(CPFloatVarI*) c
{
   _choice = c;
}
-(id<CPVar>) bestChoice
{
   return _choice;
}
-(ORInt) nbAbs
{
   return _nb;
}
+(void) setFunChoice:(ABS_FUN)nfun
{
   funChoice = nfun;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%lf,%d,%@>",_quantity,_nb,_choice];
}
@end

