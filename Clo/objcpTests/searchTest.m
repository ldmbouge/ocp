//
//  searchTest.m
//  Clo
//
//  Created by Laurent Michel on 7/2/13.
//
//

#import "searchTest.h"
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

@implementation searchTest
-(void)testTryall
{
   ORInt n = 4;
   ORInt d = 10;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange>    D = RANGE(m,1,d);
   id<ORIntVarArray> x = [ORFactory intVarArray:m range:RANGE(m,1,n) domain:D];
   int* coef = (int[]){3,4,10,30,5,1,0,9,12,-1};
   id<ORIntMatrix> z = [ORFactory intMatrix:m range:RANGE(m,1,2) :RANGE(m,1,d) using:^int(ORInt i , ORInt j) {
      if (i==1) return coef[j-1];
      else return coef[(j + 5) % 10];
   }];
   NSLog(@"Matrix is:%@",z);
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:^{
      NSLog(@"START: %@",x);
      [cp forall:RANGE(m,1,2) suchThat:^bool(ORInt i) { return YES;} orderedBy:nil do:^(ORInt i) {
         [cp tryall:D suchThat:^bool(ORInt v) { return YES;} orderedBy:^ORFloat(ORInt v) { return [z at:i :v];} in:^(ORInt v) {
            [cp label:x[i] with:v];
         } onFailure:^(ORInt v) {
            [cp diff:x[i] with:v];
         }];
      }];
      NSLog(@"SOL: x[1] = %d  x[2] = %d -- weight is %2d,%2d",[cp intValue:x[1]],[cp intValue:x[2]],
            [z at:1 :[cp intValue:x[1]]],
            [z at:2 :[cp intValue:x[2]]]);
   }];
   
}

@end
