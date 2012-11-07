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

// PVH: We need to delegate the track to the engine during search

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
-(void) captureVariable:(id<ORVar>)x
{
   [_vars addObject:x];
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
-(NSArray*) variables
{
    return [NSArray arrayWithArray: _vars];
}
-(NSArray*) constraints
{
    return [NSArray arrayWithArray: _mStore];
}
-(NSArray*) objects
{
   return [NSArray arrayWithArray: _oStore];
}
-(id<ORSolution>)solution
{
   return [[ORSolutionI alloc] initSolution:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:512] autorelease];
   [buf appendFormat:@"vars[%ld] = {\n",[_vars count]];
   for(id<ORVar> v in _vars)
      [buf appendFormat:@"\t%@\n",v];
   [buf appendFormat:@"}\n"];

   [buf appendFormat:@"objects[%ld] = {\n",[_oStore count]];
   for(id<ORObject> v in _oStore)
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
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c annotation:Default];
   
   ORConstraintI* cstr = (ORConstraintI*) c;
   [cstr setId: (ORUInt) [_mStore count]];
   [_mStore addObject:c];
}

-(void) add: (id<ORConstraint>) c annotation:(ORAnnotation)n
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c annotation:n];
   
   ORConstraintI* cstr = (ORConstraintI*) c;
   [cstr setId: (ORUInt) [_mStore count]];
   [_mStore addObject:c];   
}

-(void) optimize: (id<ORObjectiveFunction>) o
{
   _objective = o;
}

-(void) minimize: (id<ORIntVar>) x
{
   _objective = [[ORMinimizeI alloc] initORMinimizeI: x];
//   [self trackObject: _objective];
}

-(void) maximize: (id<ORIntVar>) x
{
   _objective = [[ORMaximizeI alloc] initORMaximizeI: x];
//   [self trackObject: _objective];
}

-(void) trackObject: (id) obj;
{
   [_oStore addObject:obj];
}
-(void) trackVariable: (id) var;
{
   [var setId: (ORUInt) [_vars count]];
   [_vars addObject:var];
   [_oStore addObject:var];
}
-(void) trackConstraint:(id)obj
{
   [_oStore addObject:obj];
}
-(void) instantiate: (id<ORSolver>) solver
{
   NSLog(@"I start instantiating this model...");
/*
 id<ORVisit> concretizer = [solver concretizer];
   for(id c in _vars)
      [c visit: concretizer];
   for(id c in _oStore)
      [c visit: concretizer];
   for(id c in _mStore)
      [c visit: concretizer];
   [_objective visit: concretizer];
   [concretizer release];
 */
}
-(void)  applyOnVar: (void(^)(id<ORObject>)) doVar
          onObjects: (void(^)(id<ORObject>)) doObjs
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
-(void) visit: (id<ORVisitor>) visitor
{
   for(id<ORObject> c in _vars)
      [c visit: visitor];
   for(id<ORObject> c in _oStore)
      [c visit: visitor];
   for(id<ORObject> c in _mStore)
      [c visit: visitor];
   [_objective visit: visitor];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_vars];
   [aCoder encodeObject:_oStore];
   [aCoder encodeObject:_mStore];
   [aCoder encodeObject:_objective];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _vars = [[aDecoder decodeObject] retain];
   _oStore = [[aDecoder decodeObject] retain];
   _mStore = [[aDecoder decodeObject] retain];
   _objective = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
@end

@implementation ORSolutionI {
   NSArray* _shots;
}
-(ORSolutionI*) initSolution: (id<ORModel>) model
{
   self = [super init];
   NSArray* av = [model variables];
   ORULong sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   [av enumerateObjectsUsingBlock:^(id<ORSavable> obj, NSUInteger idx, BOOL *stop) {
      id<ORSavable> shot = [obj snapshot];
      if (shot)
         [snapshots addObject: shot];
      [shot release];
   }];
   _shots = snapshots;
   return self;
}
-(void) dealloc
{
   [_shots release];
   [super dealloc];
}
-(ORInt) intValue: (id) var
{
   return [[_shots objectAtIndex:[var getId]] intValue];   
}
-(BOOL) boolValue: (id) var
{
   return [[_shots objectAtIndex:[var getId]] boolValue];   
}
-(NSUInteger) count
{
   return [_shots count];   
}
- (void) encodeWithCoder: (NSCoder *)aCoder
{
   [aCoder encodeObject:_shots];   
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   _shots = [[aDecoder decodeObject] retain];
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendString:@"SOL("];
   NSUInteger last = [_shots count] - 1;
   [_shots enumerateObjectsUsingBlock:^(id<ORSnapshot> obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"%@%c",obj,idx < last ? ',' : ')'];
   }];
   return buf;
}
@end