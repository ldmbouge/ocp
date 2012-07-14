/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORTracker.h"
#import "ORFoundation/ORData.h"
@protocol ORExpr;
@protocol ORIntSet;


@protocol ORIntArray <NSObject> 
-(ORInt) at: (ORInt) value;
-(void) set: (ORInt) value at:(ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(ORRange) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
@end

@protocol ORIntSetArray <NSObject>
-(ORInt) at: (id<ORIntSet>) value;
-(void) set: (id<ORIntSet>) value at: (ORInt)idx;
-(ORInt) low;
-(ORInt) up;
-(ORRange) range;
-(NSUInteger) count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORIdArray <NSObject>
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(ORRange) range;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end

@protocol ORIdMatrix <NSObject>
-(id) flat:(ORInt)i;
-(id) at: (ORInt) i1 : (ORInt) i2;
-(id) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(ORInt) arity;
-(ORRange) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORTracker>) tracker;
@end
