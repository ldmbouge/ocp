/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFoundation/ORExpr.h"
#import "ORExprI.h"
#import "ORFactory.h"
#import "ORError.h"
#import "ORModel.h"


@implementation NSNumber (Expressions)
-(id<ORExpr>)asExpression:(id<ORTracker>)tracker
{
   const char* tt = [self objCType];
   if (strcmp(tt,@encode(ORInt))==0 || strcmp(tt,@encode(ORUInt)) ==0 || strcmp(tt,@encode(ORLong)) ==0 || strcmp(tt,@encode(ORULong)) ==0)
      return [ORFactory integer:tracker value:[self intValue]];
   else if (strcmp(tt,@encode(ORFloat))==0 || strcmp(tt,@encode(double))==0)
      return [ORFactory integer:tracker value:[self intValue]];  // should really be double
   else if (strcmp(tt,@encode(BOOL))==0 || strcmp(tt,@encode(bool))==0)
      return [ORFactory integer:tracker value:[self boolValue]];
   else {
      assert(NO);
   }
   return NULL;
}
-(id<ORExpr>)mul:(id<ORExpr>)r
{
   return [[self asExpression:[r tracker]] mul:r];
}
-(id<ORExpr>)plus:(id<ORExpr>)r
{
   return [[self asExpression:[r tracker]] plus:r];
}
-(id<ORExpr>)sub:(id<ORExpr>)r
{
   return [[self asExpression:[r tracker]] sub:r];
}
-(id<ORExpr>)div:(id<ORExpr>)r
{
   return [[self asExpression:[r tracker]] div:r];
}
-(id<ORExpr>) mod: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] mod:e];
}
-(id<ORRelation>) eq: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] eq:e];
}
-(id<ORRelation>) neq: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] neq:e];
}
-(id<ORRelation>) leq: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] leq:e];
}
-(id<ORRelation>) geq: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] geq:e];
}
-(id<ORRelation>) lt: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] lt:e];
}
-(id<ORRelation>) gt: (id<ORExpr>) e
{
   return [[self asExpression:[e tracker]] gt:e];
}
@end

@implementation ORExprI
-(id<ORTracker>) tracker
{
   return nil;
}
-(ORInt) min
{
   return 0;
}
-(ORInt) max
{
   return 0;
}
-(BOOL) isConstant
{
   return NO;
}
-(BOOL) isVariable
{
   return NO;
}
-(enum ORRelationType) type
{
   return ORRBad;
}
-(id<ORExpr>) abs
{
   return [ORFactory exprAbs:self];
}
-(id<ORExpr>) plus: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self plus:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self plus:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORExpr>) sub: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self sub:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self sub:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORExpr>) mul: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self mul:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self mul:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORExpr>) div: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self div:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self div:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORExpr>) mod: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self mod:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self mod:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORRelation>) eq: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self equal:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self equal:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORRelation>) neq: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self neq:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self neq:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORRelation>) leq: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self leq:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self leq:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORRelation>) geq: (id) e
{
   if ([e conformsToProtocol:@protocol(ORExpr)])
      return [ORFactory expr:self geq:e];
   else if ([e isKindOfClass:[NSNumber class]])
      return [ORFactory expr:self geq:[e asExpression:[self tracker]]];
   else
      return NULL;
}
-(id<ORRelation>) lt: (id) e
{
   id re = NULL;
   if ([e conformsToProtocol:@protocol(ORExpr)])
      re = e;
   else if ([e isKindOfClass:[NSNumber class]])
      re = [e asExpression:[self tracker]];
   return [ORFactory expr:self leq:[re sub:[ORFactory integer:[self tracker] value:1]]];
}
-(id<ORRelation>) gt: (id) e
{
   id re = NULL;
   if ([e conformsToProtocol:@protocol(ORExpr)])
      re = e;
   else if ([e isKindOfClass:[NSNumber class]])
      re = [e asExpression:[self tracker]];
   return [ORFactory expr:self geq:[re plus:[ORFactory integer:[self tracker] value:1]]];
}
-(id<ORExpr>)neg
{
   return [ORFactory exprNegate:self];
}
-(id<ORExpr>)and:(id<ORRelation>)e
{
   return [ORFactory expr:(id<ORRelation>)self and:e];
}
-(id<ORExpr>) or: (id<ORRelation>)e
{
   return [ORFactory expr:(id<ORRelation>)self or:e];
}
-(id<ORExpr>) imply:(id<ORRelation>)e
{
   return [ORFactory expr:(id<ORRelation>)self imply:e];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super init];
   return self;
}
- (void)visit:(id<ORVisitor>)visitor
{
   @throw [[ORExecutionError alloc] initORExecutionError: "Visitor not found"];
}
@end

