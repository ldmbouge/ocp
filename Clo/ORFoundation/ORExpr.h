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
-(id<ORExpr>) add: (id<ORExpr>) e;
-(id<ORExpr>) sub: (id<ORExpr>) e;
-(id<ORExpr>) mul: (id<ORExpr>) e;
-(id<ORExpr>) muli: (ORInt) e;
-(id<ORRelation>) equal: (id<ORExpr>) e;
@end

@protocol ORRelation <ORExpr>
@end
