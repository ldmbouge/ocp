/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORColumnGeneration.h"
#import "ORConcurrencyI.h"

@implementation ORColumnGeneration {
    @protected
    id<LPRunnable> _master;
    ORFloatArray2Runnable _slaveBlock;
    id<ORSignature> _sig;
    id<ORFloatArrayInformer> _columnInformer;
}

-(id) initWithMaster: (id<LPRunnable>)master slave: (ORFloatArray2Runnable)slaveBlock {
    if((self = [super init]) != nil) {
        _master = [master retain];
        _slaveBlock = [slaveBlock copy];
        _sig = nil;
        _columnInformer = [[ORInformerI alloc] initORInformerI];
    }
    return self;
}

-(void) dealloc {
    [_master release];
    [_sig release];
    [_columnInformer release];
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
    ORFloat reducedCost = 0.0;
    do {
        [_master run];
        id<ORFloatArray> duals = [[_master duals] retain];
       NSLog(@"Show me the duals: %@",duals);
        id<ORRunnable> slave = [_slaveBlock(duals) retain];
        //[duals release];  // [ldm] This is an issue too. The master tracks the guy permanently. This will remove it even though it sits in the master object store!
        //If the array is really meant to be transient, then the master should _not_ track it.
        if(![[slave signature] providesColumn]) {
            [NSException raise: NSGenericException
                        format: @"Invalid Signature(ORColumnGeneration): Slave does not produce a column."];
        }
        [[self columnInformer] whenNotifiedDo: ^(id<ORFloatArray> column) { [_master injectColumn: column]; }];
        [slave run];
       id<ORObjectiveValueInt> ov = [[[slave model] objective] value];
        reducedCost = [ov value];
        [slave release];
    } while(reducedCost >= -0.00001);
}

-(void) onExit: (ORClosure)block {}

-(id<ORFloatArrayInformer>) columnInformer { return _columnInformer; }

@end

@implementation ORColumnGenerator {
    @private
    id<ORRunnable> _runnable;
    ORRunnable2FloatArray _transform;
    id<ORSignature> _sig;
    NSMutableArray* _columnConsumers;
}

-(id) initWithRunnable: (id<ORRunnable>)r solutionTransform: (ORRunnable2FloatArray)block {
    if((self = [super init]) != nil) {
        _runnable = [r retain];
        _transform = [block copy];
        _columnConsumers = [[NSMutableArray alloc] initWithCapacity: 8];
    }
    return self;
}

-(void) dealloc {
    [_runnable release];
    [_columnConsumers release];
    [_transform release];
    [super dealloc];
}

-(id<ORSignature>) signature {
    if(_sig == nil) {
        ORMutableSignatureI* sig = [[ORMutableSignatureI alloc] initFromSignature: [_runnable signature]];
        _sig = [sig columnOut];
    }
    return _sig;
}

-(id<ORModel>) model { return [_runnable model]; }

-(void) run {
    [_runnable run];
    id<ORFloatArray> column = _transform(_runnable);
    for(id<ORColumnConsumer> c in _columnConsumers)
        [[c columnInformer] notifyWithFloatArray: column];
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

- (ORBool)respondsToSelector:(SEL)aSelector {
    if([super respondsToSelector:aSelector]) return YES;
    else if([_runnable respondsToSelector: aSelector]) return YES;
    return NO;
}

-(void) addColumnConsumer: (id<ORSolutionStreamConsumer>)c {
    [_columnConsumers addObject: c];
}

@end

@implementation ORFactory(ORColumnGeneration)
+(id<ORRunnable>) columnGeneration: (id<LPRunnable>)master slave: (ORFloatArray2Runnable)slaveBlock {
    return [[ORColumnGeneration alloc] initWithMaster: master slave: slaveBlock];
}
+(id<ORRunnable>) generateColumn: (id<ORRunnable>)r using: (ORRunnable2FloatArray)block {
    ORColumnGenerator* generator = [[ORColumnGenerator alloc] initWithRunnable: r solutionTransform: block];
    return generator;
}
@end
