/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPConstraintI.h>

// cardinality(int[] low,var<CP>{int}[] x,int[] up)
@interface CPCardinalityCst : CPCoreConstraint 
-(id) initCardinalityCst:(CPEngineI*) m values:(ORRange)r low:(ORInt*)low array:(id)ax up:(ORInt*)up;
-(id) initCardinalityCst:(id<CPIntVarArray>) ax low: (id<ORIntArray>)low up: (id<ORIntArray>) up;
-(void)dealloc;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

