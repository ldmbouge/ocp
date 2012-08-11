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
      printf("x.min = %d \n",x.min);
      printf("x.max = %d \n",y.max);
      printf("x.bound = %d \n",y.bound);
       // insert code here...
       NSLog(@"Hello, World!");
      [cp solve: ^{
         for(ORInt i = 0; i <= 10; i++) 
//            printf("instantiating variable %d \n",i);
            [CPLabel var: (id<ORIntVar>) [a[i] dereference]];
      }];
      for(ORInt i = 0; i <= 10; i++)
         printf("x[%d] = %d \n",i,[a[i] value]);
   }
    return 0;
}

