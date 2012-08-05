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
#import "objcp/CPlabel.h"

id<ORIntSet> knightMoves(id<CPSolver> cp,int i) 
{
    id<ORIntSet> S = [CPFactory intSet: cp];
    if (i % 8 == 1) {
        [S insert: i-15]; [S insert: i-6]; [S insert: i+10]; [S insert: i+17];
    }
    else if (i % 8 == 2) {
        [S insert: i-17]; [S insert: i-15]; [S insert: i-6]; [S insert: i+10]; [S insert: i+15]; [S insert: i+17];
    }     
    else if (i % 8 == 7) {
        [S insert: i-17];[S insert: i-15];[S insert: i-10];[S insert: i+6];[S insert: i+15];[S insert: i+17];
    }
    else if (i % 8 == 0) {
        [S insert: i-17];[S insert: i-10];[S insert: i+6];[S insert: i+15];
    }           
    else {
        [S insert: i-17];[S insert: i-15];[S insert: i-10];[S insert: i-6];[S insert: i+6];[S insert: i+10];[S insert: i+15];[S insert: i+17];
    }
    return S;
}
void printCircuit(id<CPIntVarArray> jump)
{
    int curr = 1;
    printf("1");
    do {
        curr = [[jump at: curr] min];
        printf("->%d",curr);
    } while (curr != 1);
    printf("\n");
}

int main (int argc, const char * argv[])
{
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange: cp low: 0 up: 2];
   id<ORIntRange> D = [ORFactory intRange: cp low: 0 up: 30];
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
   NSLog(@"%@",x);
   printf("%d \n",[x[0] domsize]);
   id<CPTable> table = [CPFactory table: cp arity: 3];
   for(CPInt i = 0; i < 5; i++)
      for(CPInt j = i+1; j < 5; j++)
         [table insert: i : j : i*5 + j];
   [table close];
   [table print];
   [cp add: [CPFactory table: table on: x]];

   [cp solveAll:
    ^() {
       [CPLabel array: x];
       printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;
}


