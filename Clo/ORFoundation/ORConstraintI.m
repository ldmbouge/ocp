/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORError.h>
#import <ORFoundation/ORFactory.h>
#import "ORConstraintI.h"
#import "ORParameterI.h"

@implementation ORConstraintI
-(ORConstraintI*) initORConstraintI
{
   self = [super init];
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p>",[self class],self];
   return buf;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitConstraint:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] init] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] init] autorelease];
}
-(void) close
{
   
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   return self;
}
-(ORBool) memberVar:(id<ORVar>)x
{
   NSSet *vars = [self allVars];
   return [vars containsObject:x];
}
-(ORUInt) nbOccurences:(id<ORVar>)x
{
   NSArray *vars = [self allVarsArray];
   ORUInt i = 0;
   for(id<ORVar> v in vars){
      if ([v getId] == [x getId])
         i++;
   }
   return i;
}
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x
{
   return 0.0;
}
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
   return 0.0;
}
@end

@implementation ORGroupI {
   NSMutableArray* _content;
   id<ORTracker>     _model;
   enum ORGroupType     _gt;
   id<ORIntVar>      _guard;
}
-(ORGroupI*)initORGroupI:(id<ORTracker>)model type:(enum ORGroupType)gt
{
   self = [super init];
   _model = model;
   _content = [[NSMutableArray alloc] initWithCapacity:8];
   _name = -1;
   _gt = gt;
   _guard = nil;
   return self;
}
-(ORGroupI*)initORGroupI:(id<ORTracker>)model type:(enum ORGroupType)gt guard:(id<ORIntVar>)g
{
   self = [super init];
   _model = model;
   _content = [[NSMutableArray alloc] initWithCapacity:8];
   _name = -1;
   _gt = gt;
   _guard = g;
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
      c = [ORFactory algebraicConstraint:_model expr: (id<ORRelation>)c];
   [_content addObject:c];
   [_model trackConstraintInGroup:c];
   return c;
}
-(id<ORIntVar>)guard
{
   return _guard;
}
-(void) close
{
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> ",[self class],self];
   [buf appendString:@"{\n"];
   [_content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"\t\t%@\n",[obj description]];
   }];
   [buf appendString:@"\t}"];
   if (_gt == GuardedGroup)
      [buf appendFormat:@" guard: %@",_guard];
   return buf;
}
-(void)enumerateObjectWithBlock:(void(^)(id<ORConstraint>))block
{
   for(id obj in _content)
      block(obj);
}
-(ORInt) size
{
    return (ORInt)[_content count];
}
-(id<ORConstraint>) at: (ORInt) idx
{
    return [_content objectAtIndex: idx];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] init] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] init] autorelease];
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitGroup:self];
}
-(enum ORGroupType)type
{
   return _gt;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_content];
   [aCoder encodeObject:_model];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_gt];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _content = [aDecoder decodeObject];
   _model   = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_gt];
   return self;
}
-(ORBool) memberVar:(id<ORVar>)x
{
   NSSet *vars = [self allVars];
   return [vars containsObject:x];
}
-(ORUInt) nbOccurences:(id<ORVar>)x
{
   NSArray *vars = [self allVarsArray];
   ORUInt i = 0;
   for(id<ORVar> v in vars){
      if ([v getId] == [x getId])
         i++;
   }
   return i;
}
-(ORDouble) leadToAnAbsorption:(id<ORVar>)x
{
   return 0.0;
}
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
   return 0.0;
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
-(void)visit:(ORVisitor*)v
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
-(void)visit:(ORVisitor*)v
{
   [v visitRestrict:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_r];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _r = [aDecoder decodeObject];
   return self;
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
-(void)dealloc
{
   //NSLog(@"OREqualc::dealloc: %p",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORFloatEqualc {
   id<ORFloatVar> _x;
   ORFloat        _c;
}
-(ORFloatEqualc*)initORFloatEqualc:(id<ORFloatVar>)x eqi:(ORFloat)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %16.16f)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitFloatEqualc:self];
}
-(id<ORFloatVar>) left
{
   return _x;
}
-(ORFloat) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_c];
   return self;
}
@end

@implementation ORDoubleEqualc {
   id<ORDoubleVar> _x;
   ORDouble        _c;
}
-(ORDoubleEqualc*)initORDoubleEqualc:(id<ORDoubleVar>)x eqi:(ORDouble)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %16.16e)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitDoubleEqualc:self];
}
-(id<ORDoubleVar>) left
{
   return _x;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORFloat) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORFloat) at:&_c];
   return self;
}
@end

@implementation ORRealEqualc {
   id<ORRealVar> _x;
   ORDouble        _c;
}
-(ORRealEqualc*)init:(id<ORRealVar>)x eqi:(ORDouble)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %f)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRealEqualc:self];
}
-(id<ORRealVar>) left
{
   return _x;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_c];
   return self;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ != %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORFloatNEqualc {
   id<ORFloatVar> _x;
   ORFloat        _c;
}
-(ORFloatNEqualc*)initORFloatNEqualc:(id<ORFloatVar>)x neqi:(ORFloat)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ != %16.16e)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitFloatNEqualc:self];
}
-(id<ORFloatVar>) left
{
   return _x;
}
-(ORFloat) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORDoubleNEqualc {
   id<ORDoubleVar> _x;
   ORDouble        _c;
}
-(ORDoubleNEqualc*)initORDoubleNEqualc:(id<ORDoubleVar>)x neqi:(ORDouble)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ != %16.16e)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitDoubleNEqualc:self];
}
-(id<ORDoubleVar>) left
{
   return _x;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <= %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ >= %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end


@implementation OREqual {
   id<ORVar> _x;
   id<ORVar> _y;
   ORInt     _c;
}
-(id)initOREqual:(id<ORVar>)x eq:(id<ORVar>)y plus:(ORInt)c
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ + %d)",[self class],self,_x,_y,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitEqual:self];
}
-(id<ORVar>) left
{
   return _x;
}
-(id<ORVar>) right
{
   return _y;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x, _y,nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORAffine {   // y == a * x + b
   ORInt _a;
   ORInt _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORAffine*)initORAffine: (id<ORIntVar>) y eq:(ORInt)a times:(id<ORIntVar>) x plus: (ORInt) b
{
   self = [super initORConstraintI];
   _a = a;
   _b = b;
   _x = x;
   _y = y;
   assert(a != 0);
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %d * %@ + %d)",[self class],self,_y,_a,_x,_b];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ != %@ + %d)",[self class],self,_x,_y,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitNEqual:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORSoftNEqual {
    id<ORVar> _slack;
}
-(id) initORSoftNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y slack: (id<ORVar>)slack {
   self = [super initORNEqual: x neq: y];
   if(self) _slack = slack;
   return self;
}
-(id) initORSoftNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y plus: (ORInt) c slack: (id<ORVar>)slack {
   self = [super initORNEqual: x neq: y plus: c];
   if(self) _slack = slack;
   return self;
}
-(id<ORVar>) slack
{
   return _slack;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSoftNEqual:self];
}
@end

