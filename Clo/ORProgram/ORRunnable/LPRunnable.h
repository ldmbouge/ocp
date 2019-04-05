//
//  LPRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import <Foundation/Foundation.h>
#import <ORProgram/ORRunnablePiping.h>
#import <ORProgram/LPProgram.h>


@protocol LPRunnable <ORRunnable>
-(id<LPProgram>) solver;
-(void) injectColumn: (id<LPColumn>) col;
@end

@interface LPRunnableI : ORPipedRunnable<LPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<LPProgram>) solver;
-(void) injectColumn: (id<LPColumn>) col;
-(id<ORModel>) model;
-(void) run;
@end

