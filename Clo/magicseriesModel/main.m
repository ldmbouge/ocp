/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFactory.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORModeling/ORModeling.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPFactory.h>

#import <ORProgram/ORProgramFactory.h>
#import "ORCmdLineArgs.h"


NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}

int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORInt n = [args size];
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> R = [ORFactory intRange: model low: 0 up: n-1];
         id<ORIntVarArray> x = [ORFactory intVarArray: model range: R domain: R];
         //[model add: [Sum(model,i,R,[x[i] mul: @(i)]) eq: @(n) ]];
         for(ORInt i=0;i<n;i++)
            [model add: [Sum(model,j,R,[x[j] eq: @(i)]) eq: x[i] ]];
         
         id<CPProgram> cp = [ORFactory createCPProgram: model];
         
         [cp solveAll: ^{
            //NSLog(@"BASIC: %@",[[cp engine] model]);
            [cp  labelArray: x];
            //         id* gamma = [cp gamma];
            //         id<CPIntVarArray> cx = gamma[x.getId];
            //         for(ORInt i=0;i<n;i++) {
            //            while(![cp bound:x[i]]) {
            //               ORInt v = [cp min:x[i]];
            //               [cp try:^{
            //                  NSLog(@"%@ -label(%d) s = %@",tab(i),i,cx);
            //                  [cp label:x[i] with:v];
            //                  NSLog(@"%@ +label(%d) s = %@",tab(i),i,cx);
            //               } or:^{
            //                  NSLog(@"%@ -diff(%d)  s = %@",tab(i),i,cx);
            //                  [cp diff:x[i] with:v];
            //                  NSLog(@"%@ +diff(%d)  s = %@",tab(i),i,cx);
            //               }];
            //            }
            //         }
            
            
            printf("Succeeds \n");
            for(ORInt i = 0; i < n; i++)
               printf("%d ",[cp intValue:x[i]]);
            printf("\n");
         }
          ];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(1, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

