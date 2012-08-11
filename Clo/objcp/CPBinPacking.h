/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPArray.h>
#import <objcp/CPConstraintI.h>

@interface CPBinPackingI : CPActiveConstraint<CPConstraint,NSCoding> {
}
-(CPBinPackingI*) initCPBinPackingI: (id<CPIntVarArray>) x itemSize: (id<CPIntArray>) itemSize binSize: (id<CPIntArray>) binSize;
-(void) dealloc;
-(ORStatus) post;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
@end

@interface CPOneBinPackingI : CPActiveConstraint<CPConstraint,NSCoding> {
}
-(CPOneBinPackingI*) initCPOneBinPackingI: (id<CPIntVarArray>) x itemSize: (id<CPIntArray>) itemSize bin: (CPInt) b binSize: (id<ORIntVar>) binSize;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
@end
