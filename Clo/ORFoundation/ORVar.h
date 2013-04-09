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
#import "ORModel.h"

@protocol ORSnapshot
-(void) restoreInto: (NSArray*) av;
-(int)  intValue;
-(BOOL) boolValue;
@end

@protocol ORSavable<NSObject>
-(ORInt) getId;
-(id) snapshot;
-(void)restore:(id<ORSnapshot>)s;
@end

@protocol ORVar <ORObject,ORSavable,ORExpr>
-(ORInt) getId;
-(BOOL) bound;
-(NSSet*) constraints;
@end

@protocol ORIntVar <ORVar>
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds) bounds;
-(BOOL) member: (ORInt) v;
-(BOOL) isBool;
-(ORInt)scale;
-(ORInt)shift;
-(ORInt)literal;
-(id<ORIntVar>)base;
@end

@protocol ORBitVar <ORVar>
-(BOOL) bound;
-(uint64)min;
-(uint64)max;
-(ORUInt*)low;
-(ORUInt*)up;
-(ORUInt)bitLength;
-(ORULong)  domsize;
-(BOOL) member: (unsigned int*) v;
-(NSString*)stringValue;
@end

@protocol ORFloatVar <ORVar>
-(ORFloat) value;
-(ORFloat) min;
-(ORFloat) max;
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

@protocol ORIntVarMatrix <ORIdMatrix>
-(ORInt) arity;
-(id<ORIntVar>) flat:(ORInt)i;
-(id<ORIntVar>) at: (ORInt) i1 : (ORInt) i2;
-(id<ORIntVar>) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2;
-(void) set: (id) x at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
-(id<ORASolver>) solver;
@end
