/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSConstraint.h>

@interface LSLEqual : LSConstraint {
   LSIntVar* _x;
   LSIntVar* _y;
   ORInt     _c;
}
-(id)init:(id<LSEngine>)engine x:(id<LSIntVar>)x leq:(id<LSIntVar>)y plus:(ORInt)c;  // x ≤ y + c
-(void)post;
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
-(ORBool)legalAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORBool)legalSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end

@interface LSEqualc : LSConstraint {
   LSIntVar* _x;
   ORInt     _c;
}
-(id)init:(id<LSEngine>)engine x:(id<LSIntVar>)x eq:(ORInt)c;
-(void)post;
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
-(ORBool)legalAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORBool)legalSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end

@interface LSNEqualc : LSConstraint {
   LSIntVar* _x;
   ORInt     _c;
}
-(id)init:(id<LSEngine>)engine x:(id<LSIntVar>)x neq:(ORInt)c;
-(void)post;
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
-(ORBool)legalAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORBool)legalSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end

@interface LSOr  : LSConstraint {
   LSIntVar* _b;
   LSIntVar* _x;
   LSIntVar* _y;
}
-(id)init:(id<LSEngine>)engine boolean:(id<LSIntVar>)b equal:(id<LSIntVar>)x or:(id<LSIntVar>)y;
-(void)post;
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
-(ORBool)legalAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORBool)legalSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end

@interface LSMinimize: LSConstraint {
   id<LSFunction> _fun;
}
-(id)init:(id<LSEngine>)engine with:(id<LSFunction>)f;
-(void)post;
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
-(ORBool)legalAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORBool)legalSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end
