/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPConstraint.h"
#import "CPBitVarI.h"

#define UP_MASK 0xFFFFFFFF

@interface CPBitEqual : CPActiveConstraint<NSCoding> {
@private
    CPBitVarI*  _x;
    CPBitVarI*  _y;

}
-(id) initCPBitEqual: (id) x and: (id) y ;
-(void) dealloc;
-(CPStatus) post;
-(CPStatus) propagate;
@end

@interface CPBitNOT : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI* _x;
    CPBitVarI* _y;
    
}
-(id) initCPBitNOT: (id) x equals: (id) y;
-(void) dealloc;
-(CPStatus) post;
-(CPStatus) propagate;
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
-(CPStatus) propagate;
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
-(CPStatus) propagate;
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
-(CPStatus) propagate;
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
-(CPStatus) propagate;
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
-(CPStatus) propagate;
@end

@interface CPBitShiftR : CPActiveConstraint<NSCoding>{
@private 
    CPBitVarI*      _x;
    CPBitVarI*      _y;
    unsigned int    _places;
    
}-(id) initCPBitShiftR: (id) x shiftRBy:(int) places equals:(id) y;
-(void) dealloc;
-(CPStatus) post;
-(CPStatus) propagate;
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
-(CPStatus) propagate;
@end

