/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPSolverI.h"

@interface CPSolverI (Create)  
+(CPSolverI*) create;
+(CPSolverI*) createRandomized;
+(CPSolverI*) createDeterministic;
+(CPSolverI*) createFor:(CPEngineI*)fdm;
@end

@interface CPSemSolverI (Create)
+(CPSemSolverI*)            create;
+(CPSemSolverI*)            createRandomized;
+(CPSemSolverI*)            createDeterministic;
+(CPSemSolverI*)            createFor:(CPEngineI*)fdm;
@end

@interface CPParSolverI (Create)
+(CPParSolverI*)            create:(int)nbt;
@end
