/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPTypes.h"
#import "CPIntVarI.h"
#import "CPDataI.h"
#import "CPConstraintI.h"
#import "CPTrail.h"
#import "CPCardinality.h"

// cardinality(int[] low,var<CP>{int}[] x,int[] up)
@interface CPCardinalityCst : CPActiveConstraint<NSCoding> {  
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
-(id) initCardinalityCst:(CPIntVarArrayI*) ax low: (id<CPIntArray>)low up: (id<CPIntArray>) up;
-(void)dealloc;
-(CPStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

