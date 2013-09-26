/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitVar.h>
#import <objcp/CPBitVarI.h>

#import "CPProgram.h"
#import "CPSolver.h"
#import "CPConcretizer.h"


#if defined(__linux__)
#import <values.h>
#endif

// to do 23/12/2012
//
// 1. Look at IncModel to implement the incremental addition of constraints
// 2. Need to check how variables/constraints/objects are created during the search
// 3. Need to concretize them directly


@interface ORCPIntVarSnapshot : NSObject<ORSnapshot,NSCoding> {
   ORUInt    _name;
   ORInt     _value;
}
-(ORCPIntVarSnapshot*) initCPIntVarSnapshot: (id<ORIntVar>) v with: (id<CPCommonProgram>) solver;
-(int) intValue;
-(ORBool) boolValue;
-(NSString*) description;
-(ORBool)isEqual: (id) object;
-(NSUInteger) hash;
-(ORUInt)getId;
@end

@implementation ORCPIntVarSnapshot
-(ORCPIntVarSnapshot*) initCPIntVarSnapshot: (id<ORIntVar>) v with: (id<CPCommonProgram>) solver;
{
   self = [super init];
   _name = [v getId];
   _value = [solver intValue: v];
   return self;
}
-(ORUInt)getId
{
   return _name;
}

-(ORInt) intValue
{
   return _value;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORBool) boolValue
{
   return _value;
}
-(ORBool)isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORCPIntVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value;
      }
      else
         return NO;
   } else
      return NO;
}
-(NSUInteger) hash
{
   return (_name << 16) + _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"int(%d) : %d",_name,_value];
   return buf;
}
- (void)encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
   return self;
}
@end

@interface ORCPFloatVarSnapshot : NSObject <ORSnapshot,NSCoding>
{
   ORUInt    _name;
   ORFloat   _value;
}
-(ORCPFloatVarSnapshot*) initCPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<CPCommonProgram>) solver;
-(ORFloat) floatValue;
-(ORInt) intValue;
-(NSString*) description;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
@end

@implementation ORCPFloatVarSnapshot
-(ORCPFloatVarSnapshot*) initCPFloatVarSnapshot: (id<ORFloatVar>) v with: (id<CPCommonProgram>) solver;
{
   self = [super init];
   _name = [v getId];
   _value = [solver floatValue: v];
   return self;
}
-(ORInt) intValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "intValue called on a snapshot for float variables"];
   return 0;
}
-(ORBool) boolValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "boolValue called on a snapshot for float variables"];
   return 0;
}
-(ORFloat) floatValue
{
   return _value;
}
-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass:[self class]]) {
      ORCPFloatVarSnapshot* other = object;
      if (_name == other->_name) {
         return _value == other->_value;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger)hash
{
   return (_name << 16) + (ORInt) _value;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"float(%d) : %f",_name,_value];
   return buf;
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_value];
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_value];
   return self;
}
@end

@interface ORCPTakeSnapshot  : ORNOopVisit<ORVisitor>
-(ORCPTakeSnapshot*) initORCPTakeSnapshot: (id<CPCommonProgram>) solver;
-(void) dealloc;
@end

@implementation ORCPTakeSnapshot
{
   id<CPCommonProgram> _solver;
   id            _snapshot;
}
-(ORCPTakeSnapshot*) initORCPTakeSnapshot: (id<CPCommonProgram>) solver
{
   self = [super init];
   _solver = solver;
   return self;
}
-(id) snapshot:(id)obj
{
   _snapshot = NULL;
   [obj visit:self];
   return _snapshot;
}
-(void) dealloc
{
   [super dealloc];
}
-(void) visitIntVar: (id<ORIntVar>) v
{
   _snapshot = [[ORCPIntVarSnapshot alloc] initCPIntVarSnapshot: v with: _solver];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   _snapshot = [[ORCPFloatVarSnapshot alloc] initCPFloatVarSnapshot: v with: _solver];
}
@end

@interface ORCPSolutionI : ORObject<ORCPSolution>
-(ORCPSolutionI*) initORCPSolutionI: (id<ORModel>) model with: (id<CPCommonProgram>) solver;
-(id<ORSnapshot>) value: (id) var;
-(ORBool) isEqual: (id) object;
-(NSUInteger) hash;
-(id<ORObjectiveValue>) objectiveValue;
@end


// PVH: need to be generalized when the global numbering will be available
@implementation ORCPSolutionI {
   NSArray*             _varShots;
   id<ORObjectiveValue> _objValue;
}

-(ORCPSolutionI*) initORCPSolutionI: (id<ORModel>) model with: (id<CPCommonProgram>) solver
{
   self = [super init];
   NSArray* av = [model variables];
   ORULong sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   ORCPTakeSnapshot* visit = [[ORCPTakeSnapshot alloc] initORCPTakeSnapshot: solver];
   for(id obj in av) {
      id shot = [visit snapshot:obj];
      if (shot)
         [snapshots addObject: shot];
      [shot release];
   }
   _varShots = snapshots;
   
   if ([model objective])
      _objValue = [[solver objective] value];
   else
      _objValue = nil;
   [visit release];
   return self;
}

