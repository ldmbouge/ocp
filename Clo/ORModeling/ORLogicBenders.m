/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import "ORLogicBenders.h"
#import "ORConcurrencyI.h"

@implementation ORLogicBenders {
@protected
    id<ORRunnable> _master;
    ORSolution2Runnable _slaveBlock;
    id<ORSignature> _sig;
    id<ORConstraintInformer> _constraintInformer;
}

-(id) initWithMaster: (id<ORRunnable>)master slave: (ORSolution2Runnable)slaveBlock {
    if((self = [super init]) != nil) {
        _master = [master retain];
        _slaveBlock = [slaveBlock copy];
        _sig = nil;
        _constraintInformer = [[ORInformerI alloc] initORInformerI];
    }
    return self;
}

-(void) dealloc {
    [_master release];
    [_sig release];
    [_constraintInformer release];
    [_slaveBlock release];
    [super dealloc];
}

-(id<ORSignature>) signature {
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.constraintIn"];
    }
    return _sig;
}

-(id<ORModel>) model { return [_master model]; }

-(void) run {
    bool isFeasible = NO;
    do {
        [_master run];
        id<ORSolution> solution = [[_master model] bestSolution];
        id<ORRunnable> slave = [_slaveBlock(solution) retain];
        if(![[slave signature] providesConstraint]) {
            [NSException raise: NSGenericException
                        format: @"Invalid Signature(ORLogicBenders): Slave does not produce a constraint."];
        }
        [[self constraintInformer] whenNotifiedDo: ^(id<ORConstraint> c) { /* Add cut */ }];
        [slave run];
        isFeasible = [[slave model] bestSolution] != nil; // FIX: Not sure how to check if feasible from the modeling layer.
        [slave release];
    } while(!isFeasible);
}

-(void) onExit: (ORClosure)block {}

-(id<ORConstraintInformer>) constraintInformer { return _constraintInformer; }

@end

@implementation ORCutGenerator {
@private
    id<ORRunnable> _runnable;
    ORRunnable2Constraint _transform;
    id<ORSignature> _sig;
    NSMutableArray* _constraintConsumers;
}

-(id) initWithRunnable: (id<ORRunnable>)r cutTransform: (ORRunnable2Constraint)block {
    if((self = [super init]) != nil) {
        _runnable = [r retain];
        _transform = [block copy];
        _constraintConsumers = [[NSMutableArray alloc] initWithCapacity: 8];
    }
    return self;
}

-(void) dealloc {
    [_runnable release];
    [_constraintConsumers release];
    [_transform release];
    [super dealloc];
}

-(id<ORSignature>) signature {
    if(_sig == nil) {
        ORMutableSignatureI* sig = [[ORMutableSignatureI alloc] initFromSignature: [_runnable signature]];
        _sig = [sig constraintOut];
    }
    return _sig;
}

-(id<ORModel>) model { return [_runnable model]; }

-(void) run {
    [_runnable run];
    id<ORConstraint> constraint = _transform(_runnable);
    for(id<ORConstraintConsumer> c in _constraintConsumers)
        [[c constraintInformer] notifyWithConstraint: constraint];
}

-(void) onExit: (ORClosure)block {
    [_runnable onExit: block];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([_runnable respondsToSelector:
         [anInvocation selector]])
        [anInvocation invokeWithTarget: _runnable];
    else [super forwardInvocation:anInvocation];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if([super respondsToSelector:aSelector]) return YES;
    else if([_runnable respondsToSelector: aSelector]) return YES;
    return NO;
}

-(void) addConstraintConsumer:(id<ORConstraintConsumer>)c
{
    [_constraintConsumers addObject: c];
}

@end

@implementation ORFactory(ORLogicBenders)
+(id<ORRunnable>) logicBenders: (id<ORRunnable>)master slave: (ORSolution2Runnable)slaveBlock {
    return [[ORLogicBenders alloc] initWithMaster: master slave: slaveBlock];
}
+(id<ORRunnable>) generateCut: (id<ORRunnable>)r using: (ORRunnable2Constraint)block {
    ORCutGenerator* generator = [[ORCutGenerator alloc] initWithRunnable: r cutTransform: block];
    return generator;
}
@end