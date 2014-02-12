/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSConstraint.h>

@interface LSAllDifferent : LSConstraint {
   id<LSIntVarArray>  _x;  // source
   id<LSIntVarArray>  _c;  // cardinalities
   id<LSIntVarArray> _vv;  // value violations
   id<LSIntVarArray> _xv;  // variable violations
   id<LSIntVar>     _sum;  // total violations
   ORBool        _posted;  // whether we have been posted already.
}
-(id)init:(id<LSEngine>)engine vars:(id<LSIntVarArray>)x;
-(void)post;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end
