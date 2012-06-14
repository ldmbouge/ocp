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


#import <objc/objc-auto.h>
#import <Foundation/NSGarbageCollector.h>
#import <Foundation/NSObject.h>
#import "objcp/CPFactory.h"
#import "cont.h"
#import "Silly.h"
#import "DFSController.h"
#import "SillyVar.h"
#import "CPSolver.h"
#import "CPBasicConstraint.h"
#import "CP.h"


void EvalFuncOnGrid( float(^block)(float) ) {
   int i;
   for ( i = 0; i < 5 ; ++i ) {
      float x = i * 0.1;
      printf("%f %f |", x, block(x));
   }
}

void Caller(void) {
   float forceConst = 3.445;
   EvalFuncOnGrid(^(float x) { return 0.5f * forceConst * x * x; }
                  );
}

@interface Foo : NSObject {
   int _x;
   int _y;
}
   -(Foo*)initWith:(CPInt)x y:(CPInt)y;
   -(void)bye;   
   -(void)finalize;
@end

@implementation Foo
-(Foo*)initWith:(CPInt) x y:(CPInt)y {
   [super init];
   _x = x;
   _y = y;
   return self;
}
-(void)bye {
   NSLog(@"foo bye called\n");
}
-(void)finalize {
   NSLog(@"Foo::finalize called %d \n",_x);
}
@end

void silly(int i) 
{
   [[Foo alloc]initWith:i y:20];
}

static id resume=nil;

int fact(int n) {
   if (n==0) {
      resume = [NSCont takeContinuation];
      return 1;
   } else {
      return n * fact(n-1);
   }   
}

static int nbCall = 0;

void startSearch() {
   int x;
   initContinuationLibrary(&x);
   int f5 = fact(5);
   nbCall++;
   if (nbCall % 500000 ==0) 
      NSLog(@"%d:\tFact(5) = %d\n",nbCall,f5);
   if (nbCall < 20000000)
      [resume call];
}

void traverseTree() {
   int x;
   initContinuationLibrary(&x);
   DFSController* cp = [[DFSController alloc] init];
   id<CP> m = [CPFactory createSolver];
   int* cnt = NSAllocateCollectable(sizeof(CPInt), NSCollectorDisabledOption);
   *cnt = 0;
   const CPInt nbv = 8;
   NSMutableArray* vars = [[NSMutableArray alloc] initWithCapacity:nbv];
   for(CPInt i=0;i< nbv;i++)
      [vars addObject: [[SillyVar alloc] initWithLow:0 up:10]];
   NSLog(@"Array before starting: %@\n",vars);
   [m solveAll: ^() {
      for(CPInt i=0;i<nbv;i++) {
         SillyVar* cv = [vars objectAtIndex:i];
         int v = 0;
         while (![cv bound] && v < [cv imax]) {
            [m try: ^() {[cv set: v];}
                or: ^()  {[cv reset];}
             ];
	    v = v+1;
         }
         if (![cv bound]) [cp fail];
      }
      //NSLog(@"At leaf!  %@\n",vars);   
      (*cnt)++;   
   }];
}

int main (int argc, const char * argv[])
{
   //objc_startCollectorThread();
/*   for(CPInt i=0;i<1000;i++) {
      silly(i);
   }
   
   printf("Hello world");
   Caller();
   printf("\n");
   objc_clear_stack(OBJC_CLEAR_RESIDENT_STACK);
   [[NSGarbageCollector defaultCollector] collectExhaustively];
  */ 

   //startSearch();
   
/*   Silly* os = [[Silly alloc] init:10 y:2];
   double t = 0;
   for(CPInt i=0;i<500000000;i++) {
      t += [os callMe:i];
   } 
   NSLog(@"Method call: %f\n",t);
 */
   
   traverseTree();
   return 0;
}



