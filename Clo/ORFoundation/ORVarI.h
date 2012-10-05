/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORArray.h"
#import "ORSet.h"
#import "ORModel.h"
#import "ORVar.h"
#import "ORExprI.h"
#import "ORVisit.h"

@interface ORIntVarI : ORExprI<ORIntVar>
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker domain: (id<ORIntRange>) domain;
// [ldm] All the methods below were missing??????
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds)bounds;
-(BOOL) member: (ORInt) v;
-(BOOL) isBool;
-(id<ORIntVar>) dereference;
-(id<ORIntVar>) impl;
-(void) setImpl: (id<ORIntVar>) _impl;
-(id<ORASolver>) solver;
-(NSSet*)constraints;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(void) visit: (id<ORExprVisitor>)v;
@end

@interface ORIntVarAffineI : ORIntVarI
-(ORIntVarAffineI*)initORIntVarAffineI:(id<ORTracker>)tracker var:(id<ORIntVar>)x scale:(ORInt)a shift:(ORInt)b;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
@end

@interface ORFloatVarI : ORExprI<ORFloatVar>
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) tracker low: (ORFloat) low up: (ORFloat) up;
-(ORFloat) value;
-(ORFloat) min;
-(ORFloat) max;
-(id<ORIntVar>) dereference;
-(id<ORIntVar>) impl;
-(void) setImpl: (id<ORIntVar>) _impl;
-(id<ORASolver>) solver;
-(NSSet*) constraints;
-(void) visit: (id<ORExprVisitor>)v;
@end
