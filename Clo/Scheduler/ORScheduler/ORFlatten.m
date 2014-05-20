/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORFlatten.h>
#import "ORConstraintI.h"

@implementation ORFlatten (ORScheduler)
//-(void) visitPrecedes:(id<ORPrecedes>) cstr
//{
//   _result = [_into addConstraint:cstr];
//}
-(void) visitOptionalPrecedes:(id<OROptionalPrecedes>) cstr
{
    _result = [_into addConstraint:cstr];
}
-(void) visitCumulative:(id<ORCumulative>) cstr
{
    _result = [_into addConstraint:cstr];
}
-(void) visitSchedulingCumulative:(id<ORSchedulingCumulative>) cstr
{
   _result = [_into addConstraint:cstr];
}
-(void) visitDisjunctive:(id<ORDisjunctive>) cstr
{
    _result = [_into addConstraint:cstr];
}
-(void) visitSchedulingDisjunctive:(id<ORSchedulingDisjunctive>) cstr
{
   _result = [_into addConstraint:cstr];
}
-(void) visitDifference:(id<ORDifference>) cstr
{
    _result = [_into addConstraint:cstr];
}
-(void) visitDiffLEqual:(id<ORDiffLEqual>) cstr
{
    _result = [_into addConstraint:cstr];
}
-(void) visitDiffReifyLEqual:(id<ORDiffReifyLEqual>) cstr
{
    _result = [_into addConstraint:cstr];
}
-(void) visitDiffImplyLEqual:(id<ORDiffImplyLEqual>) cstr
{
    _result = [_into addConstraint:cstr];
}
@end;