-(void) dealloc
{
//   NSLog(@"dealloc ORCPSolutionI");
   [_varShots release];
   [_objValue release];
   [super dealloc];
}

-(ORBool) isEqual: (id) object
{
   if ([object isKindOfClass: [self class]]) {
      ORCPSolutionI* other = object;
      if (_objValue && other->_objValue) {
         if ([_objValue isEqual:other->_objValue]) {
            return [_varShots isEqual:other->_varShots];
         }
         else
            return NO;
      }
      else
         return NO;
   }
   else
      return NO;
}
-(NSUInteger) hash
{
   return [_varShots hash];
}
-(id<ORObjectiveValue>) objectiveValue
{
   return _objValue;
}
-(id<ORSnapshot>) value: (id) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   if (idx < [_varShots count])
      return [_varShots objectAtIndex:idx];
   else
      return nil;
}
-(ORInt) intValue: (id) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   return [(id<ORSnapshot>) [_varShots objectAtIndex:idx] intValue];
}
-(ORBool) boolValue: (id) var
{
   NSUInteger idx = [_varShots indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [obj getId] == [var getId];
   }];
   return [(id<ORSnapshot>) [_varShots objectAtIndex:idx] boolValue];
}
-(ORFloat) floatValue: (id<ORFloatVar>) var
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No float variable in LP solutions"];
}
-(NSUInteger) count
{
   return [_varShots count];
}
- (void) encodeWithCoder: (NSCoder *)aCoder
{
   [aCoder encodeObject:_varShots];
   [aCoder encodeObject:_objValue];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   _varShots = [[aDecoder decodeObject] retain];
   _objValue = [aDecoder decodeObject];
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   if (_objValue)
      [buf appendFormat:@"SOL[%@](",_objValue];
   else
      [buf appendString:@"SOL("];
   NSUInteger last = [_varShots count] - 1;
   [_varShots enumerateObjectsUsingBlock:^(id<ORSnapshot> obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"%@%c",obj,idx < last ? ',' : ')'];
   }];
   return buf;
}
@end

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
      _tab = realloc(_tab, _mx << 1);
      _mx <<= 1;
   }
   _tab[_sz++] = h;
}
-(id<CPHeuristic>) pop
{
   return _tab[--_sz];
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
   Class               _ctrlClass;
   Class               _nestedClass;
}
-(id)initORControllerFactoryI: (id<CPCommonProgram>) solver rootControllerClass:(Class)class nestedControllerClass:(Class)nc;
-(id<ORSearchController>) makeRootController;
-(id<ORSearchController>) makeNestedController;
@end

