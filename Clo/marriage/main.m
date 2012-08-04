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

int main(int argc, const char * argv[])
{
   @autoreleasepool {
   
      id<CPSolver> cp = [CPFactory createSolver];
      enum Men   { Richard = 1,James = 2,John = 3,Hugh = 4,Greg = 5 };
      enum Women { Helen = 1,Tracy = 2, Linda = 3,Sally = 4,Wanda = 5 };
      id<ORIntRange> RMen   = RANGE(cp,1,5);
      id<ORIntRange> RWomen = RANGE(cp,1,5);
      CPInt  rankM[5][5] = {{5,1,2,4,3},
         {4,1,3,2,5},
         {5,3,2,4,1},
         {1,5,4,3,2},
         {4,3,2,1,5}};
      
      CPInt rankW[5][5] = {{1,2,4,3,5},
         {3,5,1,2,4},
         {5,4,2,1,3},
         {1,3,5,4,2},
         {4,2,3,5,1}};
      CPInt* rankMPtr = (CPInt*)rankM;
      CPInt* rankWPtr = (CPInt*)rankW;
      
     
      id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
      
      
      id<CPIntVarArray> husband = [CPFactory intVarArray: cp range:RWomen domain: RMen];
      id<CPIntVarArray> wife    = [CPFactory intVarArray: cp range:RMen domain: RWomen];
      id<CPIntArray>* rm = malloc(sizeof(id<CPIntArray>)*5);
      id<CPIntArray>* rw = malloc(sizeof(id<CPIntArray>)*5);
      for(CPInt m=RMen.low;m <= RMen.up;m++)
         rm[m] = [CPFactory intArray:cp range:RWomen with:^ORInt(ORInt w) { return rankMPtr[(m-1) * 5 + w-1];}];
      for(CPInt w=RWomen.low;w <= RWomen.up;w++) 
         rw[w] = [CPFactory intArray:cp range:RMen with:^ORInt(ORInt m) { return rankWPtr[(w-1) * 5 + m-1];}];
      
      [cp solveAll:^{
         for(CPInt i=RMen.low;i <= RMen.up;i++)
            [cp add: [husband elt: wife[i]] eqi: i];
         for(CPInt i=RWomen.low;i <= RWomen.up;i++)
            [cp add: [wife elt: husband[i]] eqi: i];
         
         for(CPInt m=RMen.low;m <= RMen.up;m++) {
            for(CPInt w=RWomen.low;w <= RWomen.up;w++) {
               [cp add: [[[rm[m] elt:wife[m]] gti: [rm[m] at:w]] imply: [[rw[w] elt:husband[w]] lti: [rw[w] at:m]]]];
               [cp add: [[[rw[w] elt:husband[w]] gti: [rw[w] at:m]] imply: [[rm[m] elt:wife[m]] lti: [rm[m] at:w]]]];
            }
         }
      } using:^{
         NSLog(@"Start...");
         [CPLabel array:husband orderedBy:^ORInt(ORInt i) { return [husband[i] domsize];}];
         [CPLabel array:wife orderedBy:^ORInt(ORInt i) { return [wife[i] domsize];}];
         [nbSolutions incr];
         NSLog(@"Solution: H:%@",husband);
         NSLog(@"Solution: W:%@",wife);
      }];
      NSLog(@"#solutions: %@",nbSolutions);
      NSLog(@"Solver: %@",cp);
      [cp release];
      [CPFactory shutdown];
   }
   return 0;
}