// --------------------------------------------------------------------------------


@implementation ORExprBinaryI

-(id<ORExpr>) initORExprBinaryI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super init];
   _left = left;
   _right = right;
   _tracker = [left tracker];
   if (!_tracker)
      _tracker = [right tracker];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) left
{
   return _left;
}
-(id<ORExpr>) right
{
   return _right;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(BOOL) isConstant
{
   return [_left isConstant] && [_right isConstant];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_left];
   [aCoder encodeObject:_right];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _left  = [aDecoder decodeObject];
   _right = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprAbsI
-(id<ORExpr>) initORExprAbsI: (id<ORExpr>) op
{
   self = [super init];
   _op = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_op tracker];
}
-(ORInt) min
{
   return 0;
}
-(ORInt) max
{
   ORInt opMax = [_op max];
   ORInt opMin = [_op min];
   if (opMin >=0)
      return opMax;
   else if (opMax < 0)
      return -opMax;
   else 
      return max(-opMin,opMax);
}
-(ORExprI*) operand
{
   return _op;
}
-(BOOL) isConstant
{
   return [_op isConstant];
}

-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"abs(%@)",[_op description]];
   return rv;   
}
-(void) visit:(id<ORVisitor>)visitor
{
   [visitor visitExprAbsI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_op];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _op = [aDecoder decodeObject];
   return self;
}
@end


@implementation ORExprNegateI
-(id<ORExpr>) initORNegateI: (id<ORExpr>) op
{
   self = [super init];
   _op = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_op tracker];
}
-(ORInt) min
{
   return 0;
}
-(ORInt) max
{
   return 1;
}
-(ORExprI*) operand
{
   return _op;
}
-(BOOL) isConstant
{
   return [_op isConstant];
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"neg(%@)",[_op description]];
   return rv;
}
-(void) visit:(id<ORVisitor>)visitor
{
   [visitor visitExprNegateI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_op];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _op = [aDecoder decodeObject];
   return self;
}
@end


