/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPI.h"
#import "CPArrayI.h"
#import "CPConstraintI.h"
#import "ORTrail.h"

@class CPIntVarArrayI;

@interface CPI (Create)  
+(CPI*) create;
+(CPI*) createRandomized;
+(CPI*) createDeterministic;
+(CPI*) createFor:(CPSolverI*)fdm;
@end

@interface SemCP (Create)
+(SemCP*)            create;
+(SemCP*)            createRandomized;
+(SemCP*)            createDeterministic;
+(SemCP*)            createFor:(CPSolverI*)fdm;
@end

