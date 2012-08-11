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
typedef void (^ConstraintIntCallBack)(ORInt);


@protocol CPIntVar;
@protocol CPRelation;

@protocol CPConstraint <ORConstraint>
@end

/*
@protocol CPExpr <ORExpr,CPConstraint>
-(id<CPExpr>) plus: (id<CPExpr>) e;
-(id<CPExpr>) sub: (id<CPExpr>) e;
-(id<CPExpr>) mul: (id<CPExpr>) e;
-(id<CPExpr>) muli: (ORInt) e;
-(id<CPRelation>) eq: (id<CPExpr>) e;
-(id<CPRelation>) eqi: (ORInt) e;
-(id<CPRelation>) neq: (id<CPExpr>) e;
-(id<CPRelation>) neqi: (ORInt) e;
-(id<CPRelation>) leq: (id<CPExpr>) e;
-(id<CPRelation>) leqi: (ORInt) e;
-(id<CPRelation>) geq: (id<CPExpr>) e;
-(id<CPRelation>) geqi: (ORInt) e;
-(id<CPRelation>) lt: (id<CPExpr>) e;
-(id<CPRelation>) lti: (ORInt) e;
-(id<CPRelation>) gt: (id<CPExpr>) e;
-(id<CPRelation>) gti: (ORInt) e;
-(id<CPRelation>) and:(id<CPExpr>)e;
-(id<CPRelation>) or:(id<CPExpr>)e;
-(id<CPRelation>) imply:(id<CPExpr>)e;
@end

@protocol CPRelation <ORRelation,CPExpr>
-(id<CPRelation>)and:(id<CPRelation>)e;
-(id<CPRelation>)or:(id<CPRelation>)e;
-(id<CPRelation>)imply:(id<CPRelation>)e;
@end
*/
/*
@protocol CPInteger <ORInteger,CPExpr>
@end

@protocol CPVar <CPExpr,ORSavable>
-(CPUInt)getId;
-(id)snapshot;
-(NSSet*)constraints;
-(bool) bound;
@end

@protocol CPIntVar <ORIntVar,CPVar>
-(CPUInt)getId;
-(BOOL) isBool;
-(bool) bound;
-(ORInt)  min;
-(ORInt)  max;
-(ORInt)  value;
-(id<CPSolver>) cp;
-(void) bounds: (CPBounds*) bnd;
-(ORInt) domsize;
-(ORInt)countFrom:(ORInt)from to:(ORInt)to;
-(bool) member: (ORInt) v;
-(NSSet*)constraints;
-(id)snapshot;
@end
*/

@protocol CPVirtual 
-(ORInt) virtualOffset;   
@end

@protocol CPRandomStream <ORRandomStream>
@end;

@protocol CPZeroOneStream <ORZeroOneStream>
@end;

@protocol CPUniformDistribution <ORUniformDistribution>
@end;


