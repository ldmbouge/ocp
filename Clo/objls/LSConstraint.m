/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSConstraint.h"
#import "LSEngineI.h"
#import "LSAllDifferent.h"
#import "LSSystem.h"
#import "LSLinear.h"

@implementation LSConstraint
-(id)init:(LSEngineI*)engine
{
   self = [super init];
   _engine = engine;
   return self;
}
-(void)post
{
   
}
-(id<LSIntVarArray>)variables
{
   return nil;
}
-(ORBool)isTrue
{
   return YES;
}
-(ORInt)getViolations
{
   return 0;
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   return 0;
}
-(id<LSIntVar>)violations
{
   return nil;
}
-(id<LSIntVar>)varViolations:(id<LSIntVar>)var
{
   return nil;
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   return 0;
}
@end

@implementation LSFactory (LSConstraint)
+(id<LSConstraint>)alldifferent:(id<LSEngine>)e over:(id<LSIntVarArray>)x
{
   LSAllDifferent* c = [[LSAllDifferent alloc] init:e vars:x];
   [e trackMutable:c];
   return c;
}
+(id<LSConstraint>)system:(id<LSEngine>)e with:(NSArray*)ac
{
   LSSystem* c = [[LSSystem alloc] init:e with:ac];
   [e trackMutable:c];
   return c;
}
+(id<LSConstraint>)linear:(id<LSEngine>)e coef:(id<ORIntArray>)coef vars:(id<LSIntVarArray>)x eq:(ORInt)cst
{
   LSLinear* c = [[LSLinear alloc] init:e coefs:coef vars:x type:LSTYEqual constant:cst];
   [e trackMutable:c];
   return c;
}
@end