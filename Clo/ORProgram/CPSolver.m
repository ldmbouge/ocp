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
   ORBool                 _unique;
   ORFloat                _split3Bpercent;
   ORInt                  _searchNBFloats;
   SEL                    _subcut;
   
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
   _level = 100;
   _split3Bpercent = 10.f;
   _searchNBFloats = 2;
   _subcut = @selector(float3BSplit:call:withVars:);
   _unique = NO;
   _doOnStartupArray = [[NSMutableArray alloc] initWithCapacity: 1];
   _doOnSolArray     = [[NSMutableArray alloc] initWithCapacity: 1];
   _doOnExitArray    = [[NSMutableArray alloc] initWithCapacity: 1];
   return self;
}
-(void) dealloc
{
   NSLog(@"CPSolver dealloc'd %p",self);
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
-(void) setLevel:(ORInt) level
{
   _level = level;
}
-(void) setUnique:(ORBool) u
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
      NSLog(@"Optimal Solution: %@ thread:%d\n",[_objective primalBound],[NSThread threadID]);
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
-(ORBool) errorGEqualImpl: (id<CPFloatVar>) var with: (id<ORRational>) val fail: (ORBool) canFail
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
-(void) labelBitVarHeuristic: (id<CPBitVarHeuristic>) h withConcrete:(id<ORVarArray>)av
{
   id<CPBitVarArray> cav = [CPFactory bitVarArray:self range:av.range with:^id<CPBitVar>(ORInt i) {
      CPBitVarI* sv =_gamma[av[i].getId];
      assert([sv isKindOfClass:[CPBitVarI class]]);
      return sv;
   }];
   id<ORSelect> select = [ORFactory selectRandom: _engine
                                           range: RANGE(_engine,[cav low],[cav up])
                                        suchThat: ^ORBool(ORInt i) { return ![cav[i] bound]; }
                                       orderedBy: ^ORDouble(ORInt i) {
                                          ORDouble rv = [h varOrdering:cav[i]];
                                          ORInt bl = [cav[i] bitLength];
                                          return rv / (1 << bl);
                                       }
                                      randomized:NO
                          ];
   
   id<ORRandomStream>   valStream = [ORFactory randomStream:_engine];
   ORMutableIntegerI*   failStamp = [ORFactory mutable:_engine value:-1];
   ORMutableId*              last = [ORFactory mutableId:_engine value:nil];
   __block ORSelectorResult i ;
   do {
      id<CPBitVar> x = [last idValue];
      //      NSLog(@"at top: last = %p",x);
      if ([failStamp intValue]  == [self nbFailures] || (x == nil || [x bound])) {
         i = [select max];
         if (!i.found)
            return;
         x = cav[i.index];
         //         NSLog(@"-->Chose variable: %p=%@",x,x);
         [last setIdValue:x];
      } else {
         //        NSLog(@"STAMP: %d  - %d",[failStamp value],[self nbFailures]);
      }
      NSAssert2([x isKindOfClass:[CPBitVarI class]], @"%@ should be kind of class %@", x, [[CPBitVarI class] description]);
      [failStamp setValue:[self nbFailures]];
      ORFloat bestValue = - MAXFLOAT;
      ORLong bestRand = 0x7fffffffffffffff;
      ORInt low = [x lsFreeBit];
      ORInt up  = [x msFreeBit];
      ORInt bestIndex = - 1;
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
            //            NSLog(@"Setting bit %i of 0x%lx to 0 \n",bestIndex,(unsigned long)x);
            
            //            NSLog(@"Setting bit %i of %@ to 0 at level %i\n",bestIndex,(unsigned long)x,(unsigned int)[(CPLearningEngineI*)_engine getLevel]);
            //            [(CPBitVarI*)x bit:bestIndex setAtLevel:[(CPLearningEngineI*)_engine getLevel]];
            //            NSLog(@"%@\n",[_engine variables]);
            [self labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)x at: bestIndex with:false];
            
         } alt: ^{
            //            NSLog(@"Setting bit %i of 0x%lx to 1 \n",bestIndex,(unsigned long)x);
            //            NSLog(@"Setting bit %i of %@ to 1 at level %i\n",bestIndex,(unsigned long)x,[(CPLearningEngineI*)_engine getLevel]);
            //            NSLog(@"%@",[_engine variables]);
            [self labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)x at: bestIndex with:true];
            //            [(CPBitVarI*)x bit:bestIndex setAtLevel:[(CPLearningEngineI*)_engine getLevel]];
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
   
   /*************************************************************
    Apply SAC constraint to all variables
    ************************************************************/
   //   NSLog(@"Pruning with SAC constraint.");
   //
   //   id<ORTracer> tracer = [self tracer];
   //   ORStatus oc;
   //
   //   ORUInt wordLength;
   //   TRUInt* up;
   //   TRUInt* low;
   //   ORUInt freeBits;
   //   ORUInt failUp = 0;
   //   ORUInt failLow = 0;
   //
   //   for (int i = [av low]; i<[av up];i++){
   //      id<CPBitVar>bv = [av at:i];
   //      wordLength = [(CPBitVarI*)bv getWordLength];
   //      [(CPBitVarI*)bv getUp:&up andLow:&low];
   //
   //      for (int i=0; i<wordLength; i++) {
   //         freeBits = up[i]._val & ~(low[i]._val);
   //         for (int j=0; j<32; j++) {
   //            if (freeBits&1) {
   //               [tracer pushNode];
   //               oc = [_engine enforce:^void{[bv bind:j to:true];[ORConcurrency pumpEvents];}];
   //               if (oc==ORFailure) {
   //                  NSLog(@"Failure in probing for SAC upon search startup.");
   //                  failUp &= 1;
   //                  [tracer popNode];
   //                  freeBits >>= 1;
   //                  [bv bind:(i*32)+j to:false];
   //                  continue;
   //               }
   //               [tracer popNode];
   //
   //               [tracer pushNode];
   //               oc = [_engine enforce:^void{[bv bind:j to:false];[ORConcurrency pumpEvents];}];
   //               if (oc==ORFailure) {
   //                  NSLog(@"Failure in probing for SAC upon search startup.");
   //                  failLow &= 1;
   //                  [tracer popNode];
   //                  [bv bind:(i*32)+j to:true];
   //                  freeBits >>= 1;
   //                  continue;
   //               }
   //               [tracer popNode];
   //            }
   //            freeBits >>= 1;
   //         }
   //         if (failUp & failLow) {
   //            NSLog(@"Backtracking on SAC constraint.");
   //            failNow();
   //         }
   //         for (int k=31; k>=0; k--) {
   //            if (failUp & 1) {
   //               [bv bind:(i*32)+k to:false];
   //            }
   //            if (failLow & 1) {
   //               [bv bind:(i*32)+k to:true];
   //            }
   //            failUp >>= 1;
   //            failLow >>=1;
   //         }
   //      }
   //   }
   
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
   id<ORRational> mid = [[ORRational alloc] init:_mt];
   id<ORRational> two = [[ORRational alloc] init:_mt];
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
}
-(void) floatGthen: (id<ORFloatVar>) var with: (ORFloat) val
{
   [self floatGthenImpl: _gamma[var.getId] with: val];
}
-(void) floatLEqual: (id<ORFloatVar>) var with: (ORFloat) val
{
   [self floatLEqualImpl: _gamma[var.getId] with: val];
}
-(void) floatGEqual: (id<ORFloatVar>) var with: (ORFloat) val
{
   [self floatGEqualImpl: _gamma[var.getId] with: val];
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
//float search
-(void) maxCardinalitySearch: (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    CPFloatVarI* v = _gamma[getId(x[i])];
                                    LOG(_level,2,@"%@",v);
                                    return -cardinality(v);
                                 }];
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(maxCardinalitySearch:do:),x);
      } while (true);
   }];
   
}
-(void) minCardinalitySearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    CPFloatVarI* v = _gamma[getId(x[i])];
                                    LOG(_level,2,@"%@",v);
                                    return cardinality(v);
                                 }];
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(minCardinalitySearch:do:),x);
      } while (true);
   }];
   
}
-(void) maxDensitySearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return -[self density:x[i]];
                                 }];
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(maxDensitySearch:do:),x);
      } while (true);
   }];
}
-(void) minDensitySearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return [self density:x[i]];
                                 }];
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(minDensitySearch:do:),x);
      } while (true);
   }];
   
   
}
-(void) maxWidthSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     //                                     LOG(_level,2,@"%@",v);
                                     if(![x isEnable:i]){
                                        [x enable:i];
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    id<CPFloatVar> v = _gamma[getId(x[i])];
                                    LOG(_level,2,@"%@",v);
                                    return -[v domwidth];
                                 }];
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(maxWidthSearch:do:),x);
      } while (true);
      
   }];
   
}
-(void) minWidthSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    id<CPFloatVar> v = _gamma[getId(x[i])];
                                    LOG(_level,2,@"%@",v);
                                    return [v domwidth];
                                 }];
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(minWidthSearch:do:),x);
      } while (true);
   }];
   
}
-(void) maxMagnitudeSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    id<CPFloatVar> v = _gamma[getId(x[i])];
                                    LOG(_level,2,@"%@",v);
                                    return -[v magnitude];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(maxMagnitudeSearch:do:),x);
      } while (true);
   }];
   
}
-(void) minMagnitudeSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    id<CPFloatVar> v = _gamma[getId(x[i])];
                                    LOG(_level,2,@"%@",v);
                                    return [v magnitude];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(minMagnitudeSearch:do:),x);
      } while (true);
   }];
   
}
-(void) floatSplitArrayOrderedByDomSize: (id<ORDisabledFloatVarArray>) x
{
   SEL s = @selector(floatSplitArrayOrderedByDomSize:);
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   [self forall: RANGE(self, [x low], [x up])
       suchThat: ^ORBool(ORInt i){
          id<CPFloatVar> v = _gamma[getId(x[i])];
          if(![x isEnable:i]){
             disabled.found = YES;
             disabled.index = i;
             return false;
          }
          return ![v bound];
       }
 orderedByFloat: ^ORFloat(ORInt i) {
    id<CPFloatVar> v = _gamma[getId(x[i])];
    return (ORFloat)-[v domwidth];
 }
             do: ^(ORInt i){
                [self float6WaySplit:i call:s withVars:x];
             }];
   if(disabled.found){
      disabled.found = NO;
      [x enable:disabled.index];
      [self float6WaySplit:disabled.index call:s withVars:x];
   }
}
//lexicalorder
-(void) lexicalOrderedSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPVar> v = _gamma[getId(x[i])];
                                     LOG(_level,2,@"%@ %s %s",_gamma[getId(x[i])],[x isEnable:i] ? "" : "disabled",([v bound]) ? "b":"");
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    // LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return (ORDouble)i;
                                 }];
   NSLog(@"%@", [x description]);
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         assert(![_gamma[getId(x[i.index])] bound]);
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(lexicalOrderedSearch:do:),x);
      } while (true);
   }];
   
}
//-------------------------------------------------
// Branch & Bound on error of FloatVar
-(void) branchAndBoundSearch:  (id<ORDisabledFloatVarArray>) x out: (id<ORFloatVar>) z do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   id<ORRational> eB = [[ORRational alloc] init];
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level, 2, @"##############################################################");
         LOG(_level, 2, @"Box at beginning of loop");
         LOG(_level, 2, @"%@", [_engine model]);
         __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
         id<ORSelect> select = [ORFactory select: _engine
                                           range: RANGE(self,[x low],[x up])
                                        suchThat: ^ORBool(ORInt i) {
                                           id<CPVar> v = _gamma[getId(x[i])];
                                           LOG(_level,2,@"%@ %s %s",_gamma[getId(x[i])],[x isEnable:i] ? "" : "disabled",([v bound]) ? "b":"");
                                           if(![x isEnable:i]){
                                              if(![v bound]){
                                                 disabled.found = YES;
                                                 disabled.index = i;
                                              }
                                              [x enable:i];
                                              return false;
                                           }
                                           return ![v bound];
                                        }
                                       orderedBy: ^ORDouble(ORInt i) {
                                          // LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                          return (ORDouble)i;
                                       }];
         
         [[_engine objective] tightenPrimalBound:GlobalPrimalBound];
         [self errorGEqualImpl:_gamma[getId(z)] with:[[[_engine objective] primalBound] rationalValue] fail:YES];
         
         [[_engine objective] updateDualBound];
         
         /********** GuessError **********/
         LOG(_level, 2, @"GuessError");
         [eB setNegInf];
         ORInt iteration = 0;
         ORInt nbIteration = -1;
         id<ORCheckpoint> currentCheckpoint;
         id<ORCheckpoint> solB;
         if([((id<ORRational>)[[[_engine objective] primalBound] rationalValue]) lt: [[[ORRational alloc] init] setZero]]){
            nbIteration = 5;
         } else {
            nbIteration = 3;
         }
         
         //currentCheckpoint = [_tracer captureCheckpoint];
         ORBool isFailed = NO;
         while([[[[_engine objective] primalBound] rationalValue] leq: GlobalPrimalBound] && (iteration < nbIteration)){
            //[_tracer restoreCheckpoint:currentCheckpoint inSolver:_engine model:((id<ORPost>)_model)];
            currentCheckpoint = [_tracer captureCheckpoint];
            while(true) {
               ORSelectorResult index = [select min];
               if(index.found){
                  id<CPFloatVar> currentVar = _gamma[getId(x[index.index])];
                  LOG(_level,2, @"Choosen var: %@",currentVar);
                  if(![currentVar bound]){
                     [currentVar bind:randomValue([currentVar min], [currentVar max])];
                     LOG(_level, 2, @"var fixed at: %@", currentVar);
                     isFailed = [self errorGEqualImpl:_gamma[getId(z)] with:GlobalPrimalBound fail:NO];
                     if(isFailed){
                        //[_tracer restoreCheckpoint:currentCheckpoint inSolver:_engine model:((id<ORPost>)_model)];
                        break;
                     } else {
                        LOG(_level, 2, @"CSP after filtering");
                        LOG(_level, 2, @"%@", [_engine model]);
                        [[_engine objective] updatePrimalBound];
                     }
                  }
               } else {
                  break;
               }
            }
            if(!isFailed){
               ORBool isBound = true;
               for (id<CPFloatVar> v in [_engine variables]) {
                  isBound &= [v bound];
               }
               if(isBound && [((id<ORRational>)[[[_engine objective] primalBound] rationalValue]) gt: eB]){
                  [eB set: [[[_engine objective] primalBound] rationalValue]];
                  solB = [_tracer captureCheckpoint];
               }
               [_tracer restoreCheckpoint:currentCheckpoint inSolver:_engine model:((id<ORPost>)_model)];
            }
            iteration++;
            [_tracer restoreCheckpoint:currentCheckpoint inSolver:_engine model:((id<ORPost>)_model)];
         }
         [_tracer restoreCheckpoint:currentCheckpoint inSolver:_engine model:(id<ORPost>)_model];
         if(!isFailed){
         //[[_engine objective] tightenPrimalBound:eB];
         [GlobalPrimalBound set: eB]; //[[[_engine objective] primalBound] rationalValue]];
         LOG(_level, 2, @"New value of GlobalPrimalBound: %@", GlobalPrimalBound);
         }
         
         //   if([[[[_engine objective] primalBound] rationalValue] eq: eB]){
         //      bestSol = solB;
         //   }
         
         /******************************/
         NSLog(@"%@", [x description]);
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         assert(![_gamma[getId(x[i.index])] bound]);
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(branchAndBoundSearch:out:do:),x);
      } while (true);
   }];
}

