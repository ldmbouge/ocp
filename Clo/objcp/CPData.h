/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORExpr.h"
#import <objcp/CPSolution.h>
#import <objcp/CPTypes.h>

@protocol CP;
@protocol CPExprVisitor;


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

@protocol CPIntVar;
@protocol CPRelation;

@protocol CPExpr <ORExpr>
-(id<CPExpr>) plus: (id<CPExpr>) e;
-(id<CPExpr>) sub: (id<CPExpr>) e;
-(id<CPExpr>) mul: (id<CPExpr>) e;
-(id<CPExpr>) muli: (ORInt) e;
-(id<CPRelation>) eq: (id<CPExpr>) e;
-(id<CPRelation>) eqi: (CPInt) e;
-(id<CPRelation>) neq: (id<CPExpr>) e;
-(id<CPRelation>) leq: (id<CPExpr>) e;
-(id<CPRelation>) geq: (id<CPExpr>) e;
@end

@protocol CPRelation <ORRelation,CPExpr>
@end

@protocol CPInteger <ORInteger,CPExpr>
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
-(id<CP>) cp;
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
+(CPLong) cputime;
+(CPLong) microseconds;
@end;


