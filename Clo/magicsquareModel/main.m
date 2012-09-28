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

enum Heuristic {
   FF = 0,
   ABS = 1,
   IBS = 2,
   WDEG = 3,
   DDEG = 4
};
int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
      [ORStreamManager setRandomized];
      ORInt n = 4;
      enum Heuristic hs = FF;
      for(int k = 1;k< argc;k++) {
         if (strncmp(argv[k], "-q", 2) == 0)
            n = atoi(argv[k]+2);
         else if (strncmp(argv[k], "-h", 2)==0)
            hs = atoi(argv[k]+2);
      }
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
      id<ORInteger> nbRestarts = [ORFactory integer: model value:0];
      id<ORInteger> nbFailures = [ORFactory integer: model value:3 * n];
      ORLong maxTime =  100;
      id<CPSolver> cp = [CPFactory createSolver];
      [cp addModel:model];
      //id<CPHeuristic> h = [CPFactory createIBS:cp];
      //id<CPHeuristic> h = [CPFactory createFF:cp];
      id<CPHeuristic> h = nil;
      switch(hs) {
         case FF: h = [CPFactory createFF:cp];break;
         case IBS: h = [CPFactory createIBS:cp];break;
         case ABS: h = [CPFactory createABS:cp];break;
         case WDEG: h = [CPFactory createWDeg:cp];break;
         case DDEG: h = [CPFactory createDDeg:cp];break;
      }
     
      [cp solve:^{
         [cp limitTime:maxTime in: ^ {
            [cp repeat:^{
               [cp limitFailures:[nbFailures value] in: ^ {
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
            } onRepeat:^{
               [nbFailures setValue:(float)[nbFailures value] * 1.1];
               [nbRestarts incr];
               NSLog(@"Hit failure limit. Failure limit now: %@ / %@",nbFailures,nbRestarts);
            }];
         }];
         
      }];
      
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      printf("result: %d %lld\n",[cp nbFailures],endTime - startTime);
      [cp release];
      [CPFactory shutdown];      
   }
   return 0;
}

