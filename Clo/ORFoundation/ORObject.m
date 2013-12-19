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

@implementation ORObject
-(id)init
{
   self = [super init];
   _name = -1;
   memset(_ba,0,sizeof(_ba));
   _rc = 1;
   return self;
}
-(void)setId:(ORUInt)name
{
   assert(_name == -1);
   _name = name;
}
-(ORUInt)getId
{
   return _name;
}
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
   NSLog(@"DID NOT RECOGNIZE a selector %@",NSStringFromSelector(aSelector));
   return [super doesNotRecognizeSelector:aSelector];
}
-(id)retain
{
   _rc += 1;
   return self;
}
-(oneway void)release
{
   if (--_rc == 0) {
      [self dealloc];
   }
}
-(NSUInteger)retainCount
{
   return _rc;
}
-(id)autorelease
{
   assert(_ba[3] == 0);
   id rv = [super autorelease];
   _ba[3] = 1;
   return rv;
//   _rc += 1;
//   [NSAutoreleasePool addObject:self];
//   return self;
}
@end


