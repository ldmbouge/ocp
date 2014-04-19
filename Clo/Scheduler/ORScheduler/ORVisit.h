/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>

@interface ORVisitor (ORScheduler)
-(void) visitActivity: (id<ORActivity> ) activity;
-(void) visitCumulative:  (id<ORCumulative> ) cstr;
-(void) visitDisjunctive: (id<ORDisjunctive>) cstr;
-(void) visitDifference:  (id<ORDifference> ) cstr;
-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr;
-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr;
-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr;
@end;

@interface ORNOopVisit (ORScheduler)
-(void) visitActivity: (id<ORActivity> ) activity;
-(void) visitCumulative:  (id<ORCumulative> ) cstr;
-(void) visitDisjunctive: (id<ORDisjunctive>) cstr;
-(void) visitDifference:  (id<ORDifference> ) cstr;
-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr;
-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr;
-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr;
@end;
