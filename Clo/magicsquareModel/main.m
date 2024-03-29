/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>
#import "ORCmdLineArgs.h"

ORBool mustGoon(id<ORModel> m,ORBool* b)
{
  ORBool rv;
  @synchronized(m) {
    rv = !*b;
  }
  return rv;
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult() {
         ORInt n = [args size];
         ORDouble rf = [args restartRate];
         ORInt t = [args timeOut];
        
         id<ORModel> model = [ORFactory createModel];
         id<ORAnnotation> notes = [ORFactory annotation];
         id<ORIntRange>  R = [ORFactory intRange:model low:1 up:n];
         id<ORIntRange>  D = [ORFactory intRange:model low:1 up:n*n];
         ORInt T = n * (n*n + 1)/2;
         id<ORIntVarMatrix> s = [ORFactory intVarMatrix:model range:R :R domain:D];
         [notes dc:[model add:[ORFactory alldifferent:All2(model, ORIntVar, i, R, j, R, [s at:i :j])]]];
         for(ORInt i=1;i <= n;i++) {
            [model add:[Sum(model, j, R, [s at:i :j]) eq: @(T)]];
            [model add:[Sum(model, j, R, [s at:j :i]) eq: @(T)]];
         }
         [model add:[Sum(model, i, R, [s at:i :i]) eq: @(T)]];
         [model add:[Sum(model, i, R, [s at:i :n-i+1]) eq: @(T)]];
         for(ORInt i=1;i<=n-1;i++) {
            [model add:[[s at:i :i]     lt:[s at:i+1 :i+1]]];
            [model add:[[s at:i :n-i+1] lt:[s at:i+1 :n-i]]];
         }
         [model add:[[s at:1 :1] lt: [s at: 1 :n]]];
         [model add:[[s at:1 :1] lt: [s at: n :1]]];
         
         id<ORMutableInteger> nbRestarts = [ORFactory mutable: model value:0];
         id<ORMutableInteger> nbFailures = [ORFactory mutable: model value:rf <= 1.0 ? MAXINT : 3 * n];
         ORLong maxTime =  t * 1000;
         
         id<CPProgram> cp = [args makeProgram:model];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:nil];
         ORBool* found = malloc(sizeof(ORBool));
         *found = NO;
         [cp solve:^{
            [cp limitTime:maxTime in: ^ {
               while (mustGoon(model,found)) {
                  [cp perform:^{
                     [cp limitFailures:[nbFailures intValue:cp] in: ^ {
                        [cp labelHeuristic:h];
                        @autoreleasepool {
                           for(ORInt i =1;i <= n;i++) {
                              NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
                              for (ORInt j=1; j<=n; j++) {
                                 [buf appendFormat:@"%3d ",[cp intValue:[s at:i :j]]];
                              }
                              NSLog(@"%@",buf);
                           }
                        }
                        @synchronized(model) {
                           *found = YES;
                        }
                     }];
                  } onLimit:^{
                     [nbFailures setValue:(double)[nbFailures intValue:cp] * rf in:cp];
                     [nbRestarts incr:cp];
                     NSLog(@"Hit failure limit. Failure limit now: %d / %d",[nbFailures intValue:cp],[nbRestarts intValue:cp]);
                  }];
               };
            }];
            
         }];
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult r = REPORT(*found, [cp nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return 0;
}

