/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPEvent.h"
#include <pthread.h>

@implementation CPValueLossEvent

-(id) initValueLoss: (ORInt) value notify: (id<CPClosureList>) list
{
   self = [super init];
   _theVal = value;
   _theList = list;
   return self;
}

-(ORInt) execute
{
   __block ORInt rv;
   tryfail(^ORStatus{
      __block ORInt nbP = 0;
      scanListWithBlock(_theList,(void(^)(id)) ^(ORIntClosure trigger) {
         trigger(_theVal);
         ++nbP;
      });
      [self letgo];
      rv = nbP;
      return ORSuspend;
   }, ^ORStatus{
      [self letgo];
      failNow();
      return ORSuspend;
   });
   return rv;
}

#if TARGET_OS_IPHONE==0
static __thread id vLossCache = nil;

+(id)newValueLoss:(ORInt)value notify:(id<CPClosureList>)list
{
   // [ldm] This is an effective optimization, but it is not thread-friendly.
   // Should use TLS to store the vLossCache.
   id ptr = vLossCache;
   if (ptr) {
      vLossCache = *(id*)ptr;
   } else {
      ptr = [super allocWithZone:NULL];
      [ptr init];
   }
   // now generic code.
   *(Class*)ptr = self;
   CPValueLossEvent* evt = (CPValueLossEvent*)ptr;
   evt->_theVal = value;
   evt->_theList = list;
   return evt;
//   id rv = [ptr initValueLoss:value notify:list];
//   return rv;
}
-(void)letgo
{
   *(id*)self = vLossCache;
   vLossCache = self;
   return;
   [super dealloc];
}
#else
+(id)newValueLoss:(ORInt)value notify:(id<CPClosureList>)list
{
   CPValueLossEvent* ptr = [[CPValueLossEvent alloc] init];
   ptr->_theVal = value;
   ptr->_theList = list;
   return ptr;
}
-(void)letgo
{
   [self release];
}
#endif



@end

