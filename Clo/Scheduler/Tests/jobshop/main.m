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

//121 constraints
//235670 choices
//227271 fail
//30545589 propagations

//121 constraints
//548898 choices
//541827 fail
//21315756 propagations

ORInt size6 = 6;
ORInt iresource6[6][6] = {
   { 3, 1, 2, 4, 6, 5},
   { 2, 3, 5, 6, 1, 4},
   { 3, 4, 6, 1, 2, 5},
   { 2, 1, 3, 4, 5, 6},
   { 3, 2, 5, 6, 1, 4},
   { 2, 4, 6, 1, 5, 3}
};
ORInt iduration6[6][6] = {
   {  1,  3,  6,  7,  3,  6},
   {  8,  5, 10, 10, 10,  4},
   {  5,  4,  8,  9,  1,  7},
   {  5,  5,  5,  3,  8,  9},
   {  9,  3,  5,  4,  3,  1},
   {  3,  3,  9, 10,  4,  2}
};

ORInt size10 = 10;

ORInt iresource10[10][10] = {
   { 1,  2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10},
   { 1,  3 , 5 , 10 , 4 , 2 , 7 , 6 , 8 , 9},
   { 2,  1 , 4 , 3 , 9 , 6 , 8 , 7 , 10 , 5},
   { 2,  3 , 1 , 5 , 7 , 9 , 8 , 4 , 10 , 6},
   { 3,  1,  2 , 6 , 4 , 5 , 9 , 8 , 10 , 7},
   { 3,  2 , 6 , 4 , 9 , 10 , 1 , 7 , 5 , 8},
   { 2,  1 , 4 , 3 , 7 , 6 , 10 , 9 , 8 , 5},
   { 3,  1 , 2 , 6 , 5 , 7 , 9 , 10 , 8 , 4},
   { 1,  2 , 4 , 6 , 3 , 10 , 7 , 8 , 5 , 9},
   { 2,  1 , 3 , 7 , 9 , 10 , 6 , 4 , 5 , 8}
};
ORInt iduration10[10][10] = {
   {  29,  78 ,  9 , 36 , 49 , 11 , 62 , 56 , 44 , 21},
   {  43,  90 , 75 , 11 , 69 , 28 , 46 , 46 , 72 , 30},
   {  91,  85 , 39 , 74 , 90 , 10 , 12 , 89 , 45 , 33},
   {  81,  95 , 71 , 99 ,  9 , 52 , 85 , 98 , 22 , 43},
   {  14,   6 , 22 , 61 , 26 , 69 , 21 , 49 , 72 , 53},
   {  84,   2 , 52 , 95 , 48 , 72 , 47 , 65 ,  6 , 25},
   {  46,  37 , 61 , 13 , 32 , 21 , 32 , 89 , 30 , 55},
   {  31,  86 , 46 , 74 , 32 , 88 , 19 , 48 , 36 , 79},
   {  76,  69 , 76 , 51 , 85 , 11 , 40 , 89 , 26 , 74},
   {  85,  13 , 61 ,  7 , 64 , 76 , 47 , 52 , 90 , 45}
};

//ORInt iresource10[10][10] = {
//   {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
//   {0, 3, 4, 2, 1, 5, 8, 6, 7, 9},
//   {0, 3, 1, 2, 5, 4, 6, 7, 9, 8},
//   {0, 1, 4, 3, 6, 5, 2, 9, 7, 8},
//   {1, 0, 5, 3, 4, 7, 2, 8, 9, 6},
//   {0, 6, 2, 3, 1, 8, 4, 9, 7, 5},
//   {2, 3, 0, 1, 4, 7, 5, 6, 8, 9},
//   {2, 0, 3, 4, 1, 5, 9, 6, 7, 8},
//   {2, 1, 4, 0, 7, 5, 3, 9, 6, 8},
//   {2, 0, 8, 3, 6, 1, 4, 7, 9, 5}
//};
//ORInt iduration10[10][10] = {
//   {72, 64, 55, 31, 53, 95, 11, 52, 6, 84},
//   {61, 27, 88, 78, 49, 83, 91, 74, 29, 87},
//   {86, 32, 35, 37, 18, 48, 91, 52, 60, 30},
//   {8, 82, 27, 99, 74, 9, 33, 20, 59, 98},
//   {50, 94, 43, 62, 55, 48, 5, 36, 47, 36},
//   {53, 30, 7, 12, 68, 87, 28, 70, 45, 7},
//   {29, 96, 99, 14, 34, 14, 7, 76, 57, 76},
//   {90, 19, 87, 51, 84, 45, 84, 58, 81, 96},
//   {97, 99, 93, 38, 13, 96, 40, 64, 32, 45},
//   {44, 60, 29, 5, 74, 85, 34, 95, 51, 47}
//};


