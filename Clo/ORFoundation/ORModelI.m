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

@implementation ORConstraintI
{
   @protected
   id<ORConstraint> _impl;
   ORUInt _name;
}
-(ORConstraintI*) initORConstraintI
{
   self = [super init];
   _impl = nil;   
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
   return [_impl dereference];  
}
-(void) setImpl: (id<ORConstraint>) impl
{
   _impl = impl;
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
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORAlldifferentI: %p IS [ ",self];
   for(ORInt i = [_x low];i <= [_x up];i++) {
      [buf appendFormat:@"%@%c",_x[i],i < [_x up] ? ',' : ' '];
   }
   [buf appendString:@"]>"];
   return buf;
}
@end

@implementation ORCardinalityI
{
   id<ORIntVarArray> _x;
   id<ORIntArray>    _low;
   id<ORIntArray>    _up;
}
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
   self = [super initORConstraintI];
   _x = x;
   _low = low;
   _up = up;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(id<ORIntArray>) low
{
   return _low;
}
-(id<ORIntArray>) up
{
   return _up;
}
@end;

@implementation ORBinPackingI
{
   id<ORIntVarArray> _item;
   id<ORIntArray>    _itemSize;
   id<ORIntArray>    _binSize;
}
-(ORBinPackingI*) initORBinPackingI: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntArray>) binSize
{
   self = [super initORConstraintI];
   _item = item;
   _itemSize = itemSize;
   _binSize = binSize;
   return self;
}
-(id<ORIntVarArray>) item
{
   return _item;
}
-(id<ORIntArray>) itemSize
{
   return _itemSize;
}
-(id<ORIntArray>) binSize
{
   return _binSize;
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
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORAlgebraicConstraintI : %p IS %@>",self,_expr];
   return buf;
}
@end

@implementation ORTableConstraintI
{
   id<ORIntVarArray> _x;
   id<ORTable> _table;
}
-(ORTableConstraintI*) initORTableConstraintI: (id<ORIntVarArray>) x table: (id<ORTable>) table
{
   self = [super init];
   _x = x;
   _table = table;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(id<ORTable>) table
{
   return _table;
}
@end

@implementation ORObjectiveFunctionI
-(ORObjectiveFunctionI*) initORObjectiveFunctionI: (id<ORIntVar>) x
{
   self = [super init];
   _var = x;
   _impl = nil;
   return self;
}
-(id<ORIntVar>) var
{
   return _var;
}
-(BOOL) concretized
{
   return _impl != nil;
}
-(void) setImpl:(id<ORObjectiveFunction>)impl
{
   _impl = impl;
}
-(id<ORObjectiveFunction>)impl
{
   return _impl;
}
-(id<ORObjectiveFunction>) dereference
{
   return [_impl dereference];
}
@end


@implementation ORMinimizeI
-(ORMinimizeI*) initORMinimizeI: (id<ORIntVar>) x
{
   self = [super initORObjectiveFunctionI: x];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMinimizeI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMinimizeI: %p  --> %@> ",self,_var];
   return buf;
}
@end

@implementation ORMaximizeI
-(ORMaximizeI*) initORMaximizeI:(id<ORIntVar>) x
{
   self = [super initORObjectiveFunctionI:x];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMaximizeI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMaximizeI: %p  --> %@> ",self,_var];
   return buf;
}
@end

