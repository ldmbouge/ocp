//
//  ORRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORTypes.h"
#import "ORSignature.h"

//Forward Declarations
@protocol  ORModel;

@protocol ORRunnable<NSObject>
-(id<ORModel>) model;
-(id<ORSignature>) signature;
-(void) start;
-(void) run;
-(void) setSiblings: (NSArray*)siblings;
-(NSArray*) siblings;
-(void) connectPiping: (NSArray*)runnables;
@end

@interface ORAbstractRunnableI : NSObject<ORRunnable> {
@protected
    id<ORModel> _model;
    ORClosure _exitBlock;
    NSArray* _siblings;
}
@property(readwrite, retain) NSArray* siblings;
-(id) initWithModel: (id<ORModel>)m;
@end

@interface ORFactory(ORRunnable)
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) LPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) MIPRunnable: (id<ORModel>)m;
@end
