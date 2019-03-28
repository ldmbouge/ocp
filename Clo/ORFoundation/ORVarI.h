/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORVar.h>
#import <ORFoundation/ORExprI.h>
#import <ORFoundation/ORVisit.h>


@interface ORIntVarI : ORExprI<ORIntVar,NSCoding>
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker domain: (id<ORIntRange>) domain;
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker bounds: (id<ORIntRange>) domain;
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker domain: (id<ORIntRange>) domain name:(NSString*) name;
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) tracker bounds: (id<ORIntRange>) domain name:(NSString*) name;
-(id<ORIntRange>) domain;
-(ORInt) value;
-(ORInt)scale;
-(ORInt)shift;
-(id<ORIntVar>)base;
-(NSString*) prettyname;
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
-(ORRealVarI*) init: (id<ORTracker>) tracker name:(NSString*) name;
-(ORRealVarI*) init: (id<ORTracker>) tracker up: (ORDouble) up;
-(ORRealVarI*) init: (id<ORTracker>) tracker low: (ORDouble) low up: (ORDouble) up;
-(ORRealVarI*) init: (id<ORTracker>) tracker low: (ORDouble) low up: (ORDouble) up name:(NSString*) name;
-(void)setDomain:(id<ORRealRange>)domain;
-(ORBool) hasBounds;
-(ORDouble) low;
-(ORDouble) up;
-(void) visit: (ORVisitor*)v;
-(void) encodeWithCoder:(NSCoder *)aCoder;
-(id) initWithCoder:(NSCoder *)aDecoder;
-(enum ORVType) vtype;
@end
//-------------------
@interface ORFloatVarI : ORExprI<ORFloatVar>
-(ORFloatVarI*) init: (id<ORTracker>) tracker;
-(ORFloatVarI*) init: (id<ORTracker>) tracker domain:(id<ORFloatRange>)dom;
-(ORFloatVarI*) init: (id<ORTracker>) tracker up: (ORFloat) up;
-(ORFloatVarI*) init: (id<ORTracker>) tracker low: (ORFloat) low up: (ORFloat) up;
-(ORFloatVarI*) init: (id<ORTracker>) tracker name:(NSString*) name;
-(ORFloatVarI*) init: (id<ORTracker>) tracker up: (ORFloat) up name:(NSString*) name;
-(ORFloatVarI*) init: (id<ORTracker>) tracker low: (ORFloat) low up: (ORFloat) up name:(NSString*) name;
-(ORBool) hasBounds;
-(ORFloat) low;
-(ORFloat) up;
-(NSString*) prettyname;
-(id<ORFloatRange>) domain;
-(void) visit: (ORVisitor*)v;
-(void) encodeWithCoder:(NSCoder *)aCoder;
-(id) initWithCoder:(NSCoder *)aDecoder;
-(enum ORVType) vtype;
@end


@interface ORDoubleVarI : ORExprI<ORDoubleVar>
-(ORDoubleVarI*) init: (id<ORTracker>) tracker;
-(ORDoubleVarI*) init: (id<ORTracker>) tracker domain:(id<ORDoubleRange>) dom;
-(ORDoubleVarI*) init: (id<ORTracker>) tracker up: (ORDouble) up;
-(ORDoubleVarI*) init: (id<ORTracker>) tracker low: (ORDouble) low up: (ORDouble) up;
-(ORDoubleVarI*) init: (id<ORTracker>) tracker name:(NSString*) name;
-(ORDoubleVarI*) init: (id<ORTracker>) tracker domain:(id<ORDoubleRange>) dom name:(NSString*) name;
-(ORDoubleVarI*) init: (id<ORTracker>) tracker up: (ORDouble) up name:(NSString*) name;
-(ORDoubleVarI*) init: (id<ORTracker>) tracker low: (ORDouble) low up: (ORDouble) up name:(NSString*) name;
-(ORBool) hasBounds;
-(ORDouble) low;
-(ORDouble) up;
-(NSString*) prettyname;
-(void) visit: (ORVisitor*)v;
-(void) encodeWithCoder:(NSCoder *)aCoder;
-(id) initWithCoder:(NSCoder *)aDecoder;
-(enum ORVType) vtype;
@end


@interface ORLDoubleVarI : ORExprI<ORLDoubleVar>
-(ORLDoubleVarI*) init: (id<ORTracker>) tracker;
-(ORLDoubleVarI*) init: (id<ORTracker>) tracker domain:(id<ORLDoubleRange>) dom;
-(ORLDoubleVarI*) init: (id<ORTracker>) tracker up: (ORLDouble) up;
-(ORLDoubleVarI*) init: (id<ORTracker>) tracker low: (ORLDouble) low up: (ORLDouble) up;
-(ORBool) hasBounds;
-(ORLDouble) low;
-(ORLDouble) up;
-(void) visit: (ORVisitor*)v;
-(void) encodeWithCoder:(NSCoder *)aCoder;
-(id) initWithCoder:(NSCoder *)aDecoder;
-(enum ORVType) vtype;
@end
//------------------------
@interface ORBitVarI : ORExprI<ORBitVar>
-(ORBitVarI*)initORBitVarI:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORInt)len;
-(ORBitVarI*)initORBitVarI:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORInt)len name:(NSString*) name;
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


@interface ORDisabledVarArrayI : ORObject<ORDisabledVarArray>
-(id<ORDisabledVarArray>) init:(id<ORVarArray>) vars engine:(id<ORSearchEngine>)engine;
-(id<ORDisabledVarArray>) init:(id<ORVarArray>) vars engine:(id<ORSearchEngine>)engine nbFixed:(ORUInt) nb;
-(id<ORDisabledVarArray>) init:(id<ORVarArray>) vars engine:(id<ORSearchEngine>)engine initials:(id<ORIntArray>) ia;
-(id<ORDisabledVarArray>) init:(id<ORVarArray>) vars engine:(id<ORSearchEngine>)engine initials:(id<ORIntArray>) ia nbFixed:(ORUInt) nb;
-(id<ORVar>) at: (ORInt) value;
-(void) set: (id<ORVar>) x at: (ORInt) value;
-(id<ORVar>) objectAtIndexedSubscript: (NSUInteger) key;
-(void) setObject: (id<ORVar>) newValue atIndexedSubscript: (NSUInteger) idx;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger) count;
-(ORUInt) maxFixed;
-(ORUInt) maxId;
-(void) setMaxFixed:(ORInt)nb;
-(void) disable:(ORUInt) index;
-(void) enable:(ORUInt) index;
-(ORUInt) enableFirst;
-(ORBool) isEnabled:(ORUInt) index;
-(ORBool) isInitial:(ORUInt) index;
-(ORBool) isFullyDisabled;
-(ORBool) hasDisabled;
-(ORInt) indexLastDisabled;
-(id<ORDisabledVarArray>) initialVars:(id<ORSearchEngine>)engine;
-(id<ORDisabledVarArray>) initialVars:(id<ORSearchEngine>)engine maxFixed:(ORInt) nb;
@end
