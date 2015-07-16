
/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTAq, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORProgram/ORProgramFactory.h>
#import <objls/LSFactory.h>
#import <objls/LSConstraint.h>
#import <objls/LSSolver.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> mdl = [ORFactory createModel];
         //[ORStreamManager setDeterministic];
         ORInt nbConfigs = 6;
         id<ORIntRange> Configs = RANGE(mdl,1,nbConfigs);
         //         ORInt choiceConfig = [args size];
         //ORInt nbPeriods    = [args size];
         //ORInt choiceConfig = [args nArg];
         ORInt nbPeriods    = 7;
         ORInt choiceConfig = 6;
         
         id<ORIntRange> Hosts = RANGE(mdl,1,13);
         id<ORIntRange> Guests = RANGE(mdl,1,29);
         id<ORIntRange> Periods = RANGE(mdl,1,nbPeriods);
         id<ORIntArray> cap = [ORFactory intArray: mdl range: Hosts value: 0];
         id<ORIntArray> crew = [ORFactory intArray: mdl range: Guests value: 0];
         
         id<ORIntSetArray> config = [ORFactory intSetArray: mdl range: Configs];
         config[1] = COLLECT(mdl,i,RANGE(mdl,1,12),i);
         [config[1] insert: 16];
         config[2] = COLLECT(mdl,i,RANGE(mdl,1,13),i);
         config[3] = COLLECT(mdl,i,RANGE(mdl,3,13),i);
         [config[3] insert: 1];
         [config[3] insert: 19];
         config[4] = COLLECT(mdl,i,RANGE(mdl,3,13),i);
         [config[4] insert: 25];
         [config[4] insert: 26];
         config[5] = COLLECT(mdl,i,RANGE(mdl,1,11),i);
         [config[5] insert: 19];
         [config[5] insert: 21];
         config[6] = COLLECT(mdl,i,RANGE(mdl,1,9),i);
         for(ORInt i = 16; i <= 19; i++)
            [config[6] insert: i];
         
         NSLog(@"%@",config);
         
         FILE* dta = fopen("progressive.txt","r");
         ORInt h = 1;
         ORInt g = 1;
         for(ORInt i = 1; i <= 42; i++) {
            ORInt id, bcap, sz;
            fscanf(dta, "%d",&id);
            fscanf(dta, "%d",&bcap);
            fscanf(dta, "%d",&sz);
            if ([config[choiceConfig] member: id]) {
               [cap set: bcap - sz at: h];
               h++;
            }
            else {
               [crew set: sz at: g];
               g++;
            }
         }
         NSLog(@"CAP = %@",cap);
         NSLog(@"CREW= %@",crew);
         ORLong startTime = [ORRuntimeMonitor cputime];
         id<ORAnnotation> notes = [ORFactory annotation];
         NSLog(@"size Guests = %@",Guests);
         id<ORIntVarMatrix> boat = [ORFactory intVarMatrix:mdl range:Guests :Periods domain: Hosts];
         for(ORInt g = Guests.low; g <= Guests.up; g++)
            [notes dc:[mdl add: [ORFactory alldifferent: All(mdl,ORIntVar, p, Periods, [boat at:g :p]) ]]];
         for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++) {
            id<ORIntVarArray> a1 = All(mdl,ORIntVar, p, Periods, [boat at:g1 :p]);
            for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
               id<ORIntVarArray> a2 = All(mdl,ORIntVar, p, Periods, [boat at:g2 :p]);
               [mdl add: [ORFactory meetAtmost: mdl x:a1 y:a2 atmost:1]];
            }
         }
         for(ORInt p = Periods.low; p <= Periods.up; p++)
            [mdl add: [ORFactory multiknapsack:mdl item:All(mdl,ORIntVar, g, Guests, [boat at: g :p]) itemSize: crew capacity: cap]];
         
         ORInt nbv = 29*nbPeriods;
         id<ORIntRange> Vars = RANGE(mdl,0,nbv-1);
         id<ORIntVar>* x = malloc(nbv * sizeof(id<ORIntVar>));
         
         ORInt k = 0;
         for(ORInt g = Guests.low; g <= Guests.up; g++)
            for(ORInt p = Periods.low; p <= Periods.up; p++)
               x[k++] = [boat at:g :p];
         
         id<ORIntMatrix> tabu = [ORFactory intMatrix:mdl range: Vars : Hosts];
         id<ORIntArray> bestSolution = [ORFactory intArray:mdl range: Vars value: 0];
         id<ORIntArray> weightedBestSolution = [ORFactory intArray:mdl range: Vars value: 0];
         
         
         ORInt restartSearch = false;
         ORInt restartIterations = 1000000;
         ORInt stableLimit = 2000;
         ORInt iterationLimit = 1000000;
         ORInt LagrangianFrequency = 50000;
         __block ORInt best = FDMAXINT;
         __block ORInt weightedBest = FDMAXINT;
         __block ORInt it = 0;
         __block ORInt tbl = 2;
         __block ORInt tblMin = 2;
         __block ORInt tblMax = 10;
         __block ORInt stable = 0;
         __block ORInt nbUpdates = 0;
         
         for(ORInt i = 0; i < nbv; i++)
            for(ORInt v = Hosts.low; v <= Hosts.up; v++)
               [tabu set: -1 at: i : v];

         
         id<LSProgram> ls = [ORFactory createLSProgram:mdl annotation:nil];
         [ls solve: ^{
            
            for(ORInt i = 0; i < nbv; i++)
               [ls label: x[i] with: 1 + random() % 13] ;
            
            while (it < iterationLimit) {

               if (restartSearch && it % restartIterations == 0) {
                  for(ORInt i = 0; i < nbv; i++)
                     [ls label: x[i] with: 1 + random() % 13] ;
                  stable = 0;
                  weightedBest = FDMAXINT;
                  for(ORInt i = 0; i < nbv; i++)
                     [ls label: x[i] with: 1 + random() % 13] ;
                  [ls resetMultipliers];
               }
               
               ORInt old = [ls getWeightedViolations];
               [ls selectMax: Vars orderedBy:^ORFloat(ORInt i) { return [ls getVarWeightedViolations:x[i]];} do:^(ORInt i) {
                  ORInt gap = weightedBest - old;
                  [ls selectMin: Hosts suchThat: ^ORBool(ORInt v) { return ([tabu at: i : v] <= it) || ([ls weightedDeltaWhenAssign:x[i] to:v] < gap) ; }
                      orderedBy:^ORFloat(ORInt v) { return [ls weightedDeltaWhenAssign:x[i] to:v];} do:^(ORInt v) {
//                         ORInt delta = [ls weightedDeltaWhenAssign:x[i] to:v];
                         [tabu set: it + tbl at: i : [ls intValue: x[i]]];
                         [ls label:x[i] with:v];
                         ORInt violations = [ls getWeightedViolations];
//                         assert(old + delta == violations);
                         if (violations < old && tbl > tblMin) tbl--;
                         if (violations >= old && tbl <tblMax) tbl++;
                         
                      }];
               }];
               it++;
               
               // update the best solutions
               if ([ls getUnweightedViolations] < best) {
                  best = [ls getUnweightedViolations];
 //                 printf("[%d]",best);
                  for(ORInt i = 0; i < nbv; i++)
                     [bestSolution set: [ls intValue: x[i]] at: i];
               }
               if ([ls getViolations] < weightedBest) {
                  stable = 0;
                  weightedBest = [ls getViolations];
 //                 printf("(%d)",weightedBest);
                  for(ORInt i = 0; i < nbv; i++)
                     [weightedBestSolution set: [ls intValue: x[i]] at: i];
               }
               else
                  stable++;
 
               // Now that the best solutions are updated, test for termination
               if ([ls isTrue])
                  break;
               
               // intensification
               if (stable >= stableLimit) {
                  stable = 0;
                  for(ORInt i = 0; i < nbv; i++)
                     [ls label: x[i] with: [weightedBestSolution at: i]] ;
               }
               
               // Lagrangian update
               if (it%LagrangianFrequency == 0) {
//                  printf("^\n");
                  nbUpdates++;
                  for(ORInt i = 0; i < nbv; i++)
                     [ls label: x[i] with: [weightedBestSolution at: i]];
                  [ls updateMultipliers];
                  weightedBest = FDMAXINT;
               }
            }
            ORLong endTime = [ORRuntimeMonitor cputime];
            for(ORInt i = 0; i < nbv; i++)
               [ls label: x[i] with: [bestSolution at: i]] ;
            printf("\n\n");
            printf("Violations: %d \n",[ls getUnweightedViolations]);
            printf("Iterations: %d \n",it);
            for(ORInt p = Periods.low; p <= Periods.up; p++) {
               NSMutableString* line = [[NSMutableString alloc] initWithCapacity:64];
               [line appendFormat:@"p=%2d : ",p];
               for(ORInt g = Guests.low; g <= Guests.up; g++)
                  [line appendFormat:@"%2d ",[ls intValue:[boat at: g :p]]];
               NSLog(@"%@",line);
               [line release];
            }
            NSLog(@"Execution Time: %lld \n",endTime - startTime);
         }];
         NSLog(@"capacity %@",cap);
         NSLog(@"crew %@",crew);
         printf("Final Violations: %d \n",[ls getViolations]);
         
         int use[14];
         for(ORInt p = Periods.low; p <= Periods.up; p++) {
            for(ORInt h = 1; h <= 13; h++)
               use[h] = 0;
            
            for(ORInt g = Guests.low; g <= Guests.up; g++)
               use[[ls intValue:[boat at: g : p]]] += [crew at: g];
            for(ORInt h = 1; h <= 13; h++)
               if (use[h] > [cap at: h]) {
                  printf("Bad capacity at %d - %d: %d instead of %d \n",p,h,use[h],[cap at: h]);
               }
         }
         for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++) {
            for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
               ORInt nbEq = 0;
               for(ORInt p=Periods.low;p <= Periods.up;p++) {
                  nbEq += [ls intValue:[boat at: g1 : p]] == [ls intValue:[boat at: g2 :p]];
                  if (nbEq >= 2) {
                     NSLog(@"Violation of social: g1=%d g2=%d p=%d  %@   -  %@",g1,g2,p,[boat at:g1:p],[boat at:g2 :p]);
                  }
               }
            }
         }
         struct ORResult r = REPORT([ls getViolations], it, 0, 0);
         return r;
      }];
   }
   return 0;
}



