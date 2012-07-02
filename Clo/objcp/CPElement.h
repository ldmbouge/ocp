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
#import "CPConstraintI.h"
#import "CPBitDom.h"
#import "objcp/CPData.h"
#import "objcp/CPArray.h"

@class CPIntVarI;
@class CPSolver;
@class CPIntVarArrayI;

@interface CPElementCstBC : CPActiveConstraint<NSCoding> { // y == c[x]
@private
   CPIntVarI*     _x;   
   CPIntVarI*     _y;
   id<CPIntArray> _c;
}
-(id) initCPElementBC: (id) x indexCstArray:(id<CPIntArray>) c equal:(id)y;
-(void) dealloc;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPElementVarBC : CPActiveConstraint<NSCoding> { // y == z[x]
@private
   CPIntVarI*        _x;
   CPIntVarI*        _y;
   id<CPIntVarArray> _z;
}
-(id) initCPElementBC: (id) x indexVarArray:(id<CPIntVarArray>) c equal:(id)y;
-(void) dealloc;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

