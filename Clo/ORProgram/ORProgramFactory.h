/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/CPProgram.h>
#import <ORProgram/LPProgram.h>
#import <ORProgram/MIPProgram.h>

@interface ORFactory (Concretization)
+(id<CPProgram>)concretizeCP:(id<ORModel>)m;
+(id<CPProgram>) createCPProgram: (id<ORModel>) model;
+(id<CPProgram>) createCPSemanticProgramDFS: (id<ORModel>) model;
+(id<CPProgram>) createCPSemanticProgram: (id<ORModel>) model with: (Class) ctrlClass;
+(id<CPProgram>) createCPMultiStartProgram: (id<ORModel>) model nb: (ORInt) k;
+(id<CPProgram>) createCPParProgram:(id<ORModel>) model nb:(ORInt) k with: (Class) ctrlClass;
+(id<LPProgram>) createLPProgram: (id<ORModel>) model;
+(id<MIPProgram>) createMIPProgram: (id<ORModel>) model;
@end