@implementation ORExprCstSubI
-(id<ORExpr>) initORExprCstSubI: (id<ORIntArray>) array index:(id<ORExpr>) op
{
   self = [super init];
   _array = array;
   _index = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_index tracker];
}
-(ORInt) min
{
   ORInt minOf = MAXINT;
   for(ORInt k=[_array low];k<=[_array up];k++)
      minOf = minOf <[_array at:k] ? minOf : [_array at:k];
   return minOf;
}
-(ORInt) max
{
   ORInt maxOf = MININT;
   for(ORInt k=[_array low];k<=[_array up];k++)
      maxOf = maxOf > [_array at:k] ? maxOf : [_array at:k];
   return maxOf;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@[%@]",_array,_index];
   return rv;   
}
-(ORExprI*) index
{
   return  _index;
}
-(id<ORIntArray>)array
{
   return _array;
}
-(BOOL) isConstant
{
   return [_index isConstant];
}
-(void) visit:(id<ORVisitor>)visitor
{
   [visitor visitExprCstSubI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_array];
   [aCoder encodeObject:_index];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _array = [aDecoder decodeObject];
   _index = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprPlusI 
-(id<ORExpr>) initORExprPlusI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min 
{
   return [_left min] + [_right min]; 
}
-(ORInt) max
{
   return [_left max] + [_right max]; 
}

-(void) visit:(id<ORVisitor>) visitor
{
   [visitor visitExprPlusI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ + %@",[_left description],[_right description]];
   return rv;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprMinusI 
-(id<ORExpr>) initORExprMinusI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min 
{
   return [_left min] - [_right max]; 
}
-(ORInt) max
{
   return [_left max] - [_right min]; 
}

-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprMinusI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ - %@)",[_left description],[_right description]];
   return rv;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprMulI
-(id<ORExpr>) initORExprMulI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min 
{
   ORInt m1 = min([_left min] * [_right min],[_left min] * [_right max]);
   ORInt m2 = min([_left max] * [_right min],[_left max] * [_right max]);
   return min(m1,m2);
}
-(ORInt) max
{
   ORInt m1 = max([_left min] * [_right min],[_left min] * [_right max]);
   ORInt m2 = max([_left max] * [_right min],[_left max] * [_right max]);
   return max(m1,m2);
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprMulI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ * %@)",[_left description],[_right description]];
   return rv;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprDivI
-(id<ORExpr>) initORExprDivI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   ORInt m1 = min([_left min] / [_right min],[_left min] / [_right max]);
   ORInt m2 = min([_left max] / [_right min],[_left max] / [_right max]);
   return min(m1,m2);
}
-(ORInt) max
{
   ORInt m1 = max([_left min] / [_right min],[_left min] / [_right max]);
   ORInt m2 = max([_left max] / [_right min],[_left max] / [_right max]);
   return max(m1,m2);
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprDivI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ / %@)",[_left description],[_right description]];
   return rv;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprModI
-(id<ORExpr>) initORExprModI: (id<ORExpr>) left mod: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(ORInt) min
{
   ORInt ub = max(abs([_right min]),abs([_right max])) - 1;
   if ([_left min] > 0)
      return 0;
   else
      return - ub;
}
-(ORInt) max
{
   ORInt ub = max(abs([_right min]),abs([_right max])) - 1;
   if ([_left max] < 0)
      return 0;
   else
      return ub;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ mod %@)",[_left description],[_right description]];
   return rv;
}
-(void) visit: (id<ORVisitor>)visitor
{
   [visitor visitExprModI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprEqualI 
-(id<ORExpr>) initORExprEqualI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min 
{
   assert([self isConstant]);
   return [_left min] == [_right min];
}
-(ORInt) max 
{
   assert([self isConstant]);
   return [_left max] == [_right max];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprEqualI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ == %@",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORREq;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end


@implementation ORExprNotEqualI
-(id<ORExpr>) initORExprNotEqualI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   assert([self isConstant]);
   return [_left min] != [_right min];
}
-(ORInt) max
{
   assert([self isConstant]);
   return [_left max] != [_right max];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprNEqualI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ != %@",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRNEq;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORExprLEqualI
-(id<ORExpr>) initORExprLEqualI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   assert([self isConstant]);
   return [_left min] <= [_right min];
}
-(ORInt) max
{
   assert([self isConstant]);
   return [_left max] <= [_right max];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprLEqualI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ <= %@",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRLEq;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORDisjunctI
-(id<ORExpr>) initORDisjunctI: (id<ORExpr>) left or: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   return [_left min] || [_right min];
}
-(ORInt) max
{
   return [_left max] || [_right max];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprDisjunctI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ || %@)",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRDisj;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORConjunctI
-(id<ORExpr>) initORConjunctI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   return [_left min] && [_right min];
}
-(ORInt) max
{
   return [_left max] && [_right max];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprConjunctI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ && %@)",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRConj;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end

@implementation ORImplyI
-(id<ORExpr>) initORImplyI: (id<ORExpr>) left imply: (id<ORExpr>) right
{
   self = [super initORExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORInt) min
{
   return ![_left min] || [_right min];
}
-(ORInt) max
{
   return ![_left max] || [_right max];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprImplyI: self];
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ => %@)",[_left description],[_right description]];
   return rv;
}
-(enum ORRelationType)type
{
   return ORRImply;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   return self;
}
@end


@implementation ORExprSumI
-(id<ORExpr>) initORExprSumI: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   self = [super init];
   id<IntEnumerator> ite = [S enumerator];
   _e = [ORFactory integer: tracker value: 0];
   if (f!= NULL) {
      while ([ite more]) {
         ORInt i = [ite next];
         if (f(i))
            _e = [_e plus: e(i)];
      }
   }
   else {
      while ([ite more]) {
         ORInt i = [ite next];
         _e = [_e plus: e(i)];
      }
   }
   [ite release]; // [ldm] fixed memory leak.
   return self;
}
-(id<ORExpr>) initORExprSumI: (id<ORTracker>) tracker over: (id<ORIntIterable>) S1 over: (id<ORIntIterable>) S2 suchThat: (ORIntxInt2Bool) f of: (ORIntxInt2Expr) e {
    self = [super init];
    id<IntEnumerator> ite1 = [S1 enumerator];
    id<IntEnumerator> ite2 = [S2 enumerator];
    _e = [ORFactory integer: tracker value: 0];
    if (f!= NULL) {
        while ([ite1 more]) {
            ORInt i = [ite1 next];
            while ([ite2 more]) {
                ORInt j = [ite2 next];
                if (f(i, j)) _e = [_e plus: e(i, j)];
            }
        }
    }
    else {
        while ([ite1 more]) {
            ORInt i = [ite1 next];
            while ([ite2 more]) {
                ORInt j = [ite2 next];
                _e = [_e plus: e(i, j)];
            }
        }
    }
    [ite1 release]; // [ldm] fixed memory leak.
    [ite2 release];
    return self;
}
-(id<ORExpr>) initORExprSumI: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}

