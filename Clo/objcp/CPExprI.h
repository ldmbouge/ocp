/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPTypes.h>
#import "CPIntVarI.h"
@protocol CPExprVisitor;

@interface CPExprBinaryI : CPExprI<CPExpr,NSCoding> {
   CPExprI* _left;
   CPExprI* _right;
}
-(id<CPExpr>) initCPExprBinaryI: (id<CPExpr>) left and: (id<CPExpr>) right;
-(id<CP>) cp;
-(CPExprI*) left;
-(CPExprI*) right;
-(BOOL) isConstant;
@end

@interface CPExprAbsI : CPExprI<CPExpr,NSCoding> {
   CPExprI* _op;
}
-(id<CPExpr>) initCPExprAbsI: (id<CPExpr>) op;
-(id<CP>) cp;
-(CPInt) min;
-(CPInt) max;
-(NSString *)description;
-(CPExprI*) operand;
-(BOOL) isConstant;
-(void) visit:(id<CPExprVisitor>)v;
@end

@interface CPExprCstSubI : CPExprI<CPExpr,NSCoding> {
   id<CPIntArray> _array;
   CPExprI*       _index;
}
-(id<CPExpr>) initCPExprCstSubI: (id<CPIntArray>) array index:(id<CPExpr>) op;
-(id<CP>) cp;
-(CPInt) min;
-(CPInt) max;
-(NSString *)description;
-(CPExprI*) index;
-(id<CPIntArray>)array;
-(BOOL) isConstant;
-(void) visit:(id<CPExprVisitor>)v;
@end


@interface CPExprPlusI : CPExprBinaryI<CPExpr,NSCoding> 
-(id<CPExpr>) initCPExprPlusI: (id<CPExpr>) left and: (id<CPExpr>) right;
-(CPInt) min;
-(CPInt) max;
-(NSString *)description;
-(void) visit:(id<CPExprVisitor>)v;
@end

@interface CPExprMulI : CPExprBinaryI<CPExpr,NSCoding> 
-(id<CPExpr>) initCPExprMulI: (id<CPExpr>) left and: (id<CPExpr>) right;
-(CPInt) min;
-(CPInt) max;
-(NSString *)description;
-(void) visit: (id<CPExprVisitor>)v;
@end

@interface CPExprMinusI : CPExprBinaryI<CPExpr,NSCoding> 
-(id<CPExpr>) initCPExprMinusI: (id<CPExpr>) left and: (id<CPExpr>) right;
-(CPInt) min;
-(CPInt) max;
-(NSString *)description;
-(void) visit: (id<CPExprVisitor>)v;
@end


@interface CPExprEqualI : CPExprBinaryI<CPRelation,NSCoding> 
-(id<CPExpr>) initCPExprEqualI: (id<CPExpr>) left and: (id<CPExpr>) right;
-(CPInt) min;
-(CPInt) max;
-(NSString *)description;
-(void) visit: (id<CPExprVisitor>)v;
@end


@interface CPExprSumI : CPExprI<CPExpr,NSCoding> {
    id<CPExpr> _e;
}
-(id<CPExpr>) initCPExprSumI: (id<CP>) cp range: (CPRange) r filteredBy: (CPInt2Bool) f of: (CPInt2Expr) e;
-(void) dealloc;
-(CPInt) min;
-(CPInt) max;
-(id<CP>) cp;
-(CPExprI*) expr;
-(BOOL) isConstant;
-(NSString *) description;
-(void) visit: CPExprVisitorI;
@end


@protocol CPExprVisitor
-(void) visitIntVarI: (CPIntVarI*) e;
-(void) visitIntegerI: (CPIntegerI*) e;
-(void) visitExprPlusI: (CPExprPlusI*) e;
-(void) visitExprMinusI: (CPExprMinusI*) e;
-(void) visitExprMulI: (CPExprMulI*) e;
-(void) visitExprEqualI:(CPExprEqualI*)e;
-(void) visitExprSumI: (CPExprSumI*) e;
-(void) visitExprAbsI:(CPExprAbsI*) e;
-(void) visitExprCstSubI:(CPExprCstSubI*)e;
@end


@interface CPExprPrintI : NSObject<CPExprVisitor>
-(CPExprPrintI*) initCPExprPrintI;
-(void) dealloc;
-(void) visitIntVarI: (CPIntVarI*) e;
-(void) visitIntegerI: (CPIntegerI*) e;
-(void) visitExprPlusI: (CPExprPlusI*) e;
-(void) visitExprMinusI: (CPExprMinusI*) e;
-(void) visitExprMulI: (CPExprMulI*) e;
-(void) visitExprEqualI:(CPExprEqualI*)e;
-(void) visitExprSumI: (CPExprSumI*) e;
-(void) visitExprAbsI:(CPExprAbsI*) e;
-(void) visitExprCstSubI:(CPExprCstSubI*)e;
@end;

@interface CPExprI (visitor)
-(void) visit:(id<CPExprVisitor>)v;
@end;

@interface CPIntegerI (visitor)
-(void) visit:(id<CPExprVisitor>)v;
@end;

@interface CPIntVarI (visitor)
-(void) visit:(id<CPExprVisitor>)v;
@end;

