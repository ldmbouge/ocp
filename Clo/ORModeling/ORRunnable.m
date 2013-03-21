//
//  ORRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 1/15/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import "ORRunnable.h"
#import "ORFactory.h"
#import "ORProgramFactory.h"
#import "ORConcurrencyI.h"
#import <objmp/LPSolverI.h>

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
@synthesize providesSolutionStream;
@synthesize providesColumn;
@synthesize providesConstraint;
@synthesize acceptsLowerBound;
@synthesize acceptsLowerBoundPool;
@synthesize acceptsLowerBoundStream;
@synthesize acceptsUpperBound;
@synthesize acceptsUpperBoundPool;
@synthesize acceptsUpperBoundStream;
@synthesize acceptsSolutionStream;
@synthesize acceptsColumn;
@synthesize acceptsConstraint;

@end

@implementation ORMutableSignatureI
-(id) init {
    if((self = [super init]) != nil) {
        [self clear];
    }
    return self;
}

-(id) initFromSignature: (id<ORSignature>)sig {
    if((self = [super init]) != nil) {
        [self copy: sig];
    }
    return self;
}

-(void) copy: (id<ORSignature>)sig {
    isComplete = [sig isComplete];
    providesLowerBound = [sig providesLowerBound];
    providesLowerBoundPool = [sig providesLowerBoundPool];
    providesLowerBoundStream = [sig providesLowerBoundStream];
    providesUpperBound = [sig providesUpperBound];
    providesUpperBoundPool = [sig providesUpperBoundPool];
    providesUpperBoundStream = [sig providesUpperBoundStream];
    providesSolutionStream = [sig providesSolutionStream];
    providesColumn = [sig providesColumn];
    providesConstraint = [sig providesConstraint];
    acceptsLowerBound = [sig acceptsLowerBound];
    acceptsLowerBoundPool = [sig acceptsLowerBoundPool];
    acceptsLowerBoundStream = [sig acceptsLowerBoundStream];
    acceptsUpperBound = [sig acceptsUpperBound];
    acceptsUpperBoundPool = [sig acceptsUpperBoundPool];
    acceptsUpperBoundStream = [sig acceptsUpperBoundStream];
    acceptsSolutionStream = [sig acceptsSolutionStream];
    acceptsColumn = [sig acceptsColumn];
    acceptsConstraint = [sig acceptsConstraint];
}

-(void) clear {
    isComplete = NO;
    providesLowerBound = NO;
    providesLowerBoundPool = NO;
    providesLowerBoundStream = NO;
    providesUpperBound = NO;
    providesUpperBoundPool = NO;
    providesUpperBoundStream = NO;
    providesSolutionStream = NO;
    providesColumn = NO;
    providesConstraint = NO;
    acceptsLowerBound = NO;
    acceptsLowerBoundPool = NO;
    acceptsLowerBoundStream = NO;
    acceptsUpperBound = NO;
    acceptsUpperBoundPool = NO;
    acceptsUpperBoundStream = NO;
    acceptsSolutionStream = NO;
    acceptsColumn = NO;
    acceptsConstraint = NO;
}

-(ORMutableSignatureI*) complete { isComplete = YES; return self; }
-(ORMutableSignatureI*) upperOut { providesUpperBound = YES; return self; }
-(ORMutableSignatureI*) upperStreamOut { providesUpperBoundStream = YES; return self; }
-(ORMutableSignatureI*) upperPoolOut { providesUpperBoundPool = YES; return self; }
-(ORMutableSignatureI*) lowerOut { providesLowerBound = YES; return self; }
-(ORMutableSignatureI*) lowerStreamOut { providesLowerBoundStream = YES; return self; }
-(ORMutableSignatureI*) lowerPoolOut { providesLowerBoundPool = YES; return self; }
-(ORMutableSignatureI*) solutionStreamOut { providesSolutionStream = YES; return self; }
-(ORMutableSignatureI*) columnOut { providesColumn = YES; return self; }
-(ORMutableSignatureI*) constraintOut { providesConstraint = YES; return self; }
-(ORMutableSignatureI*) upperIn { acceptsUpperBound = YES; return self; }
-(ORMutableSignatureI*) upperStreamIn { acceptsUpperBoundStream = YES; return self; }
-(ORMutableSignatureI*) upperPoolIn { acceptsUpperBoundPool = YES; return self; }
-(ORMutableSignatureI*) lowerIn { acceptsLowerBound = YES; return self; }
-(ORMutableSignatureI*) lowerStreamIn { acceptsLowerBoundStream = YES; return self; }
-(ORMutableSignatureI*) lowerPoolIn { acceptsLowerBoundPool = YES; return self; }
-(ORMutableSignatureI*) solutionStreamIn { acceptsSolutionStream = YES; return self; }
-(ORMutableSignatureI*) columnIn { acceptsColumn = YES; return self; }
-(ORMutableSignatureI*) constraintIn { acceptsConstraint = YES; return self; }
@end

@implementation ORFactory(ORSignature)
+(id<ORSignature>) createSignature: (NSString*)sigString {
    ORMutableSignatureI* sig = [[[ORMutableSignatureI alloc] init] autorelease];
    sig = [sig valueForKeyPath: sigString];
    return sig;
}
@end

