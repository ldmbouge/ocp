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

typedef id<ORDoubleArray> (^DoubleArray2DoubleArray)(id<ORDoubleArray>);

@interface ORColumnGeneration : ORPipedRunnable<ORColumnConsumer>
-(id) initWithMaster: (id<ORRunnable>)master slave: (DoubleArray2DoubleArray)slaveBlock;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
@end

@interface ORFactory(ORColumnGeneration)
+(id<ORRunnable>) columnGeneration: (id<ORRunnable>)master slave: (DoubleArray2DoubleArray)slaveBlock;
@end
