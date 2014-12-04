/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORTask.h>
#import <ORScheduler/ORSchedConstraint.h>

@interface ORVisitor (ORScheduler)
-(void) visitAlternativeTask: (id<ORAlternativeTask> ) task;
-(void) visitSpanTask: (id<ORSpanTask> ) task;
-(void) visitResourceTask: (id<ORResourceTask>) task;
-(void) visitTask: (id<ORTaskVar> ) task;
-(void) visitTaskPrecedes:  (id<ORTaskPrecedes> ) cstr;
-(void) visitTaskDuration:  (id<ORTaskDuration> ) cstr;
-(void) visitTaskIsFinishedBy:  (id<ORTaskIsFinishedBy> ) cstr;
-(void) visitTaskAddTransitionTime:  (id<ORTaskAddTransitionTime>) cstr;
-(void) visitSumTransitionTimes:  (id<ORSumTransitionTimes>) cstr;
-(void) visitCumulative:  (id<ORCumulative> ) cstr;
-(void) visitTaskCumulative:  (id<ORTaskCumulative> ) cstr;
-(void) visitTaskDisjunctive:  (id<ORTaskDisjunctive> ) cstr;
-(void) visitDifference:  (id<ORDifference> ) cstr;
-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr;
-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr;
-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr;
@end;

@interface ORNOopVisit (ORScheduler)
-(void) visitAlternativeTask: (id<ORAlternativeTask> ) task;
-(void) visitSpanTask: (id<ORSpanTask> ) task;
-(void) visitResourceTask: (id<ORResourceTask>) task;
-(void) visitTask: (id<ORTaskVar> ) task;
-(void) visitTaskPrecedes:  (id<ORTaskPrecedes> ) cstr;
-(void) visitTaskDuration:  (id<ORTaskDuration> ) cstr;
-(void) visitTaskIsFinishedBy:  (id<ORTaskIsFinishedBy> ) cstr;
-(void) visitTaskAddTransitionTime:  (id<ORTaskAddTransitionTime>) cstr;
-(void) visitSumTransitionTimes:  (id<ORSumTransitionTimes>) cstr;
-(void) visitCumulative:  (id<ORCumulative> ) cstr;
-(void) visitTaskCumulative:  (id<ORTaskCumulative> ) cstr;
-(void) visitTaskDisjunctive:  (id<ORTaskDisjunctive> ) cstr;
-(void) visitDifference:  (id<ORDifference> ) cstr;
-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr;
-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr;
-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr;
@end;
