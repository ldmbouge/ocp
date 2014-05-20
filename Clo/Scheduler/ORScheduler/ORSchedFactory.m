/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>
#import "ORConstraintI.h"

@implementation ORFactory (ORScheduler)

+(id<ORActivity>) activity: (id<ORTracker>) model horizon: (id<ORIntRange>) horizon duration: (ORInt) duration
{
   id<ORActivity> o = [[ORActivity alloc] initORActivity: model horizon: horizon duration:duration];
   [model trackMutable:o];
   return o;
}
+(id<ORActivity>) activity: (id<ORTracker>) model horizon: (id<ORIntRange>) horizon durationVariable: (id<ORIntVar>) duration
{
   id<ORActivity> o = [[ORActivity alloc] initORActivity: model horizon: horizon durationVariable:duration];
   [model trackMutable:o];
   return o;
}
+(id<ORActivityArray>) activityArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<ORActivity>(^)(ORInt)) clo;
{
   id<ORIdArray> o = [ORFactory idArray: model range:range];
   for(ORInt k=range.low;k <= range.up;k++)
      [o set: clo(k) at:k];
   return (id<ORActivityArray>) o;
}
+(id<ORActivityArray>) activityArray: (id<ORTracker>) model range: (id<ORIntRange>) range horizon: (id<ORIntRange>) horizon duration: (id<ORIntArray>) duration
{
   return [ORFactory activityArray: model range: range with: ^id<ORActivity>(ORInt i) {
      return [ORFactory activity: model horizon: horizon duration: [duration at: i]];
   }];
}
+(id<ORActivityMatrix>) activityMatrix: (id<ORTracker>) model range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2  with: (id<ORActivity>(^)(ORInt,ORInt)) clo;
{
   id<ORIdMatrix> o = [ORFactory idMatrix: model range: R1 : R2];
   for(ORInt i=R1.low;i <= R1.up;i++)
      for(ORInt j=R2.low;j <= R2.up;j++)
         [o set: clo(i,j) at: i : j];
   return (id<ORActivityMatrix>) o;
}

+(id<ORActivityMatrix>) activityMatrix: (id<ORTracker>) model range: (id<ORIntRange>) R1 : (id<ORIntRange>) R2
                               horizon: (id<ORIntRange>) horizon duration: (id<ORIntMatrix>) duration
{
   return [ORFactory activityMatrix: model range: R1 : R2  with: ^id<ORActivity>(ORInt i,ORInt j) {
      return [ORFactory activity: model horizon: horizon duration: [duration at: i : j]];
   }];
}
// Optional activities
+(id<OROptionalActivity>) compulsoryActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
    id<OROptionalActivity> o = [[OROptionalActivity alloc] initORActivity: model horizon: horizon duration:duration];
    [model trackMutable:o];
    return o;
}
+(id<OROptionalActivity>) optionalActivity: (id<ORModel>) model horizon: (id<ORIntRange>) horizon duration: (id<ORIntRange>) duration
{
    id<OROptionalActivity> o = [[OROptionalActivity alloc] initOROptionalActivity: model horizon: horizon duration:duration];
    [model trackMutable:o];
    return o;
}
+(id<OROptionalActivity>) compulsoryAlternativeActivity: (id<ORModel>) model range: (id<ORIntRange>) range with: (id<OROptionalActivity>(^)(ORInt)) clo;
{
    id<OROptionalActivityArray> acts = [ORFactory optionalActivityArray:model range:range with:clo];
    id<OROptionalActivity> o;
    ORInt count = 0;
    for (ORInt i = acts.range.low; i <= acts.range.up; i++) {
        if (!acts[i].isOptional) count++;
    }
    if (count > 1) failNow();
    if (count == 1) {
        for (ORInt i = acts.range.low; i <= acts.range.up; i++) {
            if (acts[i].isOptional) {
                [model add: [ORFactory equalc:model var:acts[i].top to:0]];
            }
            else {
                o = acts[i];
            }
        }
    }
    else {
        o = [[OROptionalActivity alloc] initORAlternativeActivity:model activities:acts];
    }
    [model trackMutable:o];
    return o;
}
+(id<OROptionalActivityArray>) optionalActivityArray: (id<ORTracker>) model range: (id<ORIntRange>) range with: (id<OROptionalActivity>(^)(ORInt)) clo;
{
    id<ORIdArray> o = [ORFactory idArray:model range:range];
    for(ORInt k = range.low; k <= range.up; k++)
        [o set: clo(k) at:k];
    return (id<OROptionalActivityArray>) o;
}

+(id<ORDisjunctiveResourceArray>) disjunctiveResourceArray: (id<ORTracker>) model range: (id<ORIntRange>) range
{
   id<ORIdArray> o = [ORFactory idArray: model range:range];
   for(ORInt k=range.low;k <= range.up;k++) {
      id<ORDisjunctiveResource> dr = [ORFactory disjunctiveResource: model];
      [o set: dr at:k];
   }
   return (id<ORDisjunctiveResourceArray>) o;
}
// Precedes
//
+(id<ORPrecedes>) precedence: (id<ORActivity>) before precedes:(id<ORActivity>) after
{
   id<ORPrecedes> o = [[ORPrecedes alloc] initORPrecedes: before precedes: after];
   [[before.start tracker] trackMutable:o];
   return o;
}
+(id<OROptionalPrecedes>) optionalPrecedence: (id<OROptionalActivity>) before precedes:(id<OROptionalActivity>) after
{
    id<OROptionalPrecedes> o = [[OROptionalPrecedes alloc] initOROptionalPrecedes: before precedes: after];
    [[before.duration tracker] trackMutable:o];
    return o;
}

