/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>

#import "ORCmdLineArgs.h"
//345 choices
//254 fail
//5027 propagations
// First solution
// 22 choices 20 fail 277 propagations

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         ORInt n = [args size];
         id<ORModel> mdl = [ORFactory createModel];
         id<ORIntRange> R = RANGE(mdl,1,n);
         id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
         id<ORAnnotation> note = [ORFactory annotation];
         [note dc:[mdl add: [ORFactory alldifferent: x]]];
         [note dc:[mdl add: [ORFactory alldifferent: All(mdl, ORExpr, i, R, [x[i] plus:@(i)])]]];
         [note dc:[mdl add: [ORFactory alldifferent: All(mdl, ORExpr, i, R, [x[i]  sub:@(i)])]]];
         id<CPProgram> cp = [args makeProgram:mdl annotation:note];
         //id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemBDSController class]];
         //id<CPProgram> cp = [ORFactory createCPSemanticProgram:mdl with:[ORSemDFSController class]];
         //id<CPProgram> cp = [ORFactory createCPProgram: mdl];
         //id<CPProgram> cp = [ORFactory createCPMultiStartProgram: mdl nb: 2];
         //id<CPProgram> cp = [ORFactory createCPParProgram:mdl nb:2 with:[ORSemDFSController class]];
         //id<CPHeuristic> h = [args makeHeuristic:cp restricted:x];
         [cp clearOnSolution];
         __block ORInt nbSol = 0;
         NSLog(@"model: %@",mdl);
         [cp solveAll:
          ^() {
             //[cp labelHeuristic:h];
             [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize: x[i]];}];
             //[cp labelArray: x];
             /*
             id* gamma = [cp gamma];
             id<CPIntVarArray> cx = gamma[x.getId];
             for(ORInt i=1;i<=n;i++) {
                while (![cp bound:x[i]]) {
                   ORInt v = [cp min:x[i]];
                   [cp try:^{
                      NSLog(@"%@-lbl(%d,%d) = %@",tab(i),i,v,cx);
                      [cp label:x[i] with:v];
                      NSLog(@"%@+lbl(%d,%d) = %@",tab(i),i,v,cx);
                   } or:^{
                      NSLog(@"%@-dif(%d,%d) = %@",tab(i),i,v,cx);
                      [cp diff:x[i] with:v];
                      NSLog(@"%@+dif(%d,%d) = %@",tab(i),i,v,cx);
                   }];
                }
             }
              */
             @synchronized(cp) {
                nbSol++;
/*                for(ORInt i = 1; i <= 8; i++)
                   printf("%d ",[cp intValue: x[i]]);
                printf("\n");*/
             }
             //[[cp explorer] fail];
          }];
         printf("GOT %d solutions\n",nbSol);
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT(nbSol, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return r;
      }];
   }
   return 0;
}


int main0(int argc, const char * argv[])
{
   @autoreleasepool {
      ORInt n = 8;
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> R = RANGE(mdl,1,n);
      id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
      id<ORIntVarArray> x = [ORFactory intVarArray:mdl range: R domain: R];
      id<ORIntVarArray> xp = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:i]);
      id<ORIntVarArray> xn = All(mdl,ORIntVar,i,R,[ORFactory intVar:mdl var:x[i] shift:-i]);
      id<ORAnnotation> note = [ORFactory annotation];
      [note bc:[mdl add: [ORFactory alldifferent: x]]];
      [note bc:[mdl add: [ORFactory alldifferent: xp]]];
      [note bc:[mdl add: [ORFactory alldifferent: xn]]];
//      id<CPProgram> cp = [ORFactory createCPProgram: mdl];
      id<CPProgram> cp = [ORFactory createCPParProgram:mdl nb:1 annotation:note with:[ORSemDFSController class]];
      __block ORInt nbSol = 0;
      [cp solveAll:
       ^() {
          [cp switchOnDepth: ^{ [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize: x[i]];}]; }
                         to: ^{
                            NSLog(@"I switched \n");
                            for(ORInt i = 1; i <= 8; i++)
                               printf("%d-%d ",[cp min:x[i]],[cp max:x[i]]);
                            printf("\n");
                            [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [cp domsize: x[i]];}];
                         }
                      limit: 4
           ];
          for(ORInt i = 1; i <= 8; i++)
             printf("%d ",[cp intValue: x[i]]);
          printf("\n");
          nbSol++;
          [nbSolutions incr: cp];
       }
       ];
      printf("GOT %d solutions\n",nbSol);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [ORFactory shutdown];
   }
   return 0;
}

