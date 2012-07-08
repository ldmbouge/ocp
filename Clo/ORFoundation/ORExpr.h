/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORTypes.h"
#import "ORFoundation/ORTracker.h"

@protocol ORRelation;
@protocol ORExpr;

@protocol ORExpr <NSObject,NSCoding>
-(id<ORTracker>)tracker;
-(ORInt) min;
-(ORInt) max;
-(BOOL) isConstant;
-(BOOL) isVariable;
-(id<ORExpr>) plus: (id<ORExpr>) e;
-(id<ORExpr>) sub: (id<ORExpr>) e;
-(id<ORExpr>) mul: (id<ORExpr>) e;
-(id<ORExpr>) muli: (ORInt) e;
-(id<ORRelation>) eq: (id<ORExpr>) e;
-(id<ORRelation>) eqi: (ORInt) e;
-(id<ORRelation>) neq: (id<ORExpr>) e;
-(id<ORRelation>) leq: (id<ORExpr>) e;
-(id<ORRelation>) geq: (id<ORExpr>) e;
@end

enum CPRelationType {
   CPRBad = 0,
   CPREq  = 1,
   CPRNEq = 2,
   CPRLEq = 3
};

@protocol ORRelation <ORExpr>
-(enum CPRelationType)type;
@end
