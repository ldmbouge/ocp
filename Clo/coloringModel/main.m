/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

//014-06-27 14:38:21.817 coloringModel[3194:303] Infinity: [-inf..+inf]
//2014-06-27 14:38:21.818 coloringModel[3194:303] Zero    : [0.00000000000000 .. 0.00000000000000]
//2014-06-27 14:38:21.826 coloringModel[3194:303] local adr is: 0x7fff5fbfefa4
//2014-06-27 14:38:21.826 coloringModel[3194:303] base  adr is: 0x7fff5fbff048
//2014-06-27 14:38:21.826 coloringModel[3194:303] distance    : 164
//2014-06-27 14:38:21.829 coloringModel[3194:303] coloring with: 12 colors 0
//2014-06-27 14:38:21.830 coloringModel[3194:303] coloring with: 11 colors 0
//2014-06-27 14:38:27.431 coloringModel[3194:303] coloring with: 10 colors 0
//2014-06-27 14:38:34.352 coloringModel[3194:303] top-level success
//2014-06-27 14:38:34.352 coloringModel[3194:303] Optimal Solution: 10 thread:0
//2014-06-27 14:38:34.353 coloringModel[3194:303] Solution 0x102736eb0 found with value 12
//2014-06-27 14:38:34.353 coloringModel[3194:303] Solution 0x1007053c0 found with value 11
//2014-06-27 14:38:34.353 coloringModel[3194:303] Solution 0x1027388d0 found with value 10
//2014-06-27 14:38:34.354 coloringModel[3194:303] Solver status: Solver: 81 vars
//1310 constraints
//452212 choices
//452077 fail
//47861724 propagations
//2014-06-27 14:38:34.354 coloringModel[3194:303] Quitting
//2014-06-27 14:38:34.354 coloringModel[3194:303] released 82 continuations out of 82...
//FMT:heur,rand,threads,size,found,restartRate,#f,#c,#p,cpu,wc,mUsed,mPeak
//OUT:FF,0,0,4,1,0.000000,452077,452212,47861724,12530,12537,1381600,1733008
//Program ended with exit code: 0


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
   ORInt relaxCount = 274;//atoi(argv[2]);
   ORInt cliqueCount = 4;//20;//atoi(argv[1]);
      ORFloat timeLimit = 5 * 60;
      
      id<ORModel> model = [ORFactory createModel];
      FILE* dta = fopen("/Users/dan/Desktop/LRPaperStuff/clique.col","r");  // file is located in the executable directory.
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
      
      ORInt (^xdeg)(id<ORIntVar>) = ^ORInt(id<ORIntVar> x) {
         int d = 0;
         for(id<ORConstraint> c in [model constraints]) {
            if([[c allVars] containsObject: x]) d++;
         }
         return d;
      };
   
      // FIND RELAXATION -------------------------------------------------------------------------------
      ORFloat UB = 43;
      NSArray* split = [ORSubgradientTemplate autosplitVariables: [c toNSArray] constraints: nonCoupledCstr];
      NSMutableArray* varSets = [[NSMutableArray alloc] initWithCapacity: split.count];
      [split enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL* stop) {
         NSArray* allObjs = [(NSSet*)obj allObjects];
         [varSets addObject: [ORFactory idArray: model NSArray: allObjs]];
      }];
   
   // DEBUGGING
   NSMutableArray* idSplit = [[NSMutableArray alloc] init];
   NSMapTable* idDeg = [[NSMapTable alloc] init];
   for(NSSet* s in split) {
      NSMutableArray* arr2 = [s allObjects];
      [idSplit addObject: arr2];
      
      for(id<ORIntVar> x in s) {
         [idDeg setObject: @(xdeg(x)) forKey: x];
      }
   }
   
   char label = 'A';
   for(NSArray* arr in idSplit) {
      NSLog(@"clique %c(size = %li)", label++, arr.count);
      ORInt totalDeg = 0;
      for(id<ORIntVar> x in arr) {
         ORInt d = [[idDeg objectForKey: x] intValue];
         NSLog(@"c[%i] (deg=%i)", [x getId]-1, d);
         totalDeg += d;
      }
      NSLog(@"degree of clique %i -------------\n\n", totalDeg);
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
            if([clique containsObject: [cstr left]] || [clique containsObject: [cstr right]]) {
               toRelax = NO;
               *stop = YES;
            }
         }];
         if(toRelax) [relaxCstrs addObject: cstr];
         else [unrelaxCstrs addObject: cstr];
      }];
      
      
      
      id<ORModel> lm = [ORFactory linearizeModel: model];
      id<ORRunnable> r = [ORFactory MIPRunnable: lm numThreads: 1];
   
      // --------------------------------------------------------------------------------------

      char buf[1024];
      sprintf(buf,"%s/Desktop/ALL.txt",getenv("HOME"));
      FILE* f = fopen(buf, "a+");
      fprintf(f, "\n%i-%i-%i--------------------\n", nbv, cliqueCount, relaxCount);
   
   
