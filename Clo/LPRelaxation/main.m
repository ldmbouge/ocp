/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORControl.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/LPProgram.h>
#import <ORProgram/CPProgram.h>


static int nbRows = 7;
static int nbColumns = 12;

int b[7] = { 18209, 7692, 1333, 924, 26638, 61188, 13360 };
int c[12] = { 96, 76, 56, 11, 86, 10, 66, 86, 83, 12, 9, 81 };
int coef[7][12] = {
   { 19,   1,  10,  1,   1,  14, 152, 11,  1,   1, 1, 1},
   {  0,   4,  53,  0,   0,  80,   0,  4,  5,   0, 0, 0},
   {  4, 660,   3,  0,  30,   0,   3,  0,  4,  90, 0, 0},
   {  7,   0,  18,  6, 770, 330,   7,  0,  0,   6, 0, 0},
   {  0,  20,   0,  4,  52,   3,   0,  0,  0,   5, 4, 0},
   {  0,   0,  40, 70,   4,  63,   0,  0, 60,   0, 4, 0},
   {  0,  32,   0,  0,   0,   5,   0,  3,  0, 660, 0, 9}};

int main_lp(int argc, const char * argv[])
{
   
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntRange> Domain = [ORFactory intRange: model low: 0 up: 10000];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domain];
   
   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      ca[i] = [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]];
   [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
   id<LPRelaxation> lp = [ORFactory createLPRelaxation: model];
   
   [lp solve];
   
   for(ORInt i = 0; i < nbColumns-1; i++)
      printf("x[%d] = %10.5f : %10.5f \n",i,[lp floatValue: x[i]],[lp reducedCost: x[i]]);
   for(ORInt i = 0; i < nbRows; i++)
      printf("dual c[%d] = %f \n",i,[lp dual: ca[i]]);
   NSLog(@"we are done (Part I) \n\n");
   
   [lp updateLowerBound: x[10] with:6506];
   [lp updateUpperBound: x[3] with: 153];
   
   [lp solve];
   
   for(ORInt i = 0; i < nbColumns-1; i++)
      printf("x[%d] = %10.5f : %10.5f \n",i,[lp floatValue: x[i]],[lp reducedCost: x[i]]);
   NSLog(@"we are done (Part II) \n\n");
   
   [lp release];
   return 0;
}

int main_hybrid(int argc, const char * argv[])
{
   ORLong startTime = [ORRuntimeMonitor cputime];
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntRange> Domain = [ORFactory intRange: model low: 0 up: 10000];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domain];
   
//   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]];
   [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
   
   id<ORRelaxation> lp = [ORFactory createLinearRelaxation: model];
//   OROutcome b = [lp solve];
//   printf("outcome: %d \n",b);
   printf("Objective: %f \n",[lp objective]);
   for(ORInt i = 0; i < nbColumns-1; i++)
      printf("x[%d] = %10.5f in [%10.5f,%10.5f] \n",i,[lp value: x[i]],[lp lowerBound: x[i]],[lp upperBound: x[i]]);

   id<CPProgram> cp = [ORFactory createCPProgram: model withRelaxation: lp];
   
   [cp solve:
    ^() {
       for(ORInt i = 0; i < nbColumns; i++) {
          NSLog(@"Variable x[%d]=[%d,%d]",i,[cp min: x[i]],[cp max: x[i]]);
       }
       for(ORInt i = 0; i < nbColumns; i++) {
//          NSLog(@"Variable x[%d]=[%d,%d]",i,[cp min: x[i]],[cp max: x[i]]);
          while (![cp bound: x[i]]) {
             ORInt m = ([cp max: x[i]] + [cp min: x[i]]) / 2;
//             NSLog(@"Mid value: %d for [%d,%d]",m,[cp min: x[i]],[cp max: x[i]]);
             [cp try:
               ^()  { [cp gthen: x[i] with: m]; /* NSLog(@"After gthen %d: [%d,%d]",i,[cp min: x[i]],[cp max: x[i]]); */}
                  or:
              ^()  { [cp lthen: x[i] with: m+1]; /* NSLog(@"After lthen %d: [%d,%d]",i,[cp min: x[i]],[cp max: x[i]]); */}
             
              ];
          }
       }
//      for(ORInt i = 0; i < nbColumns; i++)
//         NSLog(@"Value of x[%d] = %d",i,[cp intValue: x[i]]);
    }
    ];
   ORLong endTime = [ORRuntimeMonitor cputime];
   printf("Execution Time: %lld \n",endTime - startTime);
   NSLog(@"we are done \n\n");
   [cp release];
   return 0;
}


int main(int argc, const char * argv[])
{
//   main_lp(argc,argv);
   return main_hybrid(argc,argv);
}
