/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORConcurrency.h>
#import <ORFoundation/ORExplorer.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORFlatten.h>
#import <ORProgram/ORProgram.h>
#import <ORProgram/CPProgram.h>

#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPIntVarI.h>

#if defined(__linux__)
#import <values.h>
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
   _doOnStartupArray = [[NSMutableArray alloc] initWithCapacity: 1];
   _doOnSolArray     = [[NSMutableArray alloc] initWithCapacity: 1];
   _doOnExitArray    = [[NSMutableArray alloc] initWithCapacity: 1];
   return self;
}
-(void) dealloc
{
   NSLog(@"CPSolver dealloc'd %p",self);
   [_model release];
   [_hSet release];
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
               [_engine nbVars],[_engine nbConstraints],[_search nbChoices],[_search nbFailures],[_engine nbPropagation]];
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
   return [_search nbFailures];
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
   return [[_engine objective] value];
}
-(id<ORTracer>) tracer
{
   return _tracer;
}
-(void) close
{
   if (!_closed._val) {
      assignTRInt(&_closed, YES, _trail);
      if ([_engine close] == ORFailure)
         [_search fail];
      if (![_hSet empty]) {
         @autoreleasepool {
            NSMutableArray* mvar = [[NSMutableArray alloc] initWithCapacity: [[_model variables] count]];
            NSIndexSet* iset = [[_model variables] indexesOfObjectsPassingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
               return [obj conformsToProtocol: @protocol(ORIntVar)];
            }];
            [[_model variables] enumerateObjectsAtIndexes: iset options: NSEnumerationReverse usingBlock: ^(id obj, NSUInteger idx, BOOL* stop) {
               [mvar addObject: obj];
            }];
            NSMutableArray* cvar = [[NSMutableArray alloc] initWithCapacity:[mvar count]];
            for(id<ORVar> v in mvar)
               [cvar addObject:_gamma[v.getId]];
            tryfail(^ORStatus{
               [_hSet applyToAll:^(id<CPHeuristic> h) {
                  [h initHeuristic:mvar concrete:cvar oneSol:_oneSol];
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
   [_doOnStartupArray enumerateObjectsUsingBlock:^(ORClosure  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
      block();
   }];
}
-(void) doOnSolution
{
   [_doOnSolArray enumerateObjectsUsingBlock:^(ORClosure block, NSUInteger idx, BOOL *stop) {
      block();
   }];
}
-(void) doOnExit
{
   [_doOnExitArray enumerateObjectsUsingBlock:^(ORClosure block, NSUInteger idx, BOOL *stop) {
      block();
   }];
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
               onSolution: ^{ [self doOnSolution];}
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

-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   [_search limitTime: maxTime in: cl];
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
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method lthenImpl not implemented"];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method gthenImpl not implemented"];
}
-(void) realLthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method realLthenImpl: not implemented"];
}
-(void) realGthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method realGthenImpl: not implemented"];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method restrictImpl not implemented"];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelBVImpl not implemented"];
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

-(void) labelBit:(int)i ofVar:(id<CPBitVar>)x
{
   [_search try: ^() { [self labelBV:x at:i with:false];}
            alt: ^() { [self labelBV:x at:i with:true];}];
}
-(void) labelUpFromLSB:(id<CPBitVar>) x
{
   int i;
   CPBitVarI* bv = (CPBitVarI*) _gamma[x.getId];
   while ((i=[bv lsFreeBit])>=0) {
      NSAssert(i>=0,@"ERROR in [labelUpFromLSB] bitVar is not bound, but no free bits found when using lsFreeBit.");
      [_search try: ^() { [self labelBV:x at:i with:false];}
               alt: ^() { [self labelBV:x at:i with:true];}];
   }
}

-(void) labelBitVarsFirstFail: (NSArray*)vars
{
   CPBitVarI* minDom;
   ORULong minDomSize;
   ORULong thisDomSize;
   ORLong numVars;
   bool freeVars = false;
   NSMutableArray* cvars = [[[NSMutableArray alloc] initWithCapacity:[vars count]] autorelease];
   for(id v in vars)
      [cvars addObject:_gamma[[v getId]]];
   vars = cvars;
   
   numVars = [vars count];
   int j;
   int numBound;

   for(int i=0;i<numVars;i++){
      if ([vars[i] bound])
         continue;
      if ([vars[i] domsize] <= 0)
         continue;
      minDom = vars[i];
      minDomSize = [minDom domsize];
      freeVars = true;
      break;
   }

//   NSLog(@"%lld unbound variables.",numVars);
   while (freeVars) {
      freeVars = false;
      numBound = 0;
      for(int i=0;i<numVars;i++){
         if ([vars[i] bound]){
            numBound++;
            continue;
         }
         if ([vars[i] domsize] <= 0)
            continue;
         if (!freeVars) {
            minDom = vars[i];
            minDomSize = [minDom domsize];
            freeVars = true;
            continue;
         }
         thisDomSize= [vars[i] domsize];
         if(thisDomSize==0)
            continue;
         if (thisDomSize < minDomSize) {
            minDom = vars[i];
            minDomSize = thisDomSize;
         }
      }
      if (!freeVars)
         break;
      //NSLog(@"%d//%lld bound.",numBound, numVars);
//      j=[minDom randomFreeBit];
      
      //NSLog(@"Labeling %@ at %d.", minDom, j);
      while ([minDom domsize] > 0) {
         j= [minDom randomFreeBit];
         [_search try: ^() { [self labelBVImpl:(id)minDom at:j with:false];}
                  alt: ^() { [self labelBVImpl:(id)minDom at:j with:true];}];
      }

      //NSLog(@"Labeled %@ at %d.", minDom, j);
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

-(void) labelArray: (id<ORIntVarArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   for(ORInt i = low; i <= up; i++) {
      CPIntVar* xi = _gamma[getId(x[i])];
      while (!bound(xi)) {
         ORInt m = minDom(xi);
         [_search try: ^{ [self labelImpl: xi with: m]; }
                  alt: ^{ [self  diffImpl: xi with: m]; }
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
      ORInt i = [select min];
      if (i == MAXINT)
         break;
      [self label: x[i]];
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
      if ([failStamp intValue]  == [_search nbFailures] || (x == nil || [self bound:x])) {
         ORInt i = [select max];
         if (i == MAXINT)
            return;
         x = av[i];
         //NSLog(@"-->Chose variable: %p",x);
         [last setIdValue:x];
      }/* else {
         NSLog(@"STAMP: %d  - %d",[failStamp value],[_search nbFailures]);
      }*/
      [failStamp setValue:[_search nbFailures]];
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
-(void) diff: (id<ORIntVar>) var with: (ORInt) val
{
   [self diffImpl: _gamma[var.getId] with: val];
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

-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   [self restrictImpl: _gamma[var.getId] to: S];
}
-(void) labelBV: (id<CPBitVar>) var at:(ORUInt) i with:(ORBool)val
{
   return [self labelBVImpl: (id<CPBitVar,CPBitVarNotifier>)_gamma[var.getId] at:i with: val];
}
-(void) realLthen: (id<ORRealVar>) var with: (ORDouble) val
{
   [self realLthenImpl: _gamma[var.getId] with: val];
}
-(void) realGthen: (id<ORRealVar>) var with: (ORDouble) val
{
   [self realGthenImpl: _gamma[var.getId] with: val];
}
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
-(id<CPHeuristic>) createABS:(id<ORVarArray>)rvars
{
   id<CPHeuristic> h = [[CPABS alloc] initCPABS:self restricted:rvars];
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
-(ORUInt) degree:(id<ORVar>)x
{
   return [_gamma[x.getId] degree];
}
-(ORInt) intValue: (id) x
{
   return [_gamma[[x getId]] intValue];
}
-(ORBool) boolValue: (id<ORIntVar>) x
{
   return [_gamma[x.getId] intValue];
}
-(ORDouble) doubleValue: (id<ORRealVar>) x
{
   return [(id<ORRealVar>)_gamma[x.getId] doubleValue];
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
   [_gamma[x.getId] assignRelaxationValue: f];
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
  return [((id<CPIntVar>) _gamma[x.getId]) domsize];
}
-(ORInt)  member: (ORInt) v in: (id<ORIntVar>) x
{
   return [((id<CPIntVar>) _gamma[x.getId]) member: v];
}
-(ORDouble) domwidth:(id<ORRealVar>) x
{
   return [((id<CPRealVar>)_gamma[x.getId]) domwidth];
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

-(void) search:(void*(^)())stask
{
   [self solve:^{
      id<ORSTask> theTask = (id<ORSTask>)stask();
      [theTask execute];
   }];
   [_engine open];
}

-(void) searchAll:(void*(^)())stask
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
    if (status == ORFailure)
        [_search fail];
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
    if (status == ORFailure)
        [_search fail];
    [ORConcurrency pumpEvents];
}
-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^{ bindDom((CPIntVarI*)var, val);}];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^{ [var remove:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^{ [var updateMax:val-1];}];
   if (status == ORFailure) {
      [_failLT notifyWith:var andInt:val];
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
      [_search fail];
   }
   [_returnGT notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine enforce:^{ [var inside:S];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   ORStatus status = [_engine enforce:^{ [[var domain] setBit:i to:val for:var];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];   
}
-(void) realLthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateMax:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) realGthenImpl: (id<CPRealVar>) var with: (ORDouble) val
{
   ORStatus status = [_engine enforce:^{ [var updateMin:val];}];
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
   _imdl   = [[CPINCModel alloc] init:self];
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
   _imdl   = [[CPINCModel alloc] init:self];
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
   _imdl   = [[CPINCModel alloc] init:self];
   [cFact release];
   return self;
}
-(void) dealloc
{
   [_imdl  release];
   [_trail release];
   [_engine release];
   [_search release];
   [_tracer release];
   [super dealloc];
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

-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^ {
      bindDom((id)var, val);
      //[var bind: val];
   }];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ { [var remove:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ {  [var updateMax:val-1];}];
   if (status == ORFailure) {
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
      [_failGT notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnGT notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine enforce:^{[var inside:S];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   ORStatus status = [_engine enforce:^ { [[var domain] setBit:i to:val for:var];}];
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
+(id<CPSemanticProgramDFS>) semanticSolverDFS
{
   return [[CPSemanticSolver alloc] initCPSemanticSolverDFS];
}
+(id<CPSemanticProgram>) semanticSolver: (id<ORSearchController>) ctrlProto
{
   return [[CPSemanticSolver alloc] initCPSemanticSolver: ctrlProto];
}
@end

