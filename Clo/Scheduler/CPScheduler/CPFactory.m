/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objcp/CPConstraint.h>
#import "CPFactory.h"
#import "CPConstraint.h"
#import "CPCumulative.h"
#import "CPDisjunctive.h"
#import "CPDifference.h"

@implementation CPFactory (CPScheduler)
// activity
+(id<CPActivity>) activity:(id<CPIntVar>)start duration:(id<CPIntVar>)duration
{
    id<CPActivity> act = [[CPActivity alloc] initCPActivity: start duration: duration];
    [[start    tracker] trackMutable: act];
    [[duration tracker] trackMutable: act];
    
    return act;
}
+(id<CPActivity>) optionalActivity:(id<CPIntVar>)top startLB:(id<CPIntVar>)startLB startUB:(id<CPIntVar>)startUB startRange:(id<ORIntRange>)startRange duration:(id<CPIntVar>)duration
{
    id<CPActivity> act = [[CPActivity alloc] initCPOptionalActivity:top startLB:startLB startUB:startUB startRange:startRange duration:duration];
    [[startLB  tracker] trackMutable: act];
    [[startUB  tracker] trackMutable: act];
    [[duration tracker] trackMutable: act];
    [[top      tracker] trackMutable: act];
    
    return act;
}

// disjunctive resource
+(id<CPDisjunctiveResource>) disjunctiveResource:  (id<ORTracker>) tracker  activities: (id<CPActivityArray>) activities
{
    id<CPDisjunctiveResource> dr = [[CPDisjunctiveResource alloc] initCPDisjunctiveResource: tracker activities: activities];
    [tracker trackMutable: dr];
    return dr;
}

// Precedence
+(id<CPConstraint>) precedence: (id<CPActivity>) before precedes:(id<CPActivity>) after
{
    // Creating a precedence propagator
    return [[CPPrecedence alloc] initCPPrecedence:before after:after];
}


