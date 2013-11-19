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
#import <objcp/CPVar.h>

@interface CPOneBinPackingI : CPCoreConstraint<CPConstraint> {
}
-(CPOneBinPackingI*) initCPOneBinPackingI: (id<CPIntVarArray>) x itemSize: (id<ORIntArray>) itemSize
                                      bin: (ORInt) b
                                  binSize: (id<CPIntVar>) binSize;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
@end
