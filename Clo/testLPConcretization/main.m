/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
#import <ORProgram/ORSolution.h>
#import <ORProgram/LPProgram.h>


static int nbRows = 7;
static int nbColumns = 12;

float b[7] = { 18209, 7692, 1333, 924, 26638, 61188, 13360 };
float c[12] = { 96, 76, 56, 11, 86, 10, 66, 86, 83, 12, 9, 81 };
float coef[7][12] = {
   { 19,   1,  10,  1,   1,  14, 152, 11,  1,   1, 1, 1},
   {  0,   4,  53,  0,   0,  80,   0,  4,  5,   0, 0, 0},
   {  4, 660,   3,  0,  30,   0,   3,  0,  4,  90, 0, 0},
   {  7,   0,  18,  6, 770, 330,   7,  0,  0,   6, 0, 0},
   {  0,  20,   0,  4,  52,   3,   0,  0,  0,   5, 4, 0},
   {  0,   0,  40, 70,   4,  63,   0,  0, 60,   0, 4, 0},
   {  0,  32,   0,  0,   0,   5,   0,  3,  0, 660, 0, 9}};

int TDP(int argc,const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Binary = [ORFactory intRange: model low: 0 up: 1];
   id<ORIntRange> Constraints = [ORFactory intRange: model low: 0 up: 2];
   id<ORRealVar> ac = [ORFactory floatVar: model low: 0.0 up: 200];
   id<ORRealVar> bc = [ORFactory floatVar: model low: 0.0 up: 200];
   id<ORRealVar> co = [ORFactory floatVar: model low: 0.0 up: 200];
   id<ORIntVar> bac = [ORFactory intVar: model bounds: Binary];
   id<ORIntVar> bbc = [ORFactory intVar: model bounds: Binary];
   id<ORIntVar> bco = [ORFactory intVar: model bounds: Binary];
   id<ORIdArray> ca = [ORFactory idArray:model range: Constraints];
   ca[0] = [model add: [ac leq: [@(70) mul: bac]]];
   ca[1] = [model add: [bc leq: [@(60) mul: bbc]]];
   ca[2] = [model add: [co leq: [@(80) mul: bco]]];
   [model add: [[ac plus: bc] eq: co]];
   [model maximize: [ac plus: bc]];
    
    id<MIPProgram> mip = [ORFactory createMIPProgram: model];
    
    [mip solve];
    id<ORSolution> sol = [[mip solutionPool] best];
    NSLog(@"Solution: %@",sol);
    NSLog(@"Objective value: %@",[sol objectiveValue]);
    printf("ac = %f \n",[sol floatValue: ac]);
    printf("bc = %f \n",[sol floatValue: bc]);
    printf("co = %f \n",[sol floatValue: co]);
    NSLog(@"we are done");
   
   id<ORModel> submodel = [ORFactory createModel];
   id<ORIntRange> Horizon = [ORFactory intRange: submodel low: 1 up: 10];
   id<ORRealVarArray> fac = [ORFactory floatVarArray: submodel range: Horizon low: 0 up: 200];
   id<ORRealVarArray> fbc = [ORFactory floatVarArray: submodel range: Horizon low: 0 up: 200];
   id<ORRealVarArray> fco = [ORFactory floatVarArray: submodel range: Horizon low: 0 up: 200];
   id<ORRealVar> sac = [ORFactory floatVar: submodel];
   id<ORRealVar> sbc = [ORFactory floatVar: submodel];
   id<ORRealVar> sco = [ORFactory floatVar: submodel];

   id<ORIdArray> cac = [ORFactory idArray:submodel range: Horizon];
   id<ORIdArray> cbc = [ORFactory idArray:submodel range: Horizon];
   id<ORIdArray> cco = [ORFactory idArray:submodel range: Horizon];
   
   for(ORInt i=1; i <= 10; i++) {
      if (i == 1)
         cac[i] = [submodel add: [fac[i] leq: @(0 * [sol intValue: bac])]];
      else if (i <= 7)
         cac[i] = [submodel add: [fac[i] leq: @(7 * [sol intValue: bac])]];
      else
         cac[i] = [submodel add: [fac[i] leq: @(0 * [sol intValue: bac])]];
      if (i <= 6)
         cbc[i] = [submodel add: [fbc[i] leq: @(6 * [sol intValue: bbc])]];
      else
         cbc[i] = [submodel add: [fbc[i] leq: @(0 * [sol intValue: bbc])]];
      cco[i] = [submodel add: [fco[i] leq: @(8 * [sol intValue: bco])]];
      [submodel add: [[fac[i] plus: fbc[i]] eq: fco[i]]];
   }
   [submodel add: [sac eq: Sum(submodel,k,Horizon,fac[k])]];
   [submodel add: [sbc eq: Sum(submodel,k,Horizon,fbc[k])]];
   [submodel add: [sco eq: Sum(submodel,k,Horizon,fco[k])]];
//   id<ORConstraint> demand = [submodel add: [sac leq: @(10)]];
   [submodel maximize: [sac plus: sbc]];
   id<LPProgram> lp = [ORFactory createLPProgram: submodel];
   
   [lp solve];
   NSLog(@"Solution: %@",[lp objectiveValue]);
   NSLog(@"Objective value: %@",[submodel objective]);
   id<ORSolution> subsol = [[lp solutionPool] best];
   for(ORInt i=1; i <= 10; i++) {
      printf("fac[%d]=%f\n",i,[subsol floatValue: fac[i]]);
      printf("fbc[%d]=%f\n",i,[subsol floatValue: fbc[i]]);
      printf("fco[%d]=%f\n",i,[subsol floatValue: fco[i]]);
   }
   for(ORInt i=1; i <= 10; i++) {
      printf("dual cac[%d]=%f\n",i,[lp dual: cac[i]]);
      printf("dual cbc[%d]=%f\n",i,[lp dual: cbc[i]]);
      printf("dual cco[%d]=%f\n",i,[lp dual: cco[i]]);
   }
//    printf("dual demand=%f\n",[lp dual: demand]);
   return 0;
}


