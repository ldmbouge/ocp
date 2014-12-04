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
#import <ORScheduler/ORTaskI.h>
#import <ORScheduler/ORActivity.h>
#import <ORProgram/CPConcretizer.h>
#import "CPScheduler/CPFactory.h"
#import "CPSCheduler/CPDifference.h"
#import "CPTask.h"
#import "CPTaskI.h"

@implementation ORCPConcretizer (CPScheduler)

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

// Difference logic constraint
-(void) visitDifference:(id<ORDifference>) cstr
{
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
-(void) visitTask:(id<ORTaskVar>) task
{
    assert([task isMemberOfClass:[ORTaskVar class]]);
    if (_gamma[task.getId] == NULL) {
        id<ORIntRange> horizon = [task horizon];
        id<ORIntRange> duration = [task duration];
        id<ORIntVar>   presence = [(ORTaskVar *)task presenceVar];
        
        id<CPTaskVar> concreteTask;
        if (![task isOptional])
            concreteTask = [CPFactory task: _engine horizon: horizon duration: duration];
        else
            concreteTask = [CPFactory optionalTask: _engine horizon: horizon duration: duration];
        _gamma[task.getId] = concreteTask;
        
        // Posting presence constraint
        if (presence != NULL) {
            [presence visit:self];
            [_engine add:[CPFactory constraint:concreteTask presence:_gamma[presence.getId]]];
        }
    }
}

// Alternative Task
-(void) visitAlternativeTask:(id<ORAlternativeTask>) task
{
    if (_gamma[task.getId] == NULL) {
        id<ORIntRange> horizon  = [task horizon];
        id<ORIntRange> duration = [task duration];
        id<ORTaskVarArray> alt  = [task alternatives];
        id<ORIntVar>   presence = [(ORAlternativeTask *)task presenceVar];
        
        [alt visit: self];
        
        // Create of a task composed by alternative tasks
        id<CPAlternativeTask> concreteTask;
        if (![task isOptional]) {
            concreteTask = [CPFactory task: _engine horizon: horizon duration: duration withAlternatives:_gamma[alt.getId]];
        }
        else {
            concreteTask = [CPFactory optionalTask: _engine horizon: horizon duration: duration withAlternatives:_gamma[alt.getId]];
        }
        
        // Create and post the alternative constraint
        id<CPConstraint> concreteCstr;
        concreteCstr = [CPFactory constraint: concreteTask alternatives:_gamma[alt.getId]];
        [_engine add: concreteCstr];

        // Posting presence constraint
        if (presence != NULL) {
            [presence visit:self];
            [_engine add:[CPFactory constraint:concreteTask presence:_gamma[presence.getId]]];
        }
        
        _gamma[task.getId] = concreteTask;
    }
}
// Span Task
-(void) visitSpanTask:(id<ORSpanTask>) task
{
    if (_gamma[task.getId] == NULL) {
        id<ORIntRange> horizon  = [task horizon];
        id<ORIntRange> duration = [task duration];
        id<ORTaskVarArray> compound = [task compound];
        id<ORIntVar>   presence = [(ORSpanTask *)task presenceVar];
        
        [compound visit: self];
        
        // Create of a task composed by alternative tasks
        id<CPSpanTask> concreteTask;
        if (![task isOptional]) {
            concreteTask = [CPFactory task: _engine horizon: horizon duration: duration withSpans:_gamma[compound.getId]];
        }
        else {
            concreteTask = [CPFactory optionalTask: _engine horizon: horizon duration: duration withSpans:_gamma[compound.getId]];
        }
        
        // Create and post the alternative constraint
        id<CPConstraint> concreteCstr;
        concreteCstr = [CPFactory constraint: concreteTask spans:_gamma[compound.getId]];
        [_engine add: concreteCstr];
        
        
        // Posting presence constraint
        if (presence != NULL) {
            [presence visit:self];
            [_engine add:[CPFactory constraint:concreteTask presence:_gamma[presence.getId]]];
        }
        
        _gamma[task.getId] = concreteTask;
    }
}

// Resource Task
-(void) visitResourceTask:(id<ORResourceTask>) task
{
    if (_gamma[task.getId] == NULL) {
        id<ORIntRange> horizon  = [task horizon];
        id<ORIntRange> duration = [task duration];
        id<ORIntArray> durationArray = [task durationArray];
        id<ORResourceArray> res = [task resources];
        id<ORIntVar>   presence = [(ORResourceTask *)task presenceVar];
        
        assert(![task isOptional]);
        
        // TODO Here it needs to be decided whether to generate one machine task or alternative task with m optional tasks
        // For the time being only machine tasks are created
        
        id<CPResourceTask> concreteTask;
        
        id<CPResourceArray> emptyRes;
        emptyRes = [CPFactory resourceArray:_engine range:[res range] with:^id<CPConstraint>(ORInt k) {
            return NULL;
        }];
        if (![task isOptional])
            concreteTask = [CPFactory taskRT:_engine horizon:horizon duration:duration durationArray:durationArray runsOnOneOf:emptyRes];
        else
            concreteTask = [CPFactory optionalTaskRT:_engine horizon:horizon duration:duration durationArray:durationArray runsOnOneOf:emptyRes];
        
        // Posting presence constraint
        if (presence != NULL) {
            [presence visit:self];
            [_engine add:[CPFactory constraint:concreteTask presence:_gamma[presence.getId]]];
        }
        
        _gamma[task.getId] = concreteTask;
    }
}

// Precedence constraint
-(void) visitTaskPrecedes:(id<ORTaskPrecedes>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORTaskVar> before = [cstr before];
      id<ORTaskVar> after  = [cstr after];
      [before visit: self];
      [after  visit: self];
      id<CPConstraint> concreteCstr;
      if ([before isOptional] || [after isOptional])
         concreteCstr = [CPFactory constraint: _gamma[before.getId] optionalPrecedes: _gamma[after.getId]];
      else
         concreteCstr = [CPFactory constraint: _gamma[before.getId] precedes: _gamma[after.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

// Duration constraint
-(void) visitTaskDuration:(id<ORTaskDuration>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORTaskVar> task = [cstr task];
      id<ORIntVar> duration  = [cstr duration];
      [task visit: self];
      [duration  visit: self];
      id<CPConstraint> concreteCstr;
      concreteCstr = [CPFactory constraint: _gamma[task.getId] duration: _gamma[duration.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitTaskAddTransitionTime:(id<ORTaskAddTransitionTime>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORTaskVar> normal = [cstr normal];
      id<ORTaskVar> extended = [cstr extended];
      id<ORIntVar> time  = [cstr time];
      [normal visit: self];
      [extended visit: self];
      [time visit: self];
      id<CPConstraint> concreteCstr;
      concreteCstr = [CPFactory constraint: _gamma[normal.getId] extended: _gamma[extended.getId] time: _gamma[time.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
// Disjunctive (resource) constraint
-(void) visitTaskDisjunctive:(id<ORTaskDisjunctive>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORTaskVarArray> tasks = [cstr taskVars];
        id<ORTaskVarArray> transitionTasks = [cstr transitionTaskVars];
        id<ORIntVarArray> succ = [cstr successors];
        [tasks visit: self];
        [transitionTasks visit: self];
        [succ visit: self];
        id<CPConstraint> concreteCstr;
        // NOTE the task sequence propagator for optional or machine tasks
        // haven't been implemented yet. Once it is then the
        // following check can be removed.
        ORBool hasOptionalTasks = false;
        for (ORInt i = tasks.low; i <= tasks.up; i++) {
            if ([tasks[i] isOptional] || [tasks[i] isMemberOfClass:[ORResourceTask class]]) {
                hasOptionalTasks = true;
                break;
            }
        }
        if (!hasOptionalTasks) {
            if ([cstr hasTransition])
                concreteCstr = [CPFactory taskSequence: _gamma[transitionTasks.getId] successors: _gamma[succ.getId]];
            else
                concreteCstr = [CPFactory taskSequence: _gamma[tasks.getId] successors: _gamma[succ.getId]];
            [_engine add: concreteCstr];
        }
        if ([cstr hasTransition])
            concreteCstr = [CPFactory taskDisjunctive: _gamma[transitionTasks.getId]];
        else
            concreteCstr = [CPFactory taskDisjunctive: _gamma[tasks.getId]];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
        
        // Check for resource tasks and set the concrete disjunctive constraint
        for (ORInt i = tasks.low; i <= tasks.up; i++) {
            if ([tasks[i] isMemberOfClass:[ORResourceTask class]]) {
                id<ORResourceTask> t = (id<ORResourceTask>) tasks[i];
                assert(_gamma[t.getId] != NULL);
                ORInt idx = [t getIndex:cstr];
                assert([t resources].low <= idx && idx <= [t resources].up);
                id<CPResourceTask> concreteT = _gamma[t.getId];
                [concreteT set:concreteCstr at:idx];
            }
        }
    }
}

// Cumulative (resource) constraint
-(void) visitTaskCumulative:(id<ORTaskCumulative>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORTaskVarArray> tasks    = [cstr taskVars];
        id<ORIntVarArray>  usages   = [cstr usages  ];
        id<ORIntVar>       capacity = [cstr capacity];
        [tasks    visit: self];
        [usages   visit: self];
        [capacity visit: self];
        id<CPConstraint> concreteCstr;
        concreteCstr = [CPFactory taskCumulative: _gamma[tasks.getId] with:_gamma[usages.getId] and:_gamma[capacity.getId]];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}

-(void) visitTaskIsFinishedBy:(id<ORTaskIsFinishedBy>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORTaskVar> task = [cstr task];
      id<ORIntVar> date  = [cstr date];
      [task visit: self];
      [date  visit: self];
      id<CPConstraint> concreteCstr = [CPFactory constraint: _gamma[task.getId] isFinishedBy: _gamma[date.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitSumTransitionTimes:(id<ORSumTransitionTimes>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORTaskDisjunctive> disjunctive = [cstr disjunctive];
      id<ORIntVar> ub = [cstr ub];
      [disjunctive visit: self];
      [ub visit: self];
      id<ORIntVarArray> successors = [disjunctive successors];
      id<ORIntMatrix> matrix = [disjunctive extendedTransitionMatrix];
      id<CPConstraint> concreteCstr;
      concreteCstr = [CPFactory assignment: _engine
                                     array: _gamma[successors.getId]
                                    matrix: matrix
                                      cost: _gamma[ub.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}


@end;
