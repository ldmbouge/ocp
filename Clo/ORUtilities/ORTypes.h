/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>

#if (defined(__APPLE__)) && (__MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_9)
#define PORTABLE_BEGIN NS_ASSUME_NONNULL_BEGIN
#define PORTABLE_END NS_ASSUME_NONNULL_END
#define PNONNULL   __nonnull
#define PNULLABLE  __nullable
#else
#define PORTABLE_BEGIN
#define PORTABLE_END
#define PNONNULL 
#define PNULLABLE 
#endif


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

typedef short ORShort;
typedef unsigned short ORUShort;
typedef int ORInt;
typedef unsigned int ORUInt;
typedef long long ORLong;
typedef unsigned long long ORULong;
typedef float  ORFloat;
typedef double ORDouble;
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

#define MAXDBL DBL_MAX
#define MINDBL DBL_MIN

#define MAXUNSIGNED ((ORUInt)0xFFFFFFFF)
#define MINUNSIGNED ((ORUInt)0x0)

static inline ORInt bindUp(ORLong a)   { return (a < (ORLong)FDMAXINT) ? (ORInt)a : FDMAXINT;}
static inline ORInt bindDown(ORLong a) { return (a > (ORLong)FDMININT) ? (ORInt)a : FDMININT;}

@protocol ORExpr;
@protocol ORRelation;
@protocol ORSolution;
@protocol ORConstraint;
@protocol ORIntArray;
@protocol ORDoubleArray;
@protocol ORConstraintSet;

typedef struct ORRange {
   ORInt low;
   ORInt up;
} ORRange;

typedef struct ORBounds {
   ORInt min;
   ORInt max;
} ORBounds;

static inline ORBounds unionOf(ORBounds a,ORBounds b)
{
   return (ORBounds){min(a.min,b.min),max(a.max,b.max)};
}

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
typedef ORBool (^ORInt2Bool)(ORInt);
typedef ORBool (^ORVoid2Bool)(void);
typedef ORInt (^ORInt2Int)(ORInt);
typedef id   (^ORInt2Id)(ORInt);
typedef void (^ORInt2Void)(ORInt);
typedef void (^ORFloat2Void)(ORFloat);
typedef void (^ORDouble2Void)(ORDouble);
typedef void (^ORFloatxFloat2Void)(ORFloat, ORFloat);
typedef void (^ORId2Void)(id);
typedef void (^ORSolution2Void)(id<ORSolution>);
typedef void (^ORConstraint2Void)(id<ORConstraint>);
typedef void (^ORIntArray2Void)(id<ORIntArray>);
typedef void (^ORDoubleArray2Void)(id<ORDoubleArray>);
typedef void (^ORConstraintSet2Void)(id<ORConstraintSet>);
typedef ORDouble (^ORIntxInt2Double)(ORInt,ORInt);
typedef int (^ORIntxInt2Int)(ORInt,ORInt);
typedef ORBool (^ORIntxInt2Bool)(ORInt,ORInt);
typedef void (^ORIntxFloat2Void)(ORInt,ORFloat);
typedef BOOL (^ORIntxInt2Bool)(ORInt,ORInt);
typedef ORDouble (^ORInt2Double)(ORInt);
typedef id<ORExpr> (^ORInt2Expr)(ORInt);
typedef id<ORExpr> (^ORIntxInt2Expr)(ORInt, ORInt);
typedef id<ORRelation> (^ORInt2Relation)(ORInt);
typedef ORStatus (^Void2ORStatus)(void);
typedef bool (^DDArcSetTransitionClosure)(char*,char*,char*,bool*, int, int, int);
typedef void (^DDUpdatePropertyClosure)(char*,char*,char*);
typedef bool (^DDStateExistsClosure)(char*,char*,char*,ORInt,ORInt);
typedef bool (^DDArcExistsClosure)(char*,char*,char*,char*,ORInt, ORInt, ORInt);
typedef void (^DDMergeClosure)(char*,char*,char*);
typedef int (^DDFixpointBoundClosure)(char*);
typedef int (^DDStateEquivalenceClassClosure)(char*,char*);
typedef int (^DDNodeSplitValueClosure)(char*, char*, char*, id);
typedef int (^DDCandidateSplitValueClosure)(id);
