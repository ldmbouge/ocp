/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORError.h>
#import "ORConstraintI.h"

@implementation ORConstraintI
-(ORConstraintI*) initORConstraintI
{
   self = [super init];
   _impl = nil;   
   return self;
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

@implementation ORGroupI {
   NSMutableArray* _content;
   id<ORTracker>     _model;
   enum ORGroupType     _gt;
}
-(ORGroupI*)initORGroupI:(id<ORTracker>)model type:(enum ORGroupType)gt
{
   self = [super init];
   _model = model;
   _content = [[NSMutableArray alloc] initWithCapacity:8];
   _name = -1;
   _gt = gt;
   return self;
}
-(void)dealloc
{
   [_content release];
   [super dealloc];
}
-(id<ORConstraint>)add:(id<ORConstraint>)c
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      c = [ORFactory algebraicConstraint:_model expr: (id<ORRelation>)c annotation:Default];
   [_content addObject:c];
   return c;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@",[self class],self,_impl];
   [buf appendString:@"{"];
   [_content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"%@,",[obj description]];
   }];
   [buf appendString:@"}"];
   return buf;
}
-(void)enumerateObjectWithBlock:(void(^)(id<ORConstraint>))block
{
   [_content enumerateObjectsUsingBlock:^(id obj,NSUInteger idx, BOOL *stop) {
      block(obj);
   }];
}

-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitGroup:self];
}
-(enum ORGroupType)type
{
   return _gt;
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

@implementation ORGEqualc {
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORGEqualc*)initORGEqualc:(id<ORIntVar>)x geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ >= %d)",[self class],self,_impl,_x,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitGEqualc:self];
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
-(OREqual*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(ORInt)c annotation:(ORAnnotation)n
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

@implementation ORAffine {   // y == a * x + b
   ORInt _a;
   ORInt _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORAnnotation _note;
}
-(ORAffine*)initORAffine: (id<ORIntVar>) y eq:(ORInt)a times:(id<ORIntVar>) x plus: (ORInt) b annotation: (ORAnnotation) n
{
   self = [super initORConstraintI];
   _a = a;
   _b = b;
   _x = x;
   _y = y;
   assert(a != 0);
   _note = n;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %d * %@ + %d)",[self class],self,_impl,_y,_a,_x,_b];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitAffine:self];
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _x;
}
-(ORInt)coef
{
   return _a;
}
-(ORInt)cst
{
   return _b;
}
-(ORAnnotation)annotation
{
   return _note;
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
-(ORPlus*)initORPlus:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z annotation:(ORAnnotation)n
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

@implementation ORSquare { // z == x^2
   id<ORIntVar> _z;
   id<ORIntVar> _x;
   ORAnnotation _n;
}
-(ORSquare*)initORSquare:(id<ORIntVar>)z square:(id<ORIntVar>)x annotation:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _x = x;
   _z = z;
   _n = n;
   return self;
}
-(id<ORIntVar>)res
{
   return _z;
}
-(id<ORIntVar>)op
{
   return _x;
}
-(ORAnnotation)annotation
{
   return _n;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@ ^ 2)",[self class],self,_impl,_z,_x];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitSquare:self];
}
@end

@implementation ORMod { // z = x MOD y
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORMod*)initORMod:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@ MOD %@)",[self class],self,_impl,_z,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitMod:self];
}
-(id<ORIntVar>) res
{
   return _z;
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
@end

@implementation ORModc { // z = x MOD y  (y==c)
   id<ORIntVar> _x;
   ORInt        _y;
   id<ORIntVar> _z;
   ORAnnotation _n;
}
-(ORModc*)initORModc:(id<ORIntVar>)x mod:(ORInt)y equal:(id<ORIntVar>)z annotation:(ORAnnotation)n
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
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@ MOD %d)",[self class],self,_impl,_z,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitModc:self];
}
-(id<ORIntVar>) res
{
   return _z;
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) right
{
   return _y;
}
-(ORAnnotation) annotation
{
   return _n;
}
@end