@implementation ORLEqual {  // a * x ≤ b * y + c
   ORInt     _a,_b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORInt        _c;
}
-(ORLEqual*)initORLEqual:(id<ORIntVar>)x leq:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _a = _b = 1;
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(ORLEqual*)initORLEqual:(ORInt)a times:(id<ORIntVar>)x leq:(ORInt)b times:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _a = a;
   _b = b;
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%d * %@ <= %d * %@ + %d)",[self class],self,_a,_x,_b,_y,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(ORInt) coefLeft
{
   return _a;
}
-(ORInt) coefRight
{
   return _b;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_a];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_b];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_a];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_b];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORPlus {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORPlus*)initORPlus:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ + %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORMult { // x = y * z
   id<ORVar> _x;
   id<ORVar> _y;
   id<ORVar> _z;
}
-(ORMult*)initORMult:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ * %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMult:self];
}
-(id<ORVar>) res
{
   return _x;
}
-(id<ORVar>) left
{
   return _y;
}
-(id<ORVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORSquare { // z == x^2
   id<ORVar> _z;
   id<ORVar> _x;
}
-(id)init:(id<ORVar>)z square:(id<ORVar>)x
{
   self = [super initORConstraintI];
   _x = x;
   _z = z;
   return self;
}
-(id<ORVar>)res
{
   return _z;
}
-(id<ORVar>)op
{
   return _x;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ ^ 2)",[self class],self,_z,_x];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSquare:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORRealSquare
-(void)visit:(ORVisitor*)v
{
   [v visitRealSquare:self];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ MOD %@)",[self class],self,_z,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORModc { // z = x MOD y  (y==c)
   id<ORIntVar> _x;
   ORInt        _y;
   id<ORIntVar> _z;
}
-(ORModc*)initORModc:(id<ORIntVar>)x mod:(ORInt)y equal:(id<ORIntVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ MOD %d)",[self class],self,_z,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_z, nil] autorelease];
}
@end

@implementation ORMin { // z = min(x,y)
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORMin*)init:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == MIN(%@,%@))",[self class],self,_z,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMin:self];
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORMax { // z = max(x,y)
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORMax*)init:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == MAX(%@,%@))",[self class],self,_z,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMax:self];
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == abs(%@))",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ || %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ && %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == (%@ => %@))",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end


@implementation ORBinImply { // x => y
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORBinImply*)init:(id<ORIntVar>)x imply:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ => %@ >",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBinImply:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@[%@] == %@)",[self class],self,_y,_idx,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_idx,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_idx,_z, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@[%@] == %@)",[self class],self,_y,_idx,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:2 + [_y count]] autorelease];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_idx];
   [ms addObject:_z];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:2 + [_y count]] autorelease];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_idx];
   [ms addObject:_z];
   return ms;
}
@end

@implementation ORElementBitVar {  // y[idx] == z
   id<ORBitVar>     _idx;
   id<ORIdArray>  _y;
   id<ORBitVar>       _z;
}
-(ORElementBitVar*)initORElement:(id<ORBitVar>)idx array:(id<ORIdArray>)y equal:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@[%@] == %@)",[self class],self,_y,_idx,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitElementBitVar:self];
}
-(id<ORIdArray>) array
{
   return _y;
}
-(id<ORBitVar>) idx
{
   return _idx;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:2 + [_y count]] autorelease];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_idx];
   [ms addObject:_z];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:2 + [_y count]] autorelease];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_idx];
   [ms addObject:_z];
   return ms;
}
@end

@implementation ORElementMatrixVar {
   id<ORIntVarMatrix> _m;
   id<ORIntVar> _v0;
   id<ORIntVar> _v1;
   id<ORIntVar> _y;
}
-(id)initORElement:(id<ORIntVarMatrix>)m elt:(id<ORIntVar>)v0 elt:(id<ORIntVar>)v1 equal:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _m = m;
   _v0 = v0;
   _v1 = v1;
   _y  = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@[%@,%@] == %@)",[self class],self,_m,_v0,_v1,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitElementMatrixVar:self];
}
-(id<ORIntVarMatrix>)matrix
{
   return _m;
}
-(id<ORIntVar>)index0
{
   return _v0;
}
-(id<ORIntVar>)index1
{
   return _v1;
}
-(id<ORIntVar>) res
{
   return _y;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:2 + [_m count]] autorelease];
   [[_m range:0] enumerateWithBlock:^(ORInt i) {
      [[_m range:1] enumerateWithBlock:^(ORInt j) {
         [ms addObject:[_m at:i :j]];
      }];
   }];
   [ms addObject:_v0];
   [ms addObject:_v1];
   [ms addObject:_y];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:2 + [_m count]] autorelease];
   [[_m range:0] enumerateWithBlock:^(ORInt i) {
      [[_m range:1] enumerateWithBlock:^(ORInt j) {
         [ms addObject:[_m at:i :j]];
      }];
   }];
   [ms addObject:_v0];
   [ms addObject:_v1];
   [ms addObject:_y];
   return ms;
}
@end


@implementation ORRealElementCst {  // y[idx] == z
   id<ORIntVar>   _idx;
   id<ORDoubleArray> _y;
   id<ORRealVar>   _z;
}
-(id)initORElement:(id<ORIntVar>)idx array:(id<ORDoubleArray>)y equal:(id<ORRealVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@[%@] == %@)",[self class],self,_y,_idx,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRealElementCst:self];
}
-(id<ORDoubleArray>) array
{
   return _y;
}
-(id<ORIntVar>) idx
{
   return _idx;
}
-(id<ORRealVar>) res
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_idx,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_idx,_z, nil] autorelease];
}
@end


