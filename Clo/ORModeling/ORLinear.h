/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@protocol ORLinear<NSObject>
-(id<ORConstraint>)postEQZ:(id<ORAddToModel>)model;
-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model;
-(id<ORConstraint>)postLEQZ:(id<ORAddToModel>)model;
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model;
@end
