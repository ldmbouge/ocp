/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORScheduler.h>
#import <CPScheduler/CPActivity.h>
#import <objcp/CPFactory.h>

@interface CPFactory (CPScheduler)
//+(id<CPActivity>) activity: (id<CPIntVar>) start duration:(id<CPIntVar>) duration end:(id<CPIntVar>) end;
+(id<CPOptionalActivity>) compulsoryActivity: (id<CPIntVar>) start duration:(id<CPIntVar>) duration;
+(id<CPOptionalActivity>) optionalActivity: (id<CPIntVar>) top startLB: (id<CPIntVar>) startLB startUB:(id<CPIntVar>) startUB startRange:(id<ORIntRange>)startRange duration:(id<CPIntVar>) duration;
+(id<CPDisjunctiveResource>) disjunctiveResource:  (id<ORTracker>) tracker  activities: (id<CPOptionalActivityArray>) activities;

//+(id<CPConstraint>) precedence: (id<CPActivity>) before precedes:(id<CPActivity>) after;
+(id<CPConstraint>) optionalPrecedence: (id<CPOptionalActivity>) before precedes:(id<CPOptionalActivity>) after;
+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d end:(id<CPIntVarArray>) e usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) cumulative: (id<CPOptionalActivityArray>) act usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d;
+(id<CPConstraint>) disjunctive: (id<CPOptionalActivityArray>) act;
+(id<CPConstraint>) difference: (id<ORTracker>) tracker engine: (id<CPEngine>) e withInitCapacity:(ORInt) numItems;
@end