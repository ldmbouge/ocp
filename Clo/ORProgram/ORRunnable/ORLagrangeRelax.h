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

@interface ORLagrangeRelax : ORPipedRunnable<NSObject>
-(id) initWithModel: (id<ORParameterizedModel>)m;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(ORFloat) bestBound;
-(id<ORSolution>) bestSolution;
@end