int main_lp(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORRealVarArray> x = [ORFactory floatVarArray: model range: Columns];
    id<ORIdArray> ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      ca[i] = [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]];
   [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
   id<LPProgram> lp = [ORFactory createLPProgram: model];
   
   [lp solve];
//   NSLog(@"Objective value: %@",[[model objective] value]);
   id<ORSolutionPool> test = [lp solutionPool];
   NSLog(@"test %@",[test best]);
   
   for(ORInt i = 0; i < nbRows; i++) {
      printf("The id of constraint %d is %d \n",i,[ca[i] getId]);
   }
   for(ORInt i = 0; i < nbRows; i++) {
      printf("The dual of constraint %d is %f \n",i,[lp dual: ca[i]]);
   }
   id<ORSolution,LPSolution> sol = [[lp solutionPool] best];
   NSLog(@"Solution: %@",sol);
   for(ORInt i = 0; i < nbColumns-1; i++)
      printf("x[%d] = %10.5f : %10.5f \n",i,[sol floatValue: x[i]],[sol reducedCost: x[i]]);
   for(ORInt i = 0; i < nbRows; i++)
      printf("dual c[%d] = %f \n",i,[sol dual: ca[i]]);
   [sol release];
   NSLog(@"we are done (Part I) \n\n");
   
   id<LPColumn> column = [lp createColumn];
   [column addObjCoef: c[nbColumns - 1]];
   for(ORInt i = 0; i < nbRows; i++)
      [column addConstraint: ca[i] coef: coef[i][nbColumns-1]];
   [lp addColumn: column];
   for(ORInt i = 0; i < nbRows; i++)
      printf("dual c[%d] = %f \n",i,[lp dual: ca[i]]);
   for(ORInt i = 0; i < nbColumns-1; i++)
      printf("reduced cost x[%d] = %f \n",i,[lp reducedCost: x[i]]);
   sol = [[lp solutionPool] best];
   NSLog(@"Solution: %@",sol);
   NSLog(@"Objective function: %@",[sol objectiveValue]);
   NSLog(@"we are done (Part II)");
   [sol release];
   [lp release];
   return 0;
}

