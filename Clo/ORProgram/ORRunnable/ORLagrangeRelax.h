//
//  ORLagrangeRelax.h
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import "ORRunnablePiping.h"

@interface ORLagrangeRelax : NSObject
-(id) initWithModel: (id<ORModel>)m;
-(id) initWithModel: (id<ORModel>)m relax: (NSArray*)cstrs;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
@end
