/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORConstraint.h>


@interface ORDisjunctive : ORConstraintI<ORDisjunctive>
-(id<ORDisjunctive>) initORDisjunctive: (id<ORIntVar>) x duration: (ORInt) dx start: (id<ORIntVar>) y duration: (ORInt) dy;
-(id<ORIntVar>) x;
-(ORInt) dx;
-(id<ORIntVar>) y;
-(ORInt) dy;
@end