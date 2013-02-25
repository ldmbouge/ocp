/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import "CPBaseHeuristic.h"
#import <objcp/CPVar.h>
@implementation CPBaseHeuristic

-(void) initHeuristic: (NSMutableArray*) array
{
   __block ORUInt nbViews = 0;
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      enum CPVarClass vc = [obj varClass];
      nbViews += (vc == CPVCShift || vc == CPVCAffine || vc == CPVCFlip);
   }];
   ORULong l = [array count] - nbViews;
   id<ORTracker> cp = [[array objectAtIndex:0] tracker];
   id<ORVarArray> direct = (id<ORVarArray>)[ORFactory idArray:cp range:RANGE(cp,0,(ORInt)l-1) ];
   __block ORUInt k = 0;
   [array enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
      enum CPVarClass vc = [obj varClass];
      if (!(vc == CPVCShift || vc == CPVCAffine || vc == CPVCFlip))
         [direct set:obj at:k++];
   }];
   [self initInternal: direct];   
}
-(void) initInternal: (id<ORVarArray>) t
{
   @throw [[ORExecutionError alloc] initORExecutionError: "initInternal not implemented"];      
}
@end


@implementation CPVirtualHeuristic {
   id<ORBindingArray> _binding;
}
-(CPVirtualHeuristic*)initWithBindings:(id<ORBindingArray>)bindings
{
   self = [super init];
   _binding = bindings;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   return [[CPVirtualHeuristic alloc] initWithBindings:[_binding retain]];
}
-(void)dealloc
{
   [_binding release];
   [super dealloc];
}
-(ORFloat) varOrdering: (id<ORIntVar>)x
{
   return [_binding[[NSThread threadID]] varOrdering:x];
}
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORIntVar>) x
{
   return [_binding[[NSThread threadID]] valOrdering:v forVar:x];
}
-(void) initInternal: (id<CPIntVarArray>) t
{
   [_binding[[NSThread threadID]] initInternal:t];
}
-(void) initHeuristic: (NSMutableArray*) array
{
   [_binding[[NSThread threadID]] initHeuristic:array];
}
-(id<ORIntVarArray>) allIntVars
{
   return [_binding[[NSThread threadID]] allIntVars];
}
-(id<CPCommonProgram>)solver
{
   id<CPHeuristic> h = _binding[[NSThread threadID]];
   return [h solver];
}
@end
