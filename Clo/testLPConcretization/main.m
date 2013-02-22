

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


int main(int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   
   // most of this is bogus; just testing without introducing floats
   id<ORIntRange> Columns = [ORFactory intRange: model low: 0 up: nbColumns-1];
   id<ORIntVarArray> x = [ORFactory intVarArray: model range: Columns domain: Columns];
   id<ORIntVar>      o = [ORFactory intVar: model domain: Columns];
   
   for(ORInt i = 0; i < nbRows; i++)
      [model add: [Sum(model,j,Columns,[x[j] muli: coef[i][j]]) leqi: b[i]]];
   [model add: [Sum(model,j,Columns,[x[j] muli: b[j]]) eq: o]];
   [model minimize: o];
//   NSLog(@"Model %@",model);
   id<LPProgram> lp = [ORFactory createLPProgram: model];
   [lp solve];
   NSLog(@"we are done");
   return 0;
}
