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

struct ORTF {
   ORTransition* tf;
   ORInt         sz;
   ORInt         st;
};


//
// Build the transition matrix for a nonogram pattern.
//
struct ORTF make_transition_matrix(id<ORModel> m,ORInt pattern[],ORInt size)
{
   const ORInt pLen = size;
   ORInt num_states = pLen;
   for(ORInt i=0;i<pLen;i++) num_states += pattern[i];
   // this is for handling 0-clues. It generates
   // just the state 1,2
   if (num_states == 0) {
      num_states = 1;
   }
   ORInt bs = num_states - pLen;
   ORInt ws = pLen + 1;
   num_states += 1;
   const ORInt w = 0;
   const ORInt b = 1;
   ORTransition* t = malloc(sizeof(ORTransition) * (bs + ws * 2));

   // convert pattern to a 0/1 pattern for easy handling of
   // the states
   ORInt tmp[num_states];
   ORInt c = 0;
   tmp[c] = w;
   for(ORInt i=0; i < pLen;i++) {
      for(ORInt j=0;j < pattern[i];j++)
         tmp[++c] = b;
      tmp[++c] = w;
   }
   ORInt nbt = 0;
   for (ORInt k=0; k<num_states; k++) {
      switch(tmp[k]) {
         case 0: {
            t[nbt][0] = k,t[nbt][1] = w, t[nbt][2] = k;nbt++;
            if (k < num_states - 1) {
               t[nbt][0] = k,t[nbt][1] = b, t[nbt][2] = k+1;nbt++;
            }
         }break;
         case 1: {
            t[nbt][0] = k,t[nbt][1] = 1==tmp[k+1] ? b : w,t[nbt][2] = k+1;nbt++;
         }break;
      }
   }
   assert(nbt == (bs+ws*2) - 1);
   return (struct ORTF) {t,nbt,bs+ws};
}

void checkRule(id<ORModel> m,ORInt* rules,ORInt mx,id<ORIntVarArray>  y)
{
   ORInt rLen  = 0;
   for(ORInt k=0;k<mx;k++) rLen += rules[k] > 0;
   ORInt* rules_tmp = alloca(sizeof(ORInt)*rLen);
   ORInt c = 0;
   for(ORInt k=0;k<mx;k++)
      if (rules[k] > 0)
         rules_tmp[c++] = rules[k];
   
   struct ORTF tfn = make_transition_matrix(m,rules_tmp,rLen);
   id<ORIntSet> F = [ORFactory intSet:m];
   [F insert:tfn.st - 1];
   [F insert:tfn.st - 2];
   id<ORAutomaton> A = [ORFactory automaton:m
                                   alphabet:RANGE(m,0,1)
                                     states:RANGE(m,0,tfn.st-1)
                                 transition:tfn.tf
                                       size:tfn.sz
                                    initial:0
                                      final:F];
   [m add:[ORFactory regular:y for:A]];
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         
         /*
         const ORInt rows = 12;
         const ORInt row_rule_len = 3;
         ORInt row_rules[rows][3] = {
            {0,0,2},
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
         const ORInt col_rule_len = 2;
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
         */
         // Nonogram problem from Gecode: P200
         // http://www.gecode.org/gecode-doc-latest/classNonogram.html
         //
         const ORInt rows = 25;
         const ORInt row_rule_len = 7;
         ORInt row_rules[rows][row_rule_len] = {
          {0,0,0,0,2,2,3},
          {0,0,4,1,1,1,4},
          {0,0,4,1,2,1,1},
          {4,1,1,1,1,1,1},
          {0,2,1,1,2,3,5},
          {0,1,1,1,1,2,1},
          {0,0,3,1,5,1,2},
          {0,3,2,2,1,2,2},
          {2,1,4,1,1,1,1},
          {0,2,2,1,2,1,2},
          {0,1,1,1,3,2,3},
          {0,0,1,1,2,7,3},
          {0,0,1,2,2,1,5},
          {0,0,3,2,2,1,2},
          {0,0,0,3,2,1,2},
          {0,0,0,0,5,1,2},
          {0,0,0,2,2,1,2},
          {0,0,0,4,2,1,2},
          {0,0,0,6,2,3,2},
          {0,0,0,7,4,3,2},
          {0,0,0,0,7,4,4},
          {0,0,0,0,7,1,4},
          {0,0,0,0,6,1,4},
          {0,0,0,0,4,2,2},
          {0,0,0,0,0,2,1}
          };
         
         
         const ORInt cols = 25;
         const ORInt col_rule_len = 6;
         ORInt col_rules[cols][col_rule_len] = {
          {0,0,1,1,2,2},
          {0,0,0,5,5,7},
          {0,0,5,2,2,9},
          {0,0,3,2,3,9},
          {0,1,1,3,2,7},
          {0,0,0,3,1,5},
          {0,7,1,1,1,3},
          {1,2,1,1,2,1},
          {0,0,0,4,2,4},
          {0,0,1,2,2,2},
          {0,0,0,4,6,2},
          {0,0,1,2,2,1},
          {0,0,3,3,2,1},
          {0,0,0,4,1,15},
          {1,1,1,3,1,1},
          {2,1,1,2,2,3},
          {0,0,1,4,4,1},
          {0,0,1,4,3,2},
          {0,0,1,1,2,2},
          {0,7,2,3,1,1},
          {0,2,1,1,1,5},
          {0,0,0,1,2,5},
          {0,0,1,1,1,3},
          {0,0,0,4,2,1},
          {0,0,0,0,0,3}
          };
         
         id<ORIntVarMatrix> x = [ORFactory intVarMatrix:model
                                                  range:RANGE(model,0,rows-1)
                                                       :RANGE(model,0,cols-1)
                                                 domain:RANGE(model,0,1)];
         
         for(ORInt i=0;i<rows;i++)
            checkRule(model, row_rules[i], row_rule_len, All(model, ORIntVar, k, RANGE(model,0,cols-1), [x at:i :k]));
         for(ORInt i=0;i<cols;i++)
            checkRule(model, col_rules[i], col_rule_len, All(model, ORIntVar, k, RANGE(model,0,rows-1), [x at:k :i]));
         
         id<CPProgram> cp = [args makeProgram:model];
         __block ORInt nbSol = 0;
         [cp solveAll:^{
            if (rows * row_rule_len < cols * col_rule_len) {
               for(ORInt r=0;r<rows;r++) {
                  for(ORInt c=0;c<cols;c++) {
                     if ([cp bound:[x at:r :c]]) continue;
                     [cp try:^{
                        [cp label:[x at:r :c] with:1];
                     } or:^{
                        [cp label:[x at:r :c] with:0];
                     }];
                  }
               }
            } else {
               for(ORInt c=0;c<cols;c++) {
                  for(ORInt r=0;r<rows;r++) {
                     if ([cp bound:[x at:r :c]]) continue;
                     [cp try:^{
                        [cp label:[x at:r :c] with:1];
                     } or:^{
                        [cp label:[x at:r :c] with:0];
                     }];
                  }
               }
            }
            @autoreleasepool {
               [[x range:0] enumerateWithBlock:^(ORInt i) {
                  printf("|");
                  [[x range:1] enumerateWithBlock:^(ORInt j) {
                     printf("%c",[cp intValue:[x at:i :j]] == 0 ? ' ' : '#');
                  }];
                  printf("|\n");
               }];
            }
         }];
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}