//      // LR-MIP -------------------------------------------
//      ORLagrangianTransform* t = [ORFactory lagrangianViolationTransform];
//      id<ORParameterizedModel> lagrangeModel0 = [t apply: lm relaxing: relaxCstrs];
//      id<ORParameterizedModel> lagrangeModel1 = [t apply: lm relaxing: unrelaxCstrs];
//
//      id<ORRunnable> r0 = [ORFactory MIPSubgradient: lagrangeModel0 bound: UB];
//      [(ORSubgradientTemplate*)r0 setAgility: 3];
//      id<ORRunnable> r1 = [ORFactory MIPSubgradient: lagrangeModel1 bound: UB];
//      [(ORSubgradientTemplate*)r1 setAgility: 3];
//      //id<ORRunnable> pr = [ORFactory composeCompleteParallel: r0 with: r1];
//      [r0 setTimeLimit: timeLimit];//[pr setTimeLimit: timeLimit];
//      //[(MIPSubgradient*)r setSolverTimeLimit: 5];
//      [r0 run];
//      NSTimeInterval time = [(ORSubgradientTemplate*)r0 runtime];
//      if(time > timeLimit) time = timeLimit;
//      ORFloat bnd = [r0 bestBound];//[pr bestBound];
//      if(fabs(bnd) > 1000) bnd = -1;
//      id<ORSolution> sol = [r0 bestSolution];//[pr bestSolution];
//      ORFloat inc = sol ? [[sol objectiveValue] floatValue] : -1;
//      if(fabs(inc) > 1000) inc = -1;
//      ORInt iter = [r0 iterations];//MAX([r0 iterations], [r1 iterations]);
//      //id<ORRunnable> solved = [pr solvedRunnable];
//      //if(solved) iter = [solved iterations];
//      [t release];
//      [r0 release];
//      [r1 release];
//      //[pr release];
//      [lagrangeModel0 release];
//      //[lagrangeModel1 release];
//      fprintf(f, "LR: %f %f %f %i\n", time, bnd, inc, iter);
//      fflush(f);
//   
//      // LR-MIP Violation -----------------------------------------
//
//      t = [ORFactory lagrangianViolationTransform];
//      lagrangeModel0 = [t apply: lm relaxing: relaxCstrs];
//      //lagrangeModel1 = [t apply: lm relaxing: unrelaxCstrs];
//      r0 = [ORFactory MIPSubgradient: lagrangeModel0 bound: UB];
//      //r1 = [ORFactory MIPSubgradient: lagrangeModel1 bound: UB];
//      //pr = [ORFactory composeCompleteParallel: r0 with: r1];
//      [r0 setTimeLimit: timeLimit];//[pr setTimeLimit: timeLimit];
//      //[(MIPSubgradient*)r setSolverTimeLimit: 5];
//      [r0 run];
//      time = [(ORSubgradientTemplate*)r0 runtime];
//      if(time > timeLimit) time = timeLimit;
//      bnd = [r0 bestBound];//[pr bestBound];
//      if(fabs(bnd) > 1000) bnd = -1;
//      sol = [r0 bestSolution];//[pr bestSolution];
//      inc = sol ? [[sol objectiveValue] floatValue] : -1;
//      if(fabs(inc) > 1000) inc = -1;
//      iter = [r0 iterations];//MAX([r0 iterations], [r1 iterations]);
//      //solved = [pr solvedRunnable];
//      //if(solved) iter = [solved iterations];
//      [t release];
//      [r0 release];
//      //[r1 release];
//      //[pr release];
//      [lagrangeModel0 release];
//      //[lagrangeModel1 release];
//      fprintf(f, "LRV: %f %f %f %i\n", time, bnd, inc, iter);
//      fflush(f);
//   
//      // Full MIP ------------------------------------------
      id<ORRunnable> r = [ORFactory MIPRunnable: lm];
      [r setTimeLimit: timeLimit];
      //[(MIPSubgradient*)r setSolverTimeLimit: 5];
      NSDate* t0 = [NSDate date];
      [r run];
      NSDate* t1 = [NSDate date];
      NSTimeInterval time = [t1 timeIntervalSinceDate: t0];
      if(time > timeLimit) time = timeLimit;
      ORInt bnd = [(id<ORLagrangeRelax>)r bestBound];
      if(fabs(bnd) > 1000) bnd = -1;
      id<ORSolution> sol = [(id<ORLagrangeRelax>)r bestSolution];
      ORFloat inc = sol ? [[sol objectiveValue] floatValue] : -1;
      if(fabs(inc) > 1000) inc = -1;
      [r release];
      fprintf(f, "MIP: %f %f %f\n", time, bnd, inc);
      fflush(f);
