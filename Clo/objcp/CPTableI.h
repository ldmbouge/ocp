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
#import "CPTypes.h"
#import "CPDataI.h"
#import "CPConstraintI.h"
#import "CPTrail.h"
#import "CPBasicConstraint.h"
#import "CPTable.h"

@interface CPTableI : NSObject<CPTable,NSCoding> {
    @package
    id<CP>      _cp;
    CPInt   _arity; 
    CPInt   _nb;
    CPInt   _size;
    CPInt** _column;
    bool        _closed;
    CPInt*  _min;          // _min[j] is the minimum value in column[j]
    CPInt*  _max;          // _max[j] is the maximun value in column[j]
    CPInt** _nextSupport;  // _nextSupport[j][i] is the next support of element j in tuple i
    CPInt** _support;      // _support[j][v] is the support (a row index) of value v in column j
}
-(CPTableI*) initCPTableI: (id<CP>) cp arity: (CPInt) arity;
-(void) dealloc;
-(void) insert: (CPInt) i : (CPInt) j : (CPInt) k;
-(void) addEmptyTuple;
-(void) fill: (CPInt) j with: (CPInt) val;
-(void) close;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;
-(void) print;
@end


@interface CPTableCstrI : CPActiveConstraint<CPConstraint,NSCoding> {
    CPIntVarI** _var;
    CPInt   _arity;  
    CPTableI*   _table;
    TRIntArray* _currentSupport;
    bool        _posted;
}
-(CPTableCstrI*) initCPTableCstrI: (CPIntVarArrayI*) x table: (CPTableI*) table;
-(void) dealloc;
-(CPStatus) post;
-(void) encodeWithCoder: (NSCoder*) aCoder;
-(id) initWithCoder: (NSCoder*) aDecoder;

@end
