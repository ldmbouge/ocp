/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/LPProgram.h>
#import <objcp/CPFactory.h>
#import "../ORModeling/ORLinearize.h"
#import "../ORModeling/ORFlatten.h"
#import "ORRunnable.h"
#import "ORLogicBenders.h"
#import "SSCPLPInstanceParser.h"
#import "CPEngineI.h"
#import "CPRunnable.h"

/*
 Single Source Capacitated Plant Location Problem

 Implementation of the Location-Allocation Problem as described in:
 
 Solving a Location-Allocation Problem with Logic-Based Benders’ Decomposition
 Mohammad M. Fazel-Zarandi and J. Christopher Beck 

 Instances can be founds at: http://www-eio.upc.es/~elena/sscplp/
*/


// Returns the minimum number of bins required to fit items
ORInt FirstFitDecreasingHeuristic(ORInt maxBinSize, id<ORIntArray> items) {
    // Sort items
    NSMutableArray* sortedItems = [[NSMutableArray alloc] initWithCapacity: [items count]];
    [items enumerateWith:^(ORInt obj, ORInt idx) { [sortedItems addObject: [NSNumber numberWithInt: obj]]; } ];
    [sortedItems sortUsingSelector:@selector(compare:)];
    
    // Create bins
    ORInt maxNbBins = (ORInt)[items count];
    ORInt bins[maxNbBins];
    for(ORInt i = 0; i < maxNbBins; i++) bins[i] = 0;
    
    // Greedily fill bins
    ORInt binCount = 1;
    for(NSNumber* n in [sortedItems reverseObjectEnumerator]) {
        BOOL foundBin = NO;
        for(ORInt b = 0; b < binCount; b++) {
            if(bins[b] + [n intValue] <= maxBinSize) {
                bins[b] += [n intValue];
                foundBin = YES;
                break;
            }
        }
        if(!foundBin) {
            binCount++;
            bins[binCount - 1] = [n intValue];
        }
    }
    [sortedItems release];
    return binCount;
}


