/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitVarI.h>
#import <objcp/CPConstraintI.h>

#define UP_MASK 0xFFFFFFFF

@interface CPBitEqual : CPActiveConstraint<NSCoding> {
@private
    CPBitVarI*  _x;
    CPBitVarI*  _y;

}
-(id) initCPBitEqual: (id) x and: (id) y ;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end

@interface CPBitNOT : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    
}
-(id) initCPBitNOT: (id) x equals: (id) y;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end

@interface CPBitAND : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;

}
-(id) initCPBitAND: (id) x and: (id) y equals: (id) z;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end

@interface CPBitOR : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;
    
}
-(id) initCPBitOR: (id) x or: (id) y equals: (id) z;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end

@interface CPBitXOR : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;
    
}
-(id) initCPBitXOR: (id) x xor: (id) y equals: (id) z;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end

@interface CPBitIF : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI* _w;
    CPBitVarI* _x;
    CPBitVarI* _y;
    CPBitVarI* _z;
    
}
-(id) initCPBitIF: (id) w equalsOneIf:(id) x equals: (id) y andZeroIfXEquals: (id) z;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end


@interface CPBitShiftL : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    unsigned int    _places;
}
-(id) initCPBitShiftL: (id) x shiftLBy:(int) places equals:(id) y;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end

@interface CPBitShiftR : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    unsigned int    _places;
    
}-(id) initCPBitShiftR: (id) x shiftRBy:(int) places equals:(id) y;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end

@interface CPBitADD: CPActiveConstraint<NSCoding>{
@private
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    CPBitVarI*      _z;
    CPBitVarI*      _cin;
    CPBitVarI*      _cout;
    
}
-(id) initCPBitAdd: (id) x plus:(id) y equals:(id) z withCarryIn:(id) cin andCarryOut:cout;
-(void) dealloc;
-(CPStatus) post;
-(void) propagate;
@end

