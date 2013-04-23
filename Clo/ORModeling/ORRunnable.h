//
//  ORRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPProgram.h"
#import "MIPProgram.h"
#import "ORTypes.h"
#import "ORSignature.h"

//Forward Declarations
@protocol  ORModel;

@protocol ORRunnable<NSObject>
-(id<ORModel>) model;
-(id<ORSignature>) signature;
-(void) start;
-(void) run;
-(NSArray*) children;
-(void) connectPiping: (NSArray*)runnables;
@end

@interface ORAbstractRunnableI : NSObject<ORRunnable> {
@protected
    id<ORModel> _model;
    ORClosure _exitBlock;
    NSArray* _child;
}
-(id) initWithModel: (id<ORModel>)m children: (NSArray*)child;
@end

@protocol LPRunnable <ORRunnable>
-(id<LPProgram>) solver;
-(id<ORFloatArray>) duals;
-(void) injectColumn: (id<ORFloatArray>) col;
@end

@interface LPRunnableI : NSObject<LPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<LPProgram>) solver;
-(id<ORFloatArray>) duals;
-(void) injectColumn: (id<ORFloatArray>) col;
-(id<ORModel>) model;
-(void) run;
@end

@protocol MIPRunnable <ORRunnable>
-(id<MIPProgram>) solver;
-(id<ORFloatArray>) duals;
-(void) injectColumn: (id<ORFloatArray>) col;
@end

@interface MIPRunnableI : NSObject<MIPRunnable>
-(id) initWithModel: (id<ORModel>)m;
-(id<ORSignature>) signature;
-(id<LPProgram>) solver;
-(id<ORFloatArray>) duals;
-(void) injectColumn: (id<ORFloatArray>) col;
-(id<ORModel>) model;
-(void) run;
@end

@interface ORFactory(ORRunnable)
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) LPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) MIPRunnable: (id<ORModel>)m;
@end
