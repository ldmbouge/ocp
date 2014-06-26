/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSSolver.h"
#import "LSEngineI.h"
#import "LSConstraint.h"
#import "LSSystem.h"
#import "ORLSConcretizer.h"
#import "ORLSSolution.h"
#import <ORFoundation/ORDataI.h>
#import <ORFoundation/ORSelector.h>

@implementation LSSolver {
   LSLRSystem* _sys;
   NSArray*    _hard;
}

-(id)initLSSolver
{
   self = [super init];
   _engine = [[LSEngineI alloc] initEngine];
   _pool = [ORFactory createSolutionPool];
   _hard = nil;
   return self;
}
-(void)dealloc
{
   [_engine release];
   [super dealloc];
}
-(void)setHard:(NSArray*)hc
{
   [_hard release];
   _hard = [hc retain];
}
-(void)setRoot:(LSLRSystem*)sys
{
   _sys = sys;
}
-(void)close
{
   [_engine close];
   // [ldm] Now that the solver is closed, we can initialize the hard constraints.
   for(id<LSConstraint> c in _hard) {
      [c hardInit];
   }
}
-(void)setSource:(id<ORModel>)m
{
   _srcModel = m;
}
-(id<OREngine>)engine
{
   return _engine;
}
//-(id) concretize: (id) o
//{
//   return o;
//}
//
-(id<ORTracker>) tracker
{
   return _engine;
}
-(id) trackObject: (id) obj
{
   return [_engine trackObject:obj];
}
-(id) trackMutable: (id) obj
{
   return [_engine trackMutable:obj];
}
-(id) trackImmutable: (id) obj
{
   return [_engine trackImmutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_engine trackVariable:obj];
}
-(id) trackObjective:(id) obj
{
   return [_engine trackObjective:obj];
}
-(id) trackConstraintInGroup:(id) obj
{
   return [_engine trackConstraintInGroup:obj];
}
// [pvh] what are these guys?
-(id) inCache:(id)obj
{
   return [_engine inCache:obj];
}
-(id) addToCache:(id)obj
{
   return [_engine addToCache:obj];
}
-(id)memoize:(id) obj
{
   return [_engine memoize:obj];
}
-(id<ORSearchObjectiveFunction>) objective
{
   return [_engine objective]; 
}
-(ORInt)intValue:(id<ORIntVar>)x
{
   return [(id<LSIntVar>)(_gamma[getId(x)]) value];
}
-(void)solve:(ORClosure)block
{
   [self close];
   block();
   //   if ([_sys violations].value == 0) {
   //save solution
   id<ORSolution> sol = [[ORLSSolution alloc] initORLSSolution:_srcModel with:self];
   [_pool addSolution:sol];
   //   }
}
-(id<ORSolutionPool>) solutionPool
{
   return _pool;
}
-(void)label:(id<ORIntVar>)x with:(ORInt)v
{
   [_engine label:_gamma[getId(x)] with:v];
}
-(void)swap:(id<ORIntVar>)x with:(id<ORIntVar>)y
{
   [_engine swap:_gamma[getId(x)] with:_gamma[getId(y)]];
}
-(ORInt)getVarViolations:(id<ORIntVar>)var
{
   return [_sys getVarViolations:_gamma[getId(var)]];
}
-(ORInt)getVarUnweightedViolations:(id<ORIntVar>)var
{
   return [_sys getVarUnweightedViolations:_gamma[getId(var)]];
}
-(ORInt)getVarWeightedViolations:(id<ORIntVar>)var
{
   return [_sys getVarWeightedViolations: _gamma[getId(var)]];
}

-(ORBool) isTrue
{
   return [_sys isTrue];
}

-(ORInt) getViolations
{
   return [_sys getViolations];
}
-(ORInt) getWeightedViolations
{
   return [_sys getWeightedViolations];
}
-(ORInt) getUnweightedViolations
{
   return [_sys getUnweightedViolations];
}
-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v
{
   return [_sys deltaWhenAssign:_gamma[getId(x)] to:v];
}
-(ORInt)deltaWhenSwap:(id<ORIntVar>)x with:(id<ORIntVar>)y
{
   return [_sys deltaWhenSwap:_gamma[getId(x)] with:_gamma[getId(y)]];
}
-(ORInt)weightedDeltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v
{
   return [_sys weightedDeltaWhenAssign:_gamma[getId(x)] to:v];
}
-(ORInt) unweightedDeltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v
{
   return [_sys unweightedDeltaWhenAssign:_gamma[getId(x)] to:v];
}
-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v inConstraint:(id<ORConstraint>)c
{
   return [[self concretize:c] deltaWhenAssign:_gamma[getId(x)] to:v];
}
-(ORInt)getVarViolations:(id<ORIntVar>)var forConstraint:(id<ORConstraint>)c
{
   return [[self concretize:c] getVarViolations:_gamma[getId(var)]];
}
-(ORInt)getCstrViolations:(id<ORConstraint>)cstr
{
   return [[self concretize:cstr] getViolations];
}

