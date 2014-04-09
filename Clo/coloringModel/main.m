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

#import "ORCmdLineArgs.h"
#import <stdlib.h>

NSString* tab(int d);

typedef struct {
   ORInt i;
   ORInt j;
} Edge;

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      //      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      //      [args measure:^struct ORResult(){
      ORInt relaxCount = atoi(argv[2]);
      ORInt cliqueCount = atoi(argv[1]);
      ORFloat timeLimit = 5 * 60;
      
      id<ORModel> model = [ORFactory createModel];
      FILE* dta = fopen("/Users/dan/Desktop/clique.col","r");
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
      sa[1] = [ORFactory intSet: model];
      [sa[1] insert: 5];
      for(ORInt i=1;i<=nbv;i++) {
         [model add: [c[i] leq: m]];
      }
      for(ORInt k = 0;k<nbe;k++) {
         ORInt i = edges[k].i;
         ORInt j = edges[k].j;
         //[model add: [c[i] neq: c[j]]];
         id<ORConstraint> cstr = [model add: [ORFactory notEqual: model var: c[i] to: c[j]]];
         if(nbe - k <= relaxCount) [coupledCstr addObject: cstr];
         else [nonCoupledCstr addObject: cstr];
      }
      [model minimize: m];
      free(edges);
      
      
      // --------------------------------------------------------------------------------------
      NSArray* split = [ORSubgradientTemplate autosplitVariables: [c toNSArray] constraints: nonCoupledCstr];
      NSMutableArray* varSets = [[NSMutableArray alloc] initWithCapacity: split.count];
      [split enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL* stop) {
         NSArray* allObjs = [(NSSet*)obj allObjects];
         [varSets addObject: [ORFactory idArray: model NSArray: allObjs]];
      }];
      
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
      [coupledCstr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
         id<ORNEqual> cstr = obj;
         __block BOOL toRelax = YES;
         [maxCliques enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
            NSSet* clique = obj;
            if([clique containsObject: [cstr left]] || [clique containsObject: [cstr right]]) {
               toRelax = NO;
               *stop = YES;
            }
         }];
         if(toRelax) [relaxCstrs addObject: cstr];
      }];
      
      
      
      id<ORModel> lm = [ORFactory linearizeModel: model];
      // --------------------------------------------------------------------------------------

      
      FILE* f = fopen("/Users/dan/Desktop/ALL.txt", "a+");
      fprintf(f, "\n%i-%i-%i--------------------\n", nbv, cliqueCount, relaxCount);
      
      ORLagrangianTransform* t = [ORFactory lagrangianViolationTransform];
      id<ORParameterizedModel> lagrangeModel = [t apply: lm relaxing: relaxCstrs];
      id<ORRunnable> r = [ORFactory MIPSubgradient: lagrangeModel bound: 15];
      [r setTimeLimit: timeLimit];
      //[(MIPSubgradient*)r setSolverTimeLimit: 5];
      NSDate* t0 = [NSDate date];
      [r run];
      NSDate* t1 = [NSDate date];
      NSTimeInterval time = [t1 timeIntervalSinceDate: t0];
      if(time > timeLimit) time = timeLimit;
      ORFloat bnd = [(id<ORLagrangeRelax>)r bestBound];
      NSLog(@"MIP: %f", bnd);
      if(fabs(bnd) > 1000) bnd = -1;
      id<ORSolution> sol = [(id<ORLagrangeRelax>)r bestSolution];
      ORFloat inc = sol ? [[sol objectiveValue] floatValue] : -1;
      if(fabs(inc) > 1000) inc = -1;
      [lagrangeModel release];
      [t release];
      [r release];
      fprintf(f, "LR: %f %f %f %i\n", time, bnd, inc, [r iterations]);
      fflush(f);
      
      t = [ORFactory lagrangianViolationTransform];
      lagrangeModel = [t apply: lm relaxing: relaxCstrs];
      r = [ORFactory MIPSubgradient: lagrangeModel bound: 15];
      [r setTimeLimit: timeLimit];
      //[(MIPSubgradient*)r setSolverTimeLimit: 5];
      t0 = [NSDate date];
      [r run];
      t1 = [NSDate date];
      time = [t1 timeIntervalSinceDate: t0];
      if(time > timeLimit) time = timeLimit;
      bnd = [(id<ORLagrangeRelax>)r bestBound];
      if(fabs(bnd) > 1000) bnd = -1;
      sol = [(id<ORLagrangeRelax>)r bestSolution];
      inc = sol ? [[sol objectiveValue] floatValue] : -1;
      if(fabs(inc) > 1000) inc = -1;
      [lagrangeModel release];
      [t release];
      [r release];
      fprintf(f, "LRV: %f %f %f %i\n", time, bnd, inc, [r iterations]);
      fflush(f);
      
      ORSoftifyTransform* t2 = [ORFactory softifyModelTransform];
      lagrangeModel = [t2 apply: lm relaxing: relaxCstrs];
      id<ORRunnable> r2 = [ORFactory MIPRunnable: lagrangeModel];
      [r2 setTimeLimit: timeLimit];
      //[(MIPSubgradient*)r setSolverTimeLimit: 5];
      t0 = [NSDate date];
      [r2 run];
      t1 = [NSDate date];
      time = [t1 timeIntervalSinceDate: t0];
      if(time > timeLimit) time = timeLimit;
      bnd = [r2 bestBound];
      if(fabs(bnd) > 1000) bnd = -1;
      sol = [r2 bestSolution];
      inc = sol ? [[sol objectiveValue] floatValue] : -1;
      if(fabs(inc) > 1000) inc = -1;
      [lagrangeModel release];
      [t2 release];
      [r2 release];
      fprintf(f, "PRI: %f %f %f\n", time, bnd, inc);
      fflush(f);
      
      r = [ORFactory MIPRunnable: lm];
      [r setTimeLimit: timeLimit];
      //[(MIPSubgradient*)r setSolverTimeLimit: 5];
      t0 = [NSDate date];
      [r run];
      t1 = [NSDate date];
      time = [t1 timeIntervalSinceDate: t0];
      if(time > timeLimit) time = timeLimit;
      bnd = [(id<ORLagrangeRelax>)r bestBound];
      if(fabs(bnd) > 1000) bnd = -1;
      sol = [(id<ORLagrangeRelax>)r bestSolution];
      inc = sol ? [[sol objectiveValue] floatValue] : -1;
      if(fabs(inc) > 1000) inc = -1;
      [r release];
      fprintf(f, "MIP: %f %f %f\n", time, bnd, inc);
      fflush(f);
      
      
      // TEST CP-LR -----------------------------------------------------------------------
      NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
      NSArray *sds = [NSArray arrayWithObject:sd];
      NSArray* searchSets = [varSets sortedArrayUsingDescriptors: sds];
      
      ORLagrangianTransform* t4 = [ORFactory lagrangianViolationTransform];
      lagrangeModel = [t4 apply: model relaxing: relaxCstrs];
      id<ORIntVarArray> slacks = (id<ORIntVarArray>)[lagrangeModel slacks];
      
      void (^search)(id<CPCommonProgram>) = ^(id<CPCommonProgram> cp){
         for(id<ORIntVarArray> vars in searchSets) {
            //NSLog(@"**CLIQUE: %@",vars);
            
            [vars enumerateWith: ^(id obj, int idx) {
               ORInt maxc = max(0,[cp maxBound: c]);
               //NSLog(@"VARIABLE:%d -  %@ ",idx,obj);
               [cp tryall: V
                 suchThat:^bool(ORInt v) { return v <= maxc+1 && [cp member: v in: obj];}
                       in:^(ORInt v) { [cp label: obj with: v]; }
                onFailure:^(ORInt v) {
                   [cp diff: obj with:v];
                }
                ];
            }];
         }
         [cp label:m with:[cp min: m]];
         [cp labelArray: slacks];
      };
      
      r = [ORFactory CPSubgradient: lagrangeModel bound: nbv search: search];
      [r setTimeLimit: timeLimit];
      t0 = [NSDate date];
      [r run];
      t1 = [NSDate date];
      time = [t1 timeIntervalSinceDate: t0];
      id<ORSolution> bestSol = [r bestSolution];
      ORFloat bnd4 = [[bestSol objectiveValue] floatValue];
      fprintf(f, "CPLR: %f %f %f %i\n", time, bnd4, -1.0, [r iterations]);
      fflush(f);
      [lagrangeModel release];
      [r release];
      [t4 release];
      
      // TEST FULL CP -----------------------------------------------------------------
      __block cpbnd = 99999;
      __block ORFloat bndtime = -1;
      id<CPProgram> cp = [ORFactory createCPProgram: model]; //[args makeProgram:model];
      t0 = [NSDate date];
      [cp solve: ^{
         [cp limitTime: timeLimit * 1000 in: ^{
            //         [cp labelHeuristic:h];
            [cp forall: V
              suchThat:^bool(ORInt i) { return ![cp bound: c[i]];}
             orderedBy: ^ORInt(ORInt i) { return [cp domsize: c[i]]; }
                   and: ^ORInt(ORInt i) { return - [deg at:i];}
                    do: ^(ORInt i) {
                       ORInt maxc = max(0,[cp maxBound: c]);
                       [cp tryall:V suchThat:^bool(ORInt v) { return v <= maxc+1 && [cp member: v in: c[i]];} in:^(ORInt v) {
                          [cp label: c[i] with: v];
                       }
                        onFailure:^(ORInt v) {
                           [cp diff: c[i] with:v];
                        }
                        ];
                    }
             ];
            [cp label:m with:[cp min: m]];
            NSDate* t2 = [NSDate date];
            NSTimeInterval time2 = [t2 timeIntervalSinceDate: t0];
            if([cp intValue:m] < cpbnd) { cpbnd = [cp intValue:m]; bndtime = time2; }
            //NSLog(@"coloring with: %d colors -- time %f",[cp intValue:m], time2);
         }];
      }];
      t1 = [NSDate date];
      time = [t1 timeIntervalSinceDate: t0];
      bnd = [[[[cp solutionPool] best] objectiveValue] floatValue];
      fprintf(f, "CP: %f %f %f %f\n", time, -1.0, bnd, bndtime);
      fflush(f);
      fclose(f);
      
      //         id<ORSolutionPool> pool = [cp solutionPool];
      //         [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
      //         NSLog(@"Solver status: %@\n",cp);
      //         NSLog(@"Quitting");
      //         struct ORResult rep = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
      //         [cp release];
      //         [ORFactory shutdown];
      //         return rep;
      //      }];
   }
   return 0;
}

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}
