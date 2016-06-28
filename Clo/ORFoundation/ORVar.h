/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORExpr.h>
#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORConstraint.h>

PORTABLE_BEGIN

@protocol ORVar <ORObject>
-(ORInt) getId;
@end

@protocol ORExprVar <ORVar,ORRelation>
-(ORInt) getId;
@end

@protocol ORIntVar <ORExprVar>
-(id<ORIntRange>) domain;
-(ORInt) low;
-(ORInt) up;
-(ORBool) isBool;
-(ORBool) hasDenseDomain;
-(ORInt) scale;
-(ORInt) shift;
-(ORInt) literal;
-(id<ORIntVar>)base;
@end

@protocol ORBitVar <ORExprVar>
-(ORUInt*)low;
-(ORUInt*)up;
-(ORUInt)bitLength;
-(NSString*)stringValue;
@end

@protocol ORRealVar <ORExprVar>
-(id<ORRealRange>) domain;
-(void)setDomain:(id<ORRealRange>)domain;
-(ORBool) hasBounds;
-(ORDouble) low;
-(ORDouble) up;
@end


@protocol ORExprArray<ORIdArray>
-(id<ORExpr>) at: (ORInt) value;
-(void) set: (id<ORExpr>) x at: (ORInt) value;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(id<ORExpr>) objectAtIndexedSubscript: (ORInt) key;
-(void) setObject: (id<ORExpr>) newValue atIndexedSubscript: (ORInt) idx;
@end

@protocol ORVarArray <ORExprArray>
-(id<ORVar>) at: (ORInt) value;
-(void) set: (id<ORVar>) x at: (ORInt) value;
-(id<ORExpr>) elt: (id<ORExpr>) idx;
-(id<ORVar>) objectAtIndexedSubscript: (ORInt) key;
-(void) setObject: (id<ORVar>) newValue atIndexedSubscript: (ORInt) idx;
@end

@protocol ORIntVarArray <ORVarArray>
-(id<ORIntVar>) at: (ORInt) value;
-(void) set: (id<ORIntVar>) x at: (ORInt) value;
-(id<ORIntVar>) objectAtIndexedSubscript: (ORInt) key;
-(void) setObject: (id<ORIntVar>) newValue atIndexedSubscript: (ORInt) idx;
-(id<ORASolver>) solver;
@end

@protocol ORRealVarArray <ORVarArray>
-(id<ORRealVar>) at: (ORInt) value;
-(void) set: (id<ORRealVar>) x at: (ORInt) value;
-(id<ORRealVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORRealVar>) newValue atIndexedSubscript: (NSUInteger) idx;
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
-(ORDouble) objective;
-(id<ORObjectiveValue>) objectiveValue;
-(ORDouble) value: (id<ORVar>) x;
-(ORDouble) lowerBound: (id<ORVar>) x;
-(ORDouble) upperBound: (id<ORVar>) x;
-(void) updateLowerBound: (id<ORVar>) x with: (ORDouble) f;
-(void) updateUpperBound: (id<ORVar>) x with: (ORDouble) f;
-(void) updateBounds:(id<ORVar>)x lower:(ORDouble)low  upper:(ORDouble)up;
-(OROutcome) solve;
-(void) close;
-(double)reducedCost:(id<ORVar>)x;
-(ORBool)inBasis:(id<ORVar>)x;
@end

PORTABLE_END