@implementation ORAbs { // x = |y|
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORAnnotation _annotation;
}
-(ORAbs*)initORAbs:(id<ORIntVar>)x eqAbs:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _annotation = Default;
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
-(ORAnnotation) annotation
{
   return _annotation;
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
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@ || %@)",[self class],self,_impl,_x,_y,_z];
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
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@ && %@)",[self class],self,_impl,_x,_y,_z];
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
   ORAnnotation  _note;
}
-(ORElementCst*)initORElement:(id<ORIntVar>)idx array:(id<ORIntArray>)y equal:(id<ORIntVar>)z annotation:(ORAnnotation)n
{
   self = [super initORConstraintI];
   _idx = idx;
   _y = y;
   _z = z;
   _note = n;
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
-(ORAnnotation)annotation
{
   return _note;
}
@end

@implementation ORElementVar {  // y[idx] == z
   id<ORIntVar>     _idx;
   id<ORIntVarArray>  _y;
   id<ORIntVar>       _z;
   ORAnnotation    _note;
}
-(ORElementVar*)initORElement:(id<ORIntVar>)idx array:(id<ORIntVarArray>)y equal:(id<ORIntVar>)z
                   annotation:(ORAnnotation)note
{
   self = [super initORConstraintI];
   _idx = idx;
   _y = y;
   _z = z;
   _note = note;
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
-(ORAnnotation)annotation
{
   return _note;
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
-(ORReifyEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eq:(id<ORIntVar>)y annotation:(ORAnnotation)n
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
-(ORReifyNEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neq:(id<ORIntVar>)y annotation:(ORAnnotation)n
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
-(ORReifyLEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leq:(id<ORIntVar>)y annotation:(ORAnnotation)n
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
-(ORReifyGEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geq:(id<ORIntVar>)y annotation:(ORAnnotation)n
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
-(ORSumLEqc*) initSum:(id<ORIntVarArray>)ia leqi:(ORInt)c
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

@implementation ORLinearGeq {
   id<ORIntVarArray> _ia;
   id<ORIntArray>    _coefs;
   ORInt             _c;
}
-(ORLinearGeq*) initLinearGeq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) coefs cst: (ORInt) c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sum(%@,%@) >= %d)",[self class],self,_impl,_ia,_coefs,_c];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitLinearGeq: self];
}
-(id<ORIntVarArray>) vars
{
   return _ia;
}
-(id<ORIntArray>) coefs
{
   return _coefs;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation ORLinearLeq {
   id<ORIntVarArray> _ia;
   id<ORIntArray>    _coefs;
   ORInt             _c;
}
-(ORLinearLeq*) initLinearLeq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) coefs cst:(ORInt)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sum(%@,%@) <= %d)",[self class],self,_impl,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (id<ORVisitor>) v
{
   [v visitLinearLeq: self];
}
-(id<ORIntVarArray>) vars
{
   return _ia;
}
-(id<ORIntArray>) coefs
{
   return _coefs;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation ORLinearEq {
   id<ORIntVarArray> _ia;
   id<ORIntArray>    _coefs;
   ORInt             _c;
}
-(ORLinearEq*) initLinearEq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) coefs cst:(ORInt) c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sum(%@,%@) >= %d)",[self class],self,_impl,_ia,_coefs,_c];
   return buf;
}
-(void)visit: (id<ORVisitor>) v
{
   [v visitLinearEq: self];
}
-(id<ORIntVarArray>) vars
{
   return _ia;
}
-(id<ORIntArray>) coefs
{
   return _coefs;
}
-(ORInt) cst
{
   return _c;
}
@end

@implementation ORFloatLinearEq {
   id<ORVarArray> _ia;
   id<ORFloatArray>  _coefs;
   ORFloat _c;
}
-(ORFloatLinearEq*) initFloatLinearEq: (id<ORVarArray>) ia coef: (id<ORFloatArray>) coefs cst:(ORFloat) c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sum(%@,%@) >= %f)",[self class],self,_impl,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (id<ORVisitor>) v
{
   [v visitFloatLinearEq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORFloatArray>) coefs
{
   return _coefs;
}
-(ORFloat) cst
{
   return _c;
}
@end

@implementation ORFloatLinearLeq {
   id<ORVarArray> _ia;
   id<ORFloatArray> _coefs;
   ORFloat _c;
}
-(ORFloatLinearLeq*) initFloatLinearLeq: (id<ORVarArray>) ia coef: (id<ORFloatArray>) coefs cst:(ORFloat)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (sum(%@,%@) <= %f)",[self class],self,_impl,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (id<ORVisitor>) v
{
   [v visitFloatLinearLeq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORFloatArray>) coefs
{
   return _coefs;
}
-(ORFloat) cst
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
-(ORAlldifferentI*) initORAlldifferentI: (id<ORIntVarArray>) x annotation:(ORAnnotation)n
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
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up annotation:(ORAnnotation)c
{
   self = [super initORConstraintI];
   _x = x;
   _low = low;
   _up = up;
   _n = c;
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
   [buf appendFormat:@"<ORAlgebraicConstraintI : %p(%d) IS %@>",self,[self getId],_expr];
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

@implementation ORAssignmentI {
   id<ORIntVarArray> _x;
   id<ORIntMatrix> _matrix;
   id<ORIntVar>    _cost;
}
-(ORAssignmentI*)initORAssignment:(id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost
{
   self = [super initORConstraintI];
   _x = x;
   _matrix = matrix;
   _cost = cost;
   return self;
}
-(id<ORIntVarArray>) x
{
   return _x;
}
-(id<ORIntMatrix>) matrix
{
   return _matrix;
}
-(id<ORIntVar>) cost
{
   return _cost;
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitAssignment:self];
}
@end

@implementation ORObjectiveFunctionI
-(ORObjectiveFunctionI*) initORObjectiveFunctionI
{
   self = [super init];
   return self;
}
-(id<ORObjectiveValue>) value
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method value/0 not implemented"];   
}
@end

@implementation ORObjectiveFunctionVarI
-(ORObjectiveFunctionVarI*) initORObjectiveFunctionVarI: (id<ORIntVar>) x
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
-(id<ORObjectiveValue>)value
{
  return NULL;
}
-(ORBool) concretized
{
   return _impl != nil;
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitObjectiveFunctionVar:self];
}
@end

@implementation ORObjectiveValueIntI
-(id) initObjectiveValueIntI: (ORInt) pb minimize: (ORBool) b
{
   self = [super init];
   _value = pb;
   _pBound = pb;
   _direction = b ? 1 : -1;
   return self;
}
-(ORInt) value
{
   return _value;
}
-(ORInt) primal
{
   return _pBound;
}
-(ORFloat) key
{
   return _value * _direction;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
//   [buf appendFormat:@"%s(%d)",_direction==1 ? "min" : "max",_value];
   [buf appendFormat:@"%d",_value];
   return buf;
}
-(ORBool)isEqual:(id)object
{
   if ([object isKindOfClass:[self class]]) {
      return _value == [((ORObjectiveValueIntI*)object) value];
   } else return NO;
}
- (NSUInteger)hash
{
   return _value;
}
-(id<ORObjectiveValue>) best: (ORObjectiveValueIntI*) other
{
   if ([self key] <= [other key])
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: _value minimize: _direction == 1];
   else
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: [other value] minimize: _direction == 1];
}
-(ORInt) compare: (ORObjectiveValueIntI*) other
{
   ORInt mykey = [self key];
   ORInt okey = [other key];
   if (mykey < okey)
      return -1;
   else if (mykey == okey)
      return 0;
   else
      return 1;
}
@end

