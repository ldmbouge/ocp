/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import <ORProgram/CPBaseHeuristic.h>
#import <objcp/CPVar.h>

@implementation CPBaseHeuristic {
   BOOL _oneSol;
}
-(void) initHeuristic: (NSArray*)mvar concrete:(NSArray*)cvar oneSol:(ORBool)oneSol tracker:(id<ORTracker>)cp
{
   self = [super init];
   _oneSol = oneSol;
   //id<ORTracker>  cp = [[mvar objectAtIndex:0] tracker];
   id<ORIntRange>  r = RANGE(cp,0,(ORInt)[mvar count]-1);
   id<ORVarArray> mv = (id)[ORFactory idArray:cp range:r];
   ORInt k = 0;
   for(id<ORVar> v in mvar)
      mv[k++] = v;
   id<ORVarArray> cv = (id)[ORFactory idArray:cp range:r];
   k = 0;
   for(id<ORVar> v in cvar)
      cv[k++] = v;
   [self initInternal:mv with:cv];
   /*
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
    */
}
-(void) initInternal: (id<ORVarArray>) t with:(id<ORVarArray>)cv
{
   @throw [[ORExecutionError alloc] initORExecutionError: "initInternal not implemented"];      
}
-(ORDouble) varOrdering: (id<ORIntVar>)x
{
   return 0.0;
}
-(ORDouble) valOrdering: (ORInt) v forVar: (id<ORIntVar>) x
{
   return 0.0;
}
-(void) restart
{
   //NSLog(@"Restart of based heuristic called... Nothing to do.");
}
-(id<ORIntVarArray>) allIntVars
{
   return nil;
}
-(id<CPProgram>)solver
{
   return nil;
}
-(ORBool)oneSol
{
   return _oneSol;
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
-(ORDouble) varOrdering: (id<CPIntVar>)x
{
   return [_binding[[NSThread threadID]] varOrdering:x];
}
-(ORDouble) valOrdering: (ORInt) v forVar: (id<CPIntVar>) x
{
   return [_binding[[NSThread threadID]] valOrdering:v forVar:x];
}
-(void) initInternal: (id<CPIntVarArray>) t with:(id<ORVarArray>)cvs
{
   [_binding[[NSThread threadID]] initInternal:t with:cvs];
}
-(void) initHeuristic: (NSArray*)mvar concrete:(NSArray*)cvar oneSol:(ORBool)oneSol tracker:(id<ORTracker>)cp
{
   [_binding[[NSThread threadID]] initHeuristic:mvar concrete:cvar oneSol:oneSol tracker:cp];
}
-(id<ORIntVarArray>) allIntVars
{
   return [_binding[[NSThread threadID]] allIntVars];
}
-(id<CPProgram>)solver
{
   id<CPHeuristic> h = _binding[[NSThread threadID]];
   return [h solver];
}
-(void) restart
{
   id<CPHeuristic> h = _binding[[NSThread threadID]];
   return [h restart];
}
@end
