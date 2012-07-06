/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORTracker.h"
@protocol ORExpr;

@protocol ORIntArray <NSObject> 
-(ORInt) at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) index: (id<ORExpr>) idx;
@end

@protocol ORIdArray <NSObject>
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) index: (id<ORExpr>) idx;
@end
