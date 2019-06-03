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

//struct _CPBitAssignment;
//typedef struct _CPBitAssignment CPBitAssignment;
//
//struct _CPBitAntecedents;
//typedef struct _CPBitAntecedents CPBitAntecedents;

typedef struct _CPBitAssignment {
    CPBitVarI* var;
    ORUInt   index;
    ORBool   value;
} CPBitAssignment;

typedef struct _CPBitAntecedents {
    CPBitAssignment**    antecedents;
    ORUInt            numAntecedents;
} CPBitAntecedents;


@interface CPFactory (BitConstraint)
//Bit Constraints
+(id<CPBVConstraint>) bitEqualAt:(id<CPBitVar>)x at:(ORInt)k to:(ORInt)c;
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
//+(id<CPBVConstraint>) bitMultiplyComposed:(id<CPBitVar>)x times:(id<CPBitVar>) y equals:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitDivide:(id<CPBitVar>)x dividedby:(id<CPBitVar>) y equals:(id<CPBitVar>)q rem:(id<CPBitVar>) r;
+(id<CPBVConstraint>) bitDivideSigned:(id<CPBitVar>)x dividedby:(id<CPBitVar>) y equals:(id<CPBitVar>) q rem:(id<CPBitVar>)r;
+(id<CPBVConstraint>) bitIF:(id<CPBitVar>)w equalsOneIf:(id<CPBitVar>)x equals:(id<CPBitVar>)y andZeroIfXEquals:(id<CPBitVar>) z;
+(id<CPBVConstraint>) bitCount:(id<CPBitVar>)x count:(id<CPIntVar>)y;
+(id<CPBVConstraint>) bitChannel:(id<CPBitVar>)x channel:(id<CPIntVar>)y;
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

@interface CPBitCoreConstraint : CPCoreConstraint<CPBVConstraint>
-(id)initCPBitCoreConstraint:(id<CPEngine>)engine;
-(CPBitAntecedents*) getAntecedents:(CPBitAssignment*)assignment;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*)assignment;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitEqualAt : CPBitCoreConstraint<CPBVConstraint> {
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
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;

@end

@interface CPBitEqualc : CPBitCoreConstraint<CPBVConstraint> {
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
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;

@end

@interface CPBitEqual : CPBitCoreConstraint<CPBVConstraint> {
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitNOT : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitAND : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitOR : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitXOR : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitIF : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitShiftL : CPBitCoreConstraint<CPBVConstraint>{
@private 
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    ORUInt    _places;
   ORUInt**    _state;
}
-(id) initCPBitShiftL: (CPBitVarI*) x shiftLBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitShiftLBV : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   CPBitVarI*    _places;
   ORUInt**    _state;
   ORUInt  *_pUps4X;
   ORUInt  *_pLows4X;
   ORUInt  *_pUps4Y;
   ORUInt  *_pLows4Y;
}
-(id) initCPBitShiftLBV: (CPBitVarI*) x shiftLBy:(CPBitVarI*) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end



@interface CPBitShiftR : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   ORUInt    _places;
   ORUInt**    _state;
}
-(id) initCPBitShiftR: (CPBitVarI*) x shiftRBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitShiftRBV : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   CPBitVarI*    _places;
      TRUInt       _placesBound;
   ORUInt**    _state;
   ORUInt  *_pUps4X;
   ORUInt  *_pLows4X;
   ORUInt  *_pUps4Y;
   ORUInt  *_pLows4Y;
}
-(id) initCPBitShiftRBV: (CPBitVarI*) x shiftRBy:(CPBitVarI*) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end


//@interface CPBitShiftRBV : CPBitCoreConstraint<CPBVConstraint>{
//@private
//   CPBitVarI*      _x;
//   CPBitVarI*      _y;
//   CPBitVarI*    _places;
//   TRUInt        _placesBound;
//   ORUInt**    _state;
//}
//-(id) initCPBitShiftRBV: (CPBitVarI*) x shiftRBy:(CPBitVarI*) places equals: (CPBitVarI*) y;
//-(void) dealloc;
//-(NSString*) description;
//-(void) post;
//-(void) propagate;
//-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
//@end

