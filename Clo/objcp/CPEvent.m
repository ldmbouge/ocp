/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPEvent.h"

//static id vLossCache = nil;

@implementation CPValueLossEvent
-(id)initValueLoss:(ORInt)value notify:(id<CPEventNode>)list
{
   self = [super init];
   _theVal = value;
   _theList = list;
   return self;
}
-(ORInt)execute
{
   ORInt nbP = 0;
   id<CPEventNode> evt = _theList;
   @try {
      while (evt) {
         ((ConstraintIntCallBack)[evt trigger])(_theVal);
         evt = [evt next];
         ++nbP;
      }
      [self release];
      return nbP;
   } @catch(ORFailException* ex) {
      [self release];
      @throw;
   }
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

