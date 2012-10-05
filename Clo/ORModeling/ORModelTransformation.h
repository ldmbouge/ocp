//
//  ORModelTransformation.h
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
@protocol ORModel;

@protocol ORModelTransformation <NSObject>
-(id<ORModel>)apply:(id<ORModel>)m;
@end
