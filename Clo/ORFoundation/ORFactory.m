/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFactory.h"
#import "ORError.h"
#import "ORExprI.h"
#import "ORData.h"
#import "ORDataI.h"
#import "ORArrayI.h"

@implementation ORFactory
+(id<ORInteger>) integer: (id<ORTracker>)tracker value: (ORInt) value
{
   ORIntegerI* o = [[ORIntegerI alloc] initORIntegerI: tracker value:value];
   [tracker trackObject: o];
   return o;
}
+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (ORRange) range value: (ORInt) value
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range:range value: (ORInt) value];
   [tracker trackObject: o];
   return o;
}

+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (ORRange) range with:(ORInt(^)(ORInt)) clo
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range:range with:clo];
   [tracker trackObject: o];
   return o;
}

+(ORIntArrayI*) intArray: (id<ORTracker>) tracker range: (ORRange) r1 range: (ORRange) r2 with: (ORInt(^)(ORInt,ORInt)) clo
{
   ORIntArrayI* o = [[ORIntArrayI alloc] initORIntArray: tracker range: r1 range: r2 with:clo];    
   [tracker trackObject: o];
   return o;
}
+(id<ORIdArray>) idArray: (id<ORTracker>) tracker range: (ORRange) range
{
   ORIdArrayI* o = [[ORIdArrayI alloc] initORIdArray:tracker range:range];
   [tracker trackObject:o];
   return o;
}
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (ORRange) r0 : (ORRange) r1
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix:tracker range:r0 :r1];
   [tracker trackObject:o];
   return o;
}
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (ORRange) r0 : (ORRange) r1 : (ORRange) r2
{
   ORIdMatrixI* o = [[ORIdMatrixI alloc] initORIdMatrix:tracker range:r0 :r1 :r2];
   [tracker trackObject:o];
   return o;
}
@end

@implementation ORFactory (Expressions)
+(id<ORExpr>) validate:(id<ORExpr>)e onError:(const char*)str
{
   id<ORTracker> cp = [e tracker];
   if (cp == NULL)
      @throw [[ORExecutionError alloc] initORExecutionError: str]; 
   [cp trackObject: e];
   return e;   
}
+(id<ORExpr>) expr: (id<ORExpr>) left plus: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprPlusI alloc] initORExprPlusI: left and: right]; 
   return [self validate:o onError:"No CP Solver in Add Expression"];
}
+(id<ORExpr>) expr: (id<ORExpr>) left sub: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprMinusI alloc] initORExprMinusI: left and: right]; 
   return [self validate:o onError:"No CP Solver in Sub Expression"];
}
+(id<ORExpr>) expr: (id<ORExpr>) left mul: (id<ORExpr>) right
{
   id<ORExpr> o = [[ORExprMulI alloc] initORExprMulI: left and: right]; 
   return [self validate:o onError:"No CP Solver in Mul Expression"];
}
+(id<ORRelation>) expr: (id<ORExpr>) left equal: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprEqualI alloc] initORExprEqualI: left and: right]; 
   [self validate:o onError:"No CP Solver in == Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left neq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprNotEqualI alloc] initORExprNotEqualI: left and: right];
   [self validate:o onError:"No CP Solver in != Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left leq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: left and: right];
   [self validate:o onError:"No CP Solver in <= Expression"];
   return o;
}
+(id<ORRelation>) expr: (id<ORExpr>) left geq: (id<ORExpr>) right
{
   id<ORRelation> o = [[ORExprLEqualI alloc] initORExprLEqualI: right and: left];
   [self validate:o onError:"No CP Solver in >= Expression"];
   return o;
}
+(id<ORExpr>) expr: (id<ORRelation>) left and: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORConjunctI alloc] initORConjunctI:left and:right];
   return [self validate:o onError:"No CP Solver in && Expression"];
}
+(id<ORExpr>) expr: (id<ORRelation>) left or: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORDisjunctI alloc] initORDisjunctI:left or:right];
   return [self validate:o onError:"No CP Solver in || Expression"];
}
+(id<ORExpr>) expr: (id<ORRelation>) left imply: (id<ORRelation>) right
{
   id<ORExpr> o = [[ORImplyI alloc] initORImplyI:left imply:right];
   return [self validate:o onError:"No CP Solver in => Expression"];
}

+(id<ORExpr>) exprAbs: (id<ORExpr>) op
{
   id<ORExpr> o = [[ORExprAbsI alloc] initORExprAbsI:op];
   return [self validate:o onError:"No CP Solver in Abs Expression"];
}
+(id<ORExpr>) sum: (id<ORTracker>) tracker range: (ORRange) r filteredBy: (ORInt2Bool) f of: (ORInt2Expr) e
{
   ORExprSumI* o = [[ORExprSumI alloc] initORExprSumI: tracker range: r filteredBy: f of: e];
   [tracker trackObject: o];
   return o; 
}
@end