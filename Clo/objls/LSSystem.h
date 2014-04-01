/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSConstraint.h>

@protocol  LSIntVar;

@interface LSSystem : LSConstraint<LSConstraint> {
   NSArray*         _cstrs;
   ORInt               _nb;
   ORBool          _posted;
   id<LSIntVar>      _viol;
   id<LSIntVar>       _sat;
   id<LSIntVarArray>  _src;   // conventional array of source vars (sorted by id)
   id<LSIntVarArray>   _av;   // all violations
   ORInt           _lb,_ub;  // lower and upper bound for flat source array
   id<LSIntVar>*  _flatSrc;  // flat source array
   id<LSIntVarArray>   _vv;
}
-(id)init:(id<LSEngine>)engine with:(NSArray*)ca;
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
