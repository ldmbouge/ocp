/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORObject.h"
#import "ORError.h"
#import <objc/runtime.h>

static Class __orObjectClass = nil;

@implementation ORObject

+(void)load
{
   __orObjectClass = [ORObject class];
}

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
   __sync_add_and_fetch(&_rc,1);
   return self;
}
-(NSUInteger)retainCount
{
   return _rc;
}
-(oneway void)release
{
   //printf("Release called on solver: RC=%d [%s]\n",_rc,[[[self class] description] UTF8String]);
   ORUInt nc = __sync_sub_and_fetch(&_rc,1);
   if (nc == 0) {
      [self dealloc];
   }
}
-(id)autorelease
{
   //assert(_ba[3] == 0);
   //NSLog(@"   AUTORELEASE(%p) CNT=%d  -- obj: %@\n",self,_rc,self);
   id rv = [super autorelease];
   _ba[3] = 1;
   return rv;
}
-(void) visit: (ORVisitor*) visitor
{}
- (BOOL)isEqual:(id)object
{
   if ((id)self == object)
      return YES;
   if ([self isKindOfClass:__orObjectClass]) {
      return _name == getId(object);
   } else return NO;
}
- (NSUInteger)hash
{
   return _name;
}
-(id) takeSnapshot: (ORInt) id
{
   return NULL;
}
@end


