/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORModelI.h"
#import "ORError.h"
#import "ORSolver.H"

@implementation ORModelI
{
   NSMutableArray*          _vars;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   ORObjectiveFunctionI*    _objective;
   ORUInt                   _name;
}
-(ORModelI*) initORModelI
{
   self = [super init];
   _vars  = [[NSMutableArray alloc] init];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _oStore = [[NSMutableArray alloc] initWithCapacity:32];
   _objective = nil;
   _name = 0;
   return self;
}

-(void) dealloc
{
   NSLog(@"ORModelI [%p] dealloc called...\n",self);
   [_vars release];
   [_mStore release];
   [_oStore release];
   [super dealloc];
}

-(void) setId: (ORUInt) name
{
   _name = name;
}
-(id<ORSolver>) solver
{
   return nil;
}
-(id<ORObjectiveFunction>)objective
{
   return _objective;
}

-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:512] autorelease];
   [buf appendFormat:@"vars[%ld] = {\n",[_vars count]];
   for(id<ORVar> v in _vars)
      [buf appendFormat:@"\t%@\n",v];
   [buf appendFormat:@"}\n"];
   
   [buf appendFormat:@"cstr[%ld] = {\n",[_mStore count]];
   for(id<ORConstraint> c in _mStore)
      [buf appendFormat:@"\t%@\n",c];
   [buf appendFormat:@"}\n"];
   return buf;
}

-(void) add: (id<ORConstraint>) c
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c];
   
   ORConstraintI* cstr = (ORConstraintI*) c;
   [cstr setId: (ORUInt) [_mStore count]];
   [_mStore addObject:c];
}

-(void) minimize: (id<ORIntVar>) x
{
   _objective = [[ORMinimizeI alloc] initORMinimizeI: self obj: x];
   [self trackObject: _objective];
}

-(void) maximize: (id<ORIntVar>) x
{
   _objective = [[ORMaximizeI alloc] initORMaximizeI: self obj: x];
   [self trackObject: _objective];
}

-(void) trackObject: (id) obj;
{
   [_oStore addObject:obj];
   [obj autorelease];
}

-(void) trackVariable: (id) var;
{
   [var setId: (ORUInt) [_vars count]];
   [_vars addObject:var];
   [var autorelease];
}

-(void) instantiate: (id<ORSolver>) solver
{
   NSLog(@"I start instantiating this model...");
   id<ORSolverConcretizer> concretizer = [solver concretizer];
   for(id c in _vars)
      [c concretize: concretizer];
   for(id c in _oStore)
      [c concretize: concretizer];
   for(id c in _mStore)
      [c concretize: concretizer];
   [_objective concretize: concretizer];
   [concretizer release];
}
-(void)applyOnVar: (void(^)(id<ORObject>)) doVar onObjects:(void(^)(id<ORObject>))doObjs
    onConstraints:(void(^)(id<ORObject>)) doCons
      onObjective:(void(^)(id<ORObject>)) doObjective
{
   for(id<ORObject> c in _vars)
      doVar(c);
   for(id<ORObject> c in _oStore)
      doObjs(c);
   for(id<ORObject> c in _mStore)
      doCons(c);
   doObjective(_objective);
}
@end
