/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>
#import "CPActivity.h"


    // Single precedence propagator
    //
@interface CPPrecedence : CPCoreConstraint<NSCoding> {
    id<CPOptionalActivity> _before; // Optional activity
    id<CPOptionalActivity> _after;  // Optional activity
}

-(id) initCPPrecedence: (id<CPOptionalActivity>) before after: (id<CPOptionalActivity>) after;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end
