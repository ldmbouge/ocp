/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSVar.h>
#import <objls/LSFactory.h>

@class LSEngineI;
@protocol LSConstraint <NSObject>
-(void)post;
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getTrueViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
@end

@interface LSConstraint : ORObject<LSConstraint> {
   LSEngineI* _engine;
}
-(id)init:(id<LSEngine>)engine;
-(void)post;
-(id<LSIntVarArray>)variables;
-(ORBool)isTrue;
-(ORInt)getViolations;
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
@end

@interface LSFactory (LSConstraint)
+(id<LSConstraint>)alldifferent:(id<LSEngine>)e over:(id<LSIntVarArray>)x;
+(id<LSConstraint>) packing:(id<LSIntVarArray>)x weight: (id<ORIntArray>)weight capacity: (id<ORIntArray>)capacity;
+(id<LSConstraint>) packingOne: (id<LSIntVarArray>)x weight: (id<ORIntArray>)weight bin: (ORInt) bin capacity: (ORInt)capacity;
+(id<LSConstraint>) meetAtmost:(id<LSIntVarArray>)x and: (id<LSIntVarArray>)y atmost: (ORInt) k;
+(id<LSConstraint>)system:(id<LSEngine>)e with:(NSArray*)ac;
+(id<LSConstraint>)lrsystem:(id<LSEngine>)e with:(NSArray*)ac;
+(id<LSConstraint>)linear:(id<LSEngine>)e coef:(id<ORIntArray>)c vars:(id<LSIntVarArray>)x eq:(ORInt)cst;
+(id<LSConstraint>) lEqual: (id<LSIntVar>)x to: (id<LSIntVar>) y plus:(ORInt)c;
@end