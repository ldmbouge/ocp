/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPSolution.h>
#import <objcp/CPTypes.h>

@class CPExprI;
@protocol CP;
@protocol CPExprVisitor;

typedef struct CPRange {
    CPInt low;
    CPInt up;
} CPRange;

typedef struct CPBounds {
    CPInt min;
    CPInt max;
} CPBounds;

typedef enum  {
    CPFailure,
    CPSuccess,
    CPSuspend,
    CPDelay,
    CPSkip
} CPStatus;

typedef void (^ConstraintCallback)(void);
typedef void (^ConstraintIntCallBack)(CPInt);
typedef CPStatus (^CPVoid2CPStatus)(void);

@protocol IntEnumerator <NSObject>
-(bool) more;
-(CPInt) next;
@end
@protocol CPIntVar;
@protocol CPRelation;

@protocol CPExpr <NSObject,NSCoding>
-(id<CP>) cp;
-(CPInt) min;
-(CPInt) max;
-(id<CPIntVar>)var;
-(BOOL) isConstant;
-(BOOL) isVariable;
-(id<CPExpr>) add: (id<CPExpr>) e;
-(id<CPExpr>) sub: (id<CPExpr>) e;
-(id<CPExpr>) mul: (id<CPExpr>) e;
-(id<CPExpr>) muli: (CPInt) e;
-(id<CPRelation>) equal: (id<CPExpr>) e;
@end

@protocol CPRelation <CPExpr>
@end

@protocol CPInteger <CPExpr>
-(CPInt)  value;
-(void) setValue: (CPInt) value;
-(void) incr;
-(void) decr;
@end

@protocol CPVar <CPExpr,CPSavable>
-(CPUInt)getId;
-(id)snapshot;
-(NSSet*)constraints;
-(bool) bound;
@end

@protocol CPIntVar <CPVar>
-(CPUInt)getId;
-(bool) bound;
-(CPInt)  min;
-(CPInt)  max;
-(void) bounds: (CPBounds*) bnd;
-(CPInt) domsize;
-(CPInt)countFrom:(CPInt)from to:(CPInt)to;
-(bool) member: (CPInt) v;
-(NSSet*)constraints;
-(id)snapshot;
@end

@protocol CPConstraint <NSObject>
@end

@protocol CPVirtual 
-(CPInt) virtualOffset;   
@end

@interface CPRuntimeMonitor : NSObject 
+(CPInt) cputime;
+(CPInt) microseconds;
@end;

typedef void (^CPClosure)(void);
typedef bool (^CPInt2Bool)(CPInt);
typedef bool (^CPVoid2Bool)(void);
typedef CPInt (^CPInt2Int)(CPInt);
typedef void (^CPInt2Void)(CPInt);
typedef int (^CPIntxInt2Int)(CPInt,CPInt);
typedef id<CPExpr> (^CPInt2Expr)(CPInt);
typedef void (^CPVirtualClosure)(id<CP>);


