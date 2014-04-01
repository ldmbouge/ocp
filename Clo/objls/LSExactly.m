/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSExactly.h"

@implementation LSExactly

-(id)init:(id<LSEngine>)engine vars:(id<LSIntVarArray>)x
{
   self = [super init:engine];
   _x   = x;
   return self;
}
-(void)dealloc
{
   [super dealloc];
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
   return NO;
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
