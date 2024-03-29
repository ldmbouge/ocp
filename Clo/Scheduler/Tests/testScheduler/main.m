/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Pascal Van Hentenryck
 
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

int dura[2] = {5,10};

int mainOptional(int argc, const char * argv[])
{
   
   @autoreleasepool {
      
      id<ORModel> model = [ORFactory createModel];
      
      // data
      id<ORIntRange> Horizon = RANGE(model,0,100);
      id<ORIntRange> R = RANGE(model,0,1);
      
      
      id<ORIntArray> duration = [ORFactory intArray: model range: R with: ^ORInt(ORInt i) { return dura[i]; }];
      
      // variables
      
      id<ORTaskVarArray> t = [ORFactory taskVarArray: model range: R horizon: Horizon duration: duration];
      id<ORTaskVar> o = [ORFactory optionalTask: model horizon: Horizon duration: 10];
      
      // constraints and objective
      [model add: [o precedes: t[0]]];
      [model add: [t[0] precedes: t[1]]];
      
      // search
      id<CPProgram,CPScheduler> cp  = [ORFactory createCPProgram: model];
      NSLog(@"Task: %@",[cp description: t[0]]);
      NSLog(@"Task: %@",[cp description: t[1]]);
      NSLog(@"Optional Task: %@",[cp description: o]);
      [cp solve: ^{
         
//         [cp updateStart: t[0] with: 26];
         [cp updateEnd: t[1] with: 20];
//         [cp updateStart: o with: 30];
//         [cp labelPresent:o with:TRUE];
         NSLog(@"Task: %@",[cp description: t[0]]);
         NSLog(@"Task: %@",[cp description: t[1]]);
         NSLog(@"Optional Task: %@",[cp description: o]);
      }
       ];
//      id<ORSolutionPool> pool = [cp solutionPool];
//      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
//      id<ORSolution> optimum = [pool best];
//      printf("Makespan: %d \n",[optimum intValue: makespan.startLB]);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
   }
   return 0;
}

int mainTransition(int argc, const char * argv[])
{
   
   @autoreleasepool {
      
      id<ORModel> model = [ORFactory createModel];
      
      // data
      id<ORIntRange> Horizon = RANGE(model,0,100);
      id<ORIntRange> R = RANGE(model,0,1);
      
      
      id<ORIntArray> duration = [ORFactory intArray: model range: R with: ^ORInt(ORInt i) { return dura[i]; }];
      
      // variables
      
      id<ORTaskVarArray> task = [ORFactory taskVarArray: model range: R horizon: Horizon duration: duration];
      id<ORIntVar> cost = [ORFactory intVar: model domain: RANGE(model,0,10)];
      id<ORIntMatrix> transition = [ORFactory intMatrix: model range: R : R];
      for(ORInt i = R.low; i <= R.up; i++)
         for(ORInt j = R.low; j <= R.up; j++)
            [transition set: 0 at: i : j];
      [transition set: 3 at: 1 : 0];
      [transition set: 20 at: 0: 1];
      id<ORTaskDisjunctive> machine = [ORFactory disjunctiveConstraint: model transition: transition];
      
      // constraints and objective
      [machine add: task[0] type: 0];
      [machine add: task[1] type: 1];
      [model add: machine];
      
      id<ORIntVar> dur = [task[0] getDurationVar];
      [model add: [ORFactory sumTransitionTimes: machine leq:cost]];
      
      // search
      id<CPProgram,CPScheduler> cp  = [ORFactory createCPProgram: model];
      [cp solveAll: ^{
         NSLog(@"duration: %d..%d",[cp min: dur],[cp max: dur]);
         [cp sequence: machine.successors by: ^ORFloat(ORInt i) { return i;}];

         id<ORTaskVarArray> taskVar = machine.taskVars;
         id<ORTaskVarArray> transitionTaskVar = machine.transitionTaskVars;
         id<ORIntVarArray> transitionTimes = machine.transitionTimes;
         id<ORIntVarArray> successors = machine.successors;
//         NSLog(@"tasks[0] = %@",[cp description: task[0]]);
//         NSLog(@"tasks[1] = %@",[cp description: task[1]]);
         NSLog(@"tasks[1] = %@",[cp description: taskVar[1]]);
         NSLog(@"tasks[2] = %@",[cp description: taskVar[2]]);
         NSLog(@"successors = %d-%d",successors.low,successors.up);
          NSLog(@"successors[0] = %d",[cp intValue: successors[0]]);
         NSLog(@"successors[1] = %d",[cp intValue: successors[1]]);
         NSLog(@"successors[2] = %d",[cp intValue: successors[2]]);
         NSLog(@"transitionTime[1] = %d",[cp intValue: transitionTimes[1]]);
         NSLog(@"transitionTime[2] = %d",[cp intValue: transitionTimes[2]]);
         NSLog(@"transitiontasks[1] = %@",[cp description: transitionTaskVar[1]]);
         NSLog(@"transitiontasks[2] = %@",[cp description: transitionTaskVar[2]]);
         NSLog(@"cost = [%d,%d]",[cp min: cost],[cp max: cost]);
      }
       ];
      //      id<ORSolutionPool> pool = [cp solutionPool];
      //      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      //      id<ORSolution> optimum = [pool best];
      //      printf("Makespan: %d \n",[optimum intValue: makespan.startLB]);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
   }
   return 0;
}

int main(int argc, const char * argv[])
{
   return mainTransition(argc,argv);
}
