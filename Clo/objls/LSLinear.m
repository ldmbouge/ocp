/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSLinear.h"

@implementation LSLinear {
   ORBool _posted;
   id<LSIntVar> _value;        // sum(i in S) a_i * x_i
   id<LSIntVar> _sat;          // sat <=> sum(i in S) a_i * x_i OP 0
   id<LSIntVar> _violations;
}

-(id)init:(id<LSEngine>)engine
    coefs:(id<ORIntArray>)c
     vars:(id<LSIntVarArray>)x
     type:(LSLinearType)ty;     // sum(i in S) a_i x_i OP 0
{
   self = [super init:engine];
   _c = c;
   _x = x;
   _t = ty;
   _posted = NO;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(void)post
{
   if (_posted==NO) {
      _posted = YES;
      
   }
}
-(id<LSIntVarArray>)variables
{
   return nil;
}
-(ORBool)isTrue
{
   return _sat.value;
}
-(ORInt)getViolations
{
   return _violations.value;
}
-(ORInt)getVarViolations:(id<LSIntVar>)var
{
   return 0;
}
-(id<LSIntVar>)violations
{
   return _violations;
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
