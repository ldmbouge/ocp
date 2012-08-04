/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPArray.h>
#import <objcp/CPConstraintI.h>

@interface CPCircuitI : CPActiveConstraint<CPConstraint,NSCoding>
-(CPCircuitI*) initCPCircuitI: (id<CPIntVarArray>) x;
-(CPCircuitI*) initCPNoCycleI: (id<CPIntVarArray>) x;
-(void) dealloc;
-(ORStatus) post;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;

static ORStatus assign(CPCircuitI* cstr,int i);
@end

