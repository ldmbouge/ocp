/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORScheduler.h>
#import <CPScheduler/CPActivity.h>
#import <objcp/CPFactory.h>

@interface CPFactory (CPScheduler)
+(id<CPActivity>) activity: (id<CPIntVar>) start duration:(ORInt) duration;
+(id<CPDisjunctiveResource>) disjunctiveResource:  (id<ORTracker>) tracker  activities: (id<CPActivityArray>) activities;

+(id<CPConstraint>) precedence: (id<CPActivity>) before precedes:(id<CPActivity>) after;
+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) cumulative: (id<CPActivityArray>) act usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d;
+(id<CPConstraint>) disjunctive: (id<CPActivityArray>) act;
+(id<CPConstraint>) difference: (id<ORTracker>) tracker engine: (id<CPEngine>) e withInitCapacity:(ORInt) numItems;
@end