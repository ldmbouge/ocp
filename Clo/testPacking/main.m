/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPlabel.h"

int main (int argc, const char * argv[])
{
   id<CPSolver> cp = [CPFactory createSolver];
   id<ORIntRange> R = RANGE(cp,0,9);
   id<ORIntRange> D = RANGE(cp,0,1);
   id<CPIntVarArray> item = [CPFactory intVarArray:cp range: R domain: D];
   id<CPIntArray> itemSize = [CPFactory intArray: cp range: R value: 0];
   id<CPIntVarArray> binSize = [CPFactory intVarArray:cp range: RANGE(cp,0,0) domain: RANGE(cp,34,35)];
   [itemSize set: 10 at: 9];
   [itemSize set: 10 at: 8];
   [itemSize set: 10 at: 7];
   [itemSize set: 9 at: 6];
   [itemSize set: 9 at: 5];
   [itemSize set: 9 at: 4];
   [itemSize set: 9 at: 3];
   [itemSize set: 5 at: 2];
   [itemSize set: 2 at: 1];
   [itemSize set: 1 at: 0];
   
   [cp solveAll:
    ^ {
       [cp add: [CPFactory packing: item itemSize: itemSize load: binSize]];
    }
          using:
    ^ {
       [CPLabel array: item];
       NSLog(@"%@",item);
       NSLog(@"%@",binSize);
       printf("\n");
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;
}