@implementation ORControllerFactoryI
-(id)initORControllerFactoryI: (id<CPCommonProgram>) solver rootControllerClass: (Class) class nestedControllerClass: (Class) nc
{
   self = [super init];
   _solver = solver;
   _ctrlClass = class;
   _nestedClass = nc;
   return self;
}
-(id<ORSearchController>) makeRootController
{
   return [[_ctrlClass alloc] initTheController: [_solver tracer] engine: [_solver engine]];
}
-(id<ORSearchController>) makeNestedController
{
   return [[_nestedClass alloc] initTheController: [_solver tracer] engine: [_solver engine]];
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
   id<ORIdxIntInformer>  _failLabel;
   BOOL                  _closed;
   BOOL                  _oneSol;
   NSMutableArray*       _doOnSolArray;
   NSMutableArray*       _doOnExitArray;
   id<ORSolutionPool>    _sPool;
}
-(CPCoreSolver*) initCPCoreSolver
{
   self = [super initORGamma];
   _model = NULL;
   _hSet = [[CPHeuristicSet alloc] initCPHeuristicSet];
   _returnLabel = _failLabel = nil;
   _portal = [[CPInformerPortal alloc] initCPInformerPortal: self];
   _objective = nil;
   _sPool   = [ORFactory createSolutionPool];
   _closed = false;
   _oneSol = YES;
   _doOnSolArray = [[NSMutableArray alloc] initWithCapacity: 1];
   _doOnExitArray = [[NSMutableArray alloc] initWithCapacity: 1];
   return self;
}
-(void) dealloc
{
   [_model release];
   [_hSet release];
   [_portal release];
   [_returnLabel release];
   [_failLabel release];
   [_sPool release];
   [_doOnSolArray release];
   [_doOnExitArray release];
   [super dealloc];
}
-(void) setSource:(id<ORModel>)src
{
   [_model release];
   _model = [src retain];
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
-(id<ORIdxIntInformer>) failLabel
{
   if (_failLabel==nil)
      _failLabel = [ORConcurrency idxIntInformer];
   return _failLabel;
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
-(id<ORTracer>) tracer
{
   return _tracer;
}
-(void) close
{
   if (!_closed) {
      _closed = true;
      if ([_engine close] == ORFailure)
         [_search fail];
      if (![_hSet empty]) {
         NSArray* mvar = [_model variables];
         NSMutableArray* cvar = [[NSMutableArray alloc] initWithCapacity:[mvar count]];
         for(id<ORVar> v in mvar)
            [cvar addObject:_gamma[v.getId]];
         [_hSet applyToAll:^(id<CPHeuristic> h) {
            [h initHeuristic:mvar concrete:cvar oneSol:_oneSol];
         }];
         [cvar release];
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

-(void) onSolution: (ORClosure) onSolution
{
   id block = [onSolution copy];
   [_doOnSolArray addObject: block];
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
-(id<ORSolution>) captureSolution
{
   return [[ORCPSolutionI alloc] initORCPSolutionI: _model with: self];
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
-(void) solveAll: (ORClosure) search
{
   _oneSol = NO;
   ORInt nbs = (ORInt) [_doOnSolArray count];
   ORInt nbe = (ORInt) [_doOnExitArray count];
   [_search solveAllModel: self using: search
               onSolution: ^{
                  for(ORInt i = 0; i < nbs; i++)
                     ((ORClosure) [_doOnSolArray objectAtIndex: i])();
               }
                   onExit: ^{
                      for(ORInt i = 0; i < nbe; i++)
                         ((ORClosure) [_doOnExitArray objectAtIndex: i])();
                   }
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
   [ORControl forall: S suchThat: filter orderedBy: order do: body];  
}
-(void) forall: (id<ORIntIterable>) S  orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: self set: S];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) o1 and: (ORInt2Int) o2  do: (ORInt2Void) b
{
   id<ORForall> forall = [ORControl forall: self set: S];
   [forall suchThat: suchThat];
   [forall orderedBy:o1];
   [forall orderedBy:o2];
   [forall do: b];
}
-(void) try: (ORClosure) left or: (ORClosure) right
{
   [_search try: left or: right];   
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body
{
   [_search tryall: range suchThat: filter in: body];   
}
-(void) tryall: (id<ORIntIterable>) range suchThat: (ORInt2Bool) filter in: (ORInt2Void) body onFailure: (ORInt2Void) onFailure
{
   [_search tryall: range suchThat: filter in: body onFailure: onFailure];  
}
-(void) limitTime: (ORLong) maxTime in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitTime: maxTime in: cl];
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
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method restrictImpl not implemented"];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Method labelBVImpl not implemented"];
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
-(void) labelBit:(int)i ofVar:(id<CPBitVar>)x
{
   [_search try: ^() { [self labelBV:x at:i with:false];}
             or: ^() { [self labelBV:x at:i with:true];}];
}
-(void) labelUpFromLSB:(id<CPBitVar>) x
{
   int i;
//   CPBitVarI* bv = (CPBitVarI*) _gamma[x.getId];
   while ((i=[x lsFreeBit])>=0) {
      NSAssert(i>=0,@"ERROR in [labelUpFromLSB] bitVar is not bound, but no free bits found when using lsFreeBit.");
      [_search try: ^() { [self labelBV:x at:i with:false];}
                or: ^() { [self labelBV:x at:i with:true];}];
   }
}

-(void) labelDownFromMSB:(id<CPBitVar>) x
{
   int i;
//   CPBitVarI* bv = (CPBitVarI*) _gamma[x.getId];
   while ((i=[x msFreeBit])>=0) {
//      i=[bv msFreeBit];
//      NSLog(@"%@ shows MSB as %d",bv,i);
      NSAssert(i>=0,@"ERROR in [labelDownFromMSB] bitVar is not bound, but no free bits found when using msFreeBit.");
      [_search try: ^() { [self labelBV:x at:i with:true];}
                or: ^() { [self labelBV:x at:i with:false];}];
   }
}


//-(void) labelBitVarsFirstFail: (NSArray*)vars
//{
////<<<<<<< HEAD
//   NSMutableArray* unboundVars = [[NSMutableArray alloc]init];
//   NSMutableSet* alreadyTried = [[NSMutableSet alloc] init];
////=======
////   CPBitVarI* minDom;
////   ORULong minDomSize;
////   ORULong thisDomSize;
////   ORLong numVars;
////   bool freeVars = false;
////   NSMutableArray* cvars = [[[NSMutableArray alloc] initWithCapacity:[vars count]] autorelease];
////   for(id v in vars)
////      [cvars addObject:_gamma[[v getId]]];
////   vars = cvars;
////   
////   numVars = [vars count];
////>>>>>>> modeling
//   int j;
//
////<<<<<<< HEAD
//   [unboundVars addObjectsFromArray:vars];
//
//   NSArray *sortedArray;
//   bool moreVars = true;
//   while (moreVars) {
//
//      moreVars = false;
//      sortedArray = [unboundVars sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
//      if ((ORULong)[(CPBitVarI*)obj1 domsize] > (ORULong)[(CPBitVarI*)obj2 domsize]) {
//         return (NSComparisonResult)NSOrderedDescending;
//      }
//      if ((ORULong)[(CPBitVarI*)obj1 domsize] < (ORULong)[(CPBitVarI*)obj2 domsize]) {
//         return (NSComparisonResult)NSOrderedAscending;
////=======
////   for(int i=0;i<numVars;i++){
////      if ([vars[i] bound])
////         continue;
////      if ([vars[i] domsize] <= 0)
////         continue;
////      minDom = vars[i];
////      minDomSize = [minDom domsize];
////      freeVars = true;
////      break;
////   }
////
//////   NSLog(@"%lld unbound variables.",numVars);
////   while (freeVars) {
////      freeVars = false;
////      numBound = 0;
////      for(int i=0;i<numVars;i++){
////         if ([vars[i] bound]){
////            numBound++;
////            continue;
////         }
////         if ([vars[i] domsize] <= 0)
////            continue;
////         if (!freeVars) {
////            minDom = vars[i];
////            minDomSize = [minDom domsize];
////            freeVars = true;
////            continue;
////         }
////         thisDomSize= [vars[i] domsize];
////         if(thisDomSize==0)
////            continue;
////         if (thisDomSize < minDomSize) {
////            minDom = vars[i];
////            minDomSize = thisDomSize;
////         }
////      }
////      if (!freeVars)
////         break;
////      //NSLog(@"%d//%lld bound.",numBound, numVars);
//////      j=[minDom randomFreeBit];
////      
////      //NSLog(@"Labeling %@ at %d.", minDom, j);
////      while ([minDom domsize] > 0) {
////         j= [minDom randomFreeBit];
////         [_search try: ^() { [self labelBVImpl:(id)minDom at:j with:false];}
////                   or: ^() { [self labelBVImpl:(id)minDom at:j with:true];}];
////>>>>>>> modeling
//      }
//      return (NSComparisonResult)NSOrderedSame;
//      }];
//
////<<<<<<< HEAD
////      for (int i=0;i<[sortedArray count]; i++) {
////         ORULong dSize =[(CPBitVarI*)(sortedArray[i]) domsize];
////         NSLog(@"%llu",dSize);
////      }
////      NSLog(@"\n\n\n\n");
//      
//      
//      for (int i=0;i<[sortedArray count]; i++) {
////         NSLog(@"%llu",[(CPBitVarI*)sortedArray[i] domsize]);
//         if (([(CPBitVarI*)(sortedArray[i]) domsize])>0x00000001) {
////         if(![sortedArray[i] bound] && ![alreadyTried member:sortedArray[i]]){
////            NSLog(@"Processing variable with domain size %llu, %lu variables remaining",[(CPBitVarI*)(sortedArray[i]) domsize], (unsigned long)[sortedArray count]);
////         if (![(CPBitVarI*)(sortedArray[i]) bound]) {
//            moreVars = true;
//            [alreadyTried addObject:sortedArray[i]];
//            while ((j=[sortedArray[i] lsFreeBit])>=0) {
////               j=[sortedArray[i] lsFreeBit];
////               [unboundVars removeObject:sortedArray[i]];
////               NSMutableArray *temp = [[NSMutableArray alloc]init];
////               [temp addObjectsFromArray:unboundVars];
////               unboundVars = temp;
////               [unboundVars removeObject:sortedArray[i]];
////               NSLog(@"Labeling %x = %@ at %d with domain size %llu.",sortedArray[i],sortedArray[i],j,[(CPBitVarI*)sortedArray[i] domsize]);
//               [_search try: ^() { [self labelBV:(id<CPBitVar>)sortedArray[i] at:j with:false];}
//                         or: ^() { [self labelBV:(id<CPBitVar>)sortedArray[i] at:j with:true];}];
//            }
////            [alreadyTried removeObject:sortedArray[i]];
////            NSMutableArray *temp = [[NSMutableArray alloc]init];
////            [temp addObjectsFromArray:unboundVars];
////            unboundVars = temp;
////            [unboundVars removeObject:sortedArray[i]];
//            //break;
//         }
//      }
////=======
////      //NSLog(@"Labeled %@ at %d.", minDom, j);
////>>>>>>> modeling
//   }
//}

-(void) labelArray: (id<ORIntVarArray>) x
{
   ORInt low = [x low];
   ORInt up = [x up];
   for(ORInt i = low; i <= up; i++)
      [self label: x[i]];
}

-(void) labelArray: (id<ORIntVarArray>) x orderedBy: (ORInt2Float) orderedBy
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
                                  suchThat: ^bool(ORInt i) { return ![cxp[i - low] bound]; }
                                 orderedBy: orderedBy];
   do {
      ORInt i = [select min];
      if (i == MAXINT) {
         break;
      }
      [self labelImpl: cxp[i - low]];
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
      ORLong bestRand = 0x7fffffffffffffff;
      for(ORInt i=0;i<sz;i++) {
         ORInt cds = [cx[i] domsize];
         if (cds==1) continue;
         if (cds < sd) {
            sd = cds;
            sx = cx[i];
            bestRand = [tie next];
         } else if (cds==sd) {
            ORLong nr = [tie next];
            if (nr < bestRand) {
               sx = cx[i];
               bestRand = nr;
            }
         }
      }
      if (sx == NULL) break;
      ORBounds xb = [sx bounds];
      while (xb.min != xb.max) {
         [_search try:^{
            [self labelImpl:sx with:xb.min];
         } or:^{
            [self diffImpl:sx with:xb.min];
         }];
         xb = [sx bounds];
      }
   } while(true);
}


-(void) labelHeuristic: (id<CPHeuristic>) h
{
   [self labelHeuristic:h withConcrete:(id)[h allIntVars]];
}
-(void) labelHeuristic: (id<CPHeuristic>) h restricted:(id<ORIntVarArray>)av
{
   id<CPIntVarArray> cav = (id)[ORFactory intVarArray:self range:av.range with:^id<ORIntVar>(ORInt k) {
      return _gamma[av[k].getId];
   }];
   [self labelHeuristic:h withConcrete:cav];
}

-(void) labelHeuristic: (id<CPHeuristic>) h withConcrete:(id<CPIntVarArray>)av
{
   // [ldm] All four objects below are on the memory trail (+range of selector)
   // Note, the two mutables are created during the search, hence never concretized. 
   id<ORSelect> select = [ORFactory selectRandom: _engine
                                           range: RANGE(_engine,[av low],[av up])
                                        suchThat: ^bool(ORInt i) { return ![av[i] bound]; }
                                       orderedBy: ^ORFloat(ORInt i) {
                                          ORFloat rv = [h varOrdering:av[i]];
                                          return rv;
                                       }];
   id<ORRandomStream>   valStream = [ORFactory randomStream:_engine];
   ORMutableIntegerI*   failStamp = [ORFactory mutable:_engine value:-1];
   ORMutableId*              last = [ORFactory mutableId:_engine value:nil];
   do {
      id<CPIntVar> x = [last idValue];
      //NSLog(@"at top: last = %p",x);
      if ([failStamp intValue]  == [_search nbFailures] || (x == nil || [x bound])) {
         ORInt i = [select max];
         if (i == MAXINT)
            return;
         x = av[i];
         //NSLog(@"-->Chose variable: %p",x);
         [last setId:x];
      }/* else {
         NSLog(@"STAMP: %d  - %d",[failStamp value],[_search nbFailures]);
      }*/
      [failStamp setValue:[_search nbFailures]];
      ORFloat bestValue = - MAXFLOAT;
      ORLong bestRand = 0x7fffffffffffffff;
      ORInt low = x.min;
      ORInt up  = x.max;
      ORInt bestIndex = low - 1;
      for(ORInt v = low;v <= up;v++) {
        if ([x member:v]) {
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
      if (bestIndex != low - 1)  {
        [_search try: ^{
           [self labelImpl:x with: bestIndex];
        } or: ^{
           [self diffImpl:x with: bestIndex];
        }];
      }
   } while (true);
}

-(void) labelBitVarHeuristic: (id<CPBitVarHeuristic>) h
{
   [self labelBitVarHeuristic:h withConcrete:(id)[h allBitVars]];
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
//   id<ORBitVarArray> av= [h allBitVars];
   id<ORSelect> select = [ORFactory selectRandom: _engine
                                           range: RANGE(_engine,[av low],[av up])
//                                        suchThat: ^bool(ORInt i)    { return ![_gamma[[av at: i].getId] bound]; }
                                  suchThat: ^bool(ORInt i) { return ![av[i] bound]; }
                                       orderedBy: ^ORFloat(ORInt i) {
                                          ORFloat rv = [h varOrdering:av[i]];
                                          return rv;
                                       }];
//   id<ORBitVar>* last = malloc(sizeof(id<ORBitVar>));
//   id<ORRandomStream> valStream = [ORCrFactory randomStream:_engine];
//   [_trail trailClosure:^{
//      free(last);
//      [valStream release];
//   }];
//   
//   *last = nil;
//   //id<ORMutableInteger> failStamp = [ORFactory mutable:self value:-1];
//   __block ORInt failStamp = -1;
//   do {
//      id<ORBitVar> x = *last;
//      if (failStamp == [_search nbFailures] || (x == nil || [_gamma[x.getId ] bound])) {
//         ORInt i = [select max];
//         if (i == MAXINT)
//            return;
////         NSLog(@"Chose variable: %d",i);
//         x = (id<ORBitVar>)_gamma[av[i].getId];
//         *last = x;
//      }/* else {
//        NSLog(@"STAMP: %d  - %d",[failStamp value],[_search nbFailures]);
//        }*/
////      [failStamp setValue:[_search nbFailures] in:(id<ORGamma>)_gamma];
//      failStamp = [_search nbFailures];
//      ORFloat bestValue = - MAXFLOAT;
//      ORLong bestRand = 0x7fffffffffffffff;
//      ORUInt up  = [_gamma[x.getId] msFreeBit];
//      ORUInt low = [_gamma[x.getId] lsFreeBit];
//      ORInt bestIndex = -1;
//      for(ORInt v = low;v <= up;v++) {
//      if ([_gamma[x.getId] isFree:v]) {
//            ORFloat vValue = [h valOrdering:v forVar:x];
//            if (vValue > bestValue) {
//               bestValue = vValue;
//               bestIndex = v;
//               bestRand  = [valStream next];
//            }
//            else if (vValue == bestValue) {
//               ORLong rnd = [valStream next];
//               if (rnd < bestRand) {
//                  bestIndex = v;
//                  bestRand = rnd;
//               }
//            }
//         }
//      }
//      
//      if (bestIndex != - 1)  {
////         NSLog(@"Trying %x at index %u",x,bestIndex);
//         [self try: ^{
//            [self labelBVImpl:_gamma[x.getId] at:bestIndex with:false];
//         } or: ^{
//            [self labelBVImpl:_gamma[x.getId] at:bestIndex with:true];
//         }];
//      }
//      /*
//       id<ORSelect> valSelect = [ORFactory select: _engine
//       range:RANGE(_engine,[x min],[x max])
//       suchThat:^bool(ORInt v)    { return [x member:v];}
//       orderedBy:^ORFloat(ORInt v) { return [h valOrdering:v forVar:x];}];
//       do {
//       ORInt curVal = [valSelect max];
//       if (curVal == MAXINT)
//       break;
//       [self try:^{
//       [self label: x with: curVal];
//       } or:^{
//       [self diff: x with: curVal];
//       }];
//       } while(![x bound]);
//       */
//   } while (true);
   id<ORRandomStream>   valStream = [ORFactory randomStream:_engine];
   ORMutableIntegerI*   failStamp = [ORFactory mutable:_engine value:-1];
   ORMutableId*              last = [ORFactory mutableId:_engine value:nil];
   do {
      id<CPBitVar> x = [last idValue];
      //NSLog(@"at top: last = %p",x);
      if ([failStamp intValue]  == [_search nbFailures] || (x == nil || [x bound])) {
         ORInt i = [select max];
         if (i == MAXINT)
            return;
         x = av[i];
         //NSLog(@"-->Chose variable: %p=%@",x,x);
         [last setId:x];
      } else {
        //NSLog(@"STAMP: %d  - %d",[failStamp value],[_search nbFailures]);
        }
      NSAssert([x isKindOfClass:[CPBitVarI class]], @"%@ should be kind of class %@", x, [[CPBitVarI class] description]);      
      [failStamp setValue:[_search nbFailures]];
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
            [self labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)x at: bestIndex with:false];
         } or: ^{
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
      [_search try: ^{ [self labelImpl: x with: m]; }
                or: ^{ [self diffImpl:  x with: m]; }
      ];
   }
}
-(void) labelImpl: (id<CPIntVar>)x
{
   while (![x bound]) {
      ORInt m = [x min];
      [_search try: ^{ [self labelImpl: x with: m]; }
                or: ^{ [self diffImpl:  x with: m]; }
       ];
   }
}

-(void) label: (id<ORIntVar>) var with: (ORInt) val
{
   return [self labelImpl: _gamma[var.getId] with: val];
}
-(void) diff: (id<CPIntVar>) var with: (ORInt) val
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
-(void) restrict: (id<ORIntVar>) var to: (id<ORIntSet>) S
{
   [self restrictImpl: _gamma[var.getId] to: S];
}
-(void) labelBV: (id<CPBitVar>) var at:(ORUInt) i with:(ORBool)val
{
   return [self labelBVImpl: (id<CPBitVar,CPBitVarNotifier>)_gamma[var.getId] at:i with: val];
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
-(void) limitSolutions: (ORInt) maxSolutions in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitSolutions: maxSolutions in: cl];
}
-(void) limitCondition: (ORVoid2Bool) condition in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitCondition: condition in:cl];
}
-(void) limitDiscrepancies: (ORInt) maxDiscrepancies in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitDiscrepancies: maxDiscrepancies in: cl];
}
-(void) limitFailures: (ORInt) maxFailures in: (ORClosure) cl
{
   [_engine clearStatus];
   [_search limitFailures: maxFailures in: cl];
   
}
-(void) addConstraintDuringSearch: (id<ORConstraint>) c annotation: (ORAnnotation) n
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
   assert(FALSE);
   return NULL;
}

