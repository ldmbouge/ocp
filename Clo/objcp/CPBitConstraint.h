/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitVarI.h>
#import <objcp/CPIntVarI.h>
//#import <CPUKernel/CPBVConstraintI.h>

#define UP_MASK 0xFFFFFFFF

#define BIT_CONSISTENT_CHECK

struct _CPBitAssignment;
typedef struct _CPBitAssignment CPBitAssignment;

struct _CPBitAntecedents;
typedef struct _CPBitAntecedents CPBitAntecedents;

@interface CPFactory (BitConstraint)
//Bit Constraints
+(id<CPBVConstraint>) bitEqualAt:(CPBitVarI*)x at:(ORInt)k to:(ORInt)c;
+(id<CPBVConstraint>) bitEqualc:(id<CPBitVar>)x to:(ORInt)c;
+(id<CPBVConstraint>) bitEqual:(id<CPBitVar>)x to:(id<CPBitVar>)y;
+(id<CPBVConstraint>) bitAND:(id<CPBitVar>)x band:(id<CPBitVar>)y equals:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitOR:(id<CPBitVar>)x bor:(id<CPBitVar>)y equals:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitXOR:(id<CPBitVar>)x bxor:(id<CPBitVar>)y equals:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitNOT:(id<CPBitVar>)x equals:(id<CPBitVar>) y;
+(id<CPBVConstraint>) bitShiftL:(id<CPBitVar>)x by:(int) p equals:(id<CPBitVar>) y;
+(id<CPBVConstraint>) bitShiftR:(id<CPBitVar>)x by:(int) p equals:(id<CPBitVar>) y;
+(id<CPBVConstraint>) bitShiftRBV:(id<CPBitVar>)x by:(id<CPBitVar>) p equals:(id<CPBitVar>) y;
+(id<CPBVConstraint>) bitShiftRA:(id<CPBitVar>)x by:(int) p equals:(id<CPBitVar>) y;
+(id<CPBVConstraint>) bitShiftRABV:(id<CPBitVar>)x by:(id<CPBitVar>) p equals:(id<CPBitVar>) y;
+(id<CPBVConstraint>) bitShiftLBV:(CPBitVarI*)x by:(CPBitVarI*) p equals:(CPBitVarI*) y;
+(id<CPBVConstraint>) bitRotateL:(id<CPBitVar>)x by:(int) p equals:(id<CPBitVar>) y;
+(id<CPBVConstraint>) bitNegative:(id<CPBitVar>)x equals:(id<CPBitVar>) y;
+(id<CPBVConstraint>) bitADD:(id<CPBitVar>)x plus:(id<CPBitVar>) y withCarryIn:(id<CPBitVar>) cin equals:(id<CPBitVar>) z withCarryOut:(id<CPBitVar>) cout;
+(id<CPBVConstraint>) bitSubtract:(id<CPBitVar>)x minus:(id<CPBitVar>) y equals:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitMultiply:(id<CPBitVar>)x times:(id<CPBitVar>) y equals:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitDivide:(id<CPBitVar>)x dividedby:(id<CPBitVar>) y equals:(id<CPBitVar>)q rem:(id<CPBitVar>) r;
+(id<CPBVConstraint>) bitIF:(id<CPBitVar>)w equalsOneIf:(id<CPBitVar>)x equals:(id<CPBitVar>)y andZeroIfXEquals:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitCount:(id<CPBitVar>)x count:(id<CPIntVar>)y;
+(id<CPBVConstraint>) bitZeroExtend:(id<CPBitVar>)x extendTo:(id<CPBitVar>)y;
+(id<CPBVConstraint>) bitSignExtend:(id<CPBitVar>)x extendTo:(id<CPBitVar>)y;
+(id<CPBVConstraint>) bitExtract:(id<CPBitVar>)x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<CPBitVar>)y;
+(id<CPBVConstraint>) bitConcat:(id<CPBitVar>)x concat:(id<CPBitVar>)y eq:(id<CPBitVar>)z;
+(id<CPBVConstraint>) bitLT:(id<CPBitVar>)x LT:(id<CPBitVar>)y eval:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitLE:(id<CPBitVar>)x LE:(id<CPBitVar>)y eval:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitSLE:(id<CPBitVar>)x SLE:(id<CPBitVar>)y eval:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitSLT:(id<CPBitVar>)x SLT:(id<CPBitVar>)y eval:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitITE:(id<CPBitVar>)i then:(id<CPBitVar>)t else:(id<CPBitVar>) e result:(id<CPBitVar>)r;
+(id<CPBVConstraint>) bitLogicalEqual:(id<CPBitVar>)x EQ:(id<CPBitVar>)y eval:(id<CPBitVar>)r;
+(id<CPBVConstraint>) bitLogicalAnd:(id<CPBitVarArray>)x eval:(id<CPBitVar>)r;
+(id<CPBVConstraint>) bitLogicalOr:(id<CPBitVarArray>)x eval:(id<CPBitVar>)r;
+(id<CPBVConstraint>) bitOrb:(id<CPBitVar>)x bor:(id<CPBitVar>)y eval:(id<CPBitVar>)r;
+(id<CPBVConstraint>) bitEqualb:(id<CPBitVar>)x equal:(id<CPBitVar>)y eval:(id<CPBitVar>)r;
+(id<CPBVConstraint>) bitNotb:(id<CPBitVar>)x eval:(id<CPBitVar>)r;
+(id<CPBVConstraint>) bitConflict:(CPBitAntecedents*)a;
+(id<CPBVConstraint>) bitDistinct:(id<CPBitVar>)x distinctFrom:(id<CPBitVar>)y eval:(id<CPBitVar>)z;
@end

