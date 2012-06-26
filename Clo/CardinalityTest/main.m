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
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPCrFactory.h"
#import "objcp/CPLabel.h"
#import "objcp/CPHeuristic.h"

//345 choices
//254 fail
//5027 propagations

// First solution
// 22 choices 20 fail 277 propagations

/*
int main (int argc, const char * argv[])
{
    CPInt n = 8;
    CPRange R = (CPRange){1,n};
    CPRange D = (CPRange){1,2};
    CPRange DV = (CPRange){1,3};
    id<CP> cp = [CPFactory createSolver];
    id<CPIntArray> lb = [CPFactory intArray:cp range:D with: ^CPInt(CPInt i) { return 4; }]; 
    id<CPIntArray> ub = [CPFactory intArray:cp range:D with: ^CPInt(CPInt i) { return 6; }]; 
    id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: DV];
    [cp solve: 
     ^() {
         [cp add: [CPFactory cardinality: x low: lb up: ub consistency:DomainConsistency]];
     }   
        using: 
     ^() {
//         [cp label:[x at: 1] with: 2];
         printf("lb: %s\n",[[lb description] cStringUsingEncoding:NSASCIIStringEncoding]);
         printf("x: %s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);
//         [CPLabel array: x];
     }
     ];
    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
    [cp release];
    [CPFactory shutdown];
    return 0;
}
 */

int main(int argc, const char * argv[])
{
    CPInt n = 14;
    CPRange Periods = (CPRange){1,n/2};
    CPRange Teams = (CPRange){1,n};
    CPRange Weeks = (CPRange){1,n-1};
    CPRange EWeeks = (CPRange){1,n};
    CPRange HomeAway = (CPRange){0,1};
    CPRange Games = (CPRange){0,n*n};
    
    id<CP> cp = [CPFactory createSolver];
    id<CPIntArray> c = [CPFactory intArray:cp range:Teams with: ^CPInt(CPInt i) { return 2; }]; 
    id<CPIntVarMultiArray> team = [CPFactory intVarMultiArray:cp range: Periods : EWeeks : HomeAway domain:Teams];
    id<CPIntVarMatrix> game =     [CPFactory intVarMatrix:cp rows: Periods columns: Weeks domain:Games];
    id<CPIntVarArray> allgames =  [CPFactory intVarArray:cp range: Periods range: Weeks 
                                                    with: ^id<CPIntVar>(CPInt p,CPInt w) { return [game atRow: p col: w]; }];
    id<CPTable> table = [CPFactory table: cp arity: 3];
    for(CPInt i = 1; i <= n; i++)
        for(CPInt j = i+1; j <= n; j++)
            [table insert: i : j : (i-1)*n + j-1];
    [table close];

    [cp solve: 
     ^() {
         for(CPInt w = 1; w < n; w++)
             for(CPInt p = 1; p <= n/2; p++) 
                 [cp add: [CPFactory table: table on: [team at: p : w : 0] : [team at: p : w : 1] : [game atRow: p col: w]]];
         [cp add: [CPFactory alldifferent:allgames]];
         for(CPInt w = 1; w <= n; w++) 
             [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: Periods range: HomeAway   
                                                                 with: ^id<CPIntVar>(CPInt p,CPInt h) { return [team at: p : w : h ]; } ]]];
         for(CPInt p = 1; p <= n/2; p++) 
             [cp add: [CPFactory cardinality: [CPFactory intVarArray: cp range: EWeeks range: HomeAway with: ^id<CPIntVar>(CPInt w,CPInt h) { return [team at: p : w : h ]; }]
                                         low: c 
                                          up: c
                                 consistency:DomainConsistency]];
     }   
        using: 
     ^() {
         [CPLabel array: allgames orderedBy: ^CPInt(CPInt i) { return [[allgames at:i] domsize];}];
         for(CPInt p = 1; p <= n/2; p++) {
             for(CPInt w = 1; w < n; w++) 
                 printf("%d-%d [%2d]  ",[[team at: p : w : 0] min],[[team at: p : w : 1] min],[[game atRow: p col: w] min]);
             printf("\n");
         }
         //         [cp label:[x at: 1] with: 2];
//         printf("lb: %s\n",[[lb description] cStringUsingEncoding:NSASCIIStringEncoding]);
         //         [CPLabel array: x];
     }
     ];
    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
    [cp release];
    [CPFactory shutdown];
    return 0;
}

/*
id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: D];
id<CPTable> table = [CPFactory table: cp arity: 3];
for(CPInt i = 0; i < 5; i++)
for(CPInt j = i+1; j < 5; j++)
[table insert: i : j : i*5 + j];
[table close];
[table print];
[cp solveAll: 
 ^() {
     [cp add: [CPFactory table: table on: x]];
*/