@implementation ORObjectiveValueFloatI
-(id) initObjectiveValueFloatI: (ORFloat) pb minimize: (ORBool) b
{
   self = [super init];
   _value = pb;
   _pBound = pb;
   _direction = b ? 1 : -1;
   return self;
}
-(ORFloat) value
{
   return _value;
}
-(ORFloat) primal
{
   return _pBound;
}
-(ORFloat) key
{
   return _value * _direction;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   //   [buf appendFormat:@"%s(%d)",_direction==1 ? "min" : "max",_value];
   [buf appendFormat:@"%f",_value];
   return buf;
}

-(ORBool)isEqual:(id)object
{
   if ([object isKindOfClass:[self class]]) {
      return _value == [((ORObjectiveValueFloatI*)object) value];
   } else return NO;
}

- (NSUInteger) hash
{
   return _value;
}

-(id<ORObjectiveValue>) best: (ORObjectiveValueFloatI*) other
{
   if ([self key] <= [other key])
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: _value minimize: _direction == 1];
   else
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: [other value] minimize: _direction == 1];
}

-(ORInt) compare: (ORObjectiveValueFloatI*) other
{
   ORInt mykey = [self key];
   ORInt okey = [other key];
   if (mykey < okey)
      return -1;
   else if (mykey == okey)
      return 0;
   else
      return 1;
}
@end


