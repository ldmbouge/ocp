/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSSolver.h"
#import "LSEngineI.h"
#import "LSConstraint.h"
#import "ORLSConcretizer.h"

@implementation LSSolver {
   id<LSConstraint> _sys;
}

-(id)initLSSolver
{
   self = [super initORGamma];
   _engine = [[LSEngineI alloc] initEngine];
   return self;
}
-(void)dealloc
{
   [_engine release];
   [super dealloc];
}
-(void)setRoot:(id<LSConstraint>)sys
{
   _sys = sys;
}
-(void)close
{
   [_engine close];
}
-(void)setSource:(id<ORModel>)m
{
   _srcModel = m;
}
-(id<OREngine>)engine
{
   return _engine;
}
-(id) concretize: (id) o
{
   return o;
}

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

-(void)solve:(void(^)())block
{
   [_engine close];
   block();
   //save solution
}
-(id<ORSolutionPool>) solutionPool
{
   return _pool;
}
-(void)label:(id<ORIntVar>)x with:(ORInt)v
{
   [_engine label:_gamma[getId(x)] with:v];
}
-(ORInt)getVarViolations:(id<ORIntVar>)var
{
   return [_sys getVarViolations:_gamma[getId(var)]];
}
-(ORInt)violations
{
   return [_sys getViolations];
}
-(ORInt)deltaWhenAssign:(id<ORIntVar>)x to:(ORInt)v
{
   return [_sys deltaWhenAssign:_gamma[getId(x)] to:v];
}
@end

@implementation ORFactory(LS)

+(id<LSProgram>) concretizeLS: (id<ORModel>) m program: (id<LSProgram>) program annotation:(id<ORAnnotation>)notes
{
   ORUInt nbEntries =  [m nbObjects];
   id* gamma = malloc(sizeof(id) * nbEntries);
   for(ORInt i = 0; i < nbEntries; i++)
      gamma[i] = NULL;
   [program setGamma: gamma];
   ORLSConcretizer* concretizer = [[ORLSConcretizer alloc] initORLSConcretizer: program annotation:notes];
   for(id<ORObject> c in [m mutables])
      [c visit: concretizer];
   for(id<ORConstraint> c in [m constraints])
      [c visit: concretizer];
   [[m objective] visit:concretizer];
   id<LSConstraint> sys = [concretizer wrapUp];
   [concretizer release];
   [program setRoot:sys];
   [program setSource:m];
   return program;
}

+(LSSolver*)createLSProgram:(id<ORModel>)model annotation:(id<ORAnnotation>)notes
{
   LSSolver* solver = [[[LSSolver alloc] initLSSolver] autorelease];
   if (notes==nil)
      notes = [[ORAnnotation alloc] init];
   id<ORAnnotation> ncpy   = [notes copy];
   id<ORModel> fm = [model flatten: ncpy];   // models are AUTORELEASE
   NSLog(@"FLAT: %@",fm);
   [self concretizeLS:fm program:solver annotation:ncpy];
   return solver;
}
@end
