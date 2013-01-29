/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORModeling.h"
#import "ORModelI.h"

@protocol ORModel;
@protocol ORAddToModel;

@protocol ORModelTransformation <NSObject>
-(void)apply:(id<ORModel>)m into:(id<ORAddToModel>)target;
@end

