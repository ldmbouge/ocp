/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>

@implementation ORVisitor (ORScheduler)
-(void) visitPrecedes: (id<ORPrecedes>) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "precedes: visit method not defined"];
}
-(void) visitTaskPrecedes: (id<ORPrecedes>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "taskPrecedes: visit method not defined"];
}
-(void) visitTaskAddTransitionTime:  (id<ORTaskAddTransitionTime>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "taskAddTransitionTime: visit method not defined"];
}
-(void) visitSumTransitionTimes:  (id<ORSumTransitionTimes>) cstr;
{
   @throw [[ORExecutionError alloc] initORExecutionError: "sumTransitionTimes: visit method not defined"];
}
-(void) visitTaskIsFinishedBy:  (id<ORTaskIsFinishedBy> ) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "taskIsFinishedBy: visit method not defined"];
}
-(void) visitTaskCumulative: (id<ORTaskCumulative>) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "disjunctive: visit method not defined"];
}
-(void) visitTaskDisjunctive: (id<ORTaskDisjunctive>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "disjunctive: visit method not defined"];
}
-(void) visitCumulative: (id<ORCumulative>) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "cumulative: visit method not defined"];
}
-(void) visitDifference: (id<ORDifference>) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "difference: visit method not defined"];
}
-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "diffLEqual: visit method not defined"];
}
-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "diffReifyLEqual: visit method not defined"];
}
-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "diffImplyLEqual: visit method not defined"];
}
@end

@implementation ORNOopVisit (ORScheduler)
-(void) visitTaskIsFinishedBy:  (id<ORTaskIsFinishedBy> ) cstr
{
  
}
-(void) visitTaskCumlative: (id<ORTaskCumulative>) cstr
{
    
}
-(void) visitTaskDisjunctive: (id<ORTaskDisjunctive>) cstr
{
   
}
-(void) visitTaskPrecedes: (id<ORPrecedes>) cstr
{

}
-(void) visitTaskAddTransitionTime:  (id<ORTaskAddTransitionTime>) cstr
{
   
}
-(void) visitSumTransitionTimes:  (id<ORSumTransitionTimes>) cstr
{
   
}
-(void) visitCumulative: (id<ORCumulative>) cstr
{
    
}
-(void) visitDifference: (id<ORDifference>) cstr
{
    
}
-(void) visitDiffLEqual:  (id<ORDiffLEqual> ) cstr
{
    
}
-(void) visitDiffReifyLEqual:  (id<ORDiffReifyLEqual> ) cstr
{
    
}
-(void) visitDiffImplyLEqual:  (id<ORDiffImplyLEqual> ) cstr
{
    
}
@end
