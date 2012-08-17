/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPCreateI.h"
#import "CPSolverI.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPAllDifferentDC.h"
#import "CPBasicConstraint.h"
#import "CPCardinality.h"

@implementation CPSolverI (Create)
+(CPSolverI*) create
{
    return [[CPSolverI alloc] init];
}
+(CPSolverI*) createRandomized
{
    [ORStreamManager setRandomized];
    return [[CPSolverI alloc] init];
}
+(CPSolverI*) createDeterministic
{
    return [[CPSolverI alloc] init];
}

+(CPSolverI*) createFor:(CPEngineI*)fdm
{
   return [[CPSolverI alloc] initFor:fdm];
}
@end

@implementation CPSemSolverI(Create)
+(CPSemSolverI*) create
{
   return [[CPSemSolverI alloc] init];
}
+(CPSemSolverI*) createRandomized
{
   [ORStreamManager setRandomized];
   return [[CPSemSolverI alloc] init];
}
+(CPSemSolverI*) createDeterministic
{
   return [[CPSemSolverI alloc] init];
}

+(CPSemSolverI*) createFor:(CPEngineI*)fdm
{
   return [[CPSemSolverI alloc] initFor:fdm];
}
@end

@implementation CPParSolverI (Create)
+(CPParSolverI*)            create:(int)nbt
{
   return [[CPParSolverI alloc] initForWorkers:nbt];
}
@end