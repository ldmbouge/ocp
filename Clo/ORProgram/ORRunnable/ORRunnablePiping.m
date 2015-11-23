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
    id<ORDoubleInformer> _lowerBoundStreamInformer;
    id<ORSolutionInformer> _solutionStreamInformer;
    id<ORDoubleArray> _col;
}

-(id) initWithModel: (id<ORModel>)m;
{
    if((self = [super initWithModel: m]) != nil) {
        _sig = nil;
        _col = nil;
        _upperBoundStreamInformer = [[ORInformer alloc] initORInformer];
        _lowerBoundStreamInformer = [[ORInformer alloc] initORInformer];
        _solutionStreamInformer = [[ORInformer alloc] initORInformer];
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

-(void) addUpperBoundStreamConsumer:(id<ORUpperBoundStreamConsumer>)c
{
    NSLog(@"Adding upper bound consumer...");
    [_upperBoundStreamInformer wheneverNotifiedDo: ^(ORInt b) { [c receiveUpperBound: b]; }];
}

-(void) addLowerBoundStreamConsumer:(id<ORLowerBoundStreamConsumer>)c
{
    NSLog(@"Adding lower bound consumer...");
    [_lowerBoundStreamInformer wheneverNotifiedDo: ^(ORDouble b) { [c receiveLowerBound: b]; }];
}

-(void) addSolutionStreamConsumer: (id<ORSolutionStreamConsumer>)c
{
    NSLog(@"Adding solution stream consumer...");
    [_solutionStreamInformer wheneverNotifiedDo: ^(id<ORSolution> s) { [c receiveSolution: s]; }];
}

-(void) produceColumn: (id<ORDoubleArray>)col
{
    _col = col;
}

-(id<ORDoubleArray>) retrieveColumn
{
    return _col;
}

-(void) notifyUpperBound: (ORInt)bound {
    [_upperBoundStreamInformer notifyWith: bound];
}

-(void) notifyLowerBound: (ORDouble)bound {
    [_lowerBoundStreamInformer notifyWithFloat: bound];
}

-(void) notifySolution: (id<ORSolution>)sol {
    [_solutionStreamInformer notifyWithSolution: sol];
}

-(id<ORIntInformer>) upperBoundStreamInformer { return _upperBoundStreamInformer; }
-(id<ORDoubleInformer>) lowerBoundStreamInformer { return _lowerBoundStreamInformer; }
-(void) receiveUpperBound: (ORInt)bound {}
-(void) receiveLowerBound: (ORDouble)bound {}
-(id<ORSolutionInformer>) solutionStreamInformer { return nil; }
-(void) receiveSolution: (id<ORSolution>)sol {}
-(id<ORConstraintSetInformer>) constraintSetInformer { return nil; }
-(void) receiveConstraintSet: (id<ORConstraintSet>)set {}
-(void) addConstraintSetConsumer: (id<ORConstraintSetConsumer>)c {}
-(void) notifyConstraintSet: (id<ORConstraintSet>)set {}

@end