//ORInt iresource10[10][10] = {
//   {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
//   {0, 3, 4, 8, 9, 6, 7, 5, 2, 1},
//   {0, 7, 3, 2, 6, 4, 1, 5, 8, 9},
//   {0, 1, 3, 8, 5, 2, 4, 7, 6, 9},
//   {0, 6, 1, 3, 5, 2, 9, 7, 8, 4},
//   {4, 0, 6, 8, 2, 3, 9, 7, 5, 1},
//   {4, 3, 0, 9, 2, 1, 8, 7, 6, 5},
//   {4, 6, 9, 3, 8, 2, 7, 5, 0, 1},
//   {2, 6, 8, 7, 4, 9, 3, 1, 5, 0},
//   {2, 9, 5, 8, 6, 3, 7, 4, 1, 0}
//};
//
//ORInt iduration10[10][10] = {
//   { 72, 54, 33, 86, 75, 16, 96, 7, 99, 76},
//   { 16, 88, 48, 52, 60, 29, 18, 89, 80, 76},
//   { 47, 11, 14, 56, 16, 83, 10, 61, 24, 58},
//   { 49, 31, 17, 50, 63, 35, 65, 23, 50, 29},
//   { 55, 6, 28, 96, 86, 99, 14, 70, 64, 24},
//   { 46, 23, 70, 19, 54, 22, 85, 87, 79, 93},
//   { 76, 60, 76, 98, 76, 50, 86, 14, 27, 57},
//   { 93, 27, 57, 87, 86, 54, 24, 49, 20, 47},
//   { 28, 11, 78, 85, 63, 81, 10, 9, 46, 32},
//   { 22, 76, 89, 13, 88, 10, 75, 98, 78, 17}
//};


int mainBasicLNS(int argc, const char * argv[])
{
   @autoreleasepool {
      
      [ORStreamManager setRandomized];
      id<ORModel> model = [ORFactory createModel];

      // data
      ORLong timeStart = [ORRuntimeMonitor cputime];
      ORInt size = size10;
      id<ORIntRange> Size = RANGE(model,1,size);
      id<ORIntMatrix> duration = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iduration10[i-1][j-1]; } ];
      id<ORIntMatrix> resource = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iresource10[i-1][j-1]; } ];
   
      ORInt totalDuration = 0;
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            totalDuration += [duration at: i : j];
      id<ORIntRange> Horizon = RANGE(model,0,totalDuration);
      
      // variables
      
      id<ORTaskVarMatrix> task = [ORFactory taskVarMatrix: model range: Size : Size horizon: Horizon duration: duration];
      id<ORIntVar> makespan = [ORFactory intVar: model domain: RANGE(model,1,10000)];
      id<ORTaskDisjunctiveArray> disjunctive = [ORFactory disjunctiveArray: model range: Size];
      
      // model
      
      [model minimize: makespan];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j < Size.up; j++)
            [model add: [[task at: i : j] precedes: [ task at: i : j+1]]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         [model add: [[task at: i : Size.up] isFinishedBy: makespan]];

      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            [disjunctive[[resource at: i : j]] add: [ task at: i : j]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
          [model add: disjunctive[i]];

      // search
      id<CPProgram,CPScheduler> cp  = [ORFactory createCPProgram: model];
      /*
      [cp solve: ^{
         [cp forall: Size orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]]; } do: ^(ORInt i) {
            id<ORTaskVarArray> t = disjunctive[i].taskVars;
            [cp sequence: disjunctive[i].successors by: ^ORFloat(ORInt i) { return [cp est: t[i]]; } then: ^ORFloat(ORInt i) { return [cp ect: t[i]];}];
         }];
         [cp label: makespan];
         printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
      }];
       */
      [cp solve: ^{
         id<ORUniformDistribution> d = [ORFactory uniformDistribution:model range:RANGE(model,1,100)];
         [cp limitTime: 10000 in: ^{
            [cp repeat: ^{
               [cp limitFailures: 1000 in: ^{
                  [cp forall: Size orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]]; } do: ^(ORInt i) {
                     id<ORTaskVarArray> t = disjunctive[i].taskVars;
                     [cp sequence: disjunctive[i].successors by: ^ORFloat(ORInt i) { return [cp est: t[i]]; } then: ^ORFloat(ORInt i) { return [cp ect: t[i]];}];
                  }];
                  [cp label: makespan];
                  printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
                  ORLong timeEnd = [ORRuntimeMonitor cputime];
                  NSLog(@"Time: %lld:",timeEnd - timeStart);
               }];
            } onRepeat: ^{
               id<ORSolution> s = [[cp solutionPool] best];
               for(ORInt k = 1; k <= size; k++) {
                  id<ORIntVarArray> succ = disjunctive[k].successors;
                  id<ORTaskVarArray> t = disjunctive[k].taskVars;
                  for(ORInt j = succ.range.low+1; j <= succ.range.up; j++) {
                     if ([s intValue: succ[j]] != size + 1) {
                        ORInt next = [s intValue: succ[j]];
                        ORInt ect = [t[j] ect: s];
                        ORInt est = [t[next] est: s];
                        if (ect != est) { // this precedence constraint is not tight
                           if ([d next] <= 50)
                              [cp label: succ[j] with: next];
                        }
                     }
                  }
               //           NSLog(@"Restart");
               }
            }];
         }];
      }];

      ORLong timeEnd = [ORRuntimeMonitor cputime];
      NSLog(@"Time: %lld:",timeEnd - timeStart);
      id<ORSolutionPool> pool = [cp solutionPool];
