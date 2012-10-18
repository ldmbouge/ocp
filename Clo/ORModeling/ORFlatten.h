//
//  ORFlatten.h
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>

@interface ORFlatten : NSObject<ORModelTransformation>
-(id)initORFlatten;
-(id<ORModel>)apply:(id<ORModel>)m;
-(void)flatten:(id<ORConstraint>)c into:(id<ORModel>)m;
@end
