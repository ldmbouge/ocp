/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
    id<ORModel> master = [ORFactory createModel];
    
    ORInt width = 110;
    ORInt shelfCount = 5;
    id<ORIntRange> shelves = RANGE(master,0,shelfCount - 1);
    id<ORIntArray> shelf   = [ORFactory intArray: master  array:@[@20, @45, @50, @55, @75]];
    id<ORIntArray> demand  = [ORFactory intArray: master array: @[@48, @35, @24, @10, @8]];
    id<ORIntArray> columns = [ORFactory intArray: master range: shelves range: shelves with:^ORInt(ORInt i, ORInt j) {
        if(i == j) return (ORInt)floor(width / [shelf at: i]);
        return 0.0;
    }];
    id<ORRealVarArray> cut = [ORFactory realVarArray: master range: shelves low:0 up:[demand max] names:@"cut"];
    for(ORInt i = [shelves low]; i <= [shelves up]; i++) {
        [master add: [Sum(master, j, shelves, [cut[j] mul: @([columns at: j * shelfCount + i])]) geq: @([demand at: i])]];
    }
    [master minimize: Sum(master, i, shelves, cut[i])];
    id<ORRunnable> lp = [ORFactory LPRunnable: master];
    
    id<ORRunnable> r = [ORFactory columnGeneration: lp slave:^id<ORDoubleArray>(id<ORDoubleArray> cost) {
        id<ORModel> slave = [ORFactory createModel];
        id<ORIntVarArray> use = [ORFactory intVarArray: slave range: shelves domain: RANGE(slave, 0, shelfCount-1)];
        [slave minimize: [Sum(slave, i, shelves, [use[i] mul: @([cost at: i])]) mul: @(-1)]];
        [slave add: [Sum(slave, i, shelves, [@([shelf at: i]) mul: use[i]]) leq: @(width)]];
        id<MIPProgram> ip = [ORFactory createMIPProgram: slave];
        [ip solve];
        id<ORSolution> sol = [[ip solutionPool] best];
        ORDouble reducedCost = [[sol objectiveValue] doubleValue] + 1;
       NSLog(@"reduced cost %f for sol : %@", reducedCost,sol);
        id<ORDoubleArray> col = nil;
        if(reducedCost < -0.00001) {
            col = [ORFactory doubleArray: slave range: [use range] with:^ORDouble(ORInt i) {
                return [sol intValue: use[i]];
            }];
        }
        return col;
    }];

    [r run];
    NSLog(@"Best: %@", [r bestSolution]);
    
    return 0;
}
