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
#import <objcp/CPBitArrayDom.h>

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
-(void) testRank {
   @autoreleasepool {
      id<ORTrail> trail = [ORFactory trail];
      id<ORMemoryTrail> mt    = [ORFactory memoryTrail];
      id<CPEngine> engine = [CPFactory engine: trail memory:mt];
      CPBitArrayDom* bd = [[CPBitArrayDom alloc] initWithLength:6
                                                     withEngine:engine
                                                      withTrail:trail];
      [bd setBit:0 to:true for:nil];
      [bd setBit:2 to:true for:nil];
      [bd setBit:4 to:false for:nil];
      NSLog(@"d = %@",bd);
      for(ORInt i=0;i < 8;i++) {
         ORUInt* s = [bd atRank:i];
         printf("rank[%d] = ",i);
         for(ORUInt mask = (0x1 << 5); mask ; mask >>= 1) {
            BOOL bit = (s[0] & mask) == mask;
            printf("%c",bit ? '1' : '0');
         }
         printf("\n");
      }
   }
}
-(void) testShiftL {
   @autoreleasepool {
      id<ORModel>  m = [ORFactory createModel];
      id<ORBitVar> x = [ORFactory bitVar:m withLength:8];
      id<ORBitVar> y = [ORFactory bitVar:m withLength:8];
      [m add: [ORFactory bit:x shiftLBy:2 eq:y]];
      id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
      [cp solveAll:^{
         NSLog(@"x = %@",[cp stringValue:x]);
         NSLog(@"y = %@",[cp stringValue:y]);
         [cp labelBit:0 ofVar:x];
         NSLog(@"x = %@",[cp stringValue:x]);
         NSLog(@"y = %@",[cp stringValue:y]);
      }];
   }

}
-(void) testShiftL2 {
   @autoreleasepool {
      id<ORModel>  m = [ORFactory createModel];
      id<ORBitVar> x = [ORFactory bitVar:m withLength:8];
      id<ORBitVar> y = [ORFactory bitVar:m withLength:8];
      [m add: [ORFactory bit:x shiftLBy:2 eq:y]];
      id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
      [cp solveAll:^{
         NSLog(@"x = %@",[cp stringValue:x]);
         NSLog(@"y = %@",[cp stringValue:y]);
         [cp labelBV:y at:7 with:YES];
         NSLog(@"x = %@",[cp stringValue:x]);
         NSLog(@"y = %@",[cp stringValue:y]);
         [cp labelBV:y at:6 with:NO];
         NSLog(@"x = %@",[cp stringValue:x]);
         NSLog(@"y = %@",[cp stringValue:y]);
      }];
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
/*
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
*/
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

-(void) testChannel3 {
   @autoreleasepool {
      id<ORModel>  m = [ORFactory createModel];
      id<ORBitVar> x = [ORFactory bitVar:m withLength:8];
      id<ORIntVar> y = [ORFactory intVar:m domain:RANGE(m, 0,255)];
      [m add: [ORFactory bit:x channel:y]];
      id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
      [cp solveAll:^{
         [cp labelBits:x withValue:97];
         NSLog(@"x  = %@",[cp stringValue:x]);
         NSLog(@"y  = %d",[cp intValue:y]);
      }];
   }
}

-(void) testChannel4 {
   @autoreleasepool {
      id<ORModel>  m = [ORFactory createModel];
      id<ORBitVar> x = [ORFactory bitVar:m withLength:8];
      id<ORIntVar> y = [ORFactory intVar:m domain:RANGE(m, 0,255)];
      [m add: [ORFactory bit:x channel:y]];
      id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
      [cp solveAll:^{
         ORInt t = 97;
         ORInt m = 0x1;
         for(int i=0;i<8;i++) {
            [cp labelBV:x at:i with: t&m];
            m <<= 1;
         }
         NSLog(@"x  = %@",[cp stringValue:x]);
         NSLog(@"y  = %d",[cp intValue:y]);
      }];
   }
}
@end
