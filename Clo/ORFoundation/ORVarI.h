/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORArray.h"
#import "ORSet.h"
#import "ORModel.h"
#import "ORVar.h"
#import "ORExprI.h"
#import "ORVisit.h"


@interface ORIntVarI : ORExprI<ORIntVar,NSCoding>
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker domain: (id<ORIntRange>) domain;
// [ldm] All the methods below were missing??????
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt) intValue;
-(ORFloat) floatValue;
-(ORInt) min;
-(ORInt) max;
-(ORInt) domsize;
-(ORBounds)bounds;
-(BOOL) member: (ORInt) v;
-(BOOL) isBool;
-(NSSet*)constraints;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(void) visit: (id<ORVisitor>)v;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORIntVarAffineI : ORIntVarI
-(ORIntVarAffineI*)initORIntVarAffineI:(id<ORTracker>)tracker var:(id<ORIntVar>)x scale:(ORInt)a shift:(ORInt)b;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(void) visit: (id<ORVisitor>)v;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORIntVarLitEQView : ORIntVarI
-(ORIntVarLitEQView*)initORIntVarLitEQView:(id<ORTracker>)tracker var:(id<ORIntVar>)x eqi:(ORInt)lit;
-(ORInt)literal;
-(id<ORIntVar>)base;
-(void) visit: (id<ORVisitor>)v;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORFloatVarI : ORExprI<ORFloatVar>
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) tracker;
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) tracker up: (ORFloat) up;
-(ORFloatVarI*) initORFloatVarI: (id<ORTracker>) tracker low: (ORFloat) low up: (ORFloat) up;
-(BOOL) hasBounds;
-(ORFloat) low;
-(ORFloat) up;
-(ORFloat) value;
-(ORFloat) floatValue;
-(ORFloat) min;
-(ORFloat) max;
-(NSSet*) constraints;
-(void) visit: (id<ORVisitor>)v;
-(void) encodeWithCoder:(NSCoder *)aCoder;
-(id) initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORBitVarI : ORExprI<ORBitVar>
-(ORBitVarI*)initORBitVarI:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORInt)len;
-(BOOL) bound;
-(uint64)min;
-(uint64)max;
-(ORUInt*)low;
-(ORUInt*)up;
-(ORUInt)bitLength;
-(unsigned int)  domsize;
-(bool) member: (unsigned int*) v;
-(void) visit: (id<ORVisitor>)v;
-(NSSet*) constraints;
-(NSString*)stringValue;
@end


