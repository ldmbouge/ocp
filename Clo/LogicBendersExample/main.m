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

/*
 Single Source Capacitated Plant Location Problem

 Implementation of the Location-Allocation Problem as described in:
 
 Solving a Location-Allocation Problem with Logic-Based Benders’ Decomposition
 Mohammad M. Fazel-Zarandi and J. Christopher Beck 

 Instances can be founds at: http://www-eio.upc.es/~elena/sscplp/
*/


int main(int argc, const char * argv[])
{
   // Parse instance data
   NSString* instanceData =
   @"20   10\
   8.00       85.00        5.00       49.00       42.00        8.00       87.00       93.00       62.00       84.00\
   9.00        0.00        4.00       65.00       59.00       77.00       26.00       68.00       91.00       25.00\
   35.00       21.00       65.00       94.00       46.00       29.00       56.00       47.00       46.00       75.00\
   60.00       80.00       82.00       46.00       16.00       18.00       78.00       31.00       45.00       88.00\
   63.00       44.00       67.00       47.00       62.00       74.00       32.00        5.00       91.00       44.00\
   96.00       72.00       38.00       51.00       26.00       25.00       34.00       12.00       97.00       71.00\
   51.00       36.00       34.00       53.00       71.00        0.00        8.00       21.00       12.00       95.00\
   81.00       66.00       17.00       78.00       70.00       98.00       28.00       37.00       59.00        6.00\
   10.00       62.00        2.00       26.00        0.00       71.00       78.00       26.00       74.00       41.00\
   95.00       61.00       92.00       44.00       54.00       72.00       39.00       83.00       25.00       26.00\
   69.00       79.00       98.00       17.00       43.00       53.00       87.00       88.00       99.00        9.00\
   38.00       29.00       95.00       10.00       41.00       75.00       28.00       99.00       51.00       93.00\
   6.00        8.00       85.00       45.00       25.00       65.00       20.00       67.00       94.00       82.00\
   42.00       89.00       91.00       87.00        2.00       92.00       54.00       37.00       69.00       84.00\
   41.00       17.00       21.00       34.00       99.00       22.00       77.00       90.00       50.00       73.00\
   80.00       82.00       63.00        4.00       82.00       84.00       75.00       38.00       87.00       79.00\
   86.00       31.00       62.00       49.00       39.00       46.00        5.00        3.00       55.00       95.00\
   46.00       94.00       87.00       61.00       15.00       92.00       18.00       82.00        5.00       29.00\
   8.00       56.00        3.00       11.00       71.00       18.00       81.00       77.00       33.00       76.00\
   65.00       57.00        8.00       13.00       19.00       32.00       89.00        4.00       25.00       22.00\
   12.00       18.00       18.00       19.00       26.00       21.00       18.00       19.00       18.00       11.00\
   22.00       21.00       13.00       19.00       13.00       14.00       22.00       17.00       27.00       28.00\
   329.00      144.00      408.00      202.00      369.00      440.00      195.00      162.00      174.00      197.00\
   59.00       48.00       65.00       43.00       64.00       65.00       57.00       49.00       58.00       30.00";
   
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
   id<ORUniformDistribution> distr = [CPFactory uniformDistribution: master range: RANGE(master, 10, 50)];
   id<ORIntMatrix> t = [ORFactory intMatrix: master range: I : J using: ^ORInt(ORInt i, ORInt j) { return [distr next]; }];
   
   // Decision variables
   id<ORIntVarArray> p = [ORFactory intVarArray: master range: J  domain: binaryDomain];
   id<ORIntVarMatrix> x = [ORFactory intVarMatrix: master range: I : J domain: binaryDomain];
   id<ORIntVarArray> numVeh = [ORFactory intVarArray: master range: J  domain: binaryDomain];
   id<ORIntVar> objective = [ORFactory intVar: master domain: RANGE(master, 0, 100000)]; // Not sure what upper bound of the objective should be
   
   // Objective
   [master minimize: objective];
   [master add: [objective eq: [Sum(master, j, J, [[p at: j] muli: (ORInt)instance.openingCost[j]])
                                plus: [Sum2(master, i, I, j, J, [[x at: i : j] muli: (ORInt)instance.cost[i][j]])
                                       plus: Sum(master, j, J, [[numVeh at: j] muli: u])]]]];
   
   // Constraints
   for(ORInt i = 0; i < m; i++) {
      [master add: [Sum(master, j, J, [x at: i : j]) eqi: 1]];                                  // [8]
   }
   for(ORInt j = 0; j < n; j++) {
      [master add: [Sum(master, i, I, [[x at: i : j] muli: [t at: i : j]]) leqi: l * k]];       // [9]
      [master add: [Sum(master, i, I, [[x at: i : j] muli: (ORInt)instance.demand[i]])          // [11]
                    leq: [[p at: j] muli: (ORInt)instance.capacity[j]]]];
      [master add: [[numVeh at: j]                                                              // [12] This needs to use mulf!
                    geq: Sum(master, i, I, [[x at: i : j] muli: [t at: i : j] / (ORFloat)l])]];
   }
   for(ORInt i = 0; i < m; i++) {
      for(ORInt j = 0; j < n; j++) {
         [master add: [[[x at: i : j] muli: (ORInt)[t at: i : j]] leqi: l]];                    // [10]
         [master add: [[x at: i : j] leq: [p at: j]]];                                          // [14]
      }
   }   
   
   id<ORRunnable> ip = [ORFactory LPRunnable: master]; // This should be an IP.
   id<ORRunnable> benders = [ORFactory logicBenders: ip slave: ^id<ORRunnable>(id<ORSolution> solution) {
      id<ORModel> slave = [ORFactory createModel];
      id<ORIntSet> clientsAssigned[n]; // I_j
      for (ORInt j = 0; j < n; j++) {
         clientsAssigned[j] = [ORFactory collect: slave range: I
                                        suchThat: ^bool(ORInt i) { return [[x at: i : j] value] == 1; }
                                              of: ^ORInt(ORInt i) { return i; }];
      }
      
      // Need to finish
      
      return nil;
   }];
   [benders run];
   
   [instance release];
   return 0;
}

