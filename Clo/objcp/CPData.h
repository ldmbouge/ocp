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

#import <Foundation/Foundation.h>
#import <objcp/CPSolution.h>
#import <objcp/CPTypes.h>

@class CPExprI;
@protocol CP;
@protocol CPExprVisitor;

typedef struct CPRange {
    CPInt low;
    CPInt up;
} CPRange;

typedef struct CPBounds {
    CPInt min;
    CPInt max;
} CPBounds;

typedef enum  {
    CPFailure,
    CPSuccess,
    CPSuspend,
    CPDelay,
    CPSkip
} CPStatus;

typedef CPStatus (^ConstraintCallback)(void);
typedef CPStatus (^ConstraintIntCallBack)(CPInt);
typedef CPStatus (^CPVoid2CPStatus)(void);

@protocol IntEnumerator <NSObject>
-(bool) more;
-(CPInt) next;
@end


@protocol CPExpr <NSObject>
-(id<CP>) cp;
-(CPInt) min;
-(id<CPExpr>) add: (id<CPExpr>) e;
@end

@protocol CPInteger <CPExpr>
-(CPInt)  value;
-(void) setValue: (CPInt) value;
-(void) incr;
-(void) decr;
@end

@protocol CPIntVar <CPExpr,CPSavable>
-(CPUInt)getId;
-(bool) bound;
-(CPInt)  min;
-(CPInt)  max;
-(void) bounds: (CPBounds*) bnd;
-(CPInt) domsize;
-(CPInt)countFrom:(CPInt)from to:(CPInt)to;
-(bool) member: (CPInt) v;
-(NSSet*)constraints;
-(id)snapshot;
@end

@protocol CPConstraint <NSObject>
@end

@protocol CPVirtual 
-(CPInt) virtualOffset;   
@end

typedef void (^CPClosure)(void);
typedef bool (^CPInt2Bool)(CPInt);
typedef bool (^CPVoid2Bool)(void);
typedef CPInt (^CPInt2Int)(CPInt);
typedef void (^CPInt2Void)(CPInt);
typedef int (^CPIntxInt2Int)(CPInt,CPInt);
typedef id<CPExpr> (^CPInt2Expr)(CPInt);
typedef void (^CPVirtualClosure)(id<CP>);


