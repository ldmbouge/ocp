/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORScheduler.h>
#import <ORSchedulingProgram/ORSchedulingProgram.h>

@interface ORSchedulingProgramTests : XCTestCase

@end

@implementation ORSchedulingProgramTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCumulative
{
    // Instance specification (SCC 1)
//    const ORInt m = 6;  // Number of resources
//    const ORInt rcap[m] = {23, 11, 22, 11, 11, 34}; // Resource capacities
//    const ORInt rNbTask[m] = {2, 2, 18, 2, 6, 22};
//    const ORInt rtask[52] = {18,15, 17,16, 10,3,22,20,16,4,11,17,12,19,1,6,14,13,5,7,2,9, 7,3, 13,1,11,20,12,6, 11,17,19,6,14,4,12,7,9,20,18,3,16,1,10,21,22,15,8,13,5,2};
//    const ORInt n = 22; // Number of tasks
//    const ORInt max_ru[n] = {11, 11, 11, 11, 22, 11, 11, 22, 22, 22, 11, 11, 11, 22, 23, 11, 11, 23, 11, 11, 34, 22};
//    const ORInt area[n] = {110, 755, 730, 459, 178, 176, 730, 477, 215, 159, 730, 200, 108, 316, 683, 202, 154, 683, 459, 144, 811, 569};
//    const ORInt lct[n] = {517, 527, 526, 535, 557, 523, 526, 572, 563, 544, 528, 513, 526, 537, 582, 556, 560, 583, 536, 530, 580, 561};
//    const ORInt tt[n] = {83, 73, 74, 65, 43, 77, 74, 28, 37, 56, 72, 87, 74, 63, 18, 44, 40, 17, 64, 70, 20, 39};
//    const ORInt tt2r[m*n] = {
//        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  1, -1, -1,  0, -1, -1, -1, -1,
//        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  4,  0, -1, -1, -1, -1, -1,
//        61, 51, 52, 43, 21, 55, 52, -1, 15, 34, 50, 65, 52, 41, -1, 22, 18, -1, 42, 48, -1, 17,
//        -1, -1,  2, -1, -1, -1,  2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
//        13, -1, -1, -1, -1,  7, -1, -1, -1, -1,  2, 17,  4, -1, -1, -1, -1, -1, -1,  0, -1, -1,
//        71, 61, 62, 53, 31, 65, 62, 16, 25, 44, 60, 75, 62, 51,  6, 32, 28,  5, 52, 58,  8, 27
//    };
//    const ORInt horizon = 600;
//    const ORInt optimal = 9048;

    // Instance specification (SCC 3)
    const ORInt m = 5;  // Number of resources
    const ORInt rcap[m] = {10, 34, 22, 11, 22}; // Resource capacities
    const ORInt rNbTask[m] = {3, 17, 11, 5, 5};
    const ORInt rtask[52] = {4,2,5, 5,7,11,2,9,17,10,13,12,16,3,15,8,14,4,6,1, 10,1,17,4,5,3,16,11,7,6,2, 2,1,17,4,5, 15,9,12,13,8};
    const ORInt n = 17; // Number of tasks
    const ORInt max_ru[n] = {11, 10, 6, 10, 10, 22, 22, 22, 22, 22, 22, 22, 22, 34, 22, 22, 11};
    const ORInt area[n] = {772, 771, 6, 772, 772, 627, 544, 621, 621, 544, 627, 477, 621, 696, 296, 631, 771};
    const ORInt lct[n] = {552, 544, 551, 544, 544, 552, 555, 575, 568, 559, 550, 569, 571, 578, 569, 556, 550};
    const ORInt tt[n] = {48,  56,  49,  56,  56,  48,  45,  25,  32,  41,  50,  31,  29,  22,  31,  44,  50};
    const ORInt tt2r[m*n] = {
        -1,   0,  -1,   0,   0,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,
        36,  44,  37,  44,  44,  36,  33,  13,  20,  29,  38,  19,  17,  10,  19,  32,  38,
        12,  20,  13,  20,  20,  12,   9,  -1,  -1,   5,  14,  -1,  -1,  -1,  -1,   8,  14,
         0,   8,  -1,   8,   8,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,  -1,   2,
        -1,  -1,  -1,  -1,  -1,  -1,  -1,   2,   9,  -1,  -1,   8,   6,  -1,   8,  -1,  -1
    };
    const ORInt horizon = 600;
    const ORInt optimal = 10169;

    
    // Solve problem
    ORInt optVal = [self solveInterrelatedResourceModel:m rcap:rcap rNbTask:rNbTask rtask:rtask n:n maxRu:max_ru area:area lct:lct tt:tt tt2r:tt2r horizon:horizon];

    XCTAssertEqual(optimal, optVal, @"Part 1 failed");
}

