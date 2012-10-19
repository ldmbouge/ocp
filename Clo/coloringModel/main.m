/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import "ORConcretizer.h"
#import <ORModeling/ORModelTransformation.h>
#import "ORFoundation/ORFoundation.h"
#import "ORFoundation/ORSemBDSController.h"
#import "ORFoundation/ORSemDFSController.h"
#import "../ORProgram/ORConcretizer.h"

#import "objcp/CPSolver.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"


NSString* tab(int d);

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORLong startTime = [ORRuntimeMonitor wctime];
      id<ORModel> model = [ORFactory createModel];
      //FILE* dta = fopen("smallColoring.col","r");
      //FILE* dta = fopen("test-n30-e50.col","r");
      FILE* dta = fopen("test-n80-p40-0.col","r");
      int nbv = 0,nbe = 0;
      fscanf(dta,"%d %d",&nbv,&nbe);
      nbe -= 1;
      id<ORIntRange> V = [ORFactory intRange:model low:1 up:nbv];
      id<ORIntMatrix> adj = [ORFactory intMatrix:model range:V :V];
      for (ORInt i=1; i<=nbv; i++) {
         for(ORInt j =1;j <= nbv;j++) {
            [adj set:NO at: i : j];
         }
      }
      for(ORInt i = 1;i<=nbe;i++) {
         ORInt a,b;
         fscanf(dta,"%d %d ",&a,&b);
         [adj set:YES at:a : b];
         [adj set:YES at: b: a];
      }
      id<ORIntArray> deg = [ORFactory intArray:model range:V with:^ORInt(ORInt i) {
         ORInt d = 0;
         for(ORInt j=1;j <= nbv;j++)
            d +=  [adj at:i :j];
         return d;
      }];
      
      id<ORIntVarArray> c  = [ORFactory intVarArray:model range:V domain: V];
      id<ORIntVar>      m  = [ORFactory intVar:model domain:V];
      for(ORInt i=1;i<=nbv;i++)
         [model add: [ORFactory lEqual: model var: c[i] to: m]];
      for (ORInt i=1; i<=nbv; i++) {
         for(ORInt j =i+1;j <= nbv;j++) {
            if ([adj at: i :j])
               [model add: [ORFactory notEqual: model var: c[i] to: c[j]]];
         }
      }
      [model minimize: m];
      
      id<CPProgram> cp = [ORFactory createCPProgram: model];
      [cp solve: ^{
         __block ORInt maxc  = 0;
         for(ORInt i=[V low];i <= [V up];i++) {
            if ([c[i] bound])
               maxc = maxc > [c[i] value] ? maxc : [c[i] value];
         }
         NSLog(@"Initial MAXC  = %d",maxc);
         NSLog(@"%d ",[m max]);

         [cp forall:V suchThat:^bool(ORInt i) { return ![c[i] bound];} orderedBy:^ORInt(ORInt i) { return ([c[i] domsize]<< 16) - [deg at:i];} do:^(ORInt i) {
            [cp tryall:V suchThat:^bool(ORInt v) { return v <= maxc+1 && [c[i] member: v];} in:^(ORInt v) {
               [cp label: c[i] with: v];
               maxc = maxc > v ? maxc : v;
            }
            onFailure:^(ORInt v) {
               [cp diff: c[i] with:v];
            }];
         }];
         [cp label:m with:[m min]];
         NSLog(@"coloring with: %d colors %p",[m value],[NSThread currentThread]);
      }];
      
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
//      [cp release];
//      [CPFactory shutdown];
   }
   return 0;
}

