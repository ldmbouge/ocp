/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "objcpTests.h"

#import "objcp/CPSolver.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "ORFoundation/ORController.h"
#import "ORFoundation/ORTracer.h"
#import "ORFoundation/ORSet.h"
#import "ORFoundation/ORSetI.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"
#import "ORFoundation/ORAVLTree.h"

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
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:n-1];
   id<ORInteger> nbSolutions = [CPFactory integer: m value: 0];
   id<ORIntVarArray> x  = [CPFactory intVarArray:m range:R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:m range:R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<ORIntVarArray> xn = [CPFactory intVarArray:m range:R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }];

   [m add: [CPFactory alldifferent: x]];
   [m add: [CPFactory alldifferent: xp]];
   [m add: [CPFactory alldifferent: xn]];
   [m solveAll:
    ^() {
       [CPLabel array: x orderedBy: ^ORInt(ORInt i) { return [[x at:i] domsize];}];
       [nbSolutions incr];
   }
    ];
   NSLog(@"Got %@ solutions\n",nbSolutions);
   STAssertTrue([nbSolutions value]==92, @"queens-8 has 92 solutions"); 
   [m release];
   [CPFactory shutdown];
}

- (void) testWL1
{
   int s = 10;
   int n = 2;
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [CPFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORInteger> nbSolutions = [CPFactory integer: m value: 0];
   
   [m add: [CPFactory sumbool:x geq:2]];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^ORInt(ORInt i) { return i;}];
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
   [CPFactory shutdown];
}

- (void) testWL2
{
   int s = 10;
   int n = 2;
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [CPFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m add: [CPFactory sumbool:x geq:8]];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^ORInt(ORInt i) { return i;}];
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
   [CPFactory shutdown];
}

- (void) testWL3 
{
   int s = 10;
   int n = 2;
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x  = [CPFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORIntVarArray> nx = [CPFactory intVarArray: m range:R with:^id<ORIntVar>(ORInt i) {
      return [CPFactory negate:[x at:i]];
   }];
   
   
   id<ORInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m add:[CPFactory sumbool:x geq:2]];
   [m add:[CPFactory sumbool:nx geq:8]];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^ORInt(ORInt i) { return i;}];
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
   [CPFactory shutdown];
}

- (void) testWLSBEqc
{
   int s = 10;
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x = [CPFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:1]];
   id<ORInteger> nbSolutions = [CPFactory integer: m value: 0];
   
   [m add: [CPFactory sumbool:x eq:4]];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^ORInt(ORInt i) { return i;}];
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
   [CPFactory shutdown];
}



- (void) testBoolView
{
   int s = 8;
   int n = 2;
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x  = [CPFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:n-1]];
   id<ORIntVarArray> nx = [CPFactory intVarArray: m range:R with:^id<ORIntVar>(ORInt i) {
      return [CPFactory negate:[x at:i]];
   }];
   
   id<ORInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^ORInt(ORInt i) { return i;}];
      for(ORInt k=0;k<s;k++) {
         STAssertTrue([[x at:k] min] == ![[nx at:k] min], @"x and nx should be negations of each other");
      }
      [nbSolutions  incr];
   }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);   
   [m release];
   [CPFactory shutdown];
}
-(void)testReify1
{
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntVar> x = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:10]];
   id<ORIntVar> b = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:1]];
   NSArray* av = [NSArray arrayWithObjects:x,b,nil];
   
   [m add:[CPFactory reify:b with:x neq:5]];
   [m solveAll:^() {
      [CPLabel var:x];
      NSLog(@"solution: %@\n",av);
      STAssertTrue([b min] == ([x min]!=5), @"reification not ok");
   }
    ];
   [m release];
   [CPFactory shutdown];
}
-(void)testReify2
{
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntVar> x = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:10]];
   id<ORIntVar> b = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:1]];
   [m add:[CPFactory reify:b with:x eqi:5]];
   [m solveAll:^() {
      [CPLabel var:x];
      STAssertTrue([b min] == ([x min]==5), @"reification not ok");
      
   }
    ];
   [m release];
   [CPFactory shutdown];
}

