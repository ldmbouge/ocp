/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPIntVarI.h>
#import "CPConstraint.h"

// pvh: This constraint for illustration purposes right now for my dear fellow Andreas
@implementation CPDisjunctivePair {
   CPIntVar*    _x;
   ORInt        _dx;
   CPIntVar*    _y;
   ORInt        _dy;
}
-(id) initCPDisjunctivePair: (id<CPIntVar>) x duration: (ORInt) dx start: (CPIntVar*) y duration: (ORInt) dy
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = (CPIntVar*) x;
   _dx = dx;
   _y = y;
   _dy = dy;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(ORStatus) post
{
   printf("I am posting a CPDisjunctivePair Constraint\n");
   return ORSuspend;
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt) nbUVars
{
   return 0;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"CPDisjunctivePair"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   assert(false);
//   [super encodeWithCoder:aCoder];
//   [aCoder encodeObject:_x];
//   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   assert(false);
//   self = [super initWithCoder:aDecoder];
//   _x = [aDecoder decodeObject];
//   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
//   return self;
}
@end

