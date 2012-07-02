/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPCreateI.h"
#import "CPDataI.h"
#import "CPI.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPAllDifferentDC.h"
#import "CPBasicConstraint.h"
#import "CPCardinality.h"

@implementation CPI (Create)
+(CPI*) create
{
    return [[CPI alloc] init];
}
+(CPI*) createRandomized
{
    [CPStreamManager setRandomized];
    return [[CPI alloc] init];
}
+(CPI*) createDeterministic
{
    return [[CPI alloc] init];
}

+(CPI*) createFor:(CPSolverI*)fdm
{
   return [[CPI alloc] initFor:fdm];
}
@end

@implementation SemCP(Create)
+(SemCP*) create
{
   return [[SemCP alloc] init];
}
+(SemCP*) createRandomized
{
   [CPStreamManager setRandomized];
   return [[SemCP alloc] init];
}
+(SemCP*) createDeterministic
{
   return [[SemCP alloc] init];
}

+(SemCP*) createFor:(CPSolverI*)fdm
{
   return [[SemCP alloc] initFor:fdm];
}
@end


