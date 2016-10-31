/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>

@class CPIntVar;
@class CPEngine;
@class CPBitDom;
@class CPBitVarI;
@class CPBitArrayDom;

@interface CPElementCstBC : CPCoreConstraint { // y == c[x]
@private
   CPIntVar*     _x;   
   CPIntVar*     _y;
   id<ORIntArray> _c;
}
-(id) initCPElementBC: (id) x indexCstArray:(id<ORIntArray>) c equal:(id)y;
-(void) dealloc;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPElementCstAC : CPCoreConstraint { // y == c[x]
   CPIntVar*     _x;
   CPIntVar*     _y;
   id<ORIntArray> _c;
}
-(id) initCPElementAC: (id) x indexCstArray:(id<ORIntArray>) c equal:(id)y;
-(void) dealloc;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPElementVarBC : CPCoreConstraint { // y == z[x]
@private
   CPIntVar*        _x;
   CPIntVar*        _y;
   id<CPIntVarArray> _z;
}
-(id) initCPElementBC: (id) x indexVarArray:(id<CPIntVarArray>) c equal:(id)y;
-(void) dealloc;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPElementVarAC : CPCoreConstraint {
   CPIntVar*         _x;
   id<CPIntVarArray>  _array;
   CPIntVar*         _z;
   id<ORTrailableIntArray> _s;  // supports
   id<ORTrailableIntArray> _c;  // cardinalities of intersections
   CPBitDom**          _inter;  // intersections
   CPBitDom*             _iva;
   ORInt                _minA;  // lowest index in array
   ORInt               _nbVal;  // number of slots in array
   ORInt  _minCI,_maxCI,_nbCI;  // bounds & size of interesection array
}
-(id)initCPElementAC: (id) x indexVarArray:(id<CPIntVarArray>)y equal:(id)z;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPElementBitVarBC : CPCoreConstraint { // y == z[x]
@private
   CPBitVarI*        _x;
   CPBitVarI*        _y;
   id<ORIdArray> _z;
}
-(id) initCPElementBC: (id) x indexVarArray:(id<ORIdArray>) c equal:(id)y;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPElementBitVarAC : CPCoreConstraint {
   CPBitVarI*        _x;
   CPBitVarI*        _y;
   id<ORIdArray> _z;
   CPBitVarI*  _xold;
   CPBitArrayDom* _xold2;
   id<ORTrailableInt>   _la;  // lowest index in array (_z)
   id<ORTrailableInt>   _ua; // upper index of _z
   id<ORTrailableIntArray> _I; // _I[i] tells us if _y = _z[i] is a possible assignment
   id<ORTrailableIntArray> _svx0; // _svx0[i] tells us the number of zeros in the permutations of _x in column i
   id<ORTrailableIntArray> _svx1;
   id<ORTrailableIntArray> _svy0; // support for 0's in array (_z)
   id<ORTrailableIntArray> _svy1;
   id<ORTrailableInt> _cI; // cardinality of _I
   
}
-(id)initCPElementAC: (id) x indexVarArray:(id<ORIdArray>)y equal:(id)z;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

