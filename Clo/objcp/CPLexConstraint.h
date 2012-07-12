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
#import "objcp/CPArray.h"

@class CPIntVarI;
@class CPSolver;

@interface CPLexConstraint : CPActiveConstraint<NSCoding> {
   id<CPIntVarArray>  _x;
   id<CPIntVarArray>  _y;
}
-(id) initCPLexConstraint:(id<CPIntVarArray>)x and:(id<CPIntVarArray>)y;
-(void) dealloc;
-(CPStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end
