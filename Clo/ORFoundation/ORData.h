/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORCrFactory.h>


typedef enum {
   DomainConsistency,
   RangeConsistency,
   ValueConsistency,
   Hard,
   Soft,
   Default
} ORAnnotation;


@protocol ORExpr;
@protocol ORIntRange;
@protocol ORVisitor;
@protocol ORASolver;

@protocol ORObject <NSObject>
-(ORInt) getId;
-(void) visit: (id<ORVisitor>) visitor;
@end;

@protocol ORTau <NSObject,NSCopying>
-(void) set: (id) value forKey: (id) key;
-(id) get: (id) key;
@end

@protocol ORLambda <NSObject,NSCopying>
-(void) set: (id) value forKey: (id) key;
-(id) get: (id) key;
@end

@protocol ORModelMaps <NSObject,NSCopying>
-(id<ORTau>) tau;
-(id<ORLambda>) lambda;
-(id<ORObject>) concretize: (id<ORObject>) o;
-(id) copy;
@end

@interface NSObject (Concretization)
-(void) visit: (id<ORVisitor>) visitor;
@end;


@protocol ORInteger <ORObject,ORExpr>
-(ORInt) value;
@end

@protocol ORMutableInteger <ORObject,ORExpr>
-(ORInt) initialValue;
-(ORInt) setValue: (ORInt) value in: (id<ORModelMaps>) solver;
-(ORInt) incr: (id<ORModelMaps>) solver;
-(ORInt) decr: (id<ORModelMaps>) solver;
-(ORInt) value: (id<ORModelMaps>) solver;
-(ORInt) intValue: (id<ORModelMaps>) solver;
-(ORFloat) floatValue: (id<ORModelMaps>) solver;
@end

@protocol ORFloatNumber <ORObject,ORExpr>
-(ORFloat) floatValue;
-(ORFloat) value;
-(ORInt) intValue;
@end

@protocol ORMutableFloat <ORObject,ORExpr>
-(ORFloat) initialValue;
-(ORFloat) value: (id<ORModelMaps>) solver;
-(ORFloat) floatValue: (id<ORModelMaps>) solver;
-(ORFloat) setValue: (ORFloat) value in: (id<ORModelMaps>) solver;
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
@end;

@protocol ORZeroOneStream <ORObject>
-(double) next;
@end;

@protocol ORUniformDistribution <ORObject>
-(ORInt) next;
@end;

@interface ORCrFactory (OR)
+(id<ORMutableInteger>) integer:(ORInt) value;
+(id<ORRandomStream>) randomStream;
+(id<ORZeroOneStream>) zeroOneStream;
+(id<ORUniformDistribution>) uniformDistribution: (id<ORIntRange>) r;
@end

@protocol ORTable <ORObject>
-(void) insert: (ORInt) i : (ORInt) j : (ORInt) k;
-(void) addEmptyTuple;
-(void) fill: (ORInt) j with: (ORInt) val;
-(void) print;
-(void) close;
@end

@protocol ORBindingArray <NSObject>
-(id) at: (ORInt) value;
-(void) set: (id) x at: (ORInt) value;
-(id) objectAtIndexedSubscript:(NSUInteger)key;
-(void) setObject:(id)newValue atIndexedSubscript:(NSUInteger)idx;
-(ORInt) nb;
@end



@interface ORModelMaps : NSObject<ORModelMaps>
{
@protected
   id* _gamma;
   id<ORTau> _tau;
   id<ORLambda> _lambda;
}
-(ORModelMaps*) initORModelMaps;
-(void) dealloc;
-(void) setGamma: (id*) gamma;
-(void) setTau: (id<ORTau>) tau;
-(void) setLambda: (id<ORLambda>) lambda;
-(id*) gamma;
-(id<ORTau>) tau;
-(id<ORLambda>) lambda;
-(id) concretize: (id) o;
@end