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
@end


