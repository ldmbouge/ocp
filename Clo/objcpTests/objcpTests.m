/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "objcpTests.h"

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORAVLTree.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

@implementation objcpTests

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

- (void)testQueens
{
   int n = 8;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = RANGE(m,1,n);
   id<ORInteger> nbSolutions = [ORFactory integer: m value: 0];
   id<ORIntVarArray> x  = [ORFactory intVarArray:m range:R domain: R];
   id<ORIntVarArray> xp = [ORFactory intVarArray:m range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:m var:x[i] shift:i]; }];
   id<ORIntVarArray> xn = [ORFactory intVarArray:m range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:m var:x[i] shift:-i]; }];
   [m add: [ORFactory alldifferent: x]];
   [m add: [ORFactory alldifferent: xp]];
   [m add: [ORFactory alldifferent: xn]];

   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:
    ^() {
       [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return [[x at:i] domsize];}];
       [nbSolutions incr];
   }
    ];
   NSLog(@"Got %@ solutions\n",nbSolutions);
   STAssertTrue([nbSolutions value]==92, @"queens-8 has 92 solutions"); 
   [m release];
   [ORFactory shutdown];
}

- (void) testWL1
{
   int s = 10;
   int n = 2;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORInteger> nbSolutions = [ORFactory integer: m value: 0];
   [m add: [ORFactory sumbool:m array:x geqi:2]];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return i;}];
      int nbOne = 0;
      for(ORInt k=0;k<s;k++) {
         //printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
         nbOne += [[x at:k] min] == 1;
      }
      //printf("]\n");
      [nbSolutions  incr];
      STAssertTrue(nbOne>=2, @"Each solution must have at least 2 ones");
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);   
   [m release];
   [ORFactory shutdown];
}

- (void) testWL2
{
   int s = 10;
   int n = 2;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORInteger> nbSolutions = [ORFactory integer: m value: 0];
   [m add: [ORFactory sumbool:m array:x geqi:8]];

   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return i;}];
      int nbOne = 0;
      for(ORInt k=0;k<s;k++) {
         //printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
         nbOne += [[x at:k] min] == 1;
      }
      //printf("]\n");
      [nbSolutions  incr];
      STAssertTrue(nbOne>=8, @"Each solution must have at least 2 ones");
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);   
   [m release];
   [ORFactory shutdown];
}

- (void) testWL3 
{
   int s = 10;
   int n = 2;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORIntVarArray> nx = [ORFactory intVarArray: m range:R with:^id<ORIntVar>(ORInt i) {
      return [ORFactory intVar:m var:x[i] scale:-1 shift:1];
   }];
   [m add:[ORFactory sumbool:m array:x geqi:2]];
   [m add:[ORFactory sumbool:m array:nx geqi:8]];
   
   
   id<ORInteger> nbSolutions = [ORFactory integer: m value: 0];
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return i;}];
      int nbOne = 0;
      int nbZero = 0;
      for(ORInt k=0;k<s;k++) {
         //printf("%s%s",(k>0 ? "," : "["),[[[x at:k]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
         nbOne  += [[x at:k] min] == 1;
         nbZero += [[nx at:k] min] == 1;
      }
      //printf("]\n");
      //for(NSInteger k=0;k<s;k++) {
      //   printf("%s%s",(k>0 ? "," : "["),[[[nx at:k]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
      //}
      //printf("]\n");
      [nbSolutions  incr];
      STAssertTrue(nbOne>=2, @"Each solution must have at least 2 ones");
      STAssertTrue(nbZero>=8, @"Each solution must have at least 8 zeroes");
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);   
   [m release];
   [ORFactory shutdown];
}

