/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPConstraint.h>
#import <ORScheduler/ORScheduler.h>
#import <ORScheduler/ORActivity.h>
#import <ORProgram/CPConcretizer.h>
#import "CPScheduler/CPFactory.h"
#import "CPSCheduler/CPActivity.h"
#import "CPSCheduler/CPDifference.h"
#import "CPTask.h"
#import "CPTaskI.h"

@implementation ORCPConcretizer (CPScheduler)

// Activity
-(void) visitActivity:(id<ORActivity>) act
{
    // NOTE that the information about compositional activities get lost during the concretization
    if (_gamma[act.getId] == NULL) {
        id<ORIntVar> startLB  = [act startLB ];
        id<ORIntVar> startUB  = [act startUB ];
        id<ORIntVar> duration = [act duration];
        id<ORIntVar> top      = [act top     ];
        ORInt        type     = [act type    ];
        [startLB  visit: self];
        [duration visit: self];
        
        id<CPActivity> concreteAct;
        
        if (act.isOptional == TRUE) {
            [startUB visit: self];
            [top     visit: self];
            
            [_engine add: [CPFactory reify:_gamma[top.getId] with:_gamma[startLB.getId] eq:_gamma[startUB.getId] annotation:Default]];
            [_engine add: [CPFactory reify:_gamma[top.getId] with:_gamma[startLB.getId] leqi:[act startRange].up ]];
            [_engine add: [CPFactory reify:_gamma[top.getId] with:_gamma[startUB.getId] geqi:[act startRange].low]];
            
            concreteAct = [CPFactory optionalActivity:_gamma[top.getId] startLB:_gamma[startLB.getId] startUB:_gamma[startUB.getId] startRange: [act startRange] duration:_gamma[duration.getId]];
        } else {
            concreteAct = [CPFactory activity:_gamma[startLB.getId] duration:_gamma[duration.getId]];
        }
        
        _gamma[act.getId] = concreteAct;

        if (type > 1) {
            // (Optional) alternative or (optional) span
            id<ORActivityArray> comp = [act composition];
            [comp visit: self];
            id<CPActivityArray> cpComp = _gamma[comp.getId];
            if (type == ORALTCOMP) {
                // XXX Temporary the decomposition instead of the "global"
                id<ORIntVar> altIdx = [act alterIdx];
                [altIdx visit:self];
                id<CPIntVar> one = [CPFactory intVar:_engine value:1];
                id<CPIntVarArray> tops      = [CPFactory intVarArray:_engine range:cpComp.range with:^id<CPIntVar>(ORInt k) {return cpComp[k].top;     }];
                id<CPIntVarArray> starts    = [CPFactory intVarArray:_engine range:cpComp.range with:^id<CPIntVar>(ORInt k) {return cpComp[k].startLB; }];
                id<CPIntVarArray> durations = [CPFactory intVarArray:_engine range:cpComp.range with:^id<CPIntVar>(ORInt k) {return cpComp[k].duration;}];
                [_engine add: [CPFactory sumbool:tops eq:1]];
                [_engine add: [CPFactory element:_gamma[altIdx.getId] idxVarArray:tops      equal:one annotation:Default]];
                [_engine add: [CPFactory element:_gamma[altIdx.getId] idxVarArray:starts    equal:_gamma[startLB.getId ] annotation:Default]];
                [_engine add: [CPFactory element:_gamma[altIdx.getId] idxVarArray:durations equal:_gamma[duration.getId] annotation:Default]];
            }
//            if (type == ORALTCOMP || type == ORALTOPT)
//                [_engine add: [CPFactory alternative:_gamma[act.getId] composedBy:_gamma[comp.getId]]];
            else
                assert(false);
        }
    }
}

-(void) visitDisjunctiveResource:(id<ORDisjunctiveResource>) dr
{
   if (_gamma[dr.getId] == NULL) {
      id<ORActivityArray> act = [dr activities];
      [act visit: self];
       id<CPDisjunctiveResource> concreteDr = [CPFactory disjunctiveResource: _engine activities: _gamma[dr.getId]];
      _gamma[dr.getId] = concreteDr;
   }
}


// Cumulative (resource) constraint
-(void) visitCumulative:(id<ORCumulative>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVarArray> start = [cstr start];
        id<ORIntVarArray> duration = [cstr duration];
        id<ORIntArray> usage = [cstr usage];
        id<ORIntVar> capacity = [cstr capacity];
        [start visit: self];
        [duration visit: self];
        [usage visit: self];
        [capacity visit: self];
        id<CPConstraint> concreteCstr = [CPFactory cumulative: _gamma[start.getId] duration: _gamma[duration.getId] usage:usage capacity: _gamma[capacity.getId]];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}

