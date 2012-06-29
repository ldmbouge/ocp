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
#import "CP.h"
#import "CPTrail.h"
#import "CPTypes.h"
#import "CPBitDom.h"
#import "CPConstraintI.h"
#import "CPDataI.h"
#import "CPIntVarI.h"

@interface CPIntArrayI : NSObject<CPVirtual,NSCoding> {
    id<CP>       _cp;
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

@interface CPIntVarArrayI : NSObject<CPVirtual,NSCoding> {
    id<CP>         _cp;
    id<CPIntVar>*  _array;
    CPInt      _low;
    CPInt      _up;
    CPInt      _nb;
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


@interface CPIntVarMatrixI : NSObject<CPVirtual,NSCoding> {
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

