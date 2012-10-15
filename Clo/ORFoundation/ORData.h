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
   Soft
} ORAnnotation;


@protocol ORExpr;
@protocol ORIntRange;
@protocol ORVisitor;

@protocol ORObject <NSObject>
-(id) dereference;
-(void) visit: (id<ORVisitor>) visitor;
@end;

@interface NSObject (Concretization)
-(id) dereference;
@end;

@protocol ORInteger <ORObject,ORExpr>
-(ORInt)  value;
-(void) setValue: (ORInt) value;
-(void) incr;
-(void) decr;
@end

@protocol ORTrailableInt <ORObject>
-(ORInt) value;
-(void)  setValue: (ORInt) value;
-(void)  incr;
-(void)  decr;
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

@protocol ORTable <NSObject>
-(void) insert: (ORInt) i : (ORInt) j : (ORInt) k;
-(void) addEmptyTuple;
-(void) fill: (ORInt) j with: (ORInt) val;
-(void) print;
-(void) close;
@end

@interface ORTableI : NSObject<ORTable,NSCoding> {
   @public
   ORInt   _arity;
   ORInt   _nb;
   ORInt   _size;
   ORInt** _column;
   bool    _closed;
   ORInt*  _min;          // _min[j] is the minimum value in column[j]
   ORInt*  _max;          // _max[j] is the maximun value in column[j]
   ORInt** _nextSupport;  // _nextSupport[j][i] is the next support of element j in tuple i
   ORInt** _support;      // _support[j][v] is the support (a row index) of value v in column j
}
-(ORTableI*) initORTableI: (ORInt) arity;
-(void) dealloc;
-(void) insert: (ORInt) i : (ORInt) j : (ORInt) k;
-(void) addEmptyTuple;
-(void) fill: (ORInt) j with: (ORInt) val;
-(void) close;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
-(void) print;
@end