// Cumulative (resource) constraint
//
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r capacity:(id<ORIntVar>) c
{
   id<ORTracker> tracker = [s tracker];
   id<ORIntVarArray> duration = [ORFactory intVarArray: tracker range:[s range] with:^id<ORIntVar>(ORInt k) {
      return [ORFactory intVar: tracker domain: RANGE(tracker,[d at: k],[d at: k])];
   }];
    id<ORCumulative> o = [[ORCumulative alloc] initORCumulative:s duration: duration usage:r capacity:c];
    [[s tracker] trackMutable:o];
    return o;
}
+(id<ORCumulative>) cumulative: (id<ORIntVarArray>) s duration:(id<ORIntArray>) d usage:(id<ORIntArray>)r maxCapacity:(ORInt) c
{
   id<ORTracker> tracker = [s tracker];
   id<ORIntVarArray> duration = [ORFactory intVarArray: tracker range:[s range] with:^id<ORIntVar>(ORInt k) {
      return [ORFactory intVar: tracker domain: RANGE(tracker,[d at: k],[d at: k])];
   }];
   id<ORIntVar> capacity = [ORFactory intVar: [s tracker] domain: RANGE([s tracker],c,c)];
   id<ORCumulative> o = [[ORCumulative alloc] initORCumulative:s duration: duration usage:r capacity:capacity];
   [[s tracker] trackObject:o];
   return o;
}
+(id<ORSchedulingCumulative>) cumulative: (id<ORActivityArray>) act usage:(id<ORIntArray>) r maxCapacity:(ORInt) c
{
   id<ORIntVar> capacity = [ORFactory intVar: [act tracker] domain: RANGE([act tracker],c,c)];
   id<ORSchedulingCumulative> o = [[ORSchedulingCumulative alloc] initORSchedulingCumulative: act usage:r capacity:capacity];
   [[act tracker] trackObject:o];
   return o;
}
// Disjunctive (resource) constraint
//
+(id<ORDisjunctive>) disjunctive: (id<ORIntVarArray>) s duration:(id<ORIntVarArray>) d
{
    id<ORDisjunctive> o = [[ORDisjunctive alloc] initORDisjunctive:s duration:d];
    [[s tracker] trackObject:o];
    return o;
}
+(id<ORDisjunctive>) disjunctive: (id<OROptionalActivityArray>) act
{
    id<ORDisjunctive> o = [[ORDisjunctive alloc] initORDisjunctive:act];
    [[act tracker] trackObject:o];
    return o;
}
+(id<ORSchedulingDisjunctive>) schedulingDisjunctive: (id<ORActivityArray>) act
{
   id<ORSchedulingDisjunctive> o = [[ORSchedulingDisjunctive alloc] initORSchedulingDisjunctive: act];
   [[act tracker] trackObject:o];
   return o;
}

+(id<ORDisjunctiveResource>) disjunctiveResource: (id<ORTracker>) model
{
   id<ORDisjunctiveResource> o = [[ORDisjunctiveResource alloc] initORDisjunctiveResource: model];
   [model trackObject:o];
   return o;
}

// Difference Logic constraint
+(id<ORDifference>) difference: (id<ORTracker>) model initWithCapacity:(ORInt) numItems
{
    id<ORDifference> o = [[ORDifference alloc] initORDifference: model initWithCapacity: numItems];
    [model trackObject:o];
    return o;
}

// x <= y + d handled by the difference logic constraint
+(id<ORDiffLEqual>) diffLEqual:(id<ORDifference>)diff var: (id<ORIntVar>)x to: (id<ORIntVar>)y plus: (ORInt)d
{
    id<ORDiffLEqual> o = [[ORDiffLEqual alloc] initORDiffLEqual:diff var:x to:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}

// b <-> x <= y + d handled by the difference logic constraint
+(id<ORDiffReifyLEqual>) diffReifyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d
{
    if (!b.isBool) {
        @throw [[ORExecutionError alloc] initORExecutionError: "diffReifyLEqual: b is not Boolean!"];
    }
    id<ORDiffReifyLEqual> o = [[ORDiffReifyLEqual alloc] initORDiffReifyLEqual:diff boolean:b with:x leqc:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}

// b -> x <= y + d handled by the difference logic constraint
+(id<ORDiffImplyLEqual>) diffImplyLEqual: (id<ORDifference>) diff boolean:(id<ORIntVar>)b with:(id<ORIntVar>)x leqc:(id<ORIntVar>)y plus: (ORInt)d
{
    if (!b.isBool) {
        @throw [[ORExecutionError alloc] initORExecutionError: "diffImplyLEqual: b is not Boolean!"];
    }
    id<ORDiffImplyLEqual> o = [[ORDiffImplyLEqual alloc] initORDiffImplyLEqual:diff boolean:b with:x leqc:y plus:d];
    [[x tracker] trackObject:o];
    return o;
}

@end
