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

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}

int main(int argc, const char * argv[])
{
   const char* fName = argc >=2 ? argv[1] : "slab.dat";
   id<ORModel> model = [ORFactory createModel];
   FILE* dta = fopen(fName,"r");
   ORInt nbCap;
   fscanf(dta,"%d",&nbCap);
   nbCap++;
   id<ORIntRange> Caps = RANGE(model,1,nbCap);
   id<ORIntArray> cap = [ORFactory intArray: model range:Caps value: 0];
   for(ORInt i = 2; i <= nbCap; i++) {
      ORInt c;
      fscanf(dta,"%d",&c);
      [cap set: c at: i];
   }
   ORInt nbColors;
   ORInt nbOrders;
   fscanf(dta,"%d",&nbColors);
   fscanf(dta,"%d",&nbOrders);
   id<ORIntRange> Colors = RANGE(model,1,nbColors);
   id<ORIntRange> Orders = RANGE(model,1,nbOrders);
   id<ORIntArray> color = [ORFactory intArray: model range:Orders value: 0];
   id<ORIntArray> weight = [ORFactory intArray: model range:Orders value: 0];
   for(ORInt o = 1; o <= nbOrders; o++) {
      ORInt w;
      ORInt c;
      fscanf(dta,"%d",&w);
      fscanf(dta,"%d",&c);
      [weight set: w at: o];
      [color set: c at: o];
   }
   
   ORInt nbSize = nbOrders;
   id<ORIntRange> SetOrders = RANGE(model,1,nbSize);
   id<ORIntRange> Slabs = RANGE(model,1,nbSize);
   id<ORIntSetArray> coloredOrder = [ORFactory intSetArray: model range: Colors];
   for(int o = 1; o <= nbSize; o++)
      coloredOrder[[color at: o]] = [ORFactory intSet: model];
   for(int o = 1; o <= nbSize; o++)
      [coloredOrder[[color at: o]] insert: o];
   ORInt maxCapacities = 0;
   for(int c = 1; c <= nbCap; c++)
      if ([cap at: c] > maxCapacities)
         maxCapacities = [cap at: c];
   
   id<ORIntRange> Capacities = RANGE(model,0,maxCapacities);
   id<ORIntArray> loss = [ORFactory intArray: model range: Capacities value: 0];
   for(ORInt c = 0; c <= maxCapacities; c++) {
      ORInt m = MAXINT;
      for(ORInt i = Caps.low; i <= Caps.up; i++)
         if ([cap at: i] >= c && [cap at: i] - c < m)
            m = [cap at: i] - c;
      [loss set: m at: c];
   }
   [ORStreamManager setRandomized];
   id<ORUniformDistribution> d = [ORFactory uniformDistribution:model range:RANGE(model,1,100)];
   ORLong startTime = [ORRuntimeMonitor wctime];
   id<ORIntVarArray> slab = [ORFactory intVarArray: model range: SetOrders domain: Slabs];
   id<ORIntVarArray> load = [ORFactory intVarArray: model range: Slabs domain: Capacities];
   
   [model add: [ORFactory packing: slab itemSize: weight load: load]];
   for(ORInt s = Slabs.low; s <= Slabs.up; s++)
      [model add: [Sum(model,c,Colors,Or(model,o,coloredOrder[c],[slab[o] eq: @(s)])) leq: @2]];
   id<ORObjectiveFunction> obj = [model minimize: Sum(model,s,Slabs,[loss elt: [load at: s]])];
   id<CPProgram> cp = [ORFactory createCPProgram: model];
   __block ORInt lim = 64;
   __block BOOL improved = NO;
   [cp solve: ^{
      printf(" Starting search \n");
      [cp repeat:^{
         improved = NO;
         [cp limitFailures:lim in:^{
            [cp forall:SetOrders suchThat:^bool(ORInt o) { return ![cp bound: slab[o]];}
             orderedBy:^ORInt(ORInt o) { return ([cp domsize: slab[o]] << 16) - [weight at:o];}
                    do: ^(ORInt o){
                       ORInt ms = max(0,[CPUtilities maxBound: slab]);
                       [cp tryall: Slabs suchThat: ^bool(ORInt s) { return s <= ms+1 && [cp member: s in: slab[o]]; }
                               in: ^void(ORInt s) {
                           [cp label: slab[o] with: s];
                        }
                        onFailure: ^void(ORInt s) {
                           [cp diff: slab[o] with: s];
                        }
                        ];
                    }];
         }];
      } onRepeat:^{
         id<ORSolution> s = [[cp solutionPool] best];
         if (s!=nil) {
            [cp once:^{
               [cp tryall:RANGE(cp,0,1000) suchThat:nil in:^(ORInt k) {
                  [SetOrders enumerateWithBlock:^(ORInt i) {
                     if ([d next]  <= 90 - 10 * i) {
                        [cp add:[slab[i] eq:@([s intValue:slab[i]])]];
                     }
                  }];
               }];
            }];
            if (!improved)
               lim *= 2;
            NSLog(@"New limit: %d",lim);
            //[[cp objective] tightenPrimalBound:[s objectiveValue]];
         }
      }];
      NSLog(@"Objective value: %@",[obj value]);
      improved = YES;
   }];
   id<ORCPSolution> sol = [[cp solutionPool] best];
   for(ORInt i = [SetOrders low]; i <= [SetOrders up]; i++)
      printf("slab[%d] = %d \n",i,[sol intValue: slab[i]]);
   printf("\n");
   ORLong endTime = [ORRuntimeMonitor wctime];
   NSLog(@"Execution Time (WC): %lld \n",endTime - startTime);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [ORFactory shutdown];
   return 0;
}




