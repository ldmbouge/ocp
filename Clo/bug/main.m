/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORProgram/ORProgramFactory.h>


int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORIntRange> D = RANGE(mdl,1,8);
      id<ORIntVar> x = [ORFactory intVar:mdl domain:D];
      id<ORIntVar> y = [ORFactory intVar:mdl domain:D];
      id<ORIntVar> b = [ORFactory intVar:mdl domain:RANGE(mdl,0,1)];

      [mdl add: [x gt: [[y sub: @3] sub: [b mul: @10000]]]];
      [mdl add: [x lt: [[y sub: @3] sub: [[b sub:@1] mul: @10000]]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id* gamma = [cp gamma];
      [cp solveAll:
       ^() {
          [cp lthen:x with:6];
          [cp label:y with:6];
          [cp diff:x with:1];
          [cp diff:x with:2];
          [cp diff:x with:5];
          NSLog(@"here: %@",[[cp engine] variables]);
          NSLog(@"GAMMA[8] = %@",gamma[8]);
          [cp diff:x with:4];
//          [cp label:x with:3];
          NSLog(@"here: %@",[[cp engine] variables]);
       }
       ];
   }
   return 0;
}

