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
#import "ORModelI.h"

@interface ORFactory : NSObject
+(id<ORInteger>) integer: (id<ORTracker>) tracker value: (ORInt) value;
+(id<ORIntSet>)  intSet: (id<ORTracker>) tracker;
+(id<ORIntRange>)  intRange: (id<ORTracker>) tracker low: (ORInt) low up: (ORInt) up;

+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range value: (ORInt) value;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range with:(ORInt(^)(ORInt)) clo;
+(id<ORIntArray>) intArray: (id<ORTracker>) tracker range: (id<ORIntRange>) r1 range: (id<ORIntRange>) r2 with: (ORInt(^)(ORInt,ORInt)) clo;

+(id<ORIdArray>)   idArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
+(id<ORIdMatrix>) idMatrix: (id<ORTracker>) tracker range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;

+(id<ORIntSetArray>) intSetArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range;
+(id<ORIntSet>) collect: (id<ORTracker>) cp range: (id<ORIntRange>) r suchThat: (ORInt2Bool) f of: (ORInt2Int) e;

+(id<IntEnumerator>) intEnumerator: (id<ORTracker>) cp over: (id<ORIntIterator>) r;

+(id<ORModel>) createModel;
+(id<ORIntVar>) intVar: (id<ORTracker>) tracker domain: (id<ORIntRange>) r;
+(id<ORIntVarArray>) intVarArray: (id<ORTracker>) tracker range: (id<ORIntRange>) range domain: (id<ORIntRange>) domain;
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x;
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
+(id<ORExpr>) sum: (id<ORTracker>) tracker over: (id<ORIntIterator>) S suchThat: (ORInt2Bool) f of: (ORInt2Expr) e;
+(id<ORRelation>) or: (id<ORTracker>) tracker over: (id<ORIntIterator>) r suchThat: (ORInt2Bool) f of: (ORInt2Relation) e;
@end

#define RANGE(cp,a,b)      [ORFactory intRange: cp low: a up: b]
