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
#import <ORProgram/ORConcretizer.h>
#import <ORProgram/LPProgram.h>
#import <objcp/CPFactory.h>
#import "../ORModeling/ORLinearize.h"
#import "../ORModeling/ORFlatten.h"
#import "ORRunnable.h"
#import "ORParallelRunnable.h"

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
    id<ORIntVarArray> cut = [ORFactory intVarArray: master range: shelves domain: RANGE(master, 0, [demand max])];    
    id<ORIntVar> masterObj = [ORFactory intVar: master domain: RANGE(master, 0, shelfCount * [demand max])];
    [master minimize: masterObj];
    [master add: [masterObj eq: Sum(master, i, shelves, [cut at: i])]];
    for(ORInt i = [shelves low]; i <= [shelves up]; i++) {
        [master add: [Sum(master, j, shelves, [[cut at: j] muli: [columns at: j * shelfCount + i]])
               geqi: [demand at: i]]];
    }

    id<ORRunnable> mr = [[LPRunnableI alloc] initWithModel: master];
    [mr run];
    
    for(id<ORIntVar> v in [master variables])
        NSLog(@"var(%@): %i", [v description], [v value]);
    
    //NSLog(@"%@", [master description]);
    NSLog(@"master objective: %i", [masterObj value]);
    NSLog(@"master done");
    
    //id<ORModel> slave = [ORFactory createModel];
    //id<ORIntVarArray> use = [ORFactory intVarArray: slave range: shelves domain: RANGE(master, 0, boardWidth)];
    //id<ORIntArray> cost = [ORFactory intArray: slave range: shelves with: ^ORInt(ORInt i) { return }];
    
    /*
    model Knapsack {
        var{int} use[shelves](0..board_width);
        var{int} cost[shelves](-100..100);
    objective: Minimize(1 - sum(i in shelves) cost[i] * use[i]);
    post: Satisfy((sum(i in shelves) shelf[i] * use[i]) <= board_width);
    }
    */
    
    return 0;
}