int main(int argc, const char * argv[])
{
   // Parse instance data
   NSString* instanceData =
    @"20   10\
    51.00       47.00       94.00       76.00       60.00       24.00       18.00        6.00       96.00       20.00\
    39.00        5.00        1.00        8.00       33.00       70.00        2.00       86.00       55.00       81.00\
    65.00       62.00       12.00       10.00       16.00       50.00       27.00       38.00       84.00       97.00\
    93.00        9.00       82.00       64.00       65.00        1.00       29.00       16.00       39.00       95.00\
    90.00        5.00       12.00       72.00       65.00       48.00       25.00       65.00       77.00       25.00\
    42.00       46.00       36.00       63.00        2.00       31.00       61.00       69.00       56.00       33.00\
    8.00       42.00       70.00       83.00       25.00       59.00       67.00       12.00       41.00       28.00\
    30.00       68.00       45.00       53.00       83.00       94.00       21.00       42.00       42.00       97.00\
    56.00       67.00       81.00        4.00       17.00       58.00       69.00       56.00       70.00       68.00\
    74.00       93.00        0.00       65.00       20.00       51.00       34.00       35.00       75.00       51.00\
    94.00       83.00       80.00       60.00       26.00       90.00       53.00       55.00       74.00       51.00\
    42.00       14.00        7.00       98.00       84.00       26.00        9.00       90.00       27.00       84.00\
    3.00       31.00       92.00        7.00       47.00       28.00       99.00        2.00       44.00       11.00\
    86.00       64.00       46.00       93.00       75.00       85.00       37.00        8.00       94.00       99.00\
    43.00       83.00       29.00       94.00       85.00       19.00       87.00       84.00       78.00       95.00\
    85.00       95.00       54.00       10.00       95.00       20.00       49.00       31.00       12.00       53.00\
    79.00       24.00       22.00        3.00       17.00       64.00        3.00       37.00       15.00       67.00\
    52.00       20.00       57.00       83.00       58.00       45.00       32.00       52.00       47.00       58.00\
    49.00       98.00       55.00       47.00       56.00       21.00       41.00       29.00       13.00       17.00\
    11.00       53.00       48.00       27.00       29.00       23.00       87.00       94.00       45.00       90.00\
    17.00       24.00       23.00       37.00       12.00       29.00       21.00        2.00       18.00        9.00\
    22.00       21.00       12.00       16.00       24.00       35.00       23.00        5.00       33.00       22.00\
    206.00      132.00      335.00      219.00      340.00      206.00      340.00      298.00      233.00      322.00\
    36.00       47.00       66.00       56.00       72.00       39.00       58.00       41.00       62.00       56.00";
   
   SSCPLPInstanceParser* parser = [[SSCPLPInstanceParser alloc] init];
   SSCPLPInstance* instance = [parser parseInstanceString: instanceData];
   [parser release];
   
   id<ORModel> master = [ORFactory createModel];
   ORInt m = instance.numberOfClients;
   ORInt n = instance.numberOfPlants;
   id<ORIntRange> I = RANGE(master, 0, m-1);
   id<ORIntRange> J = RANGE(master, 0, n-1);
   id<ORIntRange> binaryDomain = RANGE(master, 0, 1);
   
   // l an u values taken from paper
   ORInt l = 40;
   ORInt u = 50;
   
   // Maximum number of trucks at a facility.
   ORInt k = [ORFactory maxOver: I suchThat: nil of: ^ORInt(ORInt i) { return (ORInt)instance.demand[i]; }];
   
   // travel distances initialized at random in interval [10, 50] as in the uncorrelated condition in the paper.
   id<ORUniformDistribution> distr = [ORFactory uniformDistribution: master range: RANGE(master, 10, 50)];
   id<ORIntMatrix> t = [ORFactory intMatrix: master range: I : J using: ^ORInt(ORInt i, ORInt j) { return [distr next]; }];
   
   // Decision variables
   id<ORIntVarArray> p = [ORFactory intVarArray: master range: J  domain: binaryDomain];
   id<ORIntVarMatrix> x = [ORFactory intVarMatrix: master range: I : J domain: binaryDomain];
   id<ORIntVarArray> numVeh = [ORFactory intVarArray: master range: J  domain: RANGE(master, 0, k)];
   id<ORIntVar> objective = [ORFactory intVar: master domain: RANGE(master, 0, 100000)]; // Not sure what upper bound of the objective should be
   
   // Objective
   [master minimize: objective];
   [master add: [objective eq: [Sum(master, j, J, [[p at: j] mul: @((ORInt)instance.openingCost[j])])
                                plus: [Sum2(master, i, I, j, J, [[x at: i : j] mul: @(instance.cost[i][j])])
                                       plus: Sum(master, j, J, [[numVeh at: j] mul: @(u)])]]]];
   
   // Constraints
   for(ORInt i = 0; i < m; i++) {
      [master add: [Sum(master, j, J, [x at: i : j]) eq: @1]];                                  // [8]
   }
   for(ORInt j = 0; j < n; j++) {
      [master add: [Sum(master, i, I, [[x at: i : j] mul: @([t at: i : j])]) leq: @(l * k)]];       // [9]
      [master add: [Sum(master, i, I, [[x at: i : j] mul: @((ORInt)instance.demand[i])])          // [11]
                    leq: [[p at: j] mul: @((ORInt)instance.capacity[j])]]];
      [master add: [[numVeh at: j]                                                              // [12] This needs to use mulf!
                    geq: Sum(master, i, I, [[x at: i : j] mul: @([t at: i : j] / (ORFloat)l)])]];
   }
   for(ORInt i = 0; i < m; i++) {
      for(ORInt j = 0; j < n; j++) {
         [master add: [[[x at: i : j] mul: @([t at: i : j])] leq: @(l)]];                    // [10]
         [master add: [[x at: i : j] leq: [p at: j]]];                                          // [14]
      }
   }   
   
   id<ORRunnable> ip = [ORFactory MIPRunnable: master];
   id<ORRunnable> benders = [ORFactory logicBenders: ip slave: ^id<ORConstraintSet>() {
           id<ORConstraintSet> cuts = [ORFactory createConstraintSet];
           for (ORInt j = 0; j < n; j++) {
               id<ORIntSet> Ij = [ORFactory collect: master range: I suchThat: ^bool(ORInt i) { return [[x at: i : j] value] == 1; } of: ^ORInt(ORInt e) { return e; } ];
               if([Ij size] == 0) continue; // Facility not being used
               id<IntEnumerator> enumIj = [Ij enumerator];
               id<ORIntArray> dist = [ORFactory intArray: master range: RANGE(master, 0, [Ij size]-1) with: ^ORInt(ORInt e) { return [t at: [enumIj next] : j]; }];
               printf("dist: ");
               for(int i = 0; i < [Ij size]; i++) printf("%i ", [dist at: i]);
               printf("\n");
               
               
               ORInt numVehFFD = FirstFitDecreasingHeuristic(l, dist);
               NSLog(@"FFD vs numVehj : %i %i", numVehFFD, [[numVeh at: j] value]);
               if(numVehFFD > [[numVeh at: j] value]) {
                   // Run subproblems
                   for(ORInt numVehBinPacking = [[numVeh at: j] value]; numVehBinPacking < numVehFFD; numVehBinPacking++) {
                       NSLog(@"Running Subproblem...");
                       id<ORModel> subproblem = [ORFactory createModel];
                       id<ORIntVarArray> load = [ORFactory intVarArray: subproblem range: RANGE(subproblem, 0, numVehBinPacking-1) domain: RANGE(subproblem, 0, l)];
                       id<ORIntVarArray> truck = [ORFactory intVarArray: subproblem range: RANGE(subproblem, 0, (ORInt)[dist count]-1) domain: RANGE(subproblem, 1, [[numVeh at: j] value])];
                       NSLog(@"truck: %@ dist: %@ load: %@", [[truck range] description], [[dist range] description], [[load range] description]);
                       
                       [subproblem add: [ORFactory packing: truck itemSize: dist load: load]];
                       id<ORRunnable> r = [ORFactory CPRunnable: subproblem];
                       [r run];
                       CPEngineI* engine = (CPEngineI*)[[((id<CPRunnable>)r) solver] engine];
                       if([engine status] == ORFailure) {
                           // Add Cut to pool
                           id<ORExpr> numVehValue = [ORFactory integer: master value: [[numVeh at: j] value]];
                           id<ORExpr> one = [ORFactory integer: master value: 1];
                           [cuts addConstraint: [[numVeh at: j] geq:
                                                 [numVehValue sub: [ORFactory sum: master over: Ij suchThat: nil of:
                                                                    ^id<ORExpr>(ORInt i) { return [one sub: [x at: i : j]]; }]]]];
                           [r release];
                           [subproblem release];
                       }
                       else { [r release]; [subproblem release]; break; }
                   }
                   
               }
               [dist release];
           }
       return cuts;
   }];
   [benders run];
   
   [instance release];
   return 0;
}

