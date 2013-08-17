/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORConstraintI.h"
#import "ORVisit.h"

@implementation ORDisjunctive {
   id<ORIntVar> _x;
   ORInt        _dx;
   id<ORIntVar> _y;
   ORInt        _dy;
}
-(id<ORDisjunctive>) initORDisjunctive: (id<ORIntVar>) x duration: (ORInt) dx start: (id<ORIntVar>) y duration: (ORInt) dy;
{
   self = [super initORConstraintI];
   _x = x;
   _dx = dx;
   _y = y;
   _dy = dy;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"disjunctive %@ %@",[self class],self];
   return buf;
}
-(void) visit:(ORVisitor*) v
{
   [v visitDisjunctive: self];
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) dx
{
   return _dx;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(ORInt) dy
{
   return _dy;
}
-(NSSet*) allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
@end
