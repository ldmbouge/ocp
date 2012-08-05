//
//  main.m
//  slab
//
//  Created by Pascal Van Hentenryck on 7/20/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
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
   id<CPSolver> cp = [CPFactory createSolver];
   FILE* dta = fopen("slab.dat","r");
   CPInt nbCap;
   fscanf(dta,"%d",&nbCap);
   nbCap++;
   id<ORIntRange> Caps = RANGE(cp,1,nbCap);
   id<CPIntArray> cap = [CPFactory intArray: cp range:Caps value: 0];
   for(CPInt i = 2; i <= nbCap; i++) {
      CPInt c;
      fscanf(dta,"%d",&c);
      [cap set: c at: i];
   }
   CPInt nbColors;
   CPInt nbOrders;
   fscanf(dta,"%d",&nbColors);
   fscanf(dta,"%d",&nbOrders);
   id<ORIntRange> Colors = RANGE(cp,1,nbColors);
   id<ORIntRange> Orders = RANGE(cp,1,nbOrders);
   id<CPIntArray> color = [CPFactory intArray: cp range:Orders value: 0];
   id<CPIntArray> weight = [CPFactory intArray: cp range:Orders value: 0];
   for(CPInt o = 1; o <= nbOrders; o++) {
      CPInt w;
      CPInt c;
      fscanf(dta,"%d",&w);
      fscanf(dta,"%d",&c);
      [weight set: w at: o];
      [color set: c at: o];
   }
   
   CPInt nbSize = 111;
   id<ORIntRange> SetOrders = RANGE(cp,1,nbSize);
   id<ORIntRange> Slabs = RANGE(cp,1,nbSize);
   id<ORIntSetArray> coloredOrder = [ORFactory intSetArray: cp range: Colors];
   for(int o = 1; o <= nbSize; o++)
      coloredOrder[[color at: o]] = [CPFactory intSet: cp];
   for(int o = 1; o <= nbSize; o++)
      [coloredOrder[[color at: o]] insert: o];
   CPInt maxCapacities = 0;
   for(int c = 1; c <= nbCap; c++)
      if ([cap at: c] > maxCapacities)
         maxCapacities = [cap at: c];
   
   id<ORIntRange> Capacities = RANGE(cp,0,maxCapacities);
   id<ORIntArray> loss = [ORFactory intArray: cp range: Capacities value: 0];
   for(CPInt c = 0; c <= maxCapacities; c++) {
      CPInt m = MAXINT;
      for(CPInt i = Caps.low; i <= Caps.up; i++)
         if ([cap at: i] >= c && [cap at: i] - c < m)
            m = [cap at: i] - c;
      [loss set: m at: c];
   }
   CPLong startTime = [CPRuntimeMonitor cputime];
   id<CPIntVarArray> slab = [CPFactory intVarArray: cp range: SetOrders domain: Slabs];
   id<CPIntVarArray> load = [CPFactory intVarArray: cp range: Slabs domain: Capacities];
   id<CPIntVar> obj = [CPFactory intVar: cp bounds: RANGE(cp,0,nbSize*maxCapacities)];
   
   [cp add: [obj eq: SUM(s,Slabs,[loss elt: [load at: s]])]];
   [cp add: [CPFactory packing: slab itemSize: weight load: load]];
   for(CPInt s = Slabs.low; s <= Slabs.up; s++)
      [cp add: [SUM(c,Colors,OR(o,coloredOrder[c],[slab[o] eqi: s])) leqi: 2]];
   [cp minimize: obj];
   
   [cp solveModel: ^{
      [ORControl forall: SetOrders suchThat: nil orderedBy: ^ORInt(ORInt o) { return [slab[o] domsize];} do: ^(ORInt o)
       {
          CPInt ms = max(0,[CPLabel maxBound: slab]);
          [cp tryall: Slabs suchThat: ^bool(CPInt s) { return s <= ms + 1; } in: ^void(CPInt s)
           {
              [cp label: slab[o] with: s];
           }
           onFailure: ^void(CPInt s)
           {
              [cp diff: slab[o] with: s];
           }
           ];
       }
       ];
      printf("\n");
      printf("obj: %d \n",[obj min]);
      printf("Slab: ");
      for(ORInt i = 1; i <= nbSize; i++)
         printf("%d ",[slab[i] value]);
      printf("\n");
   }];
   
   CPLong endTime = [CPRuntimeMonitor cputime];
   NSLog(@"Execution Time: %lld \n",endTime - startTime);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   
   @autoreleasepool {
      
      // insert code here...
      NSLog(@"Hello, World!");
      
   }
   return 0;
}