// Cumulative (resource) constraint
-(void) visitSchedulingCumulative:(id<ORSchedulingCumulative>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORActivityArray> activities = [cstr activities];
      id<ORIntArray> usage = [cstr usage];
      id<ORIntVar> capacity = [cstr capacity];
      [activities visit: self];
      [usage visit: self];
      [capacity visit: self];
      id<CPConstraint> concreteCstr = [CPFactory cumulative: _gamma[activities.getId] usage:usage capacity: _gamma[capacity.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

// Precedence constraint
-(void) visitPrecedes:(id<ORPrecedes>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORActivity> before = [cstr before];
        id<ORActivity> after  = [cstr after];
        [before visit: self];
        [after  visit: self];
        id<CPConstraint> concreteCstr = [CPFactory precedence: _gamma[before.getId] precedes: _gamma[after.getId]];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}

// Disjunctive (resource) constraint
-(void) visitDisjunctive:(id<ORDisjunctive>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<CPConstraint> concreteCstr;
        if ([cstr act] == NULL) {
            id<ORIntVarArray> start = [cstr start];
            id<ORIntVarArray> duration = [cstr duration];
            
            [start    visit: self];
            [duration visit: self];
            concreteCstr = [CPFactory disjunctive: _gamma[start.getId] duration: _gamma[duration.getId]];
        }
        else {
            id<ORActivityArray> act = [cstr act];
            
            [act visit: self];
            concreteCstr = [CPFactory disjunctive:_gamma[act.getId]];
        }
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}

// Disjunctive (resource) constraint
// TODO Remove this method
-(void) visitSchedulingDisjunctive:(id<ORSchedulingDisjunctive>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORActivityArray> act = [cstr activities];
        [act visit: self];
        id<CPConstraint> concreteCstr = [CPFactory disjunctive:_gamma[act.getId]];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}



// Difference logic constraint
-(void) visitDifference:(id<ORDifference>) cstr
{
    printf("visitDifference");
    if (_gamma[cstr.getId] == NULL) {
        const id<ORTracker> tracker = [cstr tracker];
        const ORInt cap = [cstr initCapacity];
        
        id<CPConstraint> concreteCstr = [CPFactory difference:tracker engine:_engine withInitCapacity:cap];
        
        [_engine add: concreteCstr];
        
        _gamma[cstr.getId] = concreteCstr;
    }
}

// x <= y + d
-(void) visitDiffLEqual:(id<ORDiffLEqual>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> x = [cstr x];
        id<ORIntVar> y = [cstr y];
        ORInt        d = [cstr d];
        id<ORDifference> diffCstr = [cstr diff];
        
        [x visit: self];
        [y visit: self];
        
        if (_gamma[diffCstr.getId] == NULL) {
            [self visitDifference:diffCstr];
        }
        
        CPDifference * cpdiff = (CPDifference *) _gamma[diffCstr.getId];
        
        [cpdiff addDifference:_gamma[x.getId] minus:_gamma[y.getId] leq:d];
        
        _gamma[cstr.getId] = _gamma[diffCstr.getId];
    }
}

// b <-> x <= y + d
-(void) visitDiffReifyLEqual:(id<ORDiffReifyLEqual>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORIntVar> x = [cstr x];
        id<ORIntVar> y = [cstr y];
        ORInt        d = [cstr d];
        id<ORDifference> diffCstr = [cstr diff];
        
        [b visit: self];
        [x visit: self];
        [y visit: self];
        
        if (_gamma[diffCstr.getId] == NULL) {
            [self visitDifference:diffCstr];
        }
        
        CPDifference * cpdiff = (CPDifference *) _gamma[diffCstr.getId];
        
        [cpdiff addReifyDifference:_gamma[b.getId] when:_gamma[x.getId] minus:_gamma[y.getId] leq:d];
        
        _gamma[cstr.getId] = _gamma[diffCstr.getId];
    }
}

// b -> x <= y + d
-(void) visitDiffImplyLEqual:(id<ORDiffImplyLEqual>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORIntVar> x = [cstr x];
        id<ORIntVar> y = [cstr y];
        ORInt        d = [cstr d];
        id<ORDifference> diffCstr = [cstr diff];
        
        [b visit: self];
        [x visit: self];
        [y visit: self];
        
        if (_gamma[diffCstr.getId] == NULL) {
            [self visitDifference:diffCstr];
        }
        
        CPDifference * cpdiff = (CPDifference *) _gamma[diffCstr.getId];
        
        [cpdiff addImplyDifference:_gamma[b.getId] when:_gamma[x.getId] minus:_gamma[y.getId] leq:d];
        
        _gamma[cstr.getId] = _gamma[diffCstr.getId];
    }
}

// Task
-(void) visitTask:(id<ORTask>) task
{
   if (_gamma[task.getId] == NULL) {
      id<ORIntRange> horizon = [task horizon];
      id<ORIntRange> duration = [task duration];
      
      id<CPTask> concreteTask;
      
      if (duration.low == duration.up) {
         concreteTask = [CPFactory task: _engine horizon: horizon duration: duration.low];
      }
      else {
         // pvh to fill
         assert(false);
      }
      _gamma[task.getId] = concreteTask;
   }
}


@end;
