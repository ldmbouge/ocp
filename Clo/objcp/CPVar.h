/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORModel.h>
#import <objcp/CPData.h>

@protocol CPEngine;
@protocol ORTracer;
@protocol CPBitVar;

@protocol CPVar <NSObject>
-(ORInt) getId;
-(id<ORVar>) dereference;
-(id<ORTracker>)tracker;
-(id<CPEngine>)engine;
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
-(BOOL) member: (ORInt) v;
-(BOOL) isBool;
-(id<ORIntVar>) dereference;
-(ORInt) scale;
-(ORInt) shift;
-(id<ORIntVar>) base;
-(BOOL) bound;
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

@protocol CPBitVarArray <CPVarArray>
-(id<CPIntVar>) at: (ORInt) value;
-(void) set: (id<CPBitVar>) x at: (ORInt) value;
-(id<CPBitVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<CPBitVar>) newValue atIndexedSubscript: (NSUInteger) idx;
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
