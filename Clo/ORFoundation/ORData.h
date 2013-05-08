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
-(id) dereference;
-(void) setImpl: (id) impl;
-(id) impl;
-(void) makeImpl;
-(void) visit: (id<ORVisitor>) visitor;
@end;

@protocol ORGamma <NSObject>
-(id<ORObject>) concretize: (id<ORObject>) o;
@end

@interface NSObject (Concretization)
-(id) dereference;
-(void) setImpl: (id) impl;
-(id) impl;
-(void) makeImpl;
-(void) visit: (id<ORVisitor>) visitor;
@end;

@protocol ORInteger <ORObject,ORExpr>
-(ORInt) initialValue;
-(ORInt) setValue: (ORInt) value in: (id<ORGamma>) solver;
-(ORInt) incr: (id<ORGamma>) solver;
-(ORInt) decr: (id<ORGamma>) solver;
-(ORInt) value: (id<ORGamma>) solver;
-(ORInt) intValue: (id<ORGamma>) solver;
-(ORFloat) floatValue: (id<ORGamma>) solver;
@end

@protocol ORFloatNumber <ORObject,ORExpr>
-(ORFloat) value;
-(ORFloat) floatValue;
-(ORFloat) setValue: (ORFloat) value;
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
+(id<ORInteger>) integer:(ORInt) value;
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
-(id) dereference;
@end



@interface ORGamma : NSObject<ORGamma>
{
@protected
   id* _gamma;
}
-(ORGamma*) initORGamma;
-(void) dealloc;
-(void) setGamma: (id*) gamma;
-(id*) gamma;
-(id) concretize: (id) o;
@end