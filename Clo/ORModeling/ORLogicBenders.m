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
    ORSolution2Process _slaveBlock;
    id<ORSignature> _sig;
    id<ORConstraintSetInformer> _constraintSetInformer;
}

-(id) initWithMaster: (id<ORRunnable>)master slave: (ORSolution2Process)slaveBlock {
    if((self = [super init]) != nil) {
        _master = [master retain];
        _slaveBlock = [slaveBlock copy];
        _sig = nil;
        _constraintSetInformer = [[ORInformerI alloc] initORInformerI];
    }
    return self;
}

-(void) dealloc {
    [_master release];
    [_sig release];
    [_constraintSetInformer release];
    [_slaveBlock release];
    [super dealloc];
}

-(id<ORSignature>) signature {
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.constraintSetIn"];
    }
    return _sig;
}

-(id<ORModel>) model { return [_master model]; }

-(void) run {
    __block BOOL isFeasible = NO;
    do {
        [_master run];
        id<ORSolution> solution = [[[_master solver] solutionPool] best];  // Solution pools are on Solvers.
        id<ORProcess> slave = _slaveBlock(solution);
        if(![[slave signature] providesConstraint]) {
            [NSException raise: NSGenericException
                        format: @"Invalid Signature(ORLogicBenders): Slave does not produce a constraint."];
        }
        [[self constraintSetInformer] whenNotifiedDo: ^(id<ORConstraintSet> set) {
            if(set == nil || [set size] == 0) isFeasible = YES;
            else [set enumerateWith:^(id<ORConstraint> c) { [[_master model] add: c]; } ]; // Inject cuts
        }];
        [slave run];
        [slave release];
    } while(!isFeasible);
}

-(void) onExit: (ORClosure)block {}

-(id<ORConstraintSetInformer>) constraintSetInformer { return _constraintSetInformer; }

@end

@implementation ORCutGenerator {
@private
    ORVoid2ConstraintSet _block;
    id<ORSignature> _sig;
    NSMutableArray* _constraintSetConsumers;
}

-(id) initWithBlock: (ORVoid2ConstraintSet)block
{
    if((self = [super init]) != nil) {
        _block = [block copy];
        _constraintSetConsumers = [[NSMutableArray alloc] initWithCapacity: 8];
    }
    return self;
}

-(void) dealloc
{
    [_constraintSetConsumers release];
    [_block release];
    [super dealloc];
}

-(id<ORSignature>) signature
{
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"constraintSetOut"];
    }
    return _sig;
}

-(void) run
{
    id<ORConstraintSet> set = _block();
    for(id<ORConstraintSetConsumer> c in _constraintSetConsumers)
        [[c constraintSetInformer] notifyWithConstraintSet: set];
}

-(void) addConstraintSetConsumer:(id<ORConstraintSetConsumer>)c
{
    [_constraintSetConsumers addObject: c];
}

@end

@implementation ORFactory(ORLogicBenders)
+(id<ORRunnable>) logicBenders: (id<ORRunnable>)master slave: (ORSolution2Process)slaveBlock {
    return [[ORLogicBenders alloc] initWithMaster: master slave: slaveBlock];
}
+(id<ORProcess>) generateCuts: (ORVoid2ConstraintSet)block {
    ORCutGenerator* generator = [[ORCutGenerator alloc] initWithBlock: block];
    return generator;
}
@end