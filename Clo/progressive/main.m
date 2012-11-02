/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTAq, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import "ORConcretizer.h"
#import <ORModeling/ORModelTransformation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
#import <ORProgram/ORConcretizer.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      ORInt nbConfigs = 6;
      id<ORIntRange> Configs = RANGE(mdl,1,nbConfigs);
      ORInt choiceConfig = 1;
      id<ORIntRange> Hosts = RANGE(mdl,1,13);
      id<ORIntRange> Guests = RANGE(mdl,1,29);
      ORInt nbPeriods = 9;
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
      ORLong startTime = [ORRuntimeMonitor cputime];
      
      id<ORIntVarMatrix> boat = [ORFactory intVarMatrix:mdl range:Guests :Periods domain: Hosts];
      for(ORInt g = Guests.low; g <= Guests.up; g++)
         [mdl add: [ORFactory alldifferent: All(mdl,ORIntVar, p, Periods, [boat at:g :p]) ]];
      for(ORInt g1 = Guests.low; g1 <= Guests.up; g1++)
         for(ORInt g2 = g1 + 1; g2 <= Guests.up; g2++)
            [mdl add: [Sum(mdl,p,Periods,[[boat at: g1 : p] eq: [boat at: g2 : p]]) leqi: 1]];
      for(ORInt p = Periods.low; p <= Periods.up; p++)
         [mdl add: [ORFactory packing: All(mdl,ORIntVar, g, Guests, [boat at: g :p]) itemSize: crew binSize:cap]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      [cp solve: ^{
         for(ORInt p = Periods.low; p <= Periods.up; p++) {
            // This is the same search as COMET.
            [cp forall:Guests suchThat:^bool(ORInt g) { return ![[boat at:g :p] bound];}
             orderedBy:nil do:^(ORInt g) {
                [cp tryall:Hosts suchThat:^bool(ORInt h) { return [[boat at: g: p] member:h];}
                        in:^(ORInt h) {
                           [cp label:[boat at:g :p] with:h];
                        }
                 onFailure:^(ORInt h) {
                    [cp diff:[boat at:g :p] with:h];
                 }];
             }];
            // This search is 'weaker' (30,000 choices rather than ~ 5,000  on 6,1,9
            /*
            [CPLabel array: [CPFactory intVarArray: cp range: Guests with: ^id<ORIntVar>(ORInt g) { return [boat at: g : p]; } ]
                 orderedBy: ^ORInt(ORInt g) { return [[boat at:g : p] domsize];}
             ];*/
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
      [ORFactory shutdown];
   }
   return 0;
}

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
