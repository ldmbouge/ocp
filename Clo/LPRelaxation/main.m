/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import "math.h"
#import "ORCmdLineArgs.h"
#import "PCBranching.h"

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
   id<ORRealVar> y = [ORFactory realVar: model low: 0.0 up: 0.0];
   
   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      ca[i] = [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
   [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
   id<LPRelaxation> lp = [ORFactory createLPRelaxation: model];
   
   [lp solve];
   printf("Objective: %f \n",[lp objective]);
   for(ORInt i = 0; i < nbColumns-1; i++)
      printf("x[%d] = %10.5f : %10.5f \n",i,[lp doubleValue: x[i]],[lp reducedCost: x[i]]);
   for(ORInt i = 0; i < nbRows; i++)
      printf("dual c[%d] = %f \n",i,[lp dual: ca[i]]);
   NSLog(@"we are done (Part I) \n\n");
   
   [lp updateLowerBound: x[10] with:6506];
   [lp updateUpperBound: x[3] with: 153];
   
   [lp solve];
   
   for(ORInt i = 0; i < nbColumns-1; i++)
      printf("x[%d] = %10.5f : %10.5f \n",i,[lp doubleValue: x[i]],[lp reducedCost: x[i]]);
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
   id<ORRealVar> y = [ORFactory realVar: model low: 0.0 up: 0.0];
   
   id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      ca[i] = [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
   [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
   id<MIPProgram> mip = [ORFactory createMIPProgram: model];
   
   [mip solve];
   ORLong endTime = [ORRuntimeMonitor cputime];
   printf("PUREMIP********** : Execution Time: %lld \n",endTime - startTime);
   NSLog(@"PUREMIP**********   Objective: %@",[mip objectiveValue]);
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
         id<ORRealVar> y = [ORFactory realVar: model low: 0.0 up: 0.0];
         
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
                       alt:
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
//         id<ORRealVar> y = [ORFactory realVar: model low: 0.0 up: 0.0];
         
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
                       alt:
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
         id<ORRealVar> y = [ORFactory realVar: model low: 0.0 up: 0.0];
        
         for(ORInt i = 0; i < nbRows; i++)
            [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
            //[note relax: [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]]];
            //[model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]];
          [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
         
         id<ORRelaxation> lp = [ORFactory createLinearRelaxation: model];
         id<CPProgram> cp = [ORFactory createCPProgram: model
                                        withRelaxation: lp
                                            annotation: note];
         [cp solve:
          ^() {
             id<ORSelect> sel = [ORFactory select:cp range: Columns
                                         suchThat:^ORBool(ORInt i)    { return true;}
                                        orderedBy:^ORDouble(ORInt i) { return frac([lp value: x[i]]);}];
             while (true) {
                ORInt idx = [sel max];
                ORDouble ifval = [lp value: x[idx]];
                //NSLog(@"Index: %d -> %f in [%d,%d]",idx,ifval,[cp min: x[idx]],[cp max: x[idx]]);
                if (ifval == 0.0)
                   break;
                [cp try:
                        ^{ [cp gthen: x[idx] double: ifval]; }
                    alt:
                        ^{ [cp lthen: x[idx] double: ifval]; }
                 ];
//                NSLog(@"new Objective: %f",[lp objective]);
             }
             for(ORInt i = 0; i < nbColumns; i++) {
                if (![cp bound: x[i]])
                   [cp label: x[i] with: rint([lp value: x[i]])];
             }
             [cp assignRelaxationValue: [lp value: y] to: y];
          }
          ];
         ORLong endTime = [ORRuntimeMonitor cputime];
         ORLong nbFailures = [[cp explorer] nbFailures];
         printf("Execution Time: %lld \n",endTime - startTime);
         printf("NbFailures: %lld \n",nbFailures);
         NSLog(@"we are done \n\n");
         id<ORSolution> sol = [[cp solutionPool] best];
         ORInt valueSol = [(id<ORObjectiveValueInt>)[sol objectiveValue] value];
         for(ORInt i = 0; i < nbColumns; i++) {
            NSLog(@"Variable x[%d] is %d",i,[sol intValue: x[i]]);
         }
         //NSLog(@"Variable y is in [%f,%f]",[sol doubleMin: y],[sol doubleMax: y]);
         NSLog(@"Variable y is %f",[sol doubleValue: y]);
         struct ORResult r = REPORT(valueSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}


int main_hybrid_branchingMANUALMIP(int argc, const char * argv[])
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
         id<ORRealVar> y = [ORFactory realVar: model low: 0.0 up: 0.0];
         
         for(ORInt i = 0; i < nbRows; i++)
            [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: [y plus: @(b[i])]]];
         //[note relax: [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]]];
         //[model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]];
//         [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
         [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
         
         id<ORRelaxation> lp = [ORFactory createLinearRelaxation: model];
         id<CPProgram> cp = [ORFactory createCPProgram: model
                                        withRelaxation: lp
                                            annotation: note
                                                  with: [ORSemDFSController proto]
                             ];
         [cp solve:
          ^() {
             PCBranching* pcb = [[PCBranching alloc] init:lp over:x program:cp];
             //FSBranching* pcb = [[FSBranching alloc] init:lp over:x program:cp];
             [pcb branchOn:x];
          }
          ];
         ORLong endTime = [ORRuntimeMonitor cputime];
         ORLong nbFailures = [[cp explorer] nbFailures];
         ORLong nbChoices  = [[cp explorer] nbChoices];
         printf("Execution Time: %lld \n",endTime - startTime);
         printf("#Failures: %lld \n",nbFailures);
         printf("#Choices : %lld \n",nbChoices);
         NSLog(@"we are done \n\n");
         id<ORSolution> sol = [[cp solutionPool] best];
         NSLog(@"FINAL OBJECTIVE: %@",[sol objectiveValue]);
         ORInt valueSol = [(id<ORObjectiveValueInt>)[sol objectiveValue] value];
         for(ORInt i = 0; i < nbColumns; i++) {
            NSLog(@"Variable x[%d] is %d",i,[sol intValue: x[i]]);
         }
         //NSLog(@"Variable y is in [%f,%f]",[sol doubleMin: y],[sol doubleMax: y]);
         NSLog(@"Variable y is %f",[sol doubleValue: y]);
         struct ORResult r = REPORT(valueSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}





/*


id<ORIntVarArray> av = m.intVars;
while (![p allBound:av]) {
   double brc = FDMAXINT;
   ORInt bi = av.range.low - 1;
   for(ORInt i=av.range.low;i <= av.range.up;i++) {
      if ([p bound:av[i]]) continue;
      double rc = [relax value:av[i]];
      double mp = 0.5 - (rc - floor(rc));
      double frac = fabs(mp);
      if (frac == 0.5) continue;
      printf("(%d,%.2f) ",i,frac);
      if (frac < brc) {
         brc = frac;
         bi = i;
      }
   }
   printf("\n");
   if (bi != av.range.low - 1) {
      double lb = [p min:av[bi]],ub = [p max:av[bi]];
      double m  = (lb + ub)/2.0;ORInt im = floor(m);
      [p try:^{
         [p lthen:av[bi] with:im+1];
      } alt:^{
         [p gthen:av[bi] with:im];
      }];
      NSLog(@"Objective: %@",[p objectiveValue]);
   } else break;
}
 
 */



int main(int argc, const char * argv[])
{
//   main_lp(argc,argv);
   // 261922 and 24431 failures
//   return main_hybrid(argc,argv);
    main_mip(argc,argv);
    main_hybrid_branching(argc,argv);
   return main_hybrid_branchingMANUALMIP(argc,argv);
   //return main_mip(argc,argv);
   //return main_cp(argc,argv);
}
