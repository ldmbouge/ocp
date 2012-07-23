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
   id<CP> cp = [CPFactory createSolver];
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
//   NSLog(@"%@",weight);
//   NSLog(@"%@",color);
//   NSLog(@"%@",cap);
   
   CPInt nbSize = 30;
   CPRange IOrders = {1,nbSize};
   CPRange Slabs = {1,nbSize};
   id<ORIntSetArray> coloredOrder = [ORFactory intSetArray: cp range: Colors];
   for(int o = 1; o <= nbSize; o++)
      coloredOrder[[color at: o]] = [CPFactory intSet: cp];
   for(int o = 1; o <= nbSize; o++) 
      [coloredOrder[[color at: o]] insert: o];
//   NSLog(@"%@",coloredOrder);
   CPInt maxCapacities = 0;
   for(int c = 1; c <= nbCap; c++)
      if ([cap at: c] > maxCapacities)
         maxCapacities = [cap at: c];
   
   CPRange Capacities = {0,maxCapacities};
   id<ORIntArray> loss = [ORFactory intArray: cp range: Capacities value: 0];
   for(CPInt c = 0; c <= maxCapacities; c++) {
      CPInt m = MAXINT;
      for(CPInt i = Caps.low; i <= Caps.up; i++)
         if ([cap at: i] < m)
            m = [cap at: i];
      [loss set: m at: c];
   }
   id<CPIntVarArray> slab = [CPFactory intVarArray: cp range: IOrders domain: Slabs];
   id<CPIntVarArray> load = [CPFactory intVarArray: cp range: Slabs domain: Capacities];
   id<CPIntVar> obj = [CPFactory intVar: cp bounds: (ORRange){0,nbSize*maxCapacities}];
   
   [cp minimize: obj subjectTo: ^{
      [cp add: [obj eq: SUM(s,Slabs,[loss elt: [load at: s]])]];
      [cp add: [CPFactory packing: slab itemSize: weight load: load]];
      for(CPInt s = Slabs.low; s <= Slabs.up; s++)
         [cp add: [SUM(c,Colors,[ISSUM(o,coloredOrder[c],[slab[o] eqi: c]) gti: 0]) lti: 3]];
   }
   using:^{
      [cp forrange: IOrders
        suchThat: nil
         orderedBy: ^ORInt(ORInt o) { return [slab[o] domsize];}
                do: ^(ORInt o)
       {
          [CPLabel var: slab[o]];
       }
       ];
       NSLog(@"%@",slab);
   }
   ];
   
                             
   @autoreleasepool {
       
       // insert code here...
       NSLog(@"Hello, World!");
       
   }
    return 0;
}