//int main(int argc, const char * argv[])
//{
//   @autoreleasepool {
//      ORLong startTime = [ORRuntimeMonitor wctime];
//      id<ORModel> model = [ORFactory createModel];
//      //FILE* dta = fopen("smallColoring.col","r");
//      //FILE* dta = fopen("test-n30-e50.col","r");
//      FILE* dta = fopen("test-n80-p40-0.col","r");
//      int nbv = 0,nbe = 0;
//      fscanf(dta,"%d %d",&nbv,&nbe);
//      nbe -= 1;
//      id<ORIntRange> V = [ORFactory intRange:model low:1 up:nbv];
//      id<ORIntMatrix> adj = [ORFactory intMatrix:model range:V :V];
//      for (ORInt i=1; i<=nbv; i++) {
//         for(ORInt j =1;j <= nbv;j++) {
//            [adj set:NO at: i : j];
//         }
//      }
//      for(ORInt i = 1;i<=nbe;i++) {
//         ORInt a,b;
//         fscanf(dta,"%d %d ",&a,&b);
//         [adj set:YES at:a : b];
//         [adj set:YES at: b: a];
//      }
//      id<ORIntArray> deg = [ORFactory intArray:model range:V with:^ORInt(ORInt i) {
//         ORInt d = 0;
//         for(ORInt j=1;j <= nbv;j++)
//            d +=  [adj at:i :j];
//         return d;
//      }];
//      
//      id<ORIntVarArray> c  = [ORFactory intVarArray:model range:V domain: V];
//      id<ORIntVar>      m  = [ORFactory intVar:model domain:V];
//      for(ORInt i=1;i<=nbv;i++)
//         [model add: [c[i] leq: m]];
//      for (ORInt i=1; i<=nbv; i++) {
//         for(ORInt j =i+1;j <= nbv;j++) {
//            if ([adj at: i :j])
//               [model add: [c[i] neq: c[j]]];
//         }
//      }
//      [model minimize: m];
//
//      //NSLog(@"Model: %@",model);
//
//      //id<CPSolver> cp = [CPFactory createSolver];
//      //id<CPSemSolver> cp = [CPFactory createSemSolver:[ORSemDFSController class]];
//      //id<CPSemSolver> cp = [CPFactory createSemSolver:[ORSemBDSController class]];
//      id<CPSolver> cp = [CPFactory createParSolver:2 withController:[ORSemDFSController class]];
//      //id<CPParSolver> cp = [CPFactory createParSolver:2 withController:[ORSemBDSController class]];
//      [cp addModel: model];
//      
//      [cp solve: ^{
//         __block ORInt depth = 0;
//         __block ORInt maxc  = 0;
//         for(ORInt i=[V low];i <= [V up];i++) {
//            if ([c[i] bound])
//               maxc = maxc > [c[i] value] ? maxc : [c[i] value];
//         }
//         NSLog(@"Initial MAXC  = %d",maxc);
//         NSLog(@"%d ",[m max]);
//         [cp forall:V suchThat:^bool(ORInt i) { return ![c[i] bound];} orderedBy:^ORInt(ORInt i) { return ([c[i] domsize]<< 16) - [deg at:i];} do:^(ORInt i) {
//            id<ORIntVar> ci = [c[i] dereference]; // [ldm] this line alone saves 3 seconds over 20s of runtime in //.
//            [cp tryall:V suchThat:^bool(ORInt v) { return v <= maxc+1 && [ci member:v];} in:^(ORInt v) {
//               //NSLog(@"%@?c[%d]==%d  (var:%@)",tab(depth),i,v,c[i]);
//               [cp label:ci with:v];
//               //NSLog(@"%@ c[%d]==%d  (var:%@)",tab(depth),i,v,c[i]);
//               maxc = maxc > v ? maxc : v;
//            } onFailure:^(ORInt v) {
//               [cp diff:ci with:v];
//            }];
//            depth++;
//         }];
//         [cp label:m with:[m min]];
//         NSLog(@"coloring with: %d colors %p",[m value],[NSThread currentThread]);
//      }];
//
//      ORLong endTime = [ORRuntimeMonitor wctime];
//      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
//      NSLog(@"Solver status: %@\n",cp);
//      NSLog(@"Quitting");
//      [cp release];
//      [CPFactory shutdown];
//   }
//   return 0;
//}

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}
