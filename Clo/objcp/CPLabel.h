/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <objcp/CPSolver.h>
#import <objcp/CPHeuristic.h>
#import <objcp/CPBitVar.h>

@interface CPLabel : NSObject
+(void) var: (id<ORIntVar>) x;
+(void) array: (id<ORIntVarArray>) x;
+(void) array: (id<ORIntVarArray>) x orderedBy: (ORInt2Int) orderedBy;
+(void) heuristic:(id<CPHeuristic>)h;
+(ORInt) maxBound: (id<ORIntVarArray>) x;
@end

@interface CPLabel (BitVar)
+(void) bit:(int) i ofVar:(id<CPBitVar>) x;
//TODO
//+(void) bitvar:(id<CPBitVar>)x;
//+(void) upFromLSB:(id<CPBitVar>) x;
//+(void) downFromLSB:(id<CPBitVar>) x;
//+(void) upFromMSB:(id<CPBitVar>) x;
//+(void) downFromMSB:(id<CPBitVar>) x;

@end

