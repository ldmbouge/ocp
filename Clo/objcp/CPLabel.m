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
#import "CPData.h"
#import "CPLabel.h"
#import "CPSelector.h"
#import "CPSolverI.h"
#import "CPExplorer.h"
#import "CPExplorerI.h"
#import "CPI.h"
#import "CPIntVarI.h"

@implementation CPLabel

+(void) var: (id<CPIntVar>) x
{
    id<CP> cp = [x cp];
    while (![x bound]) {
        CPInt m = [x min];
        [cp try: ^() { 
               [cp label:x with:m];
             } 
             or: ^() { 
                [cp diff:x with:m];
             }];
    }
}

+(void) array: (id<CPIntVarArray>) x
{
    CPInt low = [x low];
    CPInt up = [x up];
    for(CPInt i = low; i <= up; i++) 
        [CPLabel var: [x at: i]];
}

+(void) array: (id<CPIntVarArray>) x orderedBy: (CPInt2Int) orderedBy
{
    id<CP> cp = [x cp];
    CPI* cpi = (CPI*) cp;
    CPSelect* select = [cpi selectInRange: (CPRange){[x low],[x up]}
                              filteredBy: ^bool(CPInt i) { return [[x at: i] bound]; }
                               orderedBy: orderedBy];
    CPInt low = [x low];
    do {
        CPInt i = [select min];
        if (i < low) {
            return;
        }
        [CPLabel var: [x at: i]];
    } while (true);    
}


+(void) heuristic:(id<CPHeuristic>)h
{
   id<CPIntVarArray> av = [h allIntVars];
   NSLog(@"Heuristic on: %@",av);
   id<CP> cp = [av cp];
   CPI* cpi = (CPI*) cp;
   CPSelect* select = [cpi selectInRange: (CPRange){[av low],[av up]}
                              filteredBy: ^bool(CPInt i)      { return [[av at: i] bound]; }
                               orderedBy: ^CPInt(CPInt i) { 
                                  id<CPIntVar> avi = [av at: i];
                                  return [h varOrdering:avi];
                               }];
   CPInt low = [av low];
   do {      
      CPInt i = [select max];
      if (i < low) 
         return;
      id<CPIntVar> x = [av at: i];
      CPSelectMax* valSelect = [[CPSelectMax alloc] initSelectMin:cp
                                                            range:(CPRange){[x min],[x max]}
                                                       filteredBy:^bool(CPInt v)      { return ![x member:v];}
                                                        orderedBy:^CPInt(CPInt v) { return [h valOrdering:v forVar:x];}];
      CPInt val = [valSelect min];
      do {
         CPInt curVal = [valSelect choose];
         if (curVal < val)
            break;
         [cp try:^{
            [cp label:x with:curVal];
         } or:^{
            [cp diff:x with:curVal];
         }];
      } while(![x bound]);       
   } while (true);
}

@end;
