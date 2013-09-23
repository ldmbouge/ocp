/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         id<ORModel> model = [ORFactory createModel];
         ORInt base =  2;
         ORInt n    = [args size];
         ORInt m    = [args nArg];//pow(base,n);
         ORInt up   = (ORInt)pow(base,n)-1;
         NSLog(@"Params: n=%d m=%d base=%d",n,m,base);
         
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:RANGE(model,1,m) domain:RANGE(model,0,up)];
         id<ORIntVarMatrix> binary = [ORFactory intVarMatrix:model range:RANGE(model,1,m) :RANGE(model,1,n) domain:RANGE(model,0,base-1)];
         id<ORIntVarArray> code = [ORFactory intVarArray:model range:RANGE(model,1,m) domain:RANGE(model,0,base-1)];
         id<ORIntVarArray> gcc  = [ORFactory intVarArray:model range:RANGE(model,0,base-1) domain:RANGE(model,0,m)];
         
         [model add: [ORFactory alldifferent:x annotation:ValueConsistency]];
         for(ORInt i=2;i<=m;i++)
            [model add: [x[1] leq: x[i]]];
         for(ORInt i=1;i<=m;i++)
            [model add: [x[i] eq: Sum(model, j, RANGE(model,1,n), [[binary at:i :j] mul: @((ORInt)pow(base,n-j))])]];
         for(ORInt i=2;i<=m;i++) {
            for(ORInt j=2;j<=n;j++) {
               [model add: [[binary at:i-1 :j] eq:[binary at:i :j-1]]];
            }
         }
         for(ORInt j=2;j<=n;j++)
            [model add:[[binary at:m :j] eq: [binary at:1 :j-1]]];
         for(ORInt i=1;i<=m;i++)
            [model add:[code[i] eq:[binary at:i :1]]];
         
         for(ORInt i=0;i<base;i++)
            [model add:[Sum(model, j, RANGE(model,1,m), [code[j] eq:@(i)]) eq:gcc[i]]];
         
         
         id<CPProgram> cp = [ORFactory createCPProgram:model];
         __block ORInt nbSol = 0;
         [cp solveAll:^{
            //NSLog(@"MODEL: %@",[[cp engine] model]);
            NSLog(@"searching...");
            [cp labelArray:x];
//            @autoreleasepool {
//               NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
//               [buf appendString:@"x = ["];
//               for(ORInt i=1;i<=m;i++)
//                  [buf appendFormat:@"%d%c",[cp intValue:x[i]],i < m ? ',' : ']'];
//               NSLog(@"solution: %@",buf);
//            }
            nbSol++;
         }];
         NSLog(@"#sol: %d",nbSol);
         NSLog(@"Stats: %@",cp);
         struct ORResult res = REPORT(nbSol, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];

   }
   return 0;
}

