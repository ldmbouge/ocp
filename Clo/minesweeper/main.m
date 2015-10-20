/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

// Ian Stewart on Minesweeper: http://www.claymath.org/Popular_Lectures/Minesweeper/
//
// Richard Kaye's Minesweeper Pages
// http://web.mat.bham.ac.uk/R.W.Kaye/minesw/minesw.htm
// Some Minesweeper Configurations
// http://web.mat.bham.ac.uk/R.W.Kaye/minesw/minesw.pdf
//
//
//
// Based on MiniZinc model was created by Hakan Kjellerstrand, hakank@bonetmail.com
// See MiniZinc page: http://www.hakank.org/minizinc

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         ORInt X = -1;
//         ORInt r = 6,c=6;
//         ORInt game[6][6] = {
//            {X,X,2,X,3,X},
//            {2,X,X,X,X,X},
//            {X,X,2,4,X,3},
//            {1,X,3,4,X,X},
//            {X,X,X,X,X,3},
//            {X,3,X,3,X,X}};
        
         ORInt r = 10;
         ORInt c = 10;
         ORInt game[10][10] = {
                               {1,X,X,2,X,2,X,2,X,X},
                               {X,3,2,X,X,X,4,X,X,1},
                               {X,X,X,1,3,X,X,X,4,X},
                               {3,X,1,X,X,X,3,X,X,X},
                               {X,2,1,X,1,X,X,3,X,2},
                               {X,3,X,2,X,X,2,X,1,X},
                               {2,X,X,3,2,X,X,2,X,X},
                               {X,3,X,X,X,3,2,X,X,3},
                               {X,X,3,X,3,3,X,X,X,X},
                               {X,2,X,2,X,X,X,2,2,X}};

         for(ORInt i=0;i < r;i++) {
            for(ORInt j=0;j < c;j++) {
               printf("%2d ",game[i][j]);
            }
            printf("\n");
         }

         id<ORIntRange> D = RANGE(model,-1,1);
         id<ORIntRange> R = RANGE(model,0,r-1);
         id<ORIntRange> C = RANGE(model,0,c-1);
         id<ORIntVarMatrix> mines = [ORFactory intVarMatrix:model range:R :C domain:RANGE(model,0,1)];
         for(ORInt i=0;i<r;i++) {
            for(ORInt j=0;j < c;j++) {
               if (game[i][j] >=0) {
                  id<ORExpr> s = [ORFactory sum:model over:D over:D
                                       suchThat:^BOOL(ORInt a, ORInt b)       { return i+a >= 0 && j+b>=0 && i+a<r && j+b<c;}
                                             of:^id<ORExpr>(ORInt a, ORInt b) { return [mines at:i+a :j+b];}];
                  [model add:[s eq:@(game[i][j])]];
                  [model add:[[mines at:i :j] eq:@0]];
               }
            }
         }
         id<CPProgram> cp = [args makeProgram:model];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:All2(cp, ORIntVar, i, R, j, C, [mines at:i :j])];
         __block ORInt nbSol = 0;
         [cp solve:^{
            [cp labelHeuristic:h];
            nbSol++;
            @autoreleasepool {
               for(ORInt i=0;i < r;i++) {
                  for(ORInt j=0;j < c;j++) {
                     printf("%2d ",[cp intValue:[mines at:i :j]]);
                  }
                  printf("\n");
               }
            }
         }];
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}
