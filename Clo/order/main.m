/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor cputime];
      id<ORModel> model = [ORFactory createModel];
      ORInt n = argc > 2 ? atoi(argv[1]) : 10;
      id<ORIntRange> D = RANGE(model,0,n);
      id<ORIntVarArray> x = [ORFactory intVarArray:model range:D domain:D];
      id<ORGroup> g = [ORFactory bergeGroup:model];
      [D enumerateWithBlock:^(ORInt k) {
         if (k < n)
            [g add:[x[k] lt:x[k+1]]];
      }];
      [model add:g];
      //NSLog(@"Group: %@",g);
      //NSLog(@"MODEL %@",model);
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^{
         NSLog(@"About to search...");
         @autoreleasepool {
            id<ORIntArray> xv = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) {
               return [cp intValue:x[i]];
            }];
            NSLog(@"solution: %@",xv);
         }
      }];
      ORLong endTime = [ORRuntimeMonitor cputime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

