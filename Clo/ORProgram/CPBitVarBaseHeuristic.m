/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import <ORProgram/CPBitVarHeuristic.h>
#import <ORProgram/CPBitVarBaseHeuristic.h>
#import <objcp/CPVar.h>

@implementation CPBitVarBaseHeuristic {
   BOOL _oneSol;
}
-(void) initHeuristic: (NSArray*)mvar concrete:(NSArray*)cvar oneSol:(ORBool)oneSol
{
   self = [super init];
   _oneSol = oneSol;
   id<ORTracker>  cp = [[mvar objectAtIndex:0] tracker];
   id<ORIntRange>  r = RANGE(cp,0,(ORInt)[mvar count]-1);
   id<ORVarArray> mv = (id)[ORFactory idArray:cp range:r];
   ORInt k = 0;
   for(id<ORVar> v in mvar)
      mv[k++] = v;
   id<ORVarArray> cv = (id)[ORFactory idArray:cp range:r];
   k = 0;
   for(id<ORVar> v in cvar)
      cv[k++] = v;
   [self initInternal:mv and:cv];
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
-(void) initInternal: (id<ORVarArray>) t and:(id<ORVarArray>)cv
{
   //@throw [[ORExecutionError alloc] initORExecutionError: "initInternal not implemented"];
}
-(ORFloat) varOrdering: (id<ORIntVar>)x
{
   return 0.0;
}
-(ORFloat) valOrdering: (ORInt) v forVar: (id<ORIntVar>) x
{
   return 0.0;
}
-(void) restart
{
   //NSLog(@"Restart of based heuristic called... Nothing to do.");
}
-(id<ORBitVarArray>) allBitVars
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


@implementation CPBitVarVirtualHeuristic {
   id<ORBindingArray> _binding;
}
-(CPBitVarVirtualHeuristic*)initWithBindings:(id<ORBindingArray>)bindings
{
   self = [super init];
   _binding = bindings;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   return [[CPBitVarVirtualHeuristic alloc] initWithBindings:[_binding retain]];
}
-(void)dealloc
{
   [_binding release];
   [super dealloc];
}
-(ORFloat) varOrdering: (id<CPBitVar>)x
{
   return [_binding[[NSThread threadID]] varOrdering:x];
}
-(ORFloat) valOrdering: (ORInt) v forVar: (id<CPBitVar>) x
{
   return [_binding[[NSThread threadID]] valOrdering:v forVar:x];
}
-(void) initInternal: (id<CPBitVarArray>) t and:(id<ORVarArray>)cvs
{
   [_binding[[NSThread threadID]] initInternal:t and:cvs];
}
-(void) initHeuristic: (NSArray*)mvar concrete:(NSArray*)cvar oneSol:(ORBool)oneSol
{
   [_binding[[NSThread threadID]] initHeuristic:mvar concrete:cvar oneSol:oneSol];
}
-(id<ORBitVarArray>) allBitVars
{
   return [_binding[[NSThread threadID]] allBitVars];
}
-(id<ORBitVarArray>) allIntVars
{
   NSAssert(false,@"Attempted to get IntVars from a BitVar Heuristic");
   return nil;
}
-(id<CPProgram>)solver
{
   id<CPBitVarHeuristic> h = _binding[[NSThread threadID]];
   return [h solver];
}
-(void) restart
{
   id<CPBitVarHeuristic> h = _binding[[NSThread threadID]];
   return [h restart];
}
@end
