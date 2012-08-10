/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORModelI.h"
#import "ORError.h"
#import "ORSolver.H"


@implementation ORModelI
{
   NSMutableArray*          _vars;
   NSMutableArray*          _cStore;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   ORObjectiveFunctionI*    _objective;
}
-(ORModelI*) initORModelI
{
   self = [super init];
   _vars  = [[NSMutableArray alloc] init];
   _cStore = [[NSMutableArray alloc] initWithCapacity:32];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _oStore = [[NSMutableArray alloc] initWithCapacity:32];
   _objective = nil;
   return self;
}

-(void) dealloc
{
   NSLog(@"Solver [%p] dealloc called...\n",self);
   [_vars release];
   [_cStore release];
   [_mStore release];
   [_oStore release];
   [_objective release];
   [super dealloc];
}

-(NSString*) description
{
   return [NSString stringWithFormat:@"Model"];
}

-(void) add: (id<ORConstraint>) c
{
   ORConstraintI* cstr = (ORConstraintI*) c;
   [cstr setId: (ORUInt) [_mStore count]];
   [_mStore addObject:c];
}

-(void) minimize: (id<ORIntVar>) x
{
   
}

-(void) maximize: (id<ORIntVar>) x
{
   
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

-(ORInt) virtualOffset: (id) obj
{
   return 0;
}

-(void) instantiate: (id<ORSolver>) solver
{
   printf("I start instantiating this model \n");
   id<ORSolverConcretizer> concretizer = [solver concretizer];
   for(id<ORAbstract> c in _vars)
      [c concretize: concretizer];
   for(id<ORAbstract> c in _mStore)
      [c concretize: concretizer];
}
@end

@implementation ORIntVarI
{
   id<ORIntVar>   _impl;
   id<ORTracker>  _tracker;
   id<ORIntRange> _domain;
   BOOL           _dense;
   ORUInt         _name;
}
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) track domain: (id<ORIntRange>) domain
{
   self = [super init];
   _tracker = track;
   _domain = domain;
   _dense = true;
   [track trackVariable: self];
   return self;
}
-(void) dealloc
{
   [super dealloc];   
}
-(void) setId: (ORUInt) name
{
   _name = name;
}
-(ORInt) getId
{
   return _name;
}
-(ORInt) value
{
   if (_impl)
      return [_impl value];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];

}
-(ORInt) min
{
   if (_impl)
      return [_impl min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(ORInt) max
{
   if (_impl)
      return [_impl max];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(ORInt) domsize
{
   if (_impl)
      return [_impl domsize];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(bool) member: (ORInt) v
{
   if (_impl)
      return [_impl member: v];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(BOOL) bound
{
   if (_impl)
      return [_impl bound];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(id<ORIntVar>) impl
{
   return _impl;
}
-(void) setImpl: (id<ORIntVar>) impl
{
   _impl = impl;
}
-(id<ORIntRange>) domain
{
   return _domain;
}
-(BOOL) hasDenseDomain
{
   return _dense;
}
-(void) concretize: (id<ORSolverConcretizer>) concretizer
{
   [concretizer intVar: self];
}
@end

@implementation ORConstraintI
{
   id<ORConstraint> _impl;
   ORUInt _name;
}
-(ORConstraintI*) initORConstraintI
{
   self = [super init];
   return self;
}
-(void) setId: (ORUInt) name;
{
   _name = name;
}
-(ORUInt) getId
{
   return _name;
}
-(id<ORConstraint>) impl
{
   return _impl;
}
-(void) setImpl: (id<ORConstraint>) impl
{
   _impl = impl;
}

@end

@implementation ORAlldifferentI
{
   id<ORIntVarArray> _x;
}
-(ORAlldifferentI*) initORAlldifferentI: (id<ORIntVarArray>) x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void) concretize: (id<ORSolverConcretizer>) concretizer
{
   [concretizer alldifferent: self];
}
@end


