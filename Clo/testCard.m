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


#import "testCard.h"
#import "objcp/CPBasicConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPSolver.h"
#import "objcp/cp.h"
#import "CPLabel.h"
#import "CPData.h"
#import "CPValueConstraint.h"


@implementation testCard

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

-(NSInteger) setupCardWith:(NSInteger)n size:(NSInteger)s
{
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray:m range:(CPRange){0,s-1} domain:(CPRange){0,n-1}];
   id<CPIntArray> lb = [CPFactory intArray:m range:(CPRange){0,n-1} value:2];
   id<CPIntArray> ub = [CPFactory intArray:m range:(CPRange){0,n-1} value:3];
    
   int* cnt = alloca(sizeof(NSInteger)*n);
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [m add:[CPFactory cardinality:x low:lb up:ub]];      
   } using: ^() {
      [CPLabel array:x orderedBy:^NSInteger(NSInteger i) {
         return i;
      }];
      /*for(NSInteger k=0;k<s;k++)
         printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
      printf("]\n");
       */
      for(NSInteger k=0;k<n;k++)cnt[k]=0;
      for(NSInteger k=0;k<s;k++)
         cnt[[[x at:k] min]]++;
      for(NSInteger k=0;k<n;k++)
         STAssertTrue(cnt[k]>=2 && cnt[k] <=3, @"cnt should always be in 2..3");
      [nbSolutions incr];
   }
    ];
   printf("GOT %ld solutions\n",[nbSolutions value]);   
   NSInteger rv =  [nbSolutions value];
   [m release];
   [CPFactory shutdown];
   return rv;
}

-(void) testCard1
{
   STAssertTrue([self setupCardWith:8 size:8]==0, @"card-1 has 0 solutions");
}
-(void) testCard2
{
   STAssertTrue([self setupCardWith:4 size:8]==2520, @"card-2 has 2520 solutions");
}
@end
