/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPConstraintI.h>

// cardinality(int[] low,var<CP>{int}[] x,int[] up)
@interface CPCardinalityCst : CPActiveConstraint<NSCoding> {  
    CPEngineI*        _fdm;
    CPRange       _values;
    CPIntVarI**         _x;  // CPIntVar[_lx .. _ux] 
    ORInt*             _low;  // raw version of _low
    ORInt*              _up;  // raw version of _up
    ORInt               _lo; // int low[lo..uo] && int up[lo..uo]
    ORInt               _uo;
    ORInt               _lx; 
    ORInt               _ux;
    CPUInt        _so; // size of low/up
    CPUInt        _sx; // size of ax
    TRInt*      _required; //_required[v]= how many variables are assigned to value v
    TRInt*      _possible; //_possible[v]= how many variables have value v in their domain
}
-(id) initCardinalityCst:(CPEngineI*)m values:(CPRange)r low:(ORInt*)low array:(id)ax up:(ORInt*)up;
-(id) initCardinalityCst:(id<ORIntVarArray>) ax low: (id<ORIntArray>)low up: (id<ORIntArray>) up;
-(void)dealloc;
-(ORStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end

