//
//  LPRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import <Foundation/Foundation.h>
#import "ORRunnablePiping.h"
#import "LPProgram.h"


@protocol LPRunnable <ORRunnable>
-(id<LPProgram>) solver;
-(void) injectColumn: (id<ORFloatArray>) col;
@end

@interface LPRunnableI : ORPipedRunnable<LPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<LPProgram>) solver;
-(void) injectColumn: (id<ORFloatArray>) col;
-(id<ORModel>) model;
-(void) run;
@end

