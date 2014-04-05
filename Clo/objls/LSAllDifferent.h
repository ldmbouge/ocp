/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end

@interface LSPacking : LSConstraint {
   id<LSIntVarArray>  _x;  // decision variables
   id<ORIntArray>     _weight;  // weights
   id<ORIntArray>     _cap;  // weights
   id<LSIntVarArray>  _c;  // cardinalities
   id<LSIntVarArray>  _satDegree;  // satisfiability degree
   id<LSIntVarArray> _vv;  // value violations
   id<LSIntVarArray> _xv;  // variable violations
   id<LSIntVar>     _sum;  // total violations
   ORBool        _posted;  // whether we have been posted already.
}
-(id)init: (id<LSIntVarArray>)x weight:(id<ORIntArray>)weight cap:(id<ORIntArray>)cap;
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

@interface LSMeetAtmost : LSConstraint {
   id<LSIntVarArray>  _x;
   id<LSIntVarArray>  _y;
   ORInt              _cap;
   id<LSIntVarArray>  _equal;  // equalities on the term
   id<LSIntVar>       _sum;  // How many are equal 
   id<LSIntVar>       _satDegree;  // How many are equal - cap
   id<LSIntVar>       _violations;
   id<LSIntVarArray>  _varv;  // variable violations
   ORBool             _posted;  // whether we have been posted already.
}
-(id)init: (id<LSIntVarArray>)x and:(id<LSIntVarArray>)y atmost:(ORInt)cap;
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
