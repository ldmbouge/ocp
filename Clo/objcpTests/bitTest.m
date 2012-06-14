//
//  bitTest.m
//  Clo
//
//  Created by Laurent Michel on 5/15/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "bitTest.h"
#import "objcp/CP.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPController.h"
#import "objcp/CPTracer.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"
#import "objcp/CPAVLTree.h"

#import "objcp/CPBitArray.h"
#import "objcp/CPBitArrayDom.h"


@implementation bitTest
- (void)setUp
{
   [super setUp];
   
   // Set-up code here.
}

- (void)tearDown
{
   // Tear-down code here.
   
   [super tearDown];
}

-(void)testEnumerate
{
   unsigned int min[2];
   unsigned int max[2];
   
   min[0] = 0;
   min[1] = 0;
   max[0] = 0;
   max[1] = 0xF0F;
   CPTrail*   dummyTrail = [[CPTrail alloc] init];   
   CPBitArrayDom* bitDomain = [[CPBitArrayDom alloc] initWithBitPat:64 withLow:min andUp:max andTrail:dummyTrail];
   NSLog(@"Iterating over: %@\n",bitDomain);
   [bitDomain enumerateWith:^(unsigned int* bits,NSInteger idx) {
      unsigned long long rank = [bitDomain getRank:bits];
      unsigned int* pat = [bitDomain atRank:rank];
      NSLog(@"Value [%llu] is %x%x : %x%x",rank,bits[0],bits[1],pat[0],pat[1]);
      STAssertEquals(bits[0], pat[0],@"bit pattern (high) must be equal");
      STAssertEquals(bits[1], pat[1],@"bit pattern (low) must be equal");
      free(pat);
   }];
}
@end