int main_mip(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntRange> Domains = [ORFactory intRange: model low: 0 up: MAXINT];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domains];
   for(ORInt i = 0; i < nbRows; i++)
      [model add: [Sum(model,j,Columns,[x[j] mul: @((ORInt)coef[i][j])]) leq: @((ORInt)b[i])]];
   [model maximize: Sum(model,j,Columns,[x[j] mul: @((ORInt)c[j])])];
   
   id<MIPProgram> mip = [ORFactory createMIPProgram: model];
   
   [mip solve];
   id<ORSolution> sol = [[mip solutionPool] best];
   NSLog(@"Solution: %@",sol);
   NSLog(@"Objective value: %@",[sol objectiveValue]);
   for(ORInt i = 0; i < nbColumns; i++)
      printf("x[%d] = %d \n",i,[sol intValue: x[i]]);
   NSLog(@"we are done");
   [mip release];
   return 0;
}

int main_cp(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntRange> Domains = [ORFactory intRange: model low: 0 up: 10000];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domains];
   for(ORInt i = 0; i < nbRows; i++) // nbRows
      [model add: [Sum(model,j,Columns,[x[j] mul: @((ORInt)coef[i][j])]) leq: @((ORInt)b[i])]];
   [model maximize: Sum(model,j,Columns,[x[j] mul: @((ORInt)c[j])])];
   NSLog(@"MODEL: %@",model);
   id<CPProgram> mip = [ORFactory createCPProgram: model];
   id<CPHeuristic> h = [mip createABS];
   [mip solve:^{
      NSLog(@"x = %@",x);
      [mip labelHeuristic:h];
      [mip labelArray:x orderedBy:^ORDouble(ORInt i) {
         return -((ORInt)(c[i]) << 7) +  [mip domsize:x[i]];
      }];
   }];
   id<ORSolution> sol = [[mip solutionPool] best];
   NSLog(@"Solution: %@",sol);
   printf("Objective value: %f \n",[((id<ORObjectiveValueFloat>) [sol objectiveValue]) value]);
   for(ORInt i = 0; i < nbColumns; i++)
      printf("x[%d] = %d \n",i,[sol intValue: x[i]]);
   NSLog(@"we are done");
   [mip release];
   return 0;
}

#import <ORProgram/CPSolver.h>
@interface CPSolver (Addons)
-(void)labelFF:(id<ORIntVarArray>)x;
@end

@implementation CPSolver (Addons)
-(void)labelFF:(id<ORIntVarArray>)x
{
   for (ORInt i=x.range.low; i <= x.range.up; i++) {
      while (![self bound:x[i]]) {
         ORInt v = [self min:x[i]];
         [self try:^{
            [self label:x[i] with:v];
         } or:^{
            [self diff:x[i] with:v];
         }];
      }
   }
}
@end

int main_both(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-2];
   id<ORIntRange> Domains = [ORFactory intRange: model low: 0 up: 10000];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Domains];
   for(ORInt i = 0; i < nbRows; i++)
      [model add: [Sum(model,j,Columns,[x[j] mul: @((ORInt)coef[i][j])]) leq: @((ORInt)b[i])]];
   [model maximize: Sum(model,j,Columns,[x[j] mul: @((ORInt)c[j])])];
   NSLog(@"MODEL: %@",model);

   id<ORModel>    cpm = [model copy];
//   id<MIPProgram> mip = [ORFactory createMIPProgram:model];
//   [mip solve];
//   id<ORMIPSolution> mipSol = [[mip solutionPool] best];
//   id<ORObjectiveValueFloat> mipOBJ = [mipSol objectiveValue];
//   [cpm add: [Sum(model,j,Columns,[x[j] mul: @((ORInt)c[j])]) geq:@((ORInt)[mipOBJ value])]];
   NSLog(@"MODEL: %@",cpm);
   
   id<CPProgram>   cp = [ORFactory createCPProgram: cpm];

   id<CPHeuristic> h = [cp createABS];
   [cp solve:^{
      [cp labelHeuristic:h];
      NSLog(@"Got a solution: %@",[[cp objective] value]);
   }];
   id<ORSolution> cpSol = [[cp solutionPool] best];
   NSLog(@"Solution: %@",cpSol);
   printf("Objective value: %d \n",(ORInt) [(id<ORObjectiveValueInt>) [cpSol objectiveValue] value]);
   for(ORInt i = 0; i < nbColumns; i++)
      printf("x[%d] = %d \n",i,[cpSol intValue: x[i]]);
   NSLog(@"we are done");
   ///[mip release];
   return 0;
}


int main(int argc, const char * argv[])
{
//   int st0 =  main_lp(argc,argv);
   int st1 = TDP(argc,argv);
//   return st0+st1;
   return st1;
//   return st0;
}
