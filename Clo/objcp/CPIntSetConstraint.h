/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPBitDom.h>
#import <objcp/CPVar.h>
#import <objcp/CPISVarI.h>

@interface CPISInterAC : CPCoreConstraint { // z == x INTER y
   id<CPIntSetVar> _x;
   id<CPIntSetVar> _y;
   id<CPIntSetVar> _z;
}
-(id)init:(id<CPIntSetVar>)x inter:(id<CPIntSetVar>)y eq:(id<CPIntSetVar>)z;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
