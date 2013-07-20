//
//  main.m
//  bug
//
//  Created by Laurent Michel on 5/9/13.
//
//

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
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
      [cp release];
      [ORFactory shutdown];
   }
   return 0;
}

