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

void fillLocations(FILE* data,id<ORIntRange> Locations,id<ORIntArray> service,id<ORIntArray> startWindow,id<ORIntArray> endWindow)
{
   ORInt s,startw,endw;
   // skip the first line
   fscanf(data, "%d",&s);
   fscanf(data, "%d",&startw);
   fscanf(data, "%d",&endw);
   for(ORInt i = Locations.low; i <= Locations.up; i++) {
      fscanf(data, "%d",&s);
      fscanf(data, "%d",&startw);
      fscanf(data, "%d",&endw);
      [service set: s at: i];
      [startWindow set: startw at: i];
      [endWindow set: endw at: i];
   }
   // skip the first line
   fscanf(data, "%d",&s);
   fscanf(data, "%d",&startw);
   fscanf(data, "%d",&endw);
}

void fillCost(FILE* data,id<ORIntRange> Locations,id<ORIntMatrix> cost)
{
   ORInt tmp;
   for(ORInt j = 0; j < Locations.size + 2; j++)
      fscanf(data, "%d",&tmp);
   for(ORInt i = Locations.low; i <= Locations.up; i++) {
      fscanf(data, "%d",&tmp);
      for(ORInt j = Locations.low; j <= Locations.up; j++) {
         fscanf(data, "%d",&tmp);
         [cost set: tmp at: i : j ];
      }
      fscanf(data, "%d",&tmp);
   }
}

int main1(int argc, const char * argv[])
{

   @autoreleasepool {
      
      [ORStreamManager setRandomized];
      FILE* data = fopen("/Users/pvh/NICTA/project/objectivecp-dev/objectivecpdev/data/rbg048a.tw","r");
      ORInt nbLocations;
      
      fscanf(data, "%d",&nbLocations);
      printf("NbLocations: %d \n",nbLocations);
      nbLocations -=2;
      
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> Locations = RANGE(model,1,nbLocations);
      
      id<ORIntArray> service = [ORFactory intArray: model range: Locations value: 0];
      id<ORIntArray> startWindow = [ORFactory intArray: model range: Locations value: 0];
      id<ORIntArray> endWindow = [ORFactory intArray: model range: Locations value: 0];
      fillLocations(data,Locations,service,startWindow,endWindow);
  
      id<ORIntMatrix> cost = [ORFactory intMatrix:model range: Locations : Locations];
      fillCost(data,Locations,cost);
      
      // variables
      id<ORTaskVarArray> task = [ORFactory taskVarArray: model range: Locations with: ^id<ORTaskVar>(ORInt i) {
         return [ORFactory task: model horizon: RANGE(model,[startWindow at: i],[endWindow at: i] + [service at: i]) duration: [service at: i]];
      }];
      id<ORIntVar> obj = [ORFactory intVar: model domain: RANGE(model,0,120000)];

      // coonstraints
      id<ORTaskDisjunctive> robot = [ORFactory disjunctiveConstraint: model  transition: cost];
      for(ORInt i = Locations.low; i<= Locations.up; i++)
         [robot add: task[i] type: i];
      [model add: robot];
      [model add: [ORFactory sumTransitionTimes: robot leq: obj]];
      [model minimize: obj];
      

      id<CPProgram,CPScheduler> cp  = [ORFactory createCPProgram: model];
      id<ORIntVarArray> succ = robot.successors;
      id<ORTaskVarArray> ttask = robot.transitionTaskVars;
      
      id<ORUniformDistribution> d = [ORFactory uniformDistribution:model range:RANGE(model,0,99)];
      id<ORUniformDistribution> dc = [ORFactory uniformDistribution:model range:RANGE(model,0,1)];
      id<ORUniformDistribution> dp = [ORFactory uniformDistribution:model range: [succ range]];
      id<ORUniformDistribution> dl = [ORFactory uniformDistribution:model range: RANGE(model,5,25)];
      
      ORInt pr = 100 - 2500/nbLocations;
      // search
      [cp solve: ^{
         [cp try: ^() {
             [cp sequence: robot.successors by: ^ORFloat(ORInt i) { return [cp lst: ttask[i]]; } then: ^ORFloat(ORInt i) { return [cp est: ttask[i]];}];
             [cp label: obj];
          }
            then: ^() {
               [cp limitTime: 300000 in: ^{
                  [cp repeat: ^{
                     [cp limitFailures: 500 in: ^{
                        //                  [cp sequence: robot.successors by: ^ORFloat(ORInt i) { return [cp domsize: succ[i]]; } then: ^ORFloat(ORInt i) { return [cp ect: ttask[i]];}];
                        [cp sequence: robot.successors by: ^ORFloat(ORInt i) { return [cp lst: ttask[i]]; } then: ^ORFloat(ORInt i) { return [cp est: ttask[i]];}];
                        [cp label: obj];
                        printf("\n");
                        NSLog(@"obj = %d",[cp min: obj]);
                     }];
                  }
                    onRepeat: ^{
                       id<ORSolution,CPSchedulerSolution> s = [[cp solutionPool] best];
                       ORInt ch = [dc next];
                       if (ch == 0) {
                          for(ORInt i = succ.low; i <= succ.up; i++)
                             if ([d next] <= pr)
                                [cp label: succ[i] with: [s intValue: succ[i]]];
                          printf("R");
                       }
                       else {
                          ORInt st = [dp next];
                          ORInt en = st + [dl next];
                          ORInt i = 0;
                          ORInt curr = 0;
                          while (curr <= succ.up) {
                             if ((i < st || i >= en)) {
                                //   if ([d next] <= pr)
                                [cp label: succ[curr] with: [s intValue: succ[curr]]];
                             }
                             i++;
                             curr = [s intValue: succ[curr]];
                          }
                          printf("S");
                       }
                    }];
               }];
            }];
      }];
   }
   return 0;
}

