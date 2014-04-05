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

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> mdl = [ORFactory createModel];
         ORInt nbConfigs = 6;
         id<ORIntRange> Configs = RANGE(mdl,1,nbConfigs);
         ORInt choiceConfig = [args size];
         ORInt nbPeriods    = [args nArg];
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
         id<ORIntVarMatrix> boat = [ORFactory intVarMatrix:mdl range:Guests :Periods domain: Hosts];
         id<ORIntVarMatrix> d    = [ORFactory intVarMatrix:mdl range:Guests :Guests domain:RANGE(mdl,-1,[Periods size])];
         id<ORIdMatrix>        p = [ORFactory idMatrix:mdl range:Guests :Guests];
         id<ORIntVarArray>     z = [ORFactory intVarArray:mdl range:RANGE(mdl,0,[Guests size] * ([Guests size] -1)/2 - 1)
                                                   domain:RANGE(mdl,FDMININT,FDMAXINT)];
         id<ORIdArray> ca = [ORFactory idArray:mdl range:z.range];
         ORInt o = 0;
         for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++) {
            for(ORInt g2 = Guests.low; g2 <= g1; g2++) {
               [mdl add:[[d at:g1 :g2] eq:@0]];
               [p set:[ORFactory floatParam:mdl initially:0.0] at:g1 :g2];
            }
            
            for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
               id<ORIntParam> fp = nil;
               [p set:fp = [ORFactory intParam:mdl initially:1] at:g1 :g2];
               [mdl add: [[d at:g1 :g2] eq: [Sum(mdl,p,Periods,[[boat at: g1 : p] eq: [boat at: g2 : p]]) sub: @1]]];
               ca[o] = [mdl add: [ORFactory intWeightedVar:z[o] equal:fp times:[d at:g1 :g2]]];
               o++;
            }
         }
         [mdl minimize:Sum(mdl, k, z.range, z[k])];
                   
         for(ORInt g = Guests.low; g <= Guests.up; g++)
            [notes dc:[mdl add: [ORFactory alldifferent: All(mdl,ORIntVar, p, Periods, [boat at:g :p]) ]]];
         
//         for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++)
//            for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++)
//               [mdl add: [Sum(mdl,p,Periods,[[boat at: g1 : p] eq: [boat at: g2 : p]]) leq: @1]];
         
         for(ORInt p = Periods.low; p <= Periods.up; p++) {
            [mdl add: [ORFactory packing:mdl item:All(mdl,ORIntVar, g, Guests, [boat at: g :p]) itemSize: crew binSize:cap]];
         }
         
         
         id<CPProgram> cp = [args makeProgram:mdl annotation:notes];
         ORFloat rate = [args restartRate];
         __block ORInt lim = 1;
         __block ORFloat agility = 1000.0;
         __block ORFloat s = 0.0;
         __block ORFloat sum = 0.0;
         __block ORInt sat = 1;
         __block id<ORSolution> sol = nil;
         NSLog(@"The limit starts at: %d  (%f)",lim,rate);
         while (sat != 0) {
            [cp solve: ^{
               id<ORSolution> incumbent = [[cp solutionPool] best];
               [[cp solutionPool]  emptyPool];
               [cp limitSolutions: lim in: ^{
//                     [cp once:^{
//                        [cp forall:ca.range suchThat:^bool(ORInt i) { return [cp intValue:[ca[i] weight]] > 1;}
//                         orderedBy: ^ORInt(ORInt i) { return (ORInt) - [cp intValue:[ca[i] weight]];}
//                                do: ^(ORInt i) {
//                                   id<ORIntVar> x = [ca[i] x];
//                                   [cp tryall:RANGE(cp,1,x.domain.up) suchThat:nil in:^(ORInt r) {
//                                      [cp lthen:x with: r];
//                                   }];
//                                }
//                         ];
//                     }];
                     for(ORInt p = Periods.low; p <= Periods.up; p++) {
                        [cp forall:Guests suchThat:^bool(ORInt g) { return ![cp bound:[boat at:g :p]];}
                         orderedBy: nil // ^ORInt(ORInt g) { return [cp domsize:[boat at:g :p]];}
                                do:^(ORInt g) {
                                   ORInt inSol = [incumbent intValue:[boat at:g :p]];
                                   if (incumbent && [cp member:inSol in:[boat at:g :p]]) {
                                      [cp try:^{
                                         [cp label:[boat at:g :p] with:inSol];
                                      } or:^{
                                         [cp tryall:Hosts suchThat:^bool(ORInt h) { return [cp member:h in:[boat at: g: p]];}
                                                 in:^(ORInt h) {
                                                    [cp label:[boat at:g :p] with:h];
                                                 }
                                          onFailure:^(ORInt h) {
                                             [cp diff:[boat at:g :p] with:h];
                                          }];
                                      }];
                                   } else {
                                      [cp tryall:Hosts suchThat:^bool(ORInt h) { return [cp member:h in:[boat at: g: p]];}
                                              in:^(ORInt h) {
                                                 [cp label:[boat at:g :p] with:h];
                                              }
                                       onFailure:^(ORInt h) {
                                          [cp diff:[boat at:g :p] with:h];
                                       }];
                                   }
                                }];
                        
                     }
                     ORLong endTime = [ORRuntimeMonitor cputime];
                     NSLog(@"Execution Time: %lld \n",endTime - startTime);
                     sol = [cp captureSolution];
                     NSLog(@"INSIDE Objective: %@",[sol objectiveValue]);
               }];
               NSLog(@"Solver status: %@\n",cp);
               NSLog(@"Objective: %@",[sol objectiveValue]);
               sum = 0.0;
               sat = 0;
               for(ORInt i=ca.range.low;i <= ca.range.up;i++) {
                  ORInt   gi = [sol intValue:[ca[i] x]];
                  sat += max(0,gi);
                  sum += gi*gi;
               }
               NSLog(@"SAT? : %d",sat);
               s = agility / sum;
               for(ORInt i=ca.range.low;i <= ca.range.up;i++) {
                  ORInt   gi = [sol intValue:[ca[i] x]];
                  ORFloat li = [cp intValue:[ca[i] weight]];
                  li = max(0,li + s * gi);
                  [cp paramInt:[ca[i] weight] setValue:li];
               }
               for(ORInt i=ca.range.low;i <= ca.range.up;i++) {
                  ORInt gi = [sol intValue:[ca[i] x]];
                  ORFloat p = [cp intValue:[ca[i] weight]];
                  if (gi > 0)
                     NSLog(@"param(%d) = %lf  gradient was: %d",i,p,gi);
               }
               //lim++;
            }];
         }
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