//-------------------------------------------------
-(void) maxDegreeSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   id<ORIntArray> deg = [ORFactory intArray:self range:x.range  with:^ORInt(ORInt i) {
      return  [self countMemberedConstraints:x[i]];
   }];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return [deg[i] doubleValue];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select max];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(maxDegreeSearch:do:),x);
      } while (true);
   }];
}
-(void) minDegreeSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   id<ORIntArray> deg = [ORFactory intArray:self range:x.range  with:^ORInt(ORInt i) {
      return  [self countMemberedConstraints:x[i]];
   }];
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return [deg[i] doubleValue];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(minDegreeSearch:do:),x);
      } while (true);
   }];
}
-(void) maxOccurencesSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   id<ORIntArray> occ = [ORFactory intArray:self range:x.range  with:^ORInt(ORInt i) {
      return [self maxOccurences:x[i]];
   }];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return [occ at:i];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select max];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(maxOccurencesSearch:do:),x);
      } while (true);
   }];
}
-(void) minOccurencesSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   id<ORIntArray> occ = [ORFactory intArray:self range:x.range  with:^ORInt(ORInt i) {
      return [self maxOccurences:x[i]];
   }];
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return [occ[i] doubleValue];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         }
         else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(minOccurencesSearch:do:),x);
      } while (true);
   }];
}
-(void) maxAbsorptionSearch:  (id<ORDisabledFloatVarArray>) ovars default:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   //[hzi] collect variables leading to an abs. introduced by flattening, construct new a and call maxabsI
   id<ORFloatVarArray> vars = [_model floatVars];
   NSMutableArray<ORFloatVar> *keeped = [[NSMutableArray<ORFloatVar> alloc] init];
   NSSet* cstr = nil;
   id<CPFloatVar> cx = nil;
   id<CPFloatVar> v = nil;
   ORDouble absV = 0.0;
   for(id<ORFloatVar> x in vars){
      if([ovars contains:x]){
         [keeped addObject:x];
      }else{
         cx = _gamma[[x getId]];
         cstr = [cx constraints];
         for(id<CPConstraint> c in cstr){
            if([c canLeadToAnAbsorption]){
               v = [c varSubjectToAbsorption:cx];
               if(v == nil) continue;
               absV = [self computeAbsorptionQuantity:v by:x];
               assert(absV >= 0.0f && absV <= 1.f);
               if(absV){
                  [keeped addObject:x];
               }
            }
         }
         [cstr release];
      }
   }
   id<ORFloatVarArray> ckeeped = [ORFactory floatVarArray:self range:RANGE(self, 0, (ORInt)[keeped count]-1)];
   ORInt i = 0;
   for(id<ORFloatVar> x in keeped){
      ckeeped[i++] = x;
   }
   [keeped release];
   id<ORDisabledFloatVarArray> newX = [ORFactory disabledFloatVarArray:ckeeped engine:_engine];
   [self maxAbsorptionSearchI:newX default:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
      b(i,s,x);
   }];
}
//-(void) maxAbsorptionSearch:  (id<ORDisabledFloatVarArray>) ovars do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
//{
//   //[hzi] collect variables leading to an abs. introduced by flattening, construct new a and call maxabsI
//   id<ORFloatVarArray> vars = [_model floatVars];
//   NSMutableArray<ORFloatVar> *keeped = [[NSMutableArray<ORFloatVar> alloc] init];
//   NSSet* cstr = nil;
//   id<CPFloatVar> cx = nil;
//   id<CPFloatVar> v = nil;
//   ORDouble absV = 0.0;
//   for(id<ORFloatVar> x in vars){
//      if([ovars contains:x]){
//         [keeped addObject:x];
//      }else{
//         cx = _gamma[[x getId]];
//         cstr = [cx constraints];
//         for(id<CPConstraint> c in cstr){
//            if([c canLeadToAnAbsorption]){
//               v = [c varSubjectToAbsorption:cx];
//               if(v == nil) continue;
//               absV = [self computeAbsorptionQuantity:v by:x];
//               assert(absV >= 0.0f && absV <= 1.f);
//               if(absV){
//                  [keeped addObject:x];
//               }
//            }
//         }
//         [cstr release];
//      }
//   }
//   id<ORFloatVarArray> ckeeped = [ORFactory floatVarArray:self range:RANGE(self, 0, (ORInt)[keeped count]-1)];
//   ORInt i = 0;
//   for(id<ORFloatVar> x in keeped){
//      ckeeped[i++] = x;
//   }
//   [keeped release];
//   id<ORDisabledFloatVarArray> newX = [ORFactory disabledFloatVarArray:ckeeped engine:_engine];
//   [self maxAbsorptionSearchI:newX do:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
//      b(i,s,x);
//   }];
//}
-(void) maxAbsorptionSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return [self computeAbsorptionRate:x[i]];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select max];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         }
         else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(maxAbsorptionSearch:do:),x);
      } while (true);
   }];
}
-(void) maxAbsorptionSearchI: (id<ORDisabledFloatVarArray>) x default:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   @autoreleasepool {
      SEL s = @selector(maxAbsorptionSearchI:default:);
      __block id<ORIdArray> abs = [self computeAbsorptionsQuantities:x];
      ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
      __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
      id<ORSelect> select = [ORFactory select: _engine
                                        range: RANGE(self,[x low],[x up])
                                     suchThat: ^ORBool(ORInt i) {
                                        id<CPFloatVar> v = _gamma[getId(x[i])];
                                        if(![x isEnable:i]){
                                           if(![v bound]){
                                              disabled.found = YES;
                                              disabled.index = i;
                                           }
                                           [x enable:i];
                                           return false;
                                        }
                                        return ![v bound];
                                     }
                                    orderedBy: ^ORDouble(ORInt i) {
                                       LOG(_level,2,@"%@ rate : %16.16e",_gamma[getId(x[i])], [abs[i] quantity]);
                                       return [abs[i] quantity];
                                    }];
      
      [[self explorer] applyController:t in:^{
         do {
            LOG(_level,2,@"State before selection");
            ORSelectorResult i = [select max];
            if (!i.found){
               if(!disabled.found)
                  break;
               i.index = disabled.index;
               [x enable:i.index];
            } else if(_unique){
               [x disable:i.index];
               disabled.found = NO;
            }
            id<CPFloatVar> v = [abs[i.index] bestChoice];
            LOG(_level,2,@"selected variables: %@ and %@",_gamma[getId(x[i.index])],v);
            [self floatAbsSplit:i.index by:v call:s withVars:x default:b];
            abs = [self computeAbsorptionsQuantities:x];
         } while (true);
      }];
   }
}
-(void) minAbsorptionSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return -[self computeAbsorptionRate:x[i]];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(minAbsorptionSearch:do:),x);
      } while (true);
   }];
}
-(void) minAbsorptionSearch: (id<ORDisabledFloatVarArray>) x default:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   @autoreleasepool {
      SEL s = @selector(minAbsorptionSearch:default:);
      __block id<ORIdArray> abs = [self computeAbsorptionsQuantities:x];
      ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
      __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
      id<ORSelect> select = [ORFactory select: _engine
                                        range: RANGE(self,[x low],[x up])
                                     suchThat: ^ORBool(ORInt i) {
                                        id<CPFloatVar> v = _gamma[getId(x[i])];
                                        if(![x isEnable:i]){
                                           if(![v bound]){
                                              disabled.found = YES;
                                              disabled.index = i;
                                           }
                                           [x enable:i];
                                           return false;
                                        }
                                        return ![v bound];
                                     }
                                    orderedBy: ^ORDouble(ORInt i) {
                                       LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                       return [abs[i] quantity];
                                    }];
      
      [[self explorer] applyController:t in:^{
         do {
            LOG(_level,2,@"State before selection");
            ORSelectorResult i = [select min];
            if (!i.found){
               if(!disabled.found)
                  break;
               i.index = disabled.index;
               [x enable:i.index];
            } else if(_unique){
               [x disable:i.index];
            }
            disabled.found = NO;
            id<CPFloatVar> v = [abs[i.index] bestChoice];
            LOG(_level,2,@"selected variables: %@ and %@",_gamma[getId(x[i.index])],v);
            [self floatAbsSplit:i.index by:v call:s withVars:x default:b];
            abs = [self computeAbsorptionsQuantities:x];
         } while (true);
      }];
   }
}

