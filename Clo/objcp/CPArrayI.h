/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CP.h"
#import "ORTrail.h"
#import "CPTypes.h"
#import "CPBitDom.h"
#import "CPConstraintI.h"
#import "CPDataI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@interface CPIntArrayI : NSObject<CPVirtual,NSCoding,CPIntArray> {
    id<CP>   _cp;
    CPInt*   _array;
    CPInt    _low;
    CPInt    _up;
    CPInt    _nb;
}
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp size: (CPInt) nb value: (CPInt) v;
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp size: (CPInt) nb with: (CPInt(^)(CPInt)) clo;
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp range: (CPRange) range value: (CPInt) v;
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp range: (CPRange) range with: (CPInt(^)(CPInt)) clo;
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp range: (CPRange) r1 range: (CPRange) r2 with:(CPInt(^)(CPInt,CPInt)) clo;
-(void) dealloc;
-(CPInt) at: (CPInt) value;
-(CPInt) low;
-(CPInt) up;
-(NSUInteger)count;
-(NSString*)description;
-(id<CP>) cp;
-(CPInt)virtualOffset;   
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface CPVarArrayI : NSObject<CPVirtual,CPVarArray,NSCoding> {
   id<CP>         _cp;
   id<CPVar>*  _array;
   CPInt         _low;
   CPInt          _up;
   CPInt          _nb;   
}
-(CPVarArrayI*)initCPVarArray: (id<CP>) cp range:(CPRange)range;
-(id<CPVar>) at: (CPInt) value;
-(void) set: (id<CPVar>) x at: (CPInt) value;
-(CPInt) low;
-(CPInt) up;
-(NSUInteger)count;
-(NSString*)description;
-(id<CP>) cp;
-(id<CPSolver>) solver;
-(CPInt) virtualOffset;   
-(void)encodeWithCoder:(NSCoder*) aCoder;
-(id)initWithCoder:(NSCoder*) aDecoder;
@end

@interface CPIntVarArrayI : NSObject<CPVirtual,NSCoding,CPIntVarArray> {
    id<CP>         _cp;
    id<CPIntVar>*  _array;
    CPInt          _low;
    CPInt          _up;
    CPInt          _nb;
}
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp size: (CPInt) nb domain: (CPRange) domain;
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp size: (CPInt) nb with:(CPIntVarI*(^)(CPInt)) clo;
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp range: (CPRange) range domain: (CPRange) domain;
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp range: (CPRange) range;
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp range: (CPRange) range with:(id<CPIntVar>(^)(CPInt)) clo;
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2  with:(id<CPIntVar>(^)(CPInt,CPInt)) clo;
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp range: (CPRange) r1 : (CPRange) r2  : (CPRange) r3 with:(id<CPIntVar>(^)(CPInt,CPInt,CPInt)) clo;
-(void) dealloc;
-(id<CPIntVar>) at: (CPInt) value;
-(void) set: (id<CPIntVar>) x at: (CPInt) value;
-(CPInt) low;
-(CPInt) up;
-(NSUInteger)count;
-(NSString*)description;
-(id<CP>) cp;
-(id<CPSolver>) solver;
-(CPInt)virtualOffset;   
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end


@interface CPIntVarMatrixI : NSObject<CPIntVarMatrix,CPVirtual,NSCoding> {
@private
    id<CP>         _cp;
    id<CPIntVar>*  _flat;
    CPInt          _arity;
    CPRange*       _range;
    CPInt*         _low;
    CPInt*         _up;
    CPInt*         _size;
     CPInt*        _i;
    CPInt          _nb;
}
-(CPIntVarMatrixI*) initCPIntVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 domain: (CPRange) domain;
-(CPIntVarMatrixI*) initCPIntVarMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2 domain: (CPRange) domain;
-(void) dealloc;  
-(id<CPIntVar>) at: (CPInt) i0 : (CPInt) i1; 
-(id<CPIntVar>) at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2; 
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(id<CP>) cp;
-(id<CPSolver>) solver;
-(CPInt) virtualOffset;   
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface CPTRIntArrayI : NSObject<CPTRIntArray,CPVirtual,NSCoding> {
    @package
    id<CP>       _cp;
    ORTrail*     _trail;
    TRInt*       _array;
    CPInt        _low;
    CPInt        _up;
    CPInt        _nb;
}
-(CPTRIntArrayI*) initCPTRIntArray: (id<CP>) cp range: (CPRange) R;
-(void) dealloc;
-(CPInt) at: (CPInt) value;
-(void) set: (CPInt) value at: (CPInt) idx;
-(CPInt) low;
-(CPInt) up;
-(NSUInteger)count;
-(NSString*)description;
-(id<CP>) cp;
-(CPInt)virtualOffset;   
- (void)encodeWithCoder:(NSCoder *) aCoder;
- (id)initWithCoder:(NSCoder *) aDecoder;
@end

@interface CPIntMatrixI : NSObject<CPIntMatrix,CPVirtual,NSCoding> {
@private
    id<CP>         _cp;
    ORTrail*       _trail;
    CPInt*         _flat;
    CPInt          _arity;
    CPRange*       _range;
    CPInt*         _low;
    CPInt*         _up;
    CPInt*         _size;
    CPInt*         _i;
    CPInt          _nb;
}
-(CPIntMatrixI*) initCPIntMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1;
-(CPIntMatrixI*) initCPIntMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2;
-(void) dealloc;  
-(CPInt) at: (CPInt) i0 : (CPInt) i1; 
-(CPInt) at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2; 
-(void) set: (CPInt) value at: (CPInt) i0 : (CPInt) i1; 
-(void) set: (CPInt) value at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2; 
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(id<CP>) cp;
-(id<CPSolver>) solver;
-(CPInt) virtualOffset;   
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end


@interface CPTRIntMatrixI : NSObject<CPTRIntMatrix,CPVirtual,NSCoding> {
@private
    id<CP>         _cp;
    ORTrail*       _trail;
    TRInt*         _flat;
    CPInt          _arity;
    CPRange*       _range;
    CPInt*         _low;
    CPInt*         _up;
    CPInt*         _size;
    CPInt*         _i;
    CPInt          _nb;
}
-(CPTRIntMatrixI*) initCPTRIntMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1;
-(CPTRIntMatrixI*) initCPTRIntMatrix: (id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2;
-(void) dealloc;  
-(CPInt) at: (CPInt) i0 : (CPInt) i1; 
-(CPInt) at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2; 
-(void) set: (CPInt) value at: (CPInt) i0 : (CPInt) i1; 
-(void) set: (CPInt) value at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2; 
-(CPRange) range: (CPInt) i;
-(NSUInteger)count;
-(id<CP>) cp;
-(id<CPSolver>) solver;
-(CPInt) virtualOffset;   
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

