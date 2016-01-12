/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORModeling/ORModeling.h>

@interface ORLinearize : NSObject<ORModelTransformation>
-(id)initORLinearize:(id<ORAddToModel>)into;
-(void) apply:(id<ORModel>)m with:(id<ORAnnotation>)notes;
+(id<ORModel>)linearize:(id<ORModel>)model;
@end

@interface ORFactory(Linearize)
+(id<ORModel>) linearizeModel: (id<ORModel>)m;
@end
