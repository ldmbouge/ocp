/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
#import <ORProgram/ORProgram.h>
#import <ORProgram/ORProgramFactory.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> mdl = [ORFactory createModel];
         FILE* dta = fopen("slab.dat","r");
         ORInt nbCap;
         fscanf(dta,"%d",&nbCap);
         nbCap++;
         id<ORIntRange> Caps = RANGE(mdl,1,nbCap);
         id<ORIntArray> cap = [ORFactory intArray: mdl range:Caps value: 0];
         for(ORInt i = 2; i <= nbCap; i++) {
            ORInt c;
            fscanf(dta,"%d",&c);
            [cap set: c at: i];
         }
         ORInt nbColors;
         ORInt nbOrders;
         fscanf(dta,"%d",&nbColors);
         NSLog(@"Nb Colors: %d",nbColors);
         fscanf(dta,"%d",&nbOrders);
         id<ORIntRange> Colors = RANGE(mdl,1,nbColors);
         id<ORIntRange> Orders = RANGE(mdl,1,nbOrders);
         id<ORIntArray> color = [ORFactory intArray: mdl range:Orders value: 0];
         id<ORIntArray> weight = [ORFactory intArray: mdl range:Orders value: 0];
         for(ORInt o = 1; o <= nbOrders; o++) {
            ORInt w;
            ORInt c;
            fscanf(dta,"%d",&w);
            fscanf(dta,"%d",&c);
            [weight set: w at: o];
            [color set: c at: o];
         }
         
         ORInt nbSize = 111;
         id<ORIntRange> SetOrders = RANGE(mdl,1,nbSize);
         id<ORIntRange> Slabs = RANGE(mdl,1,nbSize);
         id<ORIntSetArray> coloredOrder = [ORFactory intSetArray: mdl range: Colors];
         for(int o = 1; o <= nbSize; o++)
            coloredOrder[[color at: o]] = [ORFactory intSet: mdl];
         for(int o = 1; o <= nbSize; o++)
            [coloredOrder[[color at: o]] insert: o];
         ORInt maxCapacities = 0;
         for(int c = 1; c <= nbCap; c++)
            if ([cap at: c] > maxCapacities)
               maxCapacities = [cap at: c];
         
         id<ORIntRange> Capacities = RANGE(mdl,0,maxCapacities);
         id<ORIntArray> loss = [ORFactory intArray: mdl range: Capacities value: 0];
         for(ORInt c = 0; c <= maxCapacities; c++) {
            ORInt m = MAXINT;
            for(ORInt i = Caps.low; i <= Caps.up; i++)
               if ([cap at: i] >= c && [cap at: i] - c < m)
                  m = [cap at: i] - c;
            [loss set: m at: c];
         }
         id<ORIntVarArray> slab = [ORFactory intVarArray: mdl range: SetOrders domain: Slabs];
         id<ORIntVarArray> load = [ORFactory intVarArray: mdl range: Slabs domain: Capacities];
         id<ORIntVar> obj = [ORFactory intVar: mdl domain: RANGE(mdl,0,nbSize*maxCapacities)];
         
         [mdl add: [obj eq: Sum(mdl,s,Slabs,[loss elt: [load at: s]])]];
         [mdl add: [ORFactory packing:mdl item:slab itemSize: weight load: load]];
         for(ORInt s = Slabs.low; s <= Slabs.up; s++)
            [mdl add: [Sum(mdl,c,Colors,Or(mdl,o,coloredOrder[c],[slab[o] eq: @(s)])) leq: @2]];
         [mdl minimize: obj];
         
         id<CPProgram> cp  = [args makeProgram:mdl];
         [cp solve: ^{
            NSLog(@"In the search ... ");
            [cp forall: SetOrders suchThat: nil orderedBy: ^ORInt(ORInt o) { return [cp domsize:slab[o]];} do: ^(ORInt o)
             {
                ORInt ms = max(0,[cp maxBound: slab]);
                [cp tryall: Slabs suchThat: ^bool(ORInt s) { return s <= ms + 1 && [cp member:s in:slab[o]]; } in: ^void(ORInt s)
                 {
                    [cp label: slab[o] with: s];
                 }
                 onFailure: ^void(ORInt s)
                 {
                    [cp diff: slab[o] with: s];
                 }
                 ];
             }
             ];
            printf("obj: %d \n",[cp intValue:obj]);
         }];
         
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}