// Cumulative (resource) constraint
//
+(id<ORConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d end:(id<CPIntVarArray>) e usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c
{
    // Creating the type of tasks
    TaskType* types = malloc(s.count * sizeof(TaskType));
    if (types == NULL)
        @throw [[ORExecutionError alloc] initORExecutionError: "Out of memory"];
    for (ORInt i = 0; i < s.count; i++)
        types[i] = CVAR_S;
    id<CPEngine> engine = [[s at: [[s range] low]] engine];
    
    // Creating singleton-valued variables for the resource usages
    id<CPIntVarArray> ru = [CPFactory intVarArray:[r tracker] range:[r range] with:^(ORInt k) {
        return [CPFactory intVar:engine value:[r at: k]];
    }];
    
    // Creating singleton-valued variables for the area
    ORInt offset = [[r range] low] - [[d range] low];
    id<CPIntVarArray> area = [CPFactory intVarArray:[r tracker] range:[r range] with:^(ORInt k) {
        if ([[d at: k - offset] domsize] == 1) {
            return [CPFactory intVar:engine value: [r at: k] * [d at: k - offset].min];
        }
        return [CPFactory intVar: [d at: k - offset] scale:[r at: k]];
    }];
    
    // Creating the cumulative propagator
    id<CPConstraint> o = [[CPCumulative alloc] initCPCumulative:s duration: d usage:ru energy:area end:e type:types capacity:c];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[s tracker] trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}

// Cumulative (resource) constraint
//
+(id<ORConstraint>) cumulative: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c
{
    // Creating view variables for the end times
    ORInt offset2 = [[s range] low] - [[d range] low];
    id<CPIntVarArray> e = [CPFactory intVarArray:[s tracker] range:[s range] with:^id<CPIntVar>(ORInt k) {
        id<CPIntVar> duration = [d at: k - offset2];
        id<CPEngine> engine =[duration engine];
        if (duration.min == duration.max)
            return [CPFactory intVar: [s at: k] shift: duration.min];
        else {
            id<CPIntVar> concreteEnd = [CPFactory intVar: engine domain: RANGE(engine,s[k].min + duration.min,s[k].max + duration.max)];
            id<CPIntVarArray> av = [CPFactory intVarArray: engine range: RANGE(engine,0,2) with: ^id<CPIntVar>(ORInt k) {
                if (k == 0)
                    return s[k];
                else if (k == 1)
                    return duration;
                else
                    return [CPFactory intVar: concreteEnd scale: -1];
            }];
            id<CPConstraint> cstr = [CPFactory sum: av eq: 0 annotation: RangeConsistency];
            [engine add: cstr];
            return concreteEnd;
        }
    }];
    return [CPFactory cumulative: s duration: d end: e usage:r capacity: c];
}
+(id<CPConstraint>) cumulative: (id<CPActivityArray>) act usage:(id<ORIntArray>)r capacity:(id<CPIntVar>) c
{
    TaskType* types = malloc(act.count * sizeof(TaskType));
    if (types == NULL)
        @throw [[ORExecutionError alloc] initORExecutionError: "Out of memory"];
    for (ORInt ii = 0; ii < act.count; ii++) {
        const ORInt i = ii + act.range.low;
        if (act[i].isOptional) {
            if (act[i].duration.domsize == 1)
                types[i] = CVAR_SR;
            else
                types[i] = CVAR_SA;
        }
        else {
            if (act[i].duration.domsize == 1)
                types[i] = CVAR_S;
            else
                types[i] = CVAR_SD;
        }
    }
    id<CPEngine> engine =[act[act.range.low].duration engine];
    // Start variables
    id<CPIntVarArray> start = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
        return act[k].startLB;
    }];
    // Duration variables
    id<CPIntVarArray> duration = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
        return act[k].duration;
    }];
    // End variables
    id<CPIntVarArray> end = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
        id<CPIntVar> duration = act[k].duration;
        if (duration.min == duration.max)
            return [CPFactory intVar: act[k].startLB shift: duration.min];
        else {
            id<CPIntVar> concreteEnd = [CPFactory intVar: engine domain: RANGE(engine,act[k].startLB.min + duration.min,act[k].startLB.max + duration.max)];
            id<CPIntVarArray> av = [CPFactory intVarArray: engine range: RANGE(engine,0,2) with: ^id<CPIntVar>(ORInt k) {
                if (k == 0)
                    return act[k].startLB;
                else if (k == 1)
                    return duration;
                else
                    return [CPFactory intVar: concreteEnd scale: -1];
            }];
            id<CPConstraint> cstr = [CPFactory sum: av eq: 0 annotation: RangeConsistency];
            [engine add: cstr];
            return concreteEnd;
        }
    }];
    // Resource usage variables
    ORInt offset = r.range.low - act.range.low;
    id<CPIntVarArray> ru = [CPFactory intVarArray:[act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
        if (act[k].isOptional)
            return [CPFactory intVar:act[k].top scale:[r at: k + offset]];
        else
            return [CPFactory intVar:engine value:[r at: k + offset]];
    }];
    // Area variables
    id<CPIntVarArray> area = [CPFactory intVarArray:[act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
        if (duration[k].domsize == 1) {
            if (ru[k].domsize == 1)
                return [CPFactory intVar:engine value:duration[k].min * ru[k].min];
            else
                return [CPFactory intVar:ru[k] scale:duration[k].min];
        }
        else {
            if (ru[k].domsize == 1)
                return [CPFactory intVar:duration[k] scale:ru[k].min];
            else {
                id<CPIntVar> area_k = [CPFactory intVar:engine bounds:RANGE(engine, duration[k].min * ru[k].min, duration[k].max * ru[k].max)];
                [engine add: [CPFactory mult:duration[k] by:ru[k] equal:area_k]];
                return area_k;
            }
        }
    }];
    // Creating the cumulative propagator
    id<CPConstraint> o = [[CPCumulative alloc] initCPCumulative:start duration:duration usage:ru energy:area end:end type:types capacity:c];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[act tracker] trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}

// Disjunctive (resource) constraint
//
+(id<CPConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d
{
    // Creating the disjunctive propagator
    id<CPConstraint> o = [[CPDisjunctive alloc] initCPDisjunctive:s duration:d];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[s tracker] trackMutable: o];
    
    // Returning the disjunctive propagator
    return o;
}
+(id<CPConstraint>) disjunctive:(id<CPActivityArray>)act
{
    // Creating the disjunctive propagator
    id<CPConstraint> o = [[CPDisjunctive alloc] initCPDisjunctive: act];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[act tracker] trackMutable: o];
    
    // Returning the disjunctive propagator
    return o;
}


// Difference (logic) constraint
//
+(id<CPConstraint>) difference: (id<ORTracker>) tracker engine: (id<CPEngine>)e withInitCapacity:(ORInt)numItems
{
    // Creating the difference logic propagator
    id<CPConstraint> o = [[CPDifference alloc] initCPDifference: e withInitCapacity: numItems];
    
    // XXX What is the meaning of the following? Variable subscription?
    [tracker trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}

@end
