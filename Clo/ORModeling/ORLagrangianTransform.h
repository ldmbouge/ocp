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
@end