//
//      
////      // TEST CP-LR -----------------------------------------------------------------------
//      NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
//      NSArray *sds = [NSArray arrayWithObject:sd];
//      NSArray* searchSets = [varSets sortedArrayUsingDescriptors: sds];
//      
//      ORLagrangianTransform* t4 = [ORFactory lagrangianViolationTransform];
//      lagrangeModel0 = [t4 apply: model relaxing: relaxCstrs];
//      lagrangeModel1 = [t4 apply: model relaxing: unrelaxCstrs];
//      id<ORIntVarArray> slacks0 = (id<ORIntVarArray>)[lagrangeModel0 slacks];
//      id<ORIntVarArray> slacks1 = (id<ORIntVarArray>)[lagrangeModel1 slacks];
//      
//      void (^search0)(id<CPCommonProgram>) = ^(id<CPCommonProgram> cp){
//         for(id<ORIntVarArray> vars in searchSets) {
//            //NSLog(@"**CLIQUE: %@",vars);
//            
//            [vars enumerateWith: ^(id obj, int idx) {
//               ORInt maxc = max(0,[cp maxBound: c]);
//               //NSLog(@"VARIABLE:%d -  %@ ",idx,obj);
//               [cp tryall: V
//                 suchThat:^bool(ORInt v) { return v <= maxc+1 && [cp member: v in: obj];}
//                       in:^(ORInt v) { [cp label: obj with: v]; }
//                onFailure:^(ORInt v) {
//                   [cp diff: obj with:v];
//                }
//                ];
//            }];
//         }
//         [cp label:m with:[cp min: m]];
//         [cp labelArray: slacks0];
//      };
//      
//      void (^search1)(id<CPCommonProgram>) = ^(id<CPCommonProgram> cp){
//         for(id<ORIntVarArray> vars in searchSets) {
//            //NSLog(@"**CLIQUE: %@",vars);
//            
//            [vars enumerateWith: ^(id obj, int idx) {
//               ORInt maxc = max(0,[cp maxBound: c]);
//               //NSLog(@"VARIABLE:%d -  %@ ",idx,obj);
//               [cp tryall: V
//                 suchThat:^bool(ORInt v) { return v <= maxc+1 && [cp member: v in: obj];}
//                       in:^(ORInt v) { [cp label: obj with: v]; }
//                onFailure:^(ORInt v) {
//                   [cp diff: obj with:v];
//                }
//                ];
//            }];
//         }
//         [cp label:m with:[cp min: m]];
//         [cp labelArray: slacks1];
//      };
//      
//      r0 = [ORFactory CPSubgradient: lagrangeModel0 bound: UB search: search0];
//      [(ORSubgradientTemplate*)r0 setAgility: 30];
//      r1 = [ORFactory CPSubgradient: lagrangeModel1 bound: UB search: search1];
//      [(ORSubgradientTemplate*)r1 setAgility: 30];
//      id<ORRunnable> pr = [ORFactory composeCompleteParallel: r0 with: r1];
//      [pr setTimeLimit: timeLimit];
//
//      t0 = [NSDate date];
//      [pr run];
//      t1 = [NSDate date];
//      time = [t1 timeIntervalSinceDate: t0];
//      ORFloat bnd4 = [pr bestBound];
//      iter = MAX([(ORSubgradientTemplate*)r0 iterations], [(ORSubgradientTemplate*)r1 iterations]);
//      id<ORRunnable> solved = [pr solvedRunnable];
//      if(solved) iter = [solved iterations];
//      if(fabs(bnd4) > 1000) bnd4 = -1;
//      fprintf(f, "CPLR: %f %f %f %i\n", time, bnd4, -1.0, iter);
//      fflush(f);
//      [lagrangeModel0 release];
//      [lagrangeModel1 release];
//      [r0 release];
//      [r1 release];
//      [pr release];
//      [t4 release];
   
      // TEST FULL CP -----------------------------------------------------------------
      __block cpbnd = 99999;
      __block ORFloat bndtime = -1;
      id<CPProgram> cp = [ORFactory createCPProgram: model]; //[args makeProgram:model];
      t0 = [NSDate date];
      id<CPHeuristic> heur = [cp createFF];
      [cp solve: ^{
         [cp labelHeuristic: heur];
         id<ORSolution> sol = [cp captureSolution];
         NSLog(@"new objective bound: %i", [[sol objectiveValue] intValue]);
         
         [cp limitTime: timeLimit * 1000 in: ^{
            //         [cp labelHeuristic:h];
            [cp forall: V
              suchThat:^ORBool(ORInt i) { return ![cp bound: c[i]];}
             orderedBy: ^ORInt(ORInt i) { return [cp domsize: c[i]]; }
                  then: ^ORInt(ORInt i) { return - [deg at:i];}
                    do: ^(ORInt i) {
                       ORInt maxc = max(0,[cp maxBound: c]);
                       [cp tryall:V suchThat:^ORBool(ORInt v) { return v <= maxc+1 && [cp member: v in: c[i]];} in:^(ORInt v) {
                          [cp label: c[i] with: v];
                       }
                        onFailure:^(ORInt v) {
                           [cp diff: c[i] with:v];
                        }
                        ];
                    }
             ];
            [cp label:m with:[cp min: m]];
            NSLog(@"coloring with: %d colors %d and first variable %d",[cp intValue:m],[NSThread threadID],[cp intValue: c[1]]);
         }];
         id<ORSolutionPool> pool = [cp solutionPool];
         [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@ and first variable %d",s,[s objectiveValue],[s intValue: c[1]]); } ];
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
      t1 = [NSDate date];
      time = [t1 timeIntervalSinceDate: t0];
      ORFloat bnd2 = [[[[cp solutionPool] best] objectiveValue] floatValue];
      fprintf(f, "CP: %f %f %f %f\n", time, -1.0, bnd2, bndtime);
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
   //}
   return 0;
}

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}