@implementation ORImplyEqualc {
    id<ORIntVar> _b;
    id<ORIntVar> _x;
    ORInt        _c;
}
-(ORImplyEqualc*)initImply:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eqi:(ORInt)c
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
    [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ == %d)",[self class],self,_b,_x,_c];
    return buf;
}
-(void)visit:(ORVisitor*)v
{
    [v visitImplyEqualc:self];
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
-(NSSet*)allVars
{
    return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_b];
    [aCoder encodeObject:_x];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _b = [aDecoder decodeObject];
    _x = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
    return self;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ == %d)",[self class],self,_b,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ != %d)",[self class],self,_b,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifyEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORReifyEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ == %@)",[self class],self,_b,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORReifyNEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORReifyNEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ != %@)",[self class],self,_b,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ <= %d)",[self class],self,_b,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifyLEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORReifyLEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ <= %@)",[self class],self,_b,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ >= %d)",[self class],self,_b,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifyGEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORReifyGEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ >= %@)",[self class],self,_b,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

// ========================================================================================================
// Sums

@implementation ORReifySumBoolEqc {
   id<ORIntVar>       _b;
   id<ORIntVarArray> _ba;
   ORInt              _c;
}
-(id) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _ba = ba;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (reify:%@ sumbool(%@) == %d)",[self class],self,_b,_ba,_c];
   return buf;
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(id<ORIntVar>) b
{
   return _b;
}
-(ORInt)cst
{
   return _c;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifySumBoolEqualc:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_ba];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _ba= [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifySumBoolGEqc {
   id<ORIntVar>       _b;
   id<ORIntVarArray> _ba;
   ORInt              _c;
}
-(id) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _ba = ba;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (reify:%@ sumbool(%@) >= %d)",[self class],self,_b,_ba,_c];
   return buf;
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(id<ORIntVar>) b
{
   return _b;
}
-(ORInt)cst
{
   return _c;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifySumBoolGEqualc:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_ba];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _ba= [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORHReifySumBoolEqc {
   id<ORIntVar>       _b;
   id<ORIntVarArray> _ba;
   ORInt              _c;
}
-(id) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _ba = ba;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (hreify:%@ sumbool(%@) == %d)",[self class],self,_b,_ba,_c];
   return buf;
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(id<ORIntVar>) b
{
   return _b;
}
-(ORInt)cst
{
   return _c;
}
-(void)visit:(ORVisitor*)v
{
   [v visitHReifySumBoolEqualc:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_ba];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _ba= [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORHReifySumBoolGEqc {
   id<ORIntVar>       _b;
   id<ORIntVarArray> _ba;
   ORInt              _c;
}
-(id) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _ba = ba;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (hreify:%@ sumbool(%@) >= %d)",[self class],self,_b,_ba,_c];
   return buf;
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(id<ORIntVar>) b
{
   return _b;
}
-(ORInt)cst
{
   return _c;
}
-(void)visit:(ORVisitor*)v
{
   [v visitHReifySumBoolGEqualc:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_ba];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _ba= [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORClause {
   id<ORIntVarArray>  _ba;
   id<ORIntVar>       _tv;
}
-(id)init:(id<ORIntVarArray>)ba eq:(id<ORIntVar>)tv
{
   self = [super initORConstraintI];
   _ba = ba;
   _tv = tv;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (clause(%@) == %@)",[self class],self,_ba,_tv];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitClause:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_tv];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_tv];
   return ms;
}
-(id<ORIntVar>)targetValue
{
   return _tv;
}
@end

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
   [buf appendFormat:@"<%@ : %p> -> (sumbool(%@) == %d)",[self class],self,_ba,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORSumBoolNEqc {
   id<ORIntVarArray> _ba;
   ORInt             _c;
}
-(ORSumBoolNEqc*)initSumBool:(id<ORIntVarArray>)ba neqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ba = ba;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sumbool(%@) != %d)",[self class],self,_ba,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSumBoolNEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(ORInt)cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
   [buf appendFormat:@"<%@ : %p> -> (sumbool(%@) <= %d)",[self class],self,_ba,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
   [buf appendFormat:@"<%@ : %p> -> (sumbool(%@) >= %d)",[self class],self,_ba,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@) == %d)",[self class],self,_ia,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@) <= %d)",[self class],self,_ia,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@) >= %d)",[self class],self,_ia,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) >= %d)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) <= %d)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (ORVisitor*) v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) == %d)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(NSUInteger)count
{
   assert([_ia count] == [_coefs count]);
   return [_ia count];
}
-(void)visit: (ORVisitor*) v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end


@implementation ORFloatMult { // x = y * z
   id<ORVar> _x;
   id<ORVar> _y;
   id<ORVar> _z;
}
-(ORFloatMult*)initORFloatMult:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ * %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitFloatMult:self];
}
-(id<ORVar>) res
{
   return _x;
}
-(id<ORVar>) left
{
   return _y;
}
-(id<ORVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORFloatDiv { // x = y * z
   id<ORVar> _x;
   id<ORVar> _y;
   id<ORVar> _z;
}
-(ORFloatDiv*)initORFloatDiv:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ / %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitFloatDiv:self];
}
-(id<ORVar>) res
{
   return _x;
}
-(id<ORVar>) left
{
   return _y;
}
-(id<ORVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORFloatLinearEq{
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) == %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORFloatLinearNEq{
   id<ORVarArray> _ia;
   id<ORFloatArray>  _coefs;
   ORFloat _c;
}
-(ORFloatLinearNEq*) initFloatLinearNEq: (id<ORVarArray>) ia coef: (id<ORFloatArray>) coefs cst:(ORFloat) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) != %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitFloatLinearNEq: self];
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORFloatLinearLT{
   id<ORVarArray> _ia;
   id<ORFloatArray>  _coefs;
   ORFloat _c;
}
-(ORFloatLinearLT*) initFloatLinearLT: (id<ORVarArray>) ia coef: (id<ORFloatArray>) coefs cst:(ORFloat) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) < %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitFloatLinearLT: self];
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORFloatLinearGT{
   id<ORVarArray> _ia;
   id<ORFloatArray>  _coefs;
   ORFloat _c;
}
-(ORFloatLinearGT*) initFloatLinearGT: (id<ORVarArray>) ia coef: (id<ORFloatArray>) coefs cst:(ORFloat) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) > %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitFloatLinearGT: self];
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORFloatLinearGEQ{
   id<ORVarArray> _ia;
   id<ORFloatArray>  _coefs;
   ORFloat _c;
}
-(ORFloatLinearGEQ*) initFloatLinearGEQ: (id<ORVarArray>) ia coef: (id<ORFloatArray>) coefs cst:(ORFloat) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) >= %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitFloatLinearGEQ: self];
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORFloatLinearLEQ{
   id<ORVarArray> _ia;
   id<ORFloatArray>  _coefs;
   ORFloat _c;
}
-(ORFloatLinearLEQ*) initFloatLinearLEQ: (id<ORVarArray>) ia coef: (id<ORFloatArray>) coefs cst:(ORFloat) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) <= %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitFloatLinearLEQ: self];
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

