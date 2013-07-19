/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

//
// * This model is a translation of the ESSENCE' model quasiGroup7.eprime
//* from the Minion Translator examples.
//* """
//* The quasiGroup existence problem (CSP lib problem 3)
//*
//* An m order quasigroup  is an mxm multiplication table of integers 1..m,
//* where each element occurrs exactly once in each row and column and certain
//* multiplication axioms hold (in this case, we want axiom 7 to hold).
//* """
//*
//* QG7 exists (e) does not exist (n) for size:
//*     5   6   7   8   9   10  11  12  13  14
//*     e   n   n   n   e   n   n   n   e   n
//*% See
//* http://www.dcs.st-and.ac.uk/~ianm/CSPLib/prob/prob003/index.html
//* http://www.dcs.st-and.ac.uk/~ianm/CSPLib/prob/prob003/spec.html
//* Axiom 7:
//* """
//* QG7.m problems are order m quasigroups for which (b*a)*b = a*(b*a).
//* """
//*
//* Model created by Hakan Kjellerstrand, hakank@bonetmail.com
//* See also my MiniZinc page: http://www.hakank.org/minizinc

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args `:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         ORInt n = [args size];
         id<ORIntRange> D = RANGE(model,0,n-1);
         id<ORIntVarMatrix> q = [ORFactory intVarMatrix:model range:D :D domain:D];
         [D enumerateWithBlock:^(ORInt r) {
            [model add:[ORFactory alldifferent:All(model, ORIntVar, c, D, [q at:r :c]) annotation:DomainConsistency]];
            [model add:[ORFactory alldifferent:All(model, ORIntVar, c, D, [q at:c :r]) annotation:DomainConsistency]];
            [model add:[[q at:r :r] eq:@(r)]];
         }];
         [D enumerateWithBlock:^(ORInt i) {
            [D enumerateWithBlock:^(ORInt j) {
               [model add:[[q at:i elt:[q at:j :i]] eq: [q elt:[q at:j :i] i1:j]]];
            }];
            [model add:[[[q at:i :n-1] plus:@2] geq:@(i)]];
         }];

         id<CPProgram> cp = [args makeProgram:model];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:All2(cp, ORIntVar, i, D, j, D, [q at:i :j])];
         __block ORInt nbSol = 0;
         [cp solve:^{
            //[cp labelArrayFF:All2(cp, ORIntVar, i, D, j, D, [q at:i :j])];
            [cp labelHeuristic:h];
            nbSol++;
            @autoreleasepool {
               for(ORInt i=0;i <n;i++) {
                  for(ORInt j=0;j < n;j++) {
                     printf("%2d ",[cp intValue:[q at:i :j]]);
                     ORInt qji = [cp intValue:[q at:j :i]];
                     assert([cp intValue:[q at:qji :j]] == [cp intValue:[q at:i :qji]]);
                  }
                  printf("\n");
               }
            }
         }];
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}
