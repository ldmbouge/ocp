/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>

int main(int argc, const char * argv[])
{

   @autoreleasepool {
      
      id<ORModel> model = [ORFactory createModel];
      id<ORRealVar> x = [ORFactory floatVar: model low: 0 up: 100];
      id<ORRealVar> y = [ORFactory floatVar: model low: 0 up: 100];
      
      [model add: [x leq: y]];
      NSLog(@"x id: %d",[x getId]);
      NSLog(@"y id: %d",[y getId]);
   }
  
   return 0;
}

int oldMain(int argc, const char * argv[])
{
   
   @autoreleasepool {
      
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> R = [ORFactory intRange: model low: 0 up: 10];
      id<ORIntVarArray> a = [ORFactory intVarArray: model range: R domain: R];
      id<ORConstraint> cstr = [ORFactory alldifferent: a];
      
      
      [model add: cstr];
      
      id<CPCommonProgram> cp = [ORFactory createCPProgram:model];
      
      [cp solve: ^{
         [cp labelArray:a];
      }];
      for(ORInt i = 0; i <= 10; i++)
         printf("x[%d] = %d \n",i,[cp intValue:a[i]]);
      NSLog(@"Solver status: %@\n",cp);
      [ORFactory shutdown];
   }
   return 0;
}


