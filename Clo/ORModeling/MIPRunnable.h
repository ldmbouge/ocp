//
//  MIPRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 4/22/13.
//
//

#import <Foundation/Foundation.h>
#import "ORRunnablePiping.h"
#import "MIPProgram.h"

@protocol MIPRunnable <ORRunnable>
-(id<MIPProgram>) solver;
-(id<ORFloatArray>) duals;
-(void) injectColumn: (id<ORFloatArray>) col;
@end

@interface MIPRunnableI : NSObject<MIPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<MIPProgram>) solver;
-(id<ORFloatArray>) duals;
-(void) injectColumn: (id<ORFloatArray>) col;
-(id<ORModel>) model;
-(void) run;
@end
