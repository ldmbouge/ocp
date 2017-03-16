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

- (void)testSumBoolNEQ {
   @autoreleasepool {
      id<ORModel> m = [ORFactory createModel];
      id<ORIntRange> R = RANGE(m,0,5);
      id<ORIntVarArray> x = [ORFactory intVarArray:m range:R with:^id<ORIntVar> _Nonnull(ORInt i) { return [ORFactory boolVar:m];}];

      [m add: [ORFactory sumbool:m array:x neqi:2]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:m];
      [cp solveAll: ^{
         [cp labelArray: x];
         @autoreleasepool {
            id<ORIntArray> s = [ORFactory intArray:cp range:R with:^ORInt(ORInt i) { return [cp intValue:x[i]];}];
            ORInt cnt = sumSet(R, ^ORInt(ORInt i) { return [s at:i];});
            NSString* buf = [NSMutableString stringWithFormat:@"SUMBOOL ≠ 2 sum(%@) == %d \n",s,cnt];
            printf("%s", [buf UTF8String]);
         }
      }];
      printf("Done: %d / %d\n",[cp nbChoices],[cp nbFailures]);
   }
}


- (void)testBinImply {
   @autoreleasepool {
      id<ORModel> m = [ORFactory createModel];
      id<ORIntRange> R = RANGE(m,0,1);
      id<ORIntVarArray> x = [ORFactory intVarArray:m range:R with:^id<ORIntVar> _Nonnull(ORInt i) { return [ORFactory boolVar:m];}];
      
      [m add: [ORFactory model:m boolean:x[0] imply:x[1]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:m];
      [cp solveAll: ^{
         [cp labelArray: x];
         @autoreleasepool {
            id<ORIntArray> s = [ORFactory intArray:cp range:R with:^ORInt(ORInt i) { return [cp intValue:x[i]];}];
            NSString* buf = [NSMutableString stringWithFormat:@"x[0] imply x[1] (%@)\n",s];
            printf("%s", [buf UTF8String]);
         }
      }];
      printf("Done: %d / %d\n",[cp nbChoices],[cp nbFailures]);
   }
}

-(void) testBitBind {
   @autoreleasepool {
      id<ORModel>  m = [ORFactory createModel];
      id<ORBitVar> x = [ORFactory bitVar:m withLength:32];
      id<ORBitVar> y = [ORFactory bitVar:m withLength:32];
      id<ORBitVar> z = [ORFactory bitVar:m withLength:32];
      [m add: [ORFactory bit:x bnot:y]];
      [m add: [ORFactory bit:y eq:z]];
      id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
      [cp solveAll:^{
         [cp labelBits:x withValue:17];
         NSLog(@"x = %@",[cp stringValue:x]);
         NSLog(@"y = %@",[cp stringValue:y]);
         NSLog(@"z = %@",[cp stringValue:z]);
      }];      
   }
}

-(void) testChannel1 {
   @autoreleasepool {
      id<ORModel>  m = [ORFactory createModel];
      id<ORBitVar> x = [ORFactory bitVar:m withLength:32];
      id<ORBitVar> y = [ORFactory bitVar:m withLength:32];
      ORUInt low = 0,up = 65535;
      id<ORBitVar> c = [ORFactory bitVar:m low:&low up:&up bitLength:32];
      id<ORIntVar> yn = [ORFactory intVar:m domain:RANGE(m, 0, 65535)];
      [m add: [ORFactory bit:x eq:y]];
      [m add: [ORFactory bit:y eq:c]];
      [m add: [ORFactory bit:y channel:yn]];
      id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
      [cp solveAll:^{
         [cp labelBits:x withValue:17];
         NSLog(@"x  = %@",[cp stringValue:x]);
         NSLog(@"y  = %@",[cp stringValue:y]);
         NSLog(@"yn = %d",[cp intValue:yn]);
      }];
   }
}

-(void) testChannel2 {
   @autoreleasepool {
      id<ORModel>  m = [ORFactory createModel];
      id<ORBitVar> x = [ORFactory bitVar:m withLength:32];
      id<ORBitVar> y = [ORFactory bitVar:m withLength:32];
      ORUInt low = 0,up = 65535;
      id<ORBitVar> c = [ORFactory bitVar:m low:&low up:&up bitLength:32];
      id<ORIntVar> yn = [ORFactory intVar:m domain:RANGE(m, 0, 65535)];
      [m add: [ORFactory bit:x eq:y]];
      [m add: [ORFactory bit:y eq:c]];
      [m add: [ORFactory bit:y channel:yn]];
      id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
      [cp solveAll:^{
         [cp label:yn with:15];
         NSLog(@"x  = %@",[cp stringValue:x]);
         NSLog(@"y  = %@",[cp stringValue:y]);
         NSLog(@"yn = %d",[cp intValue:yn]);
      }];
   }
}
@end