//int main(int argc, const char * argv[])
//{
//   @autoreleasepool {
//      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
//      [args measure:^struct ORResult() {
//         id<ORModel> mdl = [ORFactory createModel];
//         ORInt nbConfigs = 6;
//         id<ORIntRange> Configs = RANGE(mdl,1,nbConfigs);
//         ORInt choiceConfig = [args size];
//         ORInt nbPeriods    = [args nArg];
//         id<ORIntRange> Hosts = RANGE(mdl,1,13);
//         id<ORIntRange> Guests = RANGE(mdl,1,29);
//         id<ORIntRange> Periods = RANGE(mdl,1,nbPeriods);
//         id<ORIntArray> cap = [ORFactory intArray: mdl range: Hosts value: 0];
//         id<ORIntArray> crew = [ORFactory intArray: mdl range: Guests value: 0];
//         
//         id<ORIntSetArray> config = [ORFactory intSetArray: mdl range: Configs];
//         config[1] = COLLECT(mdl,i,RANGE(mdl,1,12),i);
//         [config[1] insert: 16];
//         config[2] = COLLECT(mdl,i,RANGE(mdl,1,13),i);
//         config[3] = COLLECT(mdl,i,RANGE(mdl,3,13),i);
//         [config[3] insert: 1];
//         [config[3] insert: 19];
//         config[4] = COLLECT(mdl,i,RANGE(mdl,3,13),i);
//         [config[4] insert: 25];
//         [config[4] insert: 26];
//         config[5] = COLLECT(mdl,i,RANGE(mdl,1,11),i);
//         [config[5] insert: 19];
//         [config[5] insert: 21];
//         config[6] = COLLECT(mdl,i,RANGE(mdl,1,9),i);
//         for(ORInt i = 16; i <= 19; i++)
//            [config[6] insert: i];
//         
//         NSLog(@"%@",config);
//         
//         FILE* dta = fopen("progressive.txt","r");
//         ORInt h = 1;
//         ORInt g = 1;
//         for(ORInt i = 1; i <= 42; i++) {
//            ORInt id, bcap, sz;
//            fscanf(dta, "%d",&id);
//            fscanf(dta, "%d",&bcap);
//            fscanf(dta, "%d",&sz);
//            if ([config[choiceConfig] member: id]) {
//               [cap set: bcap - sz at: h];
//               h++;
//            }
//            else {
//               [crew set: sz at: g];
//               g++;
//            }
//         }
//         NSLog(@"CAP = %@",cap);
//         NSLog(@"CREW= %@",crew);
//         ORLong startTime = [ORRuntimeMonitor cputime];
//         id<ORAnnotation> notes = [ORFactory annotation];
//         id<ORIntVarMatrix> boat = [ORFactory intVarMatrix:mdl range:Guests :Periods domain: Hosts];
//         for(ORInt g = Guests.low; g <= Guests.up; g++)
//            [notes dc:[mdl add: [ORFactory alldifferent: All(mdl,ORIntVar, p, Periods, [boat at:g :p]) ]]];
//         for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++)
//            for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++)
//               [mdl add: [Sum(mdl,p,Periods,[[boat at: g1 : p] eq: [boat at: g2 : p]]) leq: @1]];
//         for(ORInt p = Periods.low; p <= Periods.up; p++) {
//            [mdl add: [ORFactory packing:mdl item:All(mdl,ORIntVar, g, Guests, [boat at: g :p]) itemSize: crew binSize:cap]];
//            for(ORInt h=Hosts.low ; h <= Hosts.up; h++)
//               [mdl add:[Sum(mdl, g, Guests, [[[boat at:g :p] eq:@(h)] mul: @([crew at:g])]) leq:@([cap at:h])]];
//         }
//         
//         id<CPProgram> cp = [args makeProgram:mdl annotation:notes];
////         id<CPHeuristic> hr = [args makeHeuristic:cp restricted:[ORFactory flattenMatrix:boat]];
//         ORFloat rate = [args restartRate];
//         __block ORInt lim = ((ORInt)rate==0) ? FDMAXINT : ([Guests size] * [Periods size] * 3);
//         NSLog(@"The limit starts at: %d  (%f)",lim,rate);
//         [cp solve: ^{
//            /*[cp limitTime:60 * 1000 in:^{
//               [cp repeat:^{
//                  [cp limitFailures:lim in:^{
//                     for(ORInt p = Periods.low; p <= Periods.up; p++) {
//                        id<ORIntVarArray> slice = [ORFactory intVarArray:cp range:Guests with:^id<ORIntVar>(ORInt g) {
//                           return [boat at:g :p];
//                        }];
//                        [cp labelHeuristic:hr restricted:slice];
//                     }
//                  }];
//               } onRepeat:^{
//                  lim = (ORInt) (lim * rate);
//                  NSLog(@"Restarting... %d",lim);
//               }];
//            }];
//            */
//            for(ORInt p = Periods.low; p <= Periods.up; p++) {
////               id<ORIntVarArray> slice = [ORFactory intVarArray:cp range:Guests with:^id<ORIntVar>(ORInt g) {
////                  return [boat at:g :p];
////               }];
////               [cp labelHeuristic:hr restricted:slice];
//               
//               [cp forall:Guests suchThat:^bool(ORInt g) { return ![cp bound:[boat at:g :p]];}
//                orderedBy: nil // ^ORInt(ORInt g) { return [cp domsize:[boat at:g :p]];}
//                       do:^(ORInt g) {
////                          for(ORInt k=Guests.low;k <= Guests.up;k++) {
////                             printf("%c%d,%d : %2d |",k==g ? '*' : ' ',k,p,[cp domsize:[boat at:k :p]]);
////                          }
////                          printf("\n");
//                          [cp tryall:Hosts suchThat:^bool(ORInt h) { return [cp member:h in:[boat at: g: p]];}
//                                  in:^(ORInt h) {
//                                     [cp label:[boat at:g :p] with:h];
//                                  }
//                           onFailure:^(ORInt h) {
//                              [cp diff:[boat at:g :p] with:h];
//                           }];
//                       }];
//               
//               // This search is 'weaker' (30,000 choices rather than ~ 5,000  on 6,1,9
//               /*
//                [CPLabel array: [CPFactory intVarArray: cp range: Guests with: ^id<ORIntVar>(ORInt g) { return [boat at: g : p]; } ]
//                orderedBy: ^ORInt(ORInt g) { return [[boat at:g : p] domsize];}
//                ];*/
//            }
//            ORLong endTime = [ORRuntimeMonitor cputime];
//            
//            for(ORInt p = Periods.low; p <= Periods.up; p++) {
//               NSMutableString* line = [[NSMutableString alloc] initWithCapacity:64];
//               [line appendFormat:@"p=%2d : ",p];
//               for(ORInt g = Guests.low; g <= Guests.up; g++) {
//                  if ([cp bound:[boat at: g : p]])
//                     [line appendFormat:@"%2d ",[cp intValue:[boat at: g :p]]];
//                  else [line appendFormat:@"%@",[boat at: g :p] ];
//               }
//               NSLog(@"%@",line);
//               [line release];
//            }
//            NSLog(@"Execution Time: %lld \n",endTime - startTime);
//            
//            int use[14];
//            for(ORInt p = Periods.low; p <= Periods.up; p++) {
//               for(ORInt h = 1; h <= 13; h++)
//                  use[h] = 0;
//               
//               for(ORInt g = Guests.low; g <= Guests.up; g++)
//                  use[[cp intValue:[boat at: g : p]]] += [crew at: g];
//               for(ORInt h = 1; h <= 13; h++)
//                  if (use[h] > [cap at: h]) {
//                     printf("Bad capacity at %d - %d: %d instead of %d \n",p,h,use[h],[cap at: h]);
//                     abort();
//                  }
//            }
//            for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++) {
//               for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
//                  ORInt nbEq = 0;
//                  for(ORInt p=Periods.low;p <= Periods.up;p++) {
//                     nbEq += [cp intValue:[boat at: g1 : p]] == [cp intValue:[boat at: g2 :p]];
//                     if (nbEq >= 2) {
//                        NSLog(@"Violation of social: g1=%d g2=%d p=%d  %@   -  %@",g1,g2,p,[boat at:g1:p],[boat at:g2 :p]);
//                        abort();
//                     }
//                  }
//                  assert (nbEq <= 1);
//               }
//            }
//            
//            for(ORInt g = Guests.low; g <= Guests.up; g++) {
//               for(ORInt p1 = Periods.low; p1 <= Periods.up; p1++)
//                  for(ORInt p2 = p1 + 1; p2 <= Periods.up; p2++) {
//                     if ([cp intValue:[boat at: g : p1]] == [cp intValue:[boat at: g : p2]]) {
//                        printf("boat[%d,%d] = %d and boat[%d,%d] = %d \n",g,p1,g,p2,[cp intValue:[boat at:g : p1]],[cp intValue:[boat at: g : p2]]);
//                        printf("all different is wrong \n");
//                        abort();
//                     }
//                  }
//            }
//            
//            for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++)
//               for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
//                  ORInt s = 0;
//                  for(ORInt p = Periods.low; p <= Periods.up; p++)
//                     s += [cp intValue:[boat at: g1 : p]] == [cp intValue:[boat at:g2 : p]];
//                  if (s > 1) {
//                     printf("guest %d and guest %d \n",g1,g2);
//                     printf("social constraint is wrong \n");
//                     abort();
//                  }
//               }
//            //          [cp add: [CPFactory packing: [CPFactory intVarArray: cp range: Guests with: ^id<ORIntVar>(ORInt g) { return [boat at: g : p]; }] itemSize: crew binSize:cap]];
//         }
//          ];
//         NSLog(@"Solver status: %@\n",cp);
//         NSLog(@"Quitting");
//         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
//         [cp release];
//         [ORFactory shutdown];
//         return res;
//      }];
//   }
//   return 0;
//}


