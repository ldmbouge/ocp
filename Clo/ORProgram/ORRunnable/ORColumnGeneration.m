/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORColumnGeneration.h"
#import "ORConcurrencyI.h"
#import "LPRunnable.h"

@implementation ORColumnGeneration {
    @protected
    id<ORRunnable> _master;
    Void2FloatArray _slaveBlock;
    id<ORSignature> _sig;
}

-(id) initWithMaster: (id<ORRunnable>)master slave: (Void2FloatArray)slaveBlock {
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
        _sig = [ORFactory createSignature: @"complete.columnIn"];
    }
    return _sig;
}

-(id<ORModel>) model { return [_master model]; }

-(void) run {
    id<LPRunnable> master = (id<LPRunnable>)_master;
    while(1) {
        [master run];
        id<ORFloatArray> col = _slaveBlock();
        if(col == nil) break;
        [master injectColumn: col];
    }
}

@end

@implementation ORFactory(ORColumnGeneration)
+(id<ORRunnable>) columnGeneration: (id<LPRunnable>)master slave: (Void2FloatArray)slaveBlock {
    return [[ORColumnGeneration alloc] initWithMaster: master slave: slaveBlock];
}
@end
