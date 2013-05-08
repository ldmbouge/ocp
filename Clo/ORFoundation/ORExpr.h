/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORUtilities/ORTypes.h"
#import "ORFoundation/ORTracker.h"
#import "ORFoundation/ORConstraint.h"

@protocol ORRelation;
@protocol ORExpr;
@protocol ORIntArray;
@protocol ORIntVarArray;

enum ORRelationType {
   ORRBad = 0,
   ORREq  = 1,
   ORRNEq = 2,
   ORRLEq = 3,
   ORRDisj = 4,
   ORRConj = 5,
   ORRImply = 6
};

id<ORExpr> __attribute__((overloadable)) mult(NSNumber* l,id<ORExpr> r);
id<ORExpr> __attribute__((overloadable)) mult(id<ORExpr> l,id<ORExpr> r);

@protocol ORExpr <ORConstraint,NSObject,NSCoding>
-(id<ORTracker>) tracker;
-(ORInt) min;
-(ORInt) max;
-(ORFloat) floatValue;
-(ORInt) intValue;
-(ORBool) isConstant;
-(ORBool) isVariable;
-(id<ORExpr>) abs;
-(id<ORExpr>) plus: (id) e;
-(id<ORExpr>) sub: (id) e;
-(id<ORExpr>) mul: (id) e;
-(id<ORExpr>) div: (id) e;
-(id<ORExpr>) mod: (id) e;
-(id<ORRelation>) eq: (id) e;
-(id<ORRelation>) neq: (id) e;
-(id<ORRelation>) leq: (id) e;
-(id<ORRelation>) geq: (id) e;
-(id<ORRelation>) lt: (id) e;
-(id<ORRelation>) gt: (id) e;
-(id<ORRelation>) neg;
-(id<ORRelation>) and: (id<ORExpr>) e;
-(id<ORRelation>) or: (id<ORExpr>) e;
-(id<ORRelation>) imply:(id<ORExpr>)e;

-(id<ORExpr>) absTrack:(id<ORTracker>)t;
-(id<ORExpr>) plus: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) sub: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) mul: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) div: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) mod: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) eq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) neq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) leq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) geq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) lt: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) gt: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) negTrack:(id<ORTracker>)t;
-(id<ORRelation>) and: (id<ORExpr>) e  track:(id<ORTracker>)t;
-(id<ORRelation>) or: (id<ORExpr>) e track:(id<ORTracker>)t;
-(id<ORRelation>) imply:(id<ORExpr>)e  track:(id<ORTracker>)t;
-(enum ORRelationType) type;
@end

@protocol ORRelation <ORExpr>
-(enum ORRelationType) type;
-(id<ORRelation>) and: (id<ORRelation>) e;
-(id<ORRelation>) or: (id<ORRelation>) e;
-(id<ORRelation>) imply: (id<ORRelation>) e;
@end

@interface NSNumber (Expressions)
-(id<ORExpr>)asExpression:(id<ORTracker>)tracker;
-(id<ORExpr>) plus: (id<ORExpr>) e;
-(id<ORExpr>) sub: (id<ORExpr>) e;
-(id<ORExpr>) mul: (id<ORExpr>) e;
-(id<ORExpr>) div: (id<ORExpr>) e;
-(id<ORExpr>) mod: (id<ORExpr>) e;
-(id<ORRelation>) eq: (id<ORExpr>) e;
-(id<ORRelation>) neq: (id<ORExpr>) e;
-(id<ORRelation>) leq: (id<ORExpr>) e;
-(id<ORRelation>) geq: (id<ORExpr>) e;
-(id<ORRelation>) lt: (id<ORExpr>) e;
-(id<ORRelation>) gt: (id<ORExpr>) e;
@end

