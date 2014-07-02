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
-(void) visitActivity: (id<ORActivity> ) activity;
-(void) visitTask: (id<ORTaskVar> ) task;
-(void) visitDisjunctiveResource: (id<ORDisjunctiveResource> ) dr;
-(void) visitPrecedes:  (id<ORPrecedes> ) cstr;
-(void) visitCumulative:  (id<ORCumulative> ) cstr;
-(void) visitSchedulingCumulative:  (id<ORSchedulingCumulative> ) cstr;
-(void) visitDisjunctive: (id<ORDisjunctive>) cstr;
-(void) visitSchedulingDisjunctive:  (id<ORSchedulingDisjunctive> ) cstr;
-(void) visitDifference:  (id<ORDifference> ) cstr;
-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr;
-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr;
-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr;
@end;

@interface ORNOopVisit (ORScheduler)
-(void) visitActivity: (id<ORActivity> ) activity;
-(void) visitTask: (id<ORTaskVar> ) task;
-(void) visitDisjunctiveResource: (id<ORDisjunctiveResource> ) dr;
-(void) visitPrecedes:  (id<ORPrecedes> ) cstr;
-(void) visitCumulative:  (id<ORCumulative> ) cstr;
-(void) visitSchedulingCumulative:  (id<ORSchedulingCumulative> ) cstr;
-(void) visitDisjunctive: (id<ORDisjunctive>) cstr;
-(void) visitSchedulingDisjunctive:  (id<ORSchedulingDisjunctive> ) cstr;
-(void) visitDifference:  (id<ORDifference> ) cstr;
-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr;
-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr;
-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr;
@end;
