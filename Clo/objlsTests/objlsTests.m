//
//  objlsTests.m
//  objlsTests
//
//  Created by Laurent Michel on 12/10/13.
//
//

#import <XCTest/XCTest.h>
#import <ORFoundation/ORFoundation.h>
#import "LSEngineI.h"
#import "LSFactory.h"
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
   id<LSEngine>  e = [[LSEngineI alloc] initEngine];
   id<ORIdArray> x = [ORFactory idArray:e range:RANGE(e,0,10)];
   id<ORIdArray> c = [ORFactory idArray:e range:RANGE(e,0,10)];
   for (ORInt i=x.range.low; i <= x.range.up; ++i)
      x[i] = [LSFactory intVar:e value:0];
   for (ORInt i=c.range.low; i <= c.range.up; ++i)
      c[i] = [LSFactory intVar:e value:0];
   LSCount* ci = [LSFactory count:e vars:x card:c];
   [e add:ci];
   [e close];
}

@end
