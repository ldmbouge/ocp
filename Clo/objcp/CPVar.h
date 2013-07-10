/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORInterval.h>
#import <objcp/CPData.h>

@protocol CPEngine;
@protocol ORTracer;

@protocol CPVar <NSObject>
-(ORInt) getId;
-(id<ORTracker>)tracker;
-(id<CPEngine>)engine;
-(ORBool) bound;
-(NSSet*)constraints;
@end

enum CPVarClass {
   CPVCBare = 0,
   CPVCShift = 1,
   CPVCAffine = 2,
   CPVCEQLiteral = 3,
   CPVCLiterals = 4,
   CPVCFlip = 5
};

@protocol CPIntVar <CPVar>
-(enum CPVarClass)varClass;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds) bounds;
-(ORBool) member: (ORInt) v;
-(ORBool) isBool;
-(ORInt) scale;
-(ORInt) shift;
-(id<ORIntVar>) base;
-(ORBool) bound;
-(ORInt)countFrom:(ORInt)from to:(ORInt)to;
-(ORStatus) bind:(ORInt) val;
-(ORStatus) remove:(ORInt) val;
-(ORStatus) inside:(id<ORIntSet>) S;
-(ORStatus) updateMin: (ORInt) newMin;
-(ORStatus) updateMax: (ORInt) newMax;
-(ORStatus) updateMin: (ORInt) newMin andMax:(ORInt)newMax;
@end

@protocol CPVarArray <ORVarArray>
-(id<CPVar>) at: (ORInt) value;
-(void) set: (id<CPVar>) x at: (ORInt) value;
-(id<CPVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol CPIntVarArray <CPVarArray>
-(id<CPIntVar>) at: (ORInt) value;
-(void) set: (id<CPIntVar>) x at: (ORInt) value;
-(id<CPIntVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPIntVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(id<ORASolver>) solver;
@end

@protocol CPIntVarMatrix <ORIdMatrix>
-(ORInt) arity;
-(id<CPIntVar>) flat:(ORInt)i;
-(id<CPIntVar>) at: (ORInt) i1 : (ORInt) i2;
-(id<CPIntVar>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORASolver>) solver;
@end

@protocol CPFloatVar<CPVar>
-(ORFloat) min;
-(ORFloat) max;
-(ORFloat) value;
-(ORInterval) bounds;
-(ORBool) member:(ORFloat)v;
-(ORBool) bound;
-(ORStatus) bind:(ORFloat) val;
-(ORStatus) updateMin:(ORFloat) newMin;
-(ORStatus) updateMax:(ORFloat) newMax;
-(ORStatus) updateInterval:(ORInterval)v;
@end
