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

#import <Foundation/Foundation.h>
#import "objcp/CP.h"
#import "CPSolver.h"
#import "CPFactory.h"


static int nbSol = 0;

//CPStatus labelStatic(DFSTracer* t,CPSolver* m,NSArray* x,int from,int to) 
//{
//   if (from > to) {
//       nbSol++;
//      return CPSuccess;
//   } else {
//      CPIVar* xk = [x objectAtIndex:from];
//      if ([xk bound])
//         return labelStaticREC(t,m, x, from+1, to);
//      else {
//         for(CPInt i = [xk min];i <= [xk max];i++) {
//            if (![xk member:i]) continue;
//            [t pushNode];
//            CPStatus s = [m label:xk with:i];
//            if (s!=CPFailure)
//               s = labelStaticREC(t,m, x, from+1, to);
//            [t popNode];
//            s = [m diff:xk with:i];
//            if (s == CPFailure)
//               return s;
//         }
//         return CPFailure;
//      }
//   }
//}
//
//void search(CPSolver* m,NSArray* x,int from,int to)
//{
//   initContinuationLibrary(&to);
//   solveAll(m, ^() {
//      //labelStatic([[DFSTracer alloc] initDFSTracer:m], m, x, 0, n-1);
//      //labelStatic2( m, x, 0, n-1);
//      labelFF(m, x, from, to);
//      nbSol++;
//      /*      [x enumerateObjectsUsingBlock:^(id xi,NSUInteger i,BOOL* stop) {
//       printf("%s %lu:%s",(i>1 ? "," : " "),i,[[xi description] cStringUsingEncoding:NSASCIIStringEncoding]);
//       }];
//       printf("\n");*/   
//   }, ^() {
//      NSLog(@"search done..."); 
//   });
//}

#define BLOCK ^() {
#define ENDBLOCK }
#define bound(a) ^bool(int i) { return ![[a objectAtIndex:i] bound];}
#define minDomain(a) ^int(int i) { return [[x objectAtIndex:i] domsize];}

void labelFF(id<CP> m,NSArray* x,int from,int to)
{
   CPIntegerI* nbSolutions = [[CPIntegerI alloc] initCPIntegerI: 0];
   [m solve: ^() {
      [m limitSolutions: 200 in: ^() {
         [m forrange: (CPRange){from,to}
          filteredBy: ^bool(int i) { return ![[x objectAtIndex:i] bound];}
           orderedBy: ^int(int i) { return [[x objectAtIndex:i] domsize];}
                  do: ^(int i) { [m label: [x objectAtIndex:i]]; }
          ];
         nbSol++;
         [nbSolutions incr];
      }
       ];
   }     
    ];
   printf("The number of solutions is %ld \n",[nbSolutions value]);
}

void labelFF1(CP* m,NSArray* x,int from,int to)
{
   CPInteger* nbSolutions = [[CPInteger alloc] initCPInteger: 0];
   [m solveAll: ^() {
      [m restart: ^() {
         [m limitSolutions: 1 in: ^() {
            [m   forrange: (CPRange){from,to}
               filteredBy: ^bool(int i) { return ![[x objectAtIndex:i] bound];}
                orderedBy: ^int(int i) { return [[x objectAtIndex:i] domsize];}
                       do: ^(int i) { [ m label: [x objectAtIndex:i]]; }
             ];
         }
          ];
         [x enumerateObjectsUsingBlock:^(id xi,NSUInteger i,BOOL* stop) {
            printf("%s %lu:%s",(i>1 ? "," : " "),i,[[xi description] cStringUsingEncoding:NSASCIIStringEncoding]);
         }];
         printf("\n");
         [nbSolutions incr];
      }
       onRestart: ^() { printf("I am restarting ... %ld \n",[nbSolutions value]); }
          isDone: ^bool() { return [nbSolutions value] >= 5; }
       ];
   }
    ];
}

void labelFF2(CP* m,NSArray* x,int from,int to)
{
   CPInteger* nbSolutions = [[CPInteger alloc] initCPInteger: 0];
   [m solveAll: ^() {
      [m restart: ^() {
         [m limitSolutions: 1 in: ^() {
            [m   forrange: (CPRange){from,to}
               filteredBy: ^bool(int i) { return ![[x objectAtIndex:i] bound];}
                orderedBy: ^int(int i) { return [[x objectAtIndex:i] domsize];}
                       do: ^(int i) { [ m label: [x objectAtIndex:i]]; }
             ];
         }
          ];
         [nbSolutions incr];
      }
       onRestart: ^() { printf("I am restarting ... %ld \n",[nbSolutions value]); }
          isDone: ^bool() { return [nbSolutions value] >= 5; }
       ];
   }
    ];
}

