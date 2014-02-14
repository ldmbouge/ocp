/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSConstraint.h"
#import "LSEngineI.h"
#import "LSAllDifferent.h"
#import "LSSystem.h"

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
@end