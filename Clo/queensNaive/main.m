/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/ORProgramFactory.h>
#import "ORCmdLineArgs.h"

NSString* indent(int t)
{
   NSMutableString* tab = [NSMutableString stringWithCapacity:64];
   for(int i=0;i<t;i++)
      [tab appendString:@"   "];
   return tab;
}
int main (int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
      int n = [args size];
         
         id<ORModel> model = [ORFactory createModel];
         id<ORIntRange> R = RANGE(model,0,n-1);
         id<ORMutableInteger> nbSol = INTEGER(model,0);
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain: R];
         for(ORUInt i =0;i < n; i++) {
            for(ORUInt j=i+1;j< n;j++) {
               [model add: [x[i] neq: x[j]]];
               [model add: [x[i] neq: [x[j] plus: @(i-j)]]];
               [model add: [x[i] neq: [x[j] plus: @(j-i)]]];
            }
         }
         id<CPProgram> cp = [ORFactory createCPProgram: model];
         [cp clearOnSolution];
         [cp solveAll:
          ^() {
             [cp labelArray: x ];
//             @autoreleasepool {
//                NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
//                for(int i = 0; i < n; i++)
//                   [buf appendFormat:@"%d ",[cp intValue:x[i]]];
//                NSLog(@"sol [%d]: %@\n",[nbSol intValue:cp],buf);
//             }
             [nbSol incr:cp];
          }
          ];
         printf("GOT %d solutions\n",[nbSol intValue:cp]);
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult r = REPORT([nbSol intValue:cp], [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         
         return r;
      }];

   }
}
