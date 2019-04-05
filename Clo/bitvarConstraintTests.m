//
//  bitvarConstraintTests.m
//  Clo
//
//  Created by Greg Johnson on 9/19/14.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORFactory.h>
#import <ORFoundation/ORAVLTree.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

#import <objcp/CPConstraint.h>
#import <objcp/CPBitMacros.h>
#import <objcp/CPBitArray.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPBitConstraint.h>

@interface bitvarConstraintTests : XCTestCase

@end

@implementation bitvarConstraintTests

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

-(void) testBitExtract
{
   NSLog(@"Begin Test 1 of bit Extract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   min[0] = 0xB77BEFDF;
   max[0] = 0xB77BEFDF;
   yMin[0] = 0x00000000;
   yMax[0] = 0x0000FFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:16];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x from:0 to:15 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[y.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
      NSLog(@"x = %@\n", [cp stringValue:x]);
      NSLog(@"y = %@\n", [cp stringValue:y]);
   }];
   XCTAssertTrue([[cp stringValue:x] isEqualToString:@"10110111011110111110111111011111"],
                 @"testBitORConstraint: Bit Pattern for x is incorrect.");
   NSLog(@"End Test 1 of bit Extract constraint.\n");
   
}
//CPBitExtract
-(void) testBitExtract2
{
   NSLog(@"Begin Test 2 of bit Extract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   min[0] = 0xB77BEFDF;
   max[0] = 0xB77BEFDF;
   yMin[0] = 0x00000000;
   yMax[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:16];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x from:16 to:32 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[y.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 2 of bit Extract constraint.\n");
   
}

@end
