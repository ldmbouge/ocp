//
//  ORRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import "ORRunnable.h"
#import "ORFactory.h"
#import "ORConcretizer.h"

@implementation ORSignatureI

-(bool) matches: (id<ORSignature>)sig {
    return YES;
}

@synthesize isComplete;
@synthesize providesLowerBound;
@synthesize providesLowerBoundPool;
@synthesize providesLowerBoundStream;
@synthesize providesUpperBound;
@synthesize providesUpperBoundPool;
@synthesize providesUpperBoundStream;

@end

@interface ORMutableSignatureI : ORSignatureI
-(void) clear;
-(ORMutableSignatureI*) complete;
-(ORMutableSignatureI*) upperOut;
-(ORMutableSignatureI*) upperStreamOut;
-(ORMutableSignatureI*) upperPoolOut;
-(ORMutableSignatureI*) lowerOut;
-(ORMutableSignatureI*) lowerStreamOut;
-(ORMutableSignatureI*) lowerPoolOut;
-(ORMutableSignatureI*) upperIn;
-(ORMutableSignatureI*) upperStreamIn;
-(ORMutableSignatureI*) upperPoolIn;
-(ORMutableSignatureI*) lowerIn;
-(ORMutableSignatureI*) lowerStreamIn;
-(ORMutableSignatureI*) lowerPoolIn;
@end

@implementation ORMutableSignatureI
-(id) init {
    if((self = [super init]) != nil) {
        [self clear];
    }
    return self;
}

-(void) clear {
    isComplete = NO;
    providesLowerBound = NO;
    providesLowerBoundPool = NO;
    providesLowerBoundStream = NO;
    providesUpperBound = NO;
    providesUpperBoundPool = NO;
    providesUpperBoundStream = NO;
    acceptsLowerBound = NO;
    acceptsLowerBoundPool = NO;
    acceptsLowerBoundStream = NO;
    acceptsUpperBound = NO;
    acceptsUpperBoundPool = NO;
    acceptsUpperBoundStream = NO;
}

-(ORMutableSignatureI*) complete { isComplete = YES; return self; }
-(ORMutableSignatureI*) upperOut { providesUpperBound = YES; return self; }
-(ORMutableSignatureI*) upperStreamOut { providesUpperBoundStream = YES; return self; }
-(ORMutableSignatureI*) upperPoolOut { providesUpperBoundPool = YES; return self; }
-(ORMutableSignatureI*) lowerOut { providesLowerBound = YES; return self; }
-(ORMutableSignatureI*) lowerStreamOut { providesLowerBoundStream = YES; return self; }
-(ORMutableSignatureI*) lowerPoolOut { providesLowerBoundPool = YES; return self; }
-(ORMutableSignatureI*) upperIn { acceptsUpperBound = YES; return self; }
-(ORMutableSignatureI*) upperStreamIn { acceptsUpperBoundStream = YES; return self; }
-(ORMutableSignatureI*) upperPoolIn { acceptsUpperBoundPool = YES; return self; }
-(ORMutableSignatureI*) lowerIn { acceptsLowerBound = YES; return self; }
-(ORMutableSignatureI*) lowerStreamIn { acceptsLowerBoundStream = YES; return self; }
-(ORMutableSignatureI*) lowerPoolIn { acceptsLowerBoundPool = YES; return self; }
@end

@implementation ORFactory(ORSignature)
+(id<ORSignature>) createSignature: (NSString*)sigString {
    ORMutableSignatureI* sig = [[[ORMutableSignatureI alloc] init] autorelease];
    sig = [sig valueForKeyPath: sigString];
    return sig;
}
@end

@implementation CPRunnableI {
    id<ORModel> _model;
    id<CPProgram> _program;
    id<ORSignature> _sig;
    NSMutableArray* _upperBoundConsumers;
}

-(id) initWithModel: (id<ORModel>)m {
    if((self = [super init]) != nil) {
        _model = [m retain];
        _program = [ORFactory createCPProgram: _model];
        _upperBoundConsumers = [[NSMutableArray alloc] initWithCapacity: 8];
    }
    return self;
}

-(void) dealloc {
    [_model release];
    [_program release];
    [_upperBoundConsumers release];
    [_sig release];
    [super dealloc];
}

-(id<ORSignature>) signature {
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.upperStreamOut.upperStreamIn"];
    }
    return _sig;
}

-(void) addUpperBoundStreamConsumer:(id<ORUpperBoundStreamConsumer>)c {
    [_upperBoundConsumers addObject: c];
}

-(void) onStreamedUpperBound:(ORInt)b {
    [_program addConstraintDuringSearch: [[[_model objective] var] leqi: b] annotation: Hard];
}

-(void) run {
    NSLog(@"Running CP runnable(%p)...", _program);
    id<CPHeuristic> h = [ORFactory createFF: _program];
    
    // When a solution is found, pass the objective value to consumers.
    [_program onSolution: ^void () {
        for(id<ORUpperBoundStreamConsumer> c in _upperBoundConsumers)
            [c onStreamedUpperBound: (ORInt)[[[_model objective] value] key]];
    } onExit: nil];
    
    [_program solve:
     ^() {
         NSLog(@"Solving CP program...");
         [_program labelHeuristic: h];
     }];
    NSLog(@"Finishing CP runnable(%p)...", _program);
}

@end