//
//  ORLagrangianTransform.h
//  Clo
//
//  Created by Daniel Fontaine on 10/17/13.
//
//

#import <Foundation/Foundation.h>

@interface ORLagrangianTransform : NSObject
-(id<ORParameterizedModel>) apply: (id<ORModel>)m relaxing: (NSArray*)cstrs;
-(id<ORParameterizedModel>) softify: (id<ORModel>)m constraints: (NSArray*) cstrs;
+(NSArray*) coupledConstraints: (id<ORModel>)m;
@end

@interface ORLagrangianViolationTransform : ORLagrangianTransform
@end

@interface ORSoftifyTransform : NSObject
-(id<ORParameterizedModel>) apply: (id<ORModel>)m relaxing: (NSArray*)cstrs;
@end

@interface ORFactory(ORLagrangianTransform)
+(ORLagrangianTransform*) lagrangianTransform;
+(ORLagrangianTransform*) lagrangianViolationTransform;
+(ORSoftifyTransform*) softifyModelTransform;
@end