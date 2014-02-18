//
//  objlsTests.m
//  objlsTests
//
//  Created by Laurent Michel on 12/10/13.
//
//

#import <XCTest/XCTest.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>
#import <objls/LSFactory.h>
#import <objls/LSConstraint.h>
#import <objls/LSSolver.h>
#import "LSCount.h"

@interface objlsTests : XCTestCase

@end

@implementation objlsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//   id<ORModel> m = [ORFactory createModel];
   id<LSEngine>  ls = [[LSEngineI alloc] initEngine];
   id<ORIntRange> d = RANGE(ls, 0, 10);
   id<LSIntVarArray> x = [LSFactory intVarArray:ls range:d with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:ls domain:d];
   }];
   id<LSIntVarArray> c = [LSFactory intVarArray:ls range:d with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVar:ls domain:d];
   }];
   [ls add:[LSFactory count:ls vars:x card:c]];

   id<LSIntVarArray> vv = [LSFactory intVarArray:ls range:d with:^id(ORInt i) {
      return [LSFactory intVar:ls domain:d];
   }];

   for (ORInt i=vv.range.low; i <= vv.range.up; ++i)
      [ls add:[LSFactory inv:vv[i] equal:^ { return max(0, [c[i] value] - 1);} vars:@[c[i]]]];
   id<LSIntVar> sv = [LSFactory intVar:ls domain:RANGE(ls,0,FDMAXINT)];
   [ls add:[LSFactory sum: sv over:vv]];
   [ls close];
   NSLog(@"TTL: %@",sv);
   [ls atomic:^ {
      [ls label:x[1] with: 1];
      [ls label:x[2] with: 2];
   }];
   NSLog(@"count: %@",c);
   NSLog(@"vv   : %@",vv);
   NSLog(@"TTL  : %@",sv);
   [ls label:x[3] with: 3];
   NSLog(@"TTL  : %@",sv);
}
-(void)testConstraint
{
   id<LSEngine>  ls = [[LSEngineI alloc] initEngine];
   [ORStreamManager setRandomized];
   ORInt n = 8;
   id<ORIntRange> d = RANGE(ls, 0, n-1);
   id<LSIntVarArray> x = [LSFactory intVarArray:ls range:d domain:d];
   id<LSIntVarArray> xp = [LSFactory intVarArray:ls range:d with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVarView:ls domain:RANGE(ls,i,i+n) fun:^ORInt{
         return x[i].value + i;
      } src:@[x[i]]];
   }];
   id<LSIntVarArray> xn = [LSFactory intVarArray:ls range:d with:^id<LSIntVar>(ORInt i) {
      return [LSFactory intVarView:ls domain:RANGE(ls,0-i,n-i) fun:^ORInt{
         return x[i].value - i;
      } src:@[x[i]]];
   }];
   
   id<LSConstraint> ad1 = [ls addConstraint:[LSFactory alldifferent:ls over:x]];
   id<LSConstraint> ad2 = [ls addConstraint:[LSFactory alldifferent:ls over:xp]];
   id<LSConstraint> ad3 = [ls addConstraint:[LSFactory alldifferent:ls over:xn]];
   id<LSConstraint> sys = [ls addConstraint:[LSFactory system:ls with:@[ad1,ad2,ad3]]];
   [ls close];
//   id<LSIntVarArray> sv = [sys variables];
   ORInt it = 0;
   id<ORSelect> sMax = [ORFactory selectRandom:ls range:d suchThat:nil orderedBy:^ORFloat(ORInt i) {
      return [sys getVarViolations:x[i]];
   }];
   NSLog(@"Initial violations: %d",[sys violations].value);
   while ([sys violations].value > 0 && it < 50 * n) {
      ORInt i = [sMax max];
      id<ORSelect> sMin = [ORFactory selectRandom:ls range:d suchThat:nil orderedBy:^ORFloat(ORInt v) {
         return [sys deltaWhenAssign:x[i] to:v];
      }];
      ORInt v = [sMin min];
      [ls label:x[i] with:v];
      ++it;
      NSLog(@"TTL4  : %d",[sys getViolations]);
   }
   if ([sys getViolations] == 0) {
      NSLog(@"TTL4  : %d",[sys getViolations]);
      NSLog(@"QUEENS: %@",x);
      NSLog(@"Iterations: %d",it);
   } else
      NSLog(@"FAILED!");
}

-(void)testQueens
{
   ORInt n = 8;
   [ORStreamManager setRandomized];
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> D = RANGE(model, 0, n-1);
      id<ORIntVarArray> x = [ORFactory intVarArray:model range:D domain:D];
      [model add:[ORFactory alldifferent:x]];
      [model add:[ORFactory alldifferent:All(model, ORExpr, i, D, [x[i] plus:@(i)])]];
      [model add:[ORFactory alldifferent:All(model, ORExpr, i, D, [x[i] sub:@(i)])]];
      id<LSProgram> ls = [ORFactory createLSProgram:model annotation:nil];
      __block ORInt it = 0;
      [ls solve: ^{
         while ([ls violations] > 0 && it < 50 * n) {
            [ls selectMax:D orderedBy:^ORFloat(ORInt i) { return [ls getVarViolations:x[i]];} do:^(ORInt i) {
               [ls selectMin: D orderedBy:^ORFloat(ORInt v) { return [ls deltaWhenAssign:x[i] to:v];} do:^(ORInt v) {
                  [ls label:x[i] with:v];
               }];
            }];
            ++it;
         }
      }];
      id<ORSolution> b = [[ls solutionPool] best];
      if (b != nil) {
         NSLog(@"Found a solution in %d iter",it);
         NSLog(@"Sol: %@",b);
      }
   }
}

@end
