/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>


@interface CPDifference : CPCoreConstraint<NSCoding>
-(id) initCPDifference: (id<CPEngine>) engine withInitCapacity: (ORInt) numItems;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
-(void) addDifference: (id<CPIntVar>) x minus: (id<CPIntVar>) y leq: (ORInt) d;
-(void) addReifyDifference: (id<CPIntVar>) b when: (id<CPIntVar>) x minus: (id<CPIntVar>) y leq: (ORInt) d;
-(void) addImplyDifference: (id<CPIntVar>) b when: (id<CPIntVar>) x minus: (id<CPIntVar>) y leq: (ORInt) d;
@end