-(void) maxCancellationSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return [self cancellationQuantity:x[i]];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select max];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(maxCancellationSearch:do:),x);
      } while (true);
   }];
}
-(void) minCancellationSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
                                  }
                                 orderedBy: ^ORDouble(ORInt i) {
                                    LOG(_level,2,@"%@",_gamma[getId(x[i])]);
                                    return [self cancellationQuantity:x[i]];
                                 }];
   
   [[self explorer] applyController:t in:^{
      do {
         LOG(_level,2,@"State before selection");
         ORSelectorResult i = [select min];
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
         b(i.index,@selector(minCancellationSearch:do:),x);
      } while (true);
   }];
}
-(void) combinedAbsWithDensSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   id<ORIntArray> considered = [ORFactory intArray:self range:x.range value:0];
   __block ORDouble taux = 0.0;
   __block ORBool found = NO;
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x  up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
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
         }
         if (!i.found){
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
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
         b(i.index,@selector(combinedAbsWithDensSearch:do:),x);
      } while (true);
   }];
}

-(void) combinedDensWithAbsSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   id<ORIntArray> considered = [ORFactory intArray:self range:x.range value:0];
   id<ORDoubleArray> dens = [ORFactory doubleArray:self range:x.range value:0.0];
   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
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
                                     if(![x isEnable:i]){
                                        if(![v bound]){
                                           disabled.found = YES;
                                           disabled.index = i;
                                        }
                                        [x enable:i];
                                        return false;
                                     }
                                     return ![v bound];
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
            if(!disabled.found)
               break;
            i.index = disabled.index;
            [x enable:i.index];
         } else if(_unique){
            [x disable:i.index];
         }
         disabled.found = NO;
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
         b(i.index,@selector(combinedDensWithAbsSearch:do:),x);
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


