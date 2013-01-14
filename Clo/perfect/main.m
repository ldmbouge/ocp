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
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
      ORInt   s    = 112;
      id<ORIntRange> sidel = RANGE(model,1,s);
      id<ORIntRange> square = RANGE(model,0,20);
      ORInt* side = (ORInt[]){50,42,37,35,33,29,27,25,24,19,18,17,16,15,11,9,8,7,6,4,2};
      
      id<ORIntVarArray> x = [ORFactory intVarArray:model range:square domain:sidel];
      id<ORIntVarArray> y = [ORFactory intVarArray:model range:square domain:sidel];
      [square enumerateWithBlock:^(ORInt i) {
         [model add:[x[i] leqi:s - side[i] + 1]];
         [model add:[y[i] leqi:s - side[i] + 1]];
      }];
      [square enumerateWithBlock:^(ORInt i) {
         [square enumerateWithBlock:^(ORInt j) {
            if (i < j) {
               [model add: [[[[[x[i] plusi:side[i]]  leq:x[j]] or:
                              [[x[j] plusi:side[j]]  leq:x[i]]] or:
                             [[y[i] plusi:side[i]]  leq:y[j]]] or:
                            [[y[j] plusi:side[j]]  leq:y[i]]]];
            }
         }];
      }];
      NSLog(@"model: %@",model);
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      ORLong endTime = [ORRuntimeMonitor wctime];      
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