//      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      id<ORSolution> optimum = [pool best];
      printf("Makespan: %d \n",[optimum intValue: makespan]);
      NSLog(@"Solver status: %@\n",cp);
      [cp release];
      NSLog(@"Quitting");
      //      struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);

   }
   return 0;
}

int mainSubpathLNS(int argc, const char * argv[])
{
   @autoreleasepool {
      
      [ORStreamManager setRandomized];
      id<ORModel> model = [ORFactory createModel];
      
      // data
      ORLong timeStart = [ORRuntimeMonitor cputime];
      ORInt size = size10;
      id<ORIntRange> Size = RANGE(model,1,size);
      id<ORIntMatrix> duration = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iduration10[i-1][j-1]; } ];
      id<ORIntMatrix> resource = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iresource10[i-1][j-1]; } ];
      
      ORInt totalDuration = 0;
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            totalDuration += [duration at: i : j];
      id<ORIntRange> Horizon = RANGE(model,0,totalDuration);
      
      // variables
      
      id<ORTaskVarMatrix> task = [ORFactory taskVarMatrix: model range: Size : Size horizon: Horizon duration: duration];
      id<ORIntVar> makespan = [ORFactory intVar: model domain: RANGE(model,1,10000)];
      id<ORTaskDisjunctiveArray> disjunctive = [ORFactory disjunctiveArray: model range: Size];
      
      // model
      
      [model minimize: makespan];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j < Size.up; j++)
            [model add: [[task at: i : j] precedes: [ task at: i : j+1]]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         [model add: [[task at: i : Size.up] isFinishedBy: makespan]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            [disjunctive[[resource at: i : j]] add: [ task at: i : j]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         [model add: disjunctive[i]];
      
      // search
      id<CPProgram,CPScheduler> cp  = [ORFactory createCPProgram: model];
      /*
       [cp solve: ^{
       [cp forall: Size orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]]; } do: ^(ORInt i) {
       id<ORTaskVarArray> t = disjunctive[i].taskVars;
       [cp sequence: disjunctive[i].successors by: ^ORFloat(ORInt i) { return [cp est: t[i]]; } then: ^ORFloat(ORInt i) { return [cp ect: t[i]];}];
       }];
       [cp label: makespan];
       printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
       }];
       */
      [cp solve: ^{
         id<ORUniformDistribution> pD = [ORFactory uniformDistribution:model range:RANGE(model,1,100)];
         id<ORUniformDistribution> sM = [ORFactory uniformDistribution:model range:RANGE(model,1,10)];
         id<ORUniformDistribution> sD = [ORFactory uniformDistribution:model range:RANGE(model,0,10)];
         id<ORUniformDistribution> lD = [ORFactory uniformDistribution:model range:RANGE(model,4,10)];
         [cp limitTime: 20000 in: ^{
            [cp repeat: ^{
               [cp limitFailures: 500 in: ^{
                  [cp forall: Size orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]]; } do: ^(ORInt i) {
                     id<ORTaskVarArray> t = disjunctive[i].taskVars;
                     [cp sequence: disjunctive[i].successors by: ^ORFloat(ORInt i) { return [cp est: t[i]]; } then: ^ORFloat(ORInt i) { return [cp ect: t[i]];}];
                  }];
                  [cp label: makespan];
                  printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
                  ORLong timeEnd = [ORRuntimeMonitor cputime];
                  NSLog(@"Time: %lld:",timeEnd - timeStart);
               }];
            }
            onRepeat: ^{
               id<ORSolution> sol = [[cp solutionPool] best];
               for(ORInt k = 1; k <= 3; k++) {
                  ORInt i = [sM next];
                  id<ORIntVarArray> succ = disjunctive[i].successors;
                  id<ORTaskVarArray> t = disjunctive[i].taskVars;
                  ORInt s = [sD next];
                  ORInt d = [lD next];
                  // need to fix everything outside the bounds but the tight constraints
                  for(ORInt j = s; j <= min(s+d,size); j++) {
                     if (j != 0) {
                        ORInt next = [sol intValue: succ[j]];
                        if (next != size+1) {
                           ORInt ect = [t[j] ect: sol];
                           ORInt est = [t[next] est: sol];
                           if (ect != est) {
                              if ([pD next] <= 20)
                                 [cp label: succ[j] with: [sol intValue: succ[j]]];
                           }
                        }
                     }
                  }
               }
               //           NSLog(@"Restart");
            }];
         }];
      }];
      
      ORLong timeEnd = [ORRuntimeMonitor cputime];
      NSLog(@"Time: %lld:",timeEnd - timeStart);
      id<ORSolutionPool> pool = [cp solutionPool];
      //      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      id<ORSolution> optimum = [pool best];
      printf("Makespan: %d \n",[optimum intValue: makespan]);
      NSLog(@"Solver status: %@\n",cp);
      [cp release];
      NSLog(@"Quitting");
      //      struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
      
   }
   return 0;
}

