/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPFactory.h"
#import "CPConstraint.h"
#import "CPCumulative.h"
#import "CPDisjunctive.h"
#import "CPDifference.h"

@implementation CPFactory (CPScheduler)

// Cumulative (resource) constraint
//
+(id<ORConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c
{
    // Creating the type of tasks
    TaskType* types = malloc(s.count * sizeof(TaskType));
    for (ORInt i = 0; i < s.count; i++)
        types[i] = CVAR_S;
    id<CPEngine> engine = [[s at: [[s range] low]] engine];
    
    // Creating singleton-valued variables for the durations
    id<CPIntVarArray> durs = [CPFactory intVarArray:[d tracker] range:[d range] with:^(ORInt k) {
        id<ORIntRange> R = [ORFactory intRange: [d tracker] low: [d at: k] up: [d at: k]];
        return [CPFactory intVar: engine bounds:R];
    }];
    
    // Creating singleton-valued variables for the resource usages
    id<CPIntVarArray> ru = [CPFactory intVarArray:[r tracker] range:[r range] with:^(ORInt k) {
        id<ORIntRange> R = [ORFactory intRange: [r tracker] low: [r at: k] up: [r at: k]];
        return [CPFactory intVar: engine bounds:R];
    }];
    
    // Creating singleton-valued variables fir the area
    ORInt offset = [[r range] low] - [[d range] low];
    id<CPIntVarArray> area = [CPFactory intVarArray:[r tracker] range:[r range] with:^(ORInt k) {
        id<ORIntRange> R = [ORFactory intRange: [r tracker] low: [r at: k]*[d at: k - offset] up: [r at: k]*[d at: k - offset]];
        return [CPFactory intVar: engine bounds:R];
    }];
    
    // Creating view variables for the end times
    ORInt offset2 = [[s range] low] - [[d range] low];
    id<CPIntVarArray> end = [CPFactory intVarArray:[s tracker] range:[s range] with:^(ORInt k) {
        return [CPFactory intVar: [s at: k] shift: [d at: k - offset2]];
    }];
    
    // Creating the cumulative propagator
    id<CPConstraint> o = [[CPCumulative alloc] initCPCumulative:s duration:durs usage:ru energy:area end:end type:types capacity:c];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[s tracker] trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}

// Disjunctive (resource) constraint
//
+(id<ORConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d
{
    // Creating the disjunctive propagator
    id<CPConstraint> o = [[CPDisjunctive alloc] initCPDisjunctive:s duration:d];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[s tracker] trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}

// Difference (logic) constraint
//
+(id<ORConstraint>) difference: (id<ORTracker>) tracker engine: (id<CPEngine>)e withInitCapacity:(ORInt)numItems
{
    // Creating the difference logic propagator
    id<CPConstraint> o = [[CPDifference alloc] initCPDifference: e withInitCapacity: numItems];

    // XXX What is the meaning of the following? Variable subscription?
    [tracker trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}

@end
