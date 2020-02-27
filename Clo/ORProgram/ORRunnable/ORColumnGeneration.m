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
#import <objmp/LPSolverI.h>
#import <ORProgram/ORProgram.h>
#import <ORProgram/ORSolution.h>

@implementation ORColumnGeneration {
    @protected
    id<ORRunnable> _master;
    DoubleArray2DoubleArray _slaveBlock;
    id<ORSignature> _sig;
    id<ORSolution> _bestSol;
}

-(id) initWithMaster: (id<ORRunnable>)master slave: (DoubleArray2DoubleArray)slaveBlock {
    if((self = [super init]) != nil) {
        _master = [master retain];
        _slaveBlock = [slaveBlock copy];
        _sig = nil;
        _bestSol = nil;
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
        _sig = [ORFactory createSignature: @"complete.columnIn"];
    }
    return _sig;
}

-(id<ORModel>) model { return [_master model]; }

-(ORDouble) bestBound
{
    return [[_bestSol objectiveValue] doubleValue];
}

-(id<ORSolution>) bestSolution
{
    return _bestSol;
}

-(void) run {
    id<ORModel> model = [_master model];
    NSArray* cstrs = [model constraints];
    id<LPRunnable> master = (id<LPRunnable>)_master;
    id<LPProgram> lp = [master solver];
   [master run];
    while(1) {
        id<LPSolution> sol = (id<LPSolution>)[[lp solutionPool] best];
        _bestSol = (id<ORSolution>)sol;
       NSLog(@"master sol : %@",sol);
        id<ORDoubleArray> costs = [ORFactory doubleArray: model range: RANGE(model, 0, (int)[cstrs count]-1) with:^ORDouble(ORInt i) {
            return [sol dual: cstrs[i]];
        }];
        id<ORDoubleArray> col = _slaveBlock(costs);
        [costs release];
        if(col == nil) break;
        
        // Inject Column into master
        id<LPColumn> lpcol = [lp createColumn];
        [lpcol addObjCoef: 1.0];
        for(ORInt i = [col low]; i <= [col up]; i++) {
            [lpcol addConstraint: cstrs[i - [col low]] coef: [col at: i]];
        }
        [master injectColumn: lpcol];
        [master solver];
//        [[master solver] printModelToFile:"/Users/zitoun/Desktop/master.lp"];
    }
}

@end

@implementation ORFactory(ORColumnGeneration)
+(id<ORRunnable>) columnGeneration: (id<LPRunnable>)master slave:(DoubleArray2DoubleArray)slaveBlock
{
    return [[ORColumnGeneration alloc] initWithMaster: master slave: slaveBlock];
}
@end
