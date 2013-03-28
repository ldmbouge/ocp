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
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
      ORInt n = argc >= 2 ? atoi(argv[1]) : 5;
      id<ORIntRange> dom = RANGE(model,0,10*n);
      id<ORIntRange> R   = RANGE(model,0,n);
      id<ORIntVarArray> y = [ORFactory intVarArray:model range:R domain:dom];
      id<ORIntVarArray> x = [ORFactory intVarArray:model range:R domain:dom];
      for(ORInt i=2;i<=n;i++)
         [model add:[[y[i-1] sub:y[i]] leq:@0]];

      for(ORInt i=1;i<=n;i++)
         [model add:[[y[0] sub:y[i]] leq:@(n-i+1)]];
      
      [model add:[[y[n] sub:x[0]] leq:@0]];
      
      for(ORInt i=1;i<=n-1;i++) {
         for(ORInt j=i+1;j<=n;j++) {
            [model add:[[x[i] sub:x[j]] leq:@0]];
         }
      }
      [model add:[y[0] geq:@(n)]];
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^{
         [cp labelArray:[model intVars]];
         @autoreleasepool {
            NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
            [buf appendString:@"["];
            for(ORInt k=0;k<=n;k++)
               [buf appendFormat:@"%d%c",[x[k] value],k < n ? ',' : ']'];
            NSLog(@"x = %@",buf);
            buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
            [buf appendString:@"["];
            for(ORInt k=0;k<=n;k++)
               [buf appendFormat:@"%d%c",[y[k] value],k < n ? ',' : ']'];
            NSLog(@"y = %@",buf);
         }
      }];
      
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