@interface CPBitEqualAt : CPCoreConstraint<CPBVConstraint> {
   @private
   CPBitVarI* _x;
   ORInt     _at;
   ORInt      _c;
   ORUInt** _state;
}
-(id)init:(CPBitVarI*)x at:(ORInt)bit to:(ORInt)v;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;
-(void) post;
@end

@interface CPBitEqualc : CPCoreConstraint<CPBVConstraint> {
@private
   CPBitVarI*  _x;
   ORInt       _c;
   ORUInt**    _state;
}
-(id) initCPBitEqualc: (CPBitVarI*) x and: (ORInt) c ;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;
-(void) post;
@end

@interface CPBitEqual : CPCoreConstraint<CPBVConstraint> {
@private
    CPBitVarI*  _x;
    CPBitVarI*  _y;
    ORUInt**    _state;
}
-(id) initCPBitEqual: (CPBitVarI*) x and: (CPBitVarI*) y ;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitNOT : CPCoreConstraint<CPBVConstraint>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;    
    ORUInt**    _state;
}
-(id) initCPBitNOT: (CPBitVarI*) x equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitAND : CPCoreConstraint<CPBVConstraint>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;
   ORUInt**    _state;
}
-(id) initCPBitAND: (CPBitVarI*) x band: (CPBitVarI*) y equals: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitOR : CPCoreConstraint<CPBVConstraint>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;    
   ORUInt**    _state;
}
-(id) initCPBitOR: (CPBitVarI*) x bor: (CPBitVarI*) y equals: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitXOR : CPCoreConstraint<CPBVConstraint>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;    
   ORUInt**    _state;
}
-(id) initCPBitXOR: (CPBitVarI*) x bxor: (CPBitVarI*) y equals: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitIF : CPCoreConstraint<CPBVConstraint>{
@private 
    CPBitVarI* _w;
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;    
   ORUInt**    _state;
}
-(id) initCPBitIF: (CPBitVarI*) w equalsOneIf:(CPBitVarI*) x equals: (CPBitVarI*) y andZeroIfXEquals: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
@end

@interface CPBitShiftL : CPCoreConstraint<CPBVConstraint>{
@private 
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    ORUInt    _places;
   ORUInt**    _state;
}
-(id) initCPBitShiftL: (CPBitVarI*) x shiftLBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitShiftLBV : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   CPBitVarI*    _places;
   ORUInt**    _state;
}
-(id) initCPBitShiftLBV: (CPBitVarI*) x shiftLBy:(CPBitVarI*) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end