-(void)testReify3
{
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntVar> x = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:10]];
   id<ORIntVar> y = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:10]];
   id<ORIntVar> b = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:1]];
   [m add:[CPFactory reify:b with:x eq:y consistency:ValueConsistency]];
   [m solveAll:^() {
      [CPLabel var:x];
      [CPLabel var:y];
      [CPLabel var:b];
      STAssertTrue([b min] == ([x min]==[y min]), @"reification (b<=> (x==y)) not ok");      
   }
    ];
   [m release];
   [CPFactory shutdown];
}

-(void)testReify4
{
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntVar> x = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:10]];
   id<ORIntVar> y = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:10]];
   id<ORIntVar> b = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:1]];
   [m add:[CPFactory reify:b with:x eq:y consistency:DomainConsistency]];
   [m solveAll:^() {
      [CPLabel var:b];
      [CPLabel var:x];
      STAssertTrue([b min] == ([x min]==[y min]), @"reification (b first) (b<=> (x==y)) not ok");
   }
    ];
   [m release];
   [CPFactory shutdown];
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
   id<CPSolver> m = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange:m low:0 up:s-1];
   id<ORIntVarArray> x  = [CPFactory intVarArray: m range:R domain: [ORFactory intRange:m low:0 up:10]];
   id<ORIntVar> zn = [CPFactory intVar:m domain:[ORFactory intRange:m low:-10 up:0]];
   id<ORIntVar> z = [CPFactory intVar:zn scale:-1];
   id<ORInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m add: [CPFactory lEqualc:z to:5]];
   [m add: [CPFactory equal3:[x at:0] to:[x at: 1] plus:z consistency:DomainConsistency]];
   [m solveAll:^{
            [CPLabel array: x orderedBy: ^ORInt(ORInt i) { return i;}];
            NSLog(@"Solution: %@ = %@",x,z);
            [nbSolutions  incr];
         }
    ];
   printf("GOT %d solutions\n",[nbSolutions value]);   
   [m release];
   [CPFactory shutdown]; 
}

-(void)testCoder
{
   /*
   // First, setup  an "initial CP/Solver pair
   id<CPSolver> m = [CPFactory createSolver];
   // Add 2 variables and a constraint
   id<ORIntVar> x = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:10]];
   id<ORIntVar> b = [CPFactory intVar:m domain:[ORFactory intRange:m low:0 up:1]];
   [CPFactory negate:b];
   
   [m add:[CPFactory reify:b with:x eq:5]];
   // Serialize  the whole thing!
   NSData* archive = [NSArchiver archivedDataWithRootObject:[m solver]];
   
   NSLog(@"Archive size: %ld\n",[archive length]);
   // Deserialize the whole thing. We get back a solver with
   // 1. The same variables
   // 2. The same constraints
   // 3. Constraints are posted in the new solver.
   id<CPSolver> other = [NSUnarchiver unarchiveObjectWithData:archive];

   
   NSMutableArray* ca = [other allVars];
   
   NSLog(@"Variables in clone: %@\n",ca);
   
   NSLog(@"Original solver: %p\n",[m solver]);
   NSLog(@"cloned   solver: %p\n",other);
   
   // Go ahead, search in the new guy. Print its solution (and show the 
   // variables in the original to show them unaffected). 
   // Check that the resolution works as expected (backtracking is working)
   [other solveAll:^() {
      id<ORIntVar> xp = [ca objectAtIndex:0];
      id<ORIntVar> bp = [ca objectAtIndex:1];
      [CPLabel var:xp];
      NSLog(@"solution : %@\n",ca);
      NSLog(@"originals: %@\n",[[m solver] allVars]);
      STAssertTrue([bp min] == ([xp min]==5), @"reification not ok");
   }];

   [other release];
   [m release];
    */
}

