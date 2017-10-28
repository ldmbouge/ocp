//
//  ORParameterI.h
//  Clo
//
//  Created by Daniel Fontaine on 9/19/13.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORParameter.h>
#import <ORFoundation/ORExprI.h>

@interface ORIntParamI : ORExprI<ORIntParam,NSCoding>
-(ORIntParamI*) initORIntParamI: (id<ORTracker>) track initialValue: (ORInt)val;
@end

@interface ORRealParamI : ORExprI<ORRealParam,NSCoding>
-(ORRealParamI*) initORRealParamI: (id<ORTracker>) track initialValue: (ORDouble)val;
@end
