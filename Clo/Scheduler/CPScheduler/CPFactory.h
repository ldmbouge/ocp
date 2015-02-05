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
#import "CPTaskCumulative.h"
#import "CPTaskDisjunctive.h"

@protocol CPTaskVarArray;
@protocol CPTaskVar;
@protocol CPAlternativeTask;
@protocol CPMachineTask;
@protocol CPDisjunctiveArray;

@interface CPFactory (CPScheduler)
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task alternatives: (id<CPTaskVarArray>) alternatives;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task spans: (id<CPTaskVarArray>) spans;

+(id<CPConstraint>) constraint: (id<CPTaskVar>) before precedes:(id<CPTaskVar>) after;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) before optionalPrecedes:(id<CPTaskVar>) after;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) before onResource:(id<CPConstraint>)bRes optionalPrecedes:(id<CPTaskVar>) after onResource:(id<CPConstraint>)aRes;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task isFinishedBy: (id<CPIntVar>) date;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task duration: (id<CPIntVar>) duration;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) task presence: (id<CPIntVar>) presence;
+(id<CPConstraint>) constraint: (id<CPTaskVar>) normal extended:  (id<CPTaskVar>) extended time: (id<CPIntVar>) time;
+(id<CPConstraint>) constraint: (id<CPResourceTask>) normal resourceExtended:  (id<CPResourceTask>) extended time: (id<CPIntVarArray>) time;

+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d end:(id<CPIntVarArray>) e usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c;
+(id<CPConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d;
+(id<CPConstraint>) taskCumulative: (id<CPTaskVarArray>) tasks with: (id<CPIntVarArray>) usages and: (id<CPIntVar>) capacity;
+(id<CPConstraint>) taskCumulative: (id<CPTaskVarArray>) tasks resourceTasks:(id<ORIntArray>)resTasks with: (id<CPIntVarArray>) usages and: (id<CPIntVar>) capacity;
+(id<CPConstraint>) taskDisjunctive: (id<CPTaskVarArray>) tasks;
+(id<CPConstraint>) taskDisjunctive: (id<CPTaskVarArray>) tasks resourceTasks:(id<ORIntArray>)resTasks;
+(id<CPConstraint>) taskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
+(id<CPConstraint>) optionalTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
+(id<CPConstraint>) optionalTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ resource:(id<CPResourceArray>) res;

+(id<CPConstraint>) difference: (id<ORTracker>) tracker engine: (id<CPEngine>) e withInitCapacity:(ORInt) numItems;

// Creating disjunctive arrays
+(id<CPDisjunctiveArray>) disjunctiveArray: (id<CPEngine>) engine range:(id<ORIntRange>) range with: (CPTaskDisjunctive*(^)(ORInt)) clo;
+(id<CPResourceArray>) resourceArray: (id<CPEngine>) engine range:(id<ORIntRange>) range with: (id<CPConstraint>(^)(ORInt)) clo;

// Creating standard tasks
+(id<CPTaskVar>) task: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;
+(id<CPTaskVar>) optionalTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration;

// Creating alternative tasks
+(id<CPAlternativeTask>) task: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration withAlternatives: (id<CPTaskVarArray>) alternatives;
+(id<CPAlternativeTask>) optionalTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration withAlternatives: (id<CPTaskVarArray>) alternatives;

// Creating span tasks
+(id<CPSpanTask>) task: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration withSpans: (id<CPTaskVarArray>) spans;
+(id<CPSpanTask>) optionalTask: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration withSpans: (id<CPTaskVarArray>) spans;

// Creating Resource tasks
+(id<CPResourceTask>) task: (id<CPEngine>) engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration durationArray:(id<ORIntRangeArray>) durationArray runsOnOneOf: (id<CPResourceArray>) resources;
+(id<CPResourceTask>) optionalTask: (id<CPEngine>) engine horizon:(id<ORIntRange>)horizon duration:(id<ORIntRange>)duration durationArray:(id<ORIntRangeArray>) durationArray runsOnOneOf: (id<CPResourceArray>) resources;

@end