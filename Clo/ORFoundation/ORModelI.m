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
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@",[self class],self,_impl];
   return buf;
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitConstraint:self];
}

@end

@implementation ORFail
-(ORFail*)init
{
   self = [super init];
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> fail",[self class],self];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitFail:self];
}
@end

@implementation ORRestrict {
   id<ORIntVar> _x;
   id<ORIntSet> _r;
}
-(ORRestrict*)initRestrict:(id<ORIntVar>)x to:(id<ORIntSet>)d
{
   self = [super initORConstraintI];
   _x = x;
   _r = d;
   return self;
}
-(id<ORIntVar>)var
{
   return _x;
}
-(id<ORIntSet>)restriction
{
   return _r;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> restrict(%@) to %@",[self class],self,_x,_r];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitRestrict:self];
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitEqualc:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) cst
{
   return _c;
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitNEqualc:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) cst
{
   return _c;
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitLEqualc:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation OREqual {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORInt        _c;
   ORAnnotation _n;
}
-(OREqual*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = c;
   _n = DomainConsistency;
   return self;
}
-(OREqual*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(ORInt)c note:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = c;
   _n = n;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@ + %d)",[self class],self,_impl,_x,_y,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitEqual:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(ORInt) cst
{
   return _c;
}
-(ORAnnotation) annotation
{
   return _n;
}
@end

@implementation ORNEqual {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORInt        _c;
}
-(ORNEqual*)initORNEqual:(id<ORIntVar>)x neq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = 0;
   return self;
}
-(ORNEqual*)initORNEqual:(id<ORIntVar>)x neq:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = c;
   return self;   
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(ORInt) cst
{
   return _c;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ != %@ + %d)",[self class],self,_impl,_x,_y,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitNEqual:self];
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitLEqual:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation ORPlus {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
   ORAnnotation _n;
}
-(ORPlus*)initORPlus:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   _n = DomainConsistency;
   return self;
}
-(ORPlus*)initORPlus:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z note:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   _n = n;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@ + %@)",[self class],self,_impl,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitPlus:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
-(ORAnnotation) annotation
{
   return _n;
}
@end

@implementation ORMult { // x = y * z
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORMult*)initORMult:(id<ORIntVar>)x eq:(id<ORIntVar>)y times:(id<ORIntVar>)z
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
-(void)visit:(id<ORVisitor>)v
{
   [v visitMult:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
@end

@implementation ORAbs { // x = |y|
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORAbs*)initORAbs:(id<ORIntVar>)x eqAbs:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == abs(%@))",[self class],self,_impl,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitAbs:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
@end


@implementation OROr { // x = y || z
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(OROr*)initOROr:(id<ORIntVar>)x eq:(id<ORIntVar>)y or:(id<ORIntVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <= %@ || %@)",[self class],self,_impl,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitOr:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
@end

@implementation ORAnd { // x = y && z
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORAnd*)initORAnd:(id<ORIntVar>)x eq:(id<ORIntVar>)y and:(id<ORIntVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <= %@ && %@)",[self class],self,_impl,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitAnd:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
@end

@implementation ORImply { // x = y => z
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORImply*)initORImply:(id<ORIntVar>)x eq:(id<ORIntVar>)y imply:(id<ORIntVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == (%@ => %@))",[self class],self,_impl,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitImply:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
@end

@implementation ORElementCst {  // y[idx] == z
   id<ORIntVar>   _idx;
   id<ORIntArray> _y;
   id<ORIntVar>   _z;
}
-(ORElementCst*)initORElement:(id<ORIntVar>)idx array:(id<ORIntArray>)y equal:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _idx = idx;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@[%@] == %@)",[self class],self,_impl,_y,_idx,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitElementCst:self];
}
-(id<ORIntArray>) array
{
   return _y;
}
-(id<ORIntVar>) idx
{
   return _idx;
}
-(id<ORIntVar>) res
{
   return _z;
}
@end

@implementation ORElementVar {  // y[idx] == z
   id<ORIntVar>     _idx;
   id<ORIntVarArray>  _y;
   id<ORIntVar>       _z;
}
-(ORElementVar*)initORElement:(id<ORIntVar>)idx array:(id<ORIntVarArray>)y equal:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _idx = idx;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@[%@] == %@)",[self class],self,_impl,_y,_idx,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitElementVar:self];
}
-(id<ORIntVarArray>) array
{
   return _y;
}
-(id<ORIntVar>) idx
{
   return _idx;
}
-(id<ORIntVar>) res
{
   return _z;
}

@end


