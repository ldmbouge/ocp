/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORActivity.h>
#import <ORScheduler/ORSchedConstraint.h>

@implementation ORVisitor (ORScheduler)
-(void) visitActivity: (id<ORActivity>) activity
{
   @throw [[ORExecutionError alloc] initORExecutionError: "activity: visit method not defined"];
}
-(void) visitDisjunctiveResource: (id<ORDisjunctiveResource>) dr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "disjunctive resource: visit method not defined"];
}
-(void) visitPrecedes: (id<ORPrecedes>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "precedes: visit method not defined"];
}
-(void) visitDisjunctive: (id<ORDisjunctive>) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "disjunctive: visit method not defined"];
}
-(void) visitCumulative: (id<ORCumulative>) cstr
{
    @throw [[ORExecutionError alloc] initORExecutionError: "cumulative: visit method not defined"];
}
-(void) visitSchedulingCumulative: (id<ORSchedulingCumulative>) cstr
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
-(void) visitActivity: (id<ORActivity>) activity
{
   
}
-(void) visitDisjunctiveResource: (id<ORDisjunctiveResource>) activity
{
   
}
-(void) visitPrecedes: (id<ORPrecedes>) cstr
{
   
}
-(void) visitDisjunctive: (id<ORDisjunctive>) cstr
{
    
}
-(void) visitCumulative: (id<ORCumulative>) cstr
{
    
}
-(void) visitSchedulingCumulative: (id<ORSchedulingCumulative>) cstr
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
