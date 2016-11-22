//
//  TestAll.m
//  TestAll
//
//  Created by Laurent Michel on 8/17/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <ORProgram/ORProgram.h>

@interface TestAll : XCTestCase

@end

@implementation TestAll

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testReify {
   @autoreleasepool {
      id<ORModel> m = [ORFactory createModel];
      id<ORIntRange> R = RANGE(m,1,2);
      
      id<ORIntVar> A  = [ORFactory boolVar:m];
      id<ORIntVar> B  = [ORFactory intVar:m domain:R];
      id<ORIntVar> C  = [ORFactory intVar:m domain:R];
      [m add: [A eq:[B neq:C]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:m];
      id<ORIntVarArray> x = [m intVars];
      [cp solveAll: ^{
          [cp labelArray: x];
          @autoreleasepool {
             NSString* buf = [NSMutableString stringWithFormat:@"DISEQUALITY: A = %d , B = %d , C = %d\n",[cp intValue:A],[cp intValue:B],[cp intValue:C]];
             printf("%s", [buf cStringUsingEncoding:NSASCIIStringEncoding]);
          }
       }];
   }
}


@end