@interface CPBitShiftRA : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   ORUInt    _places;
   ORUInt**    _state;
}
-(id) initCPBitShiftRA: (CPBitVarI*) x shiftRBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitShiftRABV : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   CPBitVarI*    _places;
   ORUInt**    _state;
   ORUInt  *_pUps4X;
   ORUInt  *_pLows4X;
   ORUInt  *_pUps4Y;
   ORUInt  *_pLows4Y;
}
-(id) initCPBitShiftRABV: (CPBitVarI*) x shiftRBy:(CPBitVarI*) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

//@interface CPBitShiftRABV : CPBitCoreConstraint<CPBVConstraint>{
//@private
//   CPBitVarI*      _x;
//   CPBitVarI*      _y;
//   CPBitVarI*    _places;
//   TRUInt       _placesBound;
//   ORUInt**    _state;
//}
//-(id) initCPBitShiftRABV: (CPBitVarI*) x shiftRBy:(CPBitVarI*) places equals: (CPBitVarI*) y;
//-(void) dealloc;
//-(NSString*) description;
//-(void) post;
//-(void) propagate;
//-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
//@end

@interface CPBitRotateL : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   ORUInt    _places;
   ORUInt**    _state;
}
-(id) initCPBitRotateL: (CPBitVarI*) x rotateLBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitADD: CPBitCoreConstraint<CPBVConstraint>
-(id) initCPBitAdd: (CPBitVarI*) x plus: (CPBitVarI*) y equals:(CPBitVarI*) z withCarryIn:(CPBitVarI*) cin andCarryOut:(CPBitVarI*)cout;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitSum: CPBitCoreConstraint<CPBVConstraint>
-(id) initCPBitSum: (CPBitVarI*) x plus: (CPBitVarI*) y equals:(CPBitVarI*) z withCarryIn:(CPBitVarI*) cin andCarryOut:(CPBitVarI*)cout;
-(void) dealloc;
-(NSString*) description;
-(void) post;
@end

@interface CPBitCount : CPBitCoreConstraint<CPBVConstraint> 
-(id) initCPBitCount: (CPBitVarI*) x count: (CPIntVarI*) p ;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitChannel : CPBitCoreConstraint<CPBVConstraint>
-(id) init: (CPBitVarI*) x channel: (CPIntVarI*) p ;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagateIntToBit;
-(void) propagateBitToInt;
@end

@interface CPBitZeroExtend : CPBitCoreConstraint<CPBVConstraint> 
-(id) initCPBitZeroExtend: (CPBitVarI*) x extendTo: (CPBitVarI*) y ;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitSignExtend : CPBitCoreConstraint<CPBVConstraint> 
-(id) initCPBitSignExtend: (CPBitVarI*) x extendTo: (CPBitVarI*) y ;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitExtract : CPBitCoreConstraint<CPBVConstraint> 
-(id) initCPBitExtract: (CPBitVarI*) x from:(ORUInt)lsb to:(ORUInt)msb eq:(CPBitVarI*) y ;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitConcat : CPBitCoreConstraint<CPBVConstraint> {
@private
   CPBitVarI*  _x;
   CPBitVarI*  _y;
   CPBitVarI*  _z;
   ORUInt**    _state;
}
-(id) initCPBitConcat: (CPBitVarI*) x concat: (CPBitVarI*) y eq:(CPBitVarI*)z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitLogicalEqual : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   ORUInt**    _state;
}
-(id) initCPBitLogicalEqual: (CPBitVarI*) x EQ: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitLTComposed : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
}
-(id) initCPBitLTComposed: (CPBitVarI*) x LT: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitSLTComposed : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
}
-(id) initCPBitSLTComposed: (CPBitVarI*) x SLT: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end
@interface CPBitLEComposed : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
}
-(id) initCPBitLEComposed: (CPBitVarI*) x LE: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitSLEComposed : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
}
-(id) initCPBitSLEComposed: (CPBitVarI*) x SLE: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitLT : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
//   ORUInt*  _xUpCategories;
//   ORUInt*  _xLowCategories;
//   ORUInt*  _yUpCategories;
//   ORUInt*  _yLowCategories;
//   ORUInt _zUpCategory;
//   ORUInt _zLowCategory;
   ORUInt*  _xWhenZSet;
   ORUInt*  _yWhenZSet;
   ORUInt**    _state;
    
