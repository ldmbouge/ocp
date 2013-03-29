

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORControl.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORModelTransformation.h>
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

int main_lp(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORFloatVarArray> x = [ORFactory floatVarArray: model range: Columns low:0 up:nbColumns-1];
   id<ORIdArray>      ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      ca[i] = [model add: [Sum(model,j,Columns,[@(coef[i][j]) mul: x[j]]) leq: @(b[i])]];
   [model maximize: Sum(model,j,Columns,[@(c[j]) mul: x[j]])];
   id<LPProgram> lp = [ORFactory createLPProgram: model];
   
   [lp solve];
//   NSLog(@"Objective value: %@",[[model objective] value]);
   id<ORSolution> sol = [[lp solutionPool] best];
   NSLog(@"Solution: %@",sol);
   for(ORInt i = 0; i < nbRows; i++)
      printf("dual c[%d] = %f \n",i,[lp dual: ca[i]]);
   for(ORInt i = 0; i < nbColumns; i++)
      printf("reduced cost x[%d] = %f \n",i,[lp reducedCost: x[i]]);
   NSLog(@"we are done");
   return 0;
}

int main_mip(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Columns];   
   for(ORInt i = 0; i < nbRows; i++)
      [model add: [Sum(model,j,Columns,[x[j] mul: @(coef[i][j])]) leq: @(b[i])]];
   [model maximize: Sum(model,j,Columns,[x[j] mul: @(c[j])])];
   id<MIPProgram> mip = [ORFactory createMIPProgram: model];
   
   [mip solve];
   id<ORSolution> sol = [[mip solutionPool] best];
   NSLog(@"Solution: %@",sol);
   for(ORInt i = 0; i < nbColumns; i++)
      printf("x[%d] = %d \n",i,[sol intValue: x[i]]);
   NSLog(@"we are done");
   
   return 0;
}

int main(int argc, const char * argv[])
{
   return main_lp(argc,argv);
}
