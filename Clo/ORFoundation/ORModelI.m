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
@end

@implementation OREqual3 {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
   ORAnnotation _n;
}
-(OREqual3*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   _n = DomainConsistency;
   return self;
}
-(OREqual3*)initOREqual:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z note:(ORAnnotation)n
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
   [buf appendFormat:@"<%@ : %p> -> %@ = (%@ <= %@ + %@)",[self class],self,_impl,_x,_y,_z];
   return buf;
}
-(void)visit:(id<ORVisitor>)v
{
   [v visitEqual3:self];
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
@end

// ========================================================================================================


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
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitObjectiveFunction:self];
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

