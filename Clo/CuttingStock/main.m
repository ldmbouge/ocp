/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/LPProgram.h>
#import <objcp/CPFactory.h>
#import "../ORModeling/ORLinearize.h"
#import "../ORModeling/ORFlatten.h"
#import "ORRunnable.h"
#import "ORParallelRunnable.h"
#import "ORColumnGeneration.h"
#import "LPRunnable.h"
#import "CPRunnable.h"

int main (int argc, const char * argv[])
{
    id<ORModel> master = [ORFactory createModel];

    ORInt boardWidth = 110;
    ORInt shelfCount = 5;
    id<ORIntRange> shelves = [ORFactory intRange: master low: 0 up: shelfCount - 1];
    ORInt shelfValues[] = {20, 45, 50, 55, 75};
    id<ORIntArray> shelf = [ORFactory intArray: master range: shelves values: shelfValues];
    ORInt demandValues[] = {48, 35, 24, 10, 8};
    id<ORIntArray> demand = [ORFactory intArray: master range: shelves values: demandValues];
    id<ORIntArray> columns = [ORFactory intArray: master range: shelves range: shelves with:^ORInt(ORInt i, ORInt j) {
        if(i == j) return (ORInt)floor(boardWidth / [shelf at: i]);
        return 0.0;
    }];
    id<ORFloatVarArray> cut = [ORFactory floatVarArray: master range: shelves low:0 up:[demand max]];
    id<ORFloatVar> masterObj = [ORFactory floatVar: master  low:0 up:shelfCount*[demand max]];
    [master add: [masterObj eq: Sum(master, i, shelves, cut[i])]];
    id<OROrderedConstraintSet> c = [ORFactory orderedConstraintSet: master range: shelves with: ^id<ORConstraint>(ORInt i) {
        return [master add: [Sum(master, j, shelves, [[cut at: j] mul: @([columns at: j * shelfCount + i])])
                             geq: @([demand at: i])]];
    }];
    [master minimize: masterObj];

    id<ORRunnable> lp = [ORFactory LPRunnable: master];
    id<ORRunnable> cg = [ORFactory columnGeneration: lp slave: ^id<LPColumn>() {
        id<LPProgram> linearSolver = [((LPRunnableI*)lp) solver];
        id<ORModel> slave = [ORFactory createModel];
        id<ORIntVarArray> use = [ORFactory intVarArray: slave range: shelves domain: RANGE(slave, 0, boardWidth)];
        id<ORFloatArray> cost = [ORFactory floatArray: slave range: shelves with: ^ORFloat(ORInt i) {
            return [linearSolver dual: [c at: i]];
        }];
        id<ORIntVar> objective = [ORFactory intVar: slave domain: RANGE(slave, -10000, 10000)];
        [slave add: [Sum(slave, i, shelves, [[use at: i] mul: @([cost at: i])]) leq: objective]];
        [slave add: [Sum(slave, i, shelves, [[use at: i] mul: @([shelf at: i])]) leq: @(boardWidth)]];
        [slave minimize: objective];
        id<ORRunnable> slaveRunnable = [ORFactory CPRunnable: slave];
        [slaveRunnable start];
        id<CPProgram> slaveSolver = [(CPRunnableI*)slave solver];
        id<ORCPSolution> sol = [[slaveSolver solutionPool] best];
        //NSLog(@"sol: %@", sol);
        return [ORFactory column: linearSolver solution: sol array: use constraints: c];
    }];
    [cg run];
    
    for(id<ORFloatVar> v in [[lp model] variables])
        NSLog(@"var(%@): %f", [v description], [[lp solver] floatValue:v]);
    
    //NSLog(@"%@", [master description]);
    //NSLog(@"master objective: %i", [masterObj value]);
    //NSLog(@"master done");
    
    return 0;
}