-(void) switchedSearch:  (id<ORDisabledFloatVarArray>) x do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
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

-(void) maxAbsDensSearch:  (id<ORDisabledFloatVarArray>) ovars default:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   //[hzi] collect variables leading to an abs. introduced by flattening, construct new a and call maxabsI
   id<ORFloatVarArray> vars = [_model floatVars];
   NSMutableArray<ORFloatVar> *keeped = [[NSMutableArray<ORFloatVar> alloc] init];
   NSSet* cstr = nil;
   id<CPFloatVar> cx = nil;
   id<CPFloatVar> v = nil;
   ORDouble absV = 0.0;
   for(id<ORFloatVar> x in vars){
      if([ovars contains:x]){
         [keeped addObject:x];
      }else{
         cx = _gamma[[x getId]];
         cstr = [cx constraints];
         for(id<CPConstraint> c in cstr){
            if([c canLeadToAnAbsorption]){
               v = [c varSubjectToAbsorption:cx];
               if(v == nil) continue;
               absV = [self computeAbsorptionQuantity:v by:x];
               assert(absV >= 0.0f && absV <= 1.f);
               if(absV){
                  [keeped addObject:x];
               }
            }
         }
         [cstr release];
      }
   }
   id<ORFloatVarArray> ckeeped = [ORFactory floatVarArray:self range:RANGE(self, 0, (ORInt)[keeped count]-1)];
   ORInt i = 0;
   for(id<ORFloatVar> x in keeped){
      ckeeped[i++] = x;
   }
   [keeped release];
   id<ORDisabledFloatVarArray> newX = [ORFactory disabledFloatVarArray:ckeeped engine:_engine];
   [self maxAbsDensSearchI:newX default:^(ORUInt i, SEL s, id<ORDisabledFloatVarArray> x) {
      b(i,s,x);
   }];
}

