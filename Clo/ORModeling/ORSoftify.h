//
//  ORSoftify.h
//  Clo
//
//  Created by Daniel Fontaine on 10/23/13.
//
//

#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORParameter.h>
#import <ORFoundation/ORVisit.h>

@protocol ORParameterizedModel;

@interface ORSoftify : ORNOopVisit
-(ORSoftify*) initORSoftify;
-(void)apply:(id<ORModel>)m;
-(void)apply:(id<ORModel>)m toConstraints: (NSArray*)cstrs;
-(id<ORParameterizedModel>)target;
@end

@interface ORViolationSoftify : ORSoftify
@end
