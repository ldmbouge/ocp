/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"
#import "objcp/CPHeuristic.h"

//20632 choices
//20579 fail
//622248 propagations

int main(int argc, const char * argv[])
{
   CPInt n = 14;
   id<CP> cp = [CPFactory createSolver];
   id<ORIntRange> Periods = RANGE(cp,1,n/2);
   id<ORIntRange> Teams = RANGE(cp,1,n);
   id<ORIntRange> Weeks = RANGE(cp,1,n-1);
   id<ORIntRange> EWeeks = RANGE(cp,1,n);
   id<ORIntRange> HomeAway = RANGE(cp,0,1);
   id<ORIntRange> Games = RANGE(cp,0,n*n);
   id<CPIntArray> c = [CPFactory intArray:cp range:Teams with: ^CPInt(CPInt i) { return 2; }];
   id<CPIntVarMatrix> team = [CPFactory intVarMatrix:cp range: Periods : EWeeks : HomeAway domain:Teams];
   id<CPIntVarMatrix> game = [CPFactory intVarMatrix:cp range: Periods : Weeks domain:Games];
   id<CPIntVarArray> allteams =  [CPFactory intVarArray:cp range: Periods : EWeeks : HomeAway
                                                   with: ^id<CPIntVar>(CPInt p,CPInt w,CPInt h) { return [team at: p : w : h]; }];
   id<CPIntVarArray> allgames =  [CPFactory intVarArray:cp range: Periods : Weeks
                                                   with: ^id<CPIntVar>(CPInt p,CPInt w) { return [game at: p : w]; }];
   id<CPTable> table = [CPFactory table: cp arity: 3];
   for(CPInt i = 1; i <= n; i++)
      for(CPInt j = i+1; j <= n; j++)
         [table insert: i : j : (i-1)*n + j-1];
   [table close];
   
   [cp solve:
    ^() {
       for(CPInt w = 1; w < n; w++)
          for(CPInt p = 1; p <= n/2; p++)
             [cp add: [CPFactory table: table on: [team at: p : w : 0] : [team at: p : w : 1] : [game at: p : w]]];
       [cp add: [CPFactory alldifferent:allgames]];
       for(CPInt w = 1; w <= n; w++)
          [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: Periods : HomeAway
                                                              with: ^id<CPIntVar>(CPInt p,CPInt h) { return [team at: p : w : h ]; } ]]];
       for(CPInt p = 1; p <= n/2; p++)
          [cp add: [CPFactory cardinality: [CPFactory intVarArray: cp range: EWeeks : HomeAway
                                                             with: ^id<CPIntVar>(CPInt w,CPInt h) { return [team at: p : w : h ]; }]
                                      low: c
                                       up: c
                              consistency:DomainConsistency]];
    }
       using:
    ^() {
       [CPLabel array: allgames orderedBy: ^CPInt(CPInt i) { return [[allgames at:i] domsize];}];
       printf("Solution \n");
       for(CPInt p = 1; p <= n/2; p++) {
          for(CPInt w = 1; w < n; w++)
             printf("%2d-%2d [%3d]  ",[[team at: p : w : 0] min],[[team at: p : w : 1] min],[[game at: p : w] min]);
          printf("\n");
       }
       [CPLabel array: allteams orderedBy: ^CPInt(CPInt i) { return [[allteams at:i] domsize];}];
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
id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
id<CPTable> table = [CPFactory table: cp arity: 3];
for(CPInt i = 0; i < 5; i++)
for(CPInt j = i+1; j < 5; j++)
[table insert: i : j : i*5 + j];
[table close];
[table print];
[cp solveAll: 
 ^() {
     [cp add: [CPFactory table: table on: x]];
*/
