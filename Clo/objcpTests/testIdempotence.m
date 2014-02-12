//
//  testIdempotence.m
//  Clo
//
//  Created by Laurent Michel on 1/17/14.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORAVLTree.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

@interface testIdempotence : SenTestCase

@end

@implementation testIdempotence

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
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = RANGE(m,0,1);
   
   id<ORIntVar> x1 = [ORFactory intVar:m domain:R];
   id<ORIntVar> x2 = [ORFactory intVar:m var:x1 scale:-1 shift:1];
   id<ORIntVar> x3 = [ORFactory intVar:m domain:R];
   [m add: [[[[x1 mul:@5] plus:[x2 mul:@3]] plus:[x3 mul:@2]] geq:@7]];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:
    ^() {
      NSLog(@"Solving... #propagation:%d",[[cp engine] nbPropagation]);
      NSLog(@"Model: %@",[[cp engine] model]);
      //[cp label:x1 with:1];
    }
    ];
   [m release];
   [ORFactory shutdown];
}

@end
