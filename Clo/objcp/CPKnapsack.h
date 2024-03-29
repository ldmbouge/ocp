/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>

@class CPIntVar;
@interface CPKnapsack : CPCoreConstraint {
   id<CPIntVarArray> _x;
   id<ORIntArray>    _w;
   CPIntVar*        _c;
}
-(id) initCPKnapsackDC:(id<CPIntVarArray>)x weights:(id<ORIntArray>)w capacity:(id<CPIntVar>)cap;
-(void) dealloc;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
