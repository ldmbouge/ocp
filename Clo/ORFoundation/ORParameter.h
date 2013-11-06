//
//  ORParameter.h
//  Clo
//
//  Created by Daniel Fontaine on 9/19/13.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORExpr.h>


@protocol ORParameter <ORObject,ORExpr>
-(ORInt) getId;
@end

@protocol ORIntParam <ORParameter>
-(ORInt) initialValue;
@end

@protocol ORFloatParam <ORParameter>
-(ORFloat) initialValue;
@end
