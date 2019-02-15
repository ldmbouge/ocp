//
//  ORSequentialRunnable.m
//  Clo
//
//  Created by Daniel Fontaine on 12/4/16.
//
//

#import "ORSequentialRunnable.h"
#import <ORProgram/ORSolution.h>

@implementation ORSequentialRunnableI {
    id<ORSolution> _bestSol;
    id<ORRunnable> _primary;
    id<ORRunnable> _bounding;
}

-(id) initWithPrimaryRunnable:(id<ORRunnable>)r0 boundingRunnable:(id<ORRunnable>)r1
{
    if((self = [super initWithModel: [r0 model]]) != nil) {
        _primary = [r0 retain];
        _bounding = [r1 retain];
        _bestSol = nil;
    }
    return self;
}

-(void) dealloc
{
    [_primary release];
    [_bounding release];
    [_bestSol release];
    [super dealloc];
}

-(id<ORModel>) model {
    return [_primary model];
}

-(ORDouble) bestBound {
    return [[_bestSol objectiveValue] doubleValue];
}

-(void) setTimeLimit:(ORFloat)secs {
    assert(NO);
}

-(id<ORSolution>) bestSolution {
    return _bestSol;
}

-(void) run
{
    [_bounding run];
    _bestSol = [_bounding bestSolution];
    [_primary performOnStart:^{
        [(id<ORUpperBoundStreamConsumer>)_primary receiveUpperBound: (ORInt)[self bestBound]];
    }];
    [_primary run];
    id<ORSolution> best = [_primary bestSolution];
    if([[best objectiveValue] doubleValue] < [[_bestSol objectiveValue] doubleValue])
        _bestSol = best;
}

-(id<ORRunnable>) primaryRunnable   { return _primary; }
-(id<ORRunnable>) boundingRunnable { return _bounding; }


@end

