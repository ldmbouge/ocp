/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

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
#import <ORProgram/CPSolver.h>

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

-(void) testContext
{
   double a = 1.0;
   double b = 3.0;
   initContinuationLibrary((int*)&a);
   ORIReady();
   _MM_SET_ROUNDING_MODE(_MM_ROUND_UP);
   double c  = a / b;
   _MM_SET_ROUNDING_MODE(_MM_ROUND_DOWN);
   static NSCont* k = nil;
   k = [NSCont takeContinuation];
   if ([k nbCalls] == 0) {
      double d  = a / b;
      NSLog(@" c , d = %15f, %15f",c,d);
      _MM_SET_ROUNDING_MODE(_MM_ROUND_UP);
      double c1  = a / b;
      [k call];
   } else {
      double d  = a / b;
      NSLog(@" c , d = %15f, %15f",c,d);
   }
}
- (void)testQueens
{
   int n = 8;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = RANGE(m,1,n);
   id<ORMutableInteger> nbSolutions = [ORFactory mutable: m value: 0];
   id<ORIntVarArray> x  = [ORFactory intVarArray:m range:R domain: R];
   id<ORIntVarArray> xp = [ORFactory intVarArray:m range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:m var:x[i] shift:i]; }];
   id<ORIntVarArray> xn = [ORFactory intVarArray:m range:R with: ^id<ORIntVar>(ORInt i) { return [ORFactory intVar:m var:x[i] shift:-i]; }];
   [m add: [ORFactory alldifferent: x]];
   [m add: [ORFactory alldifferent: xp]];
   [m add: [ORFactory alldifferent: xn]];

   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:
    ^() {
       [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return [cp domsize:[x at:i]];}];
       [nbSolutions incr:cp];
   }
    ];
   NSLog(@"Got %@ solutions\n",nbSolutions);
   XCTAssertTrue([cp intValue:nbSolutions]==92, @"queens-8 has 92 solutions");
//<<<<<<< HEAD
//   [m release];
//   [ORFactory shutdown];
//=======
//>>>>>>> master
}

- (void) testWL1
{
   int s = 10;
   int n = 2;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORMutableInteger> nbSolutions = [ORFactory mutable: m value: 0];
   [m add: [ORFactory sumbool:m array:x geqi:2]];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return i;}];
      int nbOne = 0;
      for(ORInt k=0;k<s;k++) {
         //printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
         nbOne += [cp min:x[k]] == 1;
      }
      //printf("]\n");
      [nbSolutions  incr:cp];
      XCTAssertTrue(nbOne>=2, @"Each solution must have at least 2 ones");
   }
    ];
   printf("GOT %d solutions\n",[cp intValue: nbSolutions]);
}

- (void) testWL2
{
   int s = 10;
   int n = 2;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORMutableInteger> nbSolutions = [ORFactory mutable: m value: 0];
   [m add: [ORFactory sumbool:m array:x geqi:8]];

   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return i;}];
      int nbOne = 0;
      for(ORInt k=0;k<s;k++) {
         //printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
         nbOne += [cp min:[x at:k]] == 1;
      }
      //printf("]\n");
      [nbSolutions  incr:cp];
      XCTAssertTrue(nbOne>=8, @"Each solution must have at least 2 ones");
   }
    ];
   printf("GOT %d solutions\n",[cp intValue:nbSolutions]);
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
   
   
   id<ORMutableInteger> nbSolutions = [ORFactory mutable: m value: 0];
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return i;}];
      int nbOne = 0;
      int nbZero = 0;
      for(ORInt k=0;k<s;k++) {
         //printf("%s%s",(k>0 ? "," : "["),[[[x at:k]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
         nbOne  += [cp min:[x at:k]] == 1;
         nbZero += [cp min:[nx at:k]] == 1;
      }
      //printf("]\n");
      //for(NSInteger k=0;k<s;k++) {
      //   printf("%s%s",(k>0 ? "," : "["),[[[nx at:k]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
      //}
      //printf("]\n");
      [nbSolutions  incr:cp];
      XCTAssertTrue(nbOne>=2, @"Each solution must have at least 2 ones");
      XCTAssertTrue(nbZero>=8, @"Each solution must have at least 8 zeroes");
   }
    ];
   printf("GOT %d solutions\n",[cp intValue:nbSolutions]);
}

