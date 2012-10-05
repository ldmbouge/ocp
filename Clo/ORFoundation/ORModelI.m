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
   [buf appendFormat:@"<%@ : %p> -> %@",[self class],self,_impl];
   return buf;
}
@end

@implementation OREqualc {
   id<ORIntVar> _x;
   ORInt        _c;
}
-(OREqualc*)initOREqualc:(id<ORIntVar>)x eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %d)",[self class],self,_impl,_x,_c];
   return buf;
}
@end

@implementation ORNEqualc {
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORNEqualc*)initORNEqualc:(id<ORIntVar>)x neqi:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ != %d)",[self class],self,_impl,_x,_c];
   return buf;
}
@end

@implementation ORLEqualc {
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORLEqualc*)initORLEqualc:(id<ORIntVar>)x leqi:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <= %d)",[self class],self,_impl,_x,_c];
   return buf;
}
@end

@implementation OREqual {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORInt        _c;
}
-(OREqual*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@ + %d)",[self class],self,_impl,_x,_y,_c];
   return buf;
}
@end

@implementation ORNEqual {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORNEqual*)initORNEqual:(id<ORIntVar>)x neq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ != %@)",[self class],self,_impl,_x,_y];
   return buf;
}
@end

@implementation ORLEqual {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORInt        _c;
}
-(ORLEqual*)initORLEqual:(id<ORIntVar>)x leq:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <= %@ + %d)",[self class],self,_impl,_x,_y,_c];
   return buf;
}
@end

@implementation OREqual3 {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(OREqual3*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <= %@ + %@)",[self class],self,_impl,_x,_y,_z];
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitAlldifferent:self];
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitCardinality:self];
}
@end

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
-(void)visit:(id<ORVisitor>)v
{
   [v visitBinPacking:self];
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitAlgebraicConstraint:self];
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitTableConstraint:self];
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitMinimize:self];
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitMaximize:self];
}
@end

