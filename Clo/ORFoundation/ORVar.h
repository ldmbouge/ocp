/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORExpr.h>
#import "ORTracker.h"
#import "ORArray.h"
#import "ORSet.h"
#import "ORConstraint.h"



@protocol ORVar <ORObject,ORExpr>
-(ORInt) getId;
@end

@protocol ORIntVar <ORVar>
-(id<ORIntRange>) domain;
-(ORInt) low;
-(ORInt) up;
-(ORBool) isBool;
-(ORInt) scale;
-(ORInt) shift;
-(ORInt) literal;
-(id<ORIntVar>)base;
@end

@protocol ORFloatVar <ORVar>
-(id<ORFloatRange>) domain;
-(ORBool) hasBounds;
-(ORFloat) low;
-(ORFloat) up;
@end

@protocol ORBitVar <ORVar>
-(ORUInt*)low;
-(ORUInt*)up;
-(ORUInt)bitLength;
-(NSString*)stringValue;
@end

@protocol ORExprArray<ORIdArray>
-(id<ORExpr>) at: (ORInt) value;
-(void) set: (id<ORExpr>) x at: (ORInt) value;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(id<ORExpr>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORExpr>) newValue atIndexedSubscript: (NSUInteger) idx;
@end

@protocol ORVarArray <ORExprArray>
-(id<ORVar>) at: (ORInt) value;
-(void) set: (id<ORVar>) x at: (ORInt) value;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(id<ORVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORVar>) newValue atIndexedSubscript: (NSUInteger) idx;
@end

@protocol ORIntVarArray <ORVarArray>
-(id<ORIntVar>) at: (ORInt) value;
-(void) set: (id<ORIntVar>) x at: (ORInt) value;
-(id<ORIntVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol ORFloatVarArray <ORVarArray>
-(id<ORFloatVar>) at: (ORInt) value;
-(void) set: (id<ORFloatVar>) x at: (ORInt) value;
-(id<ORFloatVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORFloatVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol ORIntVarMatrix <ORIdMatrix>
-(ORInt) arity;
-(id<ORIntVar>) flat:(ORInt)i;
-(id<ORIntVar>) at: (ORInt) i1 : (ORInt) i2;
-(id<ORIntVar>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORExpr>) elt: (id<ORExpr>) idx i1:(ORInt)i1;
-(id<ORExpr>) at: (ORInt) i0       elt:(id<ORExpr>)e1;
-(id<ORExpr>) elt: (id<ORExpr>)e0  elt:(id<ORExpr>)e1;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORASolver>) solver;
@end

@protocol ORVarLitterals <NSObject>
-(ORInt) low;
-(ORInt) up;
-(id<ORIntVar>) litteral: (ORInt) i;
-(BOOL) exist: (ORInt) i;
-(NSString*) description;
@end

@protocol ORObjectiveValue;

typedef enum { ORinfeasible, ORoptimal, ORsuboptimal, ORunbounded, ORerror} OROutcome;

@protocol ORRelaxation <NSObject>
-(ORFloat) objective;
-(id<ORObjectiveValue>) objectiveValue;
-(ORFloat) value: (id<ORVar>) x;
-(ORFloat) lowerBound: (id<ORVar>) x;
-(ORFloat) upperBound: (id<ORVar>) x;
-(void) updateLowerBound: (id<ORVar>) x with: (ORFloat) f;
-(void) updateUpperBound: (id<ORVar>) x with: (ORFloat) f;
-(OROutcome) solve;
-(void) close;
@end

