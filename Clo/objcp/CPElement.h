/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPConstraintI.h>

@class CPIntVarI;
@class CPEngine;

@interface CPElementCstBC : CPActiveConstraint<NSCoding> { // y == c[x]
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

@interface CPElementVarBC : CPActiveConstraint<NSCoding> { // y == z[x]
@private
   CPIntVarI*        _x;
   CPIntVarI*        _y;
   id<ORIntVarArray> _z;
}
-(id) initCPElementBC: (id) x indexVarArray:(id<ORIntVarArray>) c equal:(id)y;
-(void) dealloc;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

