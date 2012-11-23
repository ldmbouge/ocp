/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPEvent.h"

@implementation CPValueLossEvent
-(id)initValueLoss:(ORInt)value notify:(VarEventNode*)list
{
   self = [super init];
   _theVal = value;
   _theList = list;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(ORInt)execute
{
   ORInt nbP = 0;
   VarEventNode* evt = _theList;
   @try {
      while (evt) {
         ((ConstraintIntCallBack)evt->_trigger)(_theVal);
         evt = evt->_node;
         ++nbP;
      }
      [self release];
      return nbP;
   } @catch(ORFailException* ex) {
      [self release];
      @throw;
   }
}
@end

