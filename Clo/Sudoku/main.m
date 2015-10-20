/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/ORProgram.h>

void show(id<CPProgram> cp,id<ORIntVarMatrix> m)
{
    id<ORIntRange> R = [m range: 0];
    id<ORIntRange> C = [m range: 1];
    for(ORInt i = [R low] ; i <= [R up]; i++) {
        for(ORInt j = C.low ; j <= C.up; j++) 
            printf("%d  ",[cp intValue:[m at: i : j]]);
        printf("\n");   
    }
    printf("\n");
}

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      FILE* f = fopen("sudokuFile3.txt","r");
      int nb;
      int r, c, v;
      fscanf(f,"%d \n",&nb);
      printf("number of entries %d \n",nb);
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,9);
      id<ORIntVarMatrix> x = [ORFactory intVarMatrix: mdl range: R : R domain: R];
      id<ORIntVarArray> a  = [ORFactory intVarArray: mdl range: R : R with: ^id<ORIntVar>(ORInt i,ORInt j) { return [x at: i : j]; }];
      for(ORInt i = 0; i < nb; i++) {
         fscanf(f,"%d%d%d",&r,&c,&v);
         [mdl  add: [[x at: r : c] eq: @(v)]];
      }
      for(ORInt i = 1; i <= 9; i++)
         [mdl add: [ORFactory alldifferent: [ORFactory intVarArray: mdl range: R with: ^id<ORIntVar>(ORInt j) { return [x at: i : j]; }]]];
      for(ORInt j = 1; j <= 9; j++)
         [mdl add: [ORFactory alldifferent: [ORFactory intVarArray: mdl range: R with: ^id<ORIntVar>(ORInt i) { return [x at: i : j]; }]]];
      for(ORInt i = 0; i <= 2; i++)
         for(ORInt j = 0; j <= 2; j++)
            [mdl add: [ORFactory alldifferent: [ORFactory intVarArray: mdl
                                                               range: RANGE(mdl,i*3+1,i*3+3)
                                                                    : RANGE(mdl,j*3+1,j*3+3)
                                                                with: ^id<ORIntVar>(ORInt r,ORInt c) { return [x at: r : c]; }]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      [cp solve:
       ^() {
          [cp labelArray: a orderedBy: ^ORDouble(ORInt i) { return [cp domsize:a[i]];}];
          show(cp,x);
       }
       ];
      
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [ORFactory shutdown];
   }
   return 0;
}

