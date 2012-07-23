/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORExpr.h"
#import "ORFoundation/ORData.h"
#import "ORFoundation/ORArray.h"
#import "ORFoundation/ORSet.h"

@interface ORFactory : NSObject
+(id<ORInteger>) integer: (id<ORTracker>)tracker value: (ORInt) value;

+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (ORRange) range value: (ORInt) value;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (ORRange) range with:(ORInt(^)(ORInt)) clo;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (ORRange) r1 range: (ORRange) r2 with: (ORInt(^)(ORInt,ORInt)) clo;

+(id<ORIdArray>)   idArray: (id<ORTracker>) tracker range: (ORRange) range;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (ORRange) r0 : (ORRange) r1;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (ORRange) r0 : (ORRange) r1 : (ORRange) r2;

+(id<ORIntSetArray>) intSetArray: (id<ORTracker>) tracker range: (ORRange) range;
+(id<ORIntSet>) collect: (id<ORTracker>) cp range: (ORRange) r suchThat: (ORInt2Bool) f of: (ORInt2Int) e;

@end

#define COLLECT(m,P,R,E) [ORFactory collect: m range:(R) suchThat:nil of:^ORInt(ORInt P) { return (ORInt)(E);}]

@interface ORFactory (Expressions)
+(id<ORExpr>) expr: (id<ORExpr>) left plus: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORExpr>) left sub: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORExpr>) left mul: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left equal: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left neq: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left leq: (id<ORExpr>) right;
+(id<ORRelation>) expr: (id<ORExpr>) left geq: (id<ORExpr>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left and: (id<ORRelation>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left or: (id<ORRelation>) right;
+(id<ORExpr>) expr: (id<ORRelation>) left imply: (id<ORRelation>) right;
+(id<ORExpr>) exprAbs: (id<ORExpr>) op;
+(id<ORExpr>) sum: (id<ORTracker>) tracker range: (ORRange) r suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORExpr>) sum: (id<ORTracker>) tracker intSet: (id<ORIntSet>) r suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
@end