-(id<CPHeuristic>) createFF: (id<ORVarArray>) rvars
{
   id<ORIntVarArray> crv = nil;
   if (rvars)
      crv = [ORFactory intVarArray:self range:rvars.range with:^id<ORIntVar>(ORInt k) {
         return _gamma[rvars[k].getId];
      }];
   id<CPHeuristic> h = [[CPFirstFail alloc] initCPFirstFail:self restricted:crv];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createWDeg:(id<ORVarArray>)rvars
{
   id<ORIntVarArray> crv = nil;
   if (rvars)
      crv = [ORFactory intVarArray:self range:rvars.range with:^id<ORIntVar>(ORInt k) {
         return _gamma[rvars[k].getId];
      }];
   id<CPHeuristic> h = [[CPWDeg alloc] initCPWDeg:self restricted:crv];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createDDeg:(id<ORVarArray>)rvars
{
   id<ORIntVarArray> crv = nil;
   if (rvars)
      crv = [ORFactory intVarArray:self range:rvars.range with:^id<ORIntVar>(ORInt k) {
         return _gamma[rvars[k].getId];
      }];
   id<CPHeuristic> h = [[CPDDeg alloc] initCPDDeg:self restricted:crv];
   [self addHeuristic:h];
   return h;
}
-(id<CPHeuristic>) createIBS:(id<ORVarArray>)rvars
{
   id<ORIntVarArray> crv = nil;
   if (rvars)
      crv = [ORFactory intVarArray:self range:rvars.range with:^id<ORIntVar>(ORInt k) {
         return _gamma[rvars[k].getId];
      }];
   id<CPHeuristic> h = [[CPIBS alloc] initCPIBS:self restricted:crv];
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
   id<ORIntVarArray> crv = nil;
   if (rvars)
      crv = [ORFactory intVarArray:self range:rvars.range with:^id<ORIntVar>(ORInt k) {
         return _gamma[rvars[k].getId];
      }];
   id<CPHeuristic> h = [[CPABS alloc] initCPABS:self restricted:crv];
   [self addHeuristic:h];
   return h;
}
-(id<CPBitVarHeuristic>) createBitVarABS:(id<ORVarArray>)rvars
{
   id<CPBitVarHeuristic> h = [[CPBitVarABS alloc] initCPBitVarABS:self restricted:rvars];
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
-(NSString*)stringValue:(id<ORBitVar>)x
{
   return [_gamma[x.getId] stringValue];
}
-(ORInt)intValue:(id<ORIntVar>)x
{
   return [_gamma[[x getId]] intValue];
}
-(ORBool) boolValue: (id<ORIntVar>) x
{
   return [_gamma[x.getId] intValue];
}
-(ORFloat) floatValue: (id<ORFloatVar>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "no method floatValue available yet"];
   // return [_gamma[x.getId] floatValue];
}
-(ORBool) bound: (id<ORIntVar>) x
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
-(NSSet*) constraints: (id<ORVar>)x
{
   return [(id<CPVar>)_gamma[x.getId] constraints];
}
-(void) incr: (id<ORMutableInteger>) i

{
   [((ORMutableIntegerI*) _gamma[i.getId]) incr];
}
@end

/******************************************************************************************/
/*                                   CPSolver                                             */
/******************************************************************************************/

@interface ORRTModel : NSObject<ORAddToModel>
-(ORRTModel*) init:(CPSolver*) solver;
-(id<ORVar>) addVariable: (id<ORVar>) var;
-(id) addMutable: (id) object;
-(id) addImmutable:(id)object;
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr;
-(id<ORObjectiveFunction>) minimize: (id<ORIntVar>) x;
-(id<ORObjectiveFunction>) maximize: (id<ORIntVar>) x;
-(id) trackConstraintInGroup:(id)obj;
-(id) trackObjective:(id)obj;
-(id) trackMutable: (id) obj;
-(id) trackVariable: (id) obj;
@end

@implementation ORRTModel
{
   CPSolver* _solver;
   id<ORVisitor> _concretizer;
}
-(ORRTModel*)init:(CPSolver*)solver
{
   self = [super init];
   _solver = solver;
   _concretizer = [[ORCPConcretizer alloc] initORCPConcretizer: solver];
   return self;
}
-(void) dealloc
{
   [_concretizer release];
   [super dealloc];
}
-(id<ORVar>) addVariable: (id<ORVar>) var
{
   [_solver trackVariable:var];
   return var;
}
-(id) addMutable: (id) object
{
   [[_solver engine] trackMutable: object];
   return object;
}
-(id) addImmutable:(id)object
{
   return [[_solver engine] trackImmutable:object];
}

-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr
{
   [cstr visit: _concretizer];
   id<CPConstraint> c = [_solver gamma][[cstr getId]];
   [_solver addConstraintDuringSearch: c annotation: DomainConsistency];
   return cstr;
}
-(id<ORTracker>)tracker
{
   return _solver;
}
-(id<ORObjectiveFunction>) minimizeVar:(id<ORIntVar>) x
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to minimizeVar: not allowed during search"];
}
-(id<ORObjectiveFunction>) maximizeVar:(id<ORIntVar>) x
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
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to minimize:coef: not allowed during search"];   
}
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) var coef: (id<ORFloatArray>) coef
{
   @throw [[ORExecutionError alloc] initORExecutionError: "calls to maximize:coef: not allowed during search"];
}
-(id) trackObject: (id) obj
{
   return [_solver trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_solver trackConstraintInGroup:obj];
}
-(id) trackObjective:(id) object
{
   return [_solver trackObjective: object];
}
-(id) trackMutable: (id) obj
{
   return [_solver trackMutable:obj];
}
-(id) trackImmutable:(id)obj
{
   return [_solver trackImmutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_solver trackVariable:obj];
}
@end

