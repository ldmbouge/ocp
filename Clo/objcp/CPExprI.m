/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "CPExprI.h"


@implementation CPExprI
-(id<CP>) cp 
{
    return nil;
}
-(CPInt) min
{
    return 0;
}
-(CPInt) max
{
   return 0;
}
-(id) var 
{
   return nil;
}
-(BOOL) isConstant
{
   return NO;
}
-(BOOL) isVariable
{
   return NO;
}
-(id<CPExpr>) add: (id<CPExpr>) e
{
    return [CPFactory expr: self add: e];
}
@end

@implementation CPExprBinaryI
-(id<CPExpr>) initCPExprBinaryI: (id<CPExpr>) left and: (id<CPExpr>) right
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
-(id<CPExpr>) left
{
   return _left;
}
-(id<CPExpr>) right
{
   return _right;
}
-(id<CP>) cp
{
   id<CP> cps = [_left cp];
   if (!cps) 
      cps = [_right cp];
   return cps;
}
-(BOOL) isConstant
{
   return [_left isConstant] && [_right isConstant];
}
@end

@implementation CPExprPlusI 
-(id<CPExpr>) initCPExprPlusI: (id<CPExpr>) left and: (id<CPExpr>) right
{
   self = [super initCPExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(CPInt) min 
{
    return [_left min] + [_right min]; 
}
-(CPInt) max
{
   return [_left max] + [_right max]; 
}

-(void) visit:(id<CPExprVisitor>) visitor
{
    [visitor visitExprPlusI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ + %@",[_left description],[_right description]];
   return rv;
}
@end

@implementation CPExprMinusI 
-(id<CPExpr>) initCPExprMinusI: (id<CPExpr>) left and: (id<CPExpr>) right
{
   self = [super initCPExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(CPInt) min 
{
   return [_left min] - [_right max]; 
}
-(CPInt) max
{
   return [_left max] - [_right min]; 
}

-(void) visit: (id<CPExprVisitor>) visitor
{
   [visitor visitExprMinusI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ - %@)",[_left description],[_right description]];
   return rv;
}
@end


@implementation CPExprMulI 
-(id<CPExpr>) initCPExprMulI: (id<CPExpr>) left and: (id<CPExpr>) right
{
   self = [super initCPExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(CPInt) min 
{
   CPInt m1 = min([_left min] * [_right min],[_left min] * [_right max]);
   CPInt m2 = min([_left max] * [_right min],[_left max] * [_right max]);
   return min(m1,m2);
}
-(CPInt) max
{
   CPInt m1 = max([_left min] * [_right min],[_left min] * [_right max]);
   CPInt m2 = max([_left max] * [_right min],[_left max] * [_right max]);
   return max(m1,m2);
}
-(void) visit: (id<CPExprVisitor>) visitor
{
   [visitor visitExprMulI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"(%@ * %@)",[_left description],[_right description]];
   return rv;
}
@end

@implementation CPExprEqualI 
-(id<CPExpr>) initCPExprEqualI: (id<CPExpr>) left and: (id<CPExpr>) right
{
   self = [super initCPExprBinaryI:left and:right];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(CPInt) min 
{
   return 0; // ldm dom(==)={0,1} [_left min] - [_right min]; 
}
-(CPInt) max 
{
   return 1; // ldm dom(==)={0,1} [_left min] - [_right min]; 
}
-(void) visit: (id<CPExprVisitor>) visitor
{
   [visitor visitExprEqualI: self]; 
}
-(NSString*) description 
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"%@ == %@",[_left description],[_right description]];
   return rv;
}
@end

@implementation CPExprSumI 
-(id<CPExpr>) initCPExprSumI: (id<CP>) cp range: (CPRange) r filteredBy: (CPInt2Bool) f of: (CPInt2Expr) e
{
    self = [super init];
    CPInt low = r.low;
    CPInt up = r.up;
    _e = [CPFactory integer: cp value: 0];
    for(CPInt i = low; i <= up; i++)
        if (!f(i)) 
            _e = [_e add: e(i)];
    return self;       
}
-(void) dealloc
{   
    [super dealloc];
}
-(id<CPExpr>) expr
{
    return _e;
}
-(CPInt) min
{
    CPExprPrintI* visitor = [[CPExprPrintI alloc] init];
    [self visit: visitor];
    return [_e min];
}
-(CPInt) max
{
   return [_e max];
}
-(BOOL) isConstant
{
   return [_e isConstant];
}
-(id<CP>) cp
{
    return [_e cp];
}
-(void) visit: (id<CPExprVisitor>) visitor
{
    [visitor visitExprSumI: self]; 
}
-(NSString *) description
{
    return [_e description];
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
-(void) visitIntegerI: (CPIntegerI*) e
{
    printf("int");
}
-(void) visitExprPlusI: (CPExprPlusI*) e
{
    [[e left] visit: self];
    printf(" + ");
    [[e right] visit: self];      
}
-(void) visitExprMinusI: (CPExprMinusI*) e
{
   [[e left] visit: self];
   printf(" - ");
   [[e right] visit: self];         
}
-(void) visitExprMulI: (CPExprMulI*) e
{
   [[e left] visit: self];
   printf(" * ");
   [[e right] visit: self];         
}
-(void) visitExprEqualI: (CPExprEqualI*) e
{
   [[e left] visit: self];
   printf(" == ");
   [[e right] visit: self];         
}
-(void) visitExprSumI: (CPExprSumI*) e
{
    [[e expr] visit: self];
}
@end


@implementation CPExprI (visitor)
-(void) visit: (id<CPExprVisitor>) visitor
{
    assert(false);  
}
@end

@implementation CPIntegerI (visitor)
-(void) visit: (id<CPExprVisitor>) visitor
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

