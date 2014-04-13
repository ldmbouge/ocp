/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>

@interface CPValueLossEvent : NSObject<CPValueEvent> {
   id<CPClosureList> _theList;
   ORInt             _theVal;
}
+(id)newValueLoss:(ORInt)value notify:(id<CPClosureList>)list;
-(void)letgo;
-(id)initValueLoss:(ORInt)value notify:(id<CPClosureList>)list;
-(ORInt)execute;
@end
