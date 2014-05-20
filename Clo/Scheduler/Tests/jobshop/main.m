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


ORInt size = 6;
ORInt iresource[6][6] = {
   { 3, 1, 2, 4, 6, 5},
   { 2, 3, 5, 6, 1, 4},
   { 3, 4, 6, 1, 2, 5},
   { 2, 1, 3, 4, 5, 6},
   { 3, 2, 5, 6, 1, 4},
   { 2, 4, 6, 1, 5, 3}
};
ORInt iduration[6][6] = {
   {  1,  3,  6,  7,  3,  6},
   {  8,  5, 10, 10, 10,  4},
   {  5,  4,  8,  9,  1,  7},
   {  5,  5,  5,  3,  8,  9},
   {  9,  3,  5,  4,  3,  1},
   {  3,  3,  9, 10,  4,  1}
};

int main(int argc, const char * argv[])
{
   
   @autoreleasepool {
      
      id<ORModel> model = [ORFactory createModel];

      // data
      id<ORIntRange> Size = RANGE(model,1,size);
      id<ORIntMatrix> duration = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iduration[i-1][j-1]; } ];
      id<ORIntMatrix> resource = [ORFactory intMatrix: model range: Size : Size with: ^ORInt(ORInt i,ORInt j) { return iresource[i-1][j-1]; } ];
      ORInt totalDuration = 0;
      for(ORInt i = Size.low; i < Size.up; i++)
         for(ORInt j = Size.low; j < Size.up; j++)
            totalDuration += [duration at: i : j];
      id<ORIntRange> Horizon = RANGE(model,0,totalDuration);
      NSLog(@"Horizon: %@",Horizon);
      
      // variables
      id<ORActivityMatrix> activity = [ORFactory activityMatrix: model range: Size : Size horizon: Horizon duration: duration];
      id<OROptionalActivity> makespan = [ORFactory compulsoryActivity: model horizon: Horizon duration: 0];
      id<ORDisjunctiveResourceArray> machine = [ORFactory disjunctiveResourceArray: model range: Size];
      
      // constraints and objective
      [model minimize: makespan.startLB];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j < Size.up; j++)
            [model add: [[activity at: i : j] precedes: [activity at: i : j+1]]];
      
      for(ORInt i = Size.low; i <= Size.up; i++)
         [model add: [[activity at: i : Size.up] precedes: makespan]];

      for(ORInt i = Size.low; i <= Size.up; i++)
         for(ORInt j = Size.low; j <= Size.up; j++)
            [machine[[resource at: i : j]] isRequiredBy: [activity at: i : j]];
      
       for(ORInt i = Size.low; i <= Size.up; i++)
          [model add: [ORFactory schedulingDisjunctive: [machine[i] activities]]];

      // search
      id<CPSchedulingProgram> cp  = [ORFactory createCPSchedulingProgram: model];
      [cp solve: ^{
         [cp setTimes: [activity flatten]];
         [cp labelOptionalActivity: makespan];
         printf("makespan = [%d,%d] \n",[cp min: makespan.startLB],[cp max: makespan.startLB]);
         for(ORInt i = Size.low; i <= Size.up; i++) {
            id<OROptionalActivityArray> act = [machine[i] activities];
            for(ORInt k = act.range.low; k <= act.range.up; k++) {
               printf("[%d): %d --(%d) --> %d]",act[k].getId,[cp intValue: act[k].startLB],[cp intValue: act[k].duration],[cp intValue: act[k].startLB] + [cp intValue: act[k].duration]);
            }
            printf("\n");
         }
      }];
      id<ORSolutionPool> pool = [cp solutionPool];
      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      id<ORSolution> optimum = [pool best];
      printf("Makespan: %d \n",[optimum intValue: makespan.startLB]);
      NSLog(@"Solver status: %@\n",cp);
      [cp release];
      NSLog(@"Quitting");
      //      struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);

   }
   return 0;
}


