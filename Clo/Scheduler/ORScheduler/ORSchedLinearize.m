/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORScheduler/ORSchedLinearize.h>
#import <ORModeling/ORLinearize.h>
#import <ORFoundation/ORSetI.h>
#import "ORModelI.h"
#import "ORExprI.h"
#import <ORFoundation/ORVisit.h>

@interface ORLinearizeSchedConstraint : ORLinearizeConstraint
-(id)init:(id<ORAddToModel>)m;
-(void) noOverlap: (id<ORTaskVar>) t0 with: (id<ORTaskVar>) t1;
@end

// Time Indexed linearization
@interface ORLinearizeSchedConstraintTI : ORLinearizeConstraint
-(id)init:(id<ORAddToModel>)m taskMapping: (NSMapTable*)taskMapping resourceMapping: (NSMapTable*)resMapping
indexVars: (id<ORIntVar>***)y horizon: (ORInt)horizon;
@end

@implementation ORFactory (SchedLinearize)
+(id<ORModel>) linearizeSchedulingModel: (id<ORModel>)m
                               encoding: (MIPSchedEncoding)enc
{
   id<ORModel> lm = [ORFactory createModel: [m nbObjects] mappings:nil];
   ORBatchModel* batch = [[ORBatchModel alloc] init: lm source: m annotation:nil]; //TOFIX
   
   // Choose the correct linearizer
   id<ORModelTransformation> linearizer;
   if(enc == MIPSchedTimeIndexed)
      linearizer = [[ORLinearizeSchedulingTI alloc] initORLinearizeSched: batch];
   else linearizer = [[ORLinearizeScheduling alloc] initORLinearizeSched:batch];
   
   [linearizer apply: m with:nil]; // TOFIX
   [batch release];
   [linearizer release];
   return lm;
}
@end


// Standard Scheduling
@implementation ORLinearizeSchedConstraint {
}
-(id) init:(id<ORAddToModel>)m {
   self = [super init: m];
   if(self) {
   }
   return self;
}

-(void) noOverlap: (id<ORTaskVar>) t0 with: (id<ORTaskVar>) t1 {
   id<ORIntVar> sx0 = [t0 getStartVar];
   id<ORIntVar> sx1 = [t1 getStartVar];
   ORInt d0 = [[t0 duration] up];
   ORInt d1 = [[t1 duration] up];
   
   ORInt M = 99999;
   id<ORIntVar> z = [ORFactory intVar: _model domain: RANGE(_model, 0, 1)];
   [_model addConstraint: [[sx0 plus: @(d0)] leq: [sx1 plus: [z mul: @(M)]]]];
   [_model addConstraint: [[sx1 plus: @(d1)] leq: [sx0 plus: [[@(1) sub: z] mul: @(M)]]]];
}

//-(void) visitPrecedes: (id<ORPrecedes>) cstr
//{
//}
-(void) visitTaskPrecedes: (id<ORPrecedes>) cstr
{
   id<ORTaskPrecedes> precedesCstr = (id<ORTaskPrecedes>)cstr;
   id<ORIntVar> sx0 = [[precedesCstr before] getStartVar];
   ORInt d0 = [[[precedesCstr before] duration] up];
   id<ORIntVar> sx1 = [[precedesCstr after] getStartVar];
   [_model addConstraint: [[sx0 plus: @(d0)] leq: sx1]];
}
//-(void) visitTaskDuration: (id<ORTaskDuration>) cstr
//{
//}
//-(void) visitTaskAddTransitionTime:  (id<ORTaskAddTransitionTime>) cstr
//{
//}
//-(void) visitSumTransitionTimes:  (id<ORSumTransitionTimes>) cstr;
//{
//}
-(void) visitTaskIsFinishedBy:  (id<ORTaskIsFinishedBy> ) cstr
{
   id<ORIntVar> sx0 = [[cstr task] getStartVar];
   ORInt duration = [[[cstr task] duration] up];
   [_model addConstraint: [[sx0 plus: @(duration)] leq: [cstr date]]];
}
//-(void) visitTaskCumulative: (id<ORTaskCumulative>) cstr
//{
//}
-(void) visitTaskDisjunctive: (id<ORTaskDisjunctive>) cstr
{
   id<ORTaskVarArray> tasks = [cstr taskVars];
   for(ORInt i = [tasks low]; i < [tasks up]; i++) {
      for(ORInt j = i+1; j <= [tasks up]; j++) {
         id<ORTaskVar> t0 = [tasks objectAtIndexedSubscript: i];
         id<ORTaskVar> t1 = [tasks objectAtIndexedSubscript: j];
         [self noOverlap: t0 with: t1];
      }
   }
}
//-(void) visitSoftTaskDisjunctive:  (id<ORSoftTaskDisjunctive> ) cstr
//{
//}
//-(void) visitCumulative: (id<ORCumulative>) cstr
//{
//}
//-(void) visitDifference: (id<ORDifference>) cstr
//{
//}
//-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr
//{
//}
//-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr
//{
//}
//-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr
//{
//}
@end


