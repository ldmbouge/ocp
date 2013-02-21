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

NSString* tab(int d);


int main(int argc, const char * argvri[])
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
      id<ORIntSetArray> sa = [ORFactory intSetArray: model range: V];
      sa[1] = [ORFactory intSet: model];
      [sa[1] insert: 5];
      for(ORInt i=1;i<=nbv;i++)
         [model add: [c[i] leq: m]];
      for (ORInt i=1; i<=nbv; i++) {
         for(ORInt j =i+1;j <= nbv;j++) {
            if ([adj at: i :j])
               [model add: [c[i] neq: c[j]]];
         }
      }
      [model minimize: m];
      
//      id<CPProgram> cp = [ORFactory createCPProgram: model];
//      id<CPProgram> cp = [ORFactory createCPSemanticProgramDFS: model];
//      id<CPProgram> cp = [ORFactory createCPSemanticProgram: model with: [ORSemDFSController class]];
//      id<CPProgram> cp = [ORFactory createCPSemanticProgram: model with: [ORSemBDSController class]];
      // id<CPProgram> cp = [ORFactory createCPMultiStartProgram: model nb: 2];
      id<CPProgram> cp = [ORFactory createCPParProgram:model nb:2 with:[ORSemDFSController class]];
      [cp solve: ^{
         [cp forall: V
           suchThat:^bool(ORInt i) { return ![c[i] bound];}
          orderedBy: ^ORInt(ORInt i) { return [c[i] domsize]; }
                and: ^ORInt(ORInt i) { return - [deg at:i];}
                 do: ^(ORInt i) {
                    ORInt maxc = max(0,[CPUtilities maxBound: c]);
                    [cp tryall:V suchThat:^bool(ORInt v) { return v <= maxc+1 && [c[i] member: v];} in:^(ORInt v) {
                       [cp label: c[i] with: v];
                    }
                     onFailure:^(ORInt v) {
                        [cp diff: c[i] with:v];
                     }
                     ];
                 }
         ];
         [cp label:m with:[m min]];
         NSLog(@"coloring with: %d colors %d",[m value],[NSThread threadID]);
      }];
      id<ORSolution> sol = [model bestSolution];
      for(ORInt i=1; i <= nbv; i++)
         NSLog(@"Variable %d has color %d",i,[sol intValue: c[i]]);
      NSLog(@"Solution retrieved: %@",sol);
      
      id<ORSolutionPool> pool = [model solutions];
      [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution found with value %@",[s objectiveValue]); } ];
      
      
      ORLong endTime = [ORRuntimeMonitor wctime];
      NSLog(@"Execution Time(WC): %lld \n",endTime - startTime);
      NSLog(@"Solver status: %@\n",cp);
      NSLog(@"Quitting");
      [cp release];
      [ORFactory shutdown];
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
