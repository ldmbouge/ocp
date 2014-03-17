/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSConstraint.h>

typedef enum : NSUInteger {
   LSTYEqual,
   LSTYLEqual,
   LSTYGEqual,
   LSTYNEqual
} LSLinearType;

@interface LSLinear : LSConstraint {
   id<ORIntArray>    _coefs;
   id<LSIntVarArray>     _x;
   LSLinearType          _t;
   ORInt                 _c;
}
-(id)init:(id<LSEngine>)engine
    coefs:(id<ORIntArray>)coef
     vars:(id<LSIntVarArray>)x
     type:(LSLinearType)ty
 constant:(ORInt)c;               // sum(i in S) a_i x_i OP c
-(void)post;
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end
