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

//setTimes for mt06
//Makespan: 55
//2014-06-29 15:01:07.168 jobshop[6054:303] Solver status: Solver: 74 vars
//43 constraints
//2054 choices
//1972 fail
//26972 propagations


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


int main(int argc, const char * argv[])
{
   @autoreleasepool {
      

      id<ORModel> model = [ORFactory createModel];

      // data
      
      ORInt size = size6;
      id<ORIntRange> Size = RANGE(model,1,size);
      id<ORIntMatrix> duration = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iduration6[i-1][j-1]; } ];
      id<ORIntMatrix> resource = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iresource6[i-1][j-1]; } ];
   
      ORInt totalDuration = 0;
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            totalDuration += [duration at: i : j];
      id<ORIntRange> Horizon = RANGE(model,0,totalDuration);
      
      // variables
      
      id<ORTaskVarMatrix> task = [ORFactory taskVarMatrix: model range: Size : Size horizon: Horizon duration: duration];
      id<ORIntVar> makespan = [ORFactory intVar: model domain: RANGE(model,1,1100)];
      id<ORTaskDisjunctiveArray> disjunctive = [ORFactory taskDisjunctiveArray: model range: Size];
      
      // model
      
      [model minimize: makespan];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j < Size.up; j++)
            [model add: [[task at: i : j] precedes: [ task at: i : j+1]]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         [model add: [[task at: i : Size.up] isFinishedBy: makespan]];

      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            [disjunctive[[resource at: i : j]] isRequiredBy: [ task at: i : j]];
      
       for(ORInt i = Size.low; i <= Size.up; i++)
          [model add: disjunctive[i]];

      
      // search
      id<CPSchedulingProgram> cp  = [ORFactory createCPSchedulingProgram: model];
      [cp solve: ^{
         [cp setTimes: [task flatten]];
         [cp label: makespan];
         printf("makespan = [%d,%d] \n",[cp min: makespan],[cp max: makespan]);
      }];
      
      id<ORSolutionPool> pool = [cp solutionPool];
      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      id<ORSolution> optimum = [pool best];
      printf("Makespan: %d \n",[optimum intValue: makespan]);
      NSLog(@"Solver status: %@\n",cp);
      [cp release];
      NSLog(@"Quitting");
      //      struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);

   }
   return 0;
}


