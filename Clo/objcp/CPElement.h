/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPConstraintI.h"
#import "CPBitDom.h"
#import "objcp/CPData.h"
#import "objcp/CPArray.h"

@class CPIntVarI;
@class CPSolver;

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