- (void) testWLSBEqc
{
   int s = 10;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: m range:R domain: RANGE(m,0,1)];
   id<ORMutableInteger> nbSolutions = [ORFactory mutable: m value: 0];
   [m add: [ORFactory sumbool:m array:x eqi:4]];
   
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return i;}];
      int nbOne = 0;
      for(ORInt k=0;k<s;k++)
         nbOne += [cp min:x[k]] == 1;
      NSLog(@"SOL: %@",x);
      [nbSolutions  incr:cp];
      XCTAssertTrue(nbOne == 4, @"Each solution must have at least 4 ones");
   }
    ];
   printf("GOT %d solutions\n",[cp intValue:nbSolutions]);
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
   
   id<ORMutableInteger> nbSolutions = [ORFactory mutable: m value: 0];
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return i;}];
      for(ORInt k=0;k<s;k++) {
         XCTAssertTrue([cp min:x[k]] == ![cp min:nx[k]], @"x and nx should be negations of each other");
      }
      [nbSolutions  incr:cp];
   }
    ];
   printf("GOT %d solutions\n",[cp intValue:nbSolutions]);
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
      XCTAssertTrue([cp min:b] == ([cp min:x]!=5), @"reification not ok");
   }
    ];
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
      XCTAssertTrue([cp min:b] == ([cp min:x]==5), @"reification not ok");
   }
    ];
}

-(void)testReify3
{
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVar> x = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> y = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> b = [ORFactory intVar:m domain:RANGE(m,0,1)];
   [m add:[ORFactory reify:m boolean:b with:x eq:y]];
   id<CPProgram> cp = [ORFactory createCPProgram:m];

   [cp solveAll:^() {
      [cp label:x];
      [cp label:y];
      [cp label:b];
      XCTAssertTrue([cp min:b] == ([cp min:x]==[cp min:y]), @"reification (b<=> (x==y)) not ok");
   }
    ];
}

-(void)testReify4
{
   id<ORModel> m = [ORFactory createModel];
   id<ORIntVar> x = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> y = [ORFactory intVar:m domain:RANGE(m,0,10)];
   id<ORIntVar> b = [ORFactory intVar:m domain:RANGE(m,0,1)];
   [m add:[ORFactory reify:m boolean:b with:x eq:y]];

   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll:^() {
      [cp label:b];
      [cp label:x];
      XCTAssertTrue([cp min:b] == ([cp min:x]==[cp min:y]), @"reification (b first) (b<=> (x==y)) not ok");
   }
    ];
}

-(void)testAVL
{
   @autoreleasepool {
      ORAVLTree* tree = [[[ORAVLTree alloc] initEmptyAVL] autorelease];
      for(NSInteger i=0;i<20;i++) {
         ORInt k = random() % 1000;
         [tree insertObject:[NSNumber numberWithLong:k] forKey:(ORInt)k];
      }
      NSLog(@"content: %@\n",tree);
   }
}

-(void)testEQ3
{
   int s = 2;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = RANGE(m,0,s-1);
   id<ORIntVarArray> x  = [ORFactory intVarArray: m range:R domain: RANGE(m,0,10)];
   id<ORIntVar> zn = [ORFactory intVar:m domain:RANGE(m,-10,0)];
   id<ORIntVar> z = [ORFactory intVar:m var:zn scale:-1];
   id<ORMutableInteger> nbSolutions = [ORFactory mutable: m value: 0];
   [m add: [z leq: @5]];
   [m add: [x[0] eq:[x[1] plus:z]]];
  
  
   id<CPProgram> cp = [ORFactory createCPProgram:m];
   [cp solveAll: ^() {
      [cp labelArray: x orderedBy: ^ORDouble(ORInt i) { return i;}];
      NSLog(@"Solution: %@ = %@",x,z);
      [nbSolutions  incr:cp];
   }
    ];
   printf("GOT %d solutions\n",[cp intValue:nbSolutions]);
}

