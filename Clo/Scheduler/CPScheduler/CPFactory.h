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
#import "CPtask.h"

@interface CPFactory (CPScheduler)
+(id<CPActivity>) activity: (id<CPIntVar>) start duration:(id<CPIntVar>) duration;
+(id<CPActivity>) optionalActivity: (id<CPIntVar>) top startLB: (id<CPIntVar>) startLB startUB:(id<CPIntVar>) startUB startRange:(id<ORIntRange>)startRange duration:(id<CPIntVar>) duration;
+(id<CPConstraint>) alternative: (id<CPActivity>) act composedBy: (id<CPActivityArray>) alternatives;

+(id<CPDisjunctiveResource>) disjunctiveResource:  (id<ORTracker>) tracker  activities: (id<CPActivityArray>) activities;

+(id<CPConstraint>) precedence: (id<CPActivity>) before precedes:(id<CPActivity>) after;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) before precedes:(id<CPTaskVar>) after;

+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d end:(id<CPIntVarArray>) e usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) cumulative: (id<CPActivityArray>) act usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d;
+(id<CPConstraint>) disjunctive: (id<CPActivityArray>) act;
+(id<CPConstraint>) difference: (id<ORTracker>) tracker engine: (id<CPEngine>) e withInitCapacity:(ORInt) numItems;

+(id<CPTaskVar>) task: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
+(id<CPTaskVar>) optionalTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
@end