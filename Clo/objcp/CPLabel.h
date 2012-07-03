/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "CP.h"
#import <objcp/CPHeuristic.h>

@interface CPLabel : NSObject
+(void) var: (id<CPIntVar>) x;
+(void) array: (id<CPIntVarArray>) x;
+(void) array: (id<CPIntVarArray>) x orderedBy: (CPInt2Int) orderedBy;
+(void) heuristic:(id<CPHeuristic>)h;
@end;

