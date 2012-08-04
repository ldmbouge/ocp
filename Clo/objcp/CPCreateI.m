/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPCreateI.h"
#import "CPI.h"
#import "CPEngineIm.h"
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
    [ORStreamManager setRandomized];
    return [[CPI alloc] init];
}
+(CPI*) createDeterministic
{
    return [[CPI alloc] init];
}

+(CPI*) createFor:(CPEngineI*)fdm
{
   return [[CPI alloc] initFor:fdm];
}
@end

/*
@implementation SemCP(Create)
+(SemCP*) create
{
   return [[SemCP alloc] init];
}
+(SemCP*) createRandomized
{
   [ORStreamManager setRandomized];
   return [[SemCP alloc] init];
}
+(SemCP*) createDeterministic
{
   return [[SemCP alloc] init];
}

+(SemCP*) createFor:(CPEngineI*)fdm
{
   return [[SemCP alloc] initFor:fdm];
}
@end
*/


