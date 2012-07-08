/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPExprI.h"


@implementation CPExprVarSubI
-(id<CPExpr>) initCPExprVarSubI: (id<CPIntVarArray>) array elt:(id<CPExpr>) op
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
-(CPInt) min
{
   CPInt minOf = MAXINT;
   for(CPInt k=[_array low];k<=[_array up];k++)
      minOf = minOf < [_array[k] min] ? minOf : [_array[k] min];
   return minOf;
}
-(CPInt) max
{
   CPInt maxOf = MININT;
   for(CPInt k=[_array low];k<=[_array up];k++)
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
-(id<CPIntVarArray>)array
{
   return _array;
}
-(BOOL) isConstant
{
   return [_index isConstant];
}
-(void) visit:(id<CPExprVisitor>)visitor
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


@implementation CPExprPrintI 
-(CPExprPrintI*) initCPExprPrintI 
{
    self = [super init];
    return self;
}
-(void) dealloc
{
    [super dealloc];
}
-(void) visitIntVarI: (CPIntVarI*) e
{
    printf("var");
}
-(void) visitIntegerI: (ORIntegerI*) e
{
    printf("int");
}
-(void) visitExprPlusI: (ORExprPlusI*) e
{
    [[e left] visit: self];
    printf(" + ");
    [[e right] visit: self];      
}
-(void) visitExprMinusI: (ORExprMinusI*) e
{
   [[e left] visit: self];
   printf(" - ");
   [[e right] visit: self];         
}
-(void) visitExprMulI: (ORExprMulI*) e
{
   [[e left] visit: self];
   printf(" * ");
   [[e right] visit: self];         
}
-(void) visitExprEqualI: (ORExprEqualI*) e
{
   [[e left] visit: self];
   printf(" == ");
   [[e right] visit: self];         
}
-(void) visitExprNEqualI: (ORExprNotEqualI*) e
{
   [[e left] visit: self];
   printf(" != ");
   [[e right] visit: self];
}
-(void) visitExprLEqualI: (ORExprLEqualI*) e
{
   [[e left] visit: self];
   printf(" <= ");
   [[e right] visit: self];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   printf("abs(");
   [[e operand] visit:self];
   printf(")");
}
-(void) visitExprSumI: (ORExprSumI*) e
{
    [[e expr] visit: self];
}
-(void) visitExprCstSubI:(ORExprCstSubI*)e
{
   printf("SUBSCRIPT-CST[");
   [[e index] visit:self];
   printf("]");
}
@end

@implementation ORIntegerI (visitor)
-(void) visit: (id<ORExprVisitor>) visitor
{
    [visitor visitIntegerI: self];
}
@end

@implementation CPIntVarI (visitor)
-(void) visit: (id<CPExprVisitor>) visitor 
{
    [visitor visitIntVarI: self];

}
@end

