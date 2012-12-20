/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPEvent.h"

static id vLossCache = nil;

@implementation CPValueLossEvent

-(id) initValueLoss: (ORInt) value notify: (id<CPEventNode>) list
{
   self = [super init];
   _theVal = value;
   _theList = list;
   return self;
}

-(ORInt) execute
{
   @try {
      __block ORInt nbP = 0;
      scanListWithBlock(_theList, ^(ConstraintIntCallBack trigger) {
         trigger(_theVal);
         ++nbP;
      });
      //CFRelease(self);
      [self letgo];
      return nbP;

   } @catch(ORFailException* ex) {
      //[self release];
      [self letgo];
      @throw;
   }
}

+(id)newValueLoss:(ORInt)value notify:(id<CPEventNode>)list
{
   // [ldm] This is an effective optimization, but it is not thread-friendly.
   // Should use TLS to store the vLossCache.
   id ptr = vLossCache;
   if (ptr)
      vLossCache = *(id*)vLossCache;
   else ptr = [super allocWithZone:nil];
   *(Class*)ptr = self;
   id rv = [ptr initValueLoss:value notify:list];
   return rv;
}
-(void)letgo
{
   *(id*)self = vLossCache;
   vLossCache = self;
   return;
   [super dealloc];
}

/*
+(id)allocWithZone:(NSZone *)zone
{
   id ptr = vLossCache;
   if (ptr)
      vLossCache = *(id*)vLossCache;
   else ptr = [super allocWithZone:zone];
   *(Class*)ptr = self;
   return ptr;
}
-(void)dealloc
{
   *(id*)self = vLossCache;
   vLossCache = self;
   return;
   [super dealloc];
}
 */

@end

