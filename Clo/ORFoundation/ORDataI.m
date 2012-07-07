/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORDataI.h"


@implementation ORIntegerI 
-(ORIntegerI*) initORIntegerI:(id<ORTracker>)tracker value:(ORInt) value
{
   self = [super init];
   _value = value;
   _tracker = tracker;
   return self;
}
-(ORInt) value 
{
   return _value;
}
-(void) setValue: (ORInt) value
{
   _value = value;
}
-(void) incr
{
   _value++;
}
-(void) decr;
{
   _value--;
}
-(ORInt) min
{
   return _value;
}
-(ORInt) max
{
   return _value;
}
-(BOOL) isConstant
{
   return YES;
}
-(BOOL) isVariable
{
   return NO;
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"%d",_value];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_value];
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_value];
   return self;
}
@end