- (void) testWLSBEqc
{
   int s = 10;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: m range:R domain: RANGE(m,0,1)];
   id<ORInteger> nbSolutions = [ORFactory integer: m value: 0];
   [m add: [ORFactory sumbool:m array:x eqi:4]];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return i;}];
      int nbOne = 0;
      for(ORInt k=0;k<s;k++)
         nbOne += [x[k] min] == 1;
      NSLog(@"SOL: %@",x);
      [nbSolutions  incr];
      STAssertTrue(nbOne == 4, @"Each solution must have at least 4 ones");
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   [m release];
   [ORFactory shutdown];
}

- (void) testBoolView
{
   int s = 8;
   int n = 2;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x  = [ORFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORIntVarArray> nx = [ORFactory intVarArray: m range:R with:^id<ORIntVar>(ORInt i) {
      return [ORFactory intVar:m var:x[i] scale:-1 shift:1];
   }];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   id<ORInteger> nbSolutions = [ORFactory integer: m value: 0];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return i;}];
      for(ORInt k=0;k<s;k++) {
         STAssertTrue([[x at:k] min] == ![[nx at:k] min], @"x and nx should be negations of each other");
      }
      [nbSolutions  incr];
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);   
   [m release];
   [ORFactory shutdown];
}
-(void)testReify1
{
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVar> x = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> b = [ORFactory intVar:m domain:RANGE(m,0,1)];
   NSArray* av = [NSArray arrayWithObjects:x,b,nil];
   [m add:[ORFactory reify:m boolean:b with:x neqi:5]];
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:^() {
      [cp label:x];
      NSLog(@"solution: %@\n",av);
      STAssertTrue([b min] == ([x min]!=5), @"reification not ok");
   }
    ];
   [m release];
   [ORFactory shutdown];
}
-(void)testReify2
{
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVar> x = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> b = [ORFactory intVar:m domain:RANGE(m,0,1)];

   [m add:[ORFactory reify:m boolean:b with:x eqi:5]];
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:^() {
      [cp label:x];
      STAssertTrue([b min] == ([x min]==5), @"reification not ok");
   }
    ];
   [m release];
   [ORFactory shutdown];
}

-(void)testReify3
{
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVar> x = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> y = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> b = [ORFactory intVar:m domain:RANGE(m,0,1)];
   [m add:[ORFactory reify:m boolean:b with:x eq:y annotation:ValueConsistency]];
   id<CPProgram> cp = [ORFactory createCPProgram:m];

   [cp solveAll:^() {
      [cp label:x];
      [cp label:y];
      [cp label:b];
      STAssertTrue([b min] == ([x min]==[y min]), @"reification (b<=> (x==y)) not ok");      
   }
    ];
   [m release];
   [ORFactory shutdown];
}

-(void)testReify4
{
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVar> x = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> y = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> b = [ORFactory intVar:m domain:RANGE(m,0,1)];
   [m add:[ORFactory reify:m boolean:b with:x eq:y annotation:DomainConsistency]];

   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:^() {
      [cp label:b];
      [cp label:x];
      STAssertTrue([b min] == ([x min]==[y min]), @"reification (b first) (b<=> (x==y)) not ok");
   }
    ];
   [m release];
   [ORFactory shutdown];
}

-(void)testAVL
{
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   ORAVLTree* tree = [[[ORAVLTree alloc] initEmptyAVL] autorelease];
   for(NSInteger i=0;i<20;i++) {
      ORInt k = random() % 1000;
      [tree insertObject:[NSNumber numberWithLong:k] forKey:(ORInt)k];
   }
   NSLog(@"content: %@\n",tree);
   [pool release];
}

-(void)testEQ3
{
   int s = 2;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = RANGE(m,0,s-1);
   id<ORIntVarArray> x  = [ORFactory intVarArray: m range:R domain: RANGE(m,0,10)];
   id<ORIntVar> zn = [ORFactory intVar:m domain:RANGE(m,-10,0)];
   id<ORIntVar> z = [ORFactory intVar:m var:zn scale:-1];
   id<ORInteger> nbSolutions = [ORFactory integer: m value: 0];
   [m add: [z leqi:5]];
   [m add: [x[0] eq:[x[1] plus:z]]];
  
  
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORFloat(ORInt i) { return i;}];
      NSLog(@"Solution: %@ = %@",x,z);
      [nbSolutions  incr];
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   [m release];
   [ORFactory shutdown]; 
}

