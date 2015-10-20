/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <ORProgram/ORProgram.h>

int main_alldiff(int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORAnnotation> notes = [ORFactory annotation];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORIntRange> ER = RANGE(mdl,-2*n,2*n);
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      id<ORIntVarArray> xp = [ORFactory intVarArray:mdl range: R domain: ER];
      id<ORIntVarArray> xn = [ORFactory intVarArray:mdl range: R domain: ER];
      
      for(ORInt i = 1; i <= n; i++) {
         [mdl add: [xp[i] eq: [x[i] plus: @(i)]]];
         [mdl add: [xn[i] eq: [x[i] sub: @(i)]]];
      }
      
      [notes dc:[mdl add: [ORFactory alldifferent: x  ]]];
      [notes dc:[mdl add: [ORFactory alldifferent: xp ]]];
      [notes dc:[mdl add: [ORFactory alldifferent: xn ]]];
          
      id<CPProgram> cp = [ORFactory createCPProgram: mdl annotation:notes];
      
      ORLong startTime = [ORRuntimeMonitor wctime];
      __block ORInt nbSol = 0;
          
      [cp solveAll:
       ^() {
          [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return [cp domsize: x[i]];}];
          @synchronized(cp) {
             nbSol++;
          }
       }
       ];
      printf("GOT %d solutions\n",nbSol);
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
      
   }
   return 0;
}


NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}

int main_neq(int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      
      for(ORInt i = 1; i <= n; i++)
         for(ORInt j = i+1; j <= n; j++) {
            [mdl add: [x[i] neq: x[j]]];
            [mdl add: [[x[i] plus: @(i)] neq: [x[j] plus: @(j)]]];
            [mdl add: [[x[i] sub: @(i)] neq: [x[j] sub: @(j)]]];
         }
      
      id<ORVarLitterals> l = [ORFactory varLitterals: mdl var: x[1]];
      NSLog(@"literals: %@",l);
      id<ORAnnotation> notes = [ORFactory annotation];
      id<CPProgram> cp = [ORFactory createCPLinearizedProgram: mdl annotation:notes];
      
      ORLong startTime = [ORRuntimeMonitor wctime];
      __block ORInt nbSol = 0;
      //id* gamma = [cp gamma];
      [cp solveAll:
       ^() {
          [cp labelArray:x orderedBy:  ^ORDouble(ORInt i) { return [cp domsize:x[i]];} ];
/*          [cp forall:x.range orderedBy:^ORInt(ORInt i) {
             return [cp domsize:x[i]];
          } do:^(ORInt i) {
             while (![cp bound:x[i]]) {
                int min = [cp min:x[i]];
                [cp try:^{
                   NSLog(@"%@x[%d] == %d",tab(i),i,min);
                   [cp label:x[i] with:min];
                } or:^{
                   NSLog(@"%@x[%d] != %d",tab(i),i,min);
                   NSLog(@"***x3 = %@",gamma[x[3].getId]);
                   [cp diff:x[i] with:min];
                   NSLog(@"***x3 = %@",gamma[x[3].getId]);
                }];
                NSLog(@"x3 = %@",gamma[x[3].getId]);
                NSLog(@"x4 = %@",gamma[x[4].getId]);
                NSLog(@"x5 = %@",gamma[x[5].getId]);
                NSLog(@"x6 = %@",gamma[x[6].getId]);
             }
          }];*/
          //[cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return [cp domsize: x[i]];}];
          id<ORIntArray> sa = [ORFactory intArray:cp range:x.range with:^ORInt(ORInt k) {
             return [cp intValue:x[k]];
          }];
          NSLog(@"Solution: %@",sa);
          //id av = [[cp engine] variables];
          //NSLog(@"AV = %@",av);
          @synchronized(cp) {
             nbSol++;
          }
       }
       ];
      printf("GOT %d solutions\n",nbSol);
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [ORFactory shutdown];
   }
   return 0;
}

int main(int argc, const char * argv[])
{
   return main_neq(argc,argv);
}
