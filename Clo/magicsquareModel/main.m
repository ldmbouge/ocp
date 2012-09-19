/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORFactory.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORSemBDSController.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
      [ORStreamManager setRandomized];
      ORInt n = 4;
      if (argc >= 2)
         n = atoi(argv[1]);
      id<ORIntRange>  R = [ORFactory intRange:model low:1 up:n];
      id<ORIntRange>  D = [ORFactory intRange:model low:1 up:n*n];
      ORInt T = n * (n*n + 1)/2;
      id<ORIntVarMatrix> s = [ORFactory intVarMatrix:model range:R :R domain:D];
      [model add:[ORFactory alldifferent:All2(model, ORIntVar, i, R, j, R, [s at:i :j])]];
      for(ORInt i=1;i <= n;i++) {
         [model add:[Sum(model, j, R, [s at:i :j]) eqi: T]];
         [model add:[Sum(model, j, R, [s at:j :i]) eqi: T]];
      }
      [model add:[Sum(model, i, R, [s at:i :i]) eqi: T]];
      [model add:[Sum(model, i, R, [s at:i :n-i+1]) eqi: T]];
      for(ORInt i=1;i<=n-1;i++) {
         [model add:[[s at:i :i]     lt:[s at:i+1 :i+1]]];
         [model add:[[s at:i :n-i+1] lt:[s at:i+1 :n-i]]];
      }
      [model add:[[s at:1 :1] lt: [s at: 1 :n]]];
      [model add:[[s at:1 :1] lt: [s at: n :1]]];
      NSLog(@"Model is: %@",model);
      
      id<CPSolver> cp = [CPFactory createSolver];
      [cp addModel:model];
      //id<CPHeuristic> h = [CPFactory createIBS:cp];
      //id<CPHeuristic> h = [CPFactory createFF:cp];
      id<CPHeuristic> h = [CPFactory createABS:cp];
      
      [cp solve:^{
         NSLog(@"Searching...");
         [CPLabel heuristic:h];
         @autoreleasepool {
            for(ORInt i =1;i <= n;i++) {
               NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
               for (ORInt j=1; j<=n; j++) {
                  [buf appendFormat:@"%3d ",[[s at:i :j] value]];
               }
               NSLog(@"%@",buf);
            }
         }
         
      }];
      
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [CPFactory shutdown];      
   }
   return 0;
}

