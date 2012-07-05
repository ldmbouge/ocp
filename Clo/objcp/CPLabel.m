/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
   NSLog(@"Heuristic on: <%lu> %@",[av count],av);
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
