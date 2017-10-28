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
   ORRLThen = 5,
   ORRGThen = 6,
   ORNeg   = 7,
   ORRDisj = 8,
   ORRConj = 9,
   ORRImply = 10,
   ORRSSA = 11
};

typedef NS_ENUM(NSUInteger,ORVType) {
   ORTBool = 0,
   ORTInt = 1,
   ORTReal = 2,
   ORTFloat = 3,
   ORTDouble = 4,
   ORTLDouble = 5,
   ORTBit  = 6,
   ORTSet  = 7,
   ORTNA = 8
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

static ORVType lookup_relation_table[][9] = {
    //ORTBOOL  ORTINT    ORTREAL,  ORTFLOAT,  ORTDouble,  ORTLDOUBLE, ORTBIT,     ORTSET,  ORTNA
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},     // ORTBOOL
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},     // ORTINT
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},     // ORTREAL
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      // ORTFLOAT
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      //ORTDouble
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      //ORTLDouble
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      //ORTBIT
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      //ORTSET
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool,  ORTNA}       //ORTTNA
};

static ORVType lookup_logical_table[][9] = {
    //ORTBOOL  ORTINT    ORTREAL,  ORTFLOAT,  ORTDouble,  ORTLDOUBLE, ORTBIT,     ORTSET,  ORTNA
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},     // ORTBOOL
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},     // ORTINT
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},     // ORTREAL
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      // ORTFLOAT
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      //ORTDouble
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      //ORTLDouble
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      //ORTBIT
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool, ORTBool},      //ORTSET
    {ORTBool,  ORTBool, ORTBool,  ORTBool,  ORTBool,    ORTBool,    ORTBool,   ORTBool,  ORTNA}       //ORTTNA
};

static ORVType lookup_expr_table[][9] = {
    //ORTBOOL  ORTINT       ORTREAL,  ORTFLOAT,  ORTDouble,  ORTLDOUBLE, ORTBIT,   ORTSET,  ORTNA
    {ORTBool,  ORTInt,    ORTReal,  ORTFloat,   ORTDouble, ORTLDouble, ORTBit,  ORTSet, ORTBool},     // ORTBOOL
    {ORTInt,  ORTInt,     ORTReal,  ORTFloat,  ORTDouble, ORTLDouble, ORTBit,   ORTSet,  ORTInt},     // ORTINT
    {ORTReal,  ORTReal,    ORTReal,  ORTReal,   ORTReal,   ORTReal,    ORTBit,   ORTSet,  ORTReal},     // ORTREAL
    {ORTFloat,  ORTFloat,   ORTReal,  ORTFloat,  ORTDouble, ORTLDouble,  ORTBit,   ORTSet, ORTFloat},      // ORTFLOAT
    {ORTDouble,  ORTDouble,  ORTReal,  ORTDouble, ORTLDouble, ORTLDouble, ORTBit,   ORTSet, ORTDouble},      //ORTDouble
    {ORTLDouble,  ORTLDouble, ORTReal,  ORTLDouble,ORTLDouble, ORTLDouble, ORTBit,   ORTSet, ORTLDouble},      //ORTLDouble
    {ORTBit,  ORTBit,     ORTBit,   ORTBit,   ORTBit,     ORTBit,     ORTBit,   ORTSet, ORTBit},      //ORTBIT
    {ORTSet,  ORTSet,     ORTSet,   ORTSet,   ORTSet,     ORTSet,     ORTSet,   ORTSet, ORTSet},      //ORTSET
    {ORTBool,  ORTInt,     ORTReal, ORTFloat,  ORTDouble,  ORTLDouble, ORTBit,    ORTSet,  ORTNA}       //ORTTNA
};

@protocol ORExpr <ORConstraint,NSObject,NSCoding>
-(id<ORTracker>) tracker;
-(ORInt) min;
-(ORInt) max;
-(ORFloat) fmin;
-(ORFloat) fmax;
-(ORInt) intValue;
-(ORFloat) floatValue;
-(ORDouble) doubleValue;
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

