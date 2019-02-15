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
-(ORUInt) getId;
@end

@protocol ORIntParam <ORParameter>
-(ORInt) initialValue;
@end

@protocol ORRealParam <ORParameter>
-(ORDouble) initialValue;
@end