-(void) updateMultipliers
{
   [_sys updateMultipliers];
}
-(void) resetMultipliers
{
   [_sys resetMultipliers];
}

-(void)selectOpt:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block dir:(ORFloat)dir
{
   ORRandomStreamI* stream = [[ORRandomStreamI alloc] init];
   float bestFound = MAXFLOAT;
   ORLong bestRand = 0x7fffffffffffffff;
   ORInt indexFound = MAXINT;
   const ORInt low = r.low,up = r.up;
   for(ORInt i=low;i <= up;i++) {
      ORFloat val = dir * fun(i);
      if (val < bestFound) {
         bestFound  = val;
         indexFound = i;
         bestRand   = [stream next];
      } else if (val == bestFound) {
         ORLong r = [stream next];
         if (r < bestRand) {
            indexFound = i;
            bestRand   = r;
         }
      }
   }
   if (indexFound < MAXINT)
      block(indexFound);
   [stream release];
}
-(void)selectOpt:(id<ORIntRange>)r suchThat:(ORBool(^)(ORInt))filter orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block dir:(ORFloat)dir
{
   ORRandomStreamI* stream = [[ORRandomStreamI alloc] init];
   float bestFound = MAXFLOAT;
   ORLong bestRand = 0x7fffffffffffffff;
   ORInt indexFound = MAXINT;
   const ORInt low = r.low,up = r.up;
   for(ORInt i=low;i <= up;i++) {
      if (filter(i)) {
         ORFloat val = dir * fun(i);
         if (val < bestFound) {
            bestFound  = val;
            indexFound = i;
            bestRand   = [stream next];
         } else if (val == bestFound) {
            ORLong r = [stream next];
            if (r < bestRand) {
               indexFound = i;
               bestRand   = r;
            }
         }
      }
   }
   if (indexFound < MAXINT)
      block(indexFound);
   [stream release];
}

-(void)selectMax:(id<ORIntRange>)r suchThat:(ORBool(^)(ORInt))filter orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block
{
   [self selectOpt:r suchThat:filter orderedBy:fun do:block dir:-1.0];
}
-(void)selectMin:(id<ORIntRange>)r suchThat:(ORBool(^)(ORInt))filter orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block
{
   [self selectOpt:r suchThat:filter orderedBy:fun do:block dir:+1.0];
}
-(void)selectMax:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block
{
   [self selectOpt:r orderedBy:fun do:block dir:-1.0];
}
-(void)selectMin:(id<ORIntRange>)r orderedBy:(ORFloat(^)(ORInt))fun do:(void(^)(ORInt))block
{
   [self selectOpt:r orderedBy:fun do:block dir:+1.0];
}

-(void)selectRandom:(id<ORIntRange>)r suchThat:(ORBool(^)(ORInt))filter do:(void(^)(ORInt))block
{
   ORRandomStreamI* stream = [[ORRandomStreamI alloc] init];
   ORLong bestRand = 0x7fffffffffffffff;
   ORInt indexFound = MAXINT;
   const ORInt low = r.low,up = r.up;
   for(ORInt i=low;i <= up;i++) {
      if (filter(i)) {
         ORLong r = [stream next];
         if (r < bestRand) {
            indexFound = i;
            bestRand   = r;
         }
      }
   }
   if (indexFound < MAXINT)
      block(indexFound);
   [stream release];
}

-(void)sweep:(void(^)(id<ORSweep>))block
{
   id<ORSweep> sweep = [ORFactory sweeper:nil]; // no tracker. Release manually.
   block(sweep);
   [sweep commit];
   [sweep release];
}
@end

// [pvh] I would prefer this to be in the ORProgram framework

@implementation ORFactory(LS)

+(id<LSProgram>) concretizeLS: (id<ORModel>) m program: (id<LSProgram>) program annotation:(id<ORAnnotation>)notes
{
   ORUInt nbEntries =  [m nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [program setGamma: gamma];
   [program setModelMappings:[m modelMappings]];
   ORLSConcretizer* concretizer = [[ORLSConcretizer alloc] initORLSConcretizer: program annotation:notes];
   for(id<ORObject> c in [m mutables])
      [c visit: concretizer];
   for(id<ORConstraint> c in [m constraints])
      [c visit: concretizer];
   [[m objective] visit:concretizer];
   id<LSConstraint> sys = [concretizer wrapUp];
   [program setRoot:sys];
   [program setSource:m];
   [program setHard:[concretizer hardSet]];
   [concretizer release];
   return program;
}

// [pvh] should put a version without annotation (cleaner than passing nil)

+(LSSolver*)createLSProgram:(id<ORModel>)model annotation:(id<ORAnnotation>)notes
{
   LSSolver* solver = [[[LSSolver alloc] initLSSolver] autorelease];
   if (notes==nil)
      notes = [[ORAnnotation alloc] init];
   id<ORAnnotation> ncpy   = [notes copy];
   id<ORModel> fm = [model flatten: ncpy];   // models are AUTORELEASE
   //NSLog(@"FLAT: %@",fm);
   [self concretizeLS:fm program:solver annotation:ncpy];
   return solver;
}
@end
