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
#import "MIPSolverI.h"
#import "MIPRunnable.h"

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
    34.00       78.00       31.00       70.00       45.00        9.00       50.00       22.00       70.00       25.00\
    36.00       73.00       11.00       99.00       32.00       35.00       81.00       92.00       64.00       26.00\
    82.00       64.00       81.00       74.00        6.00       62.00       61.00       87.00       51.00       36.00\
    9.00       10.00       63.00       80.00       78.00       97.00       45.00       17.00        9.00       47.00\
    84.00       72.00       77.00       81.00       92.00       85.00       61.00       81.00       63.00       85.00\
    98.00        0.00       89.00       11.00       90.00       16.00       90.00       45.00       55.00       90.00\
    52.00        8.00       63.00       56.00       74.00       29.00       82.00       53.00       69.00       83.00\
    32.00       63.00       70.00       61.00       22.00       32.00       42.00       21.00       17.00       83.00\
    91.00       27.00       60.00       43.00       26.00       81.00       40.00       44.00       18.00        3.00\
    99.00       81.00       58.00       12.00       95.00       19.00        5.00       10.00       80.00       95.00\
    84.00       86.00       63.00       60.00       72.00       79.00       47.00       32.00       76.00       58.00\
    80.00       99.00       99.00       41.00       53.00       45.00       45.00       30.00       33.00       21.00\
    7.00       37.00       12.00       75.00       46.00       49.00       14.00        3.00       40.00       37.00\
    94.00        1.00       80.00       12.00       11.00       20.00       31.00       89.00       65.00       57.00\
    84.00        0.00       40.00       27.00       72.00       82.00       68.00       18.00       23.00       21.00\
    30.00        0.00       74.00       26.00       50.00       56.00       67.00       76.00       43.00       53.00\
    13.00       53.00       32.00       64.00       69.00       50.00       41.00       20.00       86.00       37.00\
    24.00       47.00       28.00        7.00       98.00       11.00       44.00       32.00       81.00       88.00\
    60.00       20.00       53.00       28.00       30.00       30.00        4.00       74.00       47.00        7.00\
    11.00       58.00        6.00       31.00       88.00       94.00       88.00       94.00       81.00       27.00\
    27.00       35.00       11.00       11.00       32.00       28.00       34.00       33.00        6.00       23.00\
    26.00       22.00       27.00       24.00       11.00       22.00       21.00       15.00       17.00       30.00\
    840.00      789.00     1090.00      739.00      563.00      207.00      671.00      834.00      300.00      437.00\
    111.00       76.00       76.00       53.00       53.00       36.00       79.00       72.00       54.00       30.00";

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
      [master add: [[[numVeh at: j] mul: @(l)]                                                             // [12] This needs to use mulf!
                    geq: Sum(master, i, I, [[x at: i : j] mul: @([t at: i : j])])]];
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
                       id<ORIntVarArray> truck = [ORFactory intVarArray: subproblem range: RANGE(subproblem, 0, (ORInt)[dist count]-1) domain: RANGE(subproblem, 0, [[numVeh at: j] value]-1)];
                       NSLog(@"truck: %@ dist: %@ load: %@", [[truck range] description], [[dist range] description], [[load range] description]);
                       
                       [subproblem add: [ORFactory packing: truck itemSize: dist load: load]];
                       id<ORRunnable> r = [ORFactory CPRunnable: subproblem];
                       [r run];
                       CPEngineI* engine = (CPEngineI*)[[((id<CPRunnable>)r) solver] engine];
                       if([engine status] == ORFailure) {
                           // Add Cut to pool
                           id<ORConstraint> c = [[numVeh at: j] geq:
                                                 [@([[numVeh at: j] value]) sub: [ORFactory sum: master over: Ij suchThat: nil of:
                                                                    ^id<ORExpr>(ORInt i) { return [@1 sub: [x at: i : j]]; }]]];

                           // Cheat and inject here
                           MIPSolverI* mipSolver = [[((id<MIPRunnable>)ip) solver] solver];
                           ORInt size = [Ij size] + 1;
                           MIPVariableI* vars[size];
                           id<IntEnumerator> e = [Ij enumerator];
                           vars[0] = [[numVeh at: j] dereference];
                           for(ORInt i = 1; i < size; i++) vars[i] = [[x at: [e next] : j] dereference];
                           ORFloat coef[size];
                           coef[0] = 1;
                           for(ORInt i = 1; i < size; i++) coef[i] = -1;
                           ORFloat rhs = [[numVeh at: j] value] - [Ij size] + 1;
                           MIPConstraintI* mc = [mipSolver createGEQ: size var: vars coef: coef rhs: rhs];
                           [mipSolver postConstraint: mc];
                           NSLog(@"cut: %@", [c description]);
                           [cuts addConstraint: c];
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

