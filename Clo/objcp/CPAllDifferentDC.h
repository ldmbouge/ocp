/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPBasicConstraint.h>

@interface CPAllDifferentDC : CPCoreConstraint<CPConstraint,NSCoding>
-(CPAllDifferentDC*) initCPAllDifferentDC: (id<ORTracker>) tracker over: (id<CPIntVarArray>) x;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