@implementation ORReifyEqualc {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORReifyEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <=> (%@ == %d)",[self class],self,_impl,_b,_x,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitReifyEqualc:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation ORReifyNEqualc {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORReifyNEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <=> (%@ != %d)",[self class],self,_impl,_b,_x,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitReifyNEqualc:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation ORReifyEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORAnnotation _n;
}
-(ORReifyEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eq:(id<ORIntVar>)y note:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   _n = n;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <=> (%@ == %@)",[self class],self,_impl,_b,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitReifyEqual:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(ORAnnotation) annotation
{
   return _n;
}
@end

@implementation ORReifyNEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORAnnotation _n;
}
-(ORReifyNEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neq:(id<ORIntVar>)y note:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   _n = n;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <=> (%@ != %@)",[self class],self,_impl,_b,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitReifyNEqual:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(ORAnnotation) annotation
{
   return _n;
}
@end

@implementation ORReifyLEqualc {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORReifyLEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <=> (%@ <= %d)",[self class],self,_impl,_b,_x,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitReifyLEqualc:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation ORReifyLEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORAnnotation _n;
}
-(ORReifyLEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leq:(id<ORIntVar>)y note:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   _n = n;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <=> (%@ <= %@)",[self class],self,_impl,_b,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitReifyLEqual:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(ORAnnotation) annotation
{
   return _n;
}
@end

@implementation ORReifyGEqualc {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORReifyGEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <=> (%@ >= %d)",[self class],self,_impl,_b,_x,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitReifyGEqualc:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation ORReifyGEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORAnnotation _n;
}
-(ORReifyGEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geq:(id<ORIntVar>)y note:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   _n = n;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <=> (%@ >= %@)",[self class],self,_impl,_b,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitReifyGEqual:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(ORAnnotation) annotation
{
   return _n;
}
@end

// ========================================================================================================
// Sums

@implementation ORSumBoolEqc {
   id<ORIntVarArray> _ba;
   ORInt             _c;
}
-(ORSumBoolEqc*)initSumBool:(id<ORIntVarArray>)ba eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ba = ba;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sumbool(%@) == %d)",[self class],self,_impl,_ba,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitSumBoolEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(ORInt)cst
{
   return _c;
}
@end

@implementation ORSumBoolLEqc {
   id<ORIntVarArray> _ba;
   ORInt             _c;   
}
-(ORSumBoolLEqc*)initSumBool:(id<ORIntVarArray>)ba leqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ba = ba;
   _c  = c;
   return self;   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sumbool(%@) <= %d)",[self class],self,_impl,_ba,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitSumBoolLEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(ORInt)cst
{
   return _c;
}
@end

@implementation ORSumBoolGEqc {
   id<ORIntVarArray> _ba;
   ORInt             _c;
}
-(ORSumBoolGEqc*)initSumBool:(id<ORIntVarArray>)ba geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ba = ba;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sumbool(%@) >= %d)",[self class],self,_impl,_ba,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitSumBoolGEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(ORInt)cst
{
   return _c;
}
@end

@implementation ORSumEqc {
   id<ORIntVarArray> _ia;
   ORInt              _c;
}
-(ORSumEqc*)initSum:(id<ORIntVarArray>)ia eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sum(%@) == %d)",[self class],self,_impl,_ia,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitSumEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ia;
}
-(ORInt)cst
{
   return _c;
}
@end

@implementation ORSumLEqc {
   id<ORIntVarArray> _ia;
   ORInt              _c;   
}
-(ORSumLEqc*)initSum:(id<ORIntVarArray>)ia leqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sum(%@) <= %d)",[self class],self,_impl,_ia,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitSumLEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ia;
}
-(ORInt)cst
{
   return _c;
}
@end

@implementation ORSumGEqc {
   id<ORIntVarArray> _ia;
   ORInt              _c;   
}
-(ORSumGEqc*)initSum:(id<ORIntVarArray>)ia geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sum(%@) >= %d)",[self class],self,_impl,_ia,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitSumGEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ia;
}
-(ORInt)cst
{
   return _c;
}
@end

// ========================================================================================================


@implementation ORAlldifferentI
{
   id<ORIntVarArray> _x;
   ORAnnotation _n;
}
-(ORAlldifferentI*) initORAlldifferentI: (id<ORIntVarArray>) x note:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _x = x;
   _n = n;
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
-(ORAnnotation) annotation
{
   return _n;
}
@end

@implementation ORCardinalityI
{
   id<ORIntVarArray> _x;
   id<ORIntArray>    _low;
   id<ORIntArray>    _up;
   ORAnnotation _n;
}
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
   self = [super initORConstraintI];
   _x = x;
   _low = low;
   _up = up;
   _n = DomainConsistency;
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
-(ORAnnotation) annotation
{
   return _n;
}
@end

@implementation ORAlgebraicConstraintI {
   id<ORRelation> _expr;
   ORAnnotation   _note;
}
-(ORAlgebraicConstraintI*) initORAlgebraicConstraintI: (id<ORRelation>) expr annotation:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _expr = expr;
   _note = n;
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
-(ORAnnotation)annotation
{
   return _note;
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

@implementation ORLexLeq {
   id<ORIntVarArray> _x;
   id<ORIntVarArray> _y;
}
-(ORLexLeq*)initORLex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y
{
   self = [super init];
   _x = x;
   _y = y;
   return self;
}
-(id<ORIntVarArray>)x
{
   return _x;
}
-(id<ORIntVarArray>)y
{
   return _y;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitLexLeq:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = lexleq(%@,%@)>",[self class],self,_impl,_x,_y];
   return buf;
}
@end

@implementation ORCircuitI {
   id<ORIntVarArray> _x;
}
-(ORCircuitI*)initORCircuitI:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitCircuit:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = circuit(%@)>",[self class],self,_impl,_x];
   return buf;
}
@end

