/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORScheduler.h>
#import <ORSchedulingProgram/ORSchedulingProgram.h>

//Makespan: 66
//2014-06-29 15:00:29.197 shiploading[6044:303] Solver status: Solver: 173 vars
//78 constraints
//605 choices
//599 fail
//7220 propagations

ORInt capacity = 8;
ORInt nbTasks = 34;

int inputDuration[34] = {3, 4, 4, 6, 5, 2, 3, 4, 3, 2, 3, 2, 1, 5, 2, 3, 2, 2, 1, 1, 1, 2, 4, 5, 2, 1, 1, 2, 1, 3, 2, 1, 2, 2};
int inputDemand[34] = {4, 4, 3, 4, 5, 5, 4, 3, 4, 8, 4, 5, 4, 3, 3, 3, 6, 7, 4, 4, 4, 4, 7, 8, 8, 3, 3, 6, 8, 3, 3, 3, 3, 3};

typedef struct Precedence {
   ORInt before;
   ORInt after;
} ORPrecedence;

ORInt nbPrecedences = 42;

ORPrecedence precedence[42] = {
   (ORPrecedence){1, 2}, (ORPrecedence){1, 4}, (ORPrecedence){2, 3}, (ORPrecedence){3, 5}, (ORPrecedence){3, 7}, (ORPrecedence){4, 5}, (ORPrecedence){5, 6},
   (ORPrecedence){6, 8}, (ORPrecedence){7, 8}, (ORPrecedence){8, 9}, (ORPrecedence){9, 10}, (ORPrecedence){9, 14}, (ORPrecedence){10, 11}, (ORPrecedence){10, 12},
   (ORPrecedence){11, 13}, (ORPrecedence){12, 13},  (ORPrecedence){13, 15}, (ORPrecedence){13, 16}, (ORPrecedence){14, 15}, (ORPrecedence){15, 18},
   (ORPrecedence){16, 17}, (ORPrecedence){17, 18}, (ORPrecedence){18, 19}, (ORPrecedence){18, 20}, (ORPrecedence){18, 21}, (ORPrecedence){19, 23},
   (ORPrecedence){20, 23}, (ORPrecedence){21, 22}, (ORPrecedence){22, 23}, (ORPrecedence){23, 24}, (ORPrecedence){24, 25}, (ORPrecedence){25, 26},
   (ORPrecedence){25, 30}, (ORPrecedence){25, 31}, (ORPrecedence){25, 32}, (ORPrecedence){26, 27}, (ORPrecedence){27, 28}, (ORPrecedence){28, 29},
   (ORPrecedence){30, 28}, (ORPrecedence){31, 28}, (ORPrecedence){32, 33}, (ORPrecedence){33, 34}
};


int main(int argc, const char * argv[])
{

   @autoreleasepool {
      
      id<ORModel> model = [ORFactory createModel];
      
      // data
      id<ORIntRange> Tasks = RANGE(model,1,nbTasks);
      id<ORIntArray> duration = [ORFactory intArray: model range: Tasks with: ^ORInt(ORInt i) { return inputDuration[i-1]; } ];
      id<ORIntArray> demand = [ORFactory intArray: model range: Tasks with: ^ORInt(ORInt i) { return inputDemand[i-1]; } ];
      ORInt totalDuration = 0;
      for(ORInt i = Tasks.low; i < Tasks.up; i++)
         totalDuration += [duration at: i];
       id<ORIntRange> Horizon = RANGE(model,0,totalDuration);
      
      // variables
      id<ORTaskVarArray> activities = [ORFactory taskVarArray: model range: Tasks horizon: Horizon duration: duration];
      id<ORIntVar> makespan = [ORFactory intVar: model domain: Horizon];
      id<ORIntVar> capa = [ORFactory intVar: model bounds: RANGE(model,capacity,capacity)];
      id<ORIntVarArray> usage = [ORFactory intVarArray: model range: Tasks with: ^id<ORIntVar>(ORInt i) {
         return [ORFactory intVar: model bounds: RANGE(model,[demand at: i],[demand at: i])];
      }];
      // constraints and objective
      [model minimize: makespan];
      
      for(ORInt p = 0; p < nbPrecedences; p++)
         [model add: [activities[precedence[p].before] precedes: activities[precedence[p].after]]];
      for(ORInt t = 1; t <= nbTasks; t++)
         [model add: [activities[t] isFinishedBy: makespan]];
      [model add: [ORFactory cumulative: activities with: usage and: capa]];
      
      // search
      id<CPProgram,CPScheduler> cp  = (id)[ORFactory createCPProgram: model];
      [cp solve: ^{
         [cp setTimes: activities];
         [cp label: makespan];
         printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
      }
      ];
      id<ORSolutionPool> pool = [cp solutionPool];
      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      id<ORSolution,CPSchedulerSolution> optimum = (id)[pool best];
      printf("Makespan: %d \n",[optimum intValue: makespan]);
      for(ORInt i = 1; i <= nbTasks; i++) {
         ORInt s = [optimum est: activities[i]];
         printf("task %d = [%d,%d] \n",i,s,s + [duration at: i]);
      }
      printf("Makespan: %d \n",[optimum intValue: makespan]);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
//      struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
   }
    return 0;
}

