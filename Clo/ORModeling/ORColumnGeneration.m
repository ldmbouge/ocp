/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORColumnGeneration.h"

@implementation ORColumnGeneration {
    @protected
    id<LPRunnable> _master;
    ORFloatArray2Runnable _slaveClosure;
    id<ORSignature> _sig;
}

-(id) initWithMaster: (id<LPRunnable>)master slave: (ORFloatArray2Runnable)slaveClo {
    if((self = [super init]) != nil) {
        _master = master;
        _slaveClosure = slaveClo;
        _sig = nil;
    }
    return self;
}

-(id<ORSignature>) signature {
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete"];
    }
    return _sig;
}

-(id<ORModel>) model { return [_master model]; }

-(void) run {
    ORFloat reducedCost = 0.0;
    do {
        [_master run];
        id<ORFloatArray> duals = [[_master duals] retain];
        id<ORRunnable> slave = _slaveClosure(duals);
        [duals release];
        [slave run];
        reducedCost = [[[[slave model] objective] value] key];
    } while(reducedCost >= -0.00001);
}

-(void) onExit: (ORClosure)block {}

@end
