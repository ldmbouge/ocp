//
//  ORLinearize.h
//  Clo
//
//  Created by Daniel Fontaine on 10/6/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORModeling/ORModeling.h>
#import <ORFoundation/ORArrayI.h>

@interface ORLinearize : NSObject<ORModelTransformation>
-(id)initORLinearize;
-(void) apply:(id<ORModel>)m into:(id<ORAddToModel>)target;
+(id<ORModel>)linearize:(id<ORModel>)model;
@end

@interface ORFactory(Linearize)
+(id<ORModel>) linearizeModel: (id<ORModel>)m;
@end