void labelFF3(CP* m,id<CPIntVarArray> x,int from,int to)
{
   CPInteger* nbSolutions = [[CPInteger alloc] initCPInteger: 0];
   [m solve: ^() {
      [m labelArray: x orderedBy: ^int(int i) { return [[x at:i] domsize];}];
      for(CPInt i = from; i <= to; i++) 
         printf("%s %d:%s",(i>1 ? "," : " "),i,[[[x at: i] description] cStringUsingEncoding:NSASCIIStringEncoding]);
      printf("\n");
      [nbSolutions incr];
   }
    ];
   printf("NbSolutions: %ld \n",[nbSolutions value]);   
}

void labelFF4(CP* m,id<CPIntVarArray> x,int from,int to)
{
  [m search: ^() {
      [m maximize: [x at: 1] in:  ^() {
	  [m labelArray: x orderedBy: ^int(int i) { return [[x at:i] domsize];}];
	  for(CPInt i = from; i <= to; i++) 
	    printf("%s %d:%s",(i>1 ? "," : " "),i,[[[x at: i] description] cStringUsingEncoding:NSASCIIStringEncoding]);
	  printf("\n");
	}
	];
    }
    ];
}


int main(int argc, const char * argv[])
{
//  [CPStreamManager setRandomized];
    long startTime = [CPRuntimeMonitor cputime];
    int n = 5;
   
    id pool = [[NSAutoreleasePool alloc] init];
   
   id<CP> m = [CPFactory createSolver]; 
   id<CPIntVarArray> x = [m createIntVarArray:(CPRange){0,n-1} domain:(CPRange){0,n-1}];
    [m solve: ^() 
     {
        [m post: [CPAllDifferent on:x]];
         for(CPInt k = 0; k < 3; k++) {
             [m diff: [x at: k] with: 3];
             [m diff: [x at: k] with: 4];
         }
         printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);      
     }   
       using: ^()
     {
         [m labelArray: x orderedBy: ^int(int i) { return [[x at:i] domsize];}];
         printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);      
     }
    ];
    NSLog(@"Solver status: %@\n",m);
    NSLog(@"Quitting");
    [pool release];
  
    long endTime = [CPRuntimeMonitor cputime];
    printf("Time: %ld \n",endTime - startTime);
    return 0;
}

/*
int main(int argc, const char * argv[])
{
//  [CPStreamManager setRandomized];
    long startTime = [CPRuntimeMonitor cputime];
    int n = 8;
   
    id pool = [[NSAutoreleasePool alloc] init];
    CP* m = [[[CP alloc] init] autorelease];
    CPIntVarArray* x = [[[CPIntVarArray alloc] initCPIntVarArray: m size: n domain: (CPRange){0,n-1}] autorelease];
    for(CPInt i=0;i<n;i++) {
        id xi = [x at: i];
        for(CPInt j=i+1;j<n;j++) {
            id xj = [x at: j];
            [m post:[[[AC3NEqual alloc] initAC3NEqualOn:xi and:xj and:0] autorelease]];
            [m post:[[[AC3NEqual alloc] initAC3NEqualOn:xi and:xj and:i-j] autorelease]];
            [m post:[[[AC3NEqual alloc] initAC3NEqualOn:xi and:xj and:j-i] autorelease]];
        }
    }
    CPExpr* e1 = [CPExpr cst: 3];
    CPExpr* e2 = [CPExpr var: [x at: 1]];
    CPExpr* e3 = [e1 plus: e2];
    [e3 print];
    CPExpr* es = [CPExpr sum: (CPRange){0,n-1} filteredBy: ^bool(int i) { return i < 3; } of: ^CPExpr*(int i) { return [CPExpr var: [x at: i]]; }];
    printf("Sum: ");
    [es print];
    
    
    typedef CPStatus (^AC3Callback)(void);
  
    for(CPInt i = 0; i < n-1; i++) 
        printf("%s %d:%s",(i>1 ? "," : " "),i,[[[x at: i] description] cStringUsingEncoding:NSASCIIStringEncoding]);
    printf("\n");
  
    //labelStatic([[DFSTracer alloc] initDFSTracer:m], m, x, 0, n-1);
    //labelStatic2( m, x, 0, n-1);
    labelFF4( m, x, 0, n-1);
    for(CPInt i = 0; i < n-1; i++) 
        printf("%s %d:%s",(i>1 ? "," : " "),i,[[[x at: i] description] cStringUsingEncoding:NSASCIIStringEncoding]);
    printf("\n");
  
    NSLog(@"Solver status: %@\n",m);
    NSLog(@"Quitting");
    [pool release];
  
    long endTime = [CPRuntimeMonitor cputime];
    printf("Time: %ld \n",endTime - startTime);
    return 0;
}
*/
