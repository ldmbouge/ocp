/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORScheduler.h>
#import <objcp/CPFactory.h>
#import "CPtask.h"

@interface CPFactory (CPScheduler)
//+(id<CPConstraint>) alternative: (id<CPActivity>) act composedBy: (id<CPActivityArray>) alternatives;

+(id<CPConstraint>) constraint: (id<CPTaskVar>) before precedes:(id<CPTaskVar>) after;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) before optionalPrecedes:(id<CPTaskVar>) after;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task isFinishedBy: (id<CPIntVar>) date;

+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d end:(id<CPIntVarArray>) e usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d;
+(id<CPConstraint>) taskDisjunctive: (id<CPTaskVarArray>) tasks;

+(id<CPConstraint>) difference: (id<ORTracker>) tracker engine: (id<CPEngine>) e withInitCapacity:(ORInt) numItems;

+(id<CPTaskVar>) task: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
+(id<CPTaskVar>) optionalTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
//+(id<CPIntVar>) reifyPresent: (id<CPTaskVar>) task;
@end