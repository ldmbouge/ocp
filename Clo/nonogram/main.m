/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"

//
// Build the transition matrix for a nonogram pattern.
//
id<ORIntMatrix> make_transition_matrix(id<ORModel> m,ORInt pattern[],ORInt size)
{
   const ORInt pLen = size;
   ORInt num_states = pLen;
   for(ORInt i=0;i<pLen;i++) num_states += pattern[i];
   // this is for handling 0-clues. It generates
   // just the state 1,2
   if (num_states == 0) {
      num_states = 1;
   }
   id<ORIntMatrix> t = [ORFactory intMatrix:m range:RANGE(m,0,num_states) :RANGE(m,1,2)];

   // convert pattern to a 0/1 pattern for easy handling of
   // the states
   ORInt tmp[num_states];
   ORInt c = 0;
   tmp[c] = 0;
   for(ORInt i=0; i < pLen;i++) {
      for(ORInt j=1;j < pattern[i];j++) {
         tmp[++c] = 1;
         if (c < num_states)
            tmp[++c] = 0;
      }
   }

   // create the transition matrix
   [t set:num_states at:num_states :1];
   [t set:0 at:num_states :2];
   for(ORInt i=0;i<num_states;i++) {
      if (tmp[i] == 0) {
         [t set:i at:i :1];
         [t set:i+1 at:i :2];
      } else {
         if (i < num_states) {
            if (tmp[i+1] == 1) {
               [t set:0   at:i :1];
               [t set:i+1 at:i :2];
            } else {
               [t set:i+1 at:i :1];
               [t set:0   at:i :2];
            }
         }
      }
   }
   return t;   
}

void checkRule(id<ORModel> m,ORInt* rules,ORInt mx,id<ORIntVarArray>  y)
{
   ORInt rLen  = 0;
   for(ORInt k=0;k<mx;k++) rLen += rules[k] > 0;
   ORInt* rules_tmp = alloca(sizeof(ORInt)*rLen);
   __block ORInt c = 0;
   for(ORInt k=0;k<mx;k++) {
      if (rules[k] > 0)
         rules_tmp[c++] = rules[k];
   };
   
   id<ORIntMatrix> tfn = make_transition_matrix(m,rules_tmp,rLen);
   ORInt n_states = [[tfn range:0] size];
   ORInt input_max = 2;
   ORInt initial_state = 1;
   // Note: we cannot use 0 since it's the failing state
   id<ORIntSet> F = [ORFactory intSet:m];
   [F insert:n_states];
   
   regular(y, n_states, input_max, transition_fn,initial_state, accepting_states);
   
   
} // end check_rule


int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         ORInt n = [args size];
         
         const ORInt rows = 12;
         const ORInt row_rule_len = 3;
         ORInt row_rules[rows][3] = {{0,0,2},
            {0,1,2},
            {0,1,1},
            {0,0,2},
            {0,0,1},
            {0,0,3},
            {0,0,3},
            {0,2,2},
            {0,2,1},
            {2,2,1},
            {0,2,3},
            {0,2,2}
         };
         
         const ORInt cols = 10;
         ORInt col_rules[cols][2] = {
            {2,1},
            {1,3},
            {2,4},
            {3,4},
            {0,4},
            {0,3},
            {0,3},
            {0,3},
            {0,2},
            {0,2}
         };
         
         id<CPProgram> cp = [args makeProgram:model];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:nil];
         id<ORIntVarArray> x = All2(cp, ORIntVar, i, N, j, N, [board at:i :j]);
         __block ORInt nbSol = 0;
         [cp solve:^{

         }];
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}
