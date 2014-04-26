/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPConstraint.h>
#import <ORScheduler/ORScheduler.h>
#import <ORProgram/CPConcretizer.h>
#import "CPScheduler/CPFactory.h"
#import "CPSCheduler/CPActivity.h"
#import "CPSCheduler/CPDifference.h"

@implementation ORCPConcretizer (CPScheduler)

// Cumulative (resource) constraint
-(void) visitActivity:(id<ORActivity>) act
{
   if (_gamma[act.getId] == NULL) {
      id<ORIntVar> start = [act start];
      id<ORIntVar> duration = [act duration];
      id<ORIntVar> end = [act end];
      id<ORTracker> tracker = [start tracker];
      
      [start visit: self];
      [duration visit: self];
      id<CPIntVar> concreteEnd;
      if (duration.min == duration.max) {
         concreteEnd = [CPFactory intVar: _gamma[start.getId] shift: duration.min];
      }
      else {
         concreteEnd = [CPFactory intVar: _engine domain: RANGE(_engine,start.min + duration.min,start.max + duration.max)];
         _gamma[end.getId] = concreteEnd;
         id<CPIntVarArray> av = [CPFactory intVarArray: _engine range: RANGE(tracker,0,2) with: ^id<CPIntVar>(ORInt k) {
            if (k == 0)
               return _gamma[start.getId];
            else if (k == 1)
               return _gamma[duration.getId];
            else
               return [CPFactory intVar: concreteEnd scale: -1];
         }];
         id<CPConstraint> cstr = [CPFactory sum: av eq: 0 annotation: RangeConsistency];
         [_engine add: cstr];
      }
       _gamma[end.getId] = concreteEnd;
      id<CPActivity> concreteAct = [CPFactory activity: _gamma[start.getId] duration:  _gamma[duration.getId] end: concreteEnd];
      _gamma[act.getId] = concreteAct;
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
      id<ORActivity> after = [cstr after];
      [before visit: self];
      [after visit: self];
      id<CPConstraint> concreteCstr = [CPFactory precedence: _gamma[before.getId] precedes: _gamma[after.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

// Disjunctive (resource) constraint
-(void) visitDisjunctive:(id<ORDisjunctive>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVarArray> start = [cstr start];
        id<ORIntVarArray> duration = [cstr duration];
        [start visit: self];
        [duration visit: self];
        id<CPConstraint> concreteCstr = [CPFactory disjunctive: _gamma[start.getId] duration: _gamma[duration.getId]];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}

// Disjunctive (resource) constraint
-(void) visitSchedulingDisjunctive:(id<ORSchedulingDisjunctive>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORActivityArray> activities = [cstr activities];
      [activities visit: self];
      id<CPConstraint> concreteCstr = [CPFactory disjunctive: _gamma[activities.getId]];
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
@end;