/*
int main1(int argc, const char * argv[])
{
   id<CPSolver> cp = [CPFactory createSolver];
   FILE* dta = fopen("slab.dat","r");
   CPInt nbCap;
   fscanf(dta,"%d",&nbCap);
   nbCap++;
   CPRange Caps = {1,nbCap};
   id<CPIntArray> cap = [CPFactory intArray: cp range:Caps value: 0];
   for(CPInt i = 2; i <= nbCap; i++) {
      CPInt c;
      fscanf(dta,"%d",&c);
      [cap set: c at: i];
   }
   CPInt nbColors;
   CPInt nbOrders;
   fscanf(dta,"%d",&nbColors);
   fscanf(dta,"%d",&nbOrders);
   CPRange Colors = {1,nbColors};
   CPRange Orders = {1,nbOrders};
   id<CPIntArray> color = [CPFactory intArray: cp range:Orders value: 0];
   id<CPIntArray> weight = [CPFactory intArray: cp range:Orders value: 0];
   for(CPInt o = 1; o <= nbOrders; o++) {
      CPInt w;
      CPInt c;
      fscanf(dta,"%d",&w);
      fscanf(dta,"%d",&c);
      [weight set: w at: o];
      [color set: c at: o];
   }
   
   CPInt nbSize = 111;
   CPRange IOrders = {1,nbSize};
   CPRange Slabs = {1,nbSize};
   id<ORIntSetArray> coloredOrder = [ORFactory intSetArray: cp range: Colors];
   for(int o = 1; o <= nbSize; o++)
      coloredOrder[[color at: o]] = [CPFactory intSet: cp];
   for(int o = 1; o <= nbSize; o++) 
      [coloredOrder[[color at: o]] insert: o];
   CPInt maxCapacities = 0;
   for(int c = 1; c <= nbCap; c++)
      if ([cap at: c] > maxCapacities)
         maxCapacities = [cap at: c];
   
   CPRange Capacities = {0,maxCapacities};
   id<ORIntArray> loss = [ORFactory intArray: cp range: Capacities value: 0];
   for(CPInt c = 0; c <= maxCapacities; c++) {
      CPInt m = MAXINT;
      for(CPInt i = Caps.low; i <= Caps.up; i++)
         if ([cap at: i] >= c && [cap at: i] - c < m)
            m = [cap at: i] - c;
      [loss set: m at: c];
   }
   CPLong startTime = [CPRuntimeMonitor cputime];
   id<CPIntVarArray> slab = [CPFactory intVarArray: cp range: IOrders domain: Slabs];
   id<CPIntVarArray> load = [CPFactory intVarArray: cp range: Slabs domain: Capacities];
   id<CPIntVar> obj = [CPFactory intVar: cp bounds: (ORRange){0,nbSize*maxCapacities}];
   
   [cp minimize: obj subjectTo: ^{
      [cp add: [obj eq: SUM(s,Slabs,[loss elt: [load at: s]])]];
      [cp add: [CPFactory packing: slab itemSize: weight load: load]];
      for(CPInt s = Slabs.low; s <= Slabs.up; s++)
//         [cp add: [SUM(c,Colors,[ISSUM(o,coloredOrder[c],[slab[o] eqi: c]) gti: 0]) lti: 3]];
         [cp add: [SUM(c,Colors,OR(o,coloredOrder[c],[slab[o] eqi: s])) leqi: 2]];
   }
   using:^{
      
      [cp forall: IOrders
        suchThat: nil
         orderedBy: ^ORInt(ORInt o) { return [slab[o] domsize];}
                do: ^(ORInt o)
       {
          CPInt ms = max(0,[CPLabel maxBound: slab]);
          [cp tryall: Slabs suchThat: ^bool(CPInt s) { return s <= ms + 1; } in: ^void(CPInt s)
           {
              [cp label: slab[o] with: s];
           }
           onFailure: ^void(CPInt s)
           {
              [cp diff: slab[o] with: s];
           }
           ];
       }
       ];
   
      printf("\n");
      printf("obj: %d \n",[obj min]);
      printf("Slab: ");
      for(ORInt i = 1; i <= nbSize; i++)
         printf("%d ",[slab[i] value]);
      printf("\n");
   }
   ];
   CPLong endTime = [CPRuntimeMonitor cputime];
   NSLog(@"Execution Time: %lld \n",endTime - startTime);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
                             
   @autoreleasepool {
       
       // insert code here...
       NSLog(@"Hello, World!");
       
   }
    return 0;
}
*/
int main1(int argc, const char * argv[])
{
   id<CPSolver> cp = [CPFactory createSolver];
   FILE* dta = fopen("slab.dat","r");
   CPInt nbCap;
   fscanf(dta,"%d",&nbCap);
   nbCap++;
   id<ORIntRange> Caps = RANGE(cp,1,nbCap);
   id<CPIntArray> cap = [CPFactory intArray: cp range:Caps value: 0];
   for(CPInt i = 2; i <= nbCap; i++) {
      CPInt c;
      fscanf(dta,"%d",&c);
      [cap set: c at: i];
   }
   CPInt nbColors;
   CPInt nbOrders;
   fscanf(dta,"%d",&nbColors);
   fscanf(dta,"%d",&nbOrders);
   id<ORIntRange> Colors = RANGE(cp,1,nbColors);
   id<ORIntRange> Orders = RANGE(cp,1,nbOrders);
   id<CPIntArray> color = [CPFactory intArray: cp range:Orders value: 0];
   id<CPIntArray> weight = [CPFactory intArray: cp range:Orders value: 0];
   for(CPInt o = 1; o <= nbOrders; o++) {
      CPInt w;
      CPInt c;
      fscanf(dta,"%d",&w);
      fscanf(dta,"%d",&c);
      [weight set: w at: o];
      [color set: c at: o];
   }
   
   CPInt nbSize = 111;
   id<ORIntRange> SetOrders = RANGE(cp,1,nbSize);
   id<ORIntRange> Slabs = RANGE(cp,1,nbSize);
   id<ORIntSetArray> coloredOrder = [ORFactory intSetArray: cp range: Colors];
   for(int o = 1; o <= nbSize; o++)
      coloredOrder[[color at: o]] = [CPFactory intSet: cp];
   for(int o = 1; o <= nbSize; o++)
      [coloredOrder[[color at: o]] insert: o];
   CPInt maxCapacities = 0;
   for(int c = 1; c <= nbCap; c++)
      if ([cap at: c] > maxCapacities)
         maxCapacities = [cap at: c];
   
   id<ORIntRange> Capacities = RANGE(cp,0,maxCapacities);
   id<ORIntArray> loss = [ORFactory intArray: cp range: Capacities value: 0];
   for(CPInt c = 0; c <= maxCapacities; c++) {
      CPInt m = MAXINT;
      for(CPInt i = Caps.low; i <= Caps.up; i++)
         if ([cap at: i] >= c && [cap at: i] - c < m)
            m = [cap at: i] - c;
      [loss set: m at: c];
   }
   CPLong startTime = [CPRuntimeMonitor cputime];
   id<CPIntVarArray> slab = [CPFactory intVarArray: cp range: SetOrders domain: Slabs];
   id<CPIntVarArray> load = [CPFactory intVarArray: cp range: Slabs domain: Capacities];
   id<CPIntVar> obj = [CPFactory intVar: cp bounds: RANGE(cp,0,nbSize*maxCapacities)];
   id<CPUniformDistribution> distr = [CPFactory uniformDistribution: cp range: RANGE(cp,1,100)];
   [cp minimize: obj subjectTo: ^{
      [cp add: [obj eq: SUM(s,Slabs,[loss elt: [load at: s]])]];
      [cp add: [CPFactory packing: slab itemSize: weight load: load]];
      for(CPInt s = Slabs.low; s <= Slabs.up; s++)
         //         [cp add: [SUM(c,Colors,[ISSUM(o,coloredOrder[c],[slab[o] eqi: c]) gti: 0]) lti: 3]];
         [cp add: [SUM(c,Colors,OR(o,coloredOrder[c],[slab[o] eqi: s])) leqi: 2]];
   }
          using:^{
             
             [cp repeat: ^{
                [cp limitFailures: 100 in: ^{
                   [cp forall: SetOrders suchThat: nil orderedBy: ^ORInt(ORInt o) { return [slab[o] domsize];} do: ^(ORInt o)
                    {
                       //                    printf("o: %d \n",o);
                       [CPLabel var: slab[o]];
                    }
                    ];
                   //               NSLog(@"%@",slab);
                }
                 ];
             }
               onRepeat: ^{
                  id<ORSolution> solution = [cp solution];
                  for(CPInt i = 1; i <= nbSize; i++) {
                     if ([distr next] <= 90)
                        [cp label: slab[i] with: [solution intValue: slab[i]]];
                  }
               }
              ];
             printf("\n");
             printf("obj: %d \n",[obj min]);
             printf("Slab: ");
             for(ORInt i = 1; i <= nbSize; i++)
                printf("%d ",[slab[i] value]);
             printf("\n");
          }
    ];
   CPLong endTime = [CPRuntimeMonitor cputime];
   NSLog(@"Execution Time: %lld \n",endTime - startTime);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   
   @autoreleasepool {
      
      // insert code here...
      NSLog(@"Hello, World!");
      
   }
   return 0;
}

