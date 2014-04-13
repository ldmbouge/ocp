/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
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
typedef double ORFloat;
typedef BOOL   ORBool;

//#define minOf(a,b) ((a) < (b) ? (a) : (b))
//#define maxOf(a,b) ((a) > (b) ? (a) : (b))
static inline ORLong minOf(ORLong a,ORLong b) { return a < b ? a : b;}
static inline ORLong maxOf(ORLong a,ORLong b) { return a > b ? a : b;}

static inline ORInt min(ORInt a,ORInt b) { return a < b ? a : b;}
static inline ORInt max(ORInt a,ORInt b) { return a > b ? a : b;}

#define MAXINT ((ORInt)0x7FFFFFFF)
#define MININT ((ORInt)0x80000000)

#define FDMAXINT (((ORInt)0x7FFFFFFF)/2)
#define FDMININT (((ORInt)0x80000000)/2)

#define MAXUNSIGNED ((ORUInt)0xFFFFFFFF)
#define MINUNSIGNED ((ORUInt)0x0)

static inline ORInt bindUp(ORLong a)   { return (a < (ORLong)FDMAXINT) ? (ORInt)a : FDMAXINT;}
static inline ORInt bindDown(ORLong a) { return (a > (ORLong)FDMININT) ? (ORInt)a : FDMININT;}

@protocol ORExpr;
@protocol ORRelation;
@protocol ORSolution;
@protocol ORConstraint;
@protocol ORIntArray;
@protocol ORFloatArray;
@protocol ORConstraintSet;

typedef struct ORRange {
   ORInt low;
   ORInt up;
} ORRange;

typedef struct ORBounds {
   ORInt min;
   ORInt max;
} ORBounds;

@protocol IntEnumerator <NSObject>
-(ORBool) more;
-(ORInt) next;
@end

typedef enum  {
   ORFailure,
   ORSuccess,
   ORSuspend,
   ORDelay,
   ORSkip,
   ORNoop
} ORStatus;

typedef enum  {
   ORNone = 0,
   ORLow = 1,
   ORUp  = 2,
   ORBoth = 3
} ORNarrowing;

typedef void (^ORClosure)(void);
typedef bool (^ORInt2Bool)(ORInt);
typedef bool (^ORVoid2Bool)(void);
typedef ORInt (^ORInt2Int)(ORInt);
typedef id   (^ORInt2Id)(ORInt);
typedef void (^ORInt2Void)(ORInt);
typedef void (^ORFloat2Void)(ORFloat);
typedef void (^ORFloatxFloat2Void)(ORFloat, ORFloat);
typedef void (^ORId2Void)(id);
typedef void (^ORSolution2Void)(id<ORSolution>);
typedef void (^ORConstraint2Void)(id<ORConstraint>);
typedef void (^ORIntArray2Void)(id<ORIntArray>);
typedef void (^ORFloatArray2Void)(id<ORFloatArray>);
typedef void (^ORConstraintSet2Void)(id<ORConstraintSet>);
typedef int (^ORIntxInt2Int)(ORInt,ORInt);
typedef void (^ORIntxFloat2Void)(ORInt,ORFloat);
typedef BOOL (^ORIntxInt2Bool)(ORInt,ORInt);
typedef ORFloat (^ORInt2Float)(ORInt);
typedef id<ORExpr> (^ORInt2Expr)(ORInt);
typedef id<ORExpr> (^ORIntxInt2Expr)(ORInt, ORInt);
typedef id<ORRelation> (^ORInt2Relation)(ORInt);
typedef ORStatus (^Void2ORStatus)(void);
