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

void makeLimit(int md,int d,id<CPProgram> cp,ORClosure c)
{
   if (d >= md)
      c();
   else {
      [cp limitCondition:^bool{
         return false;
      } in:^{
         makeLimit(md, d+1, cp, c);
      }];
   }
}

int test0(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         
         ORInt n = [args size];
         ORInt l = [args nArg];
         id<ORIntRange> R = RANGE(model,1,n);
         id<ORIntRange> D = RANGE(model,0,1);
         id<ORIntVarArray> x = [ORFactory intVarArray: model range: R domain: D];
         __block ORInt nbSol = 0;
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         [cp solveAll:^{
            makeLimit(l, 0, cp, ^{
               [cp labelArray:x];
               nbSol++;
               [[cp explorer] fail];
            });
         }];
         NSLog(@"Solver %@",cp);
         NSLog(@"#sol: %d",nbSol);
         struct ORResult res = REPORT(l, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

int test0Q(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         ORInt n = [args size];
         ORInt l = [args nArg];
         id<ORModel> model = [ORFactory createModel];         
         id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
         id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
         id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) {
            return [ORFactory intVar:model var:[x at: i] shift:i];
         }];
         id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) {
            return [ORFactory intVar:model var:[x at: i] shift:-i];
         }];
         [model add: [ORFactory alldifferent: x]];
         [model add: [ORFactory alldifferent: xp]];
         [model add: [ORFactory alldifferent: xn]];
         
         __block ORInt nbSol = 0;
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         [cp solveAll:^{
            makeLimit(l, 0, cp, ^{
               [cp labelArray:x orderedBy:^ORFloat(ORInt i) {return [cp domsize:x[i]];}];
               nbSol++;
               [[cp explorer] fail];
            });
         }];
         NSLog(@"Solver %@",cp);
         NSLog(@"#sol: %d",nbSol);
         struct ORResult res = REPORT(l, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

void makePF(int md,int d,int sl,id<CPProgram> cp,ORClosure c)
{
   if (d >= md)
      c();
   else {
      [cp portfolio: ^{
         [cp limitSolutions:sl in: c];
       }
               then: ^{
                  makePF(md,d+1,sl,cp,c);
               }
       ];
   }
}
int test1(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         
         ORInt n = [args size];
         ORInt l = [args nArg];
         id<ORIntRange> R = RANGE(model,1,n);
         id<ORIntRange> D = RANGE(model,0,1);
         id<ORIntVarArray> x = [ORFactory intVarArray: model range: R domain: D];
         __block ORInt nbSol = 0;
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         [cp solveAll:^{
            makePF(l,0,65534,cp, ^{
               [cp labelArray:x];
               nbSol++;
            });
         }];
         NSLog(@"Solver %@",cp);
         NSLog(@"#sol: %d",nbSol);
         struct ORResult res = REPORT(l, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

int test1Q(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         ORInt n = [args size];
         ORInt l = [args nArg];
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
         id<ORIntVarArray> x  = [ORFactory intVarArray:model range:R domain: R];
         id<ORIntVarArray> xp = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) {
            return [ORFactory intVar:model var:[x at: i] shift:i];
         }];
         id<ORIntVarArray> xn = [ORFactory intVarArray:model range:R with: ^id<ORIntVar>(ORInt i) {
            return [ORFactory intVar:model var:[x at: i] shift:-i];
         }];
         [model add: [ORFactory alldifferent: x]];
         [model add: [ORFactory alldifferent: xp]];
         [model add: [ORFactory alldifferent: xn]];
         
         __block ORInt nbSol = 0;
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         [cp solveAll:^{
            //[cp labelArray:x orderedBy:^ORFloat(ORInt i) {return [cp domsize:x[i]];}];nbSol++;
            makePF(l,0,14199,cp, ^{
               [cp labelArray:x orderedBy:^ORFloat(ORInt i) {return [cp domsize:x[i]];}];
               nbSol++;
            } );
            [[cp explorer] fail];
         }];

         NSLog(@"Solver %@",cp);
         NSLog(@"#sol: %d",nbSol);
         struct ORResult res = REPORT(l, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}


int main(int argc, const char * argv[])
{
   if (strncmp(argv[1],"-b0",3) == 0)
      test0(argc,argv);
   else if (strncmp(argv[1],"-b1",3) == 0)
      test1(argc,argv);
   else if (strncmp(argv[1],"-b2",3) == 0)
      test0Q(argc,argv);
   else if (strncmp(argv[1],"-b3",3) == 0)
      test1Q(argc,argv);
}
