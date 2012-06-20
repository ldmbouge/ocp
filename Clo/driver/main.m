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

