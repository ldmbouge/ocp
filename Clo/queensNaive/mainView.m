/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORProgram/ORProgram.h>

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      //ORInt n = argc >= 2 ? atoi(argv[1]) : 8;
      ORInt n = 88;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl, 0, n-1);
      long startTime = [ORRuntimeMonitor cputime];
      id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value:0];
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range:R domain: R];
//      id<ORIntVarArray> xp = [ORFactory intVarArray:mdl range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:mdl var:[x at: i] shift:i]; }];
//      id<ORIntVarArray> xn = [ORFactory intVarArray:mdl range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:mdl var:[x at: i] shift:-i]; }];
      
      for(ORUInt i =0;i < n; i++) {
         for(ORUInt j=i+1;j< n;j++) {
            [mdl add: [ORFactory notEqual:mdl  var:[x at:i]   to:[x at: j]]];
            [mdl add: [ORFactory notEqual:mdl  var:[x at: i]  to:[x at: j] plus:i-j]];
            [mdl add: [ORFactory notEqual:mdl  var:[x at: i]  to:[x at: j] plus:j-i]];
         }
      }
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      //id<CPHeuristic> h2 = [cp createIBS];
      //   id<CPHeuristic> h2 = [cp createDDeg];
      //   id<CPHeuristic> h2  = [cp createWDeg];
      //id<CPHeuristic> h2 = [cp createFF];
      [cp solve:
       ^() {
          //[cp labelArrayFF:x];
          //[cp labelHeuristic:h2];
          [cp forall:R suchThat:^ORBool(ORInt i) { return ![cp bound:x[i]];} orderedBy:^ORInt(ORInt i) { return [cp domsize:x[i]];} do:^(ORInt i) {
             [cp tryall:R suchThat:^ORBool(ORInt v) { return [cp member:v in:x[i]];}
                     in:^(ORInt v) {
                [cp label:x[i] with:v];
             } onFailure:^(ORInt v) {
                [cp diff: x[i] with: v];
             }];
          }];
          [nbSolutions incr:cp];
       }
       ];
      printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
      long endTime = [ORRuntimeMonitor cputime];
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      NSLog(@"Total runtime: %ld\n",endTime - startTime);
   }
   return 0;
}

