//
//  ORModelTransformation.h
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORModeling.h"
#import "ORModelI.h"

@protocol ORModel;
@protocol ORINCModel;

@protocol ORModelTransformation <NSObject>
-(void)apply:(id<ORModel>)m into:(id<ORINCModel>)target;
@end

