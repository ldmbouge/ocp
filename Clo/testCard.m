/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "testCard.h"
#import "objcp/CPBasicConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPEngine.h"
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

-(NSInteger) setupCardWith:(CPInt)n size:(CPInt)s
{
   id<CPSolver> m = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray:m range:(CPRange){0,s-1} domain:(CPRange){0,n-1}];
   id<CPIntArray> lb = [CPFactory intArray:m range:(CPRange){0,n-1} value:2];
   id<CPIntArray> ub = [CPFactory intArray:m range:(CPRange){0,n-1} value:3];
    
   int* cnt = alloca(sizeof(NSInteger)*n);
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [m add:[CPFactory cardinality:x low:lb up:ub]];      
   } using: ^() {
      [CPLabel array:x orderedBy:^CPInt(CPInt i) {
         return i;
      }];
      /*for(NSInteger k=0;k<s;k++)
         printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
      printf("]\n");
       */
      for(NSInteger k=0;k<n;k++)cnt[k]=0;
      for(CPInt k=0;k<s;k++)
         cnt[[[x at:k] min]]++;
      for(NSInteger k=0;k<n;k++)
         STAssertTrue(cnt[k]>=2 && cnt[k] <=3, @"cnt should always be in 2..3");
      [nbSolutions incr];
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);   
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
