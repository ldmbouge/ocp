/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <objcp/CPError.h>

@interface CPTrailIntSet : ORObject<ORIntSet>

-(id)initWithSet:(id<ORIntSet>)theSource trail:(id<ORTrail>)t;

@end