/*
int real_main(int argc, const char * argv[])
{
   @autoreleasepool {      
      id<CPSolver> cp = [CPFactory createSolver];
      ORInt nbConfigs = 6;
      id<ORIntRange> Configs = RANGE(cp,1,nbConfigs);
      ORInt choiceConfig = 1;
      id<ORIntRange> Hosts = RANGE(cp,1,13);
      id<ORIntRange> Guests = RANGE(cp,1,29);
      ORInt nbPeriods = 7;
      id<ORIntRange> Periods = RANGE(cp,1,nbPeriods);
      id<ORIntArray> cap = [CPFactory intArray: cp range: Hosts value: 0];
      id<ORIntArray> crew = [CPFactory intArray: cp range: Guests value: 0];
      
      id<ORIntSetArray> config = [ORFactory intSetArray: cp range: Configs];
      config[1] = COLLECT(cp,i,RANGE(cp,1,12),i);
      [config[1] insert: 16];
      config[2] = COLLECT(cp,i,RANGE(cp,1,13),i);
      config[3] = COLLECT(cp,i,RANGE(cp,3,13),i);
      [config[3] insert: 1];
      [config[3] insert: 19];
      config[4] = COLLECT(cp,i,RANGE(cp,3,13),i);
      [config[4] insert: 25];
      [config[4] insert: 26];
      config[5] = COLLECT(cp,i,RANGE(cp,1,11),i);
      [config[5] insert: 19];
      [config[5] insert: 21];
      config[6] = COLLECT(cp,i,RANGE(cp,1,9),i);
      for(ORInt i = 16; i <= 19; i++)
         [config[6] insert: i];
      
      NSLog(@"%@",config);
      
      FILE* dta = fopen("progressive.txt","r");
      ORInt h = 1;
      ORInt g = 1;
      for(ORInt i = 1; i <= 42; i++) {
         ORInt id, bcap, sz;
         fscanf(dta, "%d",&id);
         fscanf(dta, "%d",&bcap);
         fscanf(dta, "%d",&sz);
         if ([config[choiceConfig] member: id]) {
            [cap set: bcap - sz at: h];
            h++;
         }
         else {
            [crew set: sz at: g];
            g++;
         }
      }
      //   NSLog(@"cap: %@",cap);
      //   NSLog(@"crew %@",crew);
      ORLong startTime = [ORRuntimeMonitor cputime];
      
      id<ORIntVarMatrix> boat = [CPFactory intVarMatrix:cp range:Guests :Periods domain: Hosts];
      for(ORInt g = Guests.low; g <= Guests.up; g++)
         [cp add: [CPFactory alldifferent: ALL(ORIntVar, p, Periods, [boat at:g :p]) ]];
      for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++)
         for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++)
            [cp add: [SUM(p,Periods,[[boat at: g1 : p] eq: [boat at: g2 : p]]) leqi: 1]];
      for(ORInt p = Periods.low; p <= Periods.up; p++)
         [cp add: [CPFactory packing: ALL(ORIntVar, g, Guests, [boat at: g :p]) itemSize: crew binSize:cap]];
      
      [cp solve:
       ^{
          for(ORInt p = Periods.low; p <= Periods.up; p++) {
             [CPLabel array: [CPFactory intVarArray: cp range: Guests with: ^id<ORIntVar>(ORInt g) { return [boat at: g : p]; } ]
                  orderedBy: ^ORInt(ORInt g) { return [[boat at:g : p] domsize];}
              ];
          }
          ORLong endTime = [ORRuntimeMonitor cputime];
          
          for(ORInt p = Periods.low; p <= Periods.up; p++) {
             NSMutableString* line = [[NSMutableString alloc] initWithCapacity:64];
             [line appendFormat:@"p=%2d : ",p];
             for(ORInt g = Guests.low; g <= Guests.up; g++) {
                if ([[boat at: g : p] bound])
                   [line appendFormat:@"%2d ",[[boat at: g :p] value]];
                else [line appendFormat:@"%@",[boat at: g :p] ];
             }
             NSLog(@"%@",line);
             [line release];
          }
          NSLog(@"Execution Time: %lld \n",endTime - startTime);
          
          int use[14];
          for(ORInt p = Periods.low; p <= Periods.up; p++) {
             for(ORInt h = 1; h <= 13; h++)
                use[h] = 0;
             
             for(ORInt g = Guests.low; g <= Guests.up; g++)
                use[[[boat at: g : p] value]] += [crew at: g];
             for(ORInt h = 1; h <= 13; h++)
                if (use[h] > [cap at: h]) {
                   printf("Bad capacity at %d - %d: %d instead of %d \n",p,h,use[h],[cap at: h]);
                   abort();
                }
          }
          for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++) {
             for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
                ORInt nbEq = 0;
                for(ORInt p=Periods.low;p <= Periods.up;p++) {
                   nbEq += [[boat at: g1 : p] value] == [[boat at: g2 :p] value];
                   if (nbEq >= 2) {
                      NSLog(@"Violation of social: g1=%d g2=%d p=%d  %@   -  %@",g1,g2,p,[boat at:g1:p],[boat at:g2 :p]);
                      abort();
                   }
                }
                assert (nbEq <= 1);
             }
          }
          
          for(ORInt g = Guests.low; g <= Guests.up; g++) {
             for(ORInt p1 = Periods.low; p1 <= Periods.up; p1++)
                for(ORInt p2 = p1 + 1; p2 <= Periods.up; p2++) {
                   if ([[boat at: g : p1] value] == [[boat at: g : p2] value]) {
                      printf("boat[%d,%d] = %d and boat[%d,%d] = %d \n",g,p1,g,p2,[[boat at:g : p1] value],[[boat at: g : p2] value]);
                      printf("all different is wrong \n");
                      abort();
                   }
                }
          }
          
          for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++)
             for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
                ORInt s = 0;
                for(ORInt p = Periods.low; p <= Periods.up; p++)
                   s += [[boat at: g1 : p] value] == [[boat at:g2 : p] value];
                if (s > 1) {
                   printf("guest %d and guest %d \n",g1,g2);
                   printf("social constraint is wrong \n");
                   abort();
                }
             }
          //          [cp add: [CPFactory packing: [CPFactory intVarArray: cp range: Guests with: ^id<ORIntVar>(ORInt g) { return [boat at: g : p]; }] itemSize: crew binSize:cap]];
       }
       ];
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [CPFactory shutdown];
      return 0;
   }
   return 0;
}
*/
