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
#import "CPIntVarI.h"
#import "CPDataI.h"
#import "CPConstraintI.h"
#import "CPTrail.h"
#import "CPCardinality.h"

// cardinality(int[] low,var<CP>{int}[] x,int[] up)
@interface CPCardinalityCst : CPActiveConstraint {  
    CPSolverI*        _fdm;
    CPRange       _values;
    CPIntVarI**         _x;  // CPIntVar[_lx .. _ux] 
    CPInt*             _low;  // raw version of _low
    CPInt*              _up;  // raw version of _up
    CPInt               _lo; // int low[lo..uo] && int up[lo..uo]
    CPInt               _uo;
    CPInt               _lx; 
    CPInt               _ux;
    CPUInt        _so; // size of low/up
    CPUInt        _sx; // size of ax
    TRInt*      _required; //_required[v]= how many variables are assigned to value v
    TRInt*      _possible; //_possible[v]= how many variables have value v in their domain
}
-(id) initCardinalityCst:(CPSolverI*)m values:(CPRange)r low:(CPInt*)low array:(id)ax up:(CPInt*)up;
-(id) initCardinalityCst: (CPIntVarArrayI*) ax low: (id<CPIntArray>)low up: (id<CPIntArray>) up;
-(void)dealloc;
-(CPStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