@implementation ORUpperBoundedRunnableI

-(id) initWithModel:(id<ORModel>)m {
    if((self = [super init]) != nil) {
        _model = [m retain];
        _sig = nil;
        _upperBoundStreamInformer = [[ORInformerI alloc] initORInformerI];
        _upperBoundStreamConsumers = [[NSMutableArray alloc] initWithCapacity: 8];
        _solutionStreamInformer = [[ORInformerI alloc] initORInformerI];
        _solutionStreamConsumers = [[NSMutableArray alloc] initWithCapacity: 8];
    }
    return self;
}

-(id<ORModel>) model { return _model; }

-(void) onExit: (ORClosure)block {
    _exitBlock = [block copy];
}

-(void) dealloc {
    [_model release];
    [_upperBoundStreamInformer release];
    [_upperBoundStreamConsumers release];
    [_solutionStreamInformer release];
    [_solutionStreamConsumers release];
    [_sig release];
    [_exitBlock release];
    [super dealloc];
}


-(id<ORSignature>) signature {
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.upperStreamOut.upperStreamIn.solutionStreamOut.solutionStreamIn"];
    }
    return _sig;
}

-(void) run {}

-(void) addUpperBoundStreamConsumer:(id<ORUpperBoundStreamConsumer>)c {
    NSLog(@"Adding upper bound consumer...");
    [_upperBoundStreamConsumers addObject: c];
}

-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c {
    NSLog(@"Adding solution stream consumer...");
    [_solutionStreamConsumers addObject: c];
}

-(id<ORIntInformer>) upperBoundStreamInformer {
    return _upperBoundStreamInformer;
}

-(id<ORSolutionInformer>) solutionStreamInformer {
    return _solutionStreamInformer;
}

@end

@interface CPRunnableI(Private)
-(void) setupRun;
@end

@implementation CPRunnableI {
    id<CPProgram> _program;    
}

-(id) initWithModel: (id<ORModel>)m {
    if((self = [super initWithModel: m]) != nil) {
        _program = [ORFactory createCPProgram: _model];
    }
    return self;
}

-(void) dealloc {
    [_program release];
    [super dealloc];
}

-(id<CPProgram>) solver { return _program; }

-(void) setupRun {
    [[self upperBoundStreamInformer] wheneverNotifiedDo: ^void(ORInt b) {
        NSLog(@"(%p) recieved upper bound: %i", self, b);
        [[[_program engine] objective] tightenPrimalBound: b];
    }];
}

-(void) run {
    NSLog(@"Running CP runnable(%p)...", _program);
    [self setupRun];
    id<CPHeuristic> h = [_program createFF];
    // When a solution is found, pass the objective value to consumers.
    [_program onSolution:^{
        id<ORSolution> s = [_model captureSolution];
        NSLog(@"(%p) objective tightened: %i", self, [[[_program engine] objective] primalBound]);
        for(id<ORUpperBoundStreamConsumer> c in _upperBoundStreamConsumers)
            [[c upperBoundStreamInformer] notifyWith: (ORInt)[[[_model objective] value] key]];
        NSMutableArray* sp = _solutionStreamConsumers;
        for(id<ORSolutionStreamConsumer> c in sp)
            [[c solutionStreamInformer] notifyWithSolution: s];
    }];
    
    [_program onExit: ^ {
        if(_exitBlock) _exitBlock();
        else {
            id<ORSolution> best = [[_program solutionPool] best];
            [_model restore:best];
            [best release];
        }
    }];
    
    [_program solve:
     ^() {
         NSLog(@"Solving CP program...");
         [_program labelHeuristic: h];
     }];
    NSLog(@"Finishing CP runnable(%p)...", _program);
}

-(void) restore: (id<ORSolution>)s {
    [[_program engine] enforce: ^ORStatus() {
        [_model restore: s];
        return ORSuccess;
    }];
    
}

@end

@implementation LPRunnableI {
    id<ORModel> _model;
    id<ORSignature> _sig;
    id<LPProgram> _program;
}

-(id) initWithModel: (id<ORModel>)m {
    if((self = [super init]) != nil) {
        _model = [m retain];
        _sig = nil;
        _program = [ORFactory createLPProgram: _model];
    }
    return self;
}

-(void) dealloc {
    [_model release];
    [_program release];
    [super dealloc];
}

-(id<ORModel>) model { return _model; }

-(id<ORSignature>) signature {
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete"];
    }
    return _sig;
}

-(id<LPProgram>) solver { return _program; }

-(id<ORFloatArray>) duals {
    return [[_program solver] duals];
}

-(void) injectColumn: (id<ORFloatArray>) col {
    
}

-(void) run {
    NSLog(@"Running LP runnable(%p)...", _program);
    [_program solve];
    NSLog(@"Finishing LP runnable(%p)...", _program);
}

-(void) onExit: (ORClosure)block {}

@end

@implementation ORFactory(ORRunnable)
+(id<ORRunnable>) CPRunnable: (id<ORModel>)m {
    id<ORRunnable> r = [[CPRunnableI alloc] initWithModel: m];
    return r;
}
+(id<LPRunnable>) LPRunnable: (id<ORModel>)m {
    id<LPRunnable> r = [[LPRunnableI alloc] initWithModel: m];
    return r;
}
@end
