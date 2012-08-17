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

@class CPIntVarI;
@interface CPKnapsack : CPActiveConstraint<NSCoding> {
   id<ORIntVarArray> _x;
   id<ORIntArray>    _w;
   CPIntVarI*        _c;
}
-(id) initCPKnapsackDC:(id<ORIntVarArray>)x weights:(id<ORIntArray>)w capacity:(id<ORIntVar>)cap;
-(void) dealloc;
-(ORStatus)post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
