/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>

@class CPIntVarI;
@class CPEngine;
@class CPBitDom;

@interface CPElementCstBC : CPCoreConstraint<NSCoding> { // y == c[x]
@private
   CPIntVarI*     _x;   
   CPIntVarI*     _y;
   id<ORIntArray> _c;
}
-(id) initCPElementBC: (id) x indexCstArray:(id<ORIntArray>) c equal:(id)y;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPElementCstAC : CPCoreConstraint { // y == c[x]
   CPIntVarI*     _x;
   CPIntVarI*     _y;
   id<ORIntArray> _c;
}
-(id) initCPElementAC: (id) x indexCstArray:(id<ORIntArray>) c equal:(id)y;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPElementVarBC : CPCoreConstraint<NSCoding> { // y == z[x]
@private
   CPIntVarI*        _x;
   CPIntVarI*        _y;
   id<CPIntVarArray> _z;
}
-(id) initCPElementBC: (id) x indexVarArray:(id<CPIntVarArray>) c equal:(id)y;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPElementVarAC : CPCoreConstraint {
   CPIntVarI*         _x;
   id<CPIntVarArray>  _array;
   CPIntVarI*         _z;
   id<ORTrailableIntArray> _s;  // supports
   id<ORTrailableIntArray> _c;  // cardinalities of intersections
   CPBitDom**          _inter;  // intersections
   CPBitDom*             _iva;
   ORInt                _minA;  // lowest index in array
   ORInt               _nbVal;  // number of slots in array
   ORInt  _minCI,_maxCI,_nbCI;  // bounds & size of interesection array
}
-(id)initCPElementAC: (id) x indexVarArray:(id<CPIntVarArray>)y equal:(id)z;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
