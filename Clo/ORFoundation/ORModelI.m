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