-(void)testRetractConstraintInSearch
{
   ORInt n = 8;
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = [ORFactory intRange:cp low:1 up:n];
   id<ORInteger> nbSolutions = [CPFactory integer: cp value: 0];
   [CPFactory intArray:cp range:R with: ^ORInt(ORInt i) { return i; }];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range: R domain: R];
   id<ORIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:i]; }];
   id<ORIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<ORIntVar>(ORInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }];
   
   [cp add: [CPFactory alldifferent: x consistency: DomainConsistency]];
   [cp add: [CPFactory alldifferent: xp consistency:DomainConsistency]];
   [cp add: [CPFactory alldifferent: xn consistency:DomainConsistency]];
   [cp solveAll: ^() {
       for(ORInt i=1;i<=n;i++) {
          while(![x[i] bound]) {
             const ORInt curMin = [x[i] min];
             [cp try:^{
                [cp add: [CPFactory equalc:x[i] to:curMin]];
             } or:^{
                [cp add: [CPFactory notEqualc:x[i] to:curMin]];
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
   [CPFactory shutdown];
}

-(void)testKnapsack1
{
   ORInt n = 4;
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range:[ORFactory intRange:cp low:1 up:n] domain:[ORFactory intRange:cp low:0 up:1]];
   id<ORIntVar> cap = [CPFactory intVar:cp domain:[ORFactory intRange:cp low:0 up:25]];
   int* coef = (int[]){3,4,10,30};
   id<ORIntArray> w = [CPFactory intArray:cp range:[ORFactory intRange:cp low:1 up:n] with:^ORInt(ORInt i) {return coef[i-1];}];
   [cp add:[CPFactory knapsack: x weight: w capacity:cap ]];
   [cp solveAll:^{
      NSLog(@"START: %@ = %@",x,cap);
      [CPLabel array:x];
      [CPLabel var:cap];
      NSLog(@"SOL: %@ = %@",x,cap);
   }];
}

-(void)testKnapsack2
{
   ORInt n = 4;
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range:[ORFactory intRange:cp low:1 up:n] domain:[ORFactory intRange:cp low:0 up:1]];
   id<ORIntVar> cap = [CPFactory intVar:cp domain:[ORFactory intRange:cp low:3 up:25]];
   int* coef = (int[]){3,4,10,30};
   id<ORIntArray> w = [CPFactory intArray:cp range:[ORFactory intRange:cp low:1 up:n] with:^ORInt(ORInt i) {return coef[i-1];}];
   [cp add:[CPFactory knapsack: x weight: w capacity:cap ]];
   [cp solveAll:^{
      NSLog(@"KS2: START: %@ = %@",x,cap);
      [CPLabel array:x];
      [CPLabel var:cap];
      NSLog(@"KS2: SOL: %@ = %@",x,cap);
   }];
}


-(void)testKnapsack3
{
   ORInt n = 4;
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntVarArray> x = [CPFactory intVarArray:cp range:[ORFactory intRange:cp low:1 up:n] domain:[ORFactory intRange:cp low:0 up:1]];
   id<ORIntVar> cap = [CPFactory intVar:cp domain:[ORFactory intRange:cp low:14 up:25]];
   int* coef = (int[]){3,4,10,30};
   id<ORIntArray> w = [CPFactory intArray:cp range:[ORFactory intRange:cp low:1 up:n] with:^ORInt(ORInt i) {return coef[i-1];}];
   [cp add:[CPFactory knapsack: x weight: w capacity:cap ]];
   [cp solveAll:^{
      NSLog(@"KS2: START: %@ = %@",x,cap);
      [CPLabel array:x];
      [CPLabel var:cap];
      NSLog(@"KS2: SOL: %@ = %@",x,cap);
   }];
}

@end
