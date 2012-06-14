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

int main (int argc, const char * argv[])
{
   CPInt n = 8;
   CPRange R = (CPRange){1,n};
   id<CP> cp = [CPFactory createSolver];
   id<CPInteger> nbSolutions = [CPFactory integer: cp value: 0];
   [CPFactory intArray:cp range:R with: ^CPInt(CPInt i) { return i; }]; 
   id<CPIntVarArray> x = [CPFactory intVarArray:cp range: R domain: R];
   id<CPIntVarArray> xp = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:i]; }]; 
   id<CPIntVarArray> xn = [CPFactory intVarArray:cp range: R with: ^id<CPIntVar>(CPInt i) { return [CPFactory intVar: [x at: i] shift:-i]; }]; 
////    id<CPExpr> e = [[x at: 1] add: nbSolutions];
    id<CPExpr> e = [CPFactory sum: cp range: R filteredBy: ^bool(CPInt i) {return false;} of: ^id<CPExpr>(CPInt i) { return [x at: i]; }];
    printf("GOT %d min(e)\n",[e min]);
    id<CPIntSet> set = [CPFactory intSet: cp];
    [set insert: 13];
    [set insert: 26];
    [set insert: 26];
    [set delete: 25];
    printf("is 26 present: %d \n",[set member: 26]);
    printf("is 25 present: %d \n",[set member: 25]);
    printf("size: %d \n",[set size]);
    [CPFactory print: set];
    id<CPVoidInformer> informer = [CPFactory voidInformer: cp];
    [informer wheneverNotifiedDo: ^(void) { [nbSolutions incr]; } ];
   [cp solve: 
     ^() {
        [cp add: [CPFactory alldifferent: x consistency:DomainConsistency]];
         [cp add: [CPFactory alldifferent: xp consistency:DomainConsistency]];
         [cp add: [CPFactory alldifferent: xn consistency:DomainConsistency]];
     }   
           using: 
     ^() {
         [CPLabel array: x orderedBy: ^CPInt(CPInt i) { return [[x at:i] domsize];}];
//          printnl(x);
//          [nbSolutions incr];
         [informer notify];
     }
     ];
    printf("GOT %d solutions\n",[nbSolutions value]);
    NSLog(@"Solver status: %@\n",cp);
    NSLog(@"Quitting");
   NSLog(@"SOLUTION IS: %@",x);
    [cp release];
    [CPFactory shutdown];
    return 0;
}
