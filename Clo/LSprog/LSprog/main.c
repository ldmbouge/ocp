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

