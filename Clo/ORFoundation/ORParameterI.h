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
#import <ORFoundation/ORVisit.h>

@interface ORIntParamI : ORExprI<ORIntParam,NSCoding>
-(ORIntParamI*) initORIntParamI: (id<ORTracker>) track initialValue: (ORInt)val;
@end

@interface ORFloatParamI : ORExprI<ORFloatParam,NSCoding>
-(ORIntParamI*) initORFloatParamI: (id<ORTracker>) track initialValue: (ORFloat)val;
@end