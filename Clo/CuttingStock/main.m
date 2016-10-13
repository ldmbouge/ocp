/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORRunnable.h>
#import <ORProgram/ORColumnGeneration.h>
#import <ORProgram/LPProgram.h>
#import <ORProgram/LPRunnable.h>
#import <ORProgram/CPRunnable.h>
#import <objmp/LPSolverI.h>

int main (int argc, const char * argv[])
{
    id<ORModel> master = [ORFactory createModel];

    ORInt boardWidth = 110;
    ORInt shelfCount = 5;
    id<ORIntRange> shelves = RANGE(master,0,shelfCount - 1);
    id<ORIntArray> shelf   = [ORFactory intArray: master  array:@[@20, @45, @50, @55, @75]];
    id<ORIntArray> demand  = [ORFactory intArray: master array: @[@48, @35, @24, @10, @8]];
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
        id<ORFloatArray> cost = [ORFactory floatArray: slave range: shelves with: ^ORFloat(ORInt i) { return [linearSolver dual: c[i]];}];
        [slave add: [Sum(slave, i, shelves, [use[i] mul: @([shelf at: i])]) leq: @(boardWidth)]];
        [slave minimize: [@1  sub:Sum(slave, i, shelves, [use[i] mul: @([cost at: i])])]];
        id<ORRunnable> slaveRunnable = [ORFactory CPRunnable: slave];
        [slaveRunnable start];
        id<ORASolver> slaveSolver = [slaveRunnable solver];  // [ldm] fixed bug. Not slave -> slaveRunnable
        id<ORSolution> sol = [[slaveSolver solutionPool] best];
        if ([(id<ORObjectiveValueFloat>)[sol objectiveValue] value] < -0.00001)
           return [ORFactory column: linearSolver solution: sol array: use constraints: c];
         else return nil;
    }];
    [cg run];
    id<LPProgram> mlp = (id)[lp solver];
    [mlp enumerateColumnWith:^void(id<LPColumn> ck) {
       LPVariableI* theVar = [ck theVar];
       ORFloat theValue = [theVar floatValue];
       NSLog(@"var(%@): %f", theVar, theValue);
    }];
    return 0;
}

