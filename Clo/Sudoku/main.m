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
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

void show(id<CPIntVarMatrix> m) 
{
    CPRange R = [m rowRange];
    CPRange C = [m columnRange];
    for(CPInt i = R.low ; i <= R.up; i++) {
        for(CPInt j = C.low ; j <= C.up; j++) 
            printf("%d  ",[[m atRow: i col: j] min]);
        printf("\n");   
    }
    printf("\n");
}

int main (int argc, const char * argv[])
{
    FILE* f = fopen("sudokuFile3.txt","r");
    int nb;
    int r, c, v;
    fscanf(f,"%d \n",&nb);
    printf("number of entries %d \n",nb);
    CPRange R = (CPRange){1,9};
    id<CP> cp = [CPFactory createSolver];
    id<CPIntVarMatrix> x =  [CPFactory intVarMatrix: cp rows: R columns: R domain: R];
    id<CPIntVarArray> a = [CPFactory intVarArray: cp range: R range: R with: ^id<CPIntVar>(CPInt i,CPInt j) { return [x atRow: i col: j]; }];
    [cp solve: 
     ^() {
         for(CPInt i = 0; i < nb; i++) {
             fscanf(f,"%d%d%d",&r,&c,&v);
             [cp label: [x atRow:r col:c] with:v];
         }
         for(CPInt i = 1; i <= 9; i++)
             [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: R with: ^id<CPIntVar>(CPInt j) { return [x atRow: i col: j]; }]]];
         for(CPInt j = 1; j <= 9; j++)
             [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: R with: ^id<CPIntVar>(CPInt i) { return [x atRow: i col: j]; }]]];
         for(CPInt i = 0; i <= 2; i++)
             for(CPInt j = 0; j <= 2; j++)
                 [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp 
                                                                     range: (CPRange){i*3+1,i*3+3}
                                                                     range: (CPRange){j*3+1,j*3+3}
                                                                      with: ^id<CPIntVar>(CPInt r,CPInt c) { return [x atRow: r col: c]; }]]];
     }   
        using: 
     ^() {
         [CPLabel array: a orderedBy: ^CPInt(CPInt i) { return [[a at:i] domsize];}];
         show(x);
     }
     ];
    
    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
    [cp release];
   [CPFactory shutdown];
    return 0;
}

