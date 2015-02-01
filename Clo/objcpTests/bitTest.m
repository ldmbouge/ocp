/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "bitTest.h"
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTrailI.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>
#import <objcp/CPFactory.h>

#import <objcp/CPBitArray.h>
#import <objcp/CPBitArrayDom.h>


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

-(void) testGetBit
{
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0x0006000F;
   max[0] = 0x0006000F;
   
   id<ORTrail>   dummyTrail = [[ORTrailI alloc] init];
   CPBitArrayDom* bitDomain = [[CPBitArrayDom alloc] initWithBitPat:32 withLow:min andUp:max andTrail:dummyTrail];

   unsigned char test;
   if(test=[bitDomain getBit:18])
      NSLog(@"Works!\n");
   else
      NSLog(@"Whaaaaaat? %ud\n",(unsigned short)test);
}

-(void)testEnumerate
{
   unsigned int min[2];
   unsigned int max[2];
   
   min[0] = 0;
   min[1] = 0;
   max[0] = 0;
   max[1] = 0xF0F;
   id<ORTrail>   dummyTrail = [[ORTrailI alloc] init];   
   CPBitArrayDom* bitDomain = [[CPBitArrayDom alloc] initWithBitPat:64 withLow:min andUp:max andTrail:dummyTrail];
   NSLog(@"Iterating over: %@\n",bitDomain);
   [bitDomain enumerateWith:^(unsigned int* bits,ORInt idx) {
      unsigned long long rank = [bitDomain getRank:bits];
      unsigned int* pat = [bitDomain atRank:rank];
      NSLog(@"Value [%llu] is %x%x : %x%x",rank,bits[0],bits[1],pat[0],pat[1]);
//      XCTAssertEquals(bits[0], pat[0],@"bit pattern (high) must be equal");
//      XCTAssertEquals(bits[1], pat[1],@"bit pattern (low) must be equal");
      free(pat);
   }];
}
@end
