//
//  disabledArray.m
//  disabledArray
//
//  Created by Zitoun on 21/11/2018.
//  Copyright © 2018 Laurent Michel. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPFloatVarI.h>
#import <ORProgram/CPSolver.h>

@interface disabledArray : XCTestCase

@end

@implementation disabledArray

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void) testArrayDisabled1{
   @autoreleasepool {
      NSLog(@"test");
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVarArray> va = [ORFactory floatVarArray:model range:RANGE(model, 0, 5) names:@"v"];
      id<CPProgram> cp =  [ORFactory createCPProgram:model];
      id<ORFloatVarArray> vs = [model floatVars];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      ORUInt i;
      XCTAssertFalse([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
      XCTAssertThrows([vars enableFirst]);
      [vars disable:0];
      XCTAssertTrue([vars hasDisabled]);
      XCTAssertTrue([vars isFullyDisabled]);
      XCTAssertThrows([vars disable:1]);
      i = [vars enableFirst];
      XCTAssertEqual(i,0);
      XCTAssertFalse([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
   }
}


-(void) testArrayDisabled2{
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVarArray> va = [ORFactory floatVarArray:model range:RANGE(model, 0, 5) names:@"v"];
      id<CPProgram> cp =  [ORFactory createCPProgram:model];
      id<ORFloatVarArray> vs = [model floatVars];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine] nbFixed:2];
      ORUInt i;
      XCTAssertFalse([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
      XCTAssertThrows([vars enableFirst]);
      [vars disable:0];
      XCTAssertTrue([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
      [vars disable:0];
      XCTAssertTrue([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
      [vars disable:1];
      XCTAssertTrue([vars hasDisabled]);
      XCTAssertTrue([vars isFullyDisabled]);
      for(ORUInt k = 0; k < [vars count]; k++){
         if(k == 0 || k == 1){
            XCTAssertNoThrow([vars disable:k]);
         }else{
            XCTAssertThrows([vars disable:k]);
         }
      }
      i = [vars enableFirst];
      XCTAssertEqual(i,0);
      XCTAssertTrue([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
      [vars disable:0];
      XCTAssertTrue([vars hasDisabled]);
      XCTAssertTrue([vars isFullyDisabled]);
      i = [vars enableFirst];
      XCTAssertEqual(i,1);
      XCTAssertTrue([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
      i = [vars enableFirst];
      XCTAssertEqual(i,0);
      XCTAssertFalse([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
   }
}
-(void) testArrayDisabled3{
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVarArray> va = [ORFactory floatVarArray:model range:RANGE(model, 0, 5) names:@"v"];
      id<CPProgram> cp =  [ORFactory createCPProgram:model];
      id<ORFloatVarArray> vs = [model floatVars];
      id<ORDisabledFloatVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine] nbFixed:10];
      ORUInt i;
      XCTAssertFalse([vars hasDisabled]);
      XCTAssertFalse([vars isFullyDisabled]);
      for(ORUInt k = 0; k < [vars count]; k++){
         XCTAssertFalse([vars isDisabled:k]);
         XCTAssertTrue([vars isEnabled:k]);
         [vars disable:k];
         XCTAssertTrue([vars isDisabled:k]);
         XCTAssertFalse([vars isEnabled:k]);
      }
      XCTAssertTrue([vars isFullyDisabled]);
      
      
      for(ORUInt k = 0; k < [vars count]; k++){
         XCTAssertTrue([vars isDisabled:k]);
         XCTAssertFalse([vars isEnabled:k]);
         i = [vars enableFirst];
         XCTAssertEqual(i,k);
         XCTAssertFalse([vars isDisabled:k]);
         XCTAssertTrue([vars isEnabled:k]);
      }
      XCTAssertFalse([vars isFullyDisabled]);
      XCTAssertFalse([vars hasDisabled]);
      for(ORInt k = ((ORInt)[vars count] - 1); k >= 0; k--){
         XCTAssertFalse([vars isDisabled:k]);
         XCTAssertTrue([vars isEnabled:k]);
         [vars disable:k];
         XCTAssertTrue([vars isDisabled:k]);
         XCTAssertFalse([vars isEnabled:k]);
      }
      
      XCTAssertTrue([vars isFullyDisabled]);
      for(ORInt k = ((ORInt)[vars count] - 1); k >= 0; k--){
         XCTAssertTrue([vars isDisabled:k]);
         XCTAssertFalse([vars isEnabled:k]);
         i = [vars enableFirst];
         XCTAssertEqual(i,k);
         XCTAssertFalse([vars isDisabled:k]);
         XCTAssertTrue([vars isEnabled:k]);
      }
   }
}

@end
