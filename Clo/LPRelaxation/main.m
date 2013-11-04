/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORControl.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/LPProgram.h>
#import <ORProgram/CPProgram.h>
#import "math.h"

#import "ORCmdLineArgs.h"

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
   id<ORFloatVar> y = [ORFactory floatVar: model low: 0.0 up: 0.0];
   
   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      ca[i] = [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
   [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
   id<LPRelaxation> lp = [ORFactory createLPRelaxation: model];
   
   [lp solve];
   printf("Objective: %f \n",[lp objective]);
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

int main_mip(int argc, const char * argv[])
{
   ORLong startTime = [ORRuntimeMonitor cputime];
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntRange> Domain = [ORFactory intRange: model low: 0 up: 10000];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domain];
   id<ORFloatVar> y = [ORFactory floatVar: model low: 0.0 up: 0.0];
   
   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      ca[i] = [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
   [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
   id<MIPProgram> mip = [ORFactory createMIPProgram: model];
   
   [mip solve];
   ORLong endTime = [ORRuntimeMonitor cputime];
   printf("Execution Time: %lld \n",endTime - startTime);
   NSLog(@"Objective: %@",[mip objectiveValue]);
   [mip release];
   return 0;
}

int main_cp(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORLong startTime = [ORRuntimeMonitor cputime];
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
         id<ORIntRange> Domain = [ORFactory intRange: model low: 0 up: 10000];
         id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domain];
         id<ORFloatVar> y = [ORFactory floatVar: model low: 0.0 up: 0.0];
         
         //   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
         for(ORInt i = 0; i < nbRows; i++)
            [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
         [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
         
         
         id<CPProgram> cp = [ORFactory createCPProgram: model];
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
         ORInt valueSol = [(id<ORObjectiveValueInt>)[[[cp solutionPool] best] objectiveValue] value];
         struct ORResult r = REPORT(valueSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         return r;
      }];
   }
   return 0;
}

int main_hybrid(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORLong startTime = [ORRuntimeMonitor cputime];
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
         id<ORIntRange> Domain = [ORFactory intRange: model low: 0 up: 10000];
         id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domain];
//         id<ORFloatVar> y = [ORFactory floatVar: model low: 0.0 up: 0.0];
         
         //   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
         for(ORInt i = 0; i < nbRows; i++)
//               [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
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
         ORLong nbFailures = [[cp explorer] nbFailures];
         printf("Execution Time: %lld \n",endTime - startTime);
         printf("NbFailures: %lld \n",nbFailures);
         NSLog(@"we are done \n\n");
         ORInt valueSol = [(id<ORObjectiveValueInt>)[[[cp solutionPool] best] objectiveValue] value];
         struct ORResult r = REPORT(valueSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         return r;
      }];
   }
   return 0;
}

int main_hybrid_branching(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORLong startTime = [ORRuntimeMonitor cputime];
         id<ORAnnotation> note = [ORFactory annotation];
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
         id<ORIntRange> Domain = [ORFactory intRange: model low: 0 up: 10000];
         id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domain];
         //         id<ORFloatVar> y = [ORFactory floatVar: model low: 0.0 up: 0.0];
         
         //   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
         for(ORInt i = 0; i < nbRows; i++)
            //               [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
            //[note relax: [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]]];
            [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]];
         [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
         
         id<ORRelaxation> lp = [ORFactory createLinearRelaxation: model];
         //   OROutcome b = [lp solve];
         //   printf("outcome: %d \n",b);
         printf("Objective: %f \n",[lp objective]);
         for(ORInt i = 0; i < nbColumns-1; i++)
            printf("x[%d] = %10.5f in [%10.5f,%10.5f] \n",i,[lp value: x[i]],[lp lowerBound: x[i]],[lp upperBound: x[i]]);
         id<CPProgram> cp = [ORFactory createCPProgram: model withRelaxation: lp annotation: note];
         [cp solve:
          ^() {
             NSLog(@"Objective: %f",[lp objective]);
             id<ORSelect> sel = [ORFactory select:cp range: Columns
                                         suchThat:^bool(ORInt i)    { return true;}
                                        orderedBy:^ORFloat(ORInt i) { return frac([lp value: x[i]]);}];
             while (true) {
                ORInt idx = [sel max];
                ORFloat ifval = [lp value: x[idx]];
                if (ifval == 0.0)
                   break;
                //NSLog(@"Most Fractional: %d with %f giving (%ld,%ld)",idx,ifrac,lrint(floor(ifval)),lrint(ceil(ifval)));
                [cp try:
                        ^{ [cp gthen: x[idx] float: ifval]; }
                     or:
                        ^{ [cp lthen: x[idx] float: ifval]; }
                 ];
//                NSLog(@"new Objective: %f",[lp objective]);
             }
             //NSLog(@"new primal bound: %f",[lp objective]);
             for(ORInt i = 0; i < nbColumns; i++) {
                if (![cp bound: x[i]])
                   [cp label: x[i] with: rint([lp value: x[i]])];
             }
          }
          ];
         ORLong endTime = [ORRuntimeMonitor cputime];
         ORLong nbFailures = [[cp explorer] nbFailures];
         printf("Execution Time: %lld \n",endTime - startTime);
         printf("NbFailures: %lld \n",nbFailures);
         NSLog(@"we are done \n\n");
         ORInt valueSol = [(id<ORObjectiveValueInt>)[[[cp solutionPool] best] objectiveValue] value];
         struct ORResult r = REPORT(valueSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         return r;
      }];
   }
   return 0;
}


int main(int argc, const char * argv[])
{
//   main_lp(argc,argv);
   // 261922 and 24431 failures
//   return main_hybrid(argc,argv);
    return main_hybrid_branching(argc,argv);
   //return main_mip(argc,argv);
   //return main_cp(argc,argv);
}
