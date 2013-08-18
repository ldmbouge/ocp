/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPFactory.h"
#import "CPConstraint.h"

@implementation CPFactory (CPScheduler)
+(id<CPConstraint>) disjunctive: (id<CPIntVar>) x duration: (ORInt) dx start: (id<CPIntVar>) y duration: (ORInt) dy
{
   id<CPConstraint> o = [[CPDisjunctive alloc] initCPDisjunctive: x duration: dx start: y duration: dy];
   [[x tracker] trackMutable: o];
   return o;
}
@end
