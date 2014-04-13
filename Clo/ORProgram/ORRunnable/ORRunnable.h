//
//  ORRunnable.h
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORProgram/CPProgram.h>
#import <ORProgram/LPProgram.h>
#import <ORUtilities/ORTypes.h>
#import <ORUtilities/ORTypes.h>
#import <ORProgram/ORSignature.h>

//Forward Declarations
@protocol ORModel;
@protocol ORRunnable<NSObject>
-(id<ORModel>) model;
-(id<ORSignature>) signature;
-(id<ORASolver>) solver;
-(void) start;
-(void) run;
-(ORFloat)bestBound;
@end

@interface ORAbstractRunnableI : NSObject<ORRunnable> {
@protected
    id<ORModel> _model;
    ORClosure _exitBlock;
    ORClosure _startBlock;
}
@property(readwrite, retain) NSArray* siblings;
-(id) initWithModel: (id<ORModel>)m;
-(void) performOnStart: (ORClosure)c;
-(void) performOnExit: (ORClosure)c;
-(id<ORASolver>) solver;
@end

@interface ORFactory(ORRunnable)
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) LPRunnable: (id<ORModel>)m;
+(id<ORRunnable>) MIPRunnable: (id<ORModel>)m;
@end
