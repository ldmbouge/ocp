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
    Void2ConstraintSet _slaveBlock;
    id<ORSignature> _sig;
}

-(id) initWithMaster: (id<ORRunnable>)master slave: (Void2ConstraintSet)slaveBlock {
    if((self = [super init]) != nil) {
        _master = [master retain];
        _slaveBlock = [slaveBlock copy];
        _sig = nil;
    }
    return self;
}

-(void) dealloc {
    [_master release];
    [_sig release];
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
        id<ORConstraintSet> cut = _slaveBlock();
        
        if(cut == nil || [cut size] == 0) isFeasible = YES;
        else [cut enumerateWith:^(id<ORConstraint> c) {
            [[_master model] add: c]; }]; // Inject cuts
    } while(!isFeasible);
}

-(void) onExit: (ORClosure)block {}

@end

@implementation ORFactory(ORLogicBenders)
+(id<ORRunnable>) logicBenders: (id<ORRunnable>)master slave: (Void2ConstraintSet)slaveBlock {
    return [[ORLogicBenders alloc] initWithMaster: master slave: slaveBlock];
}
@end