//----

@implementation ORDoubleMult { // x = y * z
   id<ORVar> _x;
   id<ORVar> _y;
   id<ORVar> _z;
}
-(ORDoubleMult*)initORDoubleMult:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ * %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitDoubleMult:self];
}
-(id<ORVar>) res
{
   return _x;
}
-(id<ORVar>) left
{
   return _y;
}
-(id<ORVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORDoubleDiv { // x = y * z
   id<ORVar> _x;
   id<ORVar> _y;
   id<ORVar> _z;
}
-(ORDoubleDiv*)initORDoubleDiv:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ / %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitDoubleDiv:self];
}
-(id<ORVar>) res
{
   return _x;
}
-(id<ORVar>) left
{
   return _y;
}
-(id<ORVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORDoubleLinearEq{
   id<ORVarArray> _ia;
   id<ORDoubleArray>  _coefs;
   ORDouble _c;
}
-(ORDoubleLinearEq*) initDoubleLinearEq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) == %lf)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitDoubleLinearEq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORDoubleLinearNEq{
   id<ORVarArray> _ia;
   id<ORDoubleArray>  _coefs;
   ORDouble _c;
}
-(ORDoubleLinearNEq*) initDoubleLinearNEq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) != %lf)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitDoubleLinearNEq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORDoubleLinearLT{
   id<ORVarArray> _ia;
   id<ORDoubleArray>  _coefs;
   ORDouble _c;
}
-(ORDoubleLinearLT*) initDoubleLinearLT: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) < %lf)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitDoubleLinearLT: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORDoubleLinearGT{
   id<ORVarArray> _ia;
   id<ORDoubleArray>  _coefs;
   ORDouble _c;
}
-(ORDoubleLinearGT*) initDoubleLinearGT: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) > %lf)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitDoubleLinearGT: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORDoubleLinearGEQ{
   id<ORVarArray> _ia;
   id<ORDoubleArray>  _coefs;
   ORDouble _c;
}
-(ORDoubleLinearGEQ*) initDoubleLinearGEQ: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) >= %lf)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitDoubleLinearGEQ: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORDoubleLinearLEQ{
   id<ORVarArray> _ia;
   id<ORDoubleArray>  _coefs;
   ORDouble _c;
}
-(ORDoubleLinearLEQ*) initDoubleLinearLEQ: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) <= %lf)",[self class],self,_ia,_coefs,_c];
   return buf;
}

