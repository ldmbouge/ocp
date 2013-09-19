//
//  ORParameterI.h
//  Clo
//
//  Created by Daniel Fontaine on 9/19/13.
//
//

#import <Foundation/Foundation.h>
#import "ORParameter.h"
#import "ORExprI.h"
#import "ORVisit.h"

@interface ORIntParamI : ORExprI<ORIntParam,NSCoding>
-(ORIntParamI*) initORIntParamI: (id<ORTracker>) track value: (ORInt)x;
@end

@interface ORFloatParamI : ORExprI<ORFloatParam,NSCoding>
-(ORIntParamI*) initORFloatParamI: (id<ORTracker>) track value: (ORFloat)x;
@end