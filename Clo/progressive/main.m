/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
   ORInt nbPeriods = 2;
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
   
//   NSLog(@"%@",config);
   
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
//   NSLog(@"%@",cap);
//   NSLog(@"%@",crew);
   
   id<CPIntVarMatrix> boat = [CPFactory intVarMatrix:cp range:Guests :Periods domain: Hosts];
   [cp solve:
    ^{
       for(CPInt g = Guests.low; g <= Guests.up; g++)
          [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: Periods with: ^id<CPIntVar>(CPInt p) { return [boat at: g : p]; }]]];
       for(CPInt g1 = Guests.low; g1 <= Guests.up; g1++)
          for(CPInt g2 = g1 + 1; g2 <= Guests.up; g2++) {
             id<CPExpr> e = SUM(p,Periods,[[boat at: g1 : p] eq: [boat at: g2 : p]]);
             [cp add: e leqi: 1];
          }
    }
       using:
    ^{
       for(CPInt p = Periods.low; p <= Periods.up; p++)
          [CPLabel array: [CPFactory intVarArray: cp range: Guests with: ^id<CPIntVar>(CPInt g) { return [boat at: g : p]; }]
               orderedBy: ^CPInt(CPInt g) { return [[boat at:g : p] domsize];}];
       for(CPInt g = Guests.low; g <= Guests.up; g++) {
          for(CPInt p = Periods.low; p <= Periods.up; p++)
             printf("boat[%2d,%2d] = %2d   ",g,p,[[boat at: g : p] value]);
          printf("\n");
       }
    }
    ];

   @autoreleasepool {
       
       // insert code here...
       NSLog(@"Hello, World!");
       
   }
    return 0;
}