-(void) dealloc
{   
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(BOOL) isConstant
{
   return [_e isConstant];
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprSumI: self]; 
}
-(NSString *) description
{
   return [_e description];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprProdI
-(id<ORExpr>) initORExprProdI: (id<ORTracker>) tracker over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   self = [super init];
   id<IntEnumerator> ite = [S enumerator];
   _e = [ORFactory integer: tracker value: 1];
   if (f!=NULL) {
      while ([ite more]) {
         ORInt i = [ite next];
         if (f(i))
            _e = [_e mul: e(i)];
      }
   }
   else {
      while ([ite more]) {
         ORInt i = [ite next];
         _e = [_e mul: e(i)];
      }
   }
   [ite release]; // [ldm] fixed memory leak.
   return self;
}
-(id<ORExpr>) initORExprProdI: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(BOOL) isConstant
{
   return [_e isConstant];
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprProdI: self];
}
-(NSString *) description
{
   return [_e description];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprAggOrI
-(id<ORRelation>) initORExprAggOrI: (id<ORTracker>) cp over: (id<ORIntIterable>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   self = [super init];
   id<IntEnumerator> ite = [S enumerator];
   _e = [ORFactory integer: cp value: 0];
   if (f!=NULL) {
      while ([ite more]) {
         ORInt i = [ite next];
         if (!f(i))
            _e = [_e or: e(i)];
      }
   }
   else {
      while ([ite more]) {
         ORInt i = [ite next];
         _e = [_e or: e(i)];
      }
   }
   [ite release]; // [ldm] fixed memory leak.
   return self;
}
-(id<ORRelation>) initORExprAggOrI: (id<ORExpr>) e
{
   self = [super init];
   _e = e;
   return self;
}

-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) expr
{
   return _e;
}
-(ORInt) min
{
   return [_e min];
}
-(ORInt) max
{
   return [_e max];
}
-(BOOL) isConstant
{
   return [_e isConstant];
}
-(id<ORTracker>) tracker
{
   return [_e tracker];
}
-(void) visit: (id<ORVisitor>) visitor
{
   [visitor visitExprAggOrI: self];
}
-(NSString *) description
{
   return [_e description];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_e];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _e = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORExprVarSubI
-(id<ORExpr>) initORExprVarSubI: (id<ORIntVarArray>) array elt:(id<ORExpr>) op
{
   self = [super init];
   _array = array;
   _index = op;
   return self;
}
-(id<ORTracker>) tracker
{
   return [_index tracker];
}
-(ORInt) min
{
   ORInt minOf = MAXINT;
   for(ORInt k=[_array low];k<=[_array up];k++)
      minOf = minOf < [_array[k] min] ? minOf : [_array[k] min];
   return minOf;
}
-(ORInt) max
{
   ORInt maxOf = MININT;
   for(ORInt k=[_array low];k<=[_array up];k++)
      maxOf = maxOf > [_array[k] max] ? maxOf : [_array[k] max];
   return maxOf;
}
-(NSString *)description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@[%@]",_array,_index];
   return rv;
}
-(ORExprI*) index
{
   return  _index;
}
-(id<ORIntVarArray>)array
{
   return _array;
}
-(BOOL) isConstant
{
   return [_index isConstant];
}
-(void) visit:(id<ORVisitor>)visitor
{
   [visitor visitExprVarSubI:self];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_array];
   [aCoder encodeObject:_index];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _array = [aDecoder decodeObject];
   _index = [aDecoder decodeObject];
   return self;
}
@end


id<ORExpr> __attribute__((overloadable)) mult(NSNumber* l,id<ORExpr> r)
{
   return [r mul: l];
}
id<ORExpr> __attribute__((overloadable)) mult(id<ORExpr> l,id<ORExpr> r)
{
   return [l mul: r];
}



