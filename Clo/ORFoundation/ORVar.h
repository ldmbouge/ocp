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
#import "ORConstraint.h"

@protocol ORSnapshot
-(ORInt)  intValue;
-(ORBool) boolValue;
-(ORFloat) floatValue;
@end

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

@protocol ORBitVar <ORVar>
-(ORUInt*)low;
-(ORUInt*)up;
//-(ORBounds) bounds;
-(ORUInt) bitLength;
//-(ORInt)  domsize;
//-(ORULong) numPatterns;
//-(ORULong) maxRank;
//-(ORULong) getRank:(ORUInt*)r;
//-(ORUInt*) atRank:(ORULong) r;
//-(ORStatus) bind:(unsigned int*)val;
//-(BOOL) member: (unsigned int*) v;
//-(bool) isFree:(ORUInt)pos;
//-(ORUInt) lsFreeBit;
//-(ORUInt) msFreeBit;
-(NSString*)stringValue;
@end

@protocol ORFloatVar <ORVar>
-(ORBool) hasBounds;
-(ORFloat) low;
-(ORFloat) up;
@end

@protocol ORVarArray <ORIdArray>
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

@protocol ORBitVarArray <ORVarArray>
-(id<ORBitVar>) at: (ORInt) value;
-(void) set: (id<ORBitVar>) x at: (ORInt) value;
-(id<ORBitVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORBitVar>) newValue atIndexedSubscript: (NSUInteger) idx;
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
