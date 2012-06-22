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

@class CPIntVarI;
@class CPSolver;
@class CPIntVarArrayI;


// PVH: where is _active being used
@interface CPEqualc : CPActiveConstraint<NSCoding> {
   @private
   CPIntVarI* _x;
   CPInt  _c;
}
-(id) initCPEqualc:(id)x and:(CPInt)c;
-(void) dealloc;
-(CPStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPDiffc : CPActiveConstraint<NSCoding> {
@private
   CPIntVarI* _x;
   CPInt      _c;
}
-(id) initCPDiffc:(id)x and:(CPInt)c;
-(void) dealloc;
-(CPStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPEqualBC : CPActiveConstraint<NSCoding> {
@private
   CPIntVarI*  _x;
   CPIntVarI*  _y;
   CPInt _c;
}
-(id) initCPEqualBC: (id) x and: (id) y  and: (CPInt) c;
-(void) dealloc;
-(CPStatus) post;
-(CPStatus) propagate;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

typedef int (^intgetter) (void) ;

@interface CPNotEqual : CPActiveConstraint<NSCoding> {
@private
   CPIntVarI* _x;
   CPIntVarI* _y;
   CPInt  _c;
}
-(id) initCPNotEqual: (id) x and: (id) y  and: (CPInt) c;
-(CPStatus) post;
-(CPStatus) propagate;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPBasicNotEqual : CPActiveConstraint<NSCoding> {
   CPIntVarI* _x;
   CPIntVarI* _y;
}
-(id) initCPBasicNotEqual:(id)x and:(id) y;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPLEqualBC : CPActiveConstraint<NSCoding> {  // x <= y
@private
   CPIntVarI*  _x;
   CPIntVarI*  _y;   
}
-(id) initCPLEqualBC:(id)x and:(id) y;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPLEqualc : CPActiveConstraint<NSCoding> { // x <= c
@private
   CPIntVarI* _x;
   CPInt      _c;
}
-(id) initCPLEqualc:(id)x and:(CPInt) c;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPMultBC : CPActiveConstraint<NSCoding> { // z == x * y
   CPIntVarI* _x;
   CPIntVarI* _y;
   CPIntVarI* _z;
}
-(id) initCPMultBC:(id)x times:(id)y equal:(id)z;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPAllDifferenceVC : CPActiveConstraint<NSCoding> {
   CPIntVarI**   _x;
   CPInt    _nb;   
}
-(id) initCPAllDifferenceVC: (CPIntVarI**) x nb: (CPInt) n;
-(id) initCPAllDifferenceVC: (id) x;
-(void) dealloc;
-(CPStatus) post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPIntVarMinimize : CPCoreConstraint {
   CPIntVarI*  _x;
   CPInt        _primalBound;
}
-(id)        initCPIntVarMinimize: (id<CPIntVar>) x;
-(void)      dealloc;
-(CPStatus)  post;
-(CPStatus)  check;
-(void)      updatePrimalBound;
-(CPInt)       primalBound;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

@interface CPIntVarMaximize : CPCoreConstraint {
   CPIntVarI*  _x;
   CPInt        _primalBound;
}
-(id)        initCPIntVarMaximize: (id<CPIntVar>) x;
-(void)      dealloc;
-(CPStatus)  post;
-(CPStatus)  check;
-(void)      updatePrimalBound;
-(CPInt)       primalBound;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end