@interface CPBitShiftR : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   ORUInt    _places;
   ORUInt**    _state;
}
-(id) initCPBitShiftR: (CPBitVarI*) x shiftRBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitShiftRBV : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   CPBitVarI*    _places;
   TRUInt        _placesBound;
   ORUInt**    _state;
}
-(id) initCPBitShiftRBV: (CPBitVarI*) x shiftRBy:(CPBitVarI*) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitShiftRA : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   ORUInt    _places;
   ORUInt**    _state;
}
-(id) initCPBitShiftRA: (CPBitVarI*) x shiftRBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitShiftRABV : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   CPBitVarI*    _places;
   TRUInt       _placesBound;
   ORUInt**    _state;
}
-(id) initCPBitShiftRABV: (CPBitVarI*) x shiftRBy:(CPBitVarI*) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitRotateL : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   ORUInt    _places;
   ORUInt**    _state;
}
-(id) initCPBitRotateL: (CPBitVarI*) x rotateLBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitADD: CPCoreConstraint<CPBVConstraint>
-(id) initCPBitAdd: (CPBitVarI*) x plus: (CPBitVarI*) y equals:(CPBitVarI*) z withCarryIn:(CPBitVarI*) cin andCarryOut:(CPBitVarI*)cout;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
@end

@interface CPBitSum: CPCoreConstraint<CPBVConstraint>
-(id) initCPBitSum: (CPBitVarI*) x plus: (CPBitVarI*) y equals:(CPBitVarI*) z withCarryIn:(CPBitVarI*) cin andCarryOut:(CPBitVarI*)cout;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
@end

