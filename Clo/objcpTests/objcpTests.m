/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "objcpTests.h"

#import "objcp/CP.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPController.h"
#import "objcp/CPTracer.h"
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
   CPRange R = (CPRange){1,n};
   id<CP> m = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   id<CPIntVarArray> x  = [CPFactory intVarArray:m range:R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:m range:R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<CPIntVarArray> xn = [CPFactory intVarArray:m range:R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 

   [m solveAll: 
    ^() {
       [m add: [CPFactory alldifferent: x]];
       [m add: [CPFactory alldifferent: xp]];
       [m add: [CPFactory alldifferent: xn]];
    } 
         using:
    ^() {
       [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return [[x at:i] domsize];}];
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
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray: m range:R domain: (CPRange){0,n-1}];
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   
   [m solveAll: ^() {
      [m add: [CPFactory sumbool:x geq:2]];
   } using: ^() {
      [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return i;}];
      int nbOne = 0;
      for(CPInt k=0;k<s;k++) {
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
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray: m range:R domain: (CPRange){0,n-1}];
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [m add: [CPFactory sumbool:x geq:8]];
   } using: ^() {
      [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return i;}];
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
   printf("GOT %d solutions\n",[nbSolutions value]);   
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
   id<CPIntVarArray> nx = [CPFactory intVarArray: m range:R with:^id<CPIntVar>(CPInt i) {
      return [CPFactory negate:[x at:i]];
   }];
   
   
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [m add:[CPFactory sumbool:x geq:2]];
      [m add:[CPFactory sumbool:nx geq:8]];
   } using: ^() {
      [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return i;}];
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
   printf("GOT %d solutions\n",[nbSolutions value]);   
   [m release];
   [CPFactory shutdown];
}

- (void) testWLSBEqc
{
   int s = 10;
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x = [CPFactory intVarArray: m range:R domain: RANGE(0,1)];
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   
   [m solveAll: ^() {
      [m add: [CPFactory sumbool:x eq:4]];
   } using: ^() {
      [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return i;}];
      int nbOne = 0;
      for(CPInt k=0;k<s;k++)
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
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x  = [CPFactory intVarArray: m range:R domain: (CPRange){0,n-1}];
   id<CPIntVarArray> nx = [CPFactory intVarArray: m range:R with:^id<CPIntVar>(CPInt i) {
      return [CPFactory negate:[x at:i]];
   }];
   
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return i;}];
      for(NSInteger k=0;k<s;k++) {
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
      [m add:[CPFactory reify:b with:x eqi:5]];
   } using: ^{
      [CPLabel var:x];
      STAssertTrue([b min] == ([x min]==5), @"reification not ok");
      
   }
    ];
   [m release];
   [CPFactory shutdown];
}

-(void)testReify3
{
   id<CP> m = [CPFactory createSolver];
   id<CPIntVar> x = [CPFactory intVar:m domain:(CPRange){0,10}];
   id<CPIntVar> y = [CPFactory intVar:m domain:(CPRange){0,10}];
   id<CPIntVar> b = [CPFactory intVar:m domain:(CPRange){0,1}];
   [m solveAll:^() {
      [m add:[CPFactory reify:b with:x eq:y]];
   } using: ^{
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
   id<CP> m = [CPFactory createSolver];
   id<CPIntVar> x = [CPFactory intVar:m domain:(CPRange){0,10}];
   id<CPIntVar> y = [CPFactory intVar:m domain:(CPRange){0,10}];
   id<CPIntVar> b = [CPFactory intVar:m domain:(CPRange){0,1}];
   [m solveAll:^() {
      [m add:[CPFactory reify:b with:x eq:y]];
   } using: ^{
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
      long k = random() % 1000;
      [tree insertObject:[NSNumber numberWithLong:k] forKey:(NSInteger)k];
   }
   NSLog(@"content: %@\n",tree);
   [pool release];
}

-(void)testEQ3
{
   int s = 2;
   CPRange R = (CPRange){0,s-1};
   id<CP> m = [CPFactory createSolver];
   id<CPIntVarArray> x  = [CPFactory intVarArray: m range:R domain: (CPRange){0,10}];  
   id<CPIntVar> zn = [CPFactory intVar:m domain:(CPRange){-10,0}];
   id<CPIntVar> z = [CPFactory intVar:zn scale:-1];
   id<CPInteger> nbSolutions = [CPFactory integer: m value: 0];
   [m solveAll: ^() {
      [m add: [CPFactory lEqualc:z to:5]];
      [m add: [CPFactory equal3:[x at:0] to:[x at: 1] plus:z consistency:DomainConsistency]];
   }
         using:^{
            [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return i;}];
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

-(void)testRetractConstraintInSearch
{
   CPInt n = 8;
   CPRange R = (CPRange){1,n};
   id<CP> cp = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value: 0];
   [CPFactory intArray:cp range:R with: ^CPInt(CPInt i) { return i; }];
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:i]; }];
   id<CPIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }];
   
   [cp solveAll:
    ^() {
       [cp add: [CPFactory alldifferent: x consistency: DomainConsistency]];
       [cp add: [CPFactory alldifferent: xp consistency:DomainConsistency]];
       [cp add: [CPFactory alldifferent: xn consistency:DomainConsistency]];
    }
          using:
    ^() {
       for(CPInt i=1;i<=n;i++) {
          while(![x[i] bound]) {
             const CPInt curMin = [x[i] min];
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
@end
