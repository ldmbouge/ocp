/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/DFSController.h"
#import "objcp/CPSolver.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

int main(int argc, const char * argv[])
{   
   @autoreleasepool {      
      NSArray *arguments = [[NSProcessInfo processInfo] arguments];
      NSLog(@"Driver loading file: %@",arguments);
      NSData* model = [NSData dataWithContentsOfFile:[arguments objectAtIndex:1]];
      id<CP> cp = [NSKeyedUnarchiver unarchiveObjectWithData:model];
      id<CPHeuristic> h = nil;
      if ([arguments count] >= 4 && [[arguments objectAtIndex:2] isEqual:@"-h"]) {
         if ([[arguments objectAtIndex:3] isEqual:@"ff"]) {
            h = [CPFactory createFF:cp];
         } else if ([[arguments objectAtIndex:3] isEqual:@"wdeg"]) {
            h = [CPFactory createWDeg:cp];
         } else if ([[arguments objectAtIndex:3] isEqual:@"ibs"]) {
            h = [CPFactory createIBS:cp];
         } else {
            h = [CPFactory createFF:cp];            
         }
      } else {
         h = [CPFactory createFF:cp];
      }
      id<CPInteger> nbSolutions = [CPFactory integer: cp value:0];
      [cp solveAll: 
       ^() {}   
          using: 
       ^() {
         [CPLabel heuristic:h];
         NSLog(@"Got a solution: %@",[h allIntVars]); 
         [nbSolutions incr];
       }];
      NSLog(@"Got %@ solutions",nbSolutions);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];   
      [CPFactory shutdown];
   }
   return 0;
}

