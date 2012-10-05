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
-(id<ORExpr>) plus: (id<ORExpr>) e
{
   return [ORFactory expr: self plus: e];
}
-(id<ORExpr>) plusi: (ORInt) e
{
   return [ORFactory expr: self plus:[ORFactory integer:[self tracker] value:e]];
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
-(id<ORRelation>) eq: (id<ORExpr>) e
{
   return [ORFactory expr:self equal:e];
}
-(id<ORRelation>) eqi: (ORInt) e
{
   return [ORFactory expr:self equal:[ORFactory integer:[self tracker] value:e]];
}
-(id<ORRelation>) neq: (id<ORExpr>) e
{
   return [ORFactory expr:self neq:e];
}
-(id<ORRelation>) neqi: (ORInt) c
{
   return [ORFactory expr:self neq: [ORFactory integer:[self tracker] value: c]];
}
-(id<ORRelation>) leq: (id<ORExpr>) e
{
   return [ORFactory expr:self leq:e];
}
-(id<ORRelation>) leqi: (ORInt) c
{
   return [ORFactory expr:self leq: [ORFactory integer:[self tracker] value: c]];
}
-(id<ORRelation>) geq: (id<ORExpr>) e
{
   return [ORFactory expr:self geq:e];
}
-(id<ORRelation>) geqi: (ORInt) c
{
   return [ORFactory expr:self geq: [ORFactory integer:[self tracker] value: c]];
}
-(id<ORRelation>) lt: (id<ORExpr>) e
{
   return [ORFactory expr:self leq:[e sub:[ORFactory integer:[self tracker] value:1]]];
}
-(id<ORRelation>) gt: (id<ORExpr>) e
{
   return [ORFactory expr:self geq:[e plus:[ORFactory integer:[self tracker] value:1]]];
}
-(id<ORRelation>) lti: (ORInt) e
{
   return [ORFactory expr:self leq:[ORFactory integer:[self tracker] value:e-1]];
}
-(id<ORRelation>) gti: (ORInt) e
{
   return [ORFactory expr:self geq:[ORFactory integer:[self tracker] value:e+1]];
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
-(id<ORExpr>) initORExprSumI: (id<ORTracker>) tracker over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e
{
   self = [super init];
   id<IntEnumerator> ite = [S enumerator];
   _e = [ORFactory integer: tracker value: 0];
   if (f!=nil) {
      while ([ite more]) {
         ORInt i = [ite next];
         if (!f(i))
            _e = [_e plus: e(i)];
      }
   }
   else {
      while ([ite more]) {
         ORInt i = [ite next];
         _e = [_e plus: e(i)];
      }
   }
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

@implementation ORExprAggOrI
-(id<ORRelation>) initORExprAggOrI: (id<ORTracker>) cp over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Relation) e
{
   self = [super init];
   id<IntEnumerator> ite = [S enumerator];
   _e = [ORFactory integer: cp value: 0];
   if (f!=nil) {
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


id<ORExpr> __attribute__((overloadable)) mult(ORInt l,id<ORExpr> r)
{
   return [r muli: l];
}
id<ORExpr> __attribute__((overloadable)) mult(id<ORExpr> l,id<ORExpr> r)
{
   return [l mul: r];
}



