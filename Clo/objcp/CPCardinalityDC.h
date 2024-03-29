/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>

@interface CPCardinalityDC : CPCoreConstraint<CPConstraint> 
-(CPCardinalityDC*) initCPCardinalityDC: (id<CPIntVarArray>) x low: (id<ORIntArray>) lb up: (id<ORIntArray>) ub;
-(void) dealloc;
-(void) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end
