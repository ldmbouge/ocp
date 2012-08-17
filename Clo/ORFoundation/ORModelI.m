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
   NSLog(@"Solver [%p] dealloc called...\n",self);
   [_vars release];
   [_mStore release];
   [_oStore release];
   [_objective release];
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
   NSLog(@"I start instantiating this model...");
   id<ORSolverConcretizer> concretizer = [solver concretizer];
   for(id<ORAbstract> c in _vars)
      [c concretize: concretizer];
   for(id<ORAbstract> c in _mStore)
      [c concretize: concretizer];
}
-(void)applyOnVar:(void(^)(id<ORAbstract>))doVar onConstraints:(void(^)(id<ORAbstract>))doCons
{
   for(id<ORAbstract> c in _vars)
      doVar(c);
   for(id<ORAbstract> c in _mStore)
      doCons(c);
}
@end

@implementation ORIntVarI
{
   @protected
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
-(NSString*) description
{
   if (_impl == nil)
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c)",_name,[_domain description],_dense ? 'D':'S'];
   else
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c,%@)",_name,[_domain description],_dense ? 'D':'S',_impl];
}

-(id<ORSolver>) solver
{
   if (_impl)
      return [_impl solver];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
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
-(ORBounds)bounds
{
   if (_impl)
      return [_impl bounds];
   else
      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
}
-(BOOL) member: (ORInt) v
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
-(BOOL) isBool
{
   if (_impl)
      return [_impl isBool];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(NSSet*)constraints
{
   if (_impl)
      return [_impl constraints];
   else
      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
}

-(id<ORTracker>) tracker
{
   return _tracker;
}
-(id<ORIntVar>) impl
{
   return _impl;
}
-(id<ORIntVar>) dereference
{
   return [_impl dereference];
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
   _impl = [concretizer intVar: self];
}
-(ORInt)scale
{
   return 1;
}
-(ORInt)shift
{
   return 0;
}
-(id<ORIntVar>)base
{
   return self;
}
-(void) visit: (id<ORExprVisitor>) v
{
   [((ORExprI*)[_impl dereference]) visit: v];
}
@end

@implementation ORIntVarAffineI {
   ORInt        _a;
   id<ORIntVar> _x;
   ORInt        _b;
}
-(ORIntVarAffineI*)initORIntVarAffineI:(id<ORTracker>)tracker var:(id<ORIntVar>)x scale:(ORInt)a shift:(ORInt)b
{
   id<ORIntRange> xr = [x domain];
   id<ORIntRange> ar;
   if (a > 0)
      ar = [ORFactory intRange:tracker low:a * [xr low] + b up:a * [xr up] + b];
   else
      ar = [ORFactory intRange:tracker low:a * [xr up] + b up:a * [xr low] + b];
   self = [super initORIntVarI:tracker domain:ar];
   _a = a;
   _x = x;
   _b = b;
   return self;
}
-(NSString*) description
{
   char d = _dense ? 'D':'S';
   if (_impl == nil)
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c,(%d * %@ + %d)",_name,[_domain description],d,_a,_x,_b];
   else
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c,(%d * %@ + %d,%@)",_name,[_domain description],d,_a,_x,_b,_impl];
}
-(void) concretize: (id<ORSolverConcretizer>) concretizer
{
   _impl = [concretizer affineVar: self];
}
-(ORInt)scale
{
   return _a;
}
-(ORInt)shift
{
   return _b;
}
-(id<ORIntVar>)base
{
   return _x;
}
@end

@implementation ORConstraintI
{
   @protected
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
-(id<ORConstraint>) dereference
{
   return _impl;  // [ldm] should probably be [_impl dereference] but must add [dereference] message on all concrete constraints (self)
}
-(void) setImpl: (id<ORConstraint>) impl
{
   _impl = impl;
}
-(void) concretize: (id<ORSolverConcretizer>) concretizer
{
   @throw [[ORExecutionError alloc] initORExecutionError:"Can't concretize an abstract constraint"];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> = %@",[self class],self,_impl];
   return buf;
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
   _impl = [concretizer alldifferent: self];
}
@end

@implementation ORAlgebraicConstraintI
{
   id<ORRelation> _expr;
}
-(ORAlgebraicConstraintI*) initORAlgebraicConstraintI: (id<ORRelation>) expr
{
   self = [super initORConstraintI];
   _expr = expr;
   return self;
}
-(id<ORRelation>) expr
{
   return _expr;
}
-(void) concretize: (id<ORSolverConcretizer>) concretizer
{
   _impl = [concretizer algebraicConstraint: self];
}
@end