/** Currently not working 
-(void)testRetractConstraintInSearch
{
   ORInt n = 8;
   id<ORModel> m = [ORFactory createModel];
   id<ORIntRange> R = RANGE(m,1,n);
   id<ORMutableInteger> nbSolutions = [ORFactory mutable:m value: 0];
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
          while(![cp bound:x[i]]) {
             const ORInt curMin = [cp min:x[i]];
             [cp try:^{
                [cp add: [x[i] eq:@(curMin)]];
             } or:^{
                [cp add: [x[i] neq:@(curMin)]];
             }];
          }
       }
       [nbSolutions incr:cp];
    }
    ];
   printf("GOT %d solutions\n",[cp intValue:nbSolutions]);
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   XCTAssertTrue([cp intValue:nbSolutions] == 92, @"Expecting 92 solutions");
   [cp release];
}
*/

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

-(void)testDiv
{
   @autoreleasepool {
      id<ORModel> test = [ORFactory createModel];
      id<ORIntVar> foo = [ORFactory intVar:test domain:RANGE(test, 4,6)];
      id<ORIntVar> bar = [ORFactory intVar:test domain:RANGE(test, 0,FDMAXINT)];
      
      // bar = (10*foo) / 2
      [test add:[bar eq:[[foo mul:@(10)] div:@(2)]]];
      id<CPProgram> testSolver = [ORFactory createCPProgram:test];
      [testSolver solveAll:^{
         [testSolver label:foo];
         XCTAssert([testSolver bound:foo] && [testSolver bound:bar],"both vars should be bound");
         int fv = [testSolver min:foo];
         int bv = [testSolver min:bar];
         XCTAssertEqual(bv, fv * 10 / 2, "Satisfy relation");
         NSLog(@"foo: [%d,%d], bar: [%d,%d]",
               [testSolver min:foo],
               [testSolver max:foo],
               [testSolver min:bar],
               [testSolver max:bar]
               );
      }];
   }
}

-(void)testDiv2
{
   @autoreleasepool {
      id<ORModel> test = [ORFactory createModel];
      id<ORIntVar> foo = [ORFactory intVar:test domain:RANGE(test, 1,9)];
      id<ORIntVar> bar = [ORFactory intVar:test domain:RANGE(test, 1,9)];
      id<ORIntVar> zoo = [ORFactory intVar:test domain:RANGE(test, 0,FDMAXINT)];
      
      [test add:[zoo eq:[[foo mul:@(13)] div:bar]]];
      id<CPProgram> testSolver = [ORFactory createCPProgram:test];
      [testSolver solveAll:^{
         [testSolver label:foo with:6];
         [testSolver label:bar with:3];
         XCTAssert([testSolver bound:foo] && [testSolver bound:bar],"both vars should be bound");
         int fv = [testSolver min:foo];
         int bv = [testSolver min:bar];
         int zv = [testSolver min:zoo];
         XCTAssertEqual(zv, fv * 13 / bv, "Satisfy relation");
         NSLog(@"foo: [%d,%d], bar: [%d,%d] zoo:[%d,%d]",
               [testSolver min:foo],
               [testSolver max:foo],
               [testSolver min:bar],
               [testSolver max:bar],
               [testSolver min:zoo],
               [testSolver max:zoo]
               );
      }];
   }
}
-(void)testISV1
{
   @autoreleasepool {
      CPSolver* p = (id)[CPSolverFactory solver];
      NSSet* s = [NSSet setWithObjects:@0,@1,@2,@3,@4,@5,@6,@7,@8,@9, nil];
      id<ORIntSet> src = [ORFactory intSet:p set:s];
      id<CPIntSetVar> x = [CPFactory intSetVar:[p engine] withSet:src];
      id<CPIntSetVar> y = [CPFactory intSetVar:[p engine] withSet:src];
      id<CPIntSetVar> z = [CPFactory intSetVar:[p engine] withSet:src];
      [[p engine] add:[CPFactory inter:x with:y eq:z]];
      [p solveAll:^{
         [[p engine] enforce:^{
            [z require:9];
         }];
         NSLog(@"%@\nINTER \n%@ = \n%@",x,y,z);
         [[p engine] enforce:^{
            [x exclude:8];
         }];
         NSLog(@"%@\nINTER \n%@ = \n%@",x,y,z);
         [[p engine] enforce:^{
            [x require:0];
         }];
         NSLog(@"%@\nINTER \n%@ = \n%@",x,y,z);
         [[p engine] enforce:^{
            [z exclude:0];
         }];
         NSLog(@"%@\nINTER \n%@ = \n%@",x,y,z);
         
      }];
      NSLog(@"the var is: %@",x);
   }
}
@end
