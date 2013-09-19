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
-(ORInt) intValue;
-(ORFloat) floatValue;
@end

@protocol ORIntParam <ORParameter>
-(void) set: (ORInt)x;
-(ORInt) value;
@end

@protocol ORFloatParam <ORParameter>
-(void) set: (ORFloat)x;
-(ORFloat) value;
@end