int main2(int argc, const char * argv[])
{
   
   @autoreleasepool {
      
      [ORStreamManager setRandomized];
      FILE* data = fopen("/Users/pvh/NICTA/project/objectivecp-dev/objectivecpdev/data/rbg048a.tw","r");
      ORInt nbLocations;
      
      fscanf(data, "%d",&nbLocations);
      printf("NbLocations: %d \n",nbLocations);
      nbLocations -=2;
      
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> Locations = RANGE(model,1,nbLocations);
      
      id<ORIntArray> service = [ORFactory intArray: model range: Locations value: 0];
      id<ORIntArray> startWindow = [ORFactory intArray: model range: Locations value: 0];
      id<ORIntArray> endWindow = [ORFactory intArray: model range: Locations value: 0];
      fillLocations(data,Locations,service,startWindow,endWindow);
      
      id<ORIntMatrix> cost = [ORFactory intMatrix:model range: Locations : Locations];
      fillCost(data,Locations,cost);
      
      // variables
      id<ORTaskVarArray> task = [ORFactory taskVarArray: model range: Locations with: ^id<ORTaskVar>(ORInt i) {
         return [ORFactory task: model horizon: RANGE(model,[startWindow at: i],[endWindow at: i] + [service at: i]) duration: [service at: i]];
      }];
      id<ORIntVar> obj = [ORFactory intVar: model domain: RANGE(model,0,120000)];
      
      // coonstraints
      id<ORTaskDisjunctive> robot = [ORFactory disjunctiveConstraint: model  transition: cost];
      for(ORInt i = Locations.low; i<= Locations.up; i++)
         [robot add: task[i] type: i];
      [model add: robot];
      [model add: [ORFactory sumTransitionTimes: robot leq: obj]];
      [model minimize: obj];
      
      
      id<CPProgram,CPScheduler> cp  = [ORFactory createCPProgram: model];
      id<ORIntVarArray> succ = robot.successors;
      id<ORTaskVarArray> ttask = robot.transitionTaskVars;
      id<ORIntMatrix> ecost = robot.extendedTransitionMatrix;
      
      id<ORUniformDistribution> d = [ORFactory uniformDistribution:model range:RANGE(model,0,99)];
      id<ORUniformDistribution> dc = [ORFactory uniformDistribution:model range:RANGE(model,0,1)];
      id<ORUniformDistribution> dp = [ORFactory uniformDistribution:model range: [succ range]];
      id<ORUniformDistribution> dl = [ORFactory uniformDistribution:model range: RANGE(model,5,25)];
      
      ORInt pr = 100 - 2500/nbLocations;
      // search
      [cp solve: ^{
         [cp try: ^() {
            [cp sequence: robot.successors by: ^ORFloat(ORInt i) { return [cp lst: ttask[i]]; } then: ^ORFloat(ORInt i) { return [cp est: ttask[i]];}];
            [cp label: obj];
            NSLog(@" first success");
         }
            then: ^() {
               NSLog(@" then");
               [cp limitTime: 300000 in: ^{
                  [cp repeat: ^{
                     [cp limitFailures: 500 in: ^{
                        ORInt low = succ.low;
                        ORInt size = succ.range.size - 1;
                        __block ORInt k = low;
                        for(ORInt j = 1; j <= size; j++) {
                           [cp label: succ[k] by:  ^ORFloat(ORInt i) { return [cp est: ttask[i]] + [ecost at: k : i]; }
                                then:  ^ORFloat(ORInt i) { return [cp lst: task[i]];}
                            ];
                           k = [cp intValue: succ[k]];
                        }
                        [cp label: obj];
                        printf("\n");
                        NSLog(@"obj = %d",[cp min: obj]);
                     }];
                  }
                    onRepeat: ^{
                       id<ORSolution,CPSchedulerSolution> s = [[cp solutionPool] best];
                       ORInt ch = [dc next];
                       if (ch == 0) {
                          for(ORInt i = succ.low; i <= succ.up; i++)
                             if ([d next] <= pr)
                                [cp label: succ[i] with: [s intValue: succ[i]]];
                          printf("R");
                       }
                       else {
                          ORInt st = [dp next];
                          ORInt en = st + [dl next];
                          ORInt i = 0;
                          ORInt curr = 0;
                          while (curr <= succ.up) {
                             if ((i < st || i >= en))
                                [cp label: succ[curr] with: [s intValue: succ[curr]]];
                             i++;
                             curr = [s intValue: succ[curr]];
                          }
                          printf("S");
                       }
                    }];
               }];
            }];
      }];
   }
   return 0;
}

int main(int argc, const char * argv[])
{
   return main2(argc,argv);
}