- (ORInt)solveInterrelatedResourceModel:(const ORInt)m rcap:(const ORInt *)rcap rNbTask:(const ORInt *)rNbTask rtask:(const ORInt *)rtask n:(const ORInt)n maxRu:(const ORInt *)max_ru area:(const ORInt *)area lct:(const ORInt *)lct tt:(const ORInt *)tt tt2r:(const ORInt *)tt2r horizon:(const ORInt)horizon
{
    ORInt optVal = -10;
    BOOL hasSubTasks0[n];
    BOOL * hasSubTasks = hasSubTasks0;
    ORInt c = 0;
    for (ORInt k = 0; k < n; k++)
        hasSubTasks[k] = FALSE;
    for (ORInt r = 0; r < m; r++) {
        for (ORInt k = 0; k < rNbTask[r]; k++, c++)
            hasSubTasks[rtask[c] - 1] = TRUE;
    }

    @autoreleasepool {
        id<ORModel> model = [ORFactory createModel];
        id<ORIntRange> TaskR = RANGE(model, 0, n - 1);
        id<ORIntRange> CumuR = RANGE(model, 0, m - 1);
        
        // Creating the master tasks
        id<ORTaskVarArray> taskVars = [ORFactory taskVarArray:model range:TaskR with:^id<ORTaskVar>(ORInt k) {
            const id<ORIntRange> HorR = RANGE(model, 0, lct[k]);
            const id<ORIntRange> DurR   = RANGE(model, 0, min(area[k], lct[k]));
            return [ORFactory task:model horizon:HorR durationRange:DurR];
        }];
        
        // Crerating the resource usage variables for each task
        id<ORIntVarArray> ruVars = [ORFactory intVarArray:model range:TaskR with:^id<ORIntVar>(ORInt k) {
            return [ORFactory intVar:model bounds:RANGE(model, 1, max_ru[k])];
        }];
        
        // Creating the area variables for each task
        id<ORIntVarArray> areaVars = [ORFactory intVarArray:model range:TaskR with:^id<ORIntVar>(ORInt k) {
            return [ORFactory intVar:model bounds:RANGE(model, 0, area[k])];
        }];
        
        // Creating the cumulative area variables for each task
        id<ORIntVarArray> areaCumuVars = [ORFactory intVarArray:model range:TaskR with:^id<ORIntVar>(ORInt k) {
            return [ORFactory intVar:model bounds:RANGE(model, 0, area[k] + max_ru[k] - 1)];
        }];
        
        // Creating the objective variable
        ORInt objUB = 0;
        for (ORInt k = TaskR.low; k <= TaskR.up; k++)
            objUB += area[k];
        id<ORIntVar> objVar = [ORFactory intVar:model bounds:RANGE(model, 0, objUB)];
        
        // Adding constraints regarding the area and resource usage variables
        for (ORInt k = TaskR.low; k <= TaskR.up; k++) {
            // Resource usage and cumulative area constraint
            [model add:[ORFactory mult:model var:ruVars[k] by:[taskVars[k] getDurationVar] equal:areaCumuVars[k]]];
            // Constraining all variables together
            id<ORIntVar> constant = [ORFactory intVar:model value:area[k]];
            [model add:[ORFactory min:model var:constant land:areaCumuVars[k] equal:areaVars[k]]];
            id<ORIntVarArray> aux = [ORFactory intVarArray:model range:RANGE(model, 1, 3) with:^id<ORIntVar>(ORInt i) {
                if (i == 1)
                    return areaCumuVars[k];
                if (i == 2)
                    return [ORFactory intVar:model var:areaVars[k] scale:-1];
                return [ORFactory intVar:model var:ruVars[k] scale:-1];
            }];
            [model add:[ORFactory sum:model array:aux leqi:-1]];
        }
        
        // Adding resource constraints
        ORInt offset = 0;
        for (ORInt r = CumuR.low; r <= CumuR.up; r++) {
            id<ORIntVar> constant = [ORFactory intVar:model value:rcap[r]];
            id<ORTaskCumulative> cumu = [ORFactory cumulativeConstraint:constant];
            // Adding tasks to the cumulative constraint
            for (ORInt kk = 0; kk < rNbTask[r]; kk++) {
                const ORInt k = rtask[kk + offset] - 1;
                const ORInt i = r * n + k;
                // Creating a sub-task
                assert(0 <= tt2r[i]);
                id<ORIntRange> horSub = RANGE(model, tt2r[i], lct[k] + tt2r[i]);
                id<ORTaskVar> sub = [ORFactory task:model horizon:horSub durationRange:[taskVars[k] duration]];
                // Adding the sub-task to the resource
//                [cumu add:sub with:ruVars[k]];
                [cumu add:sub with:ruVars[k] and:areaCumuVars[k]];
                // Adding constraints tying master and sub task together
                [model add:[ORFactory equal:model var:[sub getDurationVar] to:[taskVars[k] getDurationVar] plus:0      ]];
                [model add:[ORFactory equal:model var:[sub getStartVar   ] to:[taskVars[k] getStartVar   ] plus:tt2r[i]]];
            }
            [model add:cumu];
            offset += rNbTask[r];
        }
        
        // Adding constraints regarding the objective
        id<ORIntVarArray> objArr = [ORFactory intVarArray:model range:RANGE(model, TaskR.low, TaskR.up + 1) with:^id<ORIntVar>(ORInt k) {
            if (k > TaskR.up)
                return [ORFactory intVar:model var:objVar scale:-1];
            return areaVars[k];
        }];
        [model add:[ORFactory sum:model array:objArr eqi:0]];
        [model maximizeVar:objVar];
        
        id<CPProgram,CPScheduler> cp = (id<CPProgram,CPScheduler>)[ORFactory createCPProgram:model];
        
        [cp solve:^() {
            // Labeling the tasks that do not require any resource
            for (ORInt k = TaskR.low; k <= TaskR.up; k++) {
                if (!hasSubTasks[k]) {
                    [cp label:areaVars[k] with:[cp max:areaVars[k]]];
                    [cp label:ruVars[k] with:[cp max:ruVars[k]]];
                    [cp labelStart:taskVars[k] with:[cp est:taskVars[k]]];
                }
            }
            // Labeling the tasks requiring a resource
            for (ORInt k = TaskR.low; k <= TaskR.up; k++) {
                printf("Label task %d\n", k);
                while (![cp bound:areaVars[k]]) {
                    const ORInt constant = [cp max:areaVars[k]];
                    [cp try:^(){ [cp label:areaVars[k] with:constant]; }
                        alt:^(){ [cp diff :areaVars[k] with:constant]; }];
                }
                while (![cp bound:ruVars[k]]) {
                    const ORInt constant = [cp max:ruVars[k]];
                    [cp try:^(){ [cp label:ruVars[k] with:constant]; }
                        alt:^(){ [cp diff :ruVars[k] with:constant]; }];
                }
                [cp labelActivity:taskVars[k]];
            }
            // Everything should be bounded
            assert(^ORBool() {
                for (ORInt k = TaskR.low; k <= TaskR.up; k++) {
                    if (![cp bound:areaVars[k]] || ![cp bound:areaCumuVars[k]] || ![cp bound:ruVars[k]] || ![cp boundActivity:taskVars[k]])
                        return FALSE;
                }
                if (![cp bound:objVar])
                    return FALSE;
                return TRUE;
            }());
            printf("Found a solution!\n");
        }];
        id<ORSolutionPool> pool = [cp solutionPool];
        id<ORSolution,CPSchedulerSolution> best = (id)[pool best];
        optVal = [best intValue:objVar];
    }
    return optVal;
}

@end
