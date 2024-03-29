/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORTypes.h>
#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORConstraint.h>

@protocol ORRelation;
@protocol ORExpr;
@protocol ORIntArray;

#if defined(__APPLE__)
typedef NS_ENUM(NSUInteger,ORRelationType) {
   ORRBad = 0,
   ORREq  = 1,
   ORRNEq = 2,
   ORRLEq = 3,
   ORRGEq = 4,
   ORNeg   = 5,
   ORRDisj = 6,
   ORRConj = 7,
   ORRImply = 8
};

typedef NS_ENUM(NSUInteger,ORVType) {
   ORTBool = 0,
   ORTInt = 1,
   ORTReal = 2,
   ORTBit  = 3,
   ORTSet  = 4,
   ORTNA = 5
};
#else
typedef enum ORRelationType {
   ORRBad = 0,
   ORREq  = 1,
   ORRNEq = 2,
   ORRLEq = 3,
   ORRGEq = 4,
   ORNeg   = 5,
   ORRDisj = 6,
   ORRConj = 7,
   ORRImply = 8
} ORRelationType;

typedef enum ORVType {
  ORTBool = 0,
  ORTInt = 1,
  ORTReal = 2,
  ORTBit  = 3,
  ORTSet  = 4,
  ORTNA = 5
} ORVType;

#endif


static inline ORVType lubVType(ORVType t1,ORVType t2)
{
   if (t1 == t2)
      return t1;
   else if (t1+t2 <= 1)
      return ORTInt;
   else if ((t1<=1 && t2 <= 2) || (t1 <= 2  && t2 <= 1))
      return ORTReal;
   else if (t1 == ORTNA)
      return t2;
   else if (t2 == ORTNA)
      return t1;
   else
      return ORTNA;
}


@protocol ORExpr <ORConstraint,NSObject,NSCoding>
-(id<ORTracker>) tracker;
-(ORInt) min;
-(ORInt) max;
-(ORDouble) doubleValue;
-(ORInt) intValue;
-(ORBool) isConstant;
-(ORBool) isVariable;
-(id<ORExpr>) abs;
-(id<ORExpr>) square;
-(id<ORExpr>) plus: (id) e;
-(id<ORExpr>) sub: (id) e;
-(id<ORExpr>) mul: (id) e;
-(id<ORExpr>) div: (id) e;
-(id<ORExpr>) mod: (id) e;
-(id<ORExpr>) min: (id) e;
-(id<ORExpr>) max: (id) e;
-(id<ORRelation>) eq: (id) e;
-(id<ORRelation>) neq: (id) e;
-(id<ORRelation>) leq: (id) e;
-(id<ORRelation>) geq: (id) e;
-(id<ORRelation>) lt: (id) e;
-(id<ORRelation>) gt: (id) e;
-(id<ORRelation>) neg;
-(id<ORRelation>) land: (id) e;
-(id<ORRelation>) lor: (id) e;
-(id<ORRelation>) imply:(id)e;

-(id<ORExpr>) absTrack:(id<ORTracker>)t;
-(id<ORExpr>) plus: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) sub: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) mul: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) div: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) mod: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) min: (id) e  track:(id<ORTracker>)t;
-(id<ORExpr>) max: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) eq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) neq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) leq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) geq: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) lt: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) gt: (id) e  track:(id<ORTracker>)t;
-(id<ORRelation>) negTrack:(id<ORTracker>)t;
-(id<ORRelation>) land: (id<ORExpr>) e  track:(id<ORTracker>)t;
-(id<ORRelation>) lor: (id<ORExpr>) e track:(id<ORTracker>)t;
-(id<ORRelation>) imply:(id<ORExpr>)e  track:(id<ORTracker>)t;
-(ORRelationType) type;
-(ORVType)vtype;
@end

@protocol ORRelation <ORExpr>
-(ORRelationType) type;
-(id<ORRelation>) land: (id<ORExpr>) e;
-(id<ORRelation>) lor: (id<ORExpr>) e;
-(id<ORRelation>) imply: (id<ORExpr>) e;
@end

@interface NSNumber (Expressions)
-(id<ORExpr>)asExpression:(id<ORTracker>)tracker;
-(id<ORExpr>) plus: (id<ORExpr>) e;
-(id<ORExpr>) sub: (id<ORExpr>) e;
-(id<ORExpr>) mul: (id<ORExpr>) e;
-(id<ORExpr>) div: (id<ORExpr>) e;
-(id<ORExpr>) mod: (id<ORExpr>) e;
-(id<ORRelation>) eq: (id<ORExpr>) e;
-(id<ORRelation>) neq: (id<ORExpr>) e;
-(id<ORRelation>) leq: (id<ORExpr>) e;
-(id<ORRelation>) geq: (id<ORExpr>) e;
-(id<ORRelation>) lt: (id<ORExpr>) e;
-(id<ORRelation>) gt: (id<ORExpr>) e;
@end

