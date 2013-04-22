//
//  ORRunnablePiping.m
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import "ORRunnablePiping.h"
#import "ORRunnable.h"
#import "ORConcurrencyI.h"

@implementation ORPipedRunnable {
@protected
    id<ORSignature> _sig;
    id<ORIntInformer> _upperBoundStreamInformer;
    id<ORIntInformer> _lowerBoundStreamInformer;
    id<ORSolutionInformer> _solutionStreamInformer;
    NSMutableArray* _upperBoundStreamConsumers;
    NSMutableArray* _lowerBoundStreamConsumers;
    NSMutableArray* _solutionStreamConsumers;
    
    id<ORFloatArray> _col;
}

-(id) initWithModel:(id<ORModel>)m
{
    if((self = [super initWithModel: m]) != nil) {
        _sig = nil;
        _upperBoundStreamInformer = nil;
        _lowerBoundStreamInformer = nil;
        _solutionStreamInformer = nil;
        _upperBoundStreamConsumers = nil;
        _lowerBoundStreamConsumers = nil;
        _solutionStreamConsumers = nil;
        _col = nil;
    }
    return self;
}

-(void) doExit {
    if(_exitBlock) _exitBlock();
}

-(void) dealloc
{
    [_upperBoundStreamInformer release];
    [_lowerBoundStreamInformer release];
    [_solutionStreamInformer release];
    [_upperBoundStreamConsumers release];
    [_lowerBoundStreamConsumers release];
    [_solutionStreamConsumers release];
    [_sig release];
    [super dealloc];
}

-(id<ORSignature>) signature
{
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.upperStreamOut.upperStreamIn.solutionStreamOut.solutionStreamIn"];
    }
    return _sig;
}

-(void) run {}

-(void) addUpperBoundStreamConsumer:(id<ORBoundStreamConsumer>)c
{
    NSLog(@"Adding upper bound consumer...");
    if(_upperBoundStreamConsumers == nil)
        _upperBoundStreamConsumers = [[NSMutableArray alloc] initWithCapacity: 4];
    [_upperBoundStreamConsumers addObject: c];
}

-(void) addLowerBoundStreamConsumer:(id<ORBoundStreamConsumer>)c
{
    NSLog(@"Adding lower bound consumer...");
    if(_lowerBoundStreamConsumers == nil)
        _lowerBoundStreamConsumers = [[NSMutableArray alloc] initWithCapacity: 4];
    [_lowerBoundStreamConsumers addObject: c];
}

-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c
{
    NSLog(@"Adding solution stream consumer...");
    if(_solutionStreamConsumers == nil)
        _solutionStreamConsumers = [[NSMutableArray alloc] initWithCapacity: 4];
    [_solutionStreamConsumers addObject: c];
}

-(void) receivedUpperBound: (ORInt)bound {}
-(void) receivedLowerBound: (ORInt)bound {}
-(void) receivedSolution: (id<ORSolution>)sol {}

-(id<ORIntInformer>) useUpperBoundStreamInformer
{
    if(_upperBoundStreamInformer == nil) {
        _upperBoundStreamInformer = [[ORInformerI alloc] initORInformerI];
        [_upperBoundStreamInformer wheneverNotifiedDo: ^void(ORInt b) {
            [self receivedUpperBound: b];
        }];
    }
}

-(id<ORIntInformer>) useLowerBoundStreamInformer
{
    if(_lowerBoundStreamInformer == nil) {
        _lowerBoundStreamInformer = [[ORInformerI alloc] initORInformerI];
        [_lowerBoundStreamInformer wheneverNotifiedDo: ^void(ORInt b) {
            [self receivedLowerBound: b];
        }];
    }
}

-(id<ORSolutionInformer>) useSolutionStreamInformer
{
    if(_solutionStreamInformer == nil) {
        _solutionStreamInformer = [[ORInformerI alloc] initORInformerI];
        [_solutionStreamInformer wheneverNotifiedDo: ^void(id<ORSolution> s) {
            [self receivedSolution: s];
        }];
    }
}

-(void) produceColumn: (id<ORFloatArray>)col
{
    _col = col;
}

-(id<ORFloatArray>) retrieveColumn
{
    return _col;
}

-(id<ORIntInformer>) upperBoundStreamInformer
{
    return _upperBoundStreamInformer;
}

-(id<ORIntInformer>) lowerBoundStreamInformer
{
    return _lowerBoundStreamInformer;
}

-(id<ORSolutionInformer>) solutionStreamInformer
{
    return _solutionStreamInformer;
}

-(void) notifyUpperBound: (ORInt)bound {
    if(_upperBoundStreamConsumers) {
        for(id<ORBoundStreamConsumer> c in _upperBoundStreamConsumers) {
            [[c boundStreamInformer] notifyWith: bound];
        }
    }
}

-(void) notifyLowerBound: (ORInt)bound {
    if(_lowerBoundStreamConsumers) {
        for(id<ORBoundStreamConsumer> c in _lowerBoundStreamConsumers) {
            [[c boundStreamInformer] notifyWith: bound];
        }
    }
}

-(void) notifySolution: (id<ORSolution>)sol {
    if(_solutionStreamConsumers) {
        for(id<ORSolutionStreamConsumer> c in _solutionStreamConsumers) {
            [[c solutionStreamInformer] notifyWithSolution: sol];
        }
    }
}

@end