@implementation ORNoCycleI {
   id<ORIntVarArray> _x;
}
-(ORNoCycleI*)initORNoCycleI:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitNoCycle:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = nocycle(%@)>",[self class],self,_impl,_x];
   return buf;
}
@end

@implementation ORPackOneI {
   id<ORIntVarArray> _item;
   id<ORIntArray>    _itemSize;
   ORInt             _bin;
   id<ORIntVar>      _binSize;
}
-(ORPackOneI*)initORPackOneI:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize
{
   self = [super initORConstraintI];
   _item = item;
   _itemSize = itemSize;
   _bin = b;
   _binSize  = binSize;
   return self;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitPackOne:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = packOne(%@,%@,%d,%@)>",[self class],self,_impl,_item,_itemSize,_bin,_binSize];
   return buf;
}
-(id<ORIntVarArray>) item
{
   return _item;
}
-(id<ORIntArray>) itemSize
{
   return _itemSize;
}
-(ORInt) bin
{
   return _bin;
}
-(id<ORIntVar>) binSize
{
   return _binSize;
}
@end

@implementation ORPackingI {
   id<ORIntVarArray>        _x;
   id<ORIntArray>    _itemSize;
   id<ORIntVarArray>     _load;
}
typedef struct _CPPairIntId {
   ORInt        _int;
   id           _id;
} CPPairIntId;

int compareCPPairIntId(const CPPairIntId* r1,const CPPairIntId* r2)
{
   return r2->_int - r1->_int;
}
void sortIntVarInt(id<ORIntVarArray> x,id<ORIntArray> size,id<ORIntVarArray>* sx,id<ORIntArray>* sortedSize)
{
   id<ORIntRange> R = [x range];
   int nb = [R up] - [R low] + 1;
   ORInt low = [R low];
   ORInt up = [R up];
   CPPairIntId* toSort = (CPPairIntId*) alloca(sizeof(CPPairIntId) * nb);
   int k = 0;
   for(ORInt i = low; i <= up; i++)
      toSort[k++] = (CPPairIntId){[size at: i],x[i]};
   qsort(toSort,nb,sizeof(CPPairIntId),(int(*)(const void*,const void*)) &compareCPPairIntId);   
   *sx = [ORFactory intVarArray: [x tracker] range: R with: ^id<ORIntVar>(int i) { return toSort[i - low]._id; }];
   *sortedSize = [ORFactory intArray:[x tracker] range: R with: ^ORInt(ORInt i) { return toSort[i - low]._int; }];
}

-(ORPackingI*)initORPackingI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load
{
   self = [super initORConstraintI];   
   sortIntVarInt(x,itemSize,&_x,&_itemSize);
   _load     = load;
   return self;
}
-(id<ORIntVarArray>) item
{
   return _x;
}
-(id<ORIntArray>) itemSize
{
   return _itemSize;
}
-(id<ORIntVarArray>) binSize
{
   return _load;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitPacking:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = packing(%@,%@,%@)>",[self class],self,_impl,_x,_itemSize,_load];
   return buf;
}
@end

@implementation ORKnapsackI {
   id<ORIntVarArray> _x;
   id<ORIntArray>    _w;
   id<ORIntVar>      _c;
}
-(ORKnapsackI*)initORKnapsackI:(id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c
{
   self = [super initORConstraintI];
   _x = x;
   _w = w;
   _c = c;
   return self;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitKnapsack:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = knapsack(%@,%@,%@)>",[self class],self,_impl,_x,_w,_c];
   return buf;
}
-(id<ORIntVarArray>) item
{
   return _x;
}
-(id<ORIntArray>) weight
{
   return _w;
}
-(id<ORIntVar>) capacity
{
   return _c;
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
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitObjectiveFunction:self];
}
@end

@implementation ORIntObjectiveValue
-(id)initObjectiveValue:(id<ORIntVar>)var  minimize:(BOOL)b
{
   self = [super init];
   _value = [var value];
   _direction = b ? 1 : -1;
   return self;
}
-(ORInt)value
{
   return _value;
}
-(ORFloat)key
{
   return _value * _direction;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"%s(%d)",_direction==1 ? "min" : "max",_value];
   return buf;
}
-(BOOL)isEqual:(id)object
{
   if ([object isKindOfClass:[self class]]) {
      return _value == [((ORIntObjectiveValue*)object) value];
   } else return NO;
}
- (NSUInteger)hash
{
   return _value;
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
-(id<ORObjectiveValue>)value
{
   return [[ORIntObjectiveValue alloc] initObjectiveValue:_var minimize:YES];
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
-(id<ORObjectiveValue>)value
{
   return [[ORIntObjectiveValue alloc] initObjectiveValue:_var minimize:NO];
}
@end

