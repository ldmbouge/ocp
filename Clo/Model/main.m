/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CP.h>
#import <objcp/CPLabel.h>

int main(int argc, const char * argv[])
{

   @autoreleasepool {
      
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> R = [ORFactory intRange: model low: 0 up: 10];
      id<ORIntVar> x = [ORFactory intVar: model domain: R];
      id<ORIntVar> y = [ORFactory intVar: model domain: R];
      id<ORIntVarArray> a = [ORFactory intVarArray: model range: R domain: R];
      id<ORConstraint> cstr = [ORFactory alldifferent: a];
      [model add: cstr];
      printf("x.id = %d \n",x.getId);
      printf("x.id = %d \n",y.getId);
      printf("a[0].id = %d \n",a[0].getId);
      printf("a[1].id = %d \n",a[1].getId);
      printf("cstr.id = %d \n",cstr.getId);
      
      id<CPSolver> cp = [CPFactory createSolver];
      [model instantiate: cp];
       // insert code here...
       NSLog(@"Hello, World!");
      
   }
    return 0;
}

