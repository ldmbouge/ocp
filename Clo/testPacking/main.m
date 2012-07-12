//
//  main.m
//  testPacking
//
//  Created by Pascal Van Hentenryck on 7/12/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPlabel.h"

int main (int argc, const char * argv[])
{
   CPRange R = (CPRange){0,3};
   CPRange D = (CPRange){0,1};
   id<CP> cp = [CPFactory createSolver];
   id<CPIntVarArray> item = [CPFactory intVarArray:cp range: R domain: D];
   id<CPIntArray> itemSize = [CPFactory intArray: cp range: R value: 0];
   id<CPIntArray> binSize = [CPFactory intArray:cp range: D value: 14];
   [itemSize set: 8 at: 0];
   [itemSize set: 7 at: 1];
   [itemSize set: 6 at: 2];
   [itemSize set: 5 at: 3];
   
   [cp solve:
    ^() {
       [cp add: [CPFactory packing: item itemSize: itemSize binSize: binSize]];
    }
          using:
    ^() {
       [CPLabel array: item];
       for(CPInt i = 0; i <= 3; i++)
          printf("item[%d]=%d \n",i,[item[i] value]);
       printf("\n");
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   [cp release];
   [CPFactory shutdown];
   return 0;
}

