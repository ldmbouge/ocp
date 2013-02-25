/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>


static int nbSol = 0;

#define BLOCK ^() {
#define ENDBLOCK }
#define bound(a) ^bool(int i) { return ![[a objectAtIndex:i] bound];}
#define minDomain(a) ^int(int i) { return [[x objectAtIndex:i] domsize];}

void labelFF(id<CPProgram> m,NSArray* x,int from,int to)
{
   CPIntegerI* nbSolutions = [[CPIntegerI alloc] initCPIntegerI: 0];
   [m solve: ^() {
      [m limitSolutions: 200 in: ^() {
         [m forall: RANGE(m,from,to)
          suchThat: ^bool(int i) { return ![[x objectAtIndex:i] bound];}
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
      [m repeat: ^() {
         [m limitSolutions: 1 in: ^() {
            [m   forall: RANGE(m,from,to)
               suchThat: ^bool(int i) { return ![[x objectAtIndex:i] bound];}
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
       onRepeat: ^() { printf("I am restarting ... %ld \n",[nbSolutions value]); }
          until: ^bool() { return [nbSolutions value] >= 5; }
       ];
   }
    ];
}

void labelFF2(CP* m,NSArray* x,int from,int to)
{
   CPInteger* nbSolutions = [[CPInteger alloc] initCPInteger: 0];
   [m solveAll: ^() {
      [m repeat: ^() {
         [m limitSolutions: 1 in: ^() {
            [m   forall: RANGE(m,from,to)
               suchThat: ^bool(int i) { return ![[x objectAtIndex:i] bound];}
                orderedBy: ^int(int i) { return [[x objectAtIndex:i] domsize];}
                       do: ^(int i) { [ m label: [x objectAtIndex:i]]; }
             ];
         }
          ];
         [nbSolutions incr];
      }
       onRepeat: ^() { printf("I am restarting ... %ld \n",[nbSolutions value]); }
          until: ^bool() { return [nbSolutions value] >= 5; }
       ];
   }
    ];
}

void labelFF3(CP* m,id<ORIntVarArray> x,int from,int to)
{
   CPInteger* nbSolutions = [[CPInteger alloc] initCPInteger: 0];
   [m solve: ^() {
      [m labelArray: x orderedBy: ^int(int i) { return [[x at:i] domsize];}];
      for(ORInt i = from; i <= to; i++) 
         printf("%s %d:%s",(i>1 ? "," : " "),i,[[[x at: i] description] cStringUsingEncoding:NSASCIIStringEncoding]);
      printf("\n");
      [nbSolutions incr];
   }
    ];
   printf("NbSolutions: %ld \n",[nbSolutions value]);   
}

void labelFF4(CP* m,id<ORIntVarArray> x,int from,int to)
{
  [m search: ^() {
      [m maximize: [x at: 1] in:  ^() {
	  [m labelArray: x orderedBy: ^int(int i) { return [[x at:i] domsize];}];
	  for(ORInt i = from; i <= to; i++) 
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
    long startTime = [ORRuntimeMonitor cputime];
    int n = 5;
   
    id pool = [[NSAutoreleasePool alloc] init];
   
   id<CPSolver> m = [CPFactory createSolver]; 
   id<ORIntVarArray> x = [m createIntVarArray:(ORRange){0,n-1} domain:(ORRange){0,n-1}];
    [m solve: ^() 
     {
        [m post: [CPAllDifferent on:x]];
         for(ORInt k = 0; k < 3; k++) {
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
  
    long endTime = [ORRuntimeMonitor cputime];
    printf("Time: %ld \n",endTime - startTime);
    return 0;
}

/*
int main(int argc, const char * argv[])
{
//  [CPStreamManager setRandomized];
    long startTime = [ORRuntimeMonitor cputime];
    int n = 8;
   
    id pool = [[NSAutoreleasePool alloc] init];
    CP* m = [[[CP alloc] init] autorelease];
    CPIntVarArray* x = [[[CPIntVarArray alloc] initCPIntVarArray: m size: n domain: (ORRange){0,n-1}] autorelease];
    for(ORInt i=0;i<n;i++) {
        id xi = [x at: i];
        for(ORInt j=i+1;j<n;j++) {
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
    CPExpr* es = [CPExpr sum: (ORRange){0,n-1} suchThat: ^bool(int i) { return i < 3; } of: ^CPExpr*(int i) { return [CPExpr var: [x at: i]]; }];
    printf("Sum: ");
    [es print];
    
    
    typedef ORStatus (^AC3Callback)(void);
  
    for(ORInt i = 0; i < n-1; i++) 
        printf("%s %d:%s",(i>1 ? "," : " "),i,[[[x at: i] description] cStringUsingEncoding:NSASCIIStringEncoding]);
    printf("\n");
  
    //labelStatic([[DFSTracer alloc] initDFSTracer:m], m, x, 0, n-1);
    //labelStatic2( m, x, 0, n-1);
    labelFF4( m, x, 0, n-1);
    for(ORInt i = 0; i < n-1; i++) 
        printf("%s %d:%s",(i>1 ? "," : " "),i,[[[x at: i] description] cStringUsingEncoding:NSASCIIStringEncoding]);
    printf("\n");
  
    NSLog(@"Solver status: %@\n",m);
    NSLog(@"Quitting");
    [pool release];
  
    long endTime = [ORRuntimeMonitor cputime];
    printf("Time: %ld \n",endTime - startTime);
    return 0;
}
*/
