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

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      NSLog(@"args: %d %s %s %s %s",argc,argv[0],argv[1],argv[2],argv[3]);
      ORInt base = argc >= 2 ? atoi(argv[1]) : 2;
      ORInt n    = argc >= 3 ? atoi(argv[2]) : 4;
      ORInt m    = argc >= 4 ? atoi(argv[3]) : pow(base,n);
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
         [model add: [x[i] eq: Sum(model, j, RANGE(model,1,n), [[binary at:i :j] muli: (ORInt)pow(base,n-j)])]];
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
         [model add:[Sum(model, j, RANGE(model,1,m), [code[j] eqi:i]) eq:gcc[i]]];
      
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      __block ORInt nbSol = 0;
      [cp solve:^{
         NSLog(@"searching...");
         [cp labelArray:x];
         @autoreleasepool {
            NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
            [buf appendString:@"x = ["];
            for(ORInt i=1;i<=m;i++)
               [buf appendFormat:@"%d%c",[x[i] value],i < m ? ',' : ']'];
            NSLog(@"solution: %@",buf);
         }
         nbSol++;
      }];
      NSLog(@"#sol: %d",nbSol);
      NSLog(@"Stats: %@",cp);
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