// This is the real main; pvh is experimenting with modeling
int realmain(int argc, const char * argv[])
{
   id<CPSolver> cp = [CPFactory createSolver];
   FILE* dta = fopen("slab.dat","r");
   CPInt nbCap;
   fscanf(dta,"%d",&nbCap);
   nbCap++;
   id<ORIntRange> Caps = RANGE(cp,1,nbCap);
   id<CPIntArray> cap = [CPFactory intArray: cp range:Caps value: 0];
   for(CPInt i = 2; i <= nbCap; i++) {
      CPInt c;
      fscanf(dta,"%d",&c);
      [cap set: c at: i];
   }
   CPInt nbColors;
   CPInt nbOrders;
   fscanf(dta,"%d",&nbColors);
   fscanf(dta,"%d",&nbOrders);
   id<ORIntRange> Colors = RANGE(cp,1,nbColors);
   id<ORIntRange> Orders = RANGE(cp,1,nbOrders);
   id<CPIntArray> color = [CPFactory intArray: cp range:Orders value: 0];
   id<CPIntArray> weight = [CPFactory intArray: cp range:Orders value: 0];
   for(CPInt o = 1; o <= nbOrders; o++) {
      CPInt w;
      CPInt c;
      fscanf(dta,"%d",&w);
      fscanf(dta,"%d",&c);
      [weight set: w at: o];
      [color set: c at: o];
   }
   
   CPInt nbSize = 111;
   id<ORIntRange> SetOrders = RANGE(cp,1,nbSize);
   id<ORIntRange> Slabs = RANGE(cp,1,nbSize);
   id<ORIntSetArray> coloredOrder = [ORFactory intSetArray: cp range: Colors];
   for(int o = 1; o <= nbSize; o++)
      coloredOrder[[color at: o]] = [CPFactory intSet: cp];
   for(int o = 1; o <= nbSize; o++)
      [coloredOrder[[color at: o]] insert: o];
   CPInt maxCapacities = 0;
   for(int c = 1; c <= nbCap; c++)
      if ([cap at: c] > maxCapacities)
         maxCapacities = [cap at: c];
   
   id<ORIntRange> Capacities = RANGE(cp,0,maxCapacities);
   id<ORIntArray> loss = [ORFactory intArray: cp range: Capacities value: 0];
   for(CPInt c = 0; c <= maxCapacities; c++) {
      CPInt m = MAXINT;
      for(CPInt i = Caps.low; i <= Caps.up; i++)
         if ([cap at: i] >= c && [cap at: i] - c < m)
            m = [cap at: i] - c;
      [loss set: m at: c];
   }
   CPLong startTime = [CPRuntimeMonitor cputime];
   id<CPIntVarArray> slab = [CPFactory intVarArray: cp range: SetOrders domain: Slabs];
   id<CPIntVarArray> load = [CPFactory intVarArray: cp range: Slabs domain: Capacities];
   id<CPIntVar> obj = [CPFactory intVar: cp bounds: RANGE(cp,0,nbSize*maxCapacities)];
   
//   id<ORIntSet> SetSlabs = [ORFactory intSet: cp];
//   [Slabs iterate: ^void(ORInt e) { [SetSlabs insert: e]; } ];
  
   [cp minimize: obj subjectTo: ^{
      [cp add: [obj eq: SUM(s,Slabs,[loss elt: [load at: s]])]];
      [cp add: [CPFactory packing: slab itemSize: weight load: load]];
      for(CPInt s = Slabs.low; s <= Slabs.up; s++)
         //         [cp add: [SUM(c,Colors,[ISSUM(o,coloredOrder[c],[slab[o] eqi: c]) gti: 0]) lti: 3]];
         [cp add: [SUM(c,Colors,OR(o,coloredOrder[c],[slab[o] eqi: s])) leqi: 2]];
      }
      using:^{
 
         [ORControl forall: SetOrders suchThat: nil orderedBy: ^ORInt(ORInt o) { return [slab[o] domsize];} do: ^(ORInt o)
          {
             CPInt ms = max(0,[CPLabel maxBound: slab]);
             [cp tryall: Slabs suchThat: ^bool(CPInt s) { return s <= ms + 1; } in: ^void(CPInt s)
              {
                 [cp label: slab[o] with: s];
              }
              onFailure: ^void(CPInt s)
              {
                 [cp diff: slab[o] with: s];
              }
              ];
          }
          ];
         printf("\n");
         printf("obj: %d \n",[obj min]);
         printf("Slab: ");
         for(ORInt i = 1; i <= nbSize; i++)
            printf("%d ",[slab[i] value]);
         printf("\n");
      }
    ];
   CPLong endTime = [CPRuntimeMonitor cputime];
   NSLog(@"Execution Time: %lld \n",endTime - startTime);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   
   @autoreleasepool {
      
      // insert code here...
      NSLog(@"Hello, World!");
      
   }
   return 0;
}


