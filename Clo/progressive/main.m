/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTAq, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORFactory.h>
#import "objcp/CPFactory.h"
#import "objcp/CPConstraint.h"
#import <objcp/CP.h>
#import "objcp/CPLabel.h"

int main(int argc, const char * argv[])
{
   ORInt nbConfigs = 6;
   ORRange Configs = (ORRange){1,nbConfigs};
   ORInt choiceConfig = 1;
  
   ORRange Hosts = (ORRange){1,13};
   ORRange Guests = (ORRange){1,29};
   ORInt nbPeriods = 9;
   ORRange Periods = (ORRange){1,nbPeriods};
   
   id<CP> cp = [CPFactory createSolver];
   id<CPIntArray> cap = [CPFactory intArray: cp range: Hosts value: 0];
   id<CPIntArray> crew = [CPFactory intArray: cp range: Guests value: 0];
   
   id<ORIntSetArray> config = [ORFactory intSetArray: cp range: Configs];
   config[1] = COLLECT(cp,i,RANGE(1,12),i);
   [config[1] insert: 16];
   config[2] = COLLECT(cp,i,RANGE(1,13),i);
   config[3] = COLLECT(cp,i,RANGE(3,13),i);
   [config[3] insert: 1];
   [config[3] insert: 19];
   config[4] = COLLECT(cp,i,RANGE(3,13),i);
   [config[4] insert: 25];
   [config[4] insert: 26];
   config[5] = COLLECT(cp,i,RANGE(1,11),i);
   [config[5] insert: 19];
   [config[5] insert: 21];
   config[6] = COLLECT(cp,i,RANGE(1,9),i);
   for(ORInt i = 16; i <= 19; i++)
      [config[6] insert: i];
   
   NSLog(@"%@",config);
   
   FILE* dta = fopen("progressive.txt","r");
   CPInt h = 1;
   CPInt g = 1;
   for(CPInt i = 1; i <= 42; i++) {
      CPInt id, bcap, sz;
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
   CPLong startTime = [CPRuntimeMonitor cputime];
   
   id<CPIntVarMatrix> boat = [CPFactory intVarMatrix:cp range:Guests :Periods domain: Hosts];
   [cp solve:
    ^{
       for(CPInt g = Guests.low; g <= Guests.up; g++) {
          [cp add: [CPFactory alldifferent: ALL(CPIntVar, p, Periods, [boat at:g :p]) ]];
       }
       
       for(CPInt g1 = Guests.low; g1 <= Guests.up; g1++)
         for(CPInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
            [cp add: SUM(p,Periods,[[boat at: g1 : p] eq: [boat at: g2 : p]]) leqi: 1];
         }
        for(CPInt p = Periods.low; p <= Periods.up; p++)
           [cp add: [CPFactory packing: ALL(CPIntVar, g, Guests, [boat at: g :p]) itemSize: crew binSize:cap]];
    }
       using:
    ^{
       for(CPInt p = Periods.low; p <= Periods.up; p++) {          
          [cp forrange:Guests filteredBy:^bool(ORInt g) { return ![[boat at:g :p] bound];}
             orderedBy:^ORInt(ORInt g) { return g;}//[[boat at:g :p] domsize];}
                    do:^(ORInt g) {
                       //NSLog(@"BRANCHING ON: <p,g>:<%d,%d>",p,g);
                       [cp tryall:Hosts filteredBy:^bool(ORInt h) {
                          return [[boat at:g :p] member:h];
                       } in:^(ORInt h) {
                          [cp label:[boat at:g :p] with:h];
                       } onFailure:^(ORInt h) {
                          [cp diff:[boat at:g :p] with:h];
                       }];
                    }
           ];
       }
       CPLong endTime = [CPRuntimeMonitor cputime];
       
       for(CPInt p = Periods.low; p <= Periods.up; p++) {
          NSMutableString* line = [[NSMutableString alloc] initWithCapacity:64];
          [line appendFormat:@"p=%2d : ",p];
          for(CPInt g = Guests.low; g <= Guests.up; g++) {
             if ([[boat at: g : p] bound])
                [line appendFormat:@"%2d ",[[boat at: g :p] value]];
             else [line appendFormat:@"%@",[boat at: g :p] ];
          }
          NSLog(@"%@",line);
          [line release];
       }
       NSLog(@"Execution Time: %lld \n",endTime - startTime);
       /*
       for(CPInt p = Periods.low; p <= Periods.up; p++)
         [cp add: [CPFactory packing: [CPFactory intVarArray: cp range: Guests with: ^id<CPIntVar>(CPInt g) { return [boat at: g : p]; }] itemSize: crew binSize:cap]];
        */
       int use[14];
       for(CPInt p = Periods.low; p <= Periods.up; p++) {
          for(CPInt h = 1; h <= 13; h++)
             use[h] = 0;
          
          for(CPInt g = Guests.low; g <= Guests.up; g++)
             use[[[boat at: g : p] value]] += [crew at: g];
          for(CPInt h = 1; h <= 13; h++)
             if (use[h] > [cap at: h]) {
                printf("Bad capacity at %d - %d: %d instead of %d \n",p,h,use[h],[cap at: h]);
                abort();
             }
       }
       for(CPInt g1 = Guests.low; g1 <= Guests.up; g1++) {
          for(CPInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
             CPInt nbEq = 0;
             for(CPInt p=Periods.low;p <= Periods.up;p++) {
                nbEq += [[boat at: g1 : p] value] == [[boat at: g2 :p] value];
                if (nbEq >= 2) {
                   NSLog(@"Violation of social: g1=%d g2=%d p=%d  %@   -  %@",g1,g2,p,[boat at:g1:p],[boat at:g2 :p]);
                   abort();
                }
             }
             assert (nbEq <= 1);
          }
       }

       for(CPInt g = Guests.low; g <= Guests.up; g++) {
          for(CPInt p1 = Periods.low; p1 <= Periods.up; p1++)
             for(CPInt p2 = p1 + 1; p2 <= Periods.up; p2++) {
                if ([[boat at: g : p1] value] == [[boat at: g : p2] value]) {
                   printf("boat[%d,%d] = %d and boat[%d,%d] = %d \n",g,p1,g,p2,[[boat at:g : p1] value],[[boat at: g : p2] value]);
                   printf("all different is wrong \n");
                   abort();
                }
             }
       }
   
       for(CPInt g1 = Guests.low; g1 <= Guests.up; g1++)
          for(CPInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
             CPInt s = 0;
             for(CPInt p = Periods.low; p <= Periods.up; p++)
                s += [[boat at: g1 : p] value] == [[boat at:g2 : p] value];
             if (s > 1) {
                printf("guest %d and guest %d \n",g1,g2);
                printf("social constraint is wrong \n");
                abort();
             }
          }
      //          [cp add: [CPFactory packing: [CPFactory intVarArray: cp range: Guests with: ^id<CPIntVar>(CPInt g) { return [boat at: g : p]; }] itemSize: crew binSize:cap]];
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;


   @autoreleasepool {
       
       // insert code here...
       NSLog(@"Hello, World!");
       
   }
    return 0;
}

