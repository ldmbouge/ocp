#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <ORScheduler/ORScheduler.h>


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
      id<ORIntRange> Tasks = RANGE(model,1,nbTasks);
      id<ORIntArray> duration = [ORFactory intArray: model range: Tasks with: ^ORInt(ORInt i) { return inputDuration[i-1]; } ];
      ORInt totalDuration = 0;
      for(ORInt i = 1; i <= nbTasks; i++)
         totalDuration += [duration at: i];
      id<ORIntRange> Horizon = RANGE(model,0,totalDuration);
      id<ORIntArray> demand = [ORFactory intArray: model range: Tasks with: ^ORInt(ORInt i) { return inputDemand[i-1]; } ];
      
      id<ORActivityArray> activities = [ORFactory activityArray: model range: Tasks with: ^id<ORActivity>(ORInt i) {
         return [ORFactory activity: model horizon: Horizon duration: inputDuration[i-1]];
      }];
      id<ORActivity> makespan = [ORFactory activity: model horizon: Horizon duration: 0];
      [model minimize: makespan.start];
      for(ORInt p = 0; p < nbPrecedences; p++) {
         ORInt b = precedence[p].before;
         ORInt a = precedence[p].after;
         [model add: [ORFactory precedence: activities[b] precedes: activities[a]]];
      }
      for(ORInt t = 1; t <= nbTasks; t++) {
         [model add: [ORFactory precedence: activities[t] precedes: makespan]];
      }
      id<ORIntVarArray> start = [ORFactory intVarArray: model range: Tasks with: ^id<ORIntVar>(ORInt k) {
         return activities[k].start;
      }];
      [model add: [ORFactory cumulative: activities usage: demand maxCapacity: capacity]];
      
      id<CPProgram> cp  = [ORFactory createCPProgram: model];
      [cp solve: ^{
         [cp labelArray: start];
         [cp label: makespan.start];
          printf("makespan = [%d,%d] \n",[cp min: makespan.start],[cp max: makespan.start]);
      }
      ];
      id<ORSolutionPool> pool = [cp solutionPool];
      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      id<ORSolution> optimum = [pool best];
      printf("Makespan: %d \n",[optimum intValue: makespan.start]);
      for(ORInt i = 1; i <= nbTasks; i++) {
         ORInt s = [optimum intValue: [start at: i]];
         printf("task %d = [%d,%d] \n",i,s,s + [duration at: i]);
      }

      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
//      struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
      [cp release];

      NSLog(@"%@",duration);
      NSLog(@"%@",demand);
   }
    return 0;
}

