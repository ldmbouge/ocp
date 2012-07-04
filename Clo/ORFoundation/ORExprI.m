/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORExprI.h"
#import "ORFactory.h"

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
-(id<ORExpr>) add: (id<ORExpr>) e
{
   return [ORFactory expr: self add: e];
}
-(id<ORExpr>) sub: (id<ORExpr>) e
{
   return [ORFactory expr:self sub:e];
}
-(id<ORExpr>) mul: (id<ORExpr>) e
{
   return [ORFactory expr:self mul:e];
}
-(id<ORExpr>) muli: (ORInt) e
{
   return [ORFactory expr:self mul:[ORFactory integer:[self tracker] value:e]];
}
-(id<ORRelation>) equal: (id<ORExpr>) e
{
   return [ORFactory expr:self equal:e];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super init];
   return self;
}
- (void)visit:(id<ORExprVisitor>)v
{
}
@end

// --------------------------------------------------------------------------------


@implementation ORExprBinaryI
-(id<ORExpr>) initORExprBinaryI: (id<ORExpr>) left and: (id<ORExpr>) right
{
   self = [super init];
   _left = left;
   _right = right;
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
   id<ORTracker> cps = [_left tracker];
   if (!cps) 
      cps = [_right tracker];
   return cps;
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
-(void) visit:(id<ORExprVisitor>)visitor
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
-(void) visit:(id<ORExprVisitor>)visitor
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

-(void) visit:(id<ORExprVisitor>) visitor
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

-(void) visit: (id<ORExprVisitor>) visitor
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
-(void) visit: (id<ORExprVisitor>) visitor
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
   return 0; // ldm dom(==)={0,1} [_left min] - [_right min]; 
}
-(ORInt) max 
{
   return 1; // ldm dom(==)={0,1} [_left min] - [_right min]; 
}
-(void) visit: (id<ORExprVisitor>) visitor
{
   [visitor visitExprEqualI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ == %@",[_left description],[_right description]];
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

@implementation ORExprSumI 
-(id<ORExpr>) initORExprSumI: (id<ORTracker>) cp range: (ORRange) r filteredBy: (ORInt2Bool) f of: (ORInt2Expr) e
{
   self = [super init];
   ORInt low = r.low;
   ORInt up = r.up;
   _e = [ORFactory integer: cp value: 0];
   if (f!=nil) {
      for(ORInt i = low; i <= up; i++)
         if (!f(i)) 
            _e = [_e add: e(i)];
   } 
   else {
      for(ORInt i = low; i <= up; i++)
         _e = [_e add: e(i)];      
   }
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
-(void) visit: (id<ORExprVisitor>) visitor
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

