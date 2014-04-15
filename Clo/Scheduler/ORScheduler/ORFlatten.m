/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORFlatten.h>
#import "ORConstraintI.h"

@implementation ORFlatten (ORScheduler)
-(void) visitDisjunctivePair:(id<ORDisjunctivePair>) cstr
{
   _result = cstr;
}
-(void) visitCumulative:(id<ORCumulative>) cstr
{
    _result = cstr;
}
-(void) visitDisjunctive:(id<ORDisjunctive>) cstr
{
    _result = cstr;
}
-(void) visitDifference:(id<ORDifference>) cstr
{
    _result = cstr;
}
-(void) visitDiffLEqual:(id<ORDiffLEqual>) cstr
{
    _result = cstr;
}
-(void) visitDiffReifyLEqual:(id<ORDiffReifyLEqual>) cstr
{
    _result = cstr;
}
-(void) visitDiffImplyLEqual:(id<ORDiffImplyLEqual>) cstr
{
    _result = cstr;
}
@end;
