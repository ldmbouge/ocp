/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPSolution.h>

@protocol CP;
@protocol CPExprVisitor;



typedef ORStatus(*UBType)(id,SEL,...);
typedef void (^ConstraintCallback)(void);
typedef void (^ConstraintIntCallBack)(CPInt);


@protocol CPIntVar;
@protocol CPRelation;

@protocol CPConstraint <NSObject>
@end

@protocol CPExpr <ORExpr,CPConstraint>
-(id<CPExpr>) plus: (id<CPExpr>) e;
-(id<CPExpr>) sub: (id<CPExpr>) e;
-(id<CPExpr>) mul: (id<CPExpr>) e;
-(id<CPExpr>) muli: (ORInt) e;
-(id<CPRelation>) eq: (id<CPExpr>) e;
-(id<CPRelation>) eqi: (CPInt) e;
-(id<CPRelation>) neq: (id<CPExpr>) e;
-(id<CPRelation>) neqi: (CPInt) e;
-(id<CPRelation>) leq: (id<CPExpr>) e;
-(id<CPRelation>) leqi: (CPInt) e;
-(id<CPRelation>) geq: (id<CPExpr>) e;
-(id<CPRelation>) geqi: (CPInt) e;
-(id<CPRelation>) lt: (id<CPExpr>) e;
-(id<CPRelation>) lti: (CPInt) e;
-(id<CPRelation>) gt: (id<CPExpr>) e;
-(id<CPRelation>) gti: (CPInt) e;
-(id<CPRelation>) and:(id<CPExpr>)e;
-(id<CPRelation>) or:(id<CPExpr>)e;
-(id<CPRelation>) imply:(id<CPExpr>)e;
@end

@protocol CPRelation <ORRelation,CPExpr>
-(id<CPRelation>)and:(id<CPRelation>)e;
-(id<CPRelation>)or:(id<CPRelation>)e;
-(id<CPRelation>)imply:(id<CPRelation>)e;
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
-(BOOL) isBool;
-(bool) bound;
-(CPInt)  min;
-(CPInt)  max;
-(CPInt)  value;
-(id<CP>) cp;
-(void) bounds: (CPBounds*) bnd;
-(CPInt) domsize;
-(CPInt)countFrom:(CPInt)from to:(CPInt)to;
-(bool) member: (CPInt) v;
-(NSSet*)constraints;
-(id)snapshot;
@end


@protocol CPVirtual 
-(CPInt) virtualOffset;   
@end

@protocol CPRandomStream <ORRandomStream>
@end;

@protocol CPZeroOneStream <ORZeroOneStream>
@end;

@protocol CPUniformDistribution <ORUniformDistribution>
@end;


