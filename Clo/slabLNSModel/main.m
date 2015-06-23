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
#import <ORFoundation/ORFoundation.h>
#import <ORProgram/ORProgram.h>
#import <ORProgram/ORProgramFactory.h>

#import "ORCmdLineArgs.h"

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      
      [args measure:^struct ORResult(){
         const char* fName = "slab.dat";
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
         
         [model add: [ORFactory packing:model item:slab itemSize: weight load: load]];
         for(ORInt s = Slabs.low; s <= Slabs.up; s++)
            [model add: [Sum(model,c,Colors,Or(model,o,coloredOrder[c],[slab[o] eq: @(s)])) leq: @2]];
         [model minimize: Sum(model,s,Slabs,[loss elt: [load at: s]])];
         id<CPProgram> cp = [ORFactory createCPProgram: model];
         __block ORInt lim = 1000;
         __block BOOL improved = NO;
         id<ORZeroOneStream> rs = [ORFactory zeroOneStream:cp];
         [cp solve: ^{
            id<ORObjectiveFunction> obj = [cp objective];
            printf(" Starting search \n");
            [cp repeat:^{
               improved = NO;
               [cp limitFailures:lim in:^{
                  [cp forall:SetOrders suchThat:^bool(ORInt o) { return ![cp bound: slab[o]];}
                   orderedBy:^ORInt(ORInt o) { return ([cp domsize: slab[o]] << 16) - [weight at:o];}
                          do: ^(ORInt o){
                             id<ORIntSet> avail = [ORFactory intSet:cp];
                             id<ORIntSet> rS    = [ORFactory intSet:cp];
                             for(ORInt k=Slabs.low;k<=Slabs.up;k++)
                                [avail insert:k];
                             for(ORInt o=SetOrders.low;o <= SetOrders.up;o++) {
                                if (![cp bound:slab[o]])  continue;
                                ORInt idx = [cp intValue:slab[o]];
                                [avail delete:idx];
                                [rS insert:idx];
                             }
                             ORInt s = floor([rs next] * [avail size]);
                             ORInt aar = [avail atRank:s];
                             [rS insert:aar];
//                             NSLog(@"rs.insert(%d) : lbl(%d  --> %@",aar,o,rS);
                             [cp tryall: rS suchThat: ^bool(ORInt s) { return [cp member: s in: slab[o]]; }
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
                     [SetOrders enumerateWithBlock:^(ORInt i) {
                        if ([d next]  <= 90) {
                           //printf(".");fflush(stdout);
                           [cp add:[slab[i] eq:@([s intValue:slab[i]])]];
                        }
                     }];
                  }];
                  //lim *= 2;
                  NSLog(@"New limit: %d",lim);
                  //[[cp objective] tightenPrimalBound:[s objectiveValue]];
               }
            }];
            NSLog(@"Objective value: %@",[obj value]);
            improved = YES;
         }];
         id<ORSolution> sol = [[cp solutionPool] best];
         for(ORInt i = [SetOrders low]; i <= [SetOrders up]; i++)
            printf("slab[%d] = %d \n",i,[sol intValue: slab[i]]);
         printf("\n");
         ORLong endTime = [ORRuntimeMonitor wctime];
         NSLog(@"Execution Time (WC): %lld \n",endTime - startTime);
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