int mainPureCP(int argc, const char * argv[])
{
   @autoreleasepool {
      
      [ORStreamManager setRandomized];
      id<ORModel> model = [ORFactory createModel];
      
      // data
      ORLong timeStart = [ORRuntimeMonitor cputime];
      ORInt size = size10;
      id<ORIntRange> Size = RANGE(model,1,size);
      id<ORIntMatrix> duration = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iduration10[i-1][j-1]; } ];
      id<ORIntMatrix> resource = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iresource10[i-1][j-1]; } ];
      
      ORInt totalDuration = 0;
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            totalDuration += [duration at: i : j];
      id<ORIntRange> Horizon = RANGE(model,0,totalDuration);
      
      // variables
      
      id<ORTaskVarMatrix> task = [ORFactory taskVarMatrix: model range: Size : Size horizon: Horizon duration: duration];
      id<ORIntVar> makespan = [ORFactory intVar: model domain: RANGE(model,1,10000)];
      id<ORTaskDisjunctiveArray> disjunctive = [ORFactory disjunctiveArray: model range: Size];
      
      // model
      
      [model minimize: makespan];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j < Size.up; j++)
            [model add: [[task at: i : j] precedes: [ task at: i : j+1]]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         [model add: [[task at: i : Size.up] isFinishedBy: makespan]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            [disjunctive[[resource at: i : j]] add: [ task at: i : j]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         [model add: disjunctive[i]];
      
      // search
      id<CPProgram,CPScheduler> cp  = [ORFactory createCPProgram: model];
      [cp solve: ^{
         [cp forall: Size orderedBy: ^ORInt(ORInt i) { return [cp globalSlack: disjunctive[i]]; } do: ^(ORInt i) {
            id<ORTaskVarArray> t = disjunctive[i].taskVars;
            [cp sequence: disjunctive[i].successors by: ^ORFloat(ORInt i) { return [cp est: t[i]]; } then: ^ORFloat(ORInt i) { return [cp ect: t[i]];}];
         }];
         [cp label: makespan];
         printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
      }];
      ORLong timeEnd = [ORRuntimeMonitor cputime];
      NSLog(@"Time: %lld:",timeEnd - timeStart);
      id<ORSolutionPool> pool = [cp solutionPool];
      //      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      id<ORSolution> optimum = [pool best];
      printf("Makespan: %d \n",[optimum intValue: makespan]);
      NSLog(@"Solver status: %@\n",cp);
      [cp release];
      NSLog(@"Quitting");
      //      struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
      
   }
   return 0;
}

int main(int argc, const char * argv[])
{
   return mainPureCP(argc,argv);
}

