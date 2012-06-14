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


#import "objcpTests.h"

#import "objcp/CP.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPController.h"
#import "objcp/CPTracer.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"
#import "objcp/CPAVLTree.h"

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
   CPRange R = (CPRange){1,n};
   id<CP> m = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   id<CPIntVarArray> x  = [CPFactory intVarArray:m range:R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:m range:R with: ^id<CPIntVar>(NSInteger i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<CPIntVarArray> xn = [CPFactory intVarArray:m range:R with: ^id<CPIntVar>(NSInteger i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 

   [m solveAll: 
    ^() {
       [m add: [CPFactory alldifferent: x]];
       [m add: [CPFactory alldifferent: xp]];
       [m add: [CPFactory alldifferent: xn]];
    } 
         using:
    ^() {
       [CPLabel array: x orderedBy: ^NSInteger(NSInteger i) { return [[x at:i] domsize];}];
       [nbSolutions incr];
   }
    ];
   NSLog(@"Got %ld solutions\n",[nbSolutions value]);
   STAssertTrue([nbSolutions value]==92, @"queens-8 has 92 solutions"); 
   [m release];
   [CPFactory shutdown];
}

- (void) testWL1
{
   int s = 10;
   int n = 2;
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray: m range:R domain: (CPRange){0,n-1}];
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   
   [m solveAll: ^() {
      [m add: [CPFactory sumbool:x geq:2]];
   } using: ^() {
      [CPLabel array: x orderedBy: ^NSInteger(NSInteger i) { return i;}];
      int nbOne = 0;
      for(NSInteger k=0;k<s;k++) {
         //printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
         nbOne += [[x at:k] min] == 1;
      }
      //printf("]\n");
      [nbSolutions  incr];
      STAssertTrue(nbOne>=2, @"Each solution must have at least 2 ones");
   }
    ];
   printf("GOT %ld solutions\n",[nbSolutions value]);   
   [m release];
   [CPFactory shutdown];
}

- (void) testWL2
{
   int s = 10;
   int n = 2;
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray: m range:R domain: (CPRange){0,n-1}];
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [m add: [CPFactory sumbool:x geq:8]];
   } using: ^() {
      [CPLabel array: x orderedBy: ^NSInteger(NSInteger i) { return i;}];
      int nbOne = 0;
      for(NSInteger k=0;k<s;k++) {
         //printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
         nbOne += [[x at:k] min] == 1;
      }
      //printf("]\n");
      [nbSolutions  incr];
      STAssertTrue(nbOne>=8, @"Each solution must have at least 2 ones");
   }
    ];
   printf("GOT %ld solutions\n",[nbSolutions value]);   
   [m release];
   [CPFactory shutdown];
}

- (void) testWL3 
{
   int s = 10;
   int n = 2;
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x  = [CPFactory intVarArray: m range:R domain: (CPRange){0,n-1}];
   id<CPIntVarArray> nx = [CPFactory intVarArray: m range:R with:^id<CPIntVar>(NSInteger i) {
      return [CPFactory negate:[x at:i]];
   }];
   
   
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [m add:[CPFactory sumbool:x geq:2]];
      [m add:[CPFactory sumbool:nx geq:8]];
   } using: ^() {
      [CPLabel array: x orderedBy: ^NSInteger(NSInteger i) { return i;}];
      int nbOne = 0;
      int nbZero = 0;
      for(NSInteger k=0;k<s;k++) {
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
   printf("GOT %ld solutions\n",[nbSolutions value]);   
   [m release];
   [CPFactory shutdown];
}
- (void) testBoolView
{
   int s = 8;
   int n = 2;
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x  = [CPFactory intVarArray: m range:R domain: (CPRange){0,n-1}];
   id<CPIntVarArray> nx = [CPFactory intVarArray: m range:R with:^id<CPIntVar>(NSInteger i) {
      return [CPFactory negate:[x at:i]];
   }];
   
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^NSInteger(NSInteger i) { return i;}];
      for(NSInteger k=0;k<s;k++) {
         STAssertTrue([[x at:k] min] == ![[nx at:k] min], @"x and nx should be negations of each other");
      }
      [nbSolutions  incr];
   }
    ];
   printf("GOT %ld solutions\n",[nbSolutions value]);   
   [m release];
   [CPFactory shutdown];
}
-(void)testReify1
{
   id<CP> m = [CPFactory createSolver];
   id<CPIntVar> x = [CPFactory intVar:m domain:(CPRange){0,10}];
   id<CPIntVar> b = [CPFactory intVar:m domain:(CPRange){0,1}];
   NSArray* av = [NSArray arrayWithObjects:x,b,nil];
   
   [m solveAll:^() {
      [m add:[CPFactory reify:b with:x neq:5]];
   } using:^{
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
   id<CP> m = [CPFactory createSolver];
   id<CPIntVar> x = [CPFactory intVar:m domain:(CPRange){0,10}];
   id<CPIntVar> b = [CPFactory intVar:m domain:(CPRange){0,1}];
   [m solveAll:^() {
      [m add:[CPFactory reify:b with:x eq:5]];      
   } using: ^{
      [CPLabel var:x];
      STAssertTrue([b min] == ([x min]==5), @"reification not ok");
      
   }
    ];
   [m release];
   [CPFactory shutdown];
}

-(void)testAVL
{
   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   CPAVLTree* tree = [[[CPAVLTree alloc] initEmptyAVL] autorelease];
   for(NSInteger i=0;i<20;i++) {
      long k = random() % 1000;
      [tree insertObject:[NSNumber numberWithLong:k] forKey:(NSInteger)k];
   }
   NSLog(@"content: %@\n",tree);
   [pool release];
}

-(void)testCoder
{
   /*
   // First, setup  an "initial CP/Solver pair
   id<CP> m = [CPFactory createSolver];
   // Add 2 variables and a constraint
   id<CPIntVar> x = [CPFactory intVar:m domain:(CPRange){0,10}];
   id<CPIntVar> b = [CPFactory intVar:m domain:(CPRange){0,1}];
   [CPFactory negate:b];
   
   [m add:[CPFactory reify:b with:x eq:5]];
   // Serialize  the whole thing!
   NSData* archive = [NSArchiver archivedDataWithRootObject:[m solver]];
   
   NSLog(@"Archive size: %ld\n",[archive length]);
   // Deserialize the whole thing. We get back a solver with
   // 1. The same variables
   // 2. The same constraints
   // 3. Constraints are posted in the new solver.
   id<CP> other = [NSUnarchiver unarchiveObjectWithData:archive];

   
   NSMutableArray* ca = [other allVars];
   
   NSLog(@"Variables in clone: %@\n",ca);
   
   NSLog(@"Original solver: %p\n",[m solver]);
   NSLog(@"cloned   solver: %p\n",other);
   
   // Go ahead, search in the new guy. Print its solution (and show the 
   // variables in the original to show them unaffected). 
   // Check that the resolution works as expected (backtracking is working)
   [other solveAll:^() {
      id<CPIntVar> xp = [ca objectAtIndex:0];
      id<CPIntVar> bp = [ca objectAtIndex:1];
      [CPLabel var:xp];
      NSLog(@"solution : %@\n",ca);
      NSLog(@"originals: %@\n",[[m solver] allVars]);
      STAssertTrue([bp min] == ([xp min]==5), @"reification not ok");
   }];

   [other release];
   [m release];
    */
}
@end
