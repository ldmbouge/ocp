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
   id<LSIntVarArray>  _src;    // conventional array of source vars (sorted by id)
   id<LSIntVarArray>   _av;    // all violations

   ORInt           _lb,_ub;    // lower and upper bound for flat source array
   id<LSIntVar>*  _flatSrc;    // flat source array
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

@interface LSLRSystem : LSConstraint<LSConstraint> {
   NSArray*            _cstrs;
   ORInt               _nb;
   ORBool              _posted;
   id<LSIntVar>        _viol;
   id<LSIntVar>        _wviol;
   id<LSIntVar>        _sat;
   id<LSIntVarArray>   _src;   // conventional array of source vars (sorted by id)
   id<LSIntVarArray>   _av;   // all violations
   id<LSIntVarArray>   _wav;    // all violations weighted
   id<LSIntVarArray>   _lambda;   // multiplier
   ORInt               _lb,_ub;  // lower and upper bound for flat source array
   id<LSIntVar>*       _flatSrc;  // flat source array
   id<LSIntVarArray>   _vv;
   id<LSIntVarArray>   _wvv;
}
-(id)init:(id<LSEngine>)engine with:(NSArray*)ca;
-(void)post;
-(id<LSIntVarArray>)variables;

-(ORBool)isTrue;

-(ORInt)getViolations;
-(ORInt)getWeightedViolations;
-(ORInt)getUnweightedViolations;

-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(ORInt)getVarWeightedViolations:(id<LSIntVar>)var;
-(ORInt)getVarUnweightedViolations:(id<LSIntVar>)var;

-(id<LSIntVar>)violations;
-(id<LSIntVar>)weightedViolations;
-(id<LSIntVar>)unweightedViolations;

// [pvh] Not sure I want these
-(id<LSIntVar>) varViolations:(id<LSIntVar>)var;
-(id<LSIntVar>) varWeightedViolations:(id<LSIntVar>)var;
-(id<LSIntVar>) varUnweightedViolations:(id<LSIntVar>)var;

-(ORInt) deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt) weightedDeltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt) unweightedDeltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;

-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;

-(void) updateMultipliers;
-(void) resetMultipliers;
@end

