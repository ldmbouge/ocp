

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORControl.h>
#import <ORProgram/ORProgram.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/LPProgram.h>


static int nbRows = 7;
static int nbColumns = 12;

int b[7] = { 18209, 7692, 1333, 924, 26638, 61188, 13360 };
float c[12] = { 96, 76, 56, 11, 86, 10, 66, 86, 83, 12, 9, 81 };
float coef[7][12] = {
   { 19,   1,  10,  1,   1,  14, 152, 11,  1,   1, 1, 1},
   {  0,   4,  53,  0,   0,  80,   0,  4,  5,   0, 0, 0},
   {  4, 660,   3,  0,  30,   0,   3,  0,  4,  90, 0, 0},
   {  7,   0,  18,  6, 770, 330,   7,  0,  0,   6, 0, 0},
   {  0,  20,   0,  4,  52,   3,   0,  0,  0,   5, 4, 0},
   {  0,   0,  40, 70,   4,  63,   0,  0, 60,   0, 4, 0},
   {  0,  32,   0,  0,   0,   5,   0,  3,  0, 660, 0, 9}};


int main2(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORFloatVarArray> x = [ORFactory floatVarArray: model range: Columns low:0 up:nbColumns-1];
   id<ORIdArray>      ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
   for(ORInt i = 0; i < nbRows; i++)
      ca[i] = [model add: [Sum(model,j,Columns,[x[j] muli: coef[i][j]]) leqi: b[i]]];
   [model maximize: Sum(model,j,Columns,[x[j] muli: c[j]])];
   id<LPProgram> lp = [ORFactory createLPProgram: model];
   
   NSLog(@"Model %@",model);
   [lp solve];
   NSLog(@"Objective value: %@",[[model objective] value]);
   id<ORSolution> sol = [model captureSolution];
   NSLog(@"Solution: %@",sol);
   NSLog(@"we are done");
   
   // model already "knows" the solver that implements it (_impl)
   // Now model also records a map from "high-level constraints" to "{implementation constraints}"
   // So model could consult the map to go and retrieve the dual value for the implementation constraints.
   // catch -> that's LP specific functionality in an abstract model! Makes no sense.
   // -> instead have the LPProgram do it by asking the model its map and consulting the mapping to finally
   //    ask the right implementation constraint.
   
   //   [ca enumerateWith:^(id<ORConstraint> obj, int idx) {
   //      ORFloat dca = [lp dual:obj];
   //      NSLog(@"Dual value for constraint[%d] is %f",idx,dca);
   //   }];
   
   //   NSLog(@"Objective: %@  [%f]",o,[o value]);
   return 0;
}

int main1(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   
   // most of this is bogus; just testing without introducing floats
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Columns];
//   id<ORFloatVarArray> x = [ORFactory floatVarArray: model range: Columns];
//   id<ORIntVar>      o = [ORFactory intVar: model domain: Columns];
   
   for(ORInt i = 0; i < nbRows; i++)
      [model add: [Sum(model,j,Columns,[x[j] muli: coef[i][j]]) leqi: b[i]]];
//   [model add: [Sum(model,j,Columns,[x[j] muli: c[j]]) eq: o]];
   id<ORObjectiveFunction> obj = [model maximize: Sum(model,j,Columns,[x[j] muli: c[j]])];
//   [model maximizeExpr: o];
//   NSLog(@"Model %@",model);
//=======
//   id<ORFloatVarArray> x = [ORFactory floatVarArray: model range: Columns low:0 up:nbColumns-1];
//   id<ORFloatVar>      o = [ORFactory floatVar: model low:0 up:nbColumns-1];
//   id<ORIdArray>      ca = [ORFactory idArray:model range:RANGE(model,0,nbRows-1)];
//   for(ORInt i = 0; i < nbRows; i++)
//      ca[i] = [model add: [Sum(model,j,Columns,[x[j] muli: coef[i][j]]) leqi: b[i]]];
//   [model add: [Sum(model,j,Columns,[x[j] muli: c[j]]) eq: o]];
//   [model maximize: o];
//>>>>>>> 59fe343c99c52477bcafa24fe98497d22235c26b
   id<LPProgram> lp = [ORFactory createLPProgram: model];
   
   NSLog(@"Model %@",model);
   [lp solve];
   NSLog(@"Objective value: %@",[obj value]);
   id<ORSolution> sol = [model captureSolution];
   NSLog(@"Solution: %@",sol);
   NSLog(@"we are done");
   
   // model already "knows" the solver that implements it (_impl)
   // Now model also records a map from "high-level constraints" to "{implementation constraints}"
   // So model could consult the map to go and retrieve the dual value for the implementation constraints.
   // catch -> that's LP specific functionality in an abstract model! Makes no sense.
   // -> instead have the LPProgram do it by asking the model its map and consulting the mapping to finally
   //    ask the right implementation constraint.

//   [ca enumerateWith:^(id<ORConstraint> obj, int idx) {
//      ORFloat dca = [lp dual:obj];
//      NSLog(@"Dual value for constraint[%d] is %f",idx,dca);
//   }];
   
//   NSLog(@"Objective: %@  [%f]",o,[o value]);
   return 0;
}

int main3(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   
   // most of this is bogus; just testing without introducing floats
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Columns];   
   for(ORInt i = 0; i < nbRows; i++)
      [model add: [Sum(model,j,Columns,[x[j] muli: coef[i][j]]) leqi: b[i]]];
   id<ORObjectiveFunction> obj = [model maximize: Sum(model,j,Columns,[x[j] muli: c[j]])];
   id<MIPProgram> mip = [ORFactory createMIPProgram: model];
   
   NSLog(@"Model %@",model);
   [mip solve];
   NSLog(@"Objective value: %@",[obj value]);
   id<ORSolution> sol = [model captureSolution];
   NSLog(@"Solution: %@",sol);
   NSLog(@"we are done");
   
   // model already "knows" the solver that implements it (_impl)
   // Now model also records a map from "high-level constraints" to "{implementation constraints}"
   // So model could consult the map to go and retrieve the dual value for the implementation constraints.
   // catch -> that's LP specific functionality in an abstract model! Makes no sense.
   // -> instead have the LPProgram do it by asking the model its map and consulting the mapping to finally
   //    ask the right implementation constraint.
   
   //   [ca enumerateWith:^(id<ORConstraint> obj, int idx) {
   //      ORFloat dca = [lp dual:obj];
   //      NSLog(@"Dual value for constraint[%d] is %f",idx,dca);
   //   }];
   
   //   NSLog(@"Objective: %@  [%f]",o,[o value]);
   return 0;
}

int main(int argc, const char * argv[])
{
   return main2(argc,argv);
}
