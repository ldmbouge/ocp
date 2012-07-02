/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

void show(id<CPIntVarMatrix> m) 
{
    CPRange R = [m range: 0];
    CPRange C = [m range: 1];
    for(CPInt i = R.low ; i <= R.up; i++) {
        for(CPInt j = C.low ; j <= C.up; j++) 
            printf("%d  ",[[m at: i : j] min]);
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
    id<CPIntVarMatrix> x =  [CPFactory intVarMatrix: cp range: R : R domain: R];
    id<CPIntVarArray> a = [CPFactory intVarArray: cp range: R range: R with: ^id<CPIntVar>(CPInt i,CPInt j) { return [x at: i : j]; }];
    [cp solve: 
     ^() {
         for(CPInt i = 0; i < nb; i++) {
             fscanf(f,"%d%d%d",&r,&c,&v);
             [cp label: [x at: r : c] with:v];
         }
         for(CPInt i = 1; i <= 9; i++)
             [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: R with: ^id<CPIntVar>(CPInt j) { return [x at: i : j]; }]]];
         for(CPInt j = 1; j <= 9; j++)
             [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: R with: ^id<CPIntVar>(CPInt i) { return [x at: i : j]; }]]];
         for(CPInt i = 0; i <= 2; i++)
             for(CPInt j = 0; j <= 2; j++)
                 [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp 
                                                                     range: (CPRange){i*3+1,i*3+3}
                                                                     range: (CPRange){j*3+1,j*3+3}
                                                                      with: ^id<CPIntVar>(CPInt r,CPInt c) { return [x at: r : c]; }]]];
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

