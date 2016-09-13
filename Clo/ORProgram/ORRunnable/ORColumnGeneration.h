/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORRunnablePiping.h>
#import <ORProgram/LPProgram.h>

typedef id<ORRunnable> (^ORDoubleArray2Runnable)(id<ORDoubleArray>);
typedef id<LPColumn> (^Void2Column)();

@interface ORColumnGeneration : ORPipedRunnable<ORColumnConsumer>
-(id) initWithMaster: (id<ORRunnable>)master slave: (Void2Column)slaveBlock;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
@end

@interface ORFactory(ORColumnGeneration)
+(id<ORRunnable>) columnGeneration: (id<ORRunnable>)master slave: (Void2Column)slaveBlock;
+(id<LPColumn>) column: (id<LPProgram>)lp solution: (id<ORSolution>)sol array: (id<ORIntVarArray>)arr constraints: (id<ORGroup>)cstrs;
@end