@implementation CPSolver
-(id<CPProgram>) initCPSolver
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _mt    = [ORFactory memoryTrail];
   _engine = [CPFactory engine: _trail memory:_mt];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail memory:_mt];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORDFSController class]
                                                                  nestedControllerClass: [ORDFSController class]];
   _search = [ORExplorerFactory explorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(void) dealloc
{
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
   // PVH: Only used during search
   // LDM: DONE. Have not checked the variable creation/deallocation logic though. 
   id<ORAddToModel> trg = [[ORRTModel alloc] init:self];
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      [ORFlatten flattenExpression:(id<ORExpr>) c into: trg annotation: DomainConsistency];
   else
      [ORFlatten flatten: c into:trg];
   [trg release];
}
-(void) add: (id<ORConstraint>) c annotation: (ORAnnotation) cons
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   // LDM: See above. 
   id<ORAddToModel> trg = [[ORRTModel alloc] init: self];
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      [ORFlatten flattenExpression: (id<ORExpr>) c into: trg annotation: cons];
   else
      [ORFlatten flatten: c into: trg];
   [trg release];
}
-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^ORStatus { return [var bind: val];}];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return [var remove:val];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return  [var updateMax:val-1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return [var updateMin:val+1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine enforce:^ORStatus { return [var inside:S];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   ORStatus status = [_engine enforce:^ORStatus { return [[var domain] setBit:i to:val for:var];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];   
}
@end

/******************************************************************************************/
/*                                   CPSemanticSolver                                     */
/******************************************************************************************/

@implementation CPSemanticSolver
-(id<CPSemanticProgram>) initCPSemanticSolver
{
   self = [super initCPCoreSolver];
   _trail = [ORFactory trail];
   _mt   = [ORFactory memoryTrail];
   _engine = [CPFactory engine: _trail memory:_mt];
   _tracer = [[DFSTracer alloc] initDFSTracer: _trail memory:_mt];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORDFSController class]
                                                                  nestedControllerClass: [ORDFSController class]];
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
                                                                    rootControllerClass: [ORSemDFSControllerCSP class]
                                                                  nestedControllerClass: [ORSemDFSControllerCSP class]];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(id<CPSemanticProgram>) initCPSemanticSolver: (Class) ctrlClass
{
   self = [super initCPCoreSolver]; 
   _trail = [ORFactory trail];
   _mt    = [ORFactory memoryTrail];
   _engine = [CPFactory engine: _trail memory:_mt];
   _tracer = [[SemTracer alloc] initSemTracer: _trail memory:_mt];
   ORControllerFactoryI* cFact = [[ORControllerFactoryI alloc] initORControllerFactoryI: self
                                                                    rootControllerClass: [ORSemDFSControllerCSP class]
                                                                  nestedControllerClass: ctrlClass];
   _search = [ORExplorerFactory semanticExplorer: _engine withTracer: _tracer ctrlFactory: cFact];
   [cFact release];
   return self;
}
-(void) dealloc
{
   [_trail release];
   [_engine release];
   [_search release];
   [_tracer release];
   [super dealloc];
}
-(void) add: (id<ORConstraint>) c
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) add: (id<ORConstraint>) c annotation:(ORAnnotation) cons
{
   // PVH: Need to flatten/concretize
   // PVH: Only used during search
   ORStatus status = [_engine add: c];
   if (status == ORFailure)
      [_search fail];
}
-(void) labelImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce: ^ORStatus { return [var bind: val];}];
   if (status == ORFailure) {
      [_failLabel notifyWith:var andInt:val];
      [_search fail];
   }
   [_tracer addCommand: [CPSearchFactory equalc: var to: val]];
   [_returnLabel notifyWith:var andInt:val];
   [ORConcurrency pumpEvents];
}
-(void) diffImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return [var remove:val];}];
   if (status == ORFailure)
      [_search fail];
   [_tracer addCommand: [CPSearchFactory notEqualc: var to: val]];
   [ORConcurrency pumpEvents];
}
-(void) lthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return  [var updateMax:val-1];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) gthenImpl: (id<CPIntVar>) var with: (ORInt) val
{
   ORStatus status = [_engine enforce:^ORStatus { return [var updateMin:val+1];}];
   if (status == ORFailure)
      [_search fail];   
   [ORConcurrency pumpEvents];
}
-(void) restrictImpl: (id<CPIntVar>) var to: (id<ORIntSet>) S
{
   ORStatus status = [_engine enforce:^ORStatus { return [var inside:S];}];
   if (status == ORFailure)
      [_search fail];
   [ORConcurrency pumpEvents];
}
-(void) labelBVImpl:(id<CPBitVar,CPBitVarNotifier>)var at:(ORUInt)i with:(ORBool)val
{
   ORStatus status = [_engine enforce:^ORStatus { return [[var domain] setBit:i to:val for:var];}];
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
-(id<ORIdxIntInformer>) failLabel
{
   return [_cp failLabel];
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
   return [[CPSolver alloc] initCPSolver];
}
+(id<CPSemanticProgramDFS>) semanticSolverDFS
{
   return [[CPSemanticSolver alloc] initCPSemanticSolverDFS];
}
+(id<CPSemanticProgram>) semanticSolver: (Class) ctrlClass
{
   return [[CPSemanticSolver alloc] initCPSemanticSolver: ctrlClass];
}
@end

