/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

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
   [bitDomain enumerateWith:^(unsigned int* bits,CPInt idx) {
      unsigned long long rank = [bitDomain getRank:bits];
      unsigned int* pat = [bitDomain atRank:rank];
      NSLog(@"Value [%llu] is %x%x : %x%x",rank,bits[0],bits[1],pat[0],pat[1]);
      STAssertEquals(bits[0], pat[0],@"bit pattern (high) must be equal");
      STAssertEquals(bits[1], pat[1],@"bit pattern (low) must be equal");
      free(pat);
   }];
}
@end
