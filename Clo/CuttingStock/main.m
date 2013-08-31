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
#import <ORProgram/ORRunnable.h>
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
    id<OROrderedConstraintSet> c = [ORFactory orderedConstraintSet: master range: shelves with: ^id<ORConstraint>(ORInt i) {
        return [master add: [Sum(master, j, shelves, [cut[j] mul: @([columns at: j * shelfCount + i])]) geq: @([demand at: i])]];
    }];
    [master minimize: Sum(master, i, shelves, cut[i])];

    id<ORRunnable> lp = [ORFactory LPRunnable: master];
    id<ORRunnable> cg = [ORFactory columnGeneration: lp slave: ^id<LPColumn>() {
        id<LPProgram> linearSolver = [((LPRunnableI*)lp) solver];
        id<ORModel> slave = [ORFactory createModel];
        id<ORIntVarArray> use = [ORFactory intVarArray: slave range: shelves domain: RANGE(slave, 0, boardWidth)];
        id<ORFloatArray> cost = [ORFactory floatArray: slave range: shelves with: ^ORFloat(ORInt i) {
            return [linearSolver dual: [c at: i]];
        }];
        [slave add: [Sum(slave, i, shelves, [use[i] mul: @([shelf at: i])]) leq: @(boardWidth)]];
        [slave minimize: [@1  sub:Sum(slave, i, shelves, [use[i] mul: @([cost at: i])])]];
        id<ORRunnable> slaveRunnable = [ORFactory CPRunnable: slave];
        [slaveRunnable start];
        id<CPProgram> slaveSolver = [(CPRunnableI*)slaveRunnable solver];  // [ldm] fixed bug. Not slave -> slaveRunnable
        id<ORCPSolution> sol = [[slaveSolver solutionPool] best];
        NSLog(@"SLAVE Sol: %@",sol);
        if ([(id<ORObjectiveValueFloat>)[sol objectiveValue] value] < -0.00001)
           return [ORFactory column: linearSolver solution: sol array: use constraints: c];
         else return nil;
    }];
    [cg run];
   
    // [ldm] The variables added as part of the column addition are not showing up in the variables dico..... grrrrrr. 
    for(id<ORFloatVar> v in [[lp model] variables])
        NSLog(@"var(%@): %f", [v description], [[lp solver] floatValue:v]);
    
    //NSLog(@"%@", [master description]);
    //NSLog(@"master objective: %i", [masterObj value]);
    //NSLog(@"master done");
    
    return 0;
}

