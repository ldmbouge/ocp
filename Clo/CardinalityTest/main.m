/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <objcp/CPConstraint.h"
#import <objcp/CPSolver.h>
#import <objcp/CPFactory.h>
#import <objcp/CPHeuristic.h>

//20632 choices
//20579 fail
//622248 propagations

int main(int argc, const char * argv[])
{
   ORInt n = 14;
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> Periods = RANGE(cp,1,n/2);
   id<ORIntRange> Teams = RANGE(cp,1,n);
   id<ORIntRange> Weeks = RANGE(cp,1,n-1);
   id<ORIntRange> EWeeks = RANGE(cp,1,n);
   id<ORIntRange> HomeAway = RANGE(cp,0,1);
   id<ORIntRange> Games = RANGE(cp,0,n*n);
   id<ORIntArray> c = [CPFactory intArray:cp range:Teams with: ^ORInt(ORInt i) { return 2; }];
   id<ORIntVarMatrix> team = [CPFactory intVarMatrix:cp range: Periods : EWeeks : HomeAway domain:Teams];
   id<ORIntVarMatrix> game = [CPFactory intVarMatrix:cp range: Periods : Weeks domain:Games];
   id<ORIntVarArray> allteams =  [CPFactory intVarArray:cp range: Periods : EWeeks : HomeAway
                                                   with: ^id<ORIntVar>(ORInt p,ORInt w,ORInt h) { return [team at: p : w : h]; }];
   id<ORIntVarArray> allgames =  [CPFactory intVarArray:cp range: Periods : Weeks
                                                   with: ^id<ORIntVar>(ORInt p,ORInt w) { return [game at: p : w]; }];
   id<CPTable> table = [CPFactory table: cp arity: 3];
   for(ORInt i = 1; i <= n; i++)
      for(ORInt j = i+1; j <= n; j++)
         [table insert: i : j : (i-1)*n + j-1];
   [table close];
   for(ORInt w = 1; w < n; w++)
      for(ORInt p = 1; p <= n/2; p++)
         [cp add: [CPFactory table: table on: [team at: p : w : 0] : [team at: p : w : 1] : [game at: p : w]]];
   [cp add: [CPFactory alldifferent:allgames]];
   for(ORInt w = 1; w <= n; w++)
      [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: Periods : HomeAway
                                                          with: ^id<ORIntVar>(ORInt p,ORInt h) { return [team at: p : w : h ]; } ]]];
   for(ORInt p = 1; p <= n/2; p++)
      [cp add: [CPFactory cardinality: [CPFactory intVarArray: cp range: EWeeks : HomeAway
                                                         with: ^id<ORIntVar>(ORInt w,ORInt h) { return [team at: p : w : h ]; }]
                                  low: c
                                   up: c
                          consistency:DomainConsistency]];

   [cp solve:
    ^() {
       [CPLabel array: allgames orderedBy: ^ORInt(ORInt i) { return [[allgames at:i] domsize];}];
       printf("Solution \n");
       for(ORInt p = 1; p <= n/2; p++) {
          for(ORInt w = 1; w < n; w++)
             printf("%2d-%2d [%3d]  ",[[team at: p : w : 0] min],[[team at: p : w : 1] min],[[game at: p : w] min]);
          printf("\n");
       }
       [CPLabel array: allteams orderedBy: ^ORInt(ORInt i) { return [[allteams at:i] domsize];}];
       //         [cp label:[x at: 1] with: 2];
       printf("matrix: %s\n",[[team description] cStringUsingEncoding:NSASCIIStringEncoding]);
       //         [CPLabel array: x];
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;
}

/*
id<ORIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
id<CPTable> table = [CPFactory table: cp arity: 3];
for(ORInt i = 0; i < 5; i++)
for(ORInt j = i+1; j < 5; j++)
[table insert: i : j : i*5 + j];
[table close];
[table print];
[cp solveAll: 
 ^() {
     [cp add: [CPFactory table: table on: x]];
*/
