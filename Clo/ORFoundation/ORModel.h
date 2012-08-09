/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORExpr.h"
#import "ORTracker.h"

@protocol ORVar <ORExpr>
-(ORUInt) getId;
-(id) snapshot;
-(bool) bound;
@end

@protocol ORIntVar <ORVar>
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(bool) member: (ORInt) v;
@end

@protocol ORConstraint <NSObject>
@end

@protocol ORModel <NSObject,ORTracker>
-(void) add: (id<ORConstraint>) cstr;
-(void) minimize: (id<ORIntVar>) x;
-(void) maximize: (id<ORIntVar>) x;
@end
