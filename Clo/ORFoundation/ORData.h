/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORCrFactory.h>
#import <ORFoundation/ORObject.h>

//typedef enum {
//   DomainConsistency,
//   RangeConsistency,
//   ValueConsistency,
//   Hard,
//   Soft,
//   Default
//} ORAnnotation;

@protocol ORExpr;
@protocol ORIntRange;
@protocol ORASolver;
@protocol ORIntSet;
@class ORVisitor;

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

@interface ORGamma : NSObject<ORGamma>
{
@protected
   id __strong*  _gamma;
   id<ORModelMappings> _mappings;
}
-(ORGamma*) init;
-(void) dealloc;
-(id*) gamma;
-(id) concretize: (id) o;
-(void) setModelMappings: (id<ORModelMappings>) mappings;
-(id<ORModelMappings>) modelMappings;
@end


@interface NSObject (Concretization)
-(void) visit: (ORVisitor*) visitor;
@end;

@protocol ORInteger <ORObject,ORExpr>
-(ORInt) value;
@end

@protocol ORMutableId <ORObject>
-(id) idValue:(id<ORGamma>)solver;
-(void) setId:(id)v in:(id<ORGamma>)solver;
@end

@protocol ORMutableInteger <ORObject,ORExpr>
-(ORInt) initialValue;
-(ORInt) setValue: (ORInt) value in: (id<ORGamma>) solver;
-(ORInt) incr: (id<ORGamma>) solver;
-(ORInt) decr: (id<ORGamma>) solver;
-(ORInt) value: (id<ORGamma>) solver;
-(ORInt) intValue: (id<ORGamma>) solver;
-(ORFloat) floatValue: (id<ORGamma>) solver;
@end

@protocol ORFloatNumber <ORObject,ORExpr>
-(ORFloat) floatValue;
-(ORFloat) value;
-(ORInt) intValue;
@end

@protocol ORMutableFloat <ORObject,ORExpr>
-(ORFloat) initialValue;
-(ORFloat) value: (id<ORGamma>) solver;
-(ORFloat) floatValue: (id<ORGamma>) solver;
-(ORFloat) setValue: (ORFloat) value in: (id<ORGamma>) solver;
@end

@protocol ORTrailableInt <ORObject>
-(ORInt) value;
-(ORInt) setValue: (ORInt) value;
-(ORInt)  incr;  // post-incr returned
-(ORInt)  decr;  // post-decr returned
@end

@interface ORRuntimeMonitor : NSObject
+(ORLong) cputime;
+(ORLong) microseconds;
+(ORLong) wctime;
@end;

@interface ORStreamManager : NSObject
+(void) initialize;
+(void) setDeterministic;
+(void) setRandomized;
+(ORInt) deterministic;
+(void) initSeed: (unsigned short*) seed;
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

@interface ORCrFactory (OR)
+(id<ORMutableInteger>) integer:(ORInt) value;
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

