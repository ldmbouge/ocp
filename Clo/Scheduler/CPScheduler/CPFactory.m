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
+(id<CPActivity>) activity: (id<CPIntVar>) start duration:(id<CPIntVar>) duration end:(id<CPIntVar>) end
{
   id<CPActivity> act = [[CPActivity alloc] initCPActivity: start duration: duration end: end];
   
   // XXX What is the meaning of the following? Variable subscription?
   [[start tracker] trackMutable: act];
   
   return act;
}

// optional activity
+(id<CPOptionalActivity>) compulsoryActivity:(id<CPIntVar>)start duration:(id<CPIntVar>)duration
{
    id<CPOptionalActivity> act = [[CPOptionalActivity alloc] initCPActivity: start duration: duration];
    [[start    tracker] trackMutable: act];
    [[duration tracker] trackMutable: act];
    
    return act;
}
+(id<CPOptionalActivity>) optionalActivity:(id<CPIntVar>)top startLB:(id<CPIntVar>)startLB startUB:(id<CPIntVar>)startUB startRange:(id<ORIntRange>)startRange duration:(id<CPIntVar>)duration
{
    id<CPOptionalActivity> act = [[CPOptionalActivity alloc] initCPOptionalActivity:top startLB:startLB startUB:startUB startRange:startRange duration:duration];
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
   // [pvh] this is not good
   if (before.duration.domsize == 1)
      return [CPFactory lEqual: before.start to: after.start plus: -before.duration.min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "Duration is not a constant"];
}
+(id<CPConstraint>) optionalPrecedence: (id<CPOptionalActivity>) before precedes:(id<CPOptionalActivity>) after
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
   for (ORInt i = 0; i < s.count; i++)
      types[i] = CVAR_S;
   id<CPEngine> engine = [[s at: [[s range] low]] engine];
   
   // Creating singleton-valued variables for the resource usages
   id<CPIntVarArray> ru = [CPFactory intVarArray:[r tracker] range:[r range] with:^(ORInt k) {
      id<ORIntRange> R = [ORFactory intRange: [r tracker] low: [r at: k] up: [r at: k]];
      return [CPFactory intVar: engine bounds:R];
   }];
   
   // Creating singleton-valued variables fir the area
   ORInt offset = [[r range] low] - [[d range] low];
   id<CPIntVarArray> area = [CPFactory intVarArray:[r tracker] range:[r range] with:^(ORInt k) {
      id<ORIntRange> R = [ORFactory intRange: [r tracker] low: [r at: k]*[d at: k - offset].min up: [r at: k]*[d at: k - offset].max];
      return [CPFactory intVar: engine bounds:R];
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
   id<CPIntVarArray> start = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
      return act[k].start;
   }];
   id<CPIntVarArray> duration = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
      return act[k].duration;
   }];
   id<CPIntVarArray> end = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
      return act[k].end;
   }];
   return [self cumulative: start duration: duration end: end usage: r capacity: c];
}
// Disjunctive (resource) constraint
//
+(id<CPConstraint>) disjunctive: (id<CPIntVarArray>) s duration:(id<CPIntVarArray>) d
{
    // Creating the disjunctive propagator
    id<CPConstraint> o = [[CPDisjunctive alloc] initCPDisjunctive:s duration:d];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[s tracker] trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}
+(id<CPConstraint>) disjunctive:(id<CPOptionalActivityArray>)act
{
    // Creating the disjunctive propagator
    id<CPConstraint> o = [[CPDisjunctive alloc] initCPDisjunctive: act];
    
    // XXX What is the meaning of the following? Variable subscription?
    [[act tracker] trackMutable: o];
    
    // Returning the cumulative propagator
    return o;
}
+(id<CPConstraint>) schedulingDisjunctive: (id<CPActivityArray>) act
{
   id<CPIntVarArray> start = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
      return act[k].start;
   }];
   id<CPIntVarArray> duration = [CPFactory intVarArray: [act tracker] range:[act range] with:^id<CPIntVar>(ORInt k) {
      return act[k].duration;
   }];
   return [self disjunctive: start duration: duration];
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