//hzi version splitAbs
-(void) maxAbsDensSearchI: (id<ORDisabledFloatVarArray>) x default:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   @autoreleasepool {
      SEL s = @selector(maxAbsDensSearchI:default:);
      __block id<ORIdArray> abs = [self computeAbsorptionsQuantities:x];
      ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
      __block ORInt switchneeded = true;
      __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
      id<ORSelect> select = [ORFactory select: _engine
                                        range: RANGE(self,[x low],[x up])
                                     suchThat: ^ORBool(ORInt i) {
                                        id<CPFloatVar> v = _gamma[getId(x[i])];
                                        if(![x isEnable:i]){
                                           if(![v bound]){
                                              disabled.found = YES;
                                              disabled.index = i;
                                           }
                                           [x enable:i];
                                           return false;
                                        }
                                        return ![v bound];
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
               [self maxDensitySearch:x  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
                  //                                    [self floatSplit:i call:s withVars:x];
                  [self float6WaySplit:i call:s withVars:x];
               }];
            }else{
               if (!i.found){
                  if(!disabled.found)
                     break;
                  i.index = disabled.index;
                  [x enable:i.index];
               } else if(_unique){
                  [x disable:i.index];
                  disabled.found = NO;
               }
               id<CPFloatVar> v = [abs[i.index] bestChoice];
               LOG(_level,2,@"selected variables: %@ and %@",_gamma[getId(x[i.index])],v);
               [self floatAbsSplit:i.index by:v call:s withVars:x default:b];
               abs = [self computeAbsorptionsQuantities:x];
               switchneeded = true;
            }
         } while (true);
      }];
   }
}


