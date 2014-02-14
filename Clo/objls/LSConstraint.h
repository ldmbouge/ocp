/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
-(ORInt)getVarViolations:(id<LSIntVar>)var;
-(id<LSIntVar>)violations;
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var;
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
+(id<LSConstraint>)system:(id<LSEngine>)e with:(NSArray*)ac;
@end