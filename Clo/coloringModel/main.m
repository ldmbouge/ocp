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

#import "ORCmdLineArgs.h"

NSString* tab(int d);


int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
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
      }
      [model minimize: m];

      //NSLog(@"Model: %@",model);

      //id<CPSolver> cp = [CPFactory createSolver];
      //id<CPSemSolver> cp = [CPFactory createSemSolver:[ORSemDFSController class]];
      id<CPSemSolver> cp = [CPFactory createSemSolver:[ORSemBDSController class]];
      //id<CPSolver> cp = [CPFactory createParSolver:2 withController:[ORSemDFSController class]];
      //id<CPParSolver> cp = [CPFactory createParSolver:2 withController:[ORSemBDSController class]];
      [cp addModel: model];
      
      [cp solve: ^{
         __block ORInt depth = 0;
         __block ORInt maxc  = 0;
         for(ORInt i=[V low];i <= [V up];i++) {
            if ([c[i] bound])
               maxc = maxc > [c[i] value] ? maxc : [c[i] value];
         }
         [model minimize: m];     
//      id<CPProgram> cp = [ORFactory createCPProgram: model];
//      id<CPProgram> cp = [ORFactory createCPSemanticProgramDFS: model];
//      id<CPProgram> cp = [ORFactory createCPSemanticProgram: model with: [ORSemDFSController class]];
//      id<CPProgram> cp = [ORFactory createCPSemanticProgram: model with: [ORSemBDSController class]];
//      id<CPProgram> cp = [ORFactory createCPMultiStartProgram: model nb: 4];
//      id<CPHeuristic> h = [cp createPortfolio:@[@"createIBS:",@"createABS:",@"createWDeg:",@"createFF:"] with:c];
//         id<CPProgram> cp = [ORFactory createCPParProgram:model nb:2 with:[ORSemDFSController class]];
         id<CPProgram> cp = [args makeProgram:model];
         [cp solve: ^{
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
            NSLog(@"coloring with: %d colors %d",[cp intValue:m],[NSThread threadID]);
         }];
         id<ORSolutionPool> pool = [cp solutionPool];
         [pool enumerateWith: ^void(id<ORSolution> s) { NSLog(@"Solution %p found with value %@",s,[s objectiveValue]); } ];
         NSLog(@"Solver status: %@\n",cp);
         NSLog(@"Quitting");
         struct ORResult r = REPORT(1, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return r;
      }];
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