@implementation ORLinearizeScheduling {
   id<ORAddToModel> _into;
}
-(id)initORLinearizeSched:(id<ORAddToModel>)into
{
   self = [super init];
   _into = into;
   return self;
}

-(void)apply:(id<ORModel>)m with:(id<ORAnnotation>)notes
{
   NSMapTable* taskVarsMap = [[NSMapTable alloc] init];
   NSMutableArray* taskVars = [[NSMutableArray alloc] init];
   for(id<ORVar> x in [m variables])
      if([x conformsToProtocol: @protocol(ORTaskVar)])
         [taskVars addObject: x];
   for(id<ORTaskVar> x in taskVars)
      [taskVarsMap setObject: [(id<ORTaskVar>)x getStartVar] forKey: x];
   
   ORLinearizeSchedConstraint* lc = [[ORLinearizeSchedConstraint alloc] init: _into];
   [m applyOnVar:^(id<ORVar> x) {
      if(![x conformsToProtocol: @protocol(ORTaskVar)]) {
         [_into addVariable: x];
         //[[[_into modelMappings] tau] set: x forKey: x];
      }
   } onMutables:^(id<ORObject> x) {
      //NSLog(@"Got an object: %@",x);
   } onImmutables:^(id<ORObject> x) {
      //NSLog(@"Got an object: %@",x);
   } onConstraints:^(id<ORConstraint> c) {
      [c visit: lc];
   } onObjective:^(id<ORObjectiveFunction> o) {
      ORLinearizeObjective* lo = [[ORLinearizeObjective alloc] init: _into];
      [o visit: lo];
   }];
   [taskVars release];
   [taskVarsMap release];
   [lc release];
}
@end

// Time Indexed
@implementation ORLinearizeSchedConstraintTI {
   NSMapTable* _taskVarMap;
   NSMapTable* _resMap;
   id<ORIntVar>***   _y;
   ORInt _horizon;
}
-(id)init:(id<ORAddToModel>)m taskMapping: (NSMapTable*)taskMapping resourceMapping: (NSMapTable*)resMapping
indexVars: (id<ORIntVar>***)y horizon: (ORInt)horizon {
   self = [super init: m];
   if(self) {
      _taskVarMap = taskMapping;
      _resMap = resMapping;
      _y = y;
      _horizon = horizon;
   }
   return self;
}
//-(void) visitPrecedes: (id<ORPrecedes>) cstr
//{
//}
-(void) visitTaskPrecedes: (id<ORPrecedes>) cstr
{
   id<ORTaskPrecedes> precedesCstr = (id<ORTaskPrecedes>)cstr;
   ORInt j0 = [[_taskVarMap objectForKey: [precedesCstr before]] intValue];
   ORInt d0 = [[[precedesCstr before] duration] up];
   ORInt j1 = [[_taskVarMap objectForKey: [precedesCstr after]] intValue];
   id<ORIntRange> r1 = RANGE(_model, 0, _horizon);
   for(ORInt k0 = 0; k0 < [_resMap count]; k0++) {
      for(ORInt k1 = 0; k1 < [_resMap count]; k1++) {
         [_model addConstraint:
          [Sum(_model, t, r1, [_y[k0][j0][t] mul: @(t+d0)]) leq:
           Sum(_model, t, r1, [_y[k1][j1][t] mul: @(t)])]];
      }
   }
}
//-(void) visitTaskDuration: (id<ORTaskDuration>) cstr
//{
//}
//-(void) visitTaskAddTransitionTime:  (id<ORTaskAddTransitionTime>) cstr
//{
//}
//-(void) visitSumTransitionTimes:  (id<ORSumTransitionTimes>) cstr;
//{
//}
-(void) visitTaskIsFinishedBy:  (id<ORTaskIsFinishedBy> ) cstr
{
   ORInt j0 = [[_taskVarMap objectForKey: [cstr task]] intValue];
   ORInt d0 = [[[cstr task] duration] up];
   id<ORIntRange> r1 = RANGE(_model, 0, _horizon);
   for(ORInt k = 0; k < [_resMap count]; k++) {
      [_model addConstraint: [Sum(_model, t, r1, [_y[k][j0][t] mul: @(t+d0)]) leq: [cstr date]]];
   }
}
//-(void) visitTaskCumulative: (id<ORTaskCumulative>) cstr
//{
//}
-(void) visitTaskDisjunctive: (id<ORTaskDisjunctive>) cstr
{
   id<ORTaskVarArray> tasks = [cstr taskVars];
   id<ORIntArray> ji = [ORFactory intArray: _model range: [tasks range] value: 0];
   id<ORIdMatrix> T = [ORFactory idMatrix: _model range: [tasks range] : RANGE(_model, 0, _horizon)];
   for(ORInt j = [tasks low]; j <= [tasks up]; j++) {
      id<ORTaskVar> task = [tasks at: j];
      [ji set: [[_taskVarMap objectForKey: task] intValue] at: j];
      for(ORInt t = 0; t <= _horizon; t++) {
         [T set: RANGE(_model, max(0, t - [[task duration] up]+1), t) at: j : t];
      }
   }
   ORInt ki = [[_resMap objectForKey: cstr] intValue];
   for(ORInt t = 0; t <= _horizon; t++) {
      id<ORExpr> sum = Sum(_model, j, [tasks range], Sum(_model, tt, [T at: j:t], _y[ki][[ji at: j]][tt]));
      [_model addConstraint: [sum leq: @(1)]];
   }
}
//-(void) visitSoftTaskDisjunctive:  (id<ORSoftTaskDisjunctive> ) cstr
//{
//}
//-(void) visitCumulative: (id<ORCumulative>) cstr
//{
//}
//-(void) visitDifference: (id<ORDifference>) cstr
//{
//}
//-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr
//{
//}
//-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr
//{
//}
//-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr
//{
//}
@end


