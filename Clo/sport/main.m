/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>

//20639 choices
//20579 fail
//622276 propagations

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORInt n = 14;
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> Periods = RANGE(mdl,1,n/2);
         id<ORIntRange> Teams = RANGE(mdl,1,n);
         id<ORIntRange> Weeks = RANGE(mdl,1,n-1);
         id<ORIntRange> EWeeks = RANGE(mdl,1,n);
         id<ORIntRange> HomeAway = RANGE(mdl,0,1);
         id<ORIntRange> Games = RANGE(mdl,0,n*n);
         id<ORIntArray> c = [ORFactory intArray:mdl range:Teams with: ^ORInt(ORInt i) { return 2; }];
         id<ORIntVarMatrix> team = [ORFactory intVarMatrix:mdl range: Periods : EWeeks : HomeAway domain:Teams];
         id<ORIntVarMatrix> game = [ORFactory intVarMatrix:mdl range: Periods : Weeks domain:Games];
         id<ORIntVarArray> allteams =  [ORFactory intVarArray:mdl range: Periods : EWeeks : HomeAway
                                                         with: ^id<ORIntVar>(ORInt p,ORInt w,ORInt h) { return [team at: p : w : h]; }];
         id<ORIntVarArray> allgames =  [ORFactory intVarArray:mdl range: Periods : Weeks
                                                         with: ^id<ORIntVar>(ORInt p,ORInt w) { return [game at: p : w]; }];
         id<ORTable> table = [ORFactory table: mdl arity: 3];
         for(ORInt i = 1; i <= n; i++)
            for(ORInt j = i+1; j <= n; j++)
               [table insert: i : j : (i-1)*n + j-1];
         
         for(ORInt w = 1; w < n; w++)
            for(ORInt p = 1; p <= n/2; p++)
               [mdl add: [ORFactory tableConstraint:mdl table:table on: [team at: p : w : 0] : [team at: p : w : 1] : [game at: p : w]]];
         [mdl add: [ORFactory alldifferent: allgames]];
         for(ORInt w = 1; w <= n; w++)
            [mdl add: [ORFactory alldifferent: [ORFactory intVarArray: mdl range: Periods : HomeAway
                                                                 with: ^id<ORIntVar>(ORInt p,ORInt h) { return [team at: p : w : h ]; } ]]];
         for(ORInt p = 1; p <= n/2; p++)
            [mdl add: [ORFactory cardinality: [ORFactory intVarArray: mdl range: EWeeks : HomeAway
                                                                with: ^id<ORIntVar>(ORInt w,ORInt h) { return [team at: p : w : h ]; }]
                                         low: c
                                          up: c]];
         
         id<CPProgram> cp = [ORFactory createCPProgram:mdl];
         [cp solve:
          ^() {
             [cp  labelArray: allgames orderedBy: ^ORFloat(ORInt i) { return [cp domsize:[allgames at:i]];}];
             NSLog(@"after");
             [cp labelArray: allteams orderedBy: ^ORFloat(ORInt i) { return [cp domsize:[allteams at:i]];}];
             printf("Solution \n");
             for(ORInt p = 1; p <= n/2; p++) {
                for(ORInt w = 1; w < n; w++)
                   printf("%2d-%2d [%3d]  ",[cp intValue:[team at: p : w : 0]],
                          [cp intValue:[team at: p : w : 1]],
                          [cp intValue:[game at: p : w]]);
                printf("\n");
             }
          }
          ];
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