//
//-(void) maxAbsDensSearch: (id<ORDisabledFloatVarArray>) x default:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
//{
//   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
//   __block ORSelectorResult disabled = (ORSelectorResult) {NO,0};
//   SEL s = @selector(maxAbsDensSearch:default:);
//   __block ORInt switchneeded = true;
//   id<ORSelect> select = [ORFactory select: _engine
//                                     range: RANGE(self,[x low],[x up])
//                                  suchThat: ^ORBool(ORInt i) {
//                                     id<CPFloatVar> v = _gamma[getId(x[i])];
//                                     if(![x isEnable:i]){
//                                        if(![v bound]){
//                                           disabled.found = YES;
//                                           disabled.index = i;
//                                        }
//                                        [x enable:i];
//                                        return false;
//                                     }
//                                     return ![v bound];
//                                  }
//                                 orderedBy: ^ORDouble(ORInt i) {
//                                    ORDouble res = [self computeAbsorptionRate:x[i]];
//                                    LOG(_level,2,@"%@ abs : %16.16e",_gamma[getId(x[i])],res);
//                                     switchneeded = switchneeded && !(res > 0.f);
//                                    return res;
//                                 }];
//
//   [[self explorer] applyController:t in:^{
//      do {
//         LOG(_level,2,@"State before selection");
//         ORSelectorResult i = [select max];
//         if(switchneeded & i.found){
//             [self maxDensitySearch:x  do:^(ORUInt i,SEL s,id<ORDisabledFloatVarArray> x) {
////                [self floatSplit:i call:s withVars:x];
//                              [self float6WaySplit:i call:s withVars:x];
//               }];
//            }else{
//         if (!i.found){
//            if(!disabled.found)
//               break;
//            i.index = disabled.index;
//            [x enable:i.index];
//         }
//         else if(_unique){
//            [x disable:i.index];
//         }
//         disabled.found = NO;
//         LOG(_level,2,@"selected variable: %@",_gamma[getId(x[i.index])]);
////         [self float6WaySplit:i.index call:s withVars:x];
//         [self floatSplit:i.index call:s withVars:x];
//         switchneeded = true;
//      }
//      } while (true);
//   }];
//}
//-------------------------------------------------
//Value ordering
//split until value
-(void) floatStaticSplit: (ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   while (![xi bound]) {
      [self floatSplit:i call:s withVars:x];
   }
}
//static 3 split
-(void) floatStatic3WaySplit: (ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   while (![xi bound]) {
      [self float3WaySplit:i call:s withVars:x];
   }
}
//static split in 5 way until the var is bound
-(void) floatStatic5WaySplit: (ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   while (![xi bound]) {
      [self float5WaySplit:i call:s withVars:x];
   }
}
//static split in 6 way until the var is bound
-(void) floatStatic6WaySplit: (ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   while (![xi bound]) {
      [self float6WaySplit:i call:s withVars:x];
   }
}
-(void) floatAbsSplit:(ORUInt)i by:(id<CPFloatVar>) y call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x default:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b
{
   if(y == nil) {
      b(i,s,x);
      return;
   }
   float_interval interval[18];
   float_interval interval_x[3];
   float_interval interval_y[3];
   ORInt length_x = 0;
   ORInt length_y = 0;
   id<CPFloatVar> cx = _gamma[getId(x[i])];
   if([cx bound] && [y bound]) return;
   float_interval ax = computeAbsorbingInterval((CPFloatVarI*)cx);
   float_interval ay = computeAbsordedInterval((CPFloatVarI*)cx);
   if(isIntersectingWithV([y min],[y max],ay.inf,ay.sup)){
      ay.inf = maxFlt(ay.inf, [y min]);
      ay.sup = minFlt(ay.sup, [y max]);
      length_y = !([y min] == ay.inf) + !([y max] == ay.sup);
      interval_y[0] = ay;
      if(ay.inf > [y min] && [y max] > ay.sup){
         interval_y[1] = makeFloatInterval([y min],fp_previous_float(ay.inf));
         interval_y[2] = makeFloatInterval(fp_next_float(ay.sup), [y max]);
      }
      else if(ay.inf == [y min]){
         interval_y[1] = makeFloatInterval(fp_next_float(ay.sup),[y max]);
      }else {
         interval_y[1] = makeFloatInterval([y min],fp_previous_float(ay.inf));
      }
   }else{
      interval_y[0] = makeFloatInterval([y min], [y max]);
      length_y = 0;
   }
   length_x = !([cx min] == ax.inf) + !([cx max] == ax.sup);
   interval_x[0].inf = maxFlt([cx min],ax.inf);
   interval_x[0].sup = minFlt([cx max],ax.sup);
   ORInt i_x = 1;
   ORFloat xmax = [cx max];
   if(ax.sup == [cx max]){
      interval_x[1].inf = minFlt([cx min],fp_next_float(ax.inf));
      interval_x[1].sup = fp_next_float(ax.inf);
   }else{
      if(-ax.sup < [cx max]){
         interval_x[i_x].inf = -ax.sup;
         interval_x[i_x].sup = [cx max];
         xmax = -ax.sup;
         length_x++;
         i_x++;
      }
      interval_x[i_x].inf = fp_next_float(ax.sup);
      interval_x[i_x].sup = fp_previous_float(xmax);
   }
   if(length_x >= 1 && length_y >= 1){
      ORInt length = 0;
      for(ORInt i = 0; i <= length_x;i++){
         for(ORInt j = 0; j <= length_y;j++){
            interval[length] = interval_x[i];
            length++;
            interval[length] = interval_y[j];
            length++;
         }
      }
      float_interval* ip = interval;
      length--;
      [_search tryall:RANGE(self,0,length/2) suchThat:nil in:^(ORInt i) {
         LOG(_level,1,@"START #choices:%d x %@ in [%16.16e,%16.16e]\t y %@ in [%16.16e,%16.16e]",[[self explorer] nbChoices],cx,ip[2*i].inf,ip[2*i].sup,y,ip[2*i+1].inf,ip[2*i+1].sup);
         [self floatIntervalImpl:cx low:ip[2*i].inf up:ip[2*i].sup];
         [self floatIntervalImpl:y low:ip[2*i+1].inf up:ip[2*i+1].sup];
      }];
   }else{
      b(i,s,x);
      //      b(y);
   }
}
-(void) float3BSplit:(ORUInt)index call:(SEL)s withVars:(id<ORDisabledFloatVarArray>)x
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
      [self floatSplit:index call:s withVars:x];
   }
}
-(void) shave :(ORUInt) index direction:(ORInt) d percent:(ORFloat)p coef:(ORInt)c  call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
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
            [self performSelector:s withObject:x withObject:^(ORUInt ind, SEL call,id<ORDisabledFloatVarArray> vs){
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
-(void) floatSplit:(ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   if([xi bound]) return;
   ORFloat theMax = xi.max;
   ORFloat theMin = xi.min;
   ORFloat mid = theMin; //force to the left side if next(theMin) == theMax
   if(fp_next_float(theMin) != theMax){
      ORFloat tmpMax = (theMax == +infinityf()) ? maxnormalf() : theMax;
      ORFloat tmpMin = (theMin == -infinityf()) ? -maxnormalf() : theMin;
      assert(!(is_infinityf(tmpMax) && is_infinityf(tmpMin)));
      mid = tmpMin/2 + tmpMax/2;
   }
   if(mid == theMax)
      mid = theMin;
   assert(mid != NAN && mid <= xi.max && mid >= xi.min);
   [_search try: ^{
      LOG(_level,1,@"START #choices:%d %@ try x > %16.16e",[[self explorer] nbChoices],xi,mid);
      [self floatGthenImpl:xi with:mid];
   } alt: ^{
      LOG(_level,1,@"START #choices:%d %@ alt x <= %16.16e",[[self explorer] nbChoices],xi,mid);
      [self floatLEqualImpl:xi with:mid];
   }
    ];
}
//split in 3 intervals Once
-(void) float3WaySplit:(ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   if([xi bound]) return;
   ORFloat theMax = xi.max;
   ORFloat theMin = xi.min;
   ORFloat mid;
   ORInt length = 1;
   float_interval interval[3];
   if(fp_next_float(theMin) == theMax){
      interval[0].inf = interval[0].sup = theMin;
      interval[1].inf = interval[1].sup = theMax;
   }else{
      ORFloat tmpMax = (theMax == +infinityf()) ? maxnormalf() : theMax;
      ORFloat tmpMin = (theMin == -infinityf()) ? -maxnormalf() : theMin;
      mid = tmpMin/2 + tmpMax/2;
      assert(!(is_infinityf(tmpMax) && is_infinityf(tmpMin)));
      interval[1].inf  = mid;
      interval[1].sup = mid;
      interval[0].inf  = theMin;
      interval[0].sup = fp_previous_float(mid);
      interval[2].inf = fp_next_float(mid);
      interval[2].sup = theMax;
      length++;
   }
   float_interval* ip = interval;
   [_search tryall:RANGE(self,0,length) suchThat:nil in:^(ORInt i) {
      LOG(_level,1,@"(3split) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[self explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [self floatIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
//split in 5 intervals Once
-(void) float5WaySplit:(ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   if([xi bound]) return;
   float_interval interval[5];
   ORInt length = 0;
   ORFloat theMax = xi.max;
   ORFloat theMin = xi.min;
   ORFloat mid;
   length = 1;
   interval[0].inf = interval[0].sup = theMax;
   interval[1].inf = interval[1].sup = theMin;
   if(fp_next_float(theMin) == fp_previous_float(theMax)){
      mid = fp_next_float(theMin);
      interval[2].inf = interval[2].sup = mid;
      length = 2;
   }else{
      ORFloat tmpMax = (theMax == +infinityf()) ? maxnormalf() : theMax;
      ORFloat tmpMin = (theMin == -infinityf()) ? -maxnormalf() : theMin;
      mid = tmpMin/2 + tmpMax/2;
      assert(!(is_infinityf(tmpMax) && is_infinityf(tmpMin)));
      //force the interval to right side
      if(mid == fp_previous_float(theMax)){
         mid = fp_previous_float(mid);
      }
      interval[2].inf = interval[2].sup = mid;
      interval[3].inf = fp_next_float(mid);
      interval[3].sup = fp_previous_float(theMax);
      length = 3;
      if(fp_next_float(theMin) != mid){
         interval[4].inf = fp_next_float(theMin);
         interval[4].sup = fp_previous_float(mid);
         length++;
      }
   }
   float_interval* ip = interval;
   [_search tryall:RANGE(self,0,length) suchThat:nil in:^(ORInt i) {
      LOG(_level,1,@"START #choices:%d x %@ in [%16.16e,%16.16e]",[[self explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [self floatIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
//split in 6 intervals Once
-(void) float6WaySplit: (ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   if([xi bound]) return;
   float_interval interval[6];
   ORFloat theMax = xi.max;
   ORFloat theMin = xi.min;
   ORBool minIsInfinity = (theMin == -infinityf()) ;
   ORBool maxIsInfinity = (theMax == infinityf()) ;
   ORBool only2float = (fp_next_float(theMin) == theMax);
   ORBool only3float = (fp_next_float(theMin) == fp_previous_float(theMax));
   interval[0].inf = interval[0].sup = theMax;
   ORInt length = 1;
   if(!(only2float || only3float)){
      //au moins 4 floatants
      ORFloat tmpMax = (theMax == +infinityf()) ? maxnormalf() : theMax;
      ORFloat tmpMin = (theMin == -infinityf()) ? -maxnormalf() : theMin;
      ORFloat mid = tmpMin/2 + tmpMax/2;
      
      assert(!(is_infinityf(tmpMax) && is_infinityf(tmpMin)));
      ORFloat midInf = -0.0f;
      ORFloat midSup = +0.0f;
      if(!((minIsInfinity && maxIsInfinity) || (minIsInfinity && !mid) || (maxIsInfinity && ! mid))){
         midInf = fp_nextafterf(mid,-INFINITY);
         midSup = mid;
      }
      ORFloat midSupNext = nextafterf(midSup,+INFINITY);
      ORFloat supPrev = nextafterf(theMax,-INFINITY);
      ORFloat midInfPrev = nextafterf(midInf,-INFINITY);
      ORFloat infNext = nextafterf(theMin,+INFINITY);
      
      interval[2].inf = interval[2].sup = midSup;
      interval[3].inf = interval[3].sup = midInf;
      interval[1].inf = interval[1].sup = theMin;
      length+=3;
      if(midSupNext != supPrev){
         interval[length].inf = midSupNext;
         interval[length].sup = supPrev;
         length++;
      }
      if(midInfPrev != infNext){
         interval[length].sup = midInfPrev;
         interval[length].inf = infNext;
         length++;
      }
   }else if(only2float){
      if(is_eqf(theMax,+0.0f) || is_eqf(theMin,-0.0)){
         interval[1].inf = interval[1].sup = +0.0f;
         interval[2].inf = interval[2].sup = -0.0f;
         length += 2;
      }
      interval[length].inf = interval[length].sup = theMin;
      length++;
   }else{
      //forcement 3 floattants
      if(is_eqf(theMax,+0.0f) || is_eqf(theMin,-0.0)){
         interval[1].inf = interval[1].sup = +0.0f;
         interval[2].inf = interval[2].sup = -0.0f;
         length += 2;
      }else{
         ORFloat mid = nextafterf(theMin,+INFINITY);
         interval[1].inf = interval[1].sup = mid;
         length++;
         
      }
      interval[length].inf = interval[length].sup = theMin;
      length++;
   }
   float_interval* ip = interval;
   length--;
   [_search tryall:RANGE(self,0,length) suchThat:nil in:^(ORInt i) {
      LOG(_level,1,@"(6split) START #choices:%d x %@ in [%16.16e,%16.16e]",[[self explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [self floatIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
-(void) floatDeltaSplit:(ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   if([xi bound]) return;
   float_interval interval[5];
   ORInt length = 1;
   if(fp_next_float(xi.min) == xi.max){
      updateFTWithValues(&interval[0], xi.min, xi.min);
      updateFTWithValues(&interval[1], xi.max, xi.max);
   }else{
      ORFloat tmpMax = (xi.max == +infinityf()) ? maxnormalf() : xi.max;
      ORFloat tmpMin = (xi.min == -infinityf()) ? -maxnormalf() : xi.min;
      ORFloat mid = tmpMin/2 + tmpMax/2;
      ORFloat deltaMin = next_nb_float(tmpMin,_searchNBFloats- (xi.min == -infinityf()),mid);
      ORFloat deltaMax = previous_nb_float(tmpMax,_searchNBFloats - (xi.max == +infinityf()),fp_next_float(mid));
      updateFTWithValues(&interval[0],xi.min,deltaMin);
      updateFTWithValues(&interval[1],deltaMax,xi.max);
      length++;
      if(deltaMin < mid && deltaMax > mid){
         updateFTWithValues(&interval[2],mid,mid);
         length++;
         if(fp_next_float(deltaMin) != fp_previous_float(mid)){
            updateFTWithValues(&interval[3],fp_next_float(deltaMin),fp_previous_float(mid));
            length++;
         }
         if(deltaMax > fp_next_float(mid)){
            updateFTWithValues(&interval[4],fp_next_float(mid),fp_previous_float(deltaMax));
            length++;
         }
      }
   }
   float_interval* ip = interval;
   [_search tryall:RANGE(self,0,length) suchThat:nil in:^(ORInt i) {
      LOG(_level,1,@"(Deltasplit) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[self explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [self floatIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
-(void) floatEWaySplit: (ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPFloatVar> xi = _gamma[getId(x[i])];
   if([xi bound]) return;
   ORInt nb = 2*_searchNBFloats+4;
   float_interval interval[nb];//to check + assert
   ORInt length = 1;
   if(fp_next_float(xi.min) == xi.max){
      updateFTWithValues(&interval[0], xi.min, xi.min);
      updateFTWithValues(&interval[1], xi.max, xi.max);
   }else{
      ORFloat tmpMax = (xi.max == +infinityf()) ? maxnormalf() : xi.max;
      ORFloat tmpMin = (xi.min == -infinityf()) ? -maxnormalf() : xi.min;
      ORFloat mid = tmpMin/2 + tmpMax/2;
      ORFloat deltaMin = next_nb_float(tmpMin,_searchNBFloats - (xi.min == -infinityf()),mid);
      ORFloat deltaMax = previous_nb_float(tmpMax,_searchNBFloats - (xi.max == +infinityf()),fp_next_float(mid));
      for(ORFloat v = xi.min; v <= deltaMin; v = fp_next_float(v)){
         updateFTWithValues(&interval[length-1], v,v);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
      }
      for(ORFloat v = xi.max; v >= deltaMax; v = fp_previous_float(v)){
         updateFTWithValues(&interval[length-1],v,v);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
      }
      if(deltaMin < mid && deltaMax > mid){
         updateFTWithValues(&interval[length-1], mid,mid);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
         if(fp_next_float(deltaMin) != fp_previous_float(mid)){
            updateFTWithValues(&interval[length-1],fp_next_float(deltaMin),fp_previous_float(mid));
            assert(length-1 >= 0 && length-1 < nb);
            length++;
         }
         if(deltaMax > fp_next_float(mid)){
            updateFTWithValues(&interval[length-1],fp_next_float(mid),fp_previous_float(deltaMax));
            assert(length-1 >= 0 && length-1 < nb);
            length++;
         }
      }
   }
   float_interval* ip = interval;
   [_search tryall:RANGE(self,0,length) suchThat:nil in:^(ORInt i) {
      LOG(_level,1,@"(Esplit) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[self explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [self floatIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}

-(void) floatSplitD:(ORUInt) i call:(SEL)s withVars:(id<ORDisabledFloatVarArray>) x
{
   id<CPDoubleVar> xi = _gamma[getId(x[i])];
   if([xi bound]) return;
   ORDouble theMax = xi.max;
   ORDouble theMin = xi.min;
   ORDouble mid = theMin; //force to the left side if next(theMin) == theMax
   if(fp_next_double(theMin) != theMax){
      ORDouble tmpMax = (theMax == +infinity()) ? maxnormal() : theMax;
      ORDouble tmpMin = (theMin == -infinity()) ? -maxnormal() : theMin;
      assert(!(is_infinity(tmpMax) && is_infinity(tmpMin)));
      mid = tmpMin/2 + tmpMax/2;
   }
   if(mid == theMax)
      mid = theMin;
   assert(mid != NAN && mid <= xi.max && mid >= xi.min);
   [_search try: ^{
      LOG(_level,1,@"START #choices:%d %@ try x > %16.16e",[[self explorer] nbChoices],xi,mid);
      [self doubleGthenImpl:xi with:mid];
   } alt: ^{
      LOG(_level,1,@"START #choices:%d %@ alt x <= %16.16e",[[self explorer] nbChoices],xi,mid);
      [self doubleLEqualImpl:xi with:mid];
   }
    ];
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
-(void) switchSearchOnDepthUsingProperties:(ORDouble(^)(id<ORFloatVar>)) criteria1 to: (ORDouble(^)(id<ORFloatVar>)) criteria2 do:(void(^)(ORUInt,SEL,id<ORDisabledFloatVarArray>))b limit: (ORInt) depth restricted:(id<ORDisabledFloatVarArray>) x
{
   ORTrackDepth * t = [[ORTrackDepth alloc] initORTrackDepth:_trail tracker:self];
   id<ORSelect> select = [ORFactory select: _engine
                                     range: RANGE(self,[x low],[x up])
                                  suchThat: ^ORBool(ORInt i) {
                                     id<CPFloatVar> v = _gamma[getId(x[i])];
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
         b(i.index,@selector(switchSearchOnDepthUsingProperties:to:do:limit:restricted:),x);
      } while (true);
   }];
}
-(void) once: (ORClosure) cl
{
   [_search once: cl];
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
   [((id<CPRealVar>)_gamma[x.getId]) assignRelaxationValue: f];
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
   NSMutableSet* cstr = [cx constraints];
   ORUInt cpt = (ORUInt) [cstr count];
   [cstr release];
   return cpt;
}
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

-(ORDouble) computeAbsorptionQuantity:(id<CPFloatVar>)y by:(id<ORFloatVar>)x
{
   CPFloatVarI* cx = _gamma[getId(x)];
   CPFloatVarI* cy = (CPFloatVarI*) y;
   float_interval ax = computeAbsordedInterval(cx);
   if(isIntersectingWithV(ax.inf, ax.sup, [cy min], [cy max])){
      return cardinalityV(maxFlt(ax.inf, [cy min]),minFlt(ax.sup, [cy max]))/cardinality(cy);
   }
   return 0.0;
}
-(id<ORIdArray>) computeAbsorptionsQuantities:(id<ORDisabledFloatVarArray>) vars
{
   ORInt size = (ORInt)[vars count];
   id<ORIdArray> abs = [ORFactory idArray:self range:RANGE(self,0,size-1)];
   ORDouble absV;
   for(ORInt i = 0; i < size; i++){
      ABSElement* ae = [[ABSElement alloc] init];
      [self trackObject:ae];
      abs[i] = ae;
   }
   ORUInt i = 0;
   CPFloatVarI* cx;
   id<CPFloatVar> v;
   ORDouble best_rate;
   for (id<ORFloatVar> x in vars) {
      cx = _gamma[[x getId]];
      best_rate = 0.0;
      NSMutableSet* cstr = [cx constraints];
      for(id<CPConstraint> c in cstr){
         if([c canLeadToAnAbsorption]){
            v = [c varSubjectToAbsorption:cx];
            if(v == nil) continue;
            absV = [self computeAbsorptionQuantity:v by:x];
            assert(absV >= 0.0f && absV <= 1.f);
            if(absV){
               [abs[i] addQuantity:absV];
               if(absV > best_rate) [abs[i] setChoice:v];
            }
         }
      }
      [cstr release];
      i++;
   }
   return  abs;
}
-(ORDouble) computeAbsorptionRate:(id<ORVar>) x
{
   CPFloatVarI* cx = _gamma[[x getId]];
   NSMutableSet* cstr = [cx constraints];
   ORDouble rate = 0.0;
   id<CPFloatVar> v;
   for(id<CPConstraint> c in cstr){
      if([c canLeadToAnAbsorption]){
         v = [c varSubjectToAbsorption:cx];
         rate += [self computeAbsorptionQuantity:v by:(id<ORFloatVar>)x];
      }
   }
   [cstr release];
   return rate;
}
-(ORDouble)  cancellationQuantity:(id<ORVar>) x
{
   CPFloatVarI* cx = _gamma[[x getId]];
   NSMutableSet* cstr = [cx constraints];
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

-(NSSet*) constraints: (id<ORVar>)x
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
//-(id<CPProgram>) initCPSolverBackjumpingDFS
//{
//   self = [super initCPCoreSolver];
//   _trail = [ORFactory trail];
//   _mt    = [ORFactory memoryTrail];
//   _tracer = [[SemTracer alloc] initSemTracer:_trail memory:_mt];
////   _tracer = [[DFSTracer alloc] initDFSTracer: _trail memory:_mt];
//   _engine = [CPFactory learningEngine: _trail memory:_mt tracer:_tracer];
//   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
////                                                                    rootControllerClass: [ORDFSController class]
//                                                                    rootControllerClass: [ORSemDFSController class]
////                                                                  nestedControllerClass: [ORDFSController class]];
//                                                                  nestedControllerClass: [ORSemDFSController class]];
//   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
//   [cFact release];
//   return self;
//}

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
   // PVH: Only used	 during search
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
   //changed by gaj 08/07/15
   ORStatus status = [_engine enforce:^{ [[var domain] setBit:i to:val for:var];}];
   //   ORStatus status = [_engine enforce:^{ [var bind:i to:val];}];
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
   ORStatus status = [_engine enforce:^ { [[var domain] setBit:i to:val for:var];}];
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
      //[_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   //[_returnLabel notifyWith:var andInt:val];
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
      //[_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   //[_returnLabel notifyWith:var andInt:val];
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
      //[_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   //[_returnLabel notifyWith:var andInt:val];
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
-(ORBool) errorGEqualImpl: (id<CPFloatVar>) var with: (id<ORRational>) val fail: (ORBool) canFail
{
   ORStatus status = [_engine enforce:^{ [var updateMinError:val];}];
   if(canFail){
      if (status == ORFailure){
         [_search fail];
         return YES;
      }
      return NO;
   } else {
      if (status == ORFailure)
         return YES;
   }
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
//hzi should redefine release
@implementation ABSElement

-(id) init:(ORDouble)quantity
{
   self = [super init];
   _quantity = quantity;
   _choice = nil;
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
   return _quantity;
}
-(void) addQuantity:(ORFloat) c
{
   _quantity += c;
}
-(void) setChoice:(CPFloatVarI*) c
{
   _choice = c;
}
-(id<CPFloatVar>) bestChoice
{
   return _choice;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%lf,%@>",_quantity,_choice];
}
@end