@implementation ORObjectiveFunctionExprI
-(ORObjectiveFunctionExprI*) initORObjectiveFunctionExprI: (id<ORExpr>) e
{
   self = [super init];
   _expr = e;
   _impl = nil;
   return self;
}
-(id<ORExpr>) expr
{
   return _expr;
}
-(ORBool) concretized
{
   return _impl != nil;
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitObjectiveFunctionExpr: self];
}
@end

@implementation ORObjectiveFunctionLinearI
-(ORObjectiveFunctionLinearI*) initORObjectiveFunctionLinearI: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   self = [super init];
   _array = array;
   _coef = coef;
   _impl = nil;
   return self;
}
-(id<ORVarArray>) array
{
   return _array;
}
-(id<ORFloatArray>) coef
{
   return _coef;
}
-(ORBool) concretized
{
   return _impl != nil;
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitObjectiveFunctionLinear: self];
}
@end

@implementation ORMinimizeVarI
-(ORMinimizeVarI*) initORMinimizeVarI: (id<ORIntVar>) x
{
   self = [super initORObjectiveFunctionVarI: x];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMinimizeVarI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMinimizeVarI: %p  --> %@> ",self,_var];
   return buf;
}
-(void)visit:(id<ORVisitor>) v
{
   [v visitMinimizeVar:self];
}
-(id<ORObjectiveValue>) value
{
   return [((id<ORSearchObjectiveFunction>) _impl) value];
}
-(id<ORObjectiveValue>) primalBound
{
   return [_impl primalBound];
}
@end

@implementation ORMaximizeVarI
-(ORMaximizeVarI*) initORMaximizeVarI:(id<ORIntVar>) x
{
   self = [super initORObjectiveFunctionVarI:x];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMaximizeVarI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMaximizeVarI: %p  --> %@> ",self,_var];
   return buf;
}
-(void)visit:(id<ORVisitor>) v
{
   [v visitMaximizeVar:self];
}
-(id<ORObjectiveValue>) value
{
   return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: [_var value] minimize: NO];
}
@end

@implementation ORMaximizeExprI
-(ORMaximizeExprI*) initORMaximizeExprI:(id<ORExpr>) e
{
   self = [super initORObjectiveFunctionExprI: e];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMaximizeExprI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMaximizeExprI: %p  --> %@> ",self,_expr];
   return buf;
}
-(void) visit:(id<ORVisitor>)v
{
   [v visitMaximizeExpr:self];
}
-(id<ORObjectiveValue>) value
{
   return [((ORObjectiveFunctionI*) _impl) value];
}
@end

@implementation ORMinimizeExprI
-(ORMinimizeExprI*) initORMinimizeExprI:(id<ORExpr>) e
{
   self = [super initORObjectiveFunctionExprI: e];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMinimizeExprI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMinimizeExprI: %p  --> %@> ",self,_expr];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitMinimizeExpr:self];
}
-(id<ORObjectiveValue>) value
{
   return [((ORObjectiveFunctionI*) _impl) value];
}
@end

