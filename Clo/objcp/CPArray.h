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


@protocol CPIntVarArray <NSObject> 
-(id<CPIntVar>) at: (CPInt) value;
-(void) set: (id<CPIntVar>) x at: (CPInt) value;
-(CPInt) low;
-(CPInt) up;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPIntVarMatrix <NSObject> 
-(id<CPIntVar>) at: (CPInt) i1 : (CPInt) i2;
-(id<CPIntVar>) at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPIntArray <NSObject> 
-(CPInt) at: (CPInt) value;
-(CPInt) low;
-(CPInt) up;
-(NSUInteger) count;
-(NSString*) description;
-(id<CP>) cp;
-(id<CPExpr>) index: (id<CPExpr>) idx;
@end

@protocol CPTRIntArray <NSObject> 
-(CPInt)  at: (CPInt) value;
-(void)  set: (CPInt) value at: (CPInt) value;  
-(CPInt) low;
-(CPInt) up;
-(NSUInteger) count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPIntMatrix <NSObject> 
-(CPInt) at: (CPInt) i1 : (CPInt) i2;
-(CPInt) at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(void) set: (CPInt) value at: (CPInt) i1 : (CPInt) i2;
-(void) set: (CPInt) value at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end

@protocol CPTRIntMatrix <NSObject> 
-(CPInt) at: (CPInt) i1 : (CPInt) i2;
-(CPInt) at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(void) set: (CPInt) value at: (CPInt) i1 : (CPInt) i2;
-(void) set: (CPInt) value at: (CPInt) i1 : (CPInt) i2 : (CPInt) i3;
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<CP>) cp;
@end


