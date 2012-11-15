/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <objc/objc-auto.h>
#import <Foundation/NSGarbageCollector.h>
#import <Foundation/NSObject.h>
#import "cont.h"
#import "Silly.h"
#import "DFSController.h"
#import "SillyVar.h"
#import "CPEngine.h"
#import "CPBasicConstraint.h"
#import "CPSolver.h"


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
   -(Foo*)initWith:(ORInt)x y:(ORInt)y;
   -(void)bye;   
   -(void)finalize;
@end

@implementation Foo
-(Foo*)initWith:(ORInt) x y:(ORInt)y {
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
   ORDFSController* cp = [[ORDFSController alloc] init];
   id<CPSolver> m = [CPFactory createSolver];
   int* cnt = NSAllocateCollectable(sizeof(ORInt), NSCollectorDisabledOption);
   *cnt = 0;
   const ORInt nbv = 8;
   NSMutableArray* vars = [[NSMutableArray alloc] initWithCapacity:nbv];
   for(ORInt i=0;i< nbv;i++)
      [vars addObject: [[SillyVar alloc] initWithLow:0 up:10]];
   NSLog(@"Array before starting: %@\n",vars);
   [m solveAll: ^() {
      for(ORInt i=0;i<nbv;i++) {
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
/*   for(ORInt i=0;i<1000;i++) {
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
   for(ORInt i=0;i<500000000;i++) {
      t += [os callMe:i];
   } 
   NSLog(@"Method call: %f\n",t);
 */
   
   traverseTree();
   return 0;
}



