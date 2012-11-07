/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORObject.h"
#import "ORError.h"

@protocol ORVisitor;
@implementation ORObjectI
-(id) init
{
   [super init];
   _impl = NULL;
   return self;
}
-(void) setImpl: (id) impl
{
   if (_impl)
      [_impl setImpl: impl];
   else
      _impl = impl;
}
-(id) dereference
{
   if (_impl)
      return [_impl dereference];
   else
      return self;
}
-(id) impl
{
   return _impl;
}
-(void) visit: (id<ORVisitor>) visitor
{
   NSLog(@"%@",self);
   @throw [[ORExecutionError alloc] initORExecutionError: "visit: No implementation in this object"];
}
@end;


