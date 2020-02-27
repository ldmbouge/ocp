/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORExpr.h>

@protocol ORIntRange;
@protocol ORIntSet;

@protocol ORTau <NSObject,NSCopying>
-(void) set: (id) value forKey: (id) key;
-(id) get: (id) key;
-(id) copy;
@end

@protocol ORLambda <NSObject,NSCopying>
-(void) set: (id) value forKey: (id) key;
-(id) get: (id) key;
-(id) copy;
@end

@protocol ORModelMappings;

@protocol ORGamma <NSObject>
-(void) setGamma: (id*) gamma;
-(id*)gamma;
-(id<ORObject>) concretize: (id<ORObject>) o;
-(id<ORModelMappings>) modelMappings;
-(void) setModelMappings: (id<ORModelMappings>) mappings;
@end

@protocol ORModelMappings <NSObject>
-(id<ORTau>) tau;
-(id<ORLambda>) lambda;
-(id) copy;
@end

@protocol ORInteger <ORObject,ORRelation>
-(ORInt) value;
@end

@protocol ORMutableId <ORObject>
-(id) idValue:(id<ORGamma>)solver;
-(void) setIdValue:(id)v in:(id<ORGamma>)solver;
@end

@protocol ORMutableInteger <ORObject,ORExpr>
-(ORInt) initialValue;
-(ORInt) setValue: (ORInt) value;
-(ORInt) setValue: (ORInt) value in: (id<ORGamma>) solver;
-(ORInt) incr: (id<ORGamma>) solver;
-(ORInt) decr: (id<ORGamma>) solver;
-(ORInt) value: (id<ORGamma>) solver;
-(ORInt) intValue: (id<ORGamma>) solver;
-(ORDouble) doubleValue: (id<ORGamma>) solver;
@end

@protocol ORMutableFloat <ORObject,ORExpr>
-(ORFloat) initialValue;
-(ORFloat) value;
-(ORFloat) setValue: (ORFloat) value;
-(ORFloat) setValue: (ORFloat) value in: (id<ORGamma>) solver;
-(ORFloat) value: (id<ORGamma>) solver;
@end

@protocol ORMutableRational <ORObject,ORExpr>
-(id<ORRational>) initialValue;
-(id<ORRational>) value;
-(id<ORRational>) setValue: (id<ORRational>) value;
-(id<ORRational>) setValue: (id<ORRational>) value in: (id<ORGamma>) solver;
-(id<ORRational>) value: (id<ORGamma>) solver;
@end

@protocol ORDoubleNumber <ORObject,ORExpr>
-(ORDouble) doubleValue;
-(ORDouble) value;
-(ORInt) intValue;
@end

@protocol ORFloatNumber <ORObject,ORExpr>
-(ORFloat) floatValue;
-(ORFloat) fmin;
-(ORFloat) value;
-(ORInt) intValue;
@end

@protocol ORRationalNumber <ORObject,ORExpr>
-(id<ORRational>) rationalValue;
-(id<ORRational>) qmin;
-(id<ORRational>) value;
-(ORInt) intValue;
@end

@protocol ORMutableDouble <ORObject,ORExpr>
-(ORDouble) initialValue;
-(ORDouble) value: (id<ORGamma>) solver;
-(ORDouble) doubleValue: (id<ORGamma>) solver;
-(ORDouble) setValue: (ORDouble) value in: (id<ORGamma>) solver;
@end

@protocol ORRandomStream <ORObject>
-(ORLong) next;
@end

@protocol ORZeroOneStream <ORObject>
-(double) next;
@end

@protocol ORUniformDistribution <ORObject>
-(ORInt) next;
@end

@protocol ORRandomPermutation <ORRandomStream>
-(ORInt) next;
@end

@protocol ORTable <ORObject>
-(void) insert: (ORInt) i : (ORInt) j : (ORInt) k;
-(void) addEmptyTuple;
-(void) fill: (ORInt) j with: (ORInt) val;
-(void)insertTuple:(ORInt*)t;
-(void) print;
-(void) close;
@end

typedef ORInt ORTransition[3];

#define SIZETF(t) (sizeof((t)) / sizeof(ORTransition))

@protocol ORAutomaton <ORObject>
-(id<ORTable>)transition;
-(ORInt) initial;
-(id<ORIntSet>)final;
-(id<ORIntRange>)alphabet;
-(id<ORIntRange>)states;
@end

@protocol ORBindingArray <NSObject>
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(id) objectAtIndexedSubscript:(NSUInteger)key;
-(void) setObject:(id)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) nb;
@end

