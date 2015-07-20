/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPConstraint.h>
#import <CPUKernel/CPConstraintI.h>

#define UP_MASK 0xFFFFFFFF

@interface CPFactory (BitConstraint)
//Bit Constraints
+(id<CPConstraint>) bitEqual:(id<CPBitVar>)x to:(id<CPBitVar>)y;
+(id<CPConstraint>) bitAND:(id<CPBitVar>)x and:(id<CPBitVar>)y equals:(id<CPBitVar>) z;
+(id<CPConstraint>) bitOR:(id<CPBitVar>)x or:(id<CPBitVar>)y equals:(id<CPBitVar>) z;
+(id<CPConstraint>) bitXOR:(id<CPBitVar>)x xor:(id<CPBitVar>)y equals:(id<CPBitVar>) z;
+(id<CPConstraint>) bitNOT:(id<CPBitVar>)x equals:(id<CPBitVar>) y;
+(id<CPConstraint>) bitShiftL:(id<CPBitVar>)x by:(int) p equals:(id<CPBitVar>) y;
+(id<CPConstraint>) bitRotateL:(id<CPBitVar>)x by:(int) p equals:(id<CPBitVar>) y;
+(id<CPConstraint>) bitADD:(id<CPBitVar>)x plus:(id<CPBitVar>) y withCarryIn:(id<CPBitVar>) cin equals:(id<CPBitVar>) z withCarryOut:(id<CPBitVar>) cout;
+(id<CPConstraint>) bitIF:(id<CPBitVar>)w equalsOneIf:(id<CPBitVar>)x equals:(id<CPBitVar>)y andZeroIfXEquals:(id<CPBitVar>) z;
@end

@interface CPBitEqual : CPCoreConstraint {
@private
    CPBitVarI*  _x;
    CPBitVarI*  _y;
}
-(id) initCPBitEqual: (CPBitVarI*) x and: (CPBitVarI*) y ;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end

@interface CPBitNOT : CPCoreConstraint{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;    
}
-(id) initCPBitNOT: (CPBitVarI*) x equals: (CPBitVarI*) y;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end

@interface CPBitAND : CPCoreConstraint{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;
}
-(id) initCPBitAND: (CPBitVarI*) x and: (CPBitVarI*) y equals: (CPBitVarI*) z;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end

@interface CPBitOR : CPCoreConstraint{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;    
}
-(id) initCPBitOR: (CPBitVarI*) x or: (CPBitVarI*) y equals: (CPBitVarI*) z;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end

@interface CPBitXOR : CPCoreConstraint{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;    
}
-(id) initCPBitXOR: (CPBitVarI*) x xor: (CPBitVarI*) y equals: (CPBitVarI*) z;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end

@interface CPBitIF : CPCoreConstraint{
@private 
    CPBitVarI* _w;
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;    
}
-(id) initCPBitIF: (CPBitVarI*) w equalsOneIf:(CPBitVarI*) x equals: (CPBitVarI*) y andZeroIfXEquals: (CPBitVarI*) z;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end


@interface CPBitShiftL : CPCoreConstraint{
@private 
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    unsigned int    _places;
}
-(id) initCPBitShiftL: (CPBitVarI*) x shiftLBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end

@interface CPBitRotateL : CPCoreConstraint{
@private
   CPBitVarI*      _x;
   CPBitVarI*      _y;
   unsigned int    _places;
}
-(id) initCPBitRotateL: (CPBitVarI*) x rotateLBy:(int) places equals: (CPBitVarI*) y;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end

@interface CPBitShiftR : CPCoreConstraint{
@private 
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    unsigned int    _places;
}
-(id) initCPBitShiftR: (CPBitVarI*) x shiftRBy:(int) places equals:(CPBitVarI*) y;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end

@interface CPBitADD: CPCoreConstraint{
@private
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    CPBitVarI*      _z;
    CPBitVarI*      _cin;
    CPBitVarI*      _cout;    
}
-(id) initCPBitAdd: (CPBitVarI*) x plus: (CPBitVarI*) y equals:(CPBitVarI*) z withCarryIn:(CPBitVarI*) cin andCarryOut:(CPBitVarI*)cout;
-(void) dealloc;
-(void) post;
-(void) propagate;
@end



