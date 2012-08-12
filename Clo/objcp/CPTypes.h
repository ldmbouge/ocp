/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#ifndef __CPTYPES_H
#define __CPTYPES_H

#import <ORFoundation/ORFoundation.h>

typedef enum {
   DomainConsistency,
   RangeConsistency,
   ValueConsistency
} CPConsistency;

@protocol CPSolver;

typedef void (^CPVirtualClosure)(id<CPSolver>);


#endif