-(void) visit: (ORVisitor*) v
{
   [v visitDoubleLinearLEQ: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end



//----

@implementation ORRealLinearEq {
   id<ORVarArray> _ia;
   id<ORDoubleArray>  _coefs;
   ORDouble _c;
}
-(ORRealLinearEq*) initRealLinearEq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble) c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) == %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (ORVisitor*) v
{
   [v visitRealLinearEq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORRealLinearLeq {
   id<ORVarArray> _ia;
   id<ORDoubleArray> _coefs;
   ORDouble _c;
}
-(ORRealLinearLeq*) initRealLinearLeq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble)c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) <= %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (ORVisitor*) v
{
   [v visitRealLinearLeq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORRealLinearGeq {
   id<ORVarArray> _ia;
   id<ORDoubleArray> _coefs;
   ORDouble _c;
}
-(id) initRealLinearGeq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble)c
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
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) >= %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (ORVisitor*) v
{
   [v visitRealLinearGeq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end


@implementation ORAlldifferentI {
   id<ORExprArray> _x;
   NSSet*         _av;
}
-(ORAlldifferentI*) initORAlldifferentI: (id<ORExprArray>) x
{
   self = [super initORConstraintI];
   _x = x;
   _av = nil;
   return self;
}
-(void)dealloc
{
   [_av release];
   [super dealloc];
}
-(id<ORExprArray>) array
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
-(void)visit:(ORVisitor*)v
{
   [v visitAlldifferent:self];
}
-(NSSet*)allVars
{
   if (_av == nil) {
      NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
      for(id<ORExpr> e in _x)
         [ms addObject:e];
//      [_x enumerateWith:^(id obj, int idx) {
//         [ms addObject:obj];
//      }];
      _av = [ms retain];
   }
   return _av;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   for(id<ORExpr> e in _x)
      [ms addObject:e];
   return ms;
}
@end

@implementation ORRegularI {
   id<ORIntVarArray>    _x;
   id<ORAutomaton>   _auto;
}
-(id)init:(id<ORIntVarArray>)x  for:(id<ORAutomaton>)a
{
   self = [super initORConstraintI];
   _x = x;
   _auto = a;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(id<ORAutomaton>)automaton
{
   return _auto;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORRegularI: %p IS [ ",self];
   for(ORInt i = [_x low];i <= [_x up];i++) {
      [buf appendFormat:@"%@%c",_x[i],i < [_x up] ? ',' : ' '];
   }
   [buf appendString:@"]>"];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRegular:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORCardinalityI
{
   id<ORIntVarArray> _x;
   id<ORIntArray>    _low;
   id<ORIntArray>     _up;
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
-(void)visit:(ORVisitor*)v
{
   [v visitCardinality:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@interface VarCollector : ORNOopVisit {
   NSMutableSet* _theSet;
   NSMutableArray* _theArray;
}
-(id)init:(NSMutableSet*)theSet;
-(id)initwith:(NSMutableArray*)theArray;
+(NSSet*)collect:(id<ORExpr>)e;
+(NSArray*)collectAsArray:(id<ORExpr>)e;
@end

@implementation VarCollector
+(NSSet*)collect:(id<ORExpr>)e
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:4];
   VarCollector* vc = [[VarCollector alloc] init:rv];
   [e visit:vc];
   [vc release];
   return rv;
}
+(NSArray*)collectAsArray:(id<ORExpr>)e
{
   NSMutableArray* rv = [[NSMutableArray alloc] initWithCapacity:4];
   VarCollector* vc = [[VarCollector alloc] initwith:rv];
   [e visit:vc];
   [vc release];
   return rv;
}
-(id)init:(NSMutableSet*)theSet
{
   self = [super init];
   _theSet = theSet;
   _theArray = [[NSMutableArray alloc] initWithCapacity:4];
   return self;
}
-(id)initwith:(NSMutableArray *)theArray
{
   self = [super init];
   _theArray = theArray;
   _theSet = [[NSMutableSet alloc] initWithCapacity:4];
   return self;
}
-(void) visitIntVar: (id<ORIntVar>) v
{
   [_theSet addObject:v];
   [_theArray addObject:v];
}
-(void) visitBitVar: (id<ORBitVar>) v
{
   [_theSet addObject:v];
   [_theArray addObject:v];
}
-(void) visitRealVar: (id<ORRealVar>) v
{
   [_theSet addObject:v];
   [_theArray addObject:v];
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   [_theSet addObject:v];
   [_theArray addObject:v];
}
-(void) visitDoubleVar: (id<ORDoubleVar>) v
{
   [_theSet addObject:v];
   [_theArray addObject:v];
}
-(void) visitLDoubleVar: (id<ORLDoubleVar>) v
{
   [_theSet addObject:v];
   [_theArray addObject:v];
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   [_theSet addObject:v];
   [_theArray addObject:v];
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
   [_theSet addObject:v];
   [_theArray addObject:v];
}
-(void) visitIntegerI: (id<ORInteger>) e
{}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{}
-(void) visitDouble: (id<ORDoubleNumber>) e
{}
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMaxI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMinI: (ORExprAggMinI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMaxI: (ORExprAggMaxI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   [[e operand] visit:self];
}
-(void) visitExprSquareI:(ORExprSquareI*)e
{
   [[e operand] visit:self];
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
   [[e operand] visit:self];
}
-(void) visitExprCstSubI: (ORExprCstSubI*) e
{
   [[e index] visit:self];
}
-(void) visitExprCstDoubleSubI:(ORExprCstDoubleSubI*)e
{
   [[e index] visit:self];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprAggOrI: (ORExprAggOrI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggAndI: (ORExprAggAndI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprVarSubI: (ORExprVarSubI*) e
{
   [[e index] visit:self];
   id<ORIntVarArray> a = [e array];
   for(id<ORIntVar> ak in a){
      [_theSet addObject:ak];
      [_theArray addObject:ak];
   }
}
-(void) visitExprMatrixVarSubI:(ORExprMatrixVarSubI*)e
{
   [[e index0] visit:self];
   [[e index1] visit:self];
   id<ORIntVarMatrix> m = [e matrix];
   ORInt sz = (ORInt)[m count];
   for(ORInt i=0;i < sz;i++){
      [_theSet addObject:[m  flat:i]];
      [_theArray addObject:[m  flat:i]];
   }
}
@end

@implementation ORAlgebraicConstraintI {
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
   [buf appendFormat:@"<ORAlgebraicConstraintI : %p(%d) IS %@>",self,[self getId],_expr];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitAlgebraicConstraint:self];
}
-(NSSet*)allVars
{
   NSSet* ms = [[VarCollector collect:_expr] autorelease];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSArray* ms = [[VarCollector collectAsArray:_expr] autorelease];
   return ms;
}
@end

@implementation ORSoftAlgebraicConstraintI {
   id<ORVar> _slack;
}
-(ORSoftAlgebraicConstraintI*) initORSoftAlgebraicConstraintI: (id<ORRelation>) expr slack: (id<ORVar>)slack
{
   self = [super initORAlgebraicConstraintI: expr];
   _slack = slack;
   return self;
}
-(id<ORVar>) slack
{
   return _slack;
}
@end

@implementation ORRealWeightedVarI {
   id<ORVar> _x;
   id<ORVar> _z;
   id<ORParameter> _lambda;
}
-(ORRealWeightedVarI*) initRealWeightedVar: (id<ORVar>)x
{
   self = [super initORConstraintI];
   _x = x;
   _z = [ORFactory realVar: [(id<ORExpr>)x tracker]  low:FDMININT up:FDMAXINT];
   _lambda = [[ORRealParamI alloc] initORRealParamI: [(id<ORExpr>)x tracker] initialValue: 0.0]; // TOTRY [ldm] try with param @ 1.
   return self;
}
-(id<ORVar>) z
{
   return _z;
}
-(id<ORVar>)x
{
   return _x;
}
-(id<ORParameter>)weight
{
   return _lambda;
}
-(NSSet*) allVars
{
   return [[NSSet setWithObjects: _x, _z, nil] autorelease];
}
-(NSArray*) allVarsArray
{
   return [[NSArray arrayWithObjects: _x, _z, nil] autorelease];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORFloatWeightedConstraintI : %p(%d) IS %@ = %@ * %@",self,[self getId],_z,_lambda,_x];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRealWeightedVar:self];
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
-(void)visit:(ORVisitor*)v
{
   [v visitTableConstraint:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
-(void)visit:(ORVisitor*)v
{
   [v visitLexLeq:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> lexleq(%@,%@)>",[self class],self,_x,_y];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]+[_y count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]+[_y count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORCircuit {
   id<ORIntVarArray> _x;
}
-(ORCircuit*)initORCircuit:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(ORVisitor*)v
{
   [v visitCircuit:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> circuit(%@)>",[self class],self,_x];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORPath {
   id<ORIntVarArray> _x;
}
-(ORPath*) initORPath:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(ORVisitor*)v
{
   [v visitPath:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> path(%@)>",[self class],self,_x];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end
   
@implementation ORSubCircuit {
   id<ORIntVarArray> _x;
}
-(ORSubCircuit*)initORSubCircuit:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSubCircuit:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> subcircuit(%@)>",[self class],self,_x];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end


@implementation ORNoCycleI {
   id<ORIntVarArray> _x;
}
-(id) initORNoCycleI:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(ORVisitor*)v
{
   [v visitNoCycle:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> nocycle(%@)>",[self class],self,_x];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
-(void)visit:(ORVisitor*)v
{
   [v visitPackOne:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> packOne(%@,%@,%d,%@)>",[self class],self,_item,_itemSize,_bin,_binSize];
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_item count]+1] autorelease];
   [_item enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_binSize];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_item count]+1] autorelease];
   [_item enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_binSize];
   return ms;
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
-(void)visit:(ORVisitor*)v
{
   [v visitPacking:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> packing(%@,%@,%@)>",[self class],self,_x,_itemSize,_load];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]+[_load count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_load enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]+[_load count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_load enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORMultiKnapsackI {
   id<ORIntVarArray>        _x;
   id<ORIntArray>           _itemSize;
   id<ORIntArray>           _capacity;
}
-(ORMultiKnapsackI*)initORMultiKnapsackI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize capacity: (id<ORIntArray>) capacity
{
   self = [super initORConstraintI];
   _x = x;
   _itemSize = itemSize;
   _capacity    = capacity;
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
-(id<ORIntArray>) capacity
{
   return _capacity;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMultiKnapsack:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> multiknapsack(%@,%@,%@)>",[self class],self,_x,_itemSize,_capacity];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORMultiKnapsackOneI {
   id<ORIntVarArray>        _x;
   id<ORIntArray>           _itemSize;
   ORInt                    _bin;
   ORInt                   _capacity;
}
-(ORMultiKnapsackOneI*)initORMultiKnapsackOneI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b capacity: (ORInt) capacity
{
   self = [super initORConstraintI];
   _x = x;
   _itemSize = itemSize;
   _bin = b;
   _capacity    = capacity;
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
-(ORInt) capacity
{
   return _capacity;
}
-(ORInt) bin
{
   return _bin;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMultiKnapsackOne: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> multiknapsackOne(%@,%@,%d)>",[self class],self,_x,_itemSize,_capacity];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end


@implementation ORMeetAtmostI {
   id<ORIntVarArray>        _x;
   id<ORIntVarArray>        _y;
   ORInt                    _k;
}
-(ORMeetAtmostI*)initORMeetAtmostI:(id<ORIntVarArray>) x and: (id<ORIntVarArray>) y atmost: (ORInt) atmost
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _k = atmost;
   return self;
}
-(id<ORIntVarArray>) x
{
   return _x;
}
-(id<ORIntVarArray>) y
{
   return _y;
}
-(ORInt) atmost
{
   return _k;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMeetAtmost:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> MeetAtmost(%@,%@,%d)>",[self class],self,_x,_y,_k];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
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
-(void)visit:(ORVisitor*)v
{
   [v visitKnapsack:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> knapsack(%@,%@,%@)>",[self class],self,_x,_w,_c];
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
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORSoftKnapsackI {
   id<ORVar> _slack;
}
-(ORSoftKnapsackI*) initORSoftKnapsackI:(id<ORIntVarArray>)x weight:(id<ORIntArray>)w capacity:(id<ORIntVar>)c slack:(id<ORVar>)slack
{
   self = [super initORKnapsackI: x weight: w capacity: c];
   if(self) {
      _slack = slack;
   }
   return self;
}

-(id<ORVar>) slack
{
   return _slack;
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
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitAssignment:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]+1] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_cost];
   return ms;
}
-(NSArray*)allVarsArray
{
   NSMutableArray* ms = [[[NSMutableArray alloc] initWithCapacity:[_x count]+1] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_cost];
   return ms;
}
@end

@implementation ORObjectiveFunctionI
-(ORObjectiveFunctionI*) initORObjectiveFunctionI
{
   self = [super init];
   return self;
}
-(id<ORObjectiveValue>) primalValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method primalValue/0 not implemented"];
}
-(id<ORObjectiveValue>) dualValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method dualValue/0 not implemented"];
}
-(id<ORObjectiveValue>) primalBound
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method primalBound/0 not implemented"];
}
-(id<ORObjectiveValue>) dualBound
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method dualBound/0 not implemented"];
}
@end

@implementation ORObjectiveFunctionVarI
-(ORObjectiveFunctionVarI*) initORObjectiveFunctionVarI: (id<ORVar>) x
{
   self = [super init];
   _var = x;
   return self;
}
-(id<ORVar>) var
{
   return _var;
}
-(id<ORObjectiveValue>)value
{
  return NULL;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitObjectiveFunctionVar:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_var, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_var, nil] autorelease];
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
-(ORInt) intValue
{
   return _value;
}
-(ORDouble) doubleValue
{
   return _value;
}
-(ORInt) primal
{
   return _pBound;
}
-(ORDouble) key
{
   return _value * _direction;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
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
-(NSComparisonResult) compare: (ORObjectiveValueIntI*) other
{
   ORInt mykey = [self key];
   ORInt okey = [other key];
   if (mykey < okey)
      return NSOrderedAscending;
   else if (mykey == okey)
      return NSOrderedSame;
   else
      return NSOrderedDescending;
}
@end

@implementation ORObjectiveValueRealI
-(id) initObjectiveValueRealI: (ORDouble) pb minimize: (ORBool) b
{
   self = [super init];
   _value = pb;
   _pBound = pb;
   _direction = b ? 1 : -1;
   return self;
}
-(ORDouble) value
{
   return _value;
}
-(ORDouble) doubleValue
{
   return _value;
}
-(ORDouble) primal
{
   return _pBound;
}
-(ORDouble) key
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
      return _value == [((ORObjectiveValueRealI*)object) value];
   } else return NO;
}

- (NSUInteger) hash
{
   return _value;
}

-(id<ORObjectiveValue>) best: (ORObjectiveValueRealI*) other
{
   if ([self key] <= [other key])
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: _value minimize: _direction == 1];
   else
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: [other value] minimize: _direction == 1];
}

-(NSComparisonResult) compare: (ORObjectiveValueRealI*) other
{
   ORFloat mykey = [self key];
   ORFloat okey = [other key];
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
   return self;
}
-(id<ORExpr>) expr
{
   return _expr;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitObjectiveFunctionExpr: self];
}
@end

@implementation ORObjectiveFunctionLinearI
-(ORObjectiveFunctionLinearI*) initORObjectiveFunctionLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
{
   self = [super init];
   _array = array;
   _coef = coef;
   return self;
}
-(id<ORVarArray>) array
{
   return _array;
}
-(id<ORDoubleArray>) coef
{
   return _coef;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitObjectiveFunctionLinear: self];
}
@end

@implementation ORMinimizeVarI
-(ORMinimizeVarI*) initORMinimizeVarI: (id<ORVar>) x
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
-(void)visit:(ORVisitor*) v
{
   [v visitMinimizeVar:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_var, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_var, nil] autorelease];
}
@end

@implementation ORMaximizeVarI
-(ORMaximizeVarI*) initORMaximizeVarI:(id<ORVar>) x
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
-(void)visit:(ORVisitor*) v
{
   [v visitMaximizeVar:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_var, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_var, nil] autorelease];
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
-(void) visit:(ORVisitor*)v
{
   [v visitMaximizeExpr:self];
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
-(void)visit:(ORVisitor*)v
{
   [v visitMinimizeExpr:self];
    //[v visitMinimizeVar: self];
}
@end

@implementation ORMaximizeLinearI
-(ORMaximizeLinearI*) initORMaximizeLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
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
-(void)visit:(ORVisitor*)v
{
   [v visitMaximizeLinear:self];
}
@end

@implementation ORMinimizeLinearI
-(ORMinimizeLinearI*) initORMinimizeLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
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
-(void)visit:(ORVisitor*)v
{
   [v visitMinimizeLinear:self];
}
-(id<ORObjectiveValue>) value
{
   return NULL;
}
@end


@implementation ORBitEqualAt {
   id<ORBitVar>    _x;
   ORInt         _bit;
   ORInt         _val;
}
-(ORBitEqualAt*)init:(id<ORBitVar>)x at:(ORInt)k with:(ORInt)c
{
   self = [super initORConstraintI];
   _x  = x;
   _bit = k;
   _val = c;
   return self;
}
-(id<ORBitVar>)left
{
   return _x;
}
-(ORInt)cst
{
   return _val;
}
-(ORInt)bit {
   return _bit;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@[%d] == %d)",[self class],self,_x,_bit,_val];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitEqualAt:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
@end

@implementation ORBitEqualc {
   id<ORBitVar> _x;
   ORInt        _c;
}
-(ORBitEqualc*)init:(id<ORBitVar>)x eqc:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(id<ORBitVar>)left
{
   return _x;
}
-(ORInt)cst
{
   return _c;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitEqualc:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@)",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitEqual:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitOr {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitOr*)initORBitOr: (id<ORBitVar>) x bor:(id<ORBitVar>) y eq:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ | %@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitOr:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitAnd {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitAnd*)initORBitAnd: (id<ORBitVar>) x band:(id<ORBitVar>) y eq:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ & %@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitAnd:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitNot {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitNot*)initORBitNot: (id<ORBitVar>) x bnot: (id<ORBitVar>) y
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
   [buf appendFormat:@"<%@ : %p> -> (%@ ~ %@)",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitNot:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitXor {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitXor*)initORBitXor: (id<ORBitVar>) x bxor:(id<ORBitVar>) y eq:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ ^ %@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitXor:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <<%d = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftL:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitShiftL_BV {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _places;
}
-(ORBitShiftL_BV*)initORBitShiftL_BV: (id<ORBitVar>) x by:(id<ORBitVar>) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(id<ORBitVar>) places
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
   [buf appendFormat:@"<%@ : %p> -> (%@ << %@ = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftL_BV:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_places, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_places, nil] autorelease];
}
@end

@implementation ORBitShiftR {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   ORInt _places;
}
-(ORBitShiftR*)initORBitShiftR: (id<ORBitVar>) x by:(ORInt) p eq:(id<ORBitVar>)y
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
   [buf appendFormat:@"<%@ : %p> -> (%@ >>%d = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftR:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitShiftR_BV {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _places;
}
-(ORBitShiftR_BV*)initORBitShiftR_BV: (id<ORBitVar>) x by:(id<ORBitVar>) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(id<ORBitVar>) places
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
   [buf appendFormat:@"<%@ : %p> -> (%@ >> %@ = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftR_BV:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_places, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_places, nil] autorelease];
}
@end

@implementation ORBitShiftRA {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   ORInt _places;
}
-(ORBitShiftRA*)initORBitShiftRA: (id<ORBitVar>) x by:(ORInt) p eq:(id<ORBitVar>)y
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
   [buf appendFormat:@"<%@ : %p> -> (%@ >>a %d = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftRA:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitShiftRA_BV {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _places;
}
-(ORBitShiftRA_BV*)initORBitShiftRA_BV: (id<ORBitVar>) x by:(id<ORBitVar>) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(id<ORBitVar>) places
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
   [buf appendFormat:@"<%@ : %p> -> (%@ >>a %@ = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftRA_BV:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_places, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_places, nil] autorelease];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <<<%d = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitRotateL:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_ci,_z,_co, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_ci,_z,_co, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ + %@ [cin %@] = %@ [cout %@])",[self class],self,_x,_y,_ci,_z,_co];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSum:self];
}
@end

@implementation ORBitNegative{
   id<ORBitVar> _x;
   id<ORBitVar> _y;

}
-(ORBitNegative*)initORBitNegative: (id<ORBitVar>) x eq:(id<ORBitVar>)y
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
-(id<ORBitVar>) res
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (-%@ = %@ )",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitNegative:self];
}
@end


@implementation ORBitSubtract {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitSubtract*)initORBitSubtract: (id<ORBitVar>) x minus:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ - %@ = %@ )",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSubtract:self];
}
@end

@implementation ORBitMultiply {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitMultiply*)initORBitMultiply: (id<ORBitVar>) x times:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
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
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ * %@ = %@ )",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitMultiply:self];
}
@end


@implementation ORBitDivide {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _q;
   id<ORBitVar> _r;
}
-(ORBitDivide*)initORBitDivide: (id<ORBitVar>) x dividedby:(id<ORBitVar>)y eq:(id<ORBitVar>)q rem:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _q = q;
   _r = r;
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
   return _q;
}
-(id<ORBitVar>) rem
{
   return _r;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_q, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_q, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ / %@ = %@)",[self class],self,_x,_y,_q];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitDivide:self];
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
   [buf appendFormat:@"<%@ : %p> -> (%@ true if (x=%@)  equals %@ and false if x equals %@.])",[self class],self,_w,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitIf:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_w,_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_w,_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitCount {
   id<ORBitVar> _x;
   id<ORIntVar> _p;
}
-(ORBitCount*)initORBitCount: (id<ORBitVar>) x count:(id<ORIntVar>)p
{
   self = [super initORConstraintI];
   _x = x;
   _p = p;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _p;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_p, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_p, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (| %@ |  = %@ )",[self class],self,_x,_p];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitCount:self];
}
@end

@implementation ORBitChannel {
   id<ORBitVar>  _x;
   id<ORIntVar> _xc;
}
-(ORBitChannel*)init: (id<ORBitVar>) x channel:(id<ORIntVar>)xc
{
   self = [super initORConstraintI];
   _x = x;
   _xc = xc;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _xc;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_xc, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_xc, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (Natural( %@ ) = %@ )",[self class],self,_x,_xc];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitChannel:self];
}
@end

@implementation ORBitZeroExtend {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitZeroExtend*)initORBitZeroExtend:(id<ORBitVar>)x extendTo:(id<ORBitVar>)y
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
   [buf appendFormat:@"<%@ : %p> -> (0...0%@ = %@)",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitZeroExtend:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitSignExtend {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitSignExtend*)initORBitSignExtend:(id<ORBitVar>)x extendTo:(id<ORBitVar>)y
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
   [buf appendFormat:@"<%@ : %p> -> (+/-...+/-%@ = %@)",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSignExtend:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitExtract {
   id<ORBitVar> _x;
   ORUInt _lsb;
   ORUInt _msb;
   id<ORBitVar> _y;
}
-(ORBitExtract*)initORBitExtract: (id<ORBitVar>) x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<ORBitVar>) y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _lsb = lsb;
   _msb = msb;
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
-(ORUInt) lsb
{
   return _lsb;
}
-(ORUInt) msb
{
   return _msb;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ from %i to %i = %@)",[self class],self,_x,_lsb,_msb,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitExtract:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitConcat {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitConcat*)initORBitConcat: (id<ORBitVar>) x concat:(id<ORBitVar>) y eq:(id<ORBitVar>) z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
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
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@::%@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitConcat:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
@end

@implementation ORBitLogicalEqual {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitLogicalEqual*)initORBitLogicalEqual: (id<ORBitVar>) x EQ:(id<ORBitVar>) y eval:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLogicalEqual:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitLT {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitLT*)initORBitLT: (id<ORBitVar>) x LT:(id<ORBitVar>) y eval:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ < %@ evaluates to %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLT:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitLE {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitLE*)initORBitLE: (id<ORBitVar>) x LE:(id<ORBitVar>) y eval:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <= %@ evaluates to %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLE:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitSLE {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitSLE*)initORBitSLE: (id<ORBitVar>) x SLE:(id<ORBitVar>) y eval:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <=(signed) %@ evaluates to %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSLE:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitSLT {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitSLT*)initORBitSLT: (id<ORBitVar>) x SLT:(id<ORBitVar>) y eval:(id<ORBitVar>)z
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
   [buf appendFormat:@"<%@ : %p> -> (%@ <(signed) %@ evaluates to %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSLT:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end


@implementation ORBitITE {
   id<ORBitVar> _i;
   id<ORBitVar> _t;
   id<ORBitVar> _e;
   id<ORBitVar> _r;
}
-(ORBitITE*)initORBitITE: (id<ORBitVar>)i then:(id<ORBitVar>)t else:(id<ORBitVar>)e result:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _i = i;
   _t = t;
   _e = e;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVar>) left
{
   return _i;
}
-(id<ORBitVar>) right1
{
   return _t;
}
-(id<ORBitVar>) right2
{
   return _e;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (if %@ then %@ else %@) evaluates to %@",[self class],self,_i,_t,_e,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitITE:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_i,_t,_e,_r, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_i,_t,_e,_r, nil] autorelease];
}
@end

@implementation ORBitLogicalAnd {
   id<ORBitVarArray> _x;
   id<ORBitVar> _r;
}
-(ORBitLogicalAnd*)initORBitLogicalAnd:(id<ORBitVarArray>)x eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVarArray>) left
{
   return _x;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (&& %@[0..n]) evaluates to %@",[self class],self,_x[0],_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLogicalAnd:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_r, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_r, nil] autorelease];
}
@end

@implementation ORBitLogicalOr {
   id<ORBitVarArray> _x;
   id<ORBitVar> _r;
}
-(ORBitLogicalOr*)initORBitLogicalOr:(id<ORBitVarArray>)x eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVarArray>) left
{
   return _x;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (|| %@[0..n]) evaluates to %@",[self class],self,_x[0],_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLogicalOr:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_r, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_r, nil] autorelease];
}
@end

@implementation ORBitOrb {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _r;
}
-(ORBitOrb*)initORBitOrb: (id<ORBitVar>) x bor:(id<ORBitVar>) y eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ | %@ = %@)",[self class],self,_x,_y,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitOrb:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
@end

@implementation ORBitNotb {
   id<ORBitVar> _x;
   id<ORBitVar> _r;
}
-(ORBitNotb*)initORBitNotb: (id<ORBitVar>) x  eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (~ %@  = %@)",[self class],self,_x,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitNotb:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_r, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_r, nil] autorelease];
}
@end

@implementation ORBitEqualb {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _r;
}
-(ORBitEqualb*)initORBitEqualb: (id<ORBitVar>) x equal:(id<ORBitVar>) y eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ => %@)",[self class],self,_x,_y,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitEqualb:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
@end


@implementation ORBitDistinct {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _r;
}
-(ORBitDistinct*)initORBitDistinct: (id<ORBitVar>) x distinctFrom:(id<ORBitVar>) y eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
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
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ => %@)",[self class],self,_x,_y,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitDistinct:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
@end


