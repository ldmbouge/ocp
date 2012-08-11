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

typedef ORInt CPInt;
typedef ORUInt CPUInt;
typedef ORLong  CPLong;
typedef ORULong CPULong;

typedef enum {
   DomainConsistency,
   RangeConsistency,
   ValueConsistency
} CPConsistency;

typedef ORRange CPRange;
typedef ORBounds CPBounds;
typedef ORRuntimeMonitor CPRuntimeMonitor;

typedef ORVoid2Bool   CPVoid2Bool;
typedef ORInt2Int     CPInt2Int;
typedef ORIntxInt2Int CPIntxInt2Int;
typedef ORInt2Expr    CPInt2Expr;

@protocol CPSolver;

typedef void (^CPVirtualClosure)(id<CPSolver>);


#endif