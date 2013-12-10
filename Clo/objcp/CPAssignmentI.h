/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPBasicConstraint.h"

@interface CPAssignment : CPCoreConstraint<CPConstraint>
-(CPAssignment*) initCPAssignment: (id<CPEngine>) engine
                            array: (id<CPIntVarArray>) x
                           matrix: (id<ORIntMatrix>) matrix
                             cost: (id<CPIntVar>) cost;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