@implementation ORLinearizeSchedulingTI {
   id<ORAddToModel> _into;
   NSMapTable* _taskVarMap;
   NSMapTable* _resMap;
   id<ORIntVar>***   _y;
}
-(id)initORLinearizeSched:(id<ORAddToModel>)into
{
   self = [super init];
   _into = into;
   _taskVarMap = [[NSMapTable alloc] init];
   _resMap = [[NSMapTable alloc] init];
   return self;
}
-(ORInt) initializeMapping: (id<ORModel>)m {
   ORInt horizon = 0;
   ORInt taskCount = 0;
   NSMutableArray* tasks = [[NSMutableArray alloc] init];
   for(id<ORVar> x in [m variables]) {
      if([x conformsToProtocol: @protocol(ORTaskVar)]) {
         id<ORTaskVar> task = (id<ORTaskVar>)x;
         if([[task horizon] up] > horizon) horizon = [[task horizon] up];
         ORInt idx = (ORInt)[_taskVarMap count];
         [_taskVarMap setObject: @(idx) forKey: task];
         [tasks addObject: task];
         taskCount++;
      }
   }
   ORInt resCount = 0;
   for(id<ORConstraint> c in [m constraints]) {
      if([c conformsToProtocol: @protocol(ORTaskDisjunctive)]) {
         ORInt idx = (ORInt)[_resMap count];
         [_resMap setObject: @(idx) forKey: c];
         resCount++;
      }
   }
   _y = malloc(resCount * sizeof(id<ORIntVar>));
   for(ORInt k = 0; k < resCount; k++) {
      _y[k] = malloc(taskCount * sizeof(id<ORIntVar>));
      for(ORInt j = 0; j < taskCount; j++) {
         _y[k][j] = malloc((horizon+1) * sizeof(id<ORIntVar>));
         for(ORInt t = 0; t <= horizon; t++) {
            _y[k][j][t] = [ORFactory intVar: _into domain: RANGE(_into, 0, 1)];
         }
      }
   }
   // Add mapping constraints
   for(id<ORTaskVar> task in tasks) {
      ORInt j = [[_taskVarMap objectForKey: task] intValue];
      ORInt release = [[task horizon] low];
      ORInt due = [[task horizon] up];
      ORInt dur = [[task duration] up];
      for(ORInt k = 0; k < resCount; k++) {
         id<ORIntRange> rng = RANGE(_into, release, due - dur);
         [_into addConstraint: [Sum(_into, t, rng, _y[k][j][t]) eq: @(1)]];
      }
   }
   return horizon;
}
-(void)apply:(id<ORModel>)m with:(id<ORAnnotation>)notes
{
   ORInt horizon = [self initializeMapping: m];
   ORLinearizeSchedConstraintTI* lc = [[ORLinearizeSchedConstraintTI alloc] init: _into taskMapping: _taskVarMap resourceMapping: _resMap indexVars: _y horizon: horizon];
   [m applyOnVar:^(id<ORVar> x) {
      if(![x conformsToProtocol: @protocol(ORTaskVar)]) {
         [_into addVariable: x];
      }
   } onMutables:^(id<ORObject> x) {
      //NSLog(@"Got an object: %@",x);
   } onImmutables:^(id<ORObject> x) {
      //NSLog(@"Got an object: %@",x);
   } onConstraints:^(id<ORConstraint> c) {
      [c visit: lc];
   } onObjective:^(id<ORObjectiveFunction> o) {
      ORLinearizeObjective* lo = [[ORLinearizeObjective alloc] init: _into];
      [o visit: lo];
   }];
   [lc release];
}


@end
