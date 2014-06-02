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

void weightedSelect(NSArray* src, NSMutableArray* dest) {
   if([src count] == 0) return;
   else {
      ORInt weightSum = 0;
      for(id obj in src) weightSum += [obj count];
      ORInt r = (ORInt)(arc4random() % weightSum);
      id selected = nil;
      for(id obj in src) {
         if(r < [obj count]) { selected = obj; break; }
         else { r -= [obj count]; }
      }
      [dest addObject: selected];
      NSMutableArray* newSrc = [src mutableCopy];
      [newSrc removeObject: selected];
      weightedSelect(newSrc, dest);
   }
}

NSArray* shuffleArray(NSArray* array) {
   NSMutableArray* dest = [[NSMutableArray alloc] init];
   weightedSelect(array, dest);
   return dest;
}

int main(int argc, const char * argv[])
{
   //@autoreleasepool {
   //      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
   //      [args measure:^struct ORResult(){
   [ORStreamManager setRandomized];
   NSString* path = @"/Users/dan/Desktop/clique.col";//[NSString stringWithUTF8String: argv[1]];
   ORInt relaxCount = 846;//atoi(argv[3]);
   ORInt cliqueCount = 2;//atoi(argv[2]);
   ORFloat UB = 130;//atoi(argv[4]);
   ORFloat timeLimit = 5 * 60;
   
   NSLog(@"path: %@ clique: %i, relax: %i, ub: %f", path, cliqueCount, relaxCount, UB);
   
   id<ORModel> model = [ORFactory createModel];
   FILE* dta = fopen([path UTF8String],"r");//fopen("clique.col","r");
   //FILE* dta = fopen("smallColoring.col","r");
   //FILE* dta = fopen("test-n30-e50.col","r");
   //FILE* dta = fopen("test-n80-p40-0.col","r");
   int nbv = 0,nbe = 0;
   fscanf(dta,"%d %d",&nbv,&nbe);
   long fofs = ftell(dta);
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
   fseek(dta,fofs,SEEK_SET);
   Edge* edges = malloc(nbe*sizeof(Edge));
   for(ORInt k = 0;k<nbe;k++) {
      fscanf(dta,"%d %d ",&edges[k].i, &edges[k].j);
   }

   id<ORIntVarArray> c  = [ORFactory intVarArray:model range:V domain: V];
   id<ORIntVar>      m  = [ORFactory intVar:model domain:V];
   id<ORIntSetArray> sa = [ORFactory intSetArray: model range: V];
   
   ORInt lid = 1000000,uid = - 1000000;
   for(ORInt k=V.low;k <= V.up;k++) {
      lid = min(lid,[c[k] getId]);
      uid = max(uid,[c[k] getId]);
   }
   ORInt* vmap = (int*)malloc(sizeof(ORInt)*(uid - lid + 1));
   vmap -= lid;
   for(ORInt k=V.low;k <= V.up;k++) {
      vmap[getId(c[k])] = k;
   }
   
   NSMutableArray* coupledCstr = [[NSMutableArray alloc] init];
   NSMutableArray* nonCoupledCstr = [[NSMutableArray alloc] init];
   id<ORConstraint> cstr;
   sa[1] = [ORFactory intSet: model];
   [sa[1] insert: 5];
   for(ORInt i=1;i<=nbv;i++) {
      cstr = [model add: [c[i] leq: m]];
   }
   id<ORIdMatrix> cm = [ORFactory idMatrix:model range:V :V];
   ORInt k = 0;
   for (ORInt i=1; i<=nbv; i++) {
      for(ORInt j =i+1;j <= nbv;j++) {
         if ([adj at: i :j]) {
            cstr = [model add: [ORFactory notEqual: model var: c[i] to: c[j]]];
            [cm set:cstr at:i :j];
            [cm set:cstr at:j :i];
            k++;
         }
      }
   }
   for(ORInt k=0;k < nbe;k++) {
      ORInt i = edges[k].i;
      ORInt j = edges[k].j;
      cstr = [cm at:i :j];
      if (cstr) {
         if(nbe - k <= relaxCount)
            [coupledCstr addObject: cstr];
         else [nonCoupledCstr addObject: cstr];
      }
      cstr = nil;
      [cm set:cstr at:i :j];
      [cm set:cstr at:j :i];
   }
   [model minimize: m];
//   free(edges);
   
   
   // FIND RELAXATION -------------------------------------------------------------------------------
   NSArray* split = [ORSubgradientTemplate autosplitVariables: [c toNSArray] constraints: nonCoupledCstr];
   
   // Finish Model
   //NSMutableArray* branchVars = [[c toNSArray] mutableCopy];
   NSMutableArray* varSets = [[NSMutableArray alloc] initWithCapacity: split.count];
   for(NSMutableSet* clique in split) {
      //id<ORConstraint> c = nil;
      //id<ORIntVar> cm  = [ORFactory intVar:model domain:V];
      //[branchVars addObject: cm];
      NSMutableArray* allObjs = [[(NSSet*)clique allObjects] mutableCopy];
      //[allObjs addObject: cm];
      [varSets addObject: [ORFactory idArray: model NSArray: allObjs]];
      
      //for(id<ORIntVar> x in clique) {
         //if(x == cm) continue;
         //c = [model add: [x leq: cm track: model]];
         //[nonCoupledCstr addObject: c];
      //}
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
   NSComparisonResult (^myBlock)(id, id) = ^NSComparisonResult(id first, id second){
      ORInt deg1 = 0;
      NSMutableSet* s1 = [[NSMutableSet alloc] initWithCapacity: 16];
      for(ORInt i = [[(id<ORIdArray>)first range] low]; i <= [[(id<ORIdArray>)first range] up]; i++) {
         id v = [(id<ORIdArray>)first at: i];
         ORInt value = [deg at: vmap[getId(v)]];
         if(value > deg1) deg1 = value;
         [s1 addObject: @(value)];
      }
      ORInt deg2 = 0;
      //NSMutableSet* s2 = [[NSMutableSet alloc] initWithCapacity: 16];
      for(ORInt i = [[(id<ORIdArray>)second range] low]; i <= [[(id<ORIdArray>)second range] up]; i++) {
         id v = [(id<ORIdArray>)second at: i];
         ORInt value = [deg at: vmap[getId(v)]];
         if(value > deg2) deg2 = value;
         [s1 addObject: @(value)];
      }
      NSLog(@"%i, %i", [first getId], deg1);
      NSLog(@"-- %i, %lu", [first getId], (unsigned long)[s1 count]);
      
      deg1 = deg1 * (ORInt)[first count];
      deg2 = deg2 * (ORInt)[second count];
//      deg1 = (ORInt)[first count];
//      deg2 = (ORInt)[second count];
      
      if (deg1 < deg2) return NSOrderedAscending;
      else if (deg1 > deg2) return NSOrderedDescending;
      else {
         if([first count] < [second count]) return NSOrderedAscending;
         else if([first count] > [second count]) return NSOrderedDescending;
      }
      return NSOrderedSame;
   };
   NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:NO comparator: myBlock];
   NSArray *sds = [NSArray arrayWithObject:sd];
   __block NSArray* searchSets = [varSets sortedArrayUsingDescriptors: sds];
   NSArray* originalOrdering = [searchSets copy];
//   NSMutableArray* ns = [searchSets mutableCopy];
//   id a = [searchSets objectAtIndex: 3];
//   [ns removeObject: a];
//   [ns insertObject: a atIndex:1];
//   searchSets = ns;
   
   for(id<ORIdArray> arr in searchSets) {
      for(ORInt i = [[arr range] low]; i <= [[arr range] up]; i++) {
         ORInt ids = [[arr at: i] getId];
         NSLog(@"%i", ids);
      }
      NSLog(@"\n\n");
   }
   printf("digraph G { \n");
   id<ORIntArray> rdeg = [ORFactory intArray:model range:V with:^ORInt(ORInt i) { return 0;}];
   NSArray* ac = [model constraints];
   for(id<ORConstraint> c in ac) {
      if (![c conformsToProtocol:@protocol(ORNEqual)]) continue;
      if ([unrelaxCstrs containsObject:c]) {
         NSSet* cv = [c allVars];
         if ([cv count]==2) {
            NSArray* ep = [cv allObjects];
            printf("x_%d -> x_%d [color=red];\n",vmap[[[ep objectAtIndex:0] getId]],vmap[[[ep objectAtIndex:1] getId]]);
         }
      } else {
         NSSet* cv = [c allVars];
         if ([cv count]==2) {
            NSArray* ep = [cv allObjects];
            ORInt a = vmap[[[ep objectAtIndex:0] getId]];
            ORInt b = vmap[[[ep objectAtIndex:1] getId]];
            printf("x_%d -> x_%d;\n",a,b);
            [rdeg set:[rdeg at:a] + 1 at:a];
            [rdeg set:[rdeg at:b] + 1 at:b];
         }
      }
   }
   printf("}\n");
   NSLog(@"DEG    : %@",deg);
   NSLog(@"REDUCED: %@",rdeg);
   

   
   ORLagrangianTransform* t4 = [ORFactory lagrangianViolationTransform];
   id<ORParameterizedModel> lagrangeModel1 = [t4 apply: model relaxing: unrelaxCstrs];
   __block ORSubgradientTemplate* r1 = nil;
   id<ORIntVarArray> slacks1 = (id<ORIntVarArray>)[lagrangeModel1 slacks];
   
   id<ORSolution> sol = nil;
//   __block ORInt myMax = INT_MAX;
   void (^search1)(id<CPCommonProgram>) = ^(id<CPProgram> cp){

      {
      printf("AT START TIME: searchSet: ");
      ORInt k= 0;
      for(id<ORIdArray> ak in searchSets) {
         ORInt as = [ak count];
         __block ORInt maxd = 0,mind=100000;
         [ak enumerateWith:^(id obj, int idx) {
            ORInt vd = [deg at:vmap[getId(obj)]];
            maxd = vd > maxd ? vd : maxd;
            mind = vd < mind ? vd : mind;
//            printf("\tx[%d] deg: %d\n",vmap[getId(obj)],vd);
         }];
         printf("%d(%d,%d - %d),",k++,as,mind,maxd);
      }
      printf("\n");
      }

      __block ORInt CID = 0;
      id<ORMutableInteger> tl = [ORFactory mutable:cp value:500];
      ORBool* limitReached = malloc(sizeof(ORBool));
      *limitReached = YES;
      [cp repeat:^{
         [cp perform:^{
            *limitReached = NO;
            [cp limitTime:[tl intValue]
                       in: ^
             {
                for(id<ORIntVarArray> vars in searchSets) {
                //id<ORIntVarArray> vars = c;
                   //NSLog(@"**CLIQUE: %d -- %@",CID,vars);
                   [cp forall: vars.range
                     suchThat: ^bool(ORInt i) { return ![cp bound: vars[i]];}
                    orderedBy: ^ORInt(ORInt i) {
                       if([r1 lastSolution] == nil)
                          return [cp domsize: vars[i]];
                       ORFloat w = [r1 weightForVar: vars[i] in: [r1 lastSolution]];
                       //NSLog(@"W: %f", w);
                       return w;
                    }
                          and: ^ORInt(ORInt i) {
                             ORInt vid = getId(vars[i]);
                             if (lid <= vid && vid <= uid)
                                return - [rdeg at:vmap[getId(vars[i])]];
                             else return 0;
                          }
                           do: ^(ORInt i) {
                              ORInt maxc = max(0,[cp maxBound: c]);
                              [cp tryall:V suchThat:^bool(ORInt v) { return v <= maxc+1 && [cp member: v in: vars[i]];} in:^(ORInt v) {
                                 //NSLog(@"BRANCH: c[%d] == %d (%d)\n",vmap[getId(vars[i])],v,[deg at:vmap[getId(vars[i])]]);
                                 [cp label: vars[i] with: v];
                              }
                               onFailure:^(ORInt v) {
                                  [cp diff: vars[i] with:v];
                               }
                               ];
                           }
                    ];
                   CID++;
                }
                [cp label:m with:[cp min: m]];
                //[cp labelArray: slacks1];
                [tl setValue:500];
                NSLog(@"coloring: %i  Objective: %@", [cp min: m],[[cp objective] value]);
             //[[cp objective] tightenPrimalBound:[[cp objective] value]];
          }];
         } onLimit:^{
            *limitReached = YES;
            NSLog(@"Did we improve?  [%s]",[tl intValue] == 500 ? "YES" : "NO");
            if ([tl intValue] == 500)
               searchSets = [originalOrdering copy];
            else
               searchSets = shuffleArray(searchSets);
         }];
      } onRepeat:^{
         [tl setValue:(ORInt)((double)[tl intValue] * 1.1)];
         NSLog(@"From the top with: %@  LIMIT = %d",[cp objective],[tl intValue]);
         ORInt k = 0;
         printf("searchSet: ");
         for(id<ORIdArray> ak in searchSets) {
            ORInt as = [ak count];
            __block ORInt maxd = 0,mind=100000;
            [ak enumerateWith:^(id obj, int idx) {
               ORInt vd = [deg at:vmap[getId(obj)]];
               maxd = vd > maxd ? vd : maxd;
               mind = vd < mind ? vd : mind;
            }];
            printf("%d(%d,%d - %d),",k++,as,mind,maxd);
         }
         printf("\n");

      } until:^bool{
         return !*limitReached;
      }
       ];
    
//      ORInt ttlSlacks = 0;
//      for(ORInt k=slacks1.range.low;k <= slacks1.range.up;k++)
//         ttlSlacks += [cp intValue:slacks1[k]];
//      NSLog(@"TTL SLACK: %d",ttlSlacks);
   };
   
   r1 = (ORSubgradientTemplate*)[ORFactory CPSubgradient: lagrangeModel1 bound: UB search: search1];
   [r1 setTimeLimit: timeLimit];
   [(ORSubgradientTemplate*)r1 setAgility: 5.0];//7*UB];
   
   //id<ORRunnable> r1 = [ORFactory CPRunnable:model];
   
   id<CPProgram> cp = [ORFactory createCPProgram: model];
   
   char* outpath = "/Users/dan/Desktop/colorout.txt";
   FILE* f = fopen(outpath, "w+");
   
   NSDate* t0 = [NSDate date];
   [r1 run];
   NSDate* t1 = [NSDate date];
   NSTimeInterval time = [t1 timeIntervalSinceDate: t0];
   ORFloat bestBND = [r1 bestBound];
   int iter = [(ORSubgradientTemplate*)r1 iterations];
   //ORFloat bnd5 = [r1 bestBound];
   //[lagrangeModel1 release];
   //[r0 release];
   //[r1 release];
   //[pr release];
   //[t4 release];
   
   fprintf(f, "%f %i\n", time, bestBND);
   
   t0 = [NSDate date];
   //[cp solve: ^{ [cp limitTime: timeLimit * 1000 in: ^{ search1(cp); }]; }];
   t1 = [NSDate date];
   time = [t1 timeIntervalSinceDate: t0];
   fprintf(f, "%f", time);
   fclose(f);
   
   
   return 0;
}

NSString* tab(int d)
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   for(int i=0;i<d;i++)
      [buf appendString:@"   "];
   return buf;
}
