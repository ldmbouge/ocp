/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#ifndef __ORTYPES_H
#define __ORTYPES_H

#if !defined(__APPLE__) || defined(__IPHONE_NA)
typedef unsigned long long uint64;
typedef long long sint64;
typedef unsigned int uint32;
typedef int sint32;
typedef unsigned short uint16;
typedef signed short sint16;
typedef unsigned char uint8;
typedef signed char sint8;
#endif

typedef sint32 ORInt;
typedef uint32 ORUInt;
typedef sint64 ORLong;
typedef uint64 ORULong;

static inline ORLong minOf(ORLong a,ORLong b) { return a < b ? a : b;}
static inline ORLong maxOf(ORLong a,ORLong b) { return a > b ? a : b;}

static inline ORInt min(ORInt a,ORInt b) { return a < b ? a : b;}
static inline ORInt max(ORInt a,ORInt b) { return a > b ? a : b;}

#define MAXINT ((ORInt)0x7FFFFFFF)
#define MININT ((ORInt)0x80000000)

#define MAXUNSIGNED ((ORUInt)0xFFFFFFFF)
#define MINUNSIGNED ((ORUInt)0x0)

static inline ORInt bindUp(ORLong a)   { return (a < (ORLong)MAXINT) ? (ORInt)a : MAXINT;}
static inline ORInt bindDown(ORLong a) { return (a > (ORLong)MININT) ? (ORInt)a : MININT;}

@protocol ORExpr;
@protocol ORRelation;

typedef void (^ORClosure)(void);
typedef bool (^ORInt2Bool)(ORInt);
typedef bool (^ORVoid2Bool)(void);
typedef ORInt (^ORInt2Int)(ORInt);
typedef void (^ORInt2Void)(ORInt);
typedef int (^ORIntxInt2Int)(ORInt,ORInt);
typedef id<ORExpr> (^ORInt2Expr)(ORInt);
typedef id<ORRelation> (^ORInt2Relation)(ORInt);


typedef struct ORRange {
   ORInt low;
   ORInt up;
} ORRange;

typedef struct ORBounds {
   ORInt min;
   ORInt max;
} ORBounds;

@protocol IntEnumerator <NSObject>
-(bool) more;
-(ORInt) next;
@end

#endif
