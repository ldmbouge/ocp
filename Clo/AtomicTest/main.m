/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "objcp/CP.h"
#import "objcp/CPEquationBC.h"
#import "objcp/CPBasicConstraint.h"
#import "objcp/CPValueConstraint.h"
#import "objcp/CPCardinality.h"
#import "objcp/CPConcurrency.h"
#import "objcp/CPError.h"
#import "objcp/CPCrFactory.h"

/*

@interface testCard : NSObject {
@private
    
}

@end

@implementation testCard 

-(testCard*) init 
{
    self = [super init];
    return self;
}

-(CPInt) setupCardWith:(CPInt)n size:(CPInt)s
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    CP* m = [[[CP alloc] init] autorelease];
    CPIntVarArrayI* x = [[[CPIntVarArrayI alloc] initCPIntVarArray: m 
                                                            size: s 
                                                          domain: (CPRange){0,n-1}] autorelease];
    //         0 1 2 3 4 5 6 7
    int lb[] = {2,2,2,2,2,2,2,2};
    int ub[] = {3,3,3,3,3,3,3,3};
    CPRange R = (CPRange){0,n-1};
    CPIntArray* lba = [m createIntArray: R value:2]; 
    CPIntArray* uba = [m createIntArray: R value:3];
    printf("%s \n",[[lba description] cStringUsingEncoding:NSASCIIStringEncoding]);
    
//
//    [m post:[[CPCardinalityCst alloc] initCardinalityCst:[m solver] 
//                                                  values:(CPRange){0,n-1} 
//                                                     low:lb 
//                                                   array:x 
//                                                      up:ub]];
// 
    [m post: [CPCardinality on: x low: lba up: uba]]; 
    int* cnt = alloca(sizeof(CPInt)*n);
    CPIntegerI* nbSolutions = [[CPIntegerI alloc] initCPIntegerI: 0];
    [m solveAll: ^() {
        for(CPInt k=0;k<s;k++)
            printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
        printf("]\n");
        [m labelArray: x orderedBy: ^int(int i) { return i;}];
    //    for(CPInt k=0;k<s;k++)
    //     printf("%s%s",(k>0 ? "," : "["),[[[x at:k ]  description] cStringUsingEncoding:NSASCIIStringEncoding]);      
   //     printf("]\n");
        for(CPInt k=0;k<n;k++)cnt[k]=0;
        for(CPInt k=0;k<s;k++)
            cnt[[[x at:k] min]]++;
        for(CPInt k=0;k<n;k++)
            if (!(cnt[k]>=2 && cnt[k] <=3)) {
                printf("cnt should always be in 2..3\n");
                assert(false);
            }
        [nbSolutions incr];
    }
     ];
    printf("GOT %ld solutions\n",[nbSolutions value]);   
    CPInt rv =  [nbSolutions value];
    [pool release];   
    return rv;
}

-(void) testCard1
{
    if ([self setupCardWith:8 size:8]!=0) {
        printf("card-1 has 0 solutions\n");
        assert(false);
    }
}
-(void) testCard2
{
    if ([self setupCardWith:4 size:8]!=2520) {
        printf("card-2 has 2520 solutions\n");
        assert(false);
    }
}
@end

*/

/*
#import "objcp/CP.h"
#import "objcp/CPFactory.h"

typedef int (^Void2Int)(void);
Void2Int makeC1(int i);
Void2Int makeAdd(int i);
void foo();

Void2Int makeC1(int i)
{
   Void2Int rc = ^int() {
      return i;
   };
   return [rc copy];
}

Void2Int makeAdd(int i) 
{
   Void2Int c1 = makeC1(i);
   Void2Int c2 = makeC1(i*2);
   Void2Int rc = ^int() {
      return c1() + c2();
   };
   return [rc copy];
}

void foo() {
   //Void2Int theClosure = makeC1(3);
   for(CPInt k=0;k < 10000000;k++) {
      Void2Int theAdd = makeAdd(3);
      NSLog(@"Calling: %d",theAdd());
      [theAdd release];
   }
}
 */


int main (int argc, const char * argv[])
{
    id<CP> cp = [CPFactory createSolver];
    id<CPVoidInformer> informer = [CPConcurrency voidInformer];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for(CPInt i = 1; i <= 10; i++)
        [array addObject: [CPCrFactory integer: 0]];
    [CPConcurrency parall: (CPRange){1,10} 
                       do: ^void(int i) { 
                           printf("The thread %p is printing %d \n",[NSThread currentThread],i); 
                           int sum = 0;
                           while (true) {
                               sum++;
                               [[array objectAtIndex: i-1] incr];
                               if (sum % 100 == 0) 
                                    [CPConcurrency pumpEvents];
                                if (i == 10 && sum == 10000) {
                                    printf("Notification by thread 10 \n");
                                    [informer notify];
                                }
                           }
                       }
        untilNotifiedBy: informer
     ];
    for(CPInt i = 0; i < 10; i++)
        printf("thread %d terminates with value %d \n",i+1,[(id<CPInteger>)[array objectAtIndex: i] value]);
    [informer release];
    [cp release];
    printf("Main thread is done \n");
    return 0;
}


/*
int main (int argc, const char * argv[])
{
    id<CPInformer> informer = [CPConcurrency informer];
    [CPConcurrency parall: (CPRange){1,2} 
                       do: ^void(int i) { 
                           printf("The thread %p is printing %d \n",[NSThread currentThread],i); 
                           if (i == 1) {
                               for(CPInt k = 1; k <= 1000; k++);
                               printf("I am going to sleep \n");
                               [informer sleepUntilNotified];
                               printf("I am back from my sleep \n");
                           }
                           else {
                               for(CPInt k = 1; k <= 1000000; k++);
                               printf("I am about to notify \n");
                               [informer notify];
                               printf("I am done notifying \n");
                           }
                       }
     ];
    [informer release];
    printf("Main thread is done \n");
    return 0;
}
*/
    
//   foo();   
   
    /*
    id<CP> cp = [CPFactory createSolver];
    CPRange R = (CPRange){1,10};
    id<CPIntVar> x = [CPFactory intVar: cp domain: R];
    id<CPIntSet> S = [CPFactory intSet: cp];
    for(CPInt i = 2; i <= 10; i += 2)
        [S insert: i];
    [cp restrict: x to: S];
    [CPFactory print: x];
    id<IntEnumerator> it = [S enumerator];
    while ([it more]) {
        int v = [it next];
        printf("%d ",v);
    }
    printf("\n");
    NSData* archive = [NSArchiver archivedDataWithRootObject:S];
    id<CPIntSet> S1 = [[NSUnarchiver unarchiveObjectWithData: archive] retain];
    [CPFactory print: S1];
    return 0;
     */
    
    



