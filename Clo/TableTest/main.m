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
#import "objcp/CPlabel.h"
#import "objcp/CPCrFactory.h"


id<CPIntSet> knightMoves(id<CP> cp,int i) 
{
    id<CPIntSet> S = [CPFactory intSet: cp];
    if (i % 8 == 1) {
        [S insert: i-15]; [S insert: i-6]; [S insert: i+10]; [S insert: i+17];
    }
    else if (i % 8 == 2) {
        [S insert: i-17]; [S insert: i-15]; [S insert: i-6]; [S insert: i+10]; [S insert: i+15]; [S insert: i+17];
    }     
    else if (i % 8 == 7) {
        [S insert: i-17];[S insert: i-15];[S insert: i-10];[S insert: i+6];[S insert: i+15];[S insert: i+17];
    }
    else if (i % 8 == 0) {
        [S insert: i-17];[S insert: i-10];[S insert: i+6];[S insert: i+15];
    }           
    else {
        [S insert: i-17];[S insert: i-15];[S insert: i-10];[S insert: i-6];[S insert: i+6];[S insert: i+10];[S insert: i+15];[S insert: i+17];
    }
    return S;
}
void printCircuit(id<CPIntVarArray> jump)
{
    int curr = 1;
    printf("1");
    do {
        curr = [[jump at: curr] min];
        printf("->%d",curr);
    } while (curr != 1);
    printf("\n");
}
int main (int argc, const char * argv[])
{
    CPRange R = (CPRange){0,2};
    CPRange D = (CPRange){0,30};
    id<CP> cp = [CPFactory createSolver];
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
     }
           using:
     ^() {        
         [CPLabel array: x];
         printf("%s\n",[[x description] cStringUsingEncoding:NSASCIIStringEncoding]);
     }
     ];
    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
    [cp release];
    [CPFactory shutdown];
    return 0;
}



