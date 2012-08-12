/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPSolver.h"
#import "ORTrail.h"
#import "CPTypes.h"
#import "CPBitDom.h"
#import "CPConstraintI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@interface CPTRIntArrayI : NSObject<CPTRIntArray,CPVirtual,NSCoding> {
    @package
    id<CPSolver>       _cp;
    ORTrail*     _trail;
    TRInt*       _array;
    ORInt        _low;
    ORInt        _up;
    ORInt        _nb;
}
-(CPTRIntArrayI*) initCPTRIntArray: (id<CPSolver>) cp range: (id<ORIntRange>) R;
-(void) dealloc;
-(ORInt) at: (ORInt) value;
-(void) set: (ORInt) value at: (ORInt) idx;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger) count;
-(NSString*) description;
-(id<CPSolver>) cp;
-(ORInt) virtualOffset;   
- (void) encodeWithCoder:(NSCoder *) aCoder;
- (id) initWithCoder:(NSCoder *) aDecoder;
@end

@interface CPIntMatrixI : NSObject<ORIntMatrix,CPVirtual,NSCoding> {
@private
    id<CPSolver>          _cp;
    ORTrail*        _trail;
    ORInt*          _flat;
    ORInt           _arity;
    id<ORIntRange>* _range;
    ORInt*          _low;
    ORInt*          _up;
    ORInt*          _size;
    ORInt*          _i;
    ORInt           _nb;
}
-(CPIntMatrixI*) initCPIntMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
-(CPIntMatrixI*) initCPIntMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
-(void) dealloc;  
-(ORInt) at: (ORInt) i0 : (ORInt) i1; 
-(ORInt) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2; 
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1; 
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2; 
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger) count;
-(id<CPSolver>) solver;
-(id<CPEngine>) engine;
-(ORInt) virtualOffset;   
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id)initWithCoder: (NSCoder*) aDecoder;
@end


@interface CPTRIntMatrixI : NSObject<CPTRIntMatrix,CPVirtual,NSCoding> {
@private
    id<CPSolver>    _cp;
    ORTrail*        _trail;
    TRInt*          _flat;
    ORInt           _arity;
    id<ORIntRange>* _range;
    ORInt*          _low;
    ORInt*          _up;
    ORInt*          _size;
    ORInt*          _i;
    ORInt           _nb;
}
-(CPTRIntMatrixI*) initCPTRIntMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1;
-(CPTRIntMatrixI*) initCPTRIntMatrix: (id<CPSolver>) cp range: (id<ORIntRange>) r0 : (id<ORIntRange>) r1 : (id<ORIntRange>) r2;
-(void) dealloc;  
-(ORInt) at: (ORInt) i0 : (ORInt) i1; 
-(ORInt) at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2; 
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1; 
-(void) set: (ORInt) value at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2; 
-(ORInt) add:(ORInt) delta at: (ORInt) i0 : (ORInt) i1;
-(ORInt) add:(ORInt) delta at: (ORInt) i0 : (ORInt) i1 : (ORInt) i2;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger) count;
-(id<CPSolver>) solver;
-(id<CPEngine>) engine;
-(ORInt) virtualOffset;   
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
@end

