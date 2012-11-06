//
//  ORFlatten.h
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>

@interface ORBatchModel : NSObject<ORINCModel> {
   ORModelI* _target;
}
-(ORBatchModel*)init:(ORModelI*)model;
-(void)addVariable:(id<ORVar>)var;
-(void)addObject:(id)object;
-(void)addConstraint:(id<ORConstraint>)cstr;
-(void)minimize:(id<ORIntVar>)x;
-(void)maximize:(id<ORIntVar>)x;
-(id<ORModel>)model;
-(void) trackObject: (id) obj;
-(void) trackVariable: (id) obj;
@end

@interface ORFlatten : NSObject<ORModelTransformation>
-(id)initORFlatten;
-(void)apply:(id<ORModel>)m into:(id<ORINCModel>)target;
-(void)flatten:(id<ORConstraint>)c into:(id<ORINCModel>)m;
+(void)flattenExpression:(id<ORExpr>)e into:(id<ORINCModel>)m;
@end
