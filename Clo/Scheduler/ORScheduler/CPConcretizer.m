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
   if (_gamma[task.getId] == NULL) {
      id<ORIntRange> horizon = [task horizon];
      id<ORIntRange> duration = [task duration];
      
      id<CPTaskVar> concreteTask;
      if (![task isOptional])
         concreteTask = [CPFactory task: _engine horizon: horizon duration: duration];
      else
         concreteTask = [CPFactory optionalTask: _engine horizon: horizon duration: duration];
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
      if ([cstr hasTransition])
         concreteCstr = [CPFactory taskSequence: _gamma[transitionTasks.getId] successors: _gamma[succ.getId]];
      else
         concreteCstr = [CPFactory taskSequence: _gamma[tasks.getId] successors: _gamma[succ.getId]];
      [_engine add: concreteCstr];
      if ([cstr hasTransition])
         concreteCstr = [CPFactory taskDisjunctive: _gamma[transitionTasks.getId]];
      else
         concreteCstr = [CPFactory taskDisjunctive: _gamma[tasks.getId]];
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
