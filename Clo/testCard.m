/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "testCard.h"

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORAVLTree.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

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

-(NSInteger) setupCardWith:(ORInt)n size:(ORInt)s
{
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVarArray> x = [ORFactory intVarArray:m range:RANGE(m,0,s-1) domain:RANGE(m,0,n-1)];
   id<ORIntArray> lb = [ORFactory intArray:m range:RANGE(m,0,n-1) value:2];
   id<ORIntArray> ub = [ORFactory intArray:m range:RANGE(m,0,n-1) value:3];
    
   int* cnt = alloca(sizeof(NSInteger)*n);
   id<ORMutableInteger> nbSolutions = [ORFactory integer: m value: 0];
   [m add:[ORFactory cardinality:x low:lb up:ub]];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   
   [cp solveAll: ^() {
      [cp labelArray:x orderedBy:^ORFloat(ORInt i) {
         return i;
      }];
      for(NSInteger k=0;k<n;k++)cnt[k]=0;
      for(ORInt k=0;k<s;k++)
         cnt[[[x at:k] min]]++;
      for(NSInteger k=0;k<n;k++)
         STAssertTrue(cnt[k]>=2 && cnt[k] <=3, @"cnt should always be in 2..3");
      [nbSolutions incr];
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);   
   NSInteger rv =  [nbSolutions value];
   [m release];
   [ORFactory shutdown];
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
