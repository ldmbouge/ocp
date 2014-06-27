/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSFunVariable.h"
#import "LSEngineI.h"
#import "LSIntVar.h"

@implementation LSFunVariable {
   id<LSEngine>   _engine;
   id<LSIntVar>      _var;  // could be a real variable or a view
   id<LSIntVarArray> _src;
}
-(LSFunVariable*)init:(id<LSEngine>)engine with:(id<LSIntVar>)var
{
   self = [super init];
   _engine = engine;
   _var = var;
   return self;
}
-(void)post
{
}
-(id<LSIntVar>)evaluation
{
   return _var;
}
-(id<LSGradient>)increase:(id<LSIntVar>)x
{
   return [_var increase:x];
}
-(id<LSGradient>)decrease:(id<LSIntVar>)x
{
   return [_var decrease:x];
}
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v
{
   if (getId(x) == getId(_var)) {
      return v - getLSIntValue(x);
   } else return 0;
}
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y
{
   ORInt vid = getId(_var);
   if (getId(x) == vid)
      return getLSIntValue(y) - getLSIntValue(_var);
   else if (getId(y) == vid)
      return getLSIntValue(x) - getLSIntValue(_var);
   else
      return 0;
}
-(id<LSIntVarArray>)variables
{
   if (_src==nil) {
      _src = [LSFactory intVarArray:_engine range:RANGE(_engine,0,0)];
      _src[0] = _var;
   }
   return _src;
}
@end
