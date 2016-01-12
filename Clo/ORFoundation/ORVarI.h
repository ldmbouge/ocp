/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
//<<<<<<< HEAD
//#import "ORArray.h"
//#import "ORSet.h"
//#import "ORConstraint.h"
//#import "ORVar.h"
//#import "ORExprI.h"
//#import "ORFoundation/ORVisit.h"
//=======
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORVar.h>
#import <ORFoundation/ORExprI.h>
#import <ORFoundation/ORVisit.h>
//>>>>>>> master


@interface ORIntVarI : ORExprI<ORIntVar,NSCoding>
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker domain: (id<ORIntRange>) domain;
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker bounds: (id<ORIntRange>) domain;
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(void) visit: (ORVisitor*)v;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(enum ORVType) vtype;
@end

@interface ORIntVarAffineI : ORIntVarI
-(ORIntVarAffineI*)initORIntVarAffineI:(id<ORTracker>)tracker var:(id<ORIntVar>)x scale:(ORInt)a shift:(ORInt)b;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(void) visit: (ORVisitor*)v;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORIntVarLitEQView : ORIntVarI
-(ORIntVarLitEQView*)initORIntVarLitEQView:(id<ORTracker>)tracker var:(id<ORIntVar>)x eqi:(ORInt)lit;
-(ORInt)literal;
-(id<ORIntVar>)base;
-(void) visit: (ORVisitor*)v;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface ORRealVarI : ORExprI<ORRealVar>
-(ORRealVarI*) init: (id<ORTracker>) tracker;
-(ORRealVarI*) init: (id<ORTracker>) tracker up: (ORDouble) up;
-(ORRealVarI*) init: (id<ORTracker>) tracker low: (ORDouble) low up: (ORDouble) up;
-(ORBool) hasBounds;
-(ORDouble) low;
-(ORDouble) up;
-(void) visit: (ORVisitor*)v;
-(void) encodeWithCoder:(NSCoder *)aCoder;
-(id) initWithCoder:(NSCoder *)aDecoder;
-(enum ORVType) vtype;
@end

@interface ORBitVarI : ORExprI<ORBitVar>
-(ORBitVarI*)initORBitVarI:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORInt)len;
-(ORUInt*)low;
-(ORUInt*)up;
-(ORUInt)bitLength;


//-(ORInt)  domsize;
//-(ORULong)  numPatterns;
//-(ORULong)  maxRank;
//-(ORULong)  getRank:(ORUInt *)v;
//-(ORUInt*)  atRank:(ORULong)r;
//-(ORStatus) bind:(unsigned int *)val;
//-(bool) member: (unsigned int*) v;
-(void) visit: (ORVisitor*)v;
-(NSString*)stringValue;
-(enum ORVType) vtype;
@end

@interface ORVarLitterals : ORObject<ORVarLitterals>
-(ORVarLitterals*) initORVarLitterals: (id<ORTracker>) tracker var: (id<ORIntVar>) var;
-(ORInt) low;
-(ORInt) up;
-(id<ORIntVar>) litteral: (ORInt) i;
-(BOOL) exist: (ORInt) i;
-(NSString*) description;
@end