-(void)testRetractConstraintInSearch
{
   ORInt n = 8;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = RANGE(m,1,n);
   id<ORInteger> nbSolutions = [ORFactory integer:m value: 0];
   id<ORIntVarArray> x = [ORFactory intVarArray:m range: R domain: R];
   id<ORIntVarArray> xp = [ORFactory intVarArray:m range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:m var:[x at: i] shift:i]; }];
   id<ORIntVarArray> xn = [ORFactory intVarArray:m range: R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:m var:[x at: i] shift:-i]; }];
   [m add: [ORFactory alldifferent: x annotation: DomainConsistency]];
   [m add: [ORFactory alldifferent: xp annotation:DomainConsistency]];
   [m add: [ORFactory alldifferent: xn annotation:DomainConsistency]];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:
    ^() {
       for(ORInt i=1;i<=n;i++) {
          while(![x[i] bound]) {
             const ORInt curMin = [x[i] min];
             [cp try:^{
                [cp add: [x[i] eqi:curMin]];
             } or:^{
                [cp add: [x[i] neqi:curMin]];
             }];
          }
       }
       [nbSolutions incr];
    }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   STAssertTrue([nbSolutions value] == 92, @"Expecting 92 solutions");
   [cp release];
   [ORFactory shutdown];
}

-(void)testKnapsack1
{
   ORInt n = 4;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVarArray> x = [ORFactory intVarArray:m range:RANGE(m,1,n) domain:RANGE(m,0,1)];
   id<ORIntVar> cap = [ORFactory intVar:m domain:RANGE(m,0,25)];
   int* coef = (int[]){3,4,10,30};
   id<ORIntArray> w = [ORFactory intArray:m range:RANGE(m,1,n) with:^ORInt(ORInt i) {return coef[i-1];}];
   [m add:[ORFactory knapsack: x weight: w capacity:cap ]];
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:^{
      NSLog(@"START: %@ = %@",x,cap);
      [cp labelArray:x];
      [cp label:cap];
      NSLog(@"SOL: %@ = %@",x,cap);
   }];
}

-(void)testKnapsack2
{
   int n = 4;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVarArray> x = [ORFactory intVarArray:m range:RANGE(m,1,n) domain:RANGE(m,0,1)];
   id<ORIntVar> cap = [ORFactory intVar:m domain:RANGE(m,3,25)];
   int* coef = (int[]){3,4,10,30};
   id<ORIntArray> w = [ORFactory intArray:m range:RANGE(m,1,n) with:^ORInt(ORInt i) {return coef[i-1];}];
   [m add:[ORFactory knapsack: x weight: w capacity:cap ]];
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:^{
      NSLog(@"KS2: START: %@ = %@",x,cap);
      [cp labelArray:x];
      [cp label:cap];
      NSLog(@"KS2: SOL: %@ = %@",x,cap);
   }];
}


-(void)testKnapsack3
{
   int n = 4;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVarArray> x = [ORFactory intVarArray:m range:RANGE(m,1,n) domain:RANGE(m,0,1)];
   id<ORIntVar> cap = [ORFactory intVar:m domain:RANGE(m,14,25)];
   int* coef = (int[]){3,4,10,30};
   id<ORIntArray> w = [ORFactory intArray:m range:RANGE(m,1,n) with:^ORInt(ORInt i) {return coef[i-1];}];
   [m add:[ORFactory knapsack: x weight: w capacity:cap ]];
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:^{
      NSLog(@"KS2: START: %@ = %@",x,cap);
      [cp labelArray:x];
      [cp label:cap];
      NSLog(@"KS2: SOL: %@ = %@",x,cap);
   }];
}

@end