//    ORUInt** _xChanges;
//    ORUInt** _yChanges;
//    ORUInt** _zChanges;
//    TRUInt _top;
}
-(id) initCPBitLT: (CPBitVarI*) x LT: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitLE : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
//   ORUInt*  _xcategories;
//   ORUInt*  _ycategories;
//   ORUInt _zcategory;
   ORUInt**    _state;
//    ORUInt** _xChanges;
//    ORUInt** _yChanges;
//    ORUInt** _zChanges;
//    TRUInt _top;
   ORUInt*  _xWhenZSet;
   ORUInt*  _yWhenZSet;

}
-(id) initCPBitLE: (CPBitVarI*) x LE: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitSLE : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   ORUInt*  _xcategories;
   ORUInt*  _ycategories;
   ORUInt _zcategory;
   ORUInt**    _state;
//    ORUInt** _xChanges;
//    ORUInt** _yChanges;
//    ORUInt** _zChanges;
//    TRUInt _top;

}
-(id) initCPBitSLE: (CPBitVarI*) x SLE: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitSLT : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   ORUInt*  _xcategories;
   ORUInt*  _ycategories;
   ORUInt _zcategory;
   ORUInt**    _state;
//    ORUInt** _xChanges;
//    ORUInt** _yChanges;
//    ORUInt** _zChanges;
//    TRUInt _top;

}
-(id) initCPBitSLT: (CPBitVarI*) x SLT: (CPBitVarI*) y eval: (CPBitVarI*) z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitITE : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _i;
   CPBitVarI* _t;
   CPBitVarI* _e;
   CPBitVarI* _r;
   ORUInt*  _iWasSet;
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitLogicalAnd : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitLogicalOr : CPBitCoreConstraint<CPBVConstraint>{
@private
   id<CPBitVarArray> _x;
   CPBitVarI* _r;
   ORUInt**    _state;
}
-(id) initCPBitLogicalOr:(id<CPBitVarArray>) x eval:(CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitConflict : CPBitCoreConstraint<CPBVConstraint>{
@private
//   id<CPBitVarArray>       _vars;
//   ORUInt                   _bit;
//   ORUInt*       _conflictValues;
   CPBitAntecedents* _assignments;
   ORUInt**    _state;
   
   ULRep* _domainReps;
}
//-(id) initCPBitConflict:(id<CPBitVarArray>)vars atBit:(ORUInt)conflictBit withValues:(ORUInt*)values;
-(id) initCPBitConflict:(CPBitAntecedents*)a;
-(void)dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAssignments;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end


//Boolean bit constraints for SMT solver
@interface CPBitORb : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitNotb : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitEqualb : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _r;
   ORUInt**    _state;
}
-(id) initCPBitEqualb: (CPBitVarI*) x equals: (CPBitVarI*) y eval: (CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

//@interface CPBitInc : CPBitCoreConstraint<CPBVConstraint>{
//@private
//   CPBitVarI* _x;
//   CPBitVarI* _y;
//}
//-(id) initCPBitInc:(CPBitVarI*) x equals: (CPBitVarI*)y;
//-(void) dealloc;
//-(NSString*) description;
//-(void) post;
//-(void) propagate;
//-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
//@end

@interface CPBitNegative : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _one;
   CPBitVarI* _notX;
   CPBitVarI* _negXCin;
   CPBitVarI* _negXCout;
   ORUInt**    _state;
}
-(id) initCPBitNegative: (CPBitVarI*) x equals: (CPBitVarI*)y;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitSubtract : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _z;
   CPBitVarI* _one;
   CPBitVarI* _notY;
   CPBitVarI* _temp;
   CPBitVarI* _tempCin;
   CPBitVarI* _tempCout;

   CPBitVarI* _negY;
   CPBitVarI* _negYCin;
   CPBitVarI* _negYCout;
   CPBitVarI* _negZ;
   CPBitVarI* _negZCin;
   CPBitVarI* _negZCout;
   CPBitVarI* _cin;
    CPBitVarI* _cout;
   CPBitVarI* _cin2;
   CPBitVarI* _cout2;

