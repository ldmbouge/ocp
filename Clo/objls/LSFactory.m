/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <objls/LSFactory.h>
#import "LSIntVar.h"

@implementation LSFactory
+(id<LSIntVar>)intVar:(id<LSEngine>)engine domain:(id<ORIntRange>)r
{
   return [[LSIntVar alloc] initWithEngine:engine domain:r];
}
+(id<LSIntVar>)intVarView:(id<LSEngine>)engine domain:(id<ORIntRange>)r fun:(ORInt(^)())fun src:(NSArray*)src
{
   return [[LSIntVarView alloc] initWithEngine:engine domain:r fun:fun src:src];
}
+(id<LSIntVarArray>) intVarArray: (id<ORTracker>) cp range: (id<ORIntRange>) range
{
   return (id)[ORFactory idArray:cp range:range];
}
+(id<LSIntVarArray>) intVarArray: (id<LSEngine>) cp range: (id<ORIntRange>) range domain:(id<ORIntRange>)dom
{
   return (id)[ORFactory idArray:cp range:range with:^id(ORInt i) {
      return [LSFactory intVar:cp domain:dom];
   }];
}
+(id<LSIntVarArray>) intVarArray: (id<ORTracker>)cp range: (id<ORIntRange>) range with: (id<LSIntVar>(^)(ORInt)) clo
{
   return (id)[ORFactory idArray:cp range:range with:clo];
}
@end
