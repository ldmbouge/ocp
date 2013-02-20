/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORConcretizer.h>

enum Heuristic {
   FF = 0,
   ABS = 1,
   IBS = 2,
   WDEG = 3,
   DDEG = 4
};
const char* hName[] = {"FF","ABS","IBS","WDeg","DDeg"};

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      ORLong startCPU = [ORRuntimeMonitor cputime];
      id<ORModel> model = [ORFactory createModel];
      [ORStreamManager setRandomized];
      ORInt n = 4;
      ORFloat rf = 1.0;
      ORInt t = 60;
      ORInt r = 0;
      enum Heuristic hs = ABS;
      for(int k = 1;k< argc;k++) {
         if (strncmp(argv[k], "-q", 2) == 0)
            n = atoi(argv[k]+2);
         else if (strncmp(argv[k], "-h", 2)==0)
            hs = atoi(argv[k]+2);
         else if (strncmp(argv[k],"-w",2)==0)
            rf = atof(argv[k]+2);
         else if (strncmp(argv[k],"-t",2)==0)
            t = atoi(argv[k]+2);
         else if (strncmp(argv[k],"-r",2)==0)
            r = atoi(argv[k]+2);
      }
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

      id<ORInteger> nbRestarts = [ORFactory integer: model value:0];
      id<ORInteger> nbFailures = [ORFactory integer: model value:rf == 1.0 ? MAXINT : 3 * n];
      ORLong maxTime =  t * 1000;
      
      id<CPProgram> cp = [ORFactory createCPProgram: model];
      id<CPHeuristic> h = nil;
      __block BOOL found = NO;
      switch(hs) {
         case FF:   h = [ORFactory createFF:cp];break;
         case IBS:  h = [ORFactory createIBS:cp];break;
         case ABS:  h = [ORFactory createABS:cp];break;
         case WDEG: h = [ORFactory createWDeg:cp];break;
         case DDEG: h = [ORFactory createDDeg:cp];break;
      }
      [cp solve:^{
         [cp limitTime:maxTime in: ^ {
            [cp repeat:^{
               [cp limitFailures:[nbFailures value] in: ^ {
                  [cp labelHeuristic:h];
                  @autoreleasepool {
                     for(ORInt i =1;i <= n;i++) {
                        NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
                        for (ORInt j=1; j<=n; j++) {
                           [buf appendFormat:@"%3d ",[[s at:i :j] value]];
                        }
                        NSLog(@"%@",buf);
                     }
                  }
                  found = YES;
               }];
            } onRepeat:^{
               [nbFailures setValue:(float)[nbFailures value] * rf];
               [nbRestarts incr];
               NSLog(@"Hit failure limit. Failure limit now: %@ / %@",nbFailures,nbRestarts);
            }];
         }];
         
      }];
      
      ORLong endTime = [ORRuntimeMonitor wctime];
      ORLong endCPU  = [ORRuntimeMonitor cputime];
      NSLog(@"Execution Time(WC) : %lld \n",endTime - startTime);
      NSLog(@"Execution Time(CPU): %lld \n",endCPU - startCPU);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      printf("%d %s %d %d %f %d %lld %lld\n",r,hName[hs],n,found ? 1 : 0,rf,[cp nbFailures],endTime - startTime,endCPU - startCPU);
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

