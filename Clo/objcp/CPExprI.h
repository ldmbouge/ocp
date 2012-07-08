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
#import "ORFoundation/ORExprI.h"
#import "ORFoundation/ORDataI.h"
#import "CPData.h"
#import "CPIntVarI.h"

@protocol CPExprVisitor;

@interface CPExprVarSubI : ORExprI<CPExpr,NSCoding> {
   id<CPIntVarArray> _array;
   ORExprI*          _index;
}
-(id<CPExpr>) initCPExprVarSubI: (id<CPIntVarArray>) array index:(id<CPExpr>) op;
-(id<ORTracker>) tracker;
-(CPInt) min;
-(CPInt) max;
-(NSString *)description;
-(ORExprI*) index;
-(id<CPIntVarArray>)array;
-(BOOL) isConstant;
-(void) visit:(id<CPExprVisitor>)v;
@end


@protocol CPExprVisitor <ORExprVisitor>
-(void) visitIntVarI:(CPIntVarI*)var;
-(void) visitExprVarSubI:(CPExprVarSubI*)e;
@end

@interface CPExprPrintI : NSObject<ORExprVisitor>
-(CPExprPrintI*) initCPExprPrintI;
-(void) dealloc;
-(void) visitIntVarI: (id<CPIntVar>) e;
-(void) visitIntegerI: (id<CPInteger>) e;
-(void) visitExprPlusI: (ORExprPlusI*) e;
-(void) visitExprMinusI: (ORExprMinusI*) e;
-(void) visitExprMulI: (ORExprMulI*) e;
-(void) visitExprEqualI:(ORExprEqualI*)e;
-(void) visitExprSumI: (ORExprSumI*) e;
-(void) visitExprAbsI:(ORExprAbsI*) e;
-(void) visitExprCstSubI:(ORExprCstSubI*)e;
@end;


@interface ORIntegerI (visitor)
-(void) visit:(id<CPExprVisitor>)v;
@end;

@interface CPIntVarI (visitor)
-(void) visit:(id<CPExprVisitor>)v;
@end;

