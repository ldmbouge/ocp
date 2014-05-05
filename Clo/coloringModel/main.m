/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORControl.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORModeling/ORLinearize.h>
#import <ORProgram/ORRunnable.h>
#import <ORProgram/ORLagrangeRelax.h>
#import <ORProgram/ORLagrangianTransform.h>
#import <ORProgram/ORParallelCombinator.h>

#import "ORCmdLineArgs.h"
#import <stdlib.h>

NSString* tab(int d);

typedef struct {
   ORInt i;
   ORInt j;
} Edge;

int main(int argc, const char * argv[])
{
   //@autoreleasepool {
   //      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
   //      [args measure:^struct ORResult(){
   ORInt relaxCount = 201;//atoi(argv[2]);
   ORInt cliqueCount = 20;//atoi(argv[1]);
   ORFloat UB = 75;//atoi(argv[3]);
   ORFloat timeLimit = 5 * 60;
   
   id<ORModel> model = [ORFactory createModel];
   FILE* dta = fopen("clique.col","r");  // file is located in the executable directory.
   //FILE* dta = fopen("smallColoring.col","r");
   //FILE* dta = fopen("test-n30-e50.col","r");
   //FILE* dta = fopen("test-n80-p40-0.col","r");
   int nbv = 0,nbe = 0;
   fscanf(dta,"%d %d",&nbv,&nbe);
   nbe -= 1;
   id<ORIntRange> V = [ORFactory intRange:model low:1 up:nbv];
   Edge* edges = malloc(nbe*sizeof(Edge));
   for(ORInt k = 0;k<nbe;k++) {
      fscanf(dta,"%d %d ",&edges[k].i, &edges[k].j);
   }
   id<ORIntArray> deg = [ORFactory intArray:model range:V with:^ORInt(ORInt i) {
      ORInt d = 0;
      for(ORInt k = 0;k<nbe;k++)
         if(edges[k].i == i || edges[k].j == i) d++;
      return d;
   }];
   
   id<ORIntVarArray> c  = [ORFactory intVarArray:model range:V domain: V];
   id<ORIntVar>      m  = [ORFactory intVar:model domain:V];
   id<ORIntSetArray> sa = [ORFactory intSetArray: model range: V];
   NSMutableArray* coupledCstr = [[NSMutableArray alloc] init];
   NSMutableArray* nonCoupledCstr = [[NSMutableArray alloc] init];
   id<ORConstraint> cstr;
   sa[1] = [ORFactory intSet: model];
   [sa[1] insert: 5];
   for(ORInt i=1;i<=nbv;i++) {
      cstr = [model add: [c[i] leq: m]];
   }
   for(ORInt k = 0;k<nbe;k++) {
      ORInt i = edges[k].i;
      ORInt j = edges[k].j;
      //[model add: [c[i] neq: c[j]]];
      cstr = [model add: [ORFactory notEqual: model var: c[i] to: c[j]]];
      if(nbe - k <= relaxCount) [coupledCstr addObject: cstr];
      else [nonCoupledCstr addObject: cstr];
   }
   [model minimize: m];
   free(edges);
   
   
   // FIND RELAXATION -------------------------------------------------------------------------------
   NSArray* split = [ORSubgradientTemplate autosplitVariables: [c toNSArray] constraints: nonCoupledCstr];
   
   // Finish Model
   NSMutableArray* branchVars = [[c toNSArray] mutableCopy];
   NSMutableArray* varSets = [[NSMutableArray alloc] initWithCapacity: split.count];
   for(NSMutableSet* clique in split) {
      id<ORConstraint> c = nil;
      id<ORIntVar> cm  = [ORFactory intVar:model domain:V];
      [branchVars addObject: cm];
      NSMutableArray* allObjs = [[(NSSet*)clique allObjects] mutableCopy];
      [allObjs addObject: cm];
      [varSets addObject: [ORFactory idArray: model NSArray: allObjs]];
      
      for(id<ORIntVar> x in clique) {
         if(x == cm) continue;
         //c = [model add: [x leq: cm track: model]];
         //[nonCoupledCstr addObject: c];
      }
      //c = [model add: [m geq: cm track: model]];
      //[coupledCstr addObject: c];
   }
   
   NSMutableArray* maxCliques = [[NSMutableArray alloc] initWithCapacity: 8];
   __block ORInt maxCliqueSize = 0;
   [split enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL* stop) {
      NSSet* clique = obj;
      if([clique count] > maxCliqueSize) maxCliqueSize = (ORInt)[clique count];
   }];
   [split enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL* stop) {
      NSSet* clique = obj;
      if([clique count] == maxCliqueSize) [maxCliques addObject: clique];
   }];
   
   NSMutableArray* relaxCstrs = [[NSMutableArray alloc] initWithCapacity: 256];
   NSMutableArray* unrelaxCstrs = [[NSMutableArray alloc] initWithCapacity: 256];
   [coupledCstr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
      id<ORNEqual> cstr = obj;
      __block BOOL toRelax = YES;
      [maxCliques enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
         NSSet* clique = obj;
         //if(![clique respondsToSelector: @selector(left)]) return; //////////////////////////////// REMOVE ///////////
         if([clique containsObject: [cstr left]] || [clique containsObject: [cstr right]]) {
            toRelax = NO;
            *stop = YES;
         }
      }];
      if(toRelax) [relaxCstrs addObject: cstr];
      else [unrelaxCstrs addObject: cstr];
   }];
   
   //      // TEST CP-LR -----------------------------------------------------------------------
   NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
   NSArray *sds = [NSArray arrayWithObject:sd];
   NSArray* searchSets = [varSets sortedArrayUsingDescriptors: sds];
   
   NSMutableArray* searchC = [[NSMutableArray alloc] init];
   NSMutableArray* searchNC = [[NSMutableArray alloc] init];
   for(id<ORIdArray> s in searchSets) {
      NSMutableSet* ns = [[NSMutableSet alloc] init];
      NSMutableSet* nns = [[NSMutableSet alloc] init];
      [s enumerateWith: ^(id x, ORInt idx) {
         if([c contains: x]) [ns addObject: x];
         else [nns addObject: x];
      }];
      [searchC addObject: ns];
      [searchNC addObject: nns];
   }
   
   ORLagrangianTransform* t4 = [ORFactory lagrangianViolationTransform];
   id<ORParameterizedModel> lagrangeModel1 = [t4 apply: model relaxing: unrelaxCstrs];
   id<ORIntVarArray> slacks1 = (id<ORIntVarArray>)[lagrangeModel1 slacks];
   
   void (^search1)(id<CPCommonProgram>) = ^(id<CPProgram> cp){
      //         for(id<ORIntVarArray> vars in searchSets) {
      //            //NSLog(@"**CLIQUE: %@",vars);
      //            [vars enumerateWith: ^(id obj, int idx) {
      //               if(![cp bound: obj]) {
      //                  ORInt maxc = max(0,[cp maxBound: c]);
      //               //NSLog(@"VARIABLE:%d -  %@ ",idx,obj);
      //               [cp tryall: V
      //                 suchThat:^bool(ORInt v) { return v <= maxc+1 && [cp member: v in: obj];}
      //                       in:^(ORInt v) { [cp label: obj with: v]; }
      //                onFailure:^(ORInt v) {
      //                   [cp diff: obj with:v];
      //                }];
      //               }
      //            }];
      //         }
      [cp limitCondition:^bool{
         ORInt ttlSlacks = 0;
         for(ORInt k=slacks1.range.low;k <= slacks1.range.up;k++)
            if (![cp bound:slacks1[k]])
               return false;
         for(ORInt k=slacks1.range.low;k <= slacks1.range.up;k++)
            ttlSlacks += [cp intValue:slacks1[k]];
         return (ttlSlacks == 0);
      } in:^{
         
         __block ORInt maxc = 0;
         ORInt CID = 0;
         for(NSSet* vars in searchC) {
            NSLog(@"In component... %d",CID);
            for(id obj in vars) {
               if(![cp bound: obj]) {
                  //NSLog(@"VARIABLE:%d -  %@ ",idx,obj);
                  [cp tryall: V
                    suchThat:^bool(ORInt v) { return v <= maxc+1 && [cp member: v in: obj];}
                          in:^(ORInt v) { [cp label: obj with: v]; maxc = max(maxc, v); }
                   onFailure:^(ORInt v) {
                      [cp diff: obj with:v];
                   }];
               }
            }
            CID++;
         }
         NSLog(@"First loop...");
         for(NSSet* vars in searchNC) {
            for(id obj in vars) {
               if(![cp bound: obj]) {
                  //NSLog(@"VARIABLE:%d -  %@ ",idx,obj);
                  [cp tryall: V
                    suchThat:^bool(ORInt v) { return v <= maxc+1 && [cp member: v in: obj];}
                          in:^(ORInt v) { [cp label: obj with: v]; maxc = max(maxc, v); }
                   onFailure:^(ORInt v) {
                      [cp diff: obj with:v];
                   }];
               }
            }
         }
         
         [cp label:m with:[cp min: m]];
         [cp labelArray: slacks1];
         NSLog(@"coloring: %i", [cp min: m]);
         NSLog(@"Objective: %@",[[cp objective] value]);
      }];
   };
   
   id<ORRunnable> r1 = [ORFactory CPSubgradient: lagrangeModel1 bound: UB search: search1];
   [r1 setTimeLimit: timeLimit];
   [(ORSubgradientTemplate*)r1 setAgility: 7*UB];
   
   NSDate* t0 = [NSDate date];
   [r1 run];
   NSDate* t1 = [NSDate date];
   NSTimeInterval time = [t1 timeIntervalSinceDate: t0];
   int iter = [(ORSubgradientTemplate*)r1 iterations];
   ORFloat bnd5 = [r1 bestBound];
   [lagrangeModel1 release];
   //[r0 release];
   //[r1 release];
   //[pr release];
   [t4 release];
   
   NSLog(@"time: %f iter: %i", time, iter);
   
   return 0;
}

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}