@implementation ORMaximizeLinearI
-(ORMaximizeLinearI*) initORMaximizeLinearI: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   self = [super initORObjectiveFunctionLinearI: array coef: coef];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMaximizeLinearI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMaximizeLinearI: %p  --> %@ %@> ",self,_array,_coef];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitMaximizeLinear:self];
}
-(id<ORObjectiveValue>) value
{
   return [((ORObjectiveFunctionI*) _impl) value];
}
@end

@implementation ORMinimizeLinearI
-(ORMinimizeLinearI*) initORMinimizeLinearI: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   self = [super initORObjectiveFunctionLinearI: array coef: coef];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMinimizeLinearI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMinimizeLinearI: %p  --> %@ %@> ",self,_array,_coef];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitMinimizeLinear:self];
}
-(id<ORObjectiveValue>) value
{
   return NULL;
}
@end

@implementation ORBitEqual {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitEqual*)initORBitEqual: (id<ORBitVar>) x eq: (id<ORBitVar>) y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ == %@)",[self class],self,_impl,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitEqual:self];
}
@end

@implementation ORBitOr {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitOr*)initORBitOr: (id<ORBitVar>) x or:(id<ORBitVar>) y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ | %@ = %@)",[self class],self,_impl,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitOr:self];
}
@end

@implementation ORBitAnd {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitAnd*)initORBitAnd: (id<ORBitVar>) x and:(id<ORBitVar>) y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ & %@ = %@)",[self class],self,_impl,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitAnd:self];
}
@end

@implementation ORBitNot {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitNot*)initORBitNot: (id<ORBitVar>) x not: (id<ORBitVar>) y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ ~ %@)",[self class],self,_impl,_x,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitNot:self];
}
@end

@implementation ORBitXor {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitXor*)initORBitXor: (id<ORBitVar>) x xor:(id<ORBitVar>) y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ ^ %@ = %@)",[self class],self,_impl,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitXor:self];
}
@end

@implementation ORBitShiftL {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   ORInt _places;
}
-(ORBitShiftL*)initORBitShiftL: (id<ORBitVar>) x by:(ORInt) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(ORInt) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <<%d = %@)",[self class],self,_impl,_x,_places,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitShiftL:self];
}
@end

@implementation ORBitRotateL {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   ORInt _places;
}
-(ORBitRotateL*)initORBitRotateL: (id<ORBitVar>) x by:(ORInt) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(ORInt) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <<<%d = %@)",[self class],self,_impl,_x,_places,_y];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitRotateL:self];
}
@end

@implementation ORBitSum {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _ci;
   id<ORBitVar> _z;
   id<ORBitVar> _co;
}
-(ORBitSum*)initORBitSum: (id<ORBitVar>) x plus:(id<ORBitVar>)y in:(id<ORBitVar>)ci eq:(id<ORBitVar>)z out:(id<ORBitVar>)co
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _ci = ci;
   _z = z;
   _co = co;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) in
{
   return _ci;
}
-(id<ORBitVar>) out
{
   return _co;
}

-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ + %@ [cin %@] = %@ [cout %@])",[self class],self,_impl,_x,_y,_ci,_z,_co];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitSum:self];
}
@end

@implementation ORBitIf {
   id<ORBitVar> _w;
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitIf*)initORBitIf: (id<ORBitVar>)w trueIf:(id<ORBitVar>)x equals:(id<ORBitVar>)y zeroIfXEquals:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _w = w;
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _w;
}
-(id<ORBitVar>) trueIf
{
   return _x;
}
-(id<ORBitVar>) equals
{
   return _y;
}
-(id<ORBitVar>) zeroIfXEquals
{
   return _z;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ true if (x=%@)  equals %@ and false if x equals %@.])",[self class],self,_impl,_w,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitBitIf:self];
}
@end