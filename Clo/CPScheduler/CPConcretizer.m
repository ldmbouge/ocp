/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORScheduler/ORScheduler.h>
#import <ORProgram/CPConcretizer.h>
#import "CPFactory.h"

@implementation ORCPConcretizer (CPScheduler)
-(void) visitDisjunctive: (id<ORDisjunctive>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> x = [cstr x];
      ORInt dx = [cstr dx];
      id<ORIntVar> y = [cstr y];
      ORInt dy = [cstr dy];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory disjunctive: (id<CPIntVar>) _gamma[x.getId] duration: dx start: (id<CPIntVar>) _gamma[y.getId] duration: dy];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
@end;
