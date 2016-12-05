/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "MIPRunnable.h"
#import "ORLogicBenders.h"
#import "ORConcurrencyI.h"

@implementation ORLogicBenders

@synthesize timeInMaster;
@synthesize timeInSlave;

-(id) initWithMaster: (id<ORRunnable>)master slave: (ORSolution2ConstraintSet)slaveBlock {
    if((self = [super init]) != nil) {
        _master = [master retain];
        _slaveBlock = [slaveBlock copy];
        _bestSol = nil;
        _sig = nil;
        
        timeInMaster = 0;
        timeInSlave = 0;
    }
    return self;
}

-(void) dealloc {
    [_master release];
    [_sig release];
    [_slaveBlock release];
    [_bestSol release];
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
    NSDate* t0;
    NSDate* t1;
    __block BOOL isFeasible = NO;
    do {
        t0 = [NSDate date];
        [_master run];
        t1 = [NSDate date];
        timeInMaster += [t1 timeIntervalSinceDate: t0];
        t0 = [NSDate date];
        id<ORConstraintSet> cut = _slaveBlock([_master bestSolution]);
        t1 = [NSDate date];
        timeInSlave += [t1 timeIntervalSinceDate: t0];
        
        if(cut == nil || [cut size] == 0) {
            isFeasible = YES;
            _bestSol = [_master bestSolution];
        }
        else [(id<MIPRunnable>)_master addCuts: cut]; // Inject cuts
        NSLog(@"constraints in master: %li", [[[_master model] constraints] count]);
    } while(!isFeasible);
    NSLog(@"master %f slave %f", timeInMaster, timeInSlave);
}

-(id<ORSolution>) bestSolution
{
    return _bestSol;
}

-(ORDouble) bestBound
{
    return [[_bestSol objectiveValue] doubleValue];
}

-(void) onExit: (ORClosure)block {}

@end

@implementation ORFactory(ORLogicBenders)
+(id<ORRunnable>) logicBenders: (id<ORRunnable>)master slave: (ORSolution2ConstraintSet)slaveBlock {
    return [[ORLogicBenders alloc] initWithMaster: master slave: slaveBlock];
}
@end
