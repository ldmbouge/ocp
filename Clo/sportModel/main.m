//
//  main.m
//  sportModel
//
//  Created by Pascal Van Hentenryck on 8/12/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import "objcp/CPConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPFactory.h"
#import "objcp/CPLabel.h"

int main(int argc, const char * argv[])
{

   @autoreleasepool {

      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> R = [ORFactory intRange: model low: 0 up: 10];
      id<ORIntVarArray> a = [ORFactory intVarArray: model range: R domain: R];
      id<ORConstraint> cstr = [ORFactory alldifferent: a];
      
      [model add: cstr];
      
      id<CPSolver> cp = [CPFactory createSolver];
      [cp addModel: model];
      
      [cp solve: ^{
         for(ORInt i = 0; i <= 10; i++)
            [CPLabel var: a[i]];
      }];
      for(ORInt i = 0; i <= 10; i++)
         printf("x[%d] = %d \n",i,[a[i] value]);

      ORLong startTime = [ORRuntimeMonitor cputime];
      ORInt n = 14;
      id<CPSolver> cp = [CPFactory createSolver];
      id<ORIntRange> Periods = RANGE(cp,1,n/2);
      id<ORIntRange> Teams = RANGE(cp,1,n);
      id<ORIntRange> Weeks = RANGE(cp,1,n-1);
      id<ORIntRange> EWeeks = RANGE(cp,1,n);
      id<ORIntRange> HomeAway = RANGE(cp,0,1);
      id<ORIntRange> Games = RANGE(cp,0,n*n);
      id<ORIntArray> c = [CPFactory intArray:cp range:Teams with: ^ORInt(ORInt i) { return 2; }];
      id<ORIntVarMatrix> team = [CPFactory intVarMatrix:cp range: Periods : EWeeks : HomeAway domain:Teams];
      id<ORIntVarMatrix> game = [CPFactory intVarMatrix:cp range: Periods : Weeks domain:Games];
      id<ORIntVarArray> allteams =  [CPFactory intVarArray:cp range: Periods : EWeeks : HomeAway
                                                      with: ^id<ORIntVar>(ORInt p,ORInt w,ORInt h) { return [team at: p : w : h]; }];
      id<ORIntVarArray> allgames =  [CPFactory intVarArray:cp range: Periods : Weeks
                                                      with: ^id<ORIntVar>(ORInt p,ORInt w) { return [game at: p : w]; }];
      id<CPTable> table = [CPFactory table: cp arity: 3];
      for(ORInt i = 1; i <= n; i++)
         for(ORInt j = i+1; j <= n; j++)
            [table insert: i : j : (i-1)*n + j-1];
      
      for(ORInt w = 1; w < n; w++)
         for(ORInt p = 1; p <= n/2; p++)
            [cp add: [CPFactory table: table on: [team at: p : w : 0] : [team at: p : w : 1] : [game at: p : w]]];
      [cp add: [CPFactory alldifferent: allgames]];
      for(ORInt w = 1; w <= n; w++)
         [cp add: [CPFactory alldifferent: [CPFactory intVarArray: cp range: Periods : HomeAway
                                                             with: ^id<ORIntVar>(ORInt p,ORInt h) { return [team at: p : w : h ]; } ]]];
      for(ORInt p = 1; p <= n/2; p++)
         [cp add: [CPFactory cardinality: [CPFactory intVarArray: cp range: EWeeks : HomeAway
                                                            with: ^id<ORIntVar>(ORInt w,ORInt h) { return [team at: p : w : h ]; }]
                                     low: c
                                      up: c
                             consistency:DomainConsistency]];
      
      [cp solve:
       ^() {
          /*
           for(ORInt p = 1; p <= n/2 ; p++) {
           id<ORIntVarArray> ap =  [CPFactory intVarArray:cp range: Weeks with: ^id<ORIntVar>(ORInt w) { return [game at: p : w]; }];
           id<ORIntVarArray> aw =  [CPFactory intVarArray:cp range: Periods with: ^id<ORIntVar>(ORInt w) { return [game at: w : p]; }];
           [CPLabel array: ap orderedBy: ^ORInt(ORInt i) { return [[ap at:i] domsize];}];
           [CPLabel array: aw orderedBy: ^ORInt(ORInt i) { return [[aw at:i] domsize];}];
           }
           */
          [CPLabel array: allgames orderedBy: ^ORInt(ORInt i) { return [[allgames at:i] domsize];}];
          [CPLabel array: allteams orderedBy: ^ORInt(ORInt i) { return [[allteams at:i] domsize];}];
          ORLong endTime = [ORRuntimeMonitor cputime];
          printf("Solution \n");
          for(ORInt p = 1; p <= n/2; p++) {
             for(ORInt w = 1; w < n; w++)
                printf("%2d-%2d [%3d]  ",[[team at: p : w : 0] min],[[team at: p : w : 1] min],[[game at: p : w] min]);
             printf("\n");
          }
          printf("Execution Time: %lld \n",endTime - startTime);
       }
       ];
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [CPFactory shutdown];
      return 0;

    }
    return 0;
}

