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
#import <ORProgram/ORRunnablePiping.h>


@interface ORLagrangeRelax : ORPipedRunnable<NSObject>
-(id) initWithModel: (id<ORParameterizedModel>)m;
-(id) initWithModel:(id<ORParameterizedModel>)m withSurrogateSplit: (NSArray*)split;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(ORFloat) bestBound;
-(id<ORSolution>) bestSolution;
@end