//    CPBitVarI* _overflow;
}
-(id) initCPBitSubtract: (CPBitVarI*) x minus: (CPBitVarI*) y equals: (CPBitVarI*)z;
-(void) dealloc;
-(NSString*) description;
-(CPBitAntecedents*) getAntecedentsFor:(CPBitAssignment*) assignment;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitMultiplyComposed : CPBitCoreConstraint<CPBVConstraint>
-(id) initCPBitMultiplyComposed: (CPBitVarI*) x times: (CPBitVarI*) y equals: (CPBitVarI*)z;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitDivideComposed : CPBitCoreConstraint<CPBVConstraint>
-(id) initCPBitDivideComposed: (CPBitVarI*) dividend dividedBy: (CPBitVarI*) divisor  equals: (CPBitVarI*)quotient withRemainder:(CPBitVarI*)remainder;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end


//@interface CPBitMultiply : CPBitCoreConstraint<CPBVConstraint>
//-(id) initCPBitMultiply: (CPBitVarI*) x times: (CPBitVarI*) y equals: (CPBitVarI*)z;
//-(void) dealloc;
//-(NSString*) description;
//-(void) post;
//-(void) propagate;
//-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
//@end

@interface CPBitDivide : CPBitCoreConstraint<CPBVConstraint>{
@private
   CPBitVarI* _x;
   CPBitVarI* _y;
   CPBitVarI* _q;
   CPBitVarI* _r;
    CPBitVarI* _zeroBitVar;
    CPBitVarI* _oneBitVar;
    CPBitVarI* _falseVal;
   CPBitVarI* _product;
   CPBitVarI* _productLow;
   CPBitVarI* _productHigh;
   CPBitVarI* _cin;
   CPBitVarI* _cout;
   CPBitVarI* _trueVal;
//    CPBitVarI* _overflow;
    CPBitVarI* _xlty;
//    CPBitVarI* _yeq0;
//    CPBitVarI* _yneq0;
//    CPBitVarI* _qeq1;

//    CPBitVarI* _xeq0;
//    CPBitVarI* _xneq0;
}
-(id) initCPBitDivide: (CPBitVarI*) x dividedby: (CPBitVarI*) y equals: (CPBitVarI*)q rem:(CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end

@interface CPBitDivideSigned : CPBitCoreConstraint<CPBVConstraint>{
@private
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _q;
    CPBitVarI* _r;
    CPBitVarI* _zeroBitVar;
    CPBitVarI* _x2Comp;
    CPBitVarI* _y2Comp;
//    CPBitVarI* _q2Comp;
//    CPBitVarI* _r2Comp;
    CPBitVarI* _posX;
    CPBitVarI* _posY;
    CPBitVarI* _posQ;
    CPBitVarI* _posR;
    CPBitVarI* _negQ;
    CPBitVarI* _negR;
//    CPBitVarI* _product;
//    CPBitVarI* _cin;
//    CPBitVarI* _cout;
    CPBitVarI* _trueVal;
    CPBitVarI* _falseVal;
    CPBitVarI* _xSign;
    CPBitVarI* _ySign;
    CPBitVarI* _qSign;
    CPBitVarI* _rSign;
   CPBitVarI* _negQSign;
   CPBitVarI* _negRSign;
//    CPBitVarI* _sameSign;
//    CPBitVarI* _xlty;
//    CPBitVarI* _qIsPos;
    CPBitVarI* _diffSign;
   
//   CPBitVarI* _zeroBV;
   CPBitVarI* _xIsZero;
   CPBitVarI* _xNonZero;
   CPBitVarI* _qIsZero;
   CPBitVarI* _qNonZero;
   CPBitVarI* _rIsZero;
   CPBitVarI* _rNonZero;

}
-(id) initCPBitDivideSigned: (CPBitVarI*) x dividedby: (CPBitVarI*) y equals: (CPBitVarI*)q rem:(CPBitVarI*)r;
-(void) dealloc;
-(NSString*) description;
-(void) post;
-(void) propagate;
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end


@interface CPBitDistinct : CPBitCoreConstraint<CPBVConstraint>{
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
-(ORInt) prefer:(CPBitVarI*)var at:(ORUInt)index with:(ORBool)lit;
@end
