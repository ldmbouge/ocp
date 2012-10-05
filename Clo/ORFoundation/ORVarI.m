//
//  ORVarI.m
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "ORVarI.h"
#import "ORError.h"
#import "ORFactory.h"

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
   _impl = nil;
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

-(id<ORASolver>) solver
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
   [v visitIntVarI: self];
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


@implementation ORFloatVarI
{
@protected
   id<ORFloatVar>   _impl;
   id<ORTracker>    _tracker;
   ORFloat          _low;
   ORFloat          _up;
   ORUInt           _name;
}
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) track low: (ORFloat) low up: (ORFloat) up
{
   self = [super init];
   _impl = nil;
   _tracker = track;
   _low = low;
   _up = up;
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
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%f,%f)",_name,_low,_up];
   else
      return [NSString stringWithFormat:@"var<OR>{int}:%03d(%f,%f) - %@",_name,_low,_up,_impl];
}

-(id<ORASolver>) solver
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
-(ORFloat) value
{
   if (_impl)
      return [_impl value];
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

-(ORFloat) min
{
   if (_impl)
      return [_impl min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(ORFloat) max
{
   if (_impl)
      return [_impl max];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(NSSet*) constraints
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
-(id<ORFloatVar>) impl
{
   return _impl;
}
-(id<ORFloatVar>) dereference
{
   return [_impl dereference];
}
-(void) setImpl: (id<ORFloatVar>) impl
{
   _impl = impl;
}
-(void) visit: (id<ORExprVisitor>) v
{
   [v visitFloatVarI: self];
}
@end