@interface CPBitCount : CPCoreConstraint<CPBVConstraint> 
-(id) initCPBitCount: (CPBitVarI*) x count: (CPIntVarI*) p ;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitZeroExtend : CPCoreConstraint<CPBVConstraint> 
-(id) initCPBitZeroExtend: (CPBitVarI*) x extendTo: (CPBitVarI*) y ;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitSignExtend : CPCoreConstraint<CPBVConstraint> 
-(id) initCPBitSignExtend: (CPBitVarI*) x extendTo: (CPBitVarI*) y ;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitExtract : CPCoreConstraint<CPBVConstraint> 
-(id) initCPBitExtract: (CPBitVarI*) x from:(ORUInt)lsb to:(ORUInt)msb eq:(CPBitVarI*) y ;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitConcat : CPCoreConstraint<CPBVConstraint> {
@private
   CPBitVarI*  _x;
   CPBitVarI*  _y;
   CPBitVarI*  _z;
   ORUInt**    _state;
}
-(id) initCPBitConcat: (CPBitVarI*) x concat: (CPBitVarI*) y eq:(CPBitVarI*)z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitLogicalEqual : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   ORUInt**    _state;
}
-(id) initCPBitLogicalEqual: (CPBitVarI*) x EQ: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitLT : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   ORUInt*  _xUpCategories;
   ORUInt*  _xLowCategories;
   ORUInt*  _yUpCategories;
   ORUInt*  _yLowCategories;
   ORUInt _zUpCategory;
   ORUInt _zLowCategory;
   ORUInt**    _state;
}
-(id) initCPBitLT: (CPBitVarI*) x LT: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitLE : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   ORUInt*  _xcategories;
   ORUInt*  _ycategories;
   ORUInt _zcategory;
   ORUInt**    _state;
}
-(id) initCPBitLE: (CPBitVarI*) x LE: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitSLE : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   ORUInt*  _xcategories;
   ORUInt*  _ycategories;
   ORUInt _zcategory;
   ORUInt**    _state;
}
-(id) initCPBitSLE: (CPBitVarI*) x SLE: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitSLT : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   ORUInt*  _xcategories;
   ORUInt*  _ycategories;
   ORUInt _zcategory;
   ORUInt**    _state;
}
-(id) initCPBitSLT: (CPBitVarI*) x SLT: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitITE : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _i;
   CPBitVarI* _t;
   CPBitVarI* _e;
   CPBitVarI* _r;
   ORUInt*  _category;
   ORUInt**    _state;
}
-(id) initCPBitITE: (CPBitVarI*) i then: (CPBitVarI*) t else: (CPBitVarI*) e result:(CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitLogicalAnd : CPCoreConstraint<CPBVConstraint>{
@private
   id<CPBitVarArray> _x;
   CPBitVarI* _r;
   ORUInt**    _state;
}
-(id) initCPBitLogicalAnd:(id<CPBitVarArray>) x eval:(CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitLogicalOr : CPCoreConstraint<CPBVConstraint>{
@private
   id<CPBitVarArray> _x;
   CPBitVarI* _r;
   ORUInt**    _state;
}
-(id) initCPBitLogicalOr:(id<CPBitVarArray>) x eval:(CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitConflict : CPCoreConstraint<CPBVConstraint>{
@private
//   id<CPBitVarArray>       _vars;
//   ORUInt                   _bit;
//   ORUInt*       _conflictValues;
   CPBitAntecedents* _assignments;
   ORUInt**    _state;
}
//-(id) initCPBitConflict:(id<CPBitVarArray>)vars atBit:(ORUInt)conflictBit withValues:(ORUInt*)values;
-(id) initCPBitConflict:(CPBitAntecedents*)a;
-(void)dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAssignments;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end


//Boolean bit constraints for SMT solver
@interface CPBitORb : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _r;
   ORUInt**    _state;
}
-(id) initCPBitORb: (CPBitVarI*) x bor: (CPBitVarI*) y eval: (CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
@end

@interface CPBitNotb : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _r;
   ORUInt**    _state;
}
-(id) initCPBitNotb: (CPBitVarI*)x eval: (CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
@end

@interface CPBitEqualb : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _r;
   ORUInt**    _state;
}
-(id) initCPBitEqualb: (CPBitVarI*) x equals: (CPBitVarI*) y eval: (CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt **)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
@end

//@interface CPBitInc : CPCoreConstraint<CPBVConstraint>{
//@private
//   CPBitVarI* _x;
//   CPBitVarI* _y;
//}
//-(id) initCPBitInc:(CPBitVarI*) x equals: (CPBitVarI*)y;
//-(void) dealloc;
//-(NSString*) description;
//-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
//-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
//-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

//-(void) post;
//-(void) propagate;
//@end
@interface CPBitNegative : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _one;
   CPBitVarI* _notX;
   CPBitVarI* _negXCin;
   CPBitVarI* _negXCout;
//   CPBitVarI* _cin;
//   CPBitVarI* _cout;
   ORUInt**    _state;
}
-(id) initCPBitNegative: (CPBitVarI*) x equals: (CPBitVarI*)y;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitSubtract : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   CPBitVarI* _one;
   CPBitVarI* _notY;
   CPBitVarI* _negY;
   CPBitVarI* _negYCin;
   CPBitVarI* _negYCout;
   CPBitVarI* _cin;
   CPBitVarI* _cout;
}
-(id) initCPBitSubtract: (CPBitVarI*) x minus: (CPBitVarI*) y equals: (CPBitVarI*)z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
@end

@interface CPBitMultiply : CPCoreConstraint<CPBVConstraint>
-(id) initCPBitMultiply: (CPBitVarI*) x times: (CPBitVarI*) y equals: (CPBitVarI*)z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*) assignment;

-(void) post;
-(void) propagate;
@end

@interface CPBitDivide : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _q;
   CPBitVarI* _r;
   CPBitVarI* _product;
   CPBitVarI* _cin;
   CPBitVarI* _cout;
   CPBitVarI* _trueVal;
}
-(id) initCPBitDivide: (CPBitVarI*) x dividedby: (CPBitVarI*) y equals: (CPBitVarI*)q rem:(CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment withState:(ORUInt**)state;

-(void) post;
-(void) propagate;
@end


@interface CPBitDistinct : CPCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   CPBitVarI* _equal;
   ORUInt**    _state;
}
-(id) initCPBitDistinct: (CPBitVarI*) x distinctFrom: (CPBitVarI*) y eval: (CPBitVarI*)z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
@end
