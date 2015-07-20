/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPFactory.h>
#import <objcp/objcp.h>
#import <ORProgram/CPSolver.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORSemBDSController.h>


int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<CPCommonProgram> m = [CPSolverFactory solver];
      //[ORStreamManager setRandomized];
      id<ORIntRange> R = RANGE(m,0,19);
      int* key = (int[]){10,10,8,8,5,5,5,10,5,5,5,5,5,5,5,5,5,5,5,5};
      id<ORSelect> select = [ORFactory select: m
                                        range: R
                                     suchThat: ^bool(ORInt i) { return YES;}
                                    orderedBy: ^ORFloat(ORInt i) {
                                       return key[i];
                                    }];
      int cnt[20];
      for(ORInt i=0;i<20;i++) cnt[i]=0;
      for(ORInt i=0;i< 10000000;i++) {
         ORInt idx = [select min];
         cnt[idx]++;
      }
      printf("c(");
      for(ORInt i=0;i<20;i++) {
         printf("%d%c",cnt[i],i<19 ? ',' : ')');
      }
      printf("\n");
   }
   return 0;
